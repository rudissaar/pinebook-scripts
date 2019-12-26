#!/usr/bin/env bash
# Script that improves battery configuration for i3status bar.

I3_STATUS_CONFIG_FILE='/etc/i3status.conf'

# You need root permissions to run this script.
if [[ "${UID}" != '0' ]]; then
    echo '> You need to become root to run this script.'
    echo '> Aborting.'
    exit 1
fi

# Function that checks if required binary exists and installs it if necassary.
ENSURE_DEPENDENCY () {
    REQUIRED_BINARY=$(basename "${1}")
    REPO_PACKAGES="${*:2}"
    [[ ! -z "${REPO_PACKAGES}" ]] || REPO_PACKAGES="${REQUIRED_BINARY}"

    if ! command -v "${REQUIRED_BINARY}" 1> /dev/null; then
        if [[ "${REPO_UPDATED}" == '0' ]]; then
            apt update
            REPO_UPDATED=1
        fi

        for REPO_PACKAGE in ${REPO_PACKAGES}
        do
            apt install -y "${REPO_PACKAGE}"
        done
    fi
}

# Variable that keeps track if repository is already refreshed.
REPO_UPDATED=0

# Install packages if necassary.
ENSURE_DEPENDENCY 'sed'
ENSURE_DEPENDENCY 'grep'

# Rename battery all to battery 0.
sed -i '/^order += "battery all"$/s/all/0/' "${I3_STATUS_CONFIG_FILE}"
sed -i '/^battery all {$/s/all/0/' "${I3_STATUS_CONFIG_FILE}"

# Find battery device path and uevent node.
SEARCH_PATH="$(find /sys/devices/platform/soc -name "*battery" 2> /dev/null | head -n 1)"
UEVENT_PATH=$(find "${SEARCH_PATH}" -maxdepth 1 -name uevent)

if [[ ! -z "${UEVENT_PATH}" ]]; then
    if ! grep -Fq "${UEVENT_PATH}" "${I3_STATUS_CONFIG_FILE}"; then
        sed -i '/^battery 0 {$/a \ \ \ \ \ \ \ \ path = "'"${UEVENT_PATH}"'"' "${I3_STATUS_CONFIG_FILE}"
    fi
else
    echo '> Unable to find uevent node for battery.'
fi

# Show battery percentage in integers.
if ! grep -Fq 'integer_battery_capacity' "${I3_STATUS_CONFIG_FILE}"; then
    sed -i '/^battery 0 {$/a \ \ \ \ \ \ \ \ integer_battery_capacity = true' "${I3_STATUS_CONFIG_FILE}"
fi

# Let user know that they should reload their desktop session.
echo '> You should restart your desktop session in order for the changes to take effect.'

# Let user know that script has finished its job.
echo '> Finished.'

