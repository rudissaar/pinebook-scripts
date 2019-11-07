#!/usr/bin/env bash
# Script that changes values in polkit file to allow passwordless system updates.

# Polkit policy file that we are going to change.
POLKIT_FILE='/usr/share/polkit-1/actions/org.freedesktop.packagekit.policy'

# You need root permissions to run this script.
if [[ "${UID}" != '0' ]]; then
    echo '> Aborting.'
    exit 1
fi

# Install packages if necessary.
which xmllint 1> /dev/null 2>&1
[[ "${?}" == '0' ]] || apt install -y libxml2-utils

# Change values in policy .xml file.
xmllint --shell "${POLKIT_FILE}" 1> /dev/null <<EOF
cd /policyconfig/action[@id='org.freedesktop.packagekit.system-update']/defaults/allow_any
set yes
save
EOF

xmllint --shell "${POLKIT_FILE}" 1> /dev/null <<EOF
cd /policyconfig/action[@id='org.freedesktop.packagekit.system-update']/defaults/allow_inactive
set yes
save
EOF

xmllint --shell "${POLKIT_FILE}" 1> /dev/null <<EOF
cd /policyconfig/action[@id='org.freedesktop.packagekit.system-update']/defaults/allow_active
set yes
save
EOF

# Let user know that script has finished it's job.
echo '> Finished.'

