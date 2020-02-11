#!/usr/bin/env bash
# Script that installs PowerShell on current system.

VERSION='6.2.4'
DOWNLOAD_URL="https://github.com/PowerShell/PowerShell/releases/download/v${VERSION}/powershell-${VERSION}-linux-arm64.tar.gz"
PACKAGE_POOL='/usr/local'

# You need root permissions to run this script.
if [[ "${UID}" != '0' ]]; then
    echo '> You need to become root to run this script.'
    echo '> Aborting.'
    exit 1
fi

# Function that checks if required binary exists and installs it if necessary.
ENSURE_PACKAGE () {
    REQUIRED_BINARY=$(basename "${1}")
    REPO_PACKAGES="${*:2}"

    if [[ "${REQUIRED_BINARY}" != '-' ]]; then
        [[ -n "${REPO_PACKAGES}" ]] || REPO_PACKAGES="${REQUIRED_BINARY}"

        if command -v "${REQUIRED_BINARY}" 1> /dev/null; then
            REPO_PACKAGES=''
        fi  
    fi  

    [[ -n "${REPO_PACKAGES}" ]] || return

    if [[ "${REPO_REFRESHED}" == '0' ]]; then
        echo '> Refreshing package repository.'
        apt-get update 1> /dev/null
        REPO_REFRESHED=1
    fi  

    for REPO_PACKAGE in ${REPO_PACKAGES}
    do  
        apt-get install -y "${REPO_PACKAGE}"
    done
}

# Variable that keeps track if repository is already refreshed.
REPO_REFRESHED=0

# Install packages and dependencies if necessary.
ENSURE_PACKAGE 'tar'
ENSURE_PACKAGE 'gzip'
ENSURE_PACKAGE 'wget'

# Download PowerShell archive.
TMP_DATE="$(date +%s)"
TMP_FILE="/tmp/powershell-${TMP_DATE}.tar.gz"
TMP_PATH="/tmp/powershell-${TMP_DATE}"

if ! wget "${DOWNLOAD_URL}" -O "${TMP_FILE}"; then
    echo '> Unable to download required files, exiting.'
    echo '> Aborting.'
    exit 1
fi

# Extract archive.
[[ -d "${TMP_PATH}" ]] || mkdir -p "${TMP_PATH}"
tar -xf "${TMP_FILE}" -C "${TMP_PATH}"

# Copy files.
POWERSHELL_PATH="${PACKAGE_POOL}/share/powershell"
[[ -d "${POWERSHELL_PATH}" ]] || mkdir -p "${POWERSHELL_PATH}"
cp -r "${TMP_PATH}/"* "${POWERSHELL_PATH}/"

# Fix permissions.
chmod +x "${POWERSHELL_PATH}/pwsh"

# Link executable.
ln -sf "${POWERSHELL_PATH}/pwsh" "${PACKAGE_POOL}/bin/pwsh"
ln -sf "${PACKAGE_POOL}/bin/pwsh" "${PACKAGE_POOL}/bin/powershell"

# Cleanup.
rm -rf "${TMP_FILE}" "${TMP_PATH}"

# Let user know that script has finished its job.
echo '> Finished.'

