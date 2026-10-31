# Build and Run on a Mac

Step-by-step guide to build this emulator from source and run it on an Apple Silicon Mac. No AI assistant needed — every command is below. (An AI-assisted shortcut is at the end.)

> Windows/Linux users: see [docs/Build.md](docs/Build.md) and [docs/Deps.md](docs/Deps.md).

**Tested on:** MacBook Air M1, macOS 15 (Sequoia), Homebrew, Release build.
**Time:** ~10 min setup + 20–60 min compile. **Disk:** ~15 GB free recommended.

---

## What you need

- Apple Silicon Mac (M1 or newer), macOS 15+
- Internet connection
- **Your own** Nintendo Switch: keys (`prod.keys`), firmware, and game dumps must come from a console you own. This project does not provide them, and this guide does not explain where to download them.

---

## Step 1 — Install Apple's command-line tools

Open **Terminal** (Applications → Utilities → Terminal) and run:

```bash
xcode-select --install
```

Click **Install** in the pop-up and wait for it to finish. (Full Xcode is not required.)

## Step 2 — Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

When it finishes it prints two commands under "Next steps" — run them so `brew` works. Check:

```bash
brew --version
```

## Step 3 — Install build dependencies

```bash
brew install autoconf automake boost ffmpeg fmt glslang hidapi libtool libusb lz4 \
  ninja nlohmann-json openssl pkg-config qt@6 sdl3 speexdsp zlib zstd cmake \
  Catch2 molten-vk vulkan-loader spirv-tools git
```

This downloads a few GB and can take 10+ minutes.

## Step 4 — Download the source

Pick **one**:

```bash
# PokeDinner
git clone https://github.com/Apollo422/PokeDinner.git
cd PokeDinner
```

```bash
# Eglantine (branch nx2)
git clone -b nx2 https://github.com/Apollo422/Eglantine.git
cd Eglantine
```

## Step 5 — Configure

```bash
cmake -S . -B build/release -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=15.0 \
  -DENABLE_QT_TRANSLATION=OFF \
  -DENABLE_UPDATE_CHECKER=OFF \
  -DENABLE_WEB_SERVICE=OFF \
  -DUSE_DISCORD_PRESENCE=OFF \
  -DYUZU_TESTS=OFF \
  -DYUZU_USE_BUNDLED_MOLTENVK=ON
```

The first run downloads extra libraries (externals) — needs internet, takes a few minutes. It should end with `-- Build files have been written to: .../build/release`.

## Step 6 — Compile

```bash
cmake --build build/release
```

Takes 20–60 minutes. The fans will spin; that's normal. If it stops with an error, run the same command again — it resumes where it left off.

When done, the app is at:

```
build/release/bin/eglantine.app
```

## Step 7 — Sign and launch

The build is unsigned, so macOS blocks it until you ad-hoc sign it:

```bash
codesign --force --deep --sign - build/release/bin/eglantine.app
xattr -dr com.apple.quarantine build/release/bin/eglantine.app
open build/release/bin/eglantine.app
```

Optional — copy it to Applications:

```bash
cp -R build/release/bin/eglantine.app /Applications/
```

If macOS still says it "can't be opened": **System Settings → Privacy & Security** → scroll down → **Open Anyway**.

---

## Step 8 — First-time setup in the app

1. **Keys:** **Tools → Install Decryption Keys** → pick your `prod.keys`.
   (Or copy `prod.keys` / `title.keys` into `~/.local/share/eden/keys/` yourself —
   **File → Open Eglantine Folders → Root Data Folder** opens it.)
2. **Firmware:** **Tools → Install Firmware → From Folder** (or from ZIP) → pick your firmware dump.
3. **Games:** double-click the game list area → **Add Game Directory** → choose the folder with your `.nsp` / `.xci` dumps.
4. Restart the app.

Settings live in: `~/.config/eden/qt-config.ini`
Data (keys, saves, NAND) lives in: `~/.local/share/eden/`

Open settings with **⌘ ,** (or app menu → **Settings…**).

---

## Controllers

**Settings → Controls → Player 1 → Input Device**, then click each button and press it on the controller.

**GameCube controller via Mayflash adapter:**
- Set the adapter switch to **PC** mode (not Wii U).
- Choose **"Nintendo GameCube Controller"** (the SDL device) as Input Device — the built-in "GC Adapter" driver does not work on macOS.
- If up/down is reversed: right-click the stick in Controls → **Invert axis**.
- If the stick feels weak: raise the **Range** slider to ~150%.

---

## Updating later

```bash
cd PokeDinner          # or Eglantine
git pull
cmake --build build/release
codesign --force --deep --sign - build/release/bin/eglantine.app
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `xcrun: error: invalid active developer path` | Run `xcode-select --install` |
| `command not found: brew` | Run the two "Next steps" commands Homebrew printed, or reopen Terminal |
| `Could NOT find Qt6` | `brew install qt@6`, then add `-DCMAKE_PREFIX_PATH=$(brew --prefix qt@6)` to Step 5 |
| `CMake 3.31 or higher is required` | `brew upgrade cmake` |
| Configure fails downloading externals | Check internet, delete `build/release`, retry Step 5 |
| Compile killed / Mac freezes | Use fewer threads: `cmake --build build/release -j 4` |
| `No space left on device` | Free ~15 GB, run Step 6 again |
| App "is damaged" / "can't be opened" | Re-run Step 7 commands |
| App crashes on start mentioning a `.dylib` | A Homebrew library was removed or upgraded — `brew install` again (Step 3) and rebuild |
| "Missing keys" / games won't load | Keys go in `~/.local/share/eden/keys/`, and must match your firmware version |
| Low FPS | Settings → Graphics: lower resolution scale; make sure Vulkan (MoltenVK) is selected |

> macOS support is experimental upstream (see [docs/Caveats.md](docs/Caveats.md)). Expect crashes and graphics bugs in some games.

---

## Can I just copy my built app to a friend's Mac?

Only if they also install the Homebrew dependencies from **Step 3** — the app links to ~28 Homebrew libraries in `/opt/homebrew` and won't start without them. Then they run the `codesign` and `xattr` commands from Step 7 on the copied app.

---

## Using an AI assistant instead (optional)

If you have Claude Code or a similar coding assistant, open Terminal in the cloned folder and ask:

> Build this project for macOS following BUILD-AND-RUN-MAC.md. Install missing Homebrew dependencies, configure with the flags in Step 5, compile, ad-hoc sign the app, and launch it. Stop and tell me about any errors.

The assistant runs the same steps above; reading this guide tells you what it's doing.
