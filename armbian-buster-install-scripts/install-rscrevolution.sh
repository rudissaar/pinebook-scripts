#!/usr/bin/env bash
# Script that installs RSCRevolution (RuneScape Classic) client on current system.

DOWNLOAD_URL="http://game.rscrevolution.net/RSCRevolution.jar"
ICON_URL='https://raw.githubusercontent.com/rudissaar/img-murda-eu/master/ru/runescape-classic.png'
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
ENSURE_PACKAGE 'wget'
ENSURE_PACKAGE 'java' 'default-jre'

# Download RSCRevolution package.
TMP_DATE="$(date +%s)"
TMP_FILE="/tmp/rscrevolution-${TMP_DATE}.jar"

if ! wget "${DOWNLOAD_URL}" -O "${TMP_FILE}"; then
    echo '> Unable to download required files, exiting.'
    echo '> Aborting.'
    exit 1
fi

# Copy files.
RSCREVOLUTION_PATH="${PACKAGE_POOL}/share/rscrevolution"
[[ -d "${RSCREVOLUTION_PATH}" ]] || mkdir -p "${RSCREVOLUTION_PATH}"
cp "${TMP_FILE}" "${RSCREVOLUTION_PATH}/rscrevolution.jar"

# Create executable script.
cat > "${RSCREVOLUTION_PATH}/rscrevolution.sh" <<EOL
#!/usr/bin/env bash

java -jar "${RSCREVOLUTION_PATH}/rscrevolution.jar" 1> /dev/null

EOL

# Fix permissions.
chmod +x "${RSCREVOLUTION_PATH}/rscrevolution.sh"

# Link executable.
ln -sf "${RSCREVOLUTION_PATH}/rscrevolution.sh" "${PACKAGE_POOL}/bin/rscrevolution"

# Create directory for rscrevolution icons if it doesn't exist.
RSCREVOLUTION_ICON_PATH="${PACKAGE_POOL}/share/icons"
[[ -d "${RSCREVOLUTION_ICON_PATH}" ]] || mkdir -p "${RSCREVOLUTION_ICON_PATH}"

# Download icon for rscrevolution from internet.
if [[ ! -f "${RSCREVOLUTION_ICON_PATH}/rscrevolution.png" ]]; then
    wget "${ICON_URL}" -O "${RSCREVOLUTION_ICON_PATH}/rscrevolution.png"
fi

# Generate desktop entry for chatty application.
[[ -d "${PACKAGE_POOL}/share/applications" ]] || mkdir -p "${PACKAGE_POOL}/share/applications"

cat > "${PACKAGE_POOL}/share/applications/rscrevolution.desktop" <<EOL
[Desktop Entry]
Name=RSCRevolution
GenericName=RuneScape Classic Client
Comment=The most developed, longest running, most active and the only FREE OldSchool RuneScape Classic Private Server
Exec=${PACKAGE_POOL}/bin/rscrevolution
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=${RSCREVOLUTION_ICON_PATH}/rscrevolution.png
StartupNotify=true
Categories=Game;
Keywords=runescape;classic;oldschool;rscrevolution;multiplayer;
EOL

# Cleanup.
rm -rf "${TMP_FILE}"

# Let user know that script has finished its job.
echo '> Finished.'

