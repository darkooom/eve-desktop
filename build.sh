#!/bin/bash
# Installs EVE Desktop: builds the app, starts it at login, and (re)starts it now. Run it again after any change.
set -e; cd "$(dirname "$0")"
VERSION=$(tr -d '\n' < VERSION)
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Invalid VERSION: $VERSION"; exit 1; }
IFS=. read -r VERSION_MAJOR VERSION_MINOR VERSION_PATCH <<< "$VERSION"
(( VERSION_MINOR < 1000 && VERSION_PATCH < 1000 )) || { echo "VERSION components must be below 1000"; exit 1; }
BUILD=$((VERSION_MAJOR * 1000000 + VERSION_MINOR * 1000 + VERSION_PATCH))
[ "$(sw_vers -productVersion | cut -d. -f1)" -ge 26 ] || { echo "EVE Desktop needs macOS 26 or later (it uses Apple's new on-device speech)."; exit 1; }
xcode-select -p >/dev/null 2>&1 || { echo "Needs Apple's command line tools. Run: xcode-select --install   then run ./build.sh again."; exit 1; }
command -v python3 >/dev/null || { echo "EVE Desktop needs Python 3. Install it, then run ./build.sh again."; exit 1; }
command -v claude >/dev/null || [ -x ~/.local/bin/claude ] || echo "Note: Claude Code is not installed yet. EVE Desktop's setup window can install it, or you can pick Devin or Pi."
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
# A compiler error must leave the installed app and its resources alone.
# Keep the upstream Swift module name: source references such as Atticus.settings use it as a namespace.
swiftc -O -module-name Atticus -target "$(uname -m)-apple-macos26.0" Atticus.swift -o "$STAGE/EVEDesktop"
APP="$HOME/Applications/EVE Desktop.app"   # in Applications so System Settings can list it for permissions
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/ui"
cp atticus.py "$APP/Contents/Resources/"
cp ui/*.html ui/*.js "$APP/Contents/Resources/ui/"
cp ui/AppIcon.icns "$APP/Contents/Resources/"
cp LICENSE LICENSE-Plip NOTICE.md THIRD_PARTY_NOTICES.md "$APP/Contents/Resources/"
if command -v node >/dev/null && command -v npm >/dev/null; then
  mkdir -p "$STAGE/elevenlabs-runtime"
  cp elevenlabs-runtime/package.json elevenlabs-runtime/package-lock.json elevenlabs-runtime/speak.mjs "$STAGE/elevenlabs-runtime/"
  npm ci --omit=dev --ignore-scripts --prefix "$STAGE/elevenlabs-runtime" >/dev/null
  rm -rf "$APP/Contents/Resources/elevenlabs-runtime"
  cp -R "$STAGE/elevenlabs-runtime" "$APP/Contents/Resources/"
else
  echo "Note: Node.js/npm not found. EVE Desktop works, but ElevenLabs voice is unavailable until you install Node.js and rebuild."
fi
ELEVENLABS_NODE=$(command -v node 2>/dev/null || true)
cat > "$APP/Contents/Info.plist" <<P
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>com.eve.desktop</string>
<key>CFBundleName</key><string>EVE Desktop</string>
<key>CFBundleDisplayName</key><string>EVE Desktop</string>
<key>CFBundleExecutable</key><string>EVEDesktop</string>
<key>CFBundleVersion</key><string>$BUILD</string>
<key>CFBundleShortVersionString</key><string>$VERSION</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>AtticusSource</key><string>$(pwd)</string>
<key>ElevenLabsNode</key><string>$ELEVENLABS_NODE</string>
<key>LSUIElement</key><true/>
<key>NSMicrophoneUsageDescription</key><string>EVE Desktop listens when you use its shortcut or microphone button.</string>
<key>NSAppleEventsUsageDescription</key><string>EVE Desktop controls apps like Finder, Chrome and Music when you ask it to.</string>
<key>NSCalendarsFullAccessUsageDescription</key><string>EVE Desktop reads your calendar, adds events you request, and asks before moving or deleting existing events. Calendar details are sent to your chosen AI model.</string>
<key>NSSpeechRecognitionUsageDescription</key><string>EVE Desktop turns your words into text on this Mac.</string>
</dict></plist>
P
mv "$STAGE/EVEDesktop" "$APP/Contents/MacOS/EVEDesktop"
# With a code-signing identity named "EVE Desktop Local Signing" in the keychain, macOS keeps permissions across
# rebuilds and auto-updates; ad hoc signing would ask for every permission again after each one. So make it once.
ID=$(security find-identity -p codesigning | awk '/EVE Desktop Local Signing/{print $2; exit}')
if [ -z "$ID" ]; then
  K=$(mktemp -d)
  /usr/bin/openssl req -x509 -newkey rsa:2048 -nodes -days 7300 -subj "/CN=EVE Desktop Local Signing" -addext "extendedKeyUsage=critical,codeSigning" \
    -addext "keyUsage=critical,digitalSignature" -keyout "$K/k.pem" -out "$K/c.pem" 2>/dev/null &&
  /usr/bin/openssl pkcs12 -export -inkey "$K/k.pem" -in "$K/c.pem" -out "$K/a.p12" -passout pass:eve-desktop 2>/dev/null &&
  security import "$K/a.p12" -P eve-desktop -T /usr/bin/codesign >/dev/null 2>&1 || true   # fails quietly: ad hoc still works
  rm -rf "$K"
  ID=$(security find-identity -p codesigning | awk '/EVE Desktop Local Signing/{print $2; exit}')
fi
codesign -s "${ID:--}" --force "$APP"
# register with macOS, or System Settings can't list it for permissions
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP"
AGENT="$HOME/Library/LaunchAgents/com.eve.desktop.plist"   # starts at login, restarts if it crashes (Quit stays quit)
mkdir -p "$HOME/Library/LaunchAgents" "$HOME/.config/eve-desktop"
cat > "$AGENT" <<P
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Label</key><string>com.eve.desktop</string>
<key>ProgramArguments</key><array><string>$APP/Contents/MacOS/EVEDesktop</string></array>
<key>RunAtLoad</key><true/>
<key>KeepAlive</key><dict><key>SuccessfulExit</key><false/></dict>
<key>StandardErrorPath</key><string>$HOME/.config/eve-desktop/app.err</string>
</dict></plist>
P
[ -n "$ATTICUS_NO_RESTART" ] && exit 0   # the app's own updater restarts it when idle
# Reload the job so launchd refreshes its executable signing requirement after a rebuild.
launchctl bootout gui/$(id -u)/com.eve.desktop 2>/dev/null || true
pkill -f "$APP/Contents/MacOS/EVEDesktop$" 2>/dev/null && sleep 1   # stop a copy opened by hand too
# bootout can return before the job has finished unloading.
launchctl bootstrap gui/$(id -u) "$AGENT" 2>/dev/null || { sleep 1; launchctl bootstrap gui/$(id -u) "$AGENT" 2>/dev/null || {
  echo "Could not add EVE Desktop to Login Items; opening it directly instead."
  open "$APP"
}; }
echo "EVE Desktop is running. Hold Control+Option+Space and talk."
