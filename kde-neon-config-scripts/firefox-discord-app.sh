#!/usr/bin/env bash
# Script that sets up Dicord shortcut that will appear in applications menu.

ICON_URL='https://raw.githubusercontent.com/rudissaar/img-murda-eu/master/di/discord.png'
PACKAGE_POOL='/usr/local'

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

# Install packages if necessary.
ENSURE_PACKAGE 'firefox'
ENSURE_PACKAGE 'wget'

# Create directory for icons if it doesn't already exist.
ICONS_PATH="${PACKAGE_POOL}/share/icons"
[[ -d "${ICONS_PATH}" ]] || mkdir -p "${ICONS_PATH}"
ICON_PATH="${ICONS_PATH}/discord.png"

# Download icon for discord shortcut.
if ! wget "${ICON_URL}" -O "${ICON_PATH}"; then
    echo '> Unable to download icon for shortcut.'
    echo '> Skipping.'
fi

# Generate desktop entry for discord shortcut.
[[ -d "${PACKAGE_POOL}/share/applications" ]] || mkdir -p "${PACKAGE_POOL}/share/applications"

cat > "${PACKAGE_POOL}/share/applications/discord.desktop" <<EOL
[Desktop Entry]
Name=Discord
GenericName=Internet Messenger
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
Exec=firefox --new-tab https://discordapp.com/activity
Type=Application
Icon=${ICON_PATH}
Categories=Network;InstantMessaging;
EOL

# Let user know that script has finished its job.
echo '> Finished.'

