#!/usr/bin/env bash
# Script that applies fix for faulty man-pages.

# You need root permissions to run this script.
if [[ "${UID}" != '0' ]]; then
    echo '> You need to become root to run this script.'
    echo '> Aborting.'
    exit 1
fi

# Install packages.
apt update
apt install apparmor-utils -y
aa-disable $(which man)

echo '> Finished.'

