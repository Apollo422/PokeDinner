<!--
# SPDX-FileCopyrightText: Copyright 2025 Eden Emulator Project
# SPDX-License-Identifier: GPL-3.0-or-later

# SPDX-FileCopyrightText: 2018 yuzu Emulator Project
# SPDX-License-Identifier: GPL-2.0-or-later
-->
<!-- lang: en-GB -->

> ## 🍎 PokeDinner for Mac — download and play
>
> **[⬇️ Download PokeDinner for Mac (Apple Silicon)](https://github.com/Apollo422/PokeDinner/releases/latest/download/PokeDinner-macOS-AppleSilicon.zip)**: ready to run, nothing else to install.
>
> **Needs:** Apple Silicon Mac (M1 or newer), macOS 15 Sequoia or later.
>
> **Install**
> 1. Download the zip above and double-click it to unzip.
> 2. Drag **PokeDinner.app** into **Applications**.
> 3. Open it. When macOS says it "could not verify" the app, click **Done**.
> 4. Go to **System Settings → Privacy & Security**, scroll down, click **Open Anyway**, and enter your password.
> 5. It opens normally from then on.
>
> **First-time setup**
> - **Keys:** Tools → Install Decryption Keys → choose your `prod.keys`
> - **Firmware:** Tools → Install Firmware → choose your firmware dump
> - **Games:** double-click the empty game list → add the folder with your `.nsp` / `.xci` files
> - **Settings:** press **⌘ ,**
>
> Keys, firmware, and games must be dumped from **your own** Nintendo Switch. They are not included.
>
> **Controllers:** Settings → Controls → Player 1 → pick your controller under *Input Device*, then click each button and press it.
> - *GameCube controller via Mayflash adapter:* set the adapter switch to **PC** mode and choose **"Nintendo GameCube Controller"**. If up/down is reversed, right-click the stick → **Invert axis**. If the stick feels weak, raise **Range** to about 150%.
>
> **Problems?**
> - *"App is damaged" / won't open:* repeat step 4. Or, in Terminal: `xattr -dr com.apple.quarantine /Applications/PokeDinner.app`
> - *Crashes right after launch:* open it again. A rare startup crash in the game list exists in the current code.
> - *"Missing keys":* reinstall keys (Tools → Install Decryption Keys). Keys must match your firmware version.
> - *"Deconstructed ROM directory" warning:* click OK; the game still runs. Single `.nsp`/`.xci` dumps add icons, names, and update support.
>
> **Slow / low FPS?** If the status bar says *"Building: N shader(s)"*, the game is preparing graphics. It stutters the first time through each area, then gets faster and stays fast. Press **⌘ ,** and check:
> - **Graphics → Resolution:** 1x (2x renders 4× the pixels)
> - **Graphics → ASTC Decoding Method:** GPU
> - **GraphicsAdvanced → GPU Mode:** Fast *(default on Mac)*
> - **GraphicsAdvanced → Use persistent pipeline cache** and **Use Vulkan pipeline cache:** ✅
> - **GraphicsExtra → Hacks → Enable asynchronous shader compilation:** ✅ *(default on Mac)*
> - **GraphicsAdvanced → GPU Fence Behavior:** Immediate *(set back to Default if graphics glitch)*
> - **CPU → Multicore CPU Emulation:** ✅
>
> Macs translate Switch graphics through an extra layer (Vulkan → Metal), so demanding games may stay below full speed even on M4-class chips.
>
> <sub>Mac build by Apollo422. Code by Franseven ([original repo](https://git.eden-emu.dev/Franseven/PokeDinner-a-Eglantine-Fork)), based on Eglantine / Eden / yuzu, GPLv3. Want to build it yourself? See [BUILD-AND-RUN-MAC.md](BUILD-AND-RUN-MAC.md).</sub>

<h4 align="center"><b>PokeDinner is a fork that unites commits and creates fixes, it is assisted by AI and requires expensive subscriptions, please consider donating if you can. 
  Authors of main are below, i'm not affiliated</b>
</h4>
<p align="center">
    <a href="https://www.paypal.com/donate/?hosted_button_id=R3XXSG8WC3T98">
        <img src="https://img.shields.io/badge/Donate-PayPal-00457C?logo=paypal&logoColor=white"
            alt="Donate with PayPal">
    </a>
</p>

<h1 align="center">
  <br>
  <a href="https://git.eden-emu.dev/eden-emu/eden"><img src="https://github.com/user-attachments/assets/35031845-4bfa-4916-8bf5-bc3bce67d5e2" alt="Eglantine" width="200"></a>
  <br>
  <b>Eglantine</b>
  <br>
</h1>

<h4 align="center"><b>Eglantine</b> is a free and opensource (FOSS) Switch 2 emulator, derived from Eden, Yuzu and Sudachi - started by developer Camille LaVey.
It's written in C++ with portability in mind, with builds for Windows, Linux and macOS
</h4>

<p align="center">
    </a>
    <a href="https://discord.gg/jCCZ58VExk">
        <img src="https://img.shields.io/discord/1367654015269339267?color=5865F2&label=Eglantine&logo=discord&logoColor=white"
            alt="Discord">
    </a>
  
</p>

<p align="center">
  <a href="#compatibility">Compatibility</a> |
  <a href="#development">Development</a> |
  <a href="#building">Building</a> |
  <a href="#download">Download</a> |
  <a href="#support">Support</a> |
  <a href="#license">License</a>
</p>

## Compatibility

The emulator is capable of running Mario Kart World at decent/full speed depending on specs and configurations, and Splatoon Raiders at variable performances

A list of supported games will be available in future. Please be patient.

## Development
For development discussions, please join us on [Discord](https://discord.gg/jCCZ58VExk)

If you would like to contribute, we are open to new developers and pull requests. Please ensure that your work is of a high standard and properly documented. You can also contact any of the developers on Discord or Stoat to learn more about the current state of the emulator.

## Documentation

We have a user manual! See our [User Handbook](./docs/user/README.md).

## Building

See the [General Build Guide](docs/Build.md)

For information on provided development tooling, see the [Tools directory](./tools)

## Download

You can download the latest releases from [here](https://github.com/Djihads80/Eglantine/releases).

## Support

We currently do not take in any donations for the time being

If you would prefer to support us in a different way, please join our [Discord](https://discord.gg/jCCZ58VExk)

## License

Eglantine is licensed under the GPLv3 (or any later version). Refer to the [LICENSE.txt](https://github.com/Djihads80/Eglantine/blob/nx2/LICENSE.txt) file.