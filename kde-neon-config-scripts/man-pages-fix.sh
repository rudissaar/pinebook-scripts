#!/usr/bin/env bash
# Script that applies fix for faulty man-pages.

SUDO=''

if [[ "${UID}" != '0' ]]; then
    SUDO=$(which sudo)

    if [[ "${?}" != '0' ]]; then
        echo "> Unable to find 'sudo' from your environment's PATH variable."
        echo '> Aborting.'
    fi
fi

${SUDO} apt update
${SUDO} apt install apparmor-utils -y
${SUDO} aa-disable $(which man)

echo '> Finished.'

