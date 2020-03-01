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
BOOKMARKS_SCRIPT_PATH="${PACKAGE_POOL}/bin/open-bookmark.sh"

cat > "${BOOKMARKS_SCRIPT_PATH}" <<EOL
#!/usr/bin/env bash
# Script that enables you to open web browser bookmarks from dmenu.

COMMAND=''
COMMAND_FALLBACK='firefox'

# Attempt to read in selected web browser from environment variable.
[[ ! -z "\${BROWSER}" ]] && COMMAND="\${BROWSER}"

# At this point, if script was unable to detect web browser we will fallback instead.
[[ -z "\${COMMAND}" ]] && COMMAND="\${COMMAND_FALLBACK}"

BOOKMARKS="${PACKAGE_POOL}/share/bookmarks/bookmarks.txt"
USER_BOOKMARKS="\${HOME}/.local/share/bookmarks/bookmarks.txt"
[[ -f "\${USER_BOOKMARKS}" ]] && BOOKMARKS="\${USER_BOOKMARKS}"

# If bookmarks file doesn't exist then let's just exit.
[[ -f "\${BOOKMARKS}" ]] || exit 1

# Display list of available bookmarks to open.
URL=\$(sort "\${BOOKMARKS}" | sed 's/:.*//' | dmenu -i -p 'Select a Bookmark' | xargs -I % grep "%:" "\${BOOKMARKS}" | sed 's/.*://')

# If for some reason selected filename evaluates to empty string, we cancel launching web browser.
if [[ ! -z "\${URL}" ]]; then
    case "\${COMMAND}" in
        "firefox") "\${COMMAND}" --new-tab "\${URL}" 2> /dev/null;;
        "firefox-esr") "\${COMMAND}" --new-tab "\${URL}" 2> /dev/null;;
        *) "\${COMMAND}" "\${URL}";;
    esac
fi

EOL

# Fix permissions.
chmod +x "${BOOKMARKS_SCRIPT_PATH}"

# Create file for global bookmarks.
[[ -d "${PACKAGE_POOL}/share/bookmarks" ]] || mkdir -p "${PACKAGE_POOL}/share/bookmarks"
touch "${PACKAGE_POOL}/share/bookmarks/bookmarks.txt"

# Create file that can be used/sourced for uninstalling.
cat > "${PACKAGE_POOL}/share/bookmarks/uninstall.txt" <<EOL
rm "${PACKAGE_POOL}/share/bookmarks/bookmarks.txt"
rm "${PACKAGE_POOL}/share/bookmarks/uninstall.txt"
rm "${PACKAGE_POOL}/bin/open-bookmark.sh"
rmdir "${PACKAGE_POOL}/share/bookmarks" 2> /dev/null
EOL

# Let user know that script has finished its job.
echo '> Finished.'

