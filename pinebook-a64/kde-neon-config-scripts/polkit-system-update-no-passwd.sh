#!/usr/bin/env bash
# Script that changes values in polkit file to allow passwordless system updates.

# Polkit file that we are going to change.
POLKIT_FILE='/usr/share/polkit-1/actions/org.freedesktop.packagekit.policy'

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
ENSURE_PACKAGE 'xmllint' 'libxml2-utils'

# Change values in policy .xml file.
xmllint --shell "${POLKIT_FILE}" 1> /dev/null <<EOF
cd /policyconfig/action[@id='org.freedesktop.packagekit.system-update']/defaults/allow_any
set yes
save
EOF

xmllint --shell "${POLKIT_FILE}" 1> /dev/null <<EOF
cd /policyconfig/action[@id='org.freedesktop.packagekit.system-update']/defaults/allow_inactive
set yes
save
EOF

xmllint --shell "${POLKIT_FILE}" 1> /dev/null <<EOF
cd /policyconfig/action[@id='org.freedesktop.packagekit.system-update']/defaults/allow_active
set yes
save
EOF

# Let user know that script has finished its job.
echo '> Finished.'

