#!/usr/bin/env bash
# Script that provides dmenu with searchable web browser bookmarks.
# Inspired by: https://www.youtube.com/watch?v=81OQtU8E0vE

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
ENSURE_PACKAGE 'sed'
ENSURE_PACKAGE 'grep'

# Create executable script.
[[ -d "${PACKAGE_POOL}/bin" ]] || mkdir -p "${PACKAGE_POOL}/bin"
BOOKMARKS_SCRIPT_PATH="${PACKAGE_POOL}/bin/bookmarks.sh"

cat > "${BOOKMARKS_SCRIPT_PATH}" <<EOL
#!/usr/bin/env bash

HANDLE_DEFAULT () {
    if [[ ! -z "\${1}" ]]; then
        "\${1}" "\${URL}"
    elif [[ ! -z "\${BROWSER}" ]]; then
        "\${BROWSER}" "\${URL}"
    fi
}

BOOKMARKS="${PACKAGE_POOL}/share/bookmarks/bookmarks"
USER_BOOKMARKS="\${HOME}/.config/bookmarks"

if [[ -f "\${USER_BOOKMARKS}" ]]; then
    BOOKMARKS="\${USER_BOOKMARKS}"
fi

URL=\$(sort "\${BOOKMARKS}" | sed 's/:.*//' | dmenu -i -p 'Select a Bookmark' | xargs -I % grep "%:" "\${BOOKMARKS}" | sed 's/.*://')

if [[ "\${URL}" ]]; then
    case "\${1}" in
        "firefox") firefox --new-tab "\${URL}";;
        "firefox-esr") firefox-esr --new-tab "\${URL}";;
        *) HANDLE_DEFAULT;;
    esac
fi

EOL

# Fix permissions.
chmod +x "${BOOKMARKS_SCRIPT_PATH}"

# Create file for global bookmarks.
[[ -d "${PACKAGE_POOL}/share/bookmarks" ]] || mkdir -p "${PACKAGE_POOL}/share/bookmarks"
touch "${PACKAGE_POOL}/share/bookmarks/bookmarks"

# Create file that can be used/sourced for uninstalling.
cat > "${PACKAGE_POOL}/share/bookmarks/uninstall.txt" <<EOL
rm -r "${PACKAGE_POOL}/share/bookmarks/bookmarks"
rm -r "${PACKAGE_POOL}/share/bookmarks/uninstall.txt"
rm -r "${PACKAGE_POOL}/bin/bookmarks.sh"
rmdir "${PACKAGE_POOL}/share/bookmarks" 2> /dev/null
EOL

# Let user know that script has finished its job.
echo '> Finished.'

