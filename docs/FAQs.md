# FAQs and Troubleshooting
<br>

## Quick Navigation
<br>

**🚀 Getting Started:**

* [Can I set RetroFlow to launch when the Vita boots up?](#can-i-set-retroflow-to-launch-when-the-vita-boots-up)
* [Do I need to create bubbles for games?](#do-i-need-to-create-bubbles-for-games)
* [Can I change the rom folder locations?](#can-i-change-the-rom-folder-locations)
* [Can I use HexFlow too?](#can-i-use-hexflow-too)
<br><br>

**⚠️ Troubleshooting:**

* [Error screen - The RetroFlow won't start anymore](#error-screen---the-retroflow-wont-start-anymore)
* [I have duplicate games showing](#i-have-duplicate-games-showing)
* [Some systems aren't showing?](#some-systems-arent-showing)
<br><br>

**🎮 Adrenaline Issues:**

* [Adrenaline - My games aren't working?](#adrenaline---my-games-arent-working)
* [Adrenaline opens then closes without loading the game?](#adrenaline-opens-then-closes-without-loading-the-game)
* [Adrenaline how do I customise the game's boot settings?](#adrenaline-how-do-i-customise-the-games-boot-settings)
* [How do I uninstall Adrenaline Bubble Booter?](#how-do-i-uninstall-adrenaline-bubble-booter)
<br><br>

**🕹️ Emulator-Specific Issues:**

* [RetroArch games don't load](#retroarch-games-dont-load)
* [RetroArch fails to load games with "&" symbol in the game name](#retroarch-fails-to-load-games-with--symbol-in-the-game-name)
* [Can I change a core for RetroArch?](#can-i-change-a-core-for-retroarch)
* [PICO-8 games won't launch](#pico-8-games-wont-launch)
* [ScummVM some games won't launch](#scummvm-some-games-wont-launch)
* [Atari 5200 loads the memopad in RetroArch?](#atari-5200-loads-the-memopad-in-retroarch)
* [Some system apps open but don't launch?](#some-system-apps-open-but-dont-launch)
<br><br>

**🖼️ Artwork & Covers:**

* [Missing artwork - How should I name my games so covers are found?](#missing-artwork---how-should-i-name-my-games-so-covers-are-found)
* [Custom covers - How do I add custom covers?](#custom-covers---how-do-i-add-custom-covers)
* [CRC identification - Which systems and formats are supported?](#crc-identification---which-systems-and-formats-are-supported)
* [Why is there no option to download homebrew covers?](#why-is-there-no-option-to-download-homebrew-covers)
<br><br>

**⚙️ Configuration:**

* [How do I add disk based games?](#how-do-i-add-disk-based-games)
* [PS1 and RetroArch, how do I set it up?](#ps1-and-retroarch-how-do-i-set-it-up)
* [Can I change the Mega Drive name to Genesis?](#can-i-change-the-mega-drive-name-to-genesis)
<br><br>

**ℹ️ General Information:**

* [What's the difference between RetroFlow and HexFlow custom?](#whats-the-difference-between-retroflow-and-hexflow-custom)

<br>

---

## ⚠️ Troubleshooting

### Error screen - The RetroFlow won't start anymore

If you encounter a black error screen and the app won't load fully anymore, try these fixes in order:

**Fix 1: Install the latest version** 
<br>
Try installing the [latest nightly build](https://github.com/jimbob4000/RetroFlow-Launcher/releases/tag/Nightly).

**Fix 2: Manually clear the cache** 
<br>If that doesn't work, then try deleting these two folders to clear the cache:

`ux0:/data/RetroFlow/CACHE/` and  `ux0:/data/RetroFlow/TITLES/`.

**Fix 3: Start fresh**
<br>
As a last resort you can start again with a fresh install by renaming the RetroFlow's data folder:

`ux0:/data/RetroFlow/` to `ux0:/data/RetroFlow_Old` or whatever you would like to name it.

Once the app is working again you can try restoring assets like roms, covers, backgrounds, music etc. by moving or copying them back from the renamed folder.
<br><br>

### I have duplicate games showing

Check that you don't have more than one version of the game installed.

This tool can help: [RetroFlow Export Game List](https://github.com/jimbob4000/RetroFlow-Launcher/blob/main/docs/Tools.md#retroflow-export-game-list).
<br><br>

### Some systems aren't showing?

Empty collections are hidden by default. Once you add games into the game folders, they will appear.

<br>

---

## 🚀 Getting Started

### Can I set RetroFlow to launch when the Vita boots up?

If you want to auto-launch **RetroFlow Launcher** every time your PS Vita boots up, you can use the [**AutoBoot**](https://www.rinnegatamante.eu/vitadb/#/info/261) plugin by Rinnegatamante. 

⚠️ **Warning:** Use at your own risk. If AutoBoot causes issues, you may need to access recovery mode to disable it. The title ID for RetroFlow is "RETROFLOW".
<br><br>

### Do I need to create bubbles for games?

No; RetroFlow doesn't need bubbles for games.
<br><br>

### Can I change the rom folder locations?

Yes, from version 4.0 onwards.

Go to 'Scan settings' and then 'Edit game directories' to change the path to rom folders.
<br><br>

### Can I use HexFlow too?

Yes; RetroFlow is separate. It uses different folders and a different title ID, so both can be installed simultaneously.

<br>

---

## 🎮 Adrenaline Issues

### Adrenaline - My games aren't working?
 * Check you are using the official version of Adrenaline [(6.61 Adrenaline-7)](https://github.com/TheOfficialFloW/Adrenaline/releases/tag/v7) by TheOfficialFloW.
<br>Forks of Adrenaline are not supported.
<br>
 * Check you have installed the 'RetroFlow Adrenaline Launcher' and that Adrenaline is functioning okay outside of RetroFlow.
<br><br>

### Adrenaline opens then closes without loading the game?

**Behaviour:** Adrenaline opens and then closes without loading the game (returning you to the livearea).

This is a known issue with Adrenaline called the 'double launch bug'. Fix it by following the guide here: [https://github.com/TheOfficialFloW/Adrenaline#getting-rid-of-double-launch-bug](https://github.com/TheOfficialFloW/Adrenaline#getting-rid-of-double-launch-bug)
<br><br>

### Adrenaline how do I customise the game's boot settings?

To change boot settings for PSP games:

1. In RetroFlow, navigate to the game
2. Press Triangle twice
3. Select 'Adrenaline options'
4. Customize your settings
5. Click save

**Note:** If you change settings while the game is running, RetroFlow won't remember them. Always configure in RetroFlow to save them permanently.
<br><br>

### How do I uninstall Adrenaline Bubble Booter?

If you followed the install guide you should be on Adrenaline version 7.

**For Adrenaline v7:**

1. Copy the 'sce_module' folder from: `ux0:app/RETROFLOW/payloads/adrenaline/sce_module`
2. Paste it into the adrenaline directory: `ux0:app/PSPEMUCFW` (overwriting the old 'sce_module' folder)
3. If you want a backup, rename the folder before pasting
4. Restart the vita for changes to take effect

**For other versions of Adrenaline:**

Uninstall Adrenaline and reinstall it.

**Note:** Uninstalling Adrenaline Bubble Booter will stop any custom PS1 or PSP bubbles created using Adrenaline Bubble Manager from working unless it is installed once again. Adrenaline Bubble Manager can reinstall it if needed.

<br>

---

## 🕹️ Emulator-Specific Issues

### RetroArch games don't load

Older versions of RetroArch don't support launchers. 
See the [recommeded emulator versions](https://github.com/jimbob4000/RetroFlow-Launcher/blob/main/docs/Recommended-emulator-versions.md) page for version which will work. 
Or update to version 1.9.4 or newer, see the [RetroArch buildbot](https://buildbot.libretro.com/stable/) for available versions.
<br><br>

### RetroArch fails to load games with "&" symbol in the game name

This is an issue with RetroArch version 1.11 onwards. Install an older version of RetroArch until the issue is resolved. See the [recommeded emulator versions](https://github.com/jimbob4000/RetroFlow-Launcher/blob/main/docs/Recommended-emulator-versions.md) page for version which will work.
<br><br>

### Can I change a core for RetroArch?

The cores are set by system and cannot be changed on a per-game basis.

To change the core for an entire system:
1. Open `ux0:/app/RETROFLOW/index.lua`
2. Search for "Retroarch Cores"
3. Edit the core file names accordingly

RetroArch core files are located in: `ux0:/app/RETROVITA/`
<br><br>

### PICO-8 games won't launch

Support for launchers was added after July 5, 2021. Update to a more current version of [FAKE-08](https://github.com/jtothebell/fake-08/releases).
<br><br>

### ScummVM some games won't launch

Some games don't launch on ScummVM version 2.7.0. See the [recommeded emulator versions](https://github.com/jimbob4000/RetroFlow-Launcher/blob/main/docs/Recommended-emulator-versions.md) page for version which will work.
<br><br>

### Atari 5200 loads the memopad in RetroArch?

When the game is running in RetroArch:

1. Bring up the RetroArch quick menu
2. Go to 'Options > Atari System' and select 5200
3. Go back one level and select 'Overrides > Save core overrides'

The games should work provided you have everything else set up correctly.
<br><br>

### Some system apps open but don't launch?

The launch commands for some system apps are unknown. This is the best we can do at the moment.

<br>

---

## 🖼️ Artwork & Covers

### Missing artwork - How should I name my games so covers are found?
Name your ROMs using the **no-intro** file naming convention (e.g., "Game Name (USA)") for best artwork matching.

From version 7 onwards, RetroFlow uses CRC checksum identification when downloading artwork. However, not all systems support this, so no-intro filenames are still recommended. See [CRC identification](#crc-identification---which-systems-and-formats-are-supported) for more details.
<br><br>

### Custom covers - How do I add custom covers?

Custom covers override default covers. The filename should match the game name as shown in RetroFlow.

**Retro game example:**
```
Game name: My Game (USA).gba
Normal cover: My Game (USA).png
Custom cover: My Game.png
```

**Vita, PSP, PSX, PSM and Vita Homebrew:**
```
App ID: PCSE123456
Normal cover: PCSE123456.png
Custom cover: My Game.png
```

**PSP Homebrew (ISO format in ux0:pspemu/ISO/):**
```
App ID: PCSE123456
Normal cover: PCSE123456.png
Custom cover: My Game.png
```

**PSP Homebrew (EBOOT format in ux0:pspemu/PSP/GAME/):**
```
Homebrew folder: Flappy Bird
Cover name: Flappy Bird.png
```

**Location:** Save custom covers in the appropriate subfolder:
`ux0:/data/RetroFlow/COVERS/[System Name]/`

Example: `ux0:/data/RetroFlow/COVERS/Nintendo - Game Boy Advance/`

⚠️ **Important:** Rescan your games after adding custom covers.
<br><br>

### CRC identification - Which systems and formats are supported?

**Archive support:**
- ✅ Zip archives supported
- ❌ RAR and 7z not supported

**Note:** CRC checks on zip files require extraction. If you experience crashes or memory issues, extract files on a PC first.

**CRC supported systems:**
Nintendo 64, Super Nintendo, Nintendo Entertainment System, Game Boy Advance, Game Boy Color, Game Boy, Sega 32X, Sega Mega Drive / Genesis, Sega Master System, Sega Game Gear, PC Engine, TurboGrafx-16, WonderSwan, WonderSwan Color, MSX, MSX2, Atari Lynx, Atari 600, Atari 5200, Atari 7800, ColecoVision, Vectrex, Neo Geo Pocket Color.

**CRC not available:**
Sega Dreamcast, Sega CD, PC Engine CD, TurboGrafx-CD, Commodore Amiga, Commodore 64, ZX Spectrum.

**Systems using alternative identification:**
PS Vita, PSP, PlayStation, PlayStation Mobile, FBA 2012, MAME 2003 Plus, MAME 2000, Neo Geo (FBA 2012), ScummVM, PICO-8, NDS.
<br><br>

### Why is there no option to download homebrew covers?

Covers aren't needed for homebrew applications because the app icon is used instead.

If you move a homebrew game port into the Vita category, you can download a cover if available. You can also add custom covers manually.

<br>

---

## ⚙️ Configuration

### How do I add disk based games?

**PC Engine CD and TurboGrafx-CD:**
RetroFlow looks for '.cue' files. Ensure all games are in the system's game folder with .cue files.

**Dreamcast:**
'.gdi' and '.cdi' formats are supported.

**PS1 using RetroArch:**
Uses the 'PCSX ReARMed' core. See [supported extensions and setup](https://docs.libretro.com/library/pcsx_rearmed/).
<br><br>

### PS1 and RetroArch, how do I set it up?

RetroArch PlayStation 1 games use the 'PCSX ReARMed' core. For supported extensions and setup instructions: [PCSX ReARMed Documentation](https://docs.libretro.com/library/pcsx_rearmed/)
<br><br>

### Can I change the Mega Drive name to Genesis?

Yes. Change your language to 'English - American' and the 'Mega Drive' name and logo will change to 'Genesis'.

<br>

---

## ℹ️ General Information

### What's the difference between RetroFlow and HexFlow custom?

HexFlow Custom is also a fork of HexFlow, which can be confusing. I've created a detailed comparison table:

[RetroFlow vs HexFlow Custom - Feature Comparison](https://github.com/jimbob4000/RetroFlow-Launcher/blob/main/docs/RetroFlow-vs-HexFlow-Custom-Feature-Comparison.md)
<br><br>



[< Back to main page](https://github.com/jimbob4000/RetroFlow-Launcher)
