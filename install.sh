#!/bin/bash
# EVE Desktop installer. Paste in Terminal:
#   curl -fsSL https://raw.githubusercontent.com/darkooom/eve-desktop/main/install.sh | bash
# Downloads the source to ~/.eve-desktop (EVE Desktop updates itself from there), builds the app, opens it.
set -e
DIR="${EVE_DESKTOP_SOURCE:-$HOME/.eve-desktop}"
echo "Installing EVE Desktop…"
[ "$(sw_vers -productVersion | cut -d. -f1)" -ge 26 ] || { echo "EVE Desktop needs macOS 26 or later."; exit 1; }
if ! xcode-select -p >/dev/null 2>&1; then
  echo "First, Apple's command line tools. A macOS window will open: click Install."
  echo "When it finishes, paste the install line again."
  xcode-select --install 2>/dev/null || true
  exit 1
fi
if [ -d "$DIR/.git" ]; then
  git -C "$DIR" pull -q --ff-only || { echo "Could not update $DIR. Delete that folder, then paste the install line again."; exit 1; }
else
  git clone -q --depth 1 https://github.com/darkooom/eve-desktop.git "$DIR"
fi
"$DIR/build.sh"
open "$HOME/Applications/EVE Desktop.app"
echo "Done. The EVE Desktop setup window walks you through the rest."
