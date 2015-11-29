#!/bin/bash
#/ Usage: bin/hatstrap.sh [--debug]
#/ Install development dependencies on Mac OS X.
set -e

# Keep sudo timestamp updated while Strap is running.
if [ "$1" = "--sudo-wait" ]; then
  while true; do
    sudo -v
    sleep 1
  done
  exit 0
fi

[ "$1" = "--debug" ] && HATSTRAP_DEBUG="1"
HATSTRAP_SUCCESS=""

cleanup() {
  set +e
  if [ -n "$HATSTRAP_SUDO_WAIT_PID" ]; then
    sudo kill "$HATSTRAP_SUDO_WAIT_PID"
  fi
  sudo -k
  rm -f "$CLT_PLACEHOLDER" "$HATSTRAP_BREWFILE"
  if [ -z "$HATSTRAP_SUCCESS" ]; then
    if [ -n "$HATSTRAP_STEP" ]; then
      echo "!!! $HATSTRAP_STEP FAILED" >&2
    else
      echo "!!! FAILED" >&2
    fi
    if [ -z "$HATSTRAP_DEBUG" ]; then
      echo "!!! Run '$0 --debug' for debugging output." >&2
      echo "!!! If you're stuck: file an issue with debugging output at:" >&2
      echo "!!!   $HATSTRAP_ISSUES_URL" >&2
    fi
  fi
}

trap "cleanup" EXIT

if [ -n "$HATSTRAP_DEBUG" ]; then
  set -x
else
  HATSTRAP_QUIET_FLAG="-q"
  Q="$HATSTRAP_QUIET_FLAG"
fi

STDIN_FILE_DESCRIPTOR="0"
[ -t "$STDIN_FILE_DESCRIPTOR" ] && HATSTRAP_INTERACTIVE="1"

HATSTRAP_ISSUES_URL="https://github.com/tylermauthe/hatstrap/issues/new"

HATSTRAP_DIRECTORY="$(cd "$(dirname "$0")" && pwd)"
HATSTRAP_FULL_PATH="$HATSTRAP_DIRECTORY/$(basename "$0")"

abort() { HATSTRAP_STEP="";   echo "!!! $@" >&2; exit 1; }
log()   { HATSTRAP_STEP="$@"; echo "--> $@"; }
logn()  { HATSTRAP_STEP="$@"; printf -- "--> $@ "; }
logk()  { HATSTRAP_STEP="";   echo "OK"; }

sw_vers -productVersion | grep $Q -E "^10.(9|10|11)" || {
  abort "Run Strap on Mac OS X 10.9/10/11."
}

[ "$USER" = "root" ] && abort "Run Strap as yourself, not root."
groups | grep $Q admin || abort "Add $USER to the admin group."

# Initialise sudo now to save prompting later.
log "Enter your password (for sudo access):"
sudo -k
sudo /usr/bin/true
[ -f "$HATSTRAP_FULL_PATH" ]
sudo bash "$HATSTRAP_FULL_PATH" --sudo-wait &
HATSTRAP_SUDO_WAIT_PID="$!"
ps -p "$HATSTRAP_SUDO_WAIT_PID" 2>&1 >/dev/null
logk

# Copy dotfiles for common utilities
log "Copying dotfiles to $HOME:"
mkdir -p ~/.vim/{backups,swap,undo}
rsync --exclude ".DS_Store" -avh --no-perms "$(dirname $HATSTRAP_DIRECTORY)/dotfiles/" "$HOME"
logk

# Set up preferences
log "Configuring preferences:"
"$HATSTRAP_DIRECTORY"/prefs.sh
logk

# Install the Xcode Command Line Tools if Xcode isn't installed.
DEVELOPER_DIR=$("xcode-select" -print-path 2>/dev/null || true)
[ -z "$DEVELOPER_DIR" ] || ! [ -f "$DEVELOPER_DIR/usr/bin/git" ] && {
  log "Installing the Xcode Command Line Tools:"
  CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  sudo touch "$CLT_PLACEHOLDER"
  CLT_PACKAGE=$(softwareupdate -l | \
                grep -B 1 -E "Command Line (Developer|Tools)" | \
                awk -F"*" '/^ +\*/ {print $2}' | sed 's/^ *//' | head -n1)
  sudo softwareupdate -i "$CLT_PACKAGE"
  sudo rm -f "$CLT_PLACEHOLDER"
  logk
}

# Check if the Xcode license is agreed to and agree if not.
xcode_license() {
  if /usr/bin/xcrun clang 2>&1 | grep $Q license; then
    if [ -n "$HATSTRAP_INTERACTIVE" ]; then
      logn "Asking for Xcode license confirmation:"
      sudo xcodebuild -license
      logk
    else
      abort 'Run `sudo xcodebuild -license` to agree to the Xcode license.'
    fi
  fi
}
xcode_license

# Setup Homebrew directories and permissions.
logn "Installing Homebrew:"
HOMEBREW_PREFIX="/usr/local"
HOMEBREW_CACHE="/Library/Caches/Homebrew"
for dir in "$HOMEBREW_PREFIX" "$HOMEBREW_CACHE"; do
  [ -d "$dir" ] || sudo mkdir -p "$dir"
  sudo chown -R $USER:admin "$dir"
done

# Download Homebrew.
export GIT_DIR="$HOMEBREW_PREFIX/.git" GIT_WORK_TREE="$HOMEBREW_PREFIX"
git init $Q
git config remote.origin.url "https://github.com/Homebrew/homebrew"
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git rev-parse --verify --quiet origin/master >/dev/null || {
  git fetch $Q origin master:refs/remotes/origin/master --no-tags --depth=1
  git reset $Q --hard origin/master
}
sudo chmod g+rwx "$HOMEBREW_PREFIX"/* "$HOMEBREW_PREFIX"/.??*
unset GIT_DIR GIT_WORK_TREE
logk

export PATH="$HOMEBREW_PREFIX/bin:$PATH"
log "Updating Homebrew:"
brew update
logk

# Install Homebrew Bundle, Cask, Services and Versions tap.
log "Installing Homebrew taps and extensions:"
brew tap | grep -i $Q Homebrew/bundle || brew tap Homebrew/bundle
HATSTRAP_BREWFILE="/tmp/Brewfile.strap"
cat > "$HATSTRAP_BREWFILE" <<EOF
tap 'caskroom/cask'
tap 'homebrew/services'
tap 'homebrew/versions'
brew 'caskroom/cask/brew-cask'
EOF
brew bundle --file="$HATSTRAP_BREWFILE"
rm -f "$HATSTRAP_BREWFILE"
logk

# Check and install any remaining software updates.
logn "Checking for software updates:"
if softwareupdate -l 2>&1 | grep $Q "No new software available."; then
  logk
else
  echo
  log "Installing software updates:"
  if [ -z "$HATSTRAP_CI" ]; then
    sudo softwareupdate --install --all
    xcode_license
  else
    echo "Skipping software updates for CI"
  fi
  logk
fi

# Install from Hatstrap Brewfile
if [ -f "$HATSTRAP_DIRECTORY/Brewfile" ]; then
  log "Installing from Hatstrap Brewfile:"
  brew bundle --file="$HATSTRAP_DIRECTORY/Brewfile"
  logk
fi

# Install from local Brewfile
if [ -f "$HOME/.Brewfile" ]; then
  log "Installing from user Brewfile (~/.Brewfile):"
  brew bundle --global
  logk
fi

HATSTRAP_SUCCESS="1"
log 'Finished! Reboot and get to work.'
