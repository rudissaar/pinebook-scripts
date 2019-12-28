#!/usr/bin/env bash
# Script that enables desktop session switching and disables autologin for LightDM.

LIGHTDM_GTK_GREETER_FILE='/etc/lightdm/lightdm-gtk-greeter.conf'
LIGHTDM_AUTOLOGIN_FILE='/etc/lightdm/lightdm.conf.d/22-armbian-autologin.conf'

# You need root permissions to run this script.
if [[ "${UID}" != '0' ]]; then
    echo '> You need to become root to run this script.'
    echo '> Aborting.'
    exit 1
fi

# Function that checks if required binary exists and installs it if necassary.
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
       apt update 1> /dev/null
       REPO_REFRESHED=1
   fi

    for REPO_PACKAGE in ${REPO_PACKAGES}
    do
        apt install -y "${REPO_PACKAGE}"
    done
}

# Variable that keeps track if repository is already refreshed.
REPO_REFRESHED=0

# Install packages if necassary.
ENSURE_PACKAGE 'sed'
ENSURE_PACKAGE 'grep'

# Generate backup file if it doesn't exist.
[[ -f "${LIGHTDM_GTK_GREETER_FILE}.bak" ]] || cp "${LIGHTDM_GTK_GREETER_FILE}" "${LIGHTDM_GTK_GREETER_FILE}.bak"

# Change indicators line in configuration file.
if ! grep -Fq '~session' "${LIGHTDM_GTK_GREETER_FILE}"; then
echo replace
    sed -i 's/^indicators = .*$/indicators = ~language;~session;~power;~a11y/' "${LIGHTDM_GTK_GREETER_FILE}"
fi

# Disable autologin.
[[ ! -f "${LIGHTDM_AUTOLOGIN_FILE}" ]] || mv "${LIGHTDM_AUTOLOGIN_FILE}" "${LIGHTDM_AUTOLOGIN_FILE}.bak"

# Let user know that script has finished its job.
echo '> Finished.'

