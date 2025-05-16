# FAQ's and Troubleshooting

<br>

**Topics:**

* [Error screen - The RetroFlow won't start anymore](#error-screen---the-retroflow-wont-start-anymore)
* [Can I set RetroFlow to launch when the Vita boots up?](#can-i-set-retroflow-to-launch-when-the-vita-boots-up)
* [Adrenaline - My games aren't working?](#adrenaline---my-games-arent-working)
* [Adrenaline opens then closes without loading the game?](#adrenaline-opens-then-closes-without-loading-the-game)
* [Adrenaline how do I customise the game's boot settings?](#adrenaline-how-do-i-customise-the-games-boot-settings)
* [RetroArch games don't load](#retroarch-games-dont-load)
* [Some system apps open but don't launch?](#some-system-apps-open-but-dont-launch)
* [RetroArch fails to load games with "&" symbol in the game name](#retroarch-fails-to-load-games-with--symbol-in-the-game-name)
* [PICO-8 games won't launch](#pico-8-games-wont-launch)
* [ScummVM some games won't launch](#scummvm-some-games-wont-launch)
* [Atari 5200 loads the memopad in RetroArch?](#atari-5200-loads-the-memopad-in-retroarch)
* [Missing artwork - How should I name my games so covers are found?](#missing-artwork---how-should-i-name-my-games-so-covers-are-found)
* [Custom covers - How do I add custom covers?](#custom-covers---how-do-i-add-custom-covers)
* [CRC identification - Which systems and formats are supported?](#crc-identification---which-systems-and-formats-are-supported)
* [Why is there no option to download homebrew covers?](#why-is-there-no-option-to-download-homebrew-covers)
* [How do I add disk based games?](#how-do-i-add-disk-based-games)
* [PS1 and RetroArch, how do I set it up?](#ps1-and-retroarch-how-do-i-set-it-up)
* [Some systems aren't showing?](#some-systems-arent-showing)
* [Can I change a core for RetroArch?](#can-i-change-a-core-for-retroarch)
* [Can I change the game folder locations?](#can-i-change-the-game-folder-locations)
* [Can I use HexFlow too?](#can-i-use-hexflow-too)
* [Do I need to create bubbles for games?](#do-i-need-to-create-bubbles-for-games)
* [Can I change the Mega Drive name to Genesis?](#can-i-change-the-mega-drive-name-to-genesis)
* [How do I uninstall Adrenaline Bubble Booter?](#how-do-i-uninstall-adrenaline-bubble-booter)
* [I have duplicate games showing](#i-have-duplicate-games-showing)
<br><br>

### Error screen - The RetroFlow won't start anymore
If you encounter a black error screen and the app won't load fully anymore, then you can try the following fixes.

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

### Can I set RetroFlow to launch when the Vita boots up?
If you want to auto-launch **RetroFlow Launcher** every time your PS Vita boots up you can use the [**AutoBoot**](https://www.rinnegatamante.eu/vitadb/#/info/261) plugin by Rinnegatamante. Please be careful using this app, use at your own risk. The title ID for RetroFlow is "RETROFLOW".
<br><br>

### Adrenaline - My games aren't working?
<!-- * If Adrenaline games aren't launching, please install [Adrenaline Bubble Manager](https://github.com/ONElua/AdrenalineBubbleManager/releases). <br>
Or try installing [AdrBubbleBooterInstaller](https://vitadb.rinnegatamante.it/#/info/307).-->
 * Check you are using the official version of Adrenaline [(6.61 Adrenaline-7)](https://github.com/TheOfficialFloW/Adrenaline/releases/tag/v7) by TheOfficialFloW.
<br>Forks of Adrenaline are not supported.
<br>
 * Check you have installed the 'RetroFlow Adrenaline Launcher' and that Adrenaline is functioning okay outside of RetroFlow.
<br><br>

### Adrenaline opens then closes without loading the game?
Behaviour: Adrenaline opens and then closes without loading the game (returning you to the livearea).

This is a known issue with Adrenaline, called the 'double launch bug'. This can be easily fixed by following the guide here: [https://github.com/TheOfficialFloW/Adrenaline#getting-rid-of-double-launch-bug](https://github.com/TheOfficialFloW/Adrenaline#getting-rid-of-double-launch-bug)
<br><br>

### Adrenaline how do I customise the game's boot settings?
If you need to change the boot settings for PSP games, this should be done in RetroFlow, go to the game press triangle twice then select 'Adrenaline options' customise your settings and then click save.

If you change the settings whilst the game is running, RetroFlow won't remember them, so it's best to do it in RetroFlow so they are saved for next time.
<br><br>

### RetroArch games don't load
Older versions of RetroArch don't support launchers, try updating to a more recent version, I think the version I use is 1.9.4, see the [RetroArch buildbot](https://buildbot.libretro.com/stable/) for alternate versions.
<br><br>

### Some system apps open but don't launch?
The launch commands for some system apps are unkown, this is the best we can do at the moment.
<br><br>

### RetroArch fails to load games with "&" symbol in the game name
This appears to be an issue with RetroArch version 1.11 onward, try installing an [older version](https://buildbot.libretro.com/stable/) of RetroArch until the issue is resolved.
<br><br>

### PICO-8 games won't launch
Support for launchers was added after July 5, 2021. Please try a more current version of [FAKE-08](https://github.com/jtothebell/fake-08/releases). 
<br><br>
### ScummVM some games won't launch
I found some games don't launch on ScummVM version 2.7.0, please try a previous version such as 2.6.1. Direct download link: [https://downloads.scummvm.org/frs/scummvm/2.6.1/scummvm-2.6.1-vita.vpk](https://downloads.scummvm.org/frs/scummvm/2.6.1/scummvm-2.6.1-vita.vpk).
<br><br>
### Atari 5200 loads the memopad in RetroArch?
When the game is running in RetroArch bring up the RetroArch quick menu.

Go to 'Options > Atari System' and selected 5200.
Then go back one level and select 'Overrides > Save core overrides'.

The games should work provided you have everything else setup.
<br><br>

### Missing artwork - How should I name my games so covers are found?
It's recommended that your roms are named using the **no-intro** file naming convention, e.g. "Game Name (USA)", these names are used to match with cover images.

From version 7 onwards when downloading artwork RetroFlow will check the game CRC checksum where possible to try and identify games. However; not all systems are supported, which is why no-intro filenames are still recommended. See [CRC identification - which systems and formats are supported?](#crc-identification---which-systems-and-formats-are-supported) for a more information.<br><br>

### Custom covers - How do I add custom covers?

Custom covers are used to override the default covers, the name should match the game name that you see within RetroFlow.

Retro game example:

	Game name = My Game (USA).gba
	Normal cover name = My Game (USA).png
	Custom cover name = My Game.png
	
Vita, PSP, PSX, PSM and Vita Homebrew example:

	App ID = PCSE123456
	Normal cover name = PCSE123456.png
	Custom cover name = My Game.png

PSP Homebrew - iso format (saved in ux0:pspemu/ISO/):

	App ID = PCSE123456
	Normal cover name = PCSE123456.png
	Custom cover name = My Game.png

PSP Homebrew - eboot format (saved in ux0:pspemu/PSP/GAME/):

	Homebrew folder name = Flappy Bird
	Cover name = Flappy Bird.png
	

<br>
Make sure your custom cover is saved in the cover directory and in the correct subfolder i.e. <br>
`ux0:/data/RetroFlow/COVERS/Nintendo - Game Boy Advance`

**Don't forget** you need to **rescan your games** so the custom cover is found.
<br><br>


### CRC identification - Which systems and formats are supported?

**Archive support and CRC:**<br>
Zip and rar archives are support but **7z is not supported**.

Whilst CRC checks can be performed on zip and rar files, the app will need to extract them to read the file inside. If you encounter issues or crashes due to memory, then extract the files on a PC and rescan.

**CRC support available for:**<br>
Nintendo 64, Super Nintendo, Nintendo Entertainment System, Game Boy Advance, Game Boy Color, Game Boy, Sega 32X, Sega Mega Drive / Genesis, Sega Master System, Sega Game Gear, PC Engine, TurboGrafx-16, WonderSwan, WonderSwan Color, MSX, MSX2, Atari Lynx, Atari 600, Atari 5200, Atari 7800, ColecoVision, Vectrex, Neo Geo Pocket Color.

**CRC is not unavailable for:<br>**
Sega Dreamcast, Sega CD, PC Engine CD, TurboGrafx-CD, Commodore Amiga, Commodore 64, ZX Spectrum.

**Systems which don't need CRC: <br>**
PS Vita, PSP, Playstation, Playstation Mobile, FBA 2012, MAME 2003 Plus, MAME 2000, Neo Geo (FBA 2012), ScummVM and PICO-8. Other methods are used to identify the games.<br><br>


### Why is there no option to download homebrew covers?
Covers haven't been made for homebrew applications as it's not necessary as the app icon is used. 

If you move a homebrew game port into the Vita category you can download a cover if it's available. Vita style covers for homebrew applications won't be added, but you can always add your own.
<br><br>

### How do I add disk based games?
 * PC Engine CD and TurboGrafx-CD - RetroFlow will look for '.cue' files for these CD systems. Please make sure all the games are loose with the system's game folder with .cue files.
 * Dreamcast - '.gdi' and '.cdi' games are supported.
 * PS1 using RetroArch - They will use the 'PCSX ReARMed' core, more information on supported extensions here: [https://docs.libretro.com/library/pcsx_rearmed/](https://docs.libretro.com/library/pcsx_rearmed/)
<br><br>

### PS1 and RetroArch, how do I set it up?
RetroArch Playstation 1 games use the 'PCSX ReARMed' core, more information on supported extensions and setup see here: [https://docs.libretro.com/library/pcsx_rearmed/](https://docs.libretro.com/library/pcsx_rearmed/)
<br><br>



### Some systems aren't showing?
Empty collections are hidden by default, once you add some games into the game's folder, they will appear.
<br><br>

### Can I change a core for RetroArch?
The cores have been set by system and cannot be changed on a game-by-game basis.

To change the core for an entire system, search for "Retroarch Cores" in the file below and edit the core file names accordingly. `ux0:/app/RETROFLOW/index.lua`

The RetroArch core files can be found here: `ux0:/app/RETROVITA/`
<br><br>

### Can I change the rom folder locations?
Yes, from version 4.0 onwards.
Go to 'Scan settings' and then 'Edit game directories' to change the path to rom folders.
<br><br>

### Can I use HexFlow too?
Yes; RetroFlow is separate, it uses different folders and a different title ID.
<br><br>

### Do I need to create bubbles for games?
No; RetroFlow doesn't need bubbles for games.
<br><br>

### Can I change the Mega Drive name to Genesis?
Sure; changing your language to 'English - American' will change the 'Mega Drive' name and logo to 'Genesis'.
<br><br>

### How do I uninstall Adrenaline Bubble Booter?
If you followed the install guide you should be on Adrenaline version 7.

**For Adrenaline v7:**

 * Please copy the 'sce_module' folder from here: `ux0:app/RETROFLOW/payloads/adrenaline/sce_module`
 * Then paste it into the adrenaline directory: `ux0:app/PSPEMUCFW` overwriting the old 'sce_module' folder. If you want a backup, then rename the folder before pasting so it's not overwritten.
 * Restart the vita for the changes to take effect.


**For other versions of Adrenaline:**

 * Please uninstall Adrenaline and install again.

**Note:** Uninstalling Adrenaline Bubble Booter will stop any custom PS1 or PSP bubbles you created using Adrenaline Bubble manager from working unless it is installed once again, Adrenaline Bubble manager can install it again for you if needed.
<br><br>

### I have duplicate games showing
Check that you don't have more than one version of the game installed.
<br>This tool can help: [RetroFlow Export Game List](https://github.com/jimbob4000/RetroFlow-Launcher/blob/main/docs/Tools.md#retroflow-export-game-list).

<br><br>

[< Back to main page](https://github.com/jimbob4000/RetroFlow-Launcher)
