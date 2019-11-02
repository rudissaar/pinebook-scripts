#!/usr/bin/env bash
# Script that applies fix for faulty man-pages.

# You need root permissions to run this script.
if [[ "${UID}" != '0' ]]; then
    echo "> Unable to find 'sudo' from your environment's PATH variable."
    echo '> Aborting.'
    exit 1
fi

apt update
apt install apparmor-utils -y
aa-disable $(which man)

echo '> Finished.'

