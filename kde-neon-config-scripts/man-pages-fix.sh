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
apt install -y apparmor-utils
aa-disable "$(command -v man)" 1> /dev/null 2>&1

# Let user know that script has finished its job.
echo '> Finished.'

