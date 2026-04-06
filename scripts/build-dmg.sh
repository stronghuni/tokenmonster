#!/bin/bash
set -euo pipefail

# Build a distributable DMG from dist/TokenMonster.app.
# Run ./scripts/build-app.sh first.
# Usage: ./scripts/build-dmg.sh

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

APP="dist/TokenMonster.app"
if [ ! -d "$APP" ]; then
  echo "Missing $APP — run scripts/build-app.sh first"; exit 1
fi

VERSION=$(defaults read "$PWD/$APP/Contents/Info" CFBundleShortVersionString)
DMG="dist/TokenMonster-${VERSION}.dmg"
STAGE="dist/dmg-stage"

rm -rf "$STAGE" "$DMG"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"

hdiutil create \
  -volname "Token Monster" \
  -srcfolder "$STAGE" \
  -ov -format UDZO \
  "$DMG"

rm -rf "$STAGE"
echo "==> DMG: $DMG"
ls -lh "$DMG"
