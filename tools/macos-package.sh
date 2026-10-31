#!/usr/bin/env bash
# Package a self-contained, ad-hoc-signed PokeDinner.app zip for Apple Silicon Macs.
# Bundles Homebrew/Qt libraries so end users need nothing else installed.
#
# Usage: tools/macos-package.sh [build-dir] [output-dir]
#   build-dir  defaults to build/release
#   output-dir defaults to build/macos-release
set -euo pipefail

BUILD_DIR="${1:-build/release}"
OUT_DIR="${2:-build/macos-release}"
SRC_APP="$BUILD_DIR/bin/eglantine.app"
APP_NAME="PokeDinner"
ZIP_NAME="$APP_NAME-macOS-AppleSilicon.zip"
MACDEPLOYQT="$(brew --prefix qt)/bin/macdeployqt"
BREW_LIB="$(brew --prefix)/lib"
FW='@executable_path/../Frameworks'

[[ -d "$SRC_APP" ]] || { echo "error: $SRC_APP not found; build first" >&2; exit 1; }
[[ -x "$MACDEPLOYQT" ]] || { echo "error: macdeployqt not found (brew install qt)" >&2; exit 1; }

rm -rf "$OUT_DIR" && mkdir -p "$OUT_DIR"
WORK="$OUT_DIR/eglantine.app"
cp -R "$SRC_APP" "$WORK"

# Non-code files in Contents/MacOS keep their signature in xattrs, which zips drop.
rm -f "$WORK/Contents/MacOS/nx2_switches.txt"

echo "==> Bundling libraries"
"$MACDEPLOYQT" "$WORK" -libpath="$BREW_LIB" 2>&1 | grep -E '^ERROR' | sort -u || true

# Plugins whose Qt modules we don't ship and don't need.
rm -f "$WORK/Contents/PlugIns/platforminputcontexts/libqtvirtualkeyboardplugin.dylib" \
      "$WORK/Contents/PlugIns/imageformats/libqpdf.dylib"

# QtSvg is needed for SVG icons but macdeployqt misses it (separate Homebrew keg).
SVG_FW="$(brew --prefix qtsvg)/lib/QtSvg.framework"
if [[ -d "$SVG_FW" && ! -d "$WORK/Contents/Frameworks/QtSvg.framework" ]]; then
    cp -R "$SVG_FW" "$WORK/Contents/Frameworks/"
    chmod -R u+w "$WORK/Contents/Frameworks/QtSvg.framework"
    SVG_BIN="$WORK/Contents/Frameworks/QtSvg.framework/Versions/A/QtSvg"
    install_name_tool -id "$FW/QtSvg.framework/Versions/A/QtSvg" "$SVG_BIN" 2>/dev/null
    for mod in QtGui QtCore; do
        old="$(otool -L "$SVG_BIN" | awk -v m="$mod.framework" '$0 ~ m {print $1; exit}')"
        [[ -n "$old" ]] && install_name_tool -change "$old" "$FW/$mod.framework/Versions/A/$mod" "$SVG_BIN" 2>/dev/null
    done
fi
while IFS= read -r -d '' plugin; do
    if otool -L "$plugin" | grep -q '@rpath/QtSvg.framework'; then
        install_name_tool -change @rpath/QtSvg.framework/Versions/A/QtSvg \
            "$FW/QtSvg.framework/Versions/A/QtSvg" "$plugin" 2>/dev/null
    fi
done < <(find "$WORK/Contents/PlugIns" -name '*.dylib' -print0)

BIN="$WORK/Contents/MacOS/eglantine"
install_name_tool -delete_rpath "$BREW_LIB" "$BIN" 2>/dev/null || true
install_name_tool -add_rpath "$FW" "$BIN" 2>/dev/null || true

echo "==> Checking for leftover Homebrew references"
LEFT="$(find "$WORK" -type f \( -perm -111 -o -name '*.dylib' \) -print0 \
        | xargs -0 otool -L 2>/dev/null | grep -E '/opt/homebrew|/usr/local' || true)"
if [[ -n "$LEFT" ]]; then
    echo "error: bundle still links to Homebrew:" >&2
    echo "$LEFT" | sort -u >&2
    exit 1
fi

echo "==> Setting bundle metadata"
PLIST="$WORK/Contents/Info.plist"
PB=/usr/libexec/PlistBuddy
VERSION="${APP_VERSION:-$(date +%Y.%m.%d)}"
set_key() { $PB -c "Set :$1 $2" "$PLIST" 2>/dev/null || $PB -c "Add :$1 string $2" "$PLIST"; }
set_key CFBundleExecutable eglantine
set_key CFBundleName "$APP_NAME"
set_key CFBundleDisplayName "$APP_NAME"
set_key CFBundleShortVersionString "$VERSION"
set_key CFBundleVersion "$VERSION"
set_key LSMinimumSystemVersion 15.0
plutil -lint "$PLIST" >/dev/null

mv "$WORK" "$OUT_DIR/$APP_NAME.app"
APP="$OUT_DIR/$APP_NAME.app"

echo "==> Signing"
xattr -cr "$APP"
codesign --force --deep --sign - "$APP"
codesign --verify --deep --strict "$APP"

echo "==> Zipping (no xattrs / AppleDouble files)"
ditto -c -k --norsrc --noextattr --noqtn --keepParent "$APP" "$OUT_DIR/$ZIP_NAME"

echo "==> Verifying zip round-trip"
CHECK="$(mktemp -d)"
ditto -x -k "$OUT_DIR/$ZIP_NAME" "$CHECK"
codesign --verify --deep --strict "$CHECK/$APP_NAME.app"
[[ -z "$(find "$CHECK" -name '._*')" ]] || { echo "error: AppleDouble files in zip" >&2; exit 1; }
rm -rf "$CHECK"

shasum -a 256 "$OUT_DIR/$ZIP_NAME"
echo "Done: $OUT_DIR/$ZIP_NAME"
