#!/usr/bin/env bash
# Script that installs chatty application and related dependencies.

VERSION='0.9.6'
ARCHIVE_URL="https://github.com/chatty/chatty/releases/download/v${VERSION}/Chatty_${VERSION}.zip"
ICON_URL='http://img.murda.eu/ch/chatty.png'
POOL='/usr/local'

SUDO=''

if [[ "${UID}" != '0' ]]; then
    SUDO=$(which sudo)

    if [[ "${?}" != '0' ]]; then
        echo "> Unable to find 'sudo' from your environment's PATH variable."
        echo '> Aborting.'
    fi
fi

${SUDO} apt update

WGET=$(which wget)

if [[ "${?}" != '0' ]]; then
    ${SUDO} apt install wget -y
fi

UNZIP=$(which unzip)

if [[ "${?}" != '0' ]]; then
    ${SUDO} apt install unzip -y
fi

JAVA=$(which java)

if [[ "${?}" != '0' ]]; then
    ${SUDO} apt install openjdk-11-jre -y
fi

CHATTY_DIR="${POOL}/chatty"
mkdir -p "${CHATTY_DIR}"

ARCHIVE_PATH="chatty-${VERSION}.zip"
wget "${ARCHIVE_URL}" -O "${ARCHIVE_PATH}"

unzip "${ARCHIVE_PATH}" -d "${CHATTY_DIR}"

rm "${ARCHIVE_PATH}"

echo '> Finished.'

