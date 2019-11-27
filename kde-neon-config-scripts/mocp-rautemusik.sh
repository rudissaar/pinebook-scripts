#!/usr/bin/env bash
# Script that installs mocp on current system and provides it with rm.fm media sources.

BIN_DIRECTORY='/usr/local/bin'

# You need root permissions to run this script.
if [[ "${UID}" != '0' ]]; then
    echo '> You need to become root to run this script.'
    echo '> Aborting.'
    exit 1
fi

# Function that checks if required binary exists and installs it if necassary.
ENSURE_DEPENDENCY () {
    REQUIRED_BINARY=$(basename ${1})
    REPO_PACKAGE="${2}"
    [[ ! -z "${REPO_PACKAGE}" ]] || REPO_PACKAGE="${REQUIRED_BINARY}"

    which "${REQUIRED_BINARY}" 1> /dev/null 2>&1

    if [[ "${?}" != '0' ]]; then
        if [[ "${REPO_UPDATED}" == '0' ]]; then
            apt update
            REPO_UPDATED=1
        fi

        apt install -y "${REPO_PACKAGE}"
    fi
}

# Variable that keeps track if repository is already refreshed.
REPO_UPDATED=0

# Install packages if necassary.
ENSURE_DEPENDENCY 'mocp' 'moc'
ENSURE_DEPENDENCY 'jq'
ENSURE_DEPENDENCY 'curl'

# Create executable script.
[[ ! -d "${BIN_DIRECTORY}" ]] || mkdir -p "${BIN_DIRECTORY}"

cat > "${BIN_DIRECTORY}/mocp-rm.fm" <<EOL
#!/usr/bin/env bash

URL='https://gist.githubusercontent.com/rudissaar/3cbb35a6072d7cd0e9fc7304d8c6528f/raw/1caa85f8c8eb740619016d16cff8856ca411a94a/rautemusik-channels.json'
mocp \$(curl -L -s \${URL} | jq .channels[].urls.mp3 | tr -d '"')

EOL

# Let user know that script has finished its job.
echo '> Finished.'

