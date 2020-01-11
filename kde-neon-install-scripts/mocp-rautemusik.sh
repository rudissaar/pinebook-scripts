#!/usr/bin/env bash
# Script that installs mocp on current system and provides it with rm.fm media sources.

BIN_DIRECTORY='/usr/local/bin'

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
ENSURE_PACKAGE 'mocp' 'moc' 'moc-ffmpeg-plugin'
ENSURE_PACKAGE 'jq'
ENSURE_PACKAGE 'curl'

# Create executable script.
[[ -d "${BIN_DIRECTORY}" ]] || mkdir -p "${BIN_DIRECTORY}"

cat > "${BIN_DIRECTORY}/mocp-rm.fm" <<EOL
#!/usr/bin/env bash
# shellcheck disable=SC2046

URL='https://gist.githubusercontent.com/rudissaar/3cbb35a6072d7cd0e9fc7304d8c6528f/raw/1caa85f8c8eb740619016d16cff8856ca411a94a/rautemusik-channels.json'
mocp \$(curl -L -s \${URL} | jq .channels[].urls.mp3 | tr -d '"')

EOL

chmod 755 "${BIN_DIRECTORY}/mocp-rm.fm"

# Let user know that script has finished its job.
echo '> Finished.'

