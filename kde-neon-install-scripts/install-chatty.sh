#!/usr/bin/env bash
# Script that installs chatty application and related dependencies.

VERSION='0.10'
ARCHIVE_URL="https://github.com/chatty/chatty/releases/download/v${VERSION}/Chatty_${VERSION}.zip"
ICON_URL='http://img.murda.eu/ch/chatty.png'
POOL='/usr/local'

# You need root permissions to run this script.
if [[ "${UID}" != '0' ]]; then
    echo "> Unable to find 'sudo' from your environment's PATH variable."
    echo '> Aborting.'
    exit 1
fi

# Update repositories.
apt update

# Capture commands and install them if they are not already installed.
WGET=$(which wget)

if [[ "${?}" != '0' ]]; then
    apt install wget -y
fi

UNZIP=$(which unzip)

if [[ "${?}" != '0' ]]; then
    apt install unzip -y
fi

JAVA=$(which java)

if [[ "${?}" != '0' ]]; then
    apt install openjdk-11-jre -y
fi

# Create directory for chatty.
CHATTY_DIR="${POOL}/chatty"
mkdir -p "${CHATTY_DIR}"

# Download and extract chatty archive.
ARCHIVE_PATH="chatty-${VERSION}.zip"
"${WGET}" "${ARCHIVE_URL}" -O "${ARCHIVE_PATH}"

"${UNZIP}" "${ARCHIVE_PATH}" -d "${CHATTY_DIR}"

# Create directory for chatty icons if it doesn' exist.
CHATTY_ICON_DIR="${POOL}/icons"
[[ -d "${CHATTY_ICON_DIR}" ]] || mkdir -p "${CHATTY_ICON_DIR}"

# Download icon for chatty from internet if it doesn't exist locally.
if [[ ! -f "${CHATTY_ICON_DIR}/chatty.png" ]]; then
    "${WGET}" "${ICON_URL}" -O "${CHATTY_ICON_DIR}/chatty.png"
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

echo '> Finished.'

