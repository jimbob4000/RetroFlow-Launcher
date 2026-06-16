# RetroFlow Tools

## How do I use the Recovery tools?

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


## RetroFlow Export Game List
<br>

**Information:**

* Supported systems: PlayStation Vita
* Format: VPK 
* Requirements: RetroFlow must be installed and setup on your Vita.
* Download link: [RetroFlow_Export_Game_List_v2.vpk](https://github.com/jimbob4000/RetroFlow-Launcher/raw/refs/heads/main/Tools/RetroFlow_Export_Game_List_v2.vpk)


**What does it do?**

* The VPK tool will read your RetroFlow cache and export a tidy tab-delimited list of all of your games.
* The exported list of games will be saved here:
`ux0:/data/RetroFlow/Exported game list.txt`
* The following fields will be exported: The name of the game, system, whether the game is set as a favourite or hidden, and also the file path of the game.
* The list can be opened in Microsoft Excel so you can read the list easily and also use filters.


**Use cases:**

* Duplicate PS1 games installed? <br>This tool will help you find where they are. PS1 games are often stored in folders using only the Title ID, making duplicate installations difficult to identify manually.
* Want to export your library? <br>This is a quick way to get a list of all the games you have in RetroFlow.


**VPK Changelog:**

Version 2

* Updated for RetroFlow version 8.1.1 - New systems: Atari ST, EasyRPG, MS-DOS, NDS.
* Added two additional fields: 'Name' and 'App Type', these fields could assist with creating custom collections (either manually, or automatically with AI, or with a desktop app if one is made).

Version 1

* Initial release
<br><br><br>

[< Back to main page](https://github.com/jimbob4000/RetroFlow-Launcher)