#!/usr/bin/env bash
# Script that installs linssid package from repository and applies required modifications.

# You need root permissions to run this script.
if [[ "${UID}" != '0' ]]; then
    echo '> You need to become root to run this script.'
    echo '> Aborting.'
    exit 1
fi

SED=$(which sed)

if [[ "${?}" != '0' ]]; then
    apt install sed -y
fi

# Install linssid package.
apt install linssid -y --reinstall

if [[ -f '/usr/share/applications/linssid.desktop' ]]; then
    ${SED} -i 's/^Exec=linssid$/Exec=pkexec --user root env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY linssid/g' \
        '/usr/share/applications/linssid.desktop'
fi

echo '> Finished.'

