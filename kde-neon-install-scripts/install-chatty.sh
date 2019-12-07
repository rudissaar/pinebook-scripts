#!/usr/bin/env bash
# Script that installs chatty application and related dependencies.

VERSION='0.10'
ARCHIVE_URL="https://github.com/chatty/chatty/releases/download/v${VERSION}/Chatty_${VERSION}.zip"
ICON_URL='http://img.murda.eu/ch/chatty.png'
POOL='/usr/local'

# You need root permissions to run this script.
if [[ "${UID}" != '0' ]]; then
    echo '> You need to become root to run this script.'
    echo '> Aborting.'
    exit 1
fi

# Function that checks if required binary exists and installs it if necassary.
ENSURE_DEPENDENCY () {
    REQUIRED_BINARY=$(basename "${1}")
    REPO_PACKAGE="${2}"
    [[ ! -z "${REPO_PACKAGE}" ]] || REPO_PACKAGE="${REQUIRED_BINARY}"

    if ! command -v "${REQUIRED_BINARY}" 1> /dev/null; then
        if [[ "${REPO_UPDATED}" == '0' ]]; then
            apt update
            REPO_UPDATED=1
        fi

        apt install -y "${REPO_PACKAGE}"
    fi
}

# Variable that keeps track if repository is already refreshed.
REPO_UPDATED=0

# Install packages if necessary.
ENSURE_DEPENDENCY 'wget'
ENSURE_DEPENDENCY 'unzip'
ENSURE_DEPENDENCY 'java' 'default-jre'

# Create directory for chatty.
CHATTY_DIR="${POOL}/chatty"
mkdir -p "${CHATTY_DIR}"

# Download and extract chatty archive.
ARCHIVE_PATH="chatty-${VERSION}.zip"
wget "${ARCHIVE_URL}" -O "${ARCHIVE_PATH}"
unzip "${ARCHIVE_PATH}" -d "${CHATTY_DIR}"

# Create directory for chatty icons if it doesn't exist.
CHATTY_ICON_DIR="${POOL}/icons"
[[ -d "${CHATTY_ICON_DIR}" ]] || mkdir -p "${CHATTY_ICON_DIR}"

# Download icon for chatty from internet if it doesn't exist locally.
if [[ ! -f "${CHATTY_ICON_DIR}/chatty.png" ]]; then
    wget "${ICON_URL}" -O "${CHATTY_ICON_DIR}/chatty.png"
fi

# Generate desktop entry for chatty application.
cat > "${POOL}/share/applications/chatty.desktop" <<EOL
[Desktop Entry]
Version=${VERSION}
Name=Chatty
GenericName=Chatty
Comment=Twitch Chat Client written in Java
Exec=java -jar ${CHATTY_DIR}/Chatty.jar
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=${CHATTY_ICON_DIR}/chatty.png
StartupNotify=true
Categories=Network;InstantMessaging;
EOL

# Cleanup.
rm "${ARCHIVE_PATH}"

# Let user know that script has finished its job.
echo '> Finished.'
