#!/usr/bin/env bash
# Script that installs linssid package from repository and applies required modifications.

SUDO=''

if [[ "${UID}" != '0' ]]; then
    SUDO=$(which sudo)

    if [[ "${?}" != '0' ]]; then
        echo "> Unable to find 'sudo' from your environment's PATH variable."
        echo '> Aborting.'
    fi
fi

${SUDO} apt update

SED=$(which sed)

if [[ "${?}" != '0' ]]; then
    ${SUDO} apt install sed -y
fi

${SUDO} apt install linssid -y --reinstall

if [[ -f '/usr/share/applications/linssid.desktop' ]]; then
    ${SED} -i 's/^Exec=linssid$/Exec=pkexec --user root env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY linssid/g' \
        '/usr/share/applications/linssid.desktop'
fi

echo '> Finished.'
