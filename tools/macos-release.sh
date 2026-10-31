#!/usr/bin/env bash
# Build, package, and publish a NEW GitHub release for the Mac app.
# Every run creates a new tag so older versions stay downloadable.
#
# Usage: tools/macos-release.sh "What changed in this version" [patch|minor|major]
#
# Versions follow semver tags: v1.0.0 -> v1.0.1 (patch, default) -> v1.1.0 (minor) -> v2.0.0 (major).
#   patch: bug fixes and small tweaks
#   minor: new features or notable improvements
#   major: big changes that may break settings or workflows
set -euo pipefail

CHANGES="${1:?usage: tools/macos-release.sh \"what changed\" [patch|minor|major]}"
BUMP="${2:-patch}"
REPO="${RELEASE_REPO:-Apollo422/PokeDinner}"
REMOTE="${RELEASE_REMOTE:-github}"
BUILD_DIR="build/release"
OUT_DIR="build/macos-release"
ZIP="$OUT_DIR/PokeDinner-macOS-AppleSilicon.zip"

cd "$(git rev-parse --show-toplevel)"

if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
    echo "error: commit your changes first, so the release matches a pushed commit" >&2
    exit 1
fi

# Next version from the newest vX.Y.Z release.
LATEST="$(gh release list -R "$REPO" --limit 100 --json tagName -q '.[].tagName' \
          | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sed 's/^v//' | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)"
IFS=. read -r MAJ MIN PAT <<< "${LATEST:-0.0.0}"
case "$BUMP" in
    patch) PAT=$((PAT + 1)) ;;
    minor) MIN=$((MIN + 1)); PAT=0 ;;
    major) MAJ=$((MAJ + 1)); MIN=0; PAT=0 ;;
    *) echo "error: bump must be patch, minor, or major" >&2; exit 1 ;;
esac
VERSION="$MAJ.$MIN.$PAT"
TAG="v$VERSION"
if gh release view "$TAG" -R "$REPO" >/dev/null 2>&1; then
    echo "error: $TAG already exists" >&2; exit 1
fi
echo "==> Releasing $TAG (previous: ${LATEST:-none})"

echo "==> Building"
cmake --build "$BUILD_DIR"

echo "==> Packaging"
APP_VERSION="$VERSION" tools/macos-package.sh "$BUILD_DIR" "$OUT_DIR"
SHA="$(shasum -a 256 "$ZIP" | cut -d' ' -f1)"

echo "==> Pushing source"
git push "$REMOTE" HEAD:master
COMMIT="$(git rev-parse --short HEAD)"

NOTES="$(mktemp)"
cat > "$NOTES" <<EOF
## What's new in $TAG
$CHANGES

---

Ready-to-run **macOS build of PokeDinner** for Apple Silicon Macs. Nothing else to install: no Homebrew, no Terminal.

**Requirements:** Apple Silicon Mac (M1 or newer), macOS 15 Sequoia or later.

### Install
1. Download **PokeDinner-macOS-AppleSilicon.zip** below and double-click it to unzip.
2. Drag **PokeDinner.app** into your **Applications** folder (replace the old one if updating).
3. Open it. macOS will say it "could not verify" the app (it is not notarized by Apple). Click **Done**.
4. Open **System Settings → Privacy & Security**, scroll down, and click **Open Anyway** next to PokeDinner. Confirm with your password.
5. From now on it opens normally.

### First-time setup
- **Keys:** Tools → Install Decryption Keys → choose your \`prod.keys\`
- **Firmware:** Tools → Install Firmware → choose your firmware dump
- **Games:** double-click the empty game list → add the folder with your \`.nsp\` / \`.xci\` files

Keys, firmware, and games must be dumped from **your own** Nintendo Switch. They are not included.

Running slow? See **"Slow / low FPS?"** in the README. Also see the README for controller setup and troubleshooting.
Older versions are listed on the Releases page.

---
Built from commit \`$COMMIT\` of this repository. Code by [Franseven](https://git.eden-emu.dev/Franseven/PokeDinner-a-Eglantine-Fork), based on Eglantine / Eden / yuzu. GPLv3, and the full source is in this repo.

SHA-256: \`$SHA\`
EOF

echo "==> Creating release $TAG"
gh release create "$TAG" "$ZIP" -R "$REPO" --target "$(git rev-parse HEAD)" \
    --title "PokeDinner for Mac $TAG" --notes-file "$NOTES" --latest
rm -f "$NOTES"

echo "Released: https://github.com/$REPO/releases/tag/$TAG"
