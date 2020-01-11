#!/usr/bin/env bash
# Script that installs chatty application and related dependencies.

VERSION='0.10'
DOWNLOAD_URL="https://github.com/chatty/chatty/releases/download/v${VERSION}/Chatty_${VERSION}.zip"
ICON_URL='http://img.murda.eu/ch/chatty.png'
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
ENSURE_PACKAGE 'wget'
ENSURE_PACKAGE 'unzip'
ENSURE_PACKAGE 'java' 'default-jre'

# Create directory for Chatty.

# Download Chatty archive.
TMP_DATE="$(date +%s)"
TMP_FILE="/tmp/chatty-${TMP_DATE}.zip"
TMP_PATH="/tmp/chatty-${TMP_DATE}"

if ! wget "${DOWNLOAD_URL}" -O "${TMP_FILE}"; then
    echo '> Unable to download required files.'
    echo '> Aborting.'
    exit 1
fi

# Extract archive.
[[ -d "${TMP_PATH}" ]] || mkdir -p "${TMP_PATH}"
unzip "${TMP_FILE}" -d "${TMP_PATH}"

# Copy files.
CHATTY_PATH="${PACKAGE_POOL}/share/chatty"
[[ -d "${CHATTY_PATH}" ]] || mkdir -p "${CHATTY_PATH}"
cp -r "${TMP_PATH}/"* "${CHATTY_PATH}/"

# Create directory for chatty icons if it doesn't exist.
CHATTY_ICON_PATH="${PACKAGE_POOL}/icons"
[[ -d "${CHATTY_ICON_PATH}" ]] || mkdir -p "${CHATTY_ICON_PATH}"

# Download icon for chatty from internet if it doesn't exist locally.
if [[ ! -f "${CHATTY_ICON_PATH}/chatty.png" ]]; then
    wget "${ICON_URL}" -O "${CHATTY_ICON_PATH}/chatty.png"
fi

# Generate desktop entry for chatty application.
cat > "${PACKAGE_POOL}/share/applications/chatty.desktop" <<EOL
[Desktop Entry]
Version=${VERSION}
Name=Chatty
GenericName=Chatty
Comment=Twitch Chat Client written in Java
Exec=java -jar ${CHATTY_PATH}/Chatty.jar
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=${CHATTY_ICON_PATH}/chatty.png
StartupNotify=true
Categories=Network;InstantMessaging;
EOL

# Cleanup.
rm -rf "${TMP_FILE}" "${TMP_PATH}"

# Let user know that script has finished its job.
echo '> Finished.'
