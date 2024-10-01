
# RetroFlow Launcher

[![](https://github.com/jimbob4000/RetroFlow-Launcher/raw/main/Media/main_screen.png "main_screen")](https://github.com/jimbob4000/RetroFlow-Launcher/blob/main/Media/main_screen.png)

<!--- **Project archived:** RetroFlow is no longer in active development. --->

## About
This is a modded version of [HexFlow Launcher](https://github.com/VitaHEX-Games/HexFlow-Launcher); a 3d coverflow like launcher for PS Vita. 

With RetroFlow you can also integrate retro games without the need to create bubbles for Adrenaline, RetroArch, DaedalusX64 and Flycast.

**Supported systems:**
PS Vita, PSP, Playstation, Playstation Mobile, N64, SNES, NES, GBA, GBC, Game Boy, Sega Dreamcast, Sega CD, Sega 32X, Sega Mega Drive / Genesis, Sega Master System, Sega Game Gear, PC Engine, PC Engine CD, TurboGrafx-16, TurboGrafx-CD, Commodore Amiga, Commodore 64, WonderSwan, WonderSwan Color, MSX, MSX2, ZX Spectrum, Atari Lynx, Atari 600, Atari 5200, Atari 7800, ColecoVision, Vectrex, FBA 2012, MAME 2003 Plus, MAME 2000, Neo Geo (FBA 2012), Neo Geo Pocket Color, ScummVM and PICO-8.

**Main features added since forking from HexFlow:**

* No need to create bubbles for games
* Retro game categories added
* Create your own categories (Collections)
* Favourite games category 
* Recently played category
* Ability to search for games
* Ability to rename games
* Support for game backgrounds images
* Support for multiple music tracks
* Support for multiple wallpapers
* Load from cache for faster startup
* File browser added for setting up game directories
* Smooth scrolling of game covers
* Fully translated
* Two more views added, a 2D list view and also a 2D side scrolling view




# Installation & setup

**Note:** [Adrenaline v7](https://github.com/TheOfficialFloW/Adrenaline) is required if you intend to use RetroFlow for PSP and PS1 games. If you are on a lower / higher version of Adrenaline please install v7.

## 1. Install the RetroFlow VPK's.

* Install the [latest version of RetroFlow](https://github.com/jimbob4000/RetroFlow-Launcher/releases) 
* On the first run it will install some required files for Adrenaline if necessary.
* Adrenaline Bubble Booter will be installed automatically if you haven't got it already, you will be prompted to restart the vita if this is installed. 
* RetroFlow Adrenaline Launcher vpk will also be installed which is used for launching games with Adrenaline. You don't need to open this bubble, but keep it as RetroFlow uses it when launching games with Adrenaline.


## 2. Install any other necessary apps
* [DaedalusX64](https://github.com/Rinnegatamante/DaedalusX64-vitaGL/releases) is required for N64 games. 
* [RetroArch](https://www.retroarch.com/index.php?page=platforms) is required for other retro systems.  
* [Flycast](https://www.psx-place.com/threads/release-flycast-vita-v-1-0-3-sega-dreamcast-emulator-for-psvita-pstv.38180/) is required to play Dreamcast games. Also see the [compatibility list](https://newflycast.rinnegatamante.it/)  as not all games are playable yet.
* [FAKE-08](https://github.com/jtothebell/fake-08/releases) is required for PICO-8 games.
* [ScummVM](https://www.scummvm.org/downloads/) is required for ScummVM games.


**Important:** If Adrenaline games aren't launching after you have finished the setup, please install [Adrenaline Bubble Manager](https://github.com/ONElua/AdrenalineBubbleManager/releases). Or try installing [AdrBubbleBooterInstaller](https://vitadb.rinnegatamante.it/#/info/307).


## 3. Check your PS1 and PSP are in the right Adrenaline folders


* PS1 and PSP games with eboot files should be saved here: `ux0:pspemu/PSP/GAME/`
* PSP ISO and CSO games should be saved here: `ux0:pspemu/ISO/`
* uma0, ur0, imc0 and xmc0 partitions are also supported.
* The partition you use for Adrenaline will also need to be selected in the 'Scan settings' in RetroFlow.
* **Tip:** PS1 games can also be launched using RetroArch, helpful for games which don't run well in Adrenaline.

## 4. Add your retro games to RetroFlow

For best results it's recommended that your games are named using the **no-intro** file naming convention, e.g. "Game Name (USA)", these names are used to download matching cover images.

#### Option 1 - Use the default folders

* Launch RetroFlow for the first time, RetroFlow will create the folders where you can save your games.
* Once it's finished loading; close RetroFlow and copy or move your favourite retro games into the relevant game subfolders here: `ux0:/data/RetroFlow/ROMS/`

#### Option 2 - Use your own  game folders

* If you don't want to save your games in the RetroFlow data folder, you can use your own directories.
* Go to 'Scan settings' and then 'Edit game directories' to change the path to game folders.
* Once you are done, select 'Rescan' to find the games.

#### Disc based games

 * PC Engine CD and TurboGrafx-CD: RetroFlow will look for '.cue' files for these CD systems. Please make sure all the games are loose with the system's rom folder with .cue files.
 * Dreamcast:  '.gdi' and '.cdi' games are supported.
 * PS1 using RetroArch - They will use the 'PCSX ReARMed' core, more information on supported extensions here: [https://docs.libretro.com/library/pcsx_rearmed/](https://docs.libretro.com/library/pcsx_rearmed/)


## 5. Rescan to find your games

* Press 'Start' and go to 'Scan Settings', select your Adrenaline location, and if you are using custom game folders, select those too, then select 'Rescan'.
* Your retro games should now appear when you restart the app.
* 'Startup scan' can be turned off once you have finished adding your games, the app will startup faster when it's turned off.


## 6. Download covers & backgrounds

* To download cover images, press start, go to 'Artwork' then choose which covers or backgrounds you would like to download.
* From version 5 onwards you can also extract background images for PSP games from PSP iso files.
* If you add your own covers, rescan for them to be updated.

# FAQ's & Troubleshooting

Please see the [FAQ's](https://github.com/jimbob4000/RetroFlow-Launcher/blob/main/docs/FAQs.md) page for answers to common questions and issues.

# Controls

Navigate your library using the **DPad** or the **Left Stick** or with the **Touch Screen**.

**DPad Up**: Jump to the recently played / favourites category, or filter categories to only show collections. (DPad Right when viewing games in list view)

**R/L triggers**: Skip 5 items

**Cross**: Select/Launch game/app

**Square**: Change Category

**Triangle**: Game Details/Game options menu/About

**Circle**: Change View/Cancel

**Start**: Settings menu

**Select**: Search

**DPad Down + Square**: Go back one category

**DPad Down + L/R triggers**: Skip games alphabetically



# Customisation


## Adding Custom game covers & backgrounds

#### Covers:
* Custom covers can be saved in the game folders here: `ux0:/data/RetroFlow/COVERS/`.

#### Backgrounds:
* Custom game backgrounds can be saved in the game folders here: `ux0:/data/RetroFlow/BACKGROUNDS/`.

#### Filenames:
* For Vita, PSP, PSX, PSM games and Homebrew the cover image file name must match the **Game ID** or the **Game Name** of each app. 
* For retro games the cover image name should match the **Game Name** i.e. "Game Name (USA).png".
* See the [FAQ's](https://github.com/jimbob4000/RetroFlow-Launcher/blob/main/docs/FAQs.md#custom-covers---how-do-i-add-custom-covers) page for more information.
* **Don't forget** you need to **rescan your games** so the custom cover is found.

#### Image format:
* Cover and background images must be in **png** format. 


## Adding Custom wallpaper & music

#### Wallpaper:
* You can add as many wallpapers as you like by saving them here: `ux0:/data/RetroFlow/WALLPAPER/`. 
* Images must be in .jpg or .png format, the recommended size is 960px x 544px. 
* Some custom backgrounds are available [HERE](https://github.com/andiweli/hexflow-covers/tree/main/Backgrounds)
You can change your background within the app by going to the settings menu > theme > custom background.

#### Custom  Music:
* Songs can be added to `ux0:/data/RetroFlow/MUSIC/`. 
* Music must be in **.ogg** format.



## Known issues

* PSP background extraction: May need to be run more than once, after around 150 games it skips the rest. 


# Credits

* Original [HexFlow](https://github.com/VitaHEX-Games/HexFlow-Launcher) app by: VitaHex Games.
* Programming/UI: Sakis RG.
* Developed with [Lua Player Plus](http://rinnegatamante.github.io/lpp-vita/) by Rinnegatamante.
* Scanning PSP and PSX games, and CRC checks made possible by using [ONELua](http://onelua.x10.mx/) by Team ONElua.
* Extracting Vita backgrounds is an integrated version of [copyicons](https://github.com/cy33hc/copyicons) by cy33hc.
* Aurora wallpaper: Photo by [Maria Vojtovicova](https://unsplash.com/@maripopeo).
* Blur 2 and Blur 3 wallpaper by [Tech & ALL](https://techandall.com/10-blur-wallpapers-backgrounds-for-your-website/).

### Special thanks

* Creckeryop
* andiweli: [HEXFlow Covers database](https://github.com/andiweli/hexflow-covers)
* DRok17: for his work on bubble builders.
* Rinnegatamante: for tips and support with Lua.  
* Leecherman: for his work on AdrBubbleBooter and the [PSP ISO Renamer](https://sites.google.com/site/theleecherman/PSPISORenamer)
* BlackSheepBoy69: for sharing tips and code from [HexFlow Launcher Unofficial Custom](https://github.com/BlackSheepBoy69/HexFlow-Launcher-Unofficial-Custom)

#### Translations

* French - @chronoss and @Axce
* German - @stuermerandreas
* Hungarian - @dagadtwok
* Spanish - @kodyna91
* Italian - @TheheroGAC
* Russian - @\_novff
* Portuguese - @nighto
* Portuguese (Brazil) - @dariofflima
* Japanese - @kuragehimekurara1 and @iGlitch
* Chinese - @acd13141
* Polish - @SK00RUPA



# Support

**Help and FAQ's:**
For help and answers to frequent questions please visit the [FAQ's](https://github.com/jimbob4000/RetroFlow-Launcher/blob/main/docs/FAQs.md) page.

**Feature requests:** 
Please note that I'm not a developer, this mod started as a personal project, please be mindful that there may be some redundant code, or some requests that will be beyond my knowledge to implement.
Please feel free to build upon the mod as long as you provide credit to the original HexFlow developer and the people who contributed to the project.

**Supporting developers:** 
I don't accept donations or payment for this project, however if you would like to support VitaHex; the developer of the original HexFlow app you can support their work by becoming a [Patron](https://www.patreon.com/vitahex).

You can also donate to them using [PayPal](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=RM8ECMVYMTXGJ&source=url). If you would like to follow them, you can find VitaHex on [Twitter](https://twitter.com/VitaHex), or their website [vitahex.weebly.com](https://vitahex.weebly.com/).

**Disclaimer:**
<br>
RetroFlow DOES NOT support or facilitate piracy in any way, on the contrary we are against it.
 
RetroFlow and any individual software authors will not be held responsible for any damages or loss resulting from the use of the homebrew software, by downloading the application you are agreeing to these terms.