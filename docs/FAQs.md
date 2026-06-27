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
* [How do I use the Recovery tools?](#how-do-i-use-the-recovery-tools)
* [I have duplicate games showing](#i-have-duplicate-games-showing)
* [Some systems aren't showing?](#some-systems-arent-showing)
* [My Vita cartridge games aren't showing](#vita-game-cartridge-support)
<br><br>

**🎮 Adrenaline Issues:**

* [Adrenaline - PSP and PS1 are missing](#adrenaline---psp-and-ps1-are-missing)
* [Adrenaline - My games aren't working?](#adrenaline---my-games-arent-working)
* [Adrenaline opens then closes without loading the game?](#adrenaline-opens-then-closes-without-loading-the-game)
* [Adrenaline - How do I customise the game's boot settings?](#adrenaline---how-do-i-customise-the-games-boot-settings)
* [How do I uninstall Adrenaline Bubble Booter?](#how-do-i-uninstall-adrenaline-bubble-booter)
<br><br>

**🕹️ Emulator-Specific Issues:**

* [RetroArch games don't load](#retroarch-games-dont-load)
* [Emu4Vita++ games don't load](#emu4vita-games-dont-load)
* [Can I change a core for RetroArch or Emu4Vita++?](#can-i-change-a-core-for-retroarch-or-emu4vita)
* [I changed a core and my game no longer loads](#i-changed-a-core-and-my-game-no-longer-loads)
* [RetroArch fails to load games with "&" symbol in the game name](#retroarch-fails-to-load-games-with--symbol-in-the-game-name)
* [PICO-8 games won't launch](#pico-8-games-wont-launch)
* [ScummVM some games won't launch](#scummvm-some-games-wont-launch)
* [Atari 5200 loads the memopad in RetroArch?](#atari-5200-loads-the-memopad-in-retroarch)
* [Some system apps open but don't launch?](#some-system-apps-open-but-dont-launch)
<br><br>

**📚 Custom Game Collections:**

* [How do I add a game to a custom collection?](#how-do-i-add-a-game-to-a-custom-collection)
* [How do I create a collection from search results?](#how-do-i-create-a-collection-from-search-results)
* [How do I rename a collection?](#how-do-i-rename-a-collection)
* [How to reorder games in a collection](#how-to-reorder-games-in-a-collection)
<br><br>

**🖼️ Artwork & Covers:**

* [Missing artwork - How should I name my games so covers are found?](#missing-artwork---how-should-i-name-my-games-so-covers-are-found)
* [Custom covers - How do I add custom covers?](#custom-covers---how-do-i-add-custom-covers)
* [How do I add custom icons to the game info screen?](#how-do-i-add-custom-icons-to-the-game-info-screen)
* [Why is there no option to download homebrew covers?](#why-is-there-no-option-to-download-homebrew-covers)
* [CRC identification - Which systems and formats are supported?](#crc-identification---which-systems-and-formats-are-supported)
<br><br>

**⚙️ Configuration:**

* [How do I add disc based games?](#how-do-i-add-disc-based-games)
* [How do I add MS-DOS games?](#how-do-i-add-ms-dos-games)
* [PS1 and RetroArch, how do I set it up?](#ps1-and-retroarch-how-do-i-set-it-up)
* [Can I change the Mega Drive name to Genesis?](#can-i-change-the-mega-drive-name-to-genesis)
* [Vita game cartridge support?](#vita-game-cartridge-support)
<br><br>

**ℹ️ General Information:**

* [What's the difference between RetroFlow and HexFlow custom?](#whats-the-difference-between-retroflow-and-hexflow-custom)

<br>

---

## 🚀 Getting Started
<br>

### Can I set RetroFlow to launch when the Vita boots up?

If you want to auto-launch **RetroFlow Launcher** every time your PS Vita boots up, you can use the [**AutoBoot**](https://www.rinnegatamante.eu/vitadb/#/info/261) plugin by Rinnegatamante. 

⚠️ **Warning:** Use at your own risk. If AutoBoot causes issues, you may need to access recovery mode to disable it. The title ID for RetroFlow is "RETROFLOW".
<br><br><br>

### Do I need to create bubbles for games?

No; RetroFlow doesn't need bubbles for games.
<br><br><br>

### Can I change the rom folder locations?

Yes, from version 4.0 onwards.

Go to 'Scan settings' and then 'Edit game directories' to change the path to rom folders.
<br><br><br>

### Can I use HexFlow too?

Yes; RetroFlow is separate. It uses different folders and a different title ID, so both can be installed simultaneously.

<br>

---

## ⚠️ Troubleshooting
<br>

### Error screen - The RetroFlow won't start anymore

If you encounter a black error screen and the app won't load fully anymore, try these fixes in order:

**Fix 1: Use the LiveArea Recovery Tools**  
Open RetroFlow's LiveArea and select 'Recovery tools'.  
See [How do I use the Recovery tools?](#how-do-i-use-the-recovery-tools).

**Fix 2: Install the latest version**  
Try installing the [latest nightly build](https://github.com/jimbob4000/RetroFlow-Launcher/releases/tag/Nightly). Then try the Recovery tools again if needed.
<br><br><br>

### How do I use the Recovery tools?

If RetroFlow won't start or displays an error screen during startup:

1. Return to the Vita LiveArea.
2. Select 'Recovery tools' below the Start button.
3. Try the recovery options in this order. After using each tool, try loading RetroFlow again:
   - Delete Cache
   - Reset Configuration
   - Full Reset

Use **Full Reset** only as a last resort. It renames RetroFlow's data folder so RetroFlow can start fresh. Your games and artwork are not deleted, but you may need to move files back manually afterwards.

If the Recovery tools are not available in the LiveArea, update RetroFlow to version 8.1.0 or newer.
<br><br><br>

### I have duplicate games showing

Check that you don't have more than one version of the game installed.

This tool can help: [RetroFlow Export Game List](https://github.com/jimbob4000/RetroFlow-Launcher/blob/main/docs/Tools.md#retroflow-export-game-list).
<br><br><br>

### Some systems aren't showing?

Empty collections are hidden by default. Once you add games into the game folders, they will appear.

<br>

---

## 🎮 Adrenaline Issues
<br>

### Adrenaline - PSP and PS1 are missing?

**Check the scan settings are correct:**

* Go to 'Settings > Scan Settings > Adrenaline games'.
* Select the path(s) to scan.
* Then select 'Rescan' to check for games.

**Still not showing?**

Check you have the official version of Adrenaline installed [(6.61 Adrenaline-7 by TheOfficialFloW)](https://github.com/TheOfficialFloW/Adrenaline/releases/tag/v7).

Forks or modified versions of Adrenaline are not supported.

From version 8.1.0 onwards, RetroFlow performs a compatibility check. If an unsupported version is detected, the PSP and PS1 categories will be disabled.
<br><br><br>

### Adrenaline - My games aren't working?

Please check:

* Adrenaline works correctly outside of RetroFlow
* RetroFlow Adrenaline Launcher is installed
* Check you are using the official version of Adrenaline [(6.61 Adrenaline-7)](https://github.com/TheOfficialFloW/Adrenaline/releases/tag/v7) by TheOfficialFloW. Forks of Adrenaline are not supported.
<br><br><br>

### Adrenaline opens then closes without loading the game?

**Behaviour:** Adrenaline opens and then closes without loading the game (returning you to the livearea).

This is a known issue with Adrenaline called the 'double launch bug'. Fix it by following the guide here: [https://github.com/TheOfficialFloW/Adrenaline#getting-rid-of-double-launch-bug](https://github.com/TheOfficialFloW/Adrenaline#getting-rid-of-double-launch-bug)
<br><br><br>

### Adrenaline - How do I customise the game's boot settings?

To change boot settings for PSP games:

1. In RetroFlow, navigate to the game
2. Press Triangle twice
3. Select 'Adrenaline options'
4. Customize your settings
5. Click save

**Note:** If you change settings while the game is running, RetroFlow won't remember them. Always configure in RetroFlow to save them permanently.
<br><br><br>

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
<br>

### RetroArch games don't load

Older versions of RetroArch don't support launchers. 
See the [recommended emulator versions](https://github.com/jimbob4000/RetroFlow-Launcher/blob/main/docs/Recommended-emulator-versions.md) page for version which will work. 
Or update to version 1.9.4 or newer, see the [RetroArch buildbot](https://buildbot.libretro.com/stable/) for available versions.
<br><br><br>

### Emu4Vita++ games don't load

Launching games with Emu4Vita++ from RetroFlow requires Emu4Vita++ version 0.71 or newer.

If Emu4Vita++ opens but doesn't start the selected game, update to version 0.71 or newer.

[Emu4VitaPlus GitHub releases](https://github.com/noword/Emu4VitaPlus/releases).
<br><br><br>

### Can I change a core for RetroArch or Emu4Vita++?

Yes. From version 8.2.0 onwards, RetroFlow supports both global and per-game core overrides for RetroArch and Emu4Vita++.

The global core is used by default unless a game-specific override has been configured.

**Global core overrides**

1. To change a core for an entire system, go to:
<br>'Settings > Other Settings > Global core settings'
2. Then select a core for the platform.

**Game-specific overrides**

1. Go to 'Settings > Other Settings'.
2. Turn on 'Show game core menu'.
3. Navigate to the game.
4. Press Triangle.
5. Select 'Emulator core'.
6. Change the core.
7. Save your changes.

The selected core will be remembered for that specific game.
<br><br><br>

### I changed a core and my game no longer loads

Some systems support multiple emulator cores, but not every core is compatible with every game.

Try one of the following:

1. Change the game back to the recommended core.
2. Remove the game-specific core override.
3. Reset the platform core in Global core settings.

Recommended cores are marked with a ★ symbol.
<br><br><br>

### RetroArch fails to load games with "&" symbol in the game name

This is an issue with RetroArch version 1.11 onwards. Install an older version of RetroArch until the issue is resolved. See the [recommended emulator versions](https://github.com/jimbob4000/RetroFlow-Launcher/blob/main/docs/Recommended-emulator-versions.md) page for version which will work.
<br><br><br>

### PICO-8 games won't launch

Support for launchers was added after July 5, 2021. Update to a more current version of [FAKE-08](https://github.com/jtothebell/fake-08/releases).
<br><br><br>

### ScummVM some games won't launch

Some games don't launch on ScummVM version 2.7.0. See the [recommended emulator versions](https://github.com/jimbob4000/RetroFlow-Launcher/blob/main/docs/Recommended-emulator-versions.md) page for version which will work.
<br><br><br>

### Atari 5200 loads the memopad in RetroArch?

When the game is running in RetroArch:

1. Bring up the RetroArch quick menu
2. Go to 'Options > Atari System' and select 5200
3. Go back one level and select 'Overrides > Save core overrides'

The games should work provided you have everything else set up correctly.
<br><br><br>

### Some system apps open but don't launch?

The launch commands for some system apps are unknown. This is the best we can do at the moment.

<br>

---

## 📚 Custom Game Collections
<br>

### How do I add a game to a custom collection?

1. Press triangle on a game to bring up the game information screen
2. Press triangle again and select 'Add to collection'.
3. Select either 'New collection' or choose one you have already made.
4. Go down and select 'Add to collection'
5. If it's a new collection, you will be asked to name it.

**Tip:** You can quickly create collections by searching for games and adding all the results to a collection. See below for more info.
<br><br><br>

### How do I create a collection from search results?

You can quickly create collections from search results.

1. Press Select to search
2. Enter your search term
3. Press D-Pad Up or D-Pad Right
4. Select Add to collection

All current search results will be added to the selected collection.
<br><br><br>

### How do I rename a collection?

To rename a collection:
* Go to 'Other settings > Edit collections > Rename'.
* Then enter the new name for the collection
<br><br><br>

### How to reorder games in a collection

To change the order:
* Go to 'Other settings > Edit collections > Customise game order'.
* Press 'X' on the game you would like to reorder and move it up or down, and press 'X' again once you are done.
* Once you finished customising the order, press the circle button.

Any new games added to a collection with custom sorting will be added at the end of the list. You can reset to alphabetical (Default) order using the triangle button.
<br>

---

## 🖼️ Artwork & Covers
<br>

### Missing artwork - How should I name my games so covers are found?
Name your ROMs using the **no-intro** file naming convention (e.g., "Game Name (USA)") for best artwork matching.

From version 7 onwards, RetroFlow uses CRC checksum identification when downloading artwork. However, not all systems support this, so no-intro filenames are still recommended. See [CRC identification](#crc-identification---which-systems-and-formats-are-supported) for more details.
<br><br><br>

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

**ScummVM:**
```
Game folder: Jimbobs Adventure
App ID: jbadv
Normal cover: jbadv.png
Custom cover: Jimbobs Adventure.png
```

**Image location:** Save custom covers in the appropriate subfolder:
`ux0:/data/RetroFlow/COVERS/[System Name]/`

Example: `ux0:/data/RetroFlow/COVERS/Nintendo - Game Boy Advance/`

⚠️ **Important:** Rescan your games after adding custom covers.
<br><br><br>

### How do I add custom icons to the game info screen?

To change the square icon on the game info screen, please see below for more info.

**Image requirements**

* PNG format
* Recommended size: 128px × 128px

**Naming rules**

* PlayStation systems (Vita, PSP, PS1, PSM):
Use the game’s Title ID, for example: `PCSE00001.png`

* Retro systems:
Use the ROM filename for example: `Super Mario World (USA).png`

* ScummVM:
Use the ScummVM game title for example: `bbvs.png`
If unsure, check the filenames used for covers.

**Image location:** Save custom covers in the appropriate subfolder:
`ux0:/data/RetroFlow/ICONS/[System Name]/`

**After adding icons**

Rescan your games if they do not appear immediately.
<br><br><br>

### Why is there no option to download homebrew covers?

Covers aren't needed for homebrew applications because the app icon is used instead.

If you move a homebrew game port into the Vita category, you can download a cover if available. You can also add custom covers manually.
<br><br><br>

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
<br>

---

## ⚙️ Configuration
<br>

### How do I add disc based games?

**PC Engine CD and TurboGrafx-CD:**
RetroFlow looks for '.cue' files. Ensure all games are in the system's game folder with .cue files.

**Dreamcast:**
'.gdi' and '.cdi' formats are supported.

**PS1 using RetroArch:**
Uses the 'PCSX ReARMed' core. See [supported extensions and setup](https://docs.libretro.com/library/pcsx_rearmed/).
<br><br><br>

### How do I add MS-DOS games?

MS-DOS games should be saved in .zip format.

Place the game zip files in your configured MS-DOS ROM folder and then rescan your games.

<br><br><br>

### PS1 and RetroArch, how do I set it up?

RetroArch PlayStation 1 games use the 'PCSX ReARMed' core. For supported extensions and setup instructions: [PCSX ReARMed Documentation](https://docs.libretro.com/library/pcsx_rearmed/)
<br><br><br>

### Can I change the Mega Drive name to Genesis?

Yes. Change your language to 'English - American' and the 'Mega Drive' name and logo will change to 'Genesis'.
<br><br><br>

### Vita game cartridge support?

From version 8.1.0 RetroFlow supports physical Vita game cartridges.

**Enable cartridge scanning**

1. Open Settings > Scan Settings
2. Turn on Scan Vita cartridges
3. Rescan your games

Cartridge games will display a cartridge icon near the clock indicating whether the cartridge is currently inserted.

If a cartridge is inserted while RetroFlow is running, RetroFlow will automatically jump to the game so it can be launched quickly.

**Note:** This feature can only be used if your Vita's cartridge slot is not already in use for homebrew.

<br>

---

## ℹ️ General Information
<br>

### What's the difference between RetroFlow and HexFlow custom?

HexFlow Custom is also a fork of HexFlow, which can be confusing. I've created a detailed comparison table:

[RetroFlow vs HexFlow Custom - Feature Comparison](https://github.com/jimbob4000/RetroFlow-Launcher/blob/main/docs/RetroFlow-vs-HexFlow-Custom-Feature-Comparison.md)
<br><br>



[< Back to main page](https://github.com/jimbob4000/RetroFlow-Launcher)
