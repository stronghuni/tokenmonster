#!/bin/bash
set -euo pipefail

# Build release binary + wrap in a .app bundle for macOS.
# Usage: ./scripts/build-app.sh
# Output: dist/TokenMonster.app

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BIN_NAME="TokenMonster"
APP_NAME="TokenMonster.app"
DIST="$ROOT/dist"
APP="$DIST/$APP_NAME"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RES="$CONTENTS/Resources"

echo "==> swift build -c release (arm64)"
swift build -c release --arch arm64

echo "==> preparing $APP"
rm -rf "$APP"
mkdir -p "$MACOS" "$RES"

cp ".build/arm64-apple-macosx/release/$BIN_NAME" "$MACOS/$BIN_NAME"
chmod +x "$MACOS/$BIN_NAME"

cat > "$CONTENTS/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key><string>en</string>
    <key>CFBundleDisplayName</key><string>Token Monster</string>
    <key>CFBundleExecutable</key><string>TokenMonster</string>
    <key>CFBundleIdentifier</key><string>com.stronghuni.tokenmonster</string>
    <key>CFBundleName</key><string>TokenMonster</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>0.1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSApplicationCategoryType</key><string>public.app-category.developer-tools</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSUIElement</key><true/>
    <key>NSHumanReadableCopyright</key><string>© 2026 stronghuni — MIT</string>
    <key>NSSupportsAutomaticTermination</key><false/>
    <key>NSSupportsSuddenTermination</key><false/>
</dict>
</plist>
PLIST

echo "==> ad-hoc codesign (remove quarantine on local run)"
codesign --force --deep --sign - "$APP" || true

echo "==> done: $APP"
ls -la "$APP/Contents"
