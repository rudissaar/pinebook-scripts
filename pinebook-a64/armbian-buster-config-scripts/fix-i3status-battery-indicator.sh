#!/usr/bin/env bash
# Script that improves battery configuration for i3status bar.

I3_STATUS_CONFIG_FILE='/etc/i3status.conf'

# You need root permissions to run this script.
if [[ "${UID}" != '0' ]]; then
    echo '> You need to become root to run this script.'
    echo '> Aborting.'
    exit 1
fi

# Function that checks if required binary exists and installs it if necessary.
ENSURE_PACKAGE () {
    REQUIRED_BINARY=$(basename "${1}")
    REPO_PACKAGES="${*:2}"

    if [[ "${REQUIRED_BINARY}" != '-' ]]; then
        [[ -n "${REPO_PACKAGES}" ]] || REPO_PACKAGES="${REQUIRED_BINARY}"

        if command -v "${REQUIRED_BINARY}" 1> /dev/null; then
            REPO_PACKAGES=''
        fi  
    fi  

    [[ -n "${REPO_PACKAGES}" ]] || return

    if [[ "${REPO_REFRESHED}" == '0' ]]; then
        echo '> Refreshing package repository.'
        apt-get update 1> /dev/null
        REPO_REFRESHED=1
    fi  

    for REPO_PACKAGE in ${REPO_PACKAGES}
    do  
        apt-get install -y "${REPO_PACKAGE}"
    done
}

# Variable that keeps track if repository is already refreshed.
REPO_REFRESHED=0

# Install packages and dependencies if necessary.
ENSURE_PACKAGE 'sed'
ENSURE_PACKAGE 'grep'

# Generate backup file if it doesn't exist.
[[ -f "${I3_STATUS_CONFIG_FILE}.bak" ]] || cp "${I3_STATUS_CONFIG_FILE}" "${I3_STATUS_CONFIG_FILE}.bak"

# Rename battery all to battery 0.
sed -i '/^order += "battery all"$/s/all/0/' "${I3_STATUS_CONFIG_FILE}"
sed -i '/^battery all {$/s/all/0/' "${I3_STATUS_CONFIG_FILE}"

# Find battery device path and uevent node.
SEARCH_PATH="$(find /sys/devices/platform/soc -name "*battery" 2> /dev/null | head -n 1)"
UEVENT_PATH=$(find "${SEARCH_PATH}" -maxdepth 1 -name uevent)

if [[ -n "${UEVENT_PATH}" ]]; then
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

# Remove battery remaining indicator.
sed -i '/format = "%status %percentage %remaining"/s/\ %remaining// ' "${I3_STATUS_CONFIG_FILE}"

# Let user know that they should reload their desktop session.
echo '> You should restart your desktop session in order for the changes to take effect.'

# Let user know that script has finished its job.
echo '> Finished.'

