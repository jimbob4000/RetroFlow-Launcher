-- RetroFlow Launcher - HexFlow Mod version by jimbob4000
-- Based on HexFlow Launcher  version 0.5 by VitaHEX
-- https://www.patreon.com/vitahex

local oneLoopTimer = Timer.new()

dofile("app0:addons/threads.lua")
local working_dir = "ux0:/app"
local appversion = "7.3.0"
function System.currentDirectory(dir)
    if dir == nil then
        return working_dir
    else
        working_dir = dir
    end
end

loading_tasks = 0
loading_progress = 0

loadingImage = Graphics.loadImage("app0:DATA/loading.png")

romsMainDir = "ux0:/data/RetroFlow/ROMS/"
covDir = "ux0:/data/RetroFlow/COVERS/"
snapDir = "ux0:/data/RetroFlow/BACKGROUNDS/"
iconDir = "ux0:/data/RetroFlow/ICONS/"

-- Tidy up legacy COVER folder structure to a more standard naming convention
if System.doesDirExist("ux0:/data/RetroFlow/COVERS/MAME") then System.rename("ux0:/data/RetroFlow/COVERS/MAME", "ux0:/data/RetroFlow/COVERS/MAME 2000") end
if System.doesDirExist("ux0:/data/RetroFlow/ROMS/MAME 2000") then System.rename("ux0:/data/RetroFlow/ROMS/MAME 2000", "ux0:/data/RetroFlow/ROMS/MAME 2000") end

-- Default system rom folders
romDir_Default =
{
["Atari_2600"] = "ux0:/data/RetroFlow/ROMS/Atari - 2600",
["Atari_5200"] = "ux0:/data/RetroFlow/ROMS/Atari - 5200",
["Atari_7800"] = "ux0:/data/RetroFlow/ROMS/Atari - 7800",
["Atari_Lynx"] = "ux0:/data/RetroFlow/ROMS/Atari - Lynx",
["WonderSwan"] = "ux0:/data/RetroFlow/ROMS/Bandai - WonderSwan",
["WonderSwan_Color"] = "ux0:/data/RetroFlow/ROMS/Bandai - WonderSwan Color",
["ColecoVision"] = "ux0:/data/RetroFlow/ROMS/Coleco - ColecoVision",
["Commodore_64"] = "ux0:/data/RetroFlow/ROMS/Commodore - 64",
["Amiga"] = "ux0:/data/RetroFlow/ROMS/Commodore - Amiga",
["FBA_2012"] = "ux0:/data/RetroFlow/ROMS/FBA 2012",
["Vectrex"] = "ux0:/data/RetroFlow/ROMS/GCE - Vectrex",
["MAME_2000"] = "ux0:/data/RetroFlow/ROMS/MAME 2000",
["MAME_2003Plus"] = "ux0:/data/RetroFlow/ROMS/MAME 2003 Plus",
["MSX"] = "ux0:/data/RetroFlow/ROMS/Microsoft - MSX",
["MSX2"] = "ux0:/data/RetroFlow/ROMS/Microsoft - MSX2",
["PC_Engine"] = "ux0:/data/RetroFlow/ROMS/NEC - PC Engine",
["PC_Engine_CD"] = "ux0:/data/RetroFlow/ROMS/NEC - PC Engine CD",
["TurboGrafx_16"] = "ux0:/data/RetroFlow/ROMS/NEC - TurboGrafx 16",
["TurboGrafx_CD"] = "ux0:/data/RetroFlow/ROMS/NEC - TurboGrafx CD",
["Game_Boy"] = "ux0:/data/RetroFlow/ROMS/Nintendo - Game Boy",
["Game_Boy_Advance"] = "ux0:/data/RetroFlow/ROMS/Nintendo - Game Boy Advance",
["Game_Boy_Color"] = "ux0:/data/RetroFlow/ROMS/Nintendo - Game Boy Color",
["Nintendo_64"] = "ux0:/data/RetroFlow/ROMS/Nintendo - Nintendo 64",
["Nintendo_Entertainment_System"] = "ux0:/data/RetroFlow/ROMS/Nintendo - Nintendo Entertainment System",
["Super_Nintendo"] = "ux0:/data/RetroFlow/ROMS/Nintendo - Super Nintendo Entertainment System",
["Sega_32X"] = "ux0:/data/RetroFlow/ROMS/Sega - 32X",
["Sega_Dreamcast"] = "ux0:/data/RetroFlow/ROMS/Sega - Dreamcast",
["Sega_Game_Gear"] = "ux0:/data/RetroFlow/ROMS/Sega - Game Gear",
["Sega_Master_System"] = "ux0:/data/RetroFlow/ROMS/Sega - Master System - Mark III",
["Sega_Mega_Drive"] = "ux0:/data/RetroFlow/ROMS/Sega - Mega Drive - Genesis",
["Sega_CD"] = "ux0:/data/RetroFlow/ROMS/Sega - Mega-CD - Sega CD",
["ZX_Spectrum"] = "ux0:/data/RetroFlow/ROMS/Sinclair - ZX Spectrum",
["Neo_Geo"] = "ux0:/data/RetroFlow/ROMS/SNK - Neo Geo - FBA 2012",
["Neo_Geo_Pocket_Color"] = "ux0:/data/RetroFlow/ROMS/SNK - Neo Geo Pocket Color",
["PlayStation"] = "ux0:/data/RetroFlow/ROMS/Sony - PlayStation - RetroArch",
["ScummVM"] = "ux0:/data/RetroFlow/ROMS/ScummVM",
["Pico8"] = "ux0:/data/RetroFlow/ROMS/Lexaloffle Games - Pico-8",

}

adr_partition_table =
{
[1] = "ux0",
[2] = "ur0",
[3] = "imc0",
[4] = "xmc0",
[5] = "uma0",
}

-- Create directory: Main
local cur_dir = "ux0:/data/RetroFlow/"
System.createDirectory("ux0:/data/RetroFlow/")

function print_table_rom_dirs(def_table_name)
    dofile("app0:addons/printTable.lua")
    print_table_rom_dirs((def_table_name))
end

-- Create directory: Roms
System.createDirectory(romsMainDir)

-- Create directory: Icons
System.createDirectory(iconDir)
System.createDirectory(iconDir .. "Sony - PlayStation Vita/")

-- Create default rom sub folders
for k, v in pairs(romDir_Default) do
    System.createDirectory(tostring(v))
end

-- Error handling for importing cached lua files to tables
function importLuaFile(filename, tableToAssign)
    local importLuaFileError = false  -- Initialize error flag to false

    local chunk, err = loadfile(filename)
    if not chunk then
        -- print("Error loading/compiling Lua file:", err)
        importLuaFileError = true  -- Set error flag to true
        return importLuaFileError  -- Return error flag
    end

    local success, result = pcall(chunk)
    if not success then
        -- print("Error executing Lua file:", result)
        importLuaFileError = true  -- Set error flag to true
        return importLuaFileError  -- Return error flag
    end
    
    -- If a tableToAssign parameter is provided, assign the result to it
    if tableToAssign then
        for k, v in pairs(result) do
            tableToAssign[k] = v
        end
    end
    
    return importLuaFileError  -- Return error flag
end

-- Save a copy of the default locations to an lua file so it can be customised later
if not System.doesFileExist("ux0:/data/RetroFlow/rom_directories.lua") then
    print_table_rom_dirs(romDir_Default)
end

if System.doesFileExist("ux0:/data/RetroFlow/rom_directories.lua") then
    -- File exists, import user rom dirs
    db_romdir = "ux0:/data/RetroFlow/rom_directories.lua"
    romUserDir = {}
    romUserDir = dofile(db_romdir)

    -- File not empty
    if romUserDir ~= nil then 
        -- Legacy fixes for new systems that have been added
        if romUserDir.PlayStation == nil then
            romUserDir.PlayStation = "ux0:/data/RetroFlow/ROMS/Sony - PlayStation - RetroArch"
        end

        if romUserDir.Nintendo_DS == nil then
            -- Set to DSVita folder rather than RetroFlow folder as DSVita doesn't support custom directories yet.
            romUserDir.Nintendo_DS = "ux0:/data/dsvita"
        end

        if romUserDir.Pico8 == nil then
            romUserDir.Pico8 = "ux0:/data/RetroFlow/ROMS/Lexaloffle Games - Pico-8"
        end

    -- File empty, use defaults
    else
        romUserDir = {}
        romUserDir = romDir_Default
    end

else
    -- File not found, use default rom dirs
    romUserDir = {}
    romUserDir = romDir_Default
end



SystemsToScan =
{
    [1] = 
    {
        ["apptype"] = 1,
        ["table"] = "games_table",
        ["user_db_file"] = "db_games.lua",
        -- ["romFolder"] = "",
        ["localCoverPath"] = covDir .. "Sony - PlayStation Vita" .. "/",
        ["localSnapPath"] = snapDir .. "Sony - PlayStation Vita" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PSVita/",
        ["onlineSnapPathSystem"] = "",
        ["Missing_Cover"] = "missing_cover_psv.png",
    },
    [2] = 
    {
        ["apptype"] = 0,
        ["table"] = "homebrews_table",
        ["user_db_file"] = "db_homebrews.lua",
        -- ["romFolder"] = "",
        ["localCoverPath"] = covDir .. "Homebrew" .. "/",
        ["localSnapPath"] = snapDir .. "Homebrew" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/HOMEBREW/",
        ["onlineSnapPathSystem"] = "",
        ["Missing_Cover"] = "missing_cover_homebrew.png",
    },
    [3] = 
    {
        ["apptype"] = 2,
        ["table"] = "psp_table",
        ["user_db_file"] = "db_psp.lua",
        -- ["romFolder"] = "",
        ["localCoverPath"] = covDir .. "Sony - PlayStation Portable" .. "/",
        ["localSnapPath"] = snapDir .. "Sony - PlayStation Portable" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PSP/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/PSP/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_psp.png",
    },
    [4] = 
    {
        ["apptype"] = 3,
        ["table"] = "psx_table",
        ["user_db_file"] = "db_psx.lua",
        ["romFolder"] = romUserDir.PlayStation,
        ["localCoverPath"] = covDir .. "Sony - PlayStation" .. "/",
        ["localSnapPath"] = snapDir .. "Sony - PlayStation" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PS1/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/PS1/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_psx.png",
    },
    [5] = 
    {
        ["apptype"] = 5,
        ["table"] = "n64_table",
        ["user_db_file"] = "db_n64.lua",
        ["romFolder"] = romUserDir.Nintendo_64,
        ["localCoverPath"] = covDir .. "Nintendo - Nintendo 64" .. "/",
        ["localSnapPath"] = snapDir .. "Nintendo - Nintendo 64" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/N64/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Nintendo_64/ec7430189022b591a8fb0fa16101201f861363f8/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_n64.png",
    },
    [6] = 
    {
        ["apptype"] = 6,
        ["table"] = "snes_table",
        ["user_db_file"] = "db_snes.lua",
        ["romFolder"] = romUserDir.Super_Nintendo,
        ["localCoverPath"] = covDir .. "Nintendo - Super Nintendo Entertainment System" .. "/",
        ["localSnapPath"] = snapDir .. "Nintendo - Super Nintendo Entertainment System" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/SNES/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Super_Nintendo_Entertainment_System/5c469e48755fec26b4b9d651b6962a2cdea3133d/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_snes.png",
    },
    [7] = 
    {
        ["apptype"] = 7,
        ["table"] = "nes_table",
        ["user_db_file"] = "db_nes.lua",
        ["romFolder"] = romUserDir.Nintendo_Entertainment_System,
        ["localCoverPath"] = covDir .. "Nintendo - Nintendo Entertainment System" .. "/",
        ["localSnapPath"] = snapDir .. "Nintendo - Nintendo Entertainment System" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/NES/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Nintendo_Entertainment_System/f4415b21a256bcbe7b30a9d71a571d6ba4815c71/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_nes.png",
    },
    [8] = 
    {
        ["apptype"] = 8,
        ["table"] = "gba_table",
        ["user_db_file"] = "db_gba.lua",
        ["romFolder"] = romUserDir.Game_Boy_Advance,
        ["localCoverPath"] = covDir .. "Nintendo - Game Boy Advance" .. "/",
        ["localSnapPath"] = snapDir .. "Nintendo - Game Boy Advance" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/GBA/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Game_Boy_Advance/fd58a8fae1cec5857393c0405c3d0514c7fdf6cf/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_gba.png",
    },
    [9] = 
    {
        ["apptype"] = 9,
        ["table"] = "gbc_table",
        ["user_db_file"] = "db_gbc.lua",
        ["romFolder"] = romUserDir.Game_Boy_Color,
        ["localCoverPath"] = covDir .. "Nintendo - Game Boy Color" .. "/",
        ["localSnapPath"] = snapDir .. "Nintendo - Game Boy Color" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/GBC/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Game_Boy_Color/a0cc546d2b4e2eebefdcf91b90ae3601c377c3ce/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_gbc.png",
    },
    [10] = 
    {
        ["apptype"] = 10,
        ["table"] = "gb_table",
        ["user_db_file"] = "db_gb.lua",
        ["romFolder"] = romUserDir.Game_Boy,
        ["localCoverPath"] = covDir .. "Nintendo - Game Boy" .. "/",
        ["localSnapPath"] = snapDir .. "Nintendo - Game Boy" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/GB/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Game_Boy/d5ad94ba8c5159381d7f618ec987e609d23ae203/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_gb.png",
    },
    [11] = 
    {
        ["apptype"] = 11,
        ["table"] = "dreamcast_table",
        ["user_db_file"] = "db_dreamcast.lua",
        ["romFolder"] = romUserDir.Sega_Dreamcast,
        ["localCoverPath"] = covDir .. "Sega - Dreamcast" .. "/",
        ["localSnapPath"] = snapDir .. "Sega - Dreamcast" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/DC/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/DC/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_dreamcast_eur.png",
    },
    [12] = 
    {
        ["apptype"] = 12,
        ["table"] = "sega_cd_table",
        ["user_db_file"] = "db_sega_cd.lua",
        ["romFolder"] = romUserDir.Sega_CD,
        ["localCoverPath"] = covDir .. "Sega - Mega-CD - Sega CD" .. "/",
        ["localSnapPath"] = snapDir .. "Sega - Mega-CD - Sega CD" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/SEGA_CD/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Sega_-_Mega-CD_-_Sega_CD/a8737a2a394645f27415f7346ac2ceb0cfcd0942/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_sega_cd.png",
    },
    [13] = 
    {
        ["apptype"] = 13,
        ["table"] = "s32x_table",
        ["user_db_file"] = "db_32x.lua",
        ["romFolder"] = romUserDir.Sega_32X,
        ["localCoverPath"] = covDir .. "Sega - 32X" .. "/",
        ["localSnapPath"] = snapDir .. "Sega - 32X" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/32X/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Sega_-_32X/4deb45e651e29506a7bfc440408b3343f0e1a3ae/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_32x.png",
    },
    [14] = 
    {
        ["apptype"] = 14,
        ["table"] = "md_table",
        ["user_db_file"] = "db_md.lua",
        ["romFolder"] = romUserDir.Sega_Mega_Drive,
        ["localCoverPath"] = covDir .. "Sega - Mega Drive - Genesis" .. "/",
        ["localSnapPath"] = snapDir .. "Sega - Mega Drive - Genesis" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MD/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Sega_-_Mega_Drive_-_Genesis/6ac232741f979a6f0aa54d077ff392fe170f4725/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_md.png",
    },
    [15] = 
    {
        ["apptype"] = 15,
        ["table"] = "sms_table",
        ["user_db_file"] = "db_sms.lua",
        ["romFolder"] = romUserDir.Sega_Master_System,
        ["localCoverPath"] = covDir .. "Sega - Master System - Mark III" .. "/",
        ["localSnapPath"] = snapDir .. "Sega - Master System - Mark III" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/SMS/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Sega_-_Master_System_-_Mark_III/02f8c7f989db6124475b7e0978c27af8534655eb/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_sms.png",
    },
    [16] = 
    {
        ["apptype"] = 16,
        ["table"] = "gg_table",
        ["user_db_file"] = "db_gg.lua",
        ["romFolder"] = romUserDir.Sega_Game_Gear,
        ["localCoverPath"] = covDir .. "Sega - Game Gear" .. "/",
        ["localSnapPath"] = snapDir .. "Sega - Game Gear" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/GG/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Sega_-_Game_Gear/b99b424d2adcf5ccd45c372db2c15f01653f2b92/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_gg.png",
    },
    [17] = 
    {
        ["apptype"] = 17,
        ["table"] = "tg16_table",
        ["user_db_file"] = "db_tg16.lua",
        ["romFolder"] = romUserDir.TurboGrafx_16,
        ["localCoverPath"] = covDir .. "NEC - TurboGrafx 16" .. "/",
        ["localSnapPath"] = snapDir .. "NEC - TurboGrafx 16" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/TG16/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/NEC_-_PC_Engine_-_TurboGrafx_16/d0d6e27f84d757416799e432154e0adcadb154c9/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_tg16.png",
    },
    [18] = 
    {
        ["apptype"] = 18,
        ["table"] = "tgcd_table",
        ["user_db_file"] = "db_tgcd.lua",
        ["romFolder"] = romUserDir.TurboGrafx_CD,
        ["localCoverPath"] = covDir .. "NEC - TurboGrafx CD" .. "/",
        ["localSnapPath"] = snapDir .. "NEC - TurboGrafx CD" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/TG_CD/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/NEC_-_PC_Engine_CD_-_TurboGrafx-CD/cd554a5cdca862f090e6c3f9510a3b1b6c2d5b38/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_tgcd.png",
    },
    [19] = 
    {
        ["apptype"] = 19,
        ["table"] = "pce_table",
        ["user_db_file"] = "db_pce.lua",
        ["romFolder"] = romUserDir.PC_Engine,
        ["localCoverPath"] = covDir .. "NEC - PC Engine" .. "/",
        ["localSnapPath"] = snapDir .. "NEC - PC Engine" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/PCE/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/NEC_-_PC_Engine_-_TurboGrafx_16/d0d6e27f84d757416799e432154e0adcadb154c9/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_pce.png",
    },
    [20] = 
    {
        ["apptype"] = 20,
        ["table"] = "pcecd_table",
        ["user_db_file"] = "db_pcecd.lua",
        ["romFolder"] = romUserDir.PC_Engine_CD,
        ["localCoverPath"] = covDir .. "NEC - PC Engine CD" .. "/",
        ["localSnapPath"] = snapDir .. "NEC - PC Engine CD" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/PCE_CD/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/NEC_-_PC_Engine_CD_-_TurboGrafx-CD/cd554a5cdca862f090e6c3f9510a3b1b6c2d5b38/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_pcecd.png",
    },
    [21] = 
    {
        ["apptype"] = 21,
        ["table"] = "amiga_table",
        ["user_db_file"] = "db_amiga.lua",
        ["romFolder"] = romUserDir.Amiga,
        ["localCoverPath"] = covDir .. "Commodore - Amiga" .. "/",
        ["localSnapPath"] = snapDir .. "Commodore - Amiga" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/AMIGA/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Commodore_-_Amiga/b6446e83b3dc93446371a5dbfb0f24574eb56461/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_amiga.png",
    },
    [22] = 
    {
        ["apptype"] = 22,
        ["table"] = "c64_table",
        ["user_db_file"] = "db_c64.lua",
        ["romFolder"] = romUserDir.Commodore_64,
        ["localCoverPath"] = covDir .. "Commodore - 64" .. "/",
        ["localSnapPath"] = snapDir .. "Commodore - 64" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/C64/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Commodore_-_64/df90042ef9823d1b0b9d3ec303051f555dca2246/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_c64.png",
    },
    [23] = 
    {
        ["apptype"] = 23,
        ["table"] = "wswan_col_table",
        ["user_db_file"] = "db_wswan_col.lua",
        ["romFolder"] = romUserDir.WonderSwan_Color,
        ["localCoverPath"] = covDir .. "Bandai - WonderSwan Color" .. "/",
        ["localSnapPath"] = snapDir .. "Bandai - WonderSwan Color" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/WSWAN_COL/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Bandai_-_WonderSwan_Color/5b57a78fafa4acb8590444c15c116998fcea9dce/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_wswan_col.png",
    },
    [24] = 
    {
        ["apptype"] = 24,
        ["table"] = "wswan_table",
        ["user_db_file"] = "db_wswan.lua",
        ["romFolder"] = romUserDir.WonderSwan,
        ["localCoverPath"] = covDir .. "Bandai - WonderSwan" .. "/",
        ["localSnapPath"] = snapDir .. "Bandai - WonderSwan" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/WSWAN/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Bandai_-_WonderSwan/3913706e173ec5f8c0cdeebd225b16f4dc3dd6c6/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_wswan.png",
    },
    [25] = 
    {
        ["apptype"] = 25,
        ["table"] = "msx2_table",
        ["user_db_file"] = "db_msx2.lua",
        ["romFolder"] = romUserDir.MSX2,
        ["localCoverPath"] = covDir .. "Microsoft - MSX2" .. "/",
        ["localSnapPath"] = snapDir .. "Microsoft - MSX2" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MSX2/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Microsoft_-_MSX2/12d7e10728cc4c3314b8b14b5a9b1892a886d2ab/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_msx2.png",
    },
    [26] = 
    {
        ["apptype"] = 26,
        ["table"] = "msx1_table",
        ["user_db_file"] = "db_msx1.lua",
        ["romFolder"] = romUserDir.MSX,
        ["localCoverPath"] = covDir .. "Microsoft - MSX" .. "/",
        ["localSnapPath"] = snapDir .. "Microsoft - MSX" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MSX/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Microsoft_-_MSX/ed54675a51597fd5bf66a45318a273f330b7662f/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_msx1.png",
    },
    [27] = 
    {
        ["apptype"] = 27,
        ["table"] = "zxs_table",
        ["user_db_file"] = "db_zxs.lua",
        ["romFolder"] = romUserDir.ZX_Spectrum,
        ["localCoverPath"] = covDir .. "Sinclair - ZX Spectrum" .. "/",
        ["localSnapPath"] = snapDir .. "Sinclair - ZX Spectrum" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/ZXS/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Sinclair_-_ZX_Spectrum/d23c953dc9853983fb2fce2b8e96a1ccc08b70e8/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_zxs.png",
    },
    [28] = 
    {
        ["apptype"] = 28,
        ["table"] = "atari_7800_table",
        ["user_db_file"] = "db_atari_7800.lua",
        ["romFolder"] = romUserDir.Atari_7800,
        ["localCoverPath"] = covDir .. "Atari - 7800" .. "/",
        ["localSnapPath"] = snapDir .. "Atari - 7800" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/ATARI_7800/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Atari_-_7800/eff4d49a71a62764dd66d414b1bf7a843f85f7ae/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_atari_7800.png",
    },
    [29] = 
    {
        ["apptype"] = 29,
        ["table"] = "atari_5200_table",
        ["user_db_file"] = "db_atari_5200.lua",
        ["romFolder"] = romUserDir.Atari_5200,
        ["localCoverPath"] = covDir .. "Atari - 5200" .. "/",
        ["localSnapPath"] = snapDir .. "Atari - 5200" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/ATARI_5200/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Atari_-_5200/793489381646954046dd1767a1af0fa4f6b86c24/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_atari_5200.png",
    },
    [30] = 
    {
        ["apptype"] = 30,
        ["table"] = "atari_2600_table",
        ["user_db_file"] = "db_atari_2600.lua",
        ["romFolder"] = romUserDir.Atari_2600,
        ["localCoverPath"] = covDir .. "Atari - 2600" .. "/",
        ["localSnapPath"] = snapDir .. "Atari - 2600" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/ATARI_2600/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Atari_-_2600/ea2ba38f9bace8e85539d12e2f65e31c797c6585/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_atari_2600.png",
    },
    [31] = 
    {
        ["apptype"] = 31,
        ["table"] = "atari_lynx_table",
        ["user_db_file"] = "db_atari_lynx.lua",
        ["romFolder"] = romUserDir.Atari_Lynx,
        ["localCoverPath"] = covDir .. "Atari - Lynx" .. "/",
        ["localSnapPath"] = snapDir .. "Atari - Lynx" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/ATARI_LYNX/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Atari_-_Lynx/91278444136e9c19f89331421ffe84cce6f82fb9/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_atari_lynx.png",
    },
    [32] = 
    {
        ["apptype"] = 32,
        ["table"] = "colecovision_table",
        ["user_db_file"] = "db_colecovision.lua",
        ["romFolder"] = romUserDir.ColecoVision,
        ["localCoverPath"] = covDir .. "Coleco - ColecoVision" .. "/",
        ["localSnapPath"] = snapDir .. "Coleco - ColecoVision" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/COLECOVISION/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Coleco_-_ColecoVision/332c63436431ea5fceedf50b94447bb6e7a8e1f5/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_colecovision.png",
    },
    [33] = 
    {
        ["apptype"] = 33,
        ["table"] = "vectrex_table",
        ["user_db_file"] = "db_vectrex.lua",
        ["romFolder"] = romUserDir.Vectrex,
        ["localCoverPath"] = covDir .. "GCE - Vectrex" .. "/",
        ["localSnapPath"] = snapDir .. "GCE - Vectrex" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/VECTREX/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/GCE_-_Vectrex/ed03e5d1214399d2f4429109874b2ad3d8a18709/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_vectrex.png",
    },
    [34] = 
    {
        ["apptype"] = 34,
        ["table"] = "fba_table",
        ["user_db_file"] = "db_fba.lua",
        ["romFolder"] = romUserDir.FBA_2012,
        ["localCoverPath"] = covDir .. "FBA 2012" .. "/",
        ["localSnapPath"] = snapDir .. "FBA 2012" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MAME/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MAME/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_fba.png",
    },
    [35] = 
    {
        ["apptype"] = 35,
        ["table"] = "mame_2003_plus_table",
        ["user_db_file"] = "db_mame_2003_plus.lua",
        ["romFolder"] = romUserDir.MAME_2003Plus,
        ["localCoverPath"] = covDir .. "MAME 2003 Plus" .. "/",
        ["localSnapPath"] = snapDir .. "MAME 2003 Plus" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MAME/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MAME/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_mame.png",
    },
    [36] = 
    {
        ["apptype"] = 36,
        ["table"] = "mame_2000_table",
        ["user_db_file"] = "db_mame_2000.lua",
        ["romFolder"] = romUserDir.MAME_2000,
        ["localCoverPath"] = covDir .. "MAME 2000" .. "/",
        ["localSnapPath"] = snapDir .. "MAME 2000" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MAME/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MAME/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_mame.png",
    },
    [37] = 
    {
        ["apptype"] = 37,
        ["table"] = "neogeo_table",
        ["user_db_file"] = "db_neogeo.lua",
        ["romFolder"] = romUserDir.Neo_Geo,
        ["localCoverPath"] = covDir .. "SNK - Neo Geo - FBA 2012" .. "/",
        ["localSnapPath"] = snapDir .. "SNK - Neo Geo - FBA 2012" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/NEOGEO/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/NEOGEO/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_neogeo.png",
    },
    [38] = 
    {
        ["apptype"] = 38,
        ["table"] = "ngpc_table",
        ["user_db_file"] = "db_ngpc.lua",
        ["romFolder"] = romUserDir.Neo_Geo_Pocket_Color,
        ["localCoverPath"] = covDir .. "SNK - Neo Geo Pocket Color" .. "/",
        ["localSnapPath"] = snapDir .. "SNK - Neo Geo Pocket Color" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/NEOGEO_PC/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/SNK_-_Neo_Geo_Pocket_Color/f940bd5da36105397897c093dda77ef06d51cbcf/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_ngpc.png",
    },
    [39] = 
    {
        ["apptype"] = 39,
        ["table"] = "psm_table",
        ["user_db_file"] = "db_psm.lua",
        -- ["romFolder"] = "",
        ["localCoverPath"] = covDir .. "Sony - PlayStation Mobile" .. "/",
        ["localSnapPath"] = snapDir .. "Sony - PlayStation Mobile" .. "/",
        ["onlineCoverPathSystem"] = "",
        ["onlineSnapPathSystem"] = "",
        ["Missing_Cover"] = "missing_cover_psm.png",
    },
    [40] = 
    {
        ["apptype"] = 40,
        ["table"] = "scummvm_table",
        ["user_db_file"] = "db_scummvm.lua",
        -- ["romFolder"] = "",
        ["localCoverPath"] = covDir .. "ScummVM" .. "/",
        ["localSnapPath"] = snapDir .. "ScummVM" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/SCUMMVM/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/SCUMMVM/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_scummvm.png",
    },
    [41] = 
    {
        ["apptype"] = 41,
        ["table"] = "pico8_table",
        ["user_db_file"] = "db_pico8.lua",
        ["romFolder"] = romUserDir.Pico8,
        ["localCoverPath"] = covDir .. "Lexaloffle Games - Pico-8" .. "/",
        ["localSnapPath"] = snapDir .. "Lexaloffle Games - Pico-8" .. "/",
        ["onlineCoverPathSystem"] = "",
        ["onlineSnapPathSystem"] = "",
        ["Missing_Cover"] = "missing_cover_pico8.png",
    },
    [42] = 
    {
        ["apptype"] = 42,
        ["table"] = "sysapps_table",
        ["user_db_file"] = "db_sysapps.lua",
        -- ["romFolder"] = "",
        ["localCoverPath"] = covDir .. "System apps" .. "/",
        ["localSnapPath"] = snapDir .. "System apps" .. "/",
        ["onlineCoverPathSystem"] = "",
        ["onlineSnapPathSystem"] = "",
        ["Missing_Cover"] = "icon_psv.png",
    },
    [43] = 
    {
        ["apptype"] = 43,
        ["table"] = "nds_table",
        ["user_db_file"] = "db_nds.lua",
        ["romFolder"] = romUserDir.Nintendo_DS,
        ["localCoverPath"] = covDir .. "Nintendo - Nintendo DS" .. "/",
        ["localSnapPath"] = snapDir .. "Nintendo - Nintendo DS" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/NDS/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/NDS/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_nds.png",
    },
    [44] = 
    {
        -- ["apptype"] = 44,
        ["table"] = "fav_count",
        -- ["user_db_file"] = "",
        -- ["romFolder"] = "",
        -- ["localCoverPath"] = "",
        -- ["onlineCoverPathSystem"] = "",
        -- ["Missing_Cover"] = "",
    },
    [45] = 
    {
        -- ["apptype"] = 45,
        ["table"] = "recently_played_table",
        -- ["user_db_file"] = "",
        -- ["romFolder"] = "",
        -- ["localCoverPath"] = "",
        -- ["onlineCoverPathSystem"] = "",
        -- ["Missing_Cover"] = "",
    },
    [46] = 
    {
        -- ["apptype"] = 46,
        ["table"] = "search_results_table",
        -- ["user_db_file"] = "",
        -- ["romFolder"] = "",
        -- ["localCoverPath"] = "",
        -- ["onlineCoverPathSystem"] = "",
        -- ["Missing_Cover"] = "",
    },
    
}

-- Counts
local syscount = #SystemsToScan
count_of_systems = syscount - 1 -- Minus: Favorites, Recently played
count_of_categories = syscount
count_of_start_categories = syscount - 1  -- Minus: Search
count_of_cache_files = syscount - 3 -- -- Minus: Search, Fav, Recent
count_of_get_covers = syscount - 5 -- Minus psm
count_of_get_snaps = syscount - 6 -- Minus psm and vita too



-- QUICK SCANS

    -- Quick scan files

        local QuickDoesFileExist = {
            working_dir = {},
            cur_dir = {},
            snapDir = {},
            db_Cache_Folder = {},
            collections_dir = {},
            covDir = {},
            db_Folder = {},
            iconDir = {},
            music_dir = {},
            romsMainDir = {},
            user_DB_Folder = {},
            background_dir = {},
            app_DATA = {},
            ur0_appmeta = {},
            background_dir_psp = {}
        }

        function quickScanFiles(dir_path, depth, allow, extensions)
            depth = depth or 0
            allow = (allow == nil) and true or allow
            extensions = extensions or {}
            
            local results = {}
            
            -- Convert extensions to lookup table (handle both string and table input)
            local ext_lookup = {}
            if type(extensions) == "string" then
                -- Parse comma-separated string like ".png,.jpg,.gif"
                for ext in extensions:gmatch("[^,]+") do
                    ext = ext:match("^%s*(.-)%s*$") -- trim whitespace
                    if ext:sub(1,1) == "." then
                        ext_lookup[ext:lower()] = true
                    end
                end
            elseif type(extensions) == "table" then
                for _, ext in ipairs(extensions) do
                    if type(ext) == "string" and ext:sub(1,1) == "." then
                        ext_lookup[ext:lower()] = true
                    end
                end
            end
            
            -- Helper function to check if extension matches filter
            local function extensionMatches(filename)
                if #ext_lookup == 0 then return true end -- no filter = include all
                
                local ext = filename:match("%.([^%.]+)$")
                if ext then ext = "." .. ext:lower() end
                
                local has_ext = ext and ext_lookup[ext]
                return allow and has_ext or (not allow and not has_ext)
            end
            
            local function scanDir(path, current_depth)
                if current_depth > depth then return end
                
                local files = System.listDirectory(path)
                if not files then return end
                
                for _, file in pairs(files) do
                    if file.name ~= "." and file.name ~= ".." then
                        -- Handle path concatenation properly to avoid double slashes
                        local full_path
                        if path:sub(-1) == "/" then
                            full_path = path .. file.name
                        else
                            full_path = path .. "/" .. file.name
                        end
                        
                        if file.directory and current_depth < depth then
                            scanDir(full_path, current_depth + 1)
                        elseif not file.directory then
                            -- Skip hidden files and metadata
                            if file.name:sub(1,1) ~= "." and 
                               file.name ~= "DS_Store" and 
                               file.name ~= "Thumbs.db" then
                                
                                if extensionMatches(file.name) then
                                    -- Store as key-value pair (path -> true) like C version
                                    results[full_path] = true
                                end
                            end
                        end
                    end
                end
            end
            
            scanDir(dir_path, 0)
            return results
        end

    -- Quick scan games
    
        local QuickGameList = {
            games_table = {},
            adrenaline_games_folder = {},
            adrenaline_iso_folder = {},
            psx_retroarch = {},
            psx_table = {},
            n64_table = {},
            snes_table = {},
            nes_table = {},
            nds_table = {},
            gba_table = {},
            gbc_table = {},
            gb_table = {},
            dreamcast_table = {},
            sega_cd_table = {},
            s32x_table = {},
            md_table = {},
            sms_table = {},
            gg_table = {},
            tg16_table = {},
            tgcd_table = {},
            pce_table = {},
            pcecd_table = {},
            amiga_table = {},
            c64_table = {},
            wswan_col_table = {},
            wswan_table = {},
            msx2_table = {},
            msx1_table = {},
            zxs_table = {},
            atari_7800_table = {},
            atari_5200_table = {},
            atari_2600_table = {},
            atari_lynx_table = {},
            colecovision_table = {},
            vectrex_table = {},
            fba_table = {},
            mame_2003_plus_table = {},
            mame_2000_table = {},
            neogeo_table = {},
            ngpc_table = {},
            psm_table = {},
            scummvm_table = {},
            pico8_table = {},
            nds_table = {},
            sysapps_table = {}
        }

        function quickScanGames(dir_path, depth, allow, ...)
            depth = depth or 0
            allow = (allow == nil) and true or allow
            local extensions = {...}  -- Collect all remaining arguments into a table
            
            local results = {}
            local idx = 1
            
            -- Convert extensions to lookup table
            local ext_lookup = {}
            for _, ext in ipairs(extensions) do
                ext_lookup[ext:lower()] = true
            end
            
            -- Excluded extensions
            local excluded_exts = {
                ".sav", ".srm", ".eep", ".fla", ".rtc", ".dsv",
                ".st0", ".st1", ".st2", ".sta", ".state", ".sgm", 
                ".sr0", ".ss0", ".ss1", ".ss2", ".sv0", ".sv1",
                ".qs0", ".qs1", ".qs2", ".bsv", ".mpk", ".sra",
                ".mcr", ".mem", ".mc", ".mcd", ".vmp", ".vmu", 
                ".vms", ".dci", ".nv", ".nvm", ".nvram", ".hi",
                ".sna", ".szx", ".replay", ".cfg"
            }
            
            local excluded_lookup = {}
            for _, ext in ipairs(excluded_exts) do
                excluded_lookup[ext:lower()] = true
            end
            
            local function scanDir(path, current_depth)
                if current_depth > depth then return end
                
                local files = System.listDirectory(path)
                if not files then return end
                
                for _, file in pairs(files) do
                    if file.name ~= "." and file.name ~= ".." then
                        local full_path = path .. "/" .. file.name
                        
                        if file.directory and current_depth < depth then
                            scanDir(full_path, current_depth + 1)
                        elseif not file.directory then
                            -- Skip hidden files and metadata
                            if file.name:sub(1,1) ~= "." and 
                               file.name ~= "DS_Store" and 
                               file.name ~= "Thumbs.db" then
                                
                                local ext = file.name:match("%.([^%.]+)$")
                                if ext then ext = "." .. ext:lower() end
                                
                                -- Check if excluded
                                if not (ext and excluded_lookup[ext]) and
                                   not file.name:lower():find("bios") then
                                    
                                    -- Check extension filter
                                    local include_file = false
                                    if #extensions == 0 then
                                        include_file = true
                                    else
                                        local has_ext = ext and ext_lookup[ext]
                                        include_file = allow and has_ext or (not allow and not has_ext)
                                    end
                                    
                                    if include_file then
                                        results[idx] = {
                                            name = file.name,
                                            path = full_path,
                                            subfolder = current_depth > 0,  -- true if found in subfolder
                                            -- size = file.size
                                        }
                                        idx = idx + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            scanDir(dir_path, 0)
            return results
        end

        function quickScanVita()
            local base = "ux0:/app"
            local results = {}
            local idx = 1
            
            -- Try to list the app directory
            local apps = System.listDirectory(base)
            if not apps then
                return results -- Return empty table if directory doesn't exist
            end
            
            for _, entry in pairs(apps) do
                -- Skip . and .. entries
                if entry.name ~= "." and entry.name ~= ".." then
                    -- Only process directories
                    if entry.directory then
                        -- Only process folders with exactly 9 characters (Vita app ID format)
                        if string.len(entry.name) == 9 then
                            -- Construct full app path
                            local apppath
                            if base:sub(-1) == "/" then
                                apppath = base .. entry.name
                            else
                                apppath = base .. "/" .. entry.name
                            end
                            
                            -- Check for sce_sys/param.sfo
                            local param_path = apppath .. "/sce_sys/param.sfo"
                            if System.doesFileExist(param_path) then
                                -- Check for menucolor.bin (indicates Adrenaline bubble)
                                local menu_path = apppath .. "/menucolor.bin"
                                local has_menu = System.doesFileExist(menu_path)
                                
                                -- Build entry table
                                results[idx] = {
                                    name = entry.name,
                                    path = apppath,
                                    adrenaline_bubble = has_menu,
                                    directory = true
                                }
                                idx = idx + 1
                            end
                        end
                    end
                end
            end
            
            return results
        end


-- COLLECTIONS

    function print_table_collection_files(def_collection_files)
        dofile("app0:addons/printTable.lua")
        print_table_collection_files((def_collection_files))
    end

    function update_cached_collection(def_user_db_file, def_table_name)
        dofile("app0:addons/printTable.lua")
        print_table_collection((def_user_db_file), (def_table_name))
    end

    -- Collections: Create directory
        local collections_dir = "ux0:/data/RetroFlow/COLLECTIONS/"
        System.createDirectory(collections_dir)

    -- List directory and insert into collection_files table
        function create_collections_list()
            collection_files = {}
            collection_dir_files = System.listDirectory(collections_dir)
            for i, file in pairs(collection_dir_files) do
                if not file.directory then
                    if string.match(file.name, "%.lua")
                        and not string.match(file.name, "Thumbs%.db")
                        and not string.match(file.name, "%._") then
                        file.filename = file.name
                        -- Remove lua in filename to get table name
                        file.table_name = file.name:gsub(".lua", "")
                        -- Remove lua in filename and underscores to get display name for category titles
                        file.display_name = file.name:gsub(".lua", ""):gsub("Collection_", ""):gsub("_", " ")
                        table.insert(collection_files, file)
                    end
                end
            end
        end

        create_collections_list()

    -- Sort collection aphabetically for showing categories later
        table.sort(collection_files, function(a, b) return (a.filename:lower() < b.filename:lower()) end)

    -- Print table for debugging
        -- print_table_collection_files(collection_files)

    -- Count custom categories
        local collection_count = 0
        collection_count = #collection_files
        collection_syscount = syscount + collection_count
        if collection_count == 0 then
            collection_count_of_start_categories = count_of_start_categories
        else
            collection_count_of_start_categories = collection_count + count_of_start_categories + 1
        end



Network.init()


Sound.init()
local click = Sound.open("app0:/DATA/click2.ogg")
local sndMusic = click--temp
local imgCoverTmp = Graphics.loadImage("app0:/DATA/noimg.png")
local backTmp = Graphics.loadImage("app0:/DATA/noimg.png")

btnT = Graphics.loadImage("app0:/DATA/t.png")
btnS = Graphics.loadImage("app0:/DATA/s.png")
imgWifi = Graphics.loadImage("app0:/DATA/wifi.png")
imgBattery = Graphics.loadImage("app0:/DATA/bat.png")
imgBatteryCharging = Graphics.loadImage("app0:/DATA/bat_ch.png")
imgBack = Graphics.loadImage("app0:/DATA/BG_Default.png")
imgFloor = Graphics.loadImage("app0:/DATA/floor.png")
footer_gradient = Graphics.loadImage("app0:/DATA/footer_gradient.png")

imgFavorite_small_on = Graphics.loadImage("app0:/DATA/fav-small-on.png")
imgFavorite_large_on = Graphics.loadImage("app0:/DATA/fav-large-on.png")
imgFavorite_large_off = Graphics.loadImage("app0:/DATA/fav-large-off.png")
imgHidden_small_on = Graphics.loadImage("app0:/DATA/hidden-small-on.png")
imgHidden_large_on = Graphics.loadImage("app0:/DATA/hidden-large-on.png")

file_browser_folder_open = Graphics.loadImage("app0:/DATA/file-browser-folder-open.png")
file_browser_folder_closed = Graphics.loadImage("app0:/DATA/file-browser-folder-closed.png")
file_browser_file = Graphics.loadImage("app0:/DATA/file-browser-file.png")

setting_icon_theme = Graphics.loadImage("app0:/DATA/setting-icon-theme.png")
setting_icon_artwork = Graphics.loadImage("app0:/DATA/setting-icon-artwork.png")
setting_icon_categories = Graphics.loadImage("app0:/DATA/setting-icon-categories.png")
setting_icon_language = Graphics.loadImage("app0:/DATA/setting-icon-language.png")
setting_icon_scanning = Graphics.loadImage("app0:/DATA/setting-icon-scanning.png")
setting_icon_search = Graphics.loadImage("app0:/DATA/setting-icon-search.png")
setting_icon_sounds = Graphics.loadImage("app0:/DATA/setting-icon-sounds.png")
setting_icon_about = Graphics.loadImage("app0:/DATA/setting-icon-about.png")
setting_icon_other = Graphics.loadImage("app0:/DATA/setting-icon-other.png")

setting_icon_heart = Graphics.loadImage("app0:/DATA/setting-icon-heart.png")
setting_icon_filter = Graphics.loadImage("app0:/DATA/setting-icon-filter.png")

setting_icon_random = Graphics.loadImage("app0:/DATA/setting-icon-random.png")

setting_icon_sort = Graphics.loadImage("app0:/DATA/setting-icon-sort.png")
setting_icon_sort_up = Graphics.loadImage("app0:/DATA/setting-icon-sort-up.png")
setting_icon_sort_down = Graphics.loadImage("app0:/DATA/setting-icon-sort-down.png")

-- Start of ROM Browser setup

    local grey_dir = Color.new(200, 200, 200)
    local white_opaque = Color.new(255, 255, 255, 100)
    local transparent = Color.new(255, 255, 255, 0)

    local scripts = System.listDirectory("ux0:/")

    function scripts_sort_by_folder_first()
        sorted_directories = {}
        for k, v in pairs(scripts) do
            if v.directory == true then
                table.insert(sorted_directories, v)
            end
        end
        table.sort(sorted_directories, function(a, b) return (a.name:lower() < b.name:lower()) end)

        sorted_files = {}
        for k, v in pairs(scripts) do
            if v.directory == false then
                table.insert(sorted_files, v)
            end
        end
        table.sort(sorted_files, function(a, b) return (a.name:lower() < b.name:lower()) end)

        scripts = {}
        for k, v in pairs(sorted_directories) do
            table.insert(scripts, v)
        end
        for k, v in pairs(sorted_files) do
            table.insert(scripts, v)
        end
    end

    scripts_sort_by_folder_first()
    for k, v in pairs(scripts) do
        v.previous_directory = false
        v.save = false
    end

    selection = {}
    selection.name = "Use this directory"
    selection.directory = true
    selection.previous_directory = false
    selection.save = true

    level_up = {}
    level_up.name = "..."
    level_up.directory = true
    level_up.previous_directory = true
    level_up.save = false

    local cur_dir_fm = "ux0:/"

    -- Init a index
    local i = 1

-- End of ROM Browser setup


-- Start of Custom Collection Sort Scroll list
    cc_scrollPosition = 0  -- Current scroll offset (in items)
    cc_maxVisibleItems = 8  -- Maximum items that can fit on the screen
    cc_selected = 1  -- Index of the selected item
    cc_edit_mode = false -- Edit mode affects controls
    cc_updated = false -- If changes made then set to true
    cc_reset = false -- If reset to alphabetical then set to true
    cc_already_custom = false -- If collection already has custom sorting

-- End of Custom Collection Sort Scroll list


-- Start of Game list view setup

    -- Init a index
    -- local gl = 1

-- End of Game list view setup

temp_hb_collection = {}

Graphics.setImageFilters(imgFloor, FILTER_LINEAR, FILTER_LINEAR)


-- CREATE DIRECTORIES

-- Create directory: Backgrounds
local background_dir = "ux0:/data/RetroFlow/WALLPAPER/"
System.createDirectory(background_dir)

-- Create directory: Music
local music_dir = "ux0:/data/RetroFlow/MUSIC/"
System.createDirectory(music_dir)

-- Create directory: Cover Folders
System.createDirectory(covDir)
for k, v in pairs(SystemsToScan) do
    System.createDirectory(tostring(v.localCoverPath))
end

-- Create directory: Snap Folders
System.createDirectory(snapDir)
for k, v in pairs(SystemsToScan) do
    System.createDirectory(tostring(v.localSnapPath))
end

-- Create directory: User Database
local user_DB_Folder = "ux0:/data/RetroFlow/TITLES/"
System.createDirectory(user_DB_Folder)

-- Create directory: Databases
local db_Folder = "ux0:/data/RetroFlow/DATABASES/"
System.createDirectory(db_Folder)

-- Copy databases from app to data
if not System.doesFileExist(db_Folder .. "/mame_2000.db") then
    System.copyFile("app0:/addons/mame_2000.db", db_Folder .. "/mame_2000.db")
end
if not System.doesFileExist(db_Folder .. "/mame_2003_plus.db") then
    System.copyFile("app0:/addons/mame_2003_plus.db", db_Folder .. "/mame_2003_plus.db")
end
if not System.doesFileExist(db_Folder .. "/neogeo.db") then
    System.copyFile("app0:/addons/neogeo.db", db_Folder .. "/neogeo.db")
end
if not System.doesFileExist(db_Folder .. "/fba_2012.db") then
    System.copyFile("app0:/addons/fba_2012.db", db_Folder .. "/fba_2012.db")
end
if not System.doesFileExist(db_Folder .. "/scummvm.db") then
    System.copyFile("app0:/addons/scummvm.db", db_Folder .. "/scummvm.db")
end
if not System.doesFileExist(db_Folder .. "/amiga.db") then
    System.copyFile("app0:/addons/amiga.db", db_Folder .. "/amiga.db")
end


-- Table Cache
local db_Cache_Folder = "ux0:/data/RetroFlow/CACHE/"
System.createDirectory(db_Cache_Folder)

-- Copy default backgrounds to wallpaper folder
if not System.doesFileExist(background_dir .. "Aurora.png") then System.copyFile("app0:/DATA/Aurora.png", background_dir .. "Aurora.png") end
if not System.doesFileExist(background_dir .. "Blur 1.jpg") then System.copyFile("app0:/DATA/Blur 1.jpg", background_dir .. "Blur 1.jpg") end
if not System.doesFileExist(background_dir .. "Blur 2.jpg") then System.copyFile("app0:/DATA/Blur 2.jpg", background_dir .. "Blur 2.jpg") end
if not System.doesFileExist(background_dir .. "Blur 3.jpg") then System.copyFile("app0:/DATA/Blur 3.jpg", background_dir .. "Blur 3.jpg") end
if not System.doesFileExist(background_dir .. "Grey.png") then System.copyFile("app0:/DATA/Grey.png", background_dir .. "Grey.png") end


-- Retroarch Cores
core =
{
SNES = "app0:/snes9x2005_libretro.self",
NES = "app0:/quicknes_libretro.self",
GBA = "app0:/gpsp_libretro.self",
GBC = "app0:/gambatte_libretro.self",
GB = "app0:/gambatte_libretro.self",
SEGA_CD = "app0:/genesis_plus_gx_libretro.self",
s32X = "app0:/picodrive_libretro.self",
MD = "app0:/genesis_plus_gx_libretro.self",
SMS = "app0:/smsplus_libretro.self",
GG = "app0:/smsplus_libretro.self",
TG16 = "app0:/mednafen_pce_fast_libretro.self",
TGCD = "app0:/mednafen_pce_fast_libretro.self",
PCE = "app0:/mednafen_pce_fast_libretro.self",
PCECD = "app0:/mednafen_pce_fast_libretro.self",
AMIGA = "app0:/puae_libretro.self",
C64 = "app0:/vice_x64_libretro.self",
WSWAN_COL = "app0:/mednafen_wswan_libretro.self",
WSWAN = "app0:/mednafen_wswan_libretro.self",
MSX2 = "app0:/fmsx_libretro.self",
MSX1 = "app0:/fmsx_libretro.self",
ZXS = "app0:/fuse_libretro.self",
ATARI_7800 = "app0:/prosystem_libretro.self",
ATARI_5200 = "app0:/atari800_libretro.self",
ATARI_2600 = "app0:/stella2014_libretro.self",
ATARI_LYNX = "app0:/handy_libretro.self",
COLECOVISION = "app0:/bluemsx_libretro.self",
VECTREX = "app0:/vecx_libretro.self",
FBA = "app0:/fbalpha2012_libretro.self",
MAME_2003_PLUS = "app0:/mame2003_plus_libretro.self",
MAME_2000 = "app0:/mame2000_libretro.self",
NEOGEO = "app0:/fbalpha2012_neogeo_libretro.self",
NGPC = "app0:/mednafen_ngp_libretro.self",
PS1 = "app0:/pcsx_rearmed_libretro.self",
}

-- Launcher App Directory
-- local launch_dir_adr = "ux0:/app/RETROLNCR/"
-- local launch_app_adr = "RETROLNCR"
launch_dir_adr = "ux0:/app/RETROLNCR/"
launch_app_adr = "RETROLNCR"

-- Create Overrides file
if not System.doesFileExist(cur_dir .. "/overrides.dat") then
    local file_over = System.openFile(cur_dir .. "/overrides.dat", FCREATE)
    System.writeFile(file_over, " ", 1)
    System.closeFile(file_over)
end

-- Create Favorites file
if not System.doesFileExist(cur_dir .. "/favorites.dat") then
    local file_favorites = System.openFile(cur_dir .. "/favorites.dat", FCREATE)
    System.writeFile(file_favorites, " ", 1)
    System.closeFile(file_favorites)
end

-- load textures
local imgBox = Graphics.loadImage("app0:/DATA/vita_cover.png")
local imgBoxPSP = Graphics.loadImage("app0:/DATA/psp_cover.png")
local imgBoxPSX = Graphics.loadImage("app0:/DATA/psx_cover.png")
local imgBoxBLANK = Graphics.loadImage("app0:/DATA/blank_cover.png")

-- Load models
local modBox = Render.loadObject("app0:/DATA/box.obj", imgBox)
local modCover = Render.loadObject("app0:/DATA/cover.obj", imgCoverTmp)
local modBoxNoref = Render.loadObject("app0:/DATA/box_noreflx.obj", imgBox)
local modCoverNoref = Render.loadObject("app0:/DATA/cover_noreflx.obj", imgCoverTmp)

local modBoxPSP = Render.loadObject("app0:/DATA/boxpsp.obj", imgBoxPSP)
local modCoverPSP = Render.loadObject("app0:/DATA/coverpsp.obj", imgCoverTmp)
local modBoxPSPNoref = Render.loadObject("app0:/DATA/boxpsp_noreflx.obj", imgBoxPSP)
local modCoverPSPNoref = Render.loadObject("app0:/DATA/coverpsp_noreflx.obj", imgCoverTmp)

local modBoxPSX = Render.loadObject("app0:/DATA/boxpsx.obj", imgBoxPSX)
local modCoverPSX = Render.loadObject("app0:/DATA/coverpsx.obj", imgCoverTmp)
local modBoxPSXNoref = Render.loadObject("app0:/DATA/boxpsx_noreflx.obj", imgBoxPSX)
local modCoverPSXNoref = Render.loadObject("app0:/DATA/coverpsx_noreflx.obj", imgCoverTmp)

local modCoverN64 = Render.loadObject("app0:/DATA/covern64.obj", imgCoverTmp)
local modCoverN64Noref = Render.loadObject("app0:/DATA/covern64_noreflx.obj", imgCoverTmp)

local modCoverNES = Render.loadObject("app0:/DATA/covernes.obj", imgCoverTmp)
local modCoverNESNoref = Render.loadObject("app0:/DATA/covernes_noreflx.obj", imgCoverTmp)

local modCoverGB = Render.loadObject("app0:/DATA/covergb.obj", imgCoverTmp)
local modCoverGBNoref = Render.loadObject("app0:/DATA/covergb_noreflx.obj", imgCoverTmp)

local modCoverMD = Render.loadObject("app0:/DATA/covermd.obj", imgCoverTmp)
local modCoverMDNoref = Render.loadObject("app0:/DATA/covermd_noreflx.obj", imgCoverTmp)

local modCoverTAPE = Render.loadObject("app0:/DATA/covertape.obj", imgCoverTmp)
local modCoverTAPENoref = Render.loadObject("app0:/DATA/covertape_noreflx.obj", imgCoverTmp)

local modCoverATARI = Render.loadObject("app0:/DATA/coveratari.obj", imgCoverTmp)
local modCoverATARINoref = Render.loadObject("app0:/DATA/coveratari_noreflx.obj", imgCoverTmp)

local modCoverLYNX = Render.loadObject("app0:/DATA/coverlynx.obj", imgCoverTmp)
local modCoverLYNXNoref = Render.loadObject("app0:/DATA/coverlynx_noreflx.obj", imgCoverTmp)

local modCoverHbr = Render.loadObject("app0:/DATA/cover_square.obj", imgCoverTmp)
local modCoverHbrNoref = Render.loadObject("app0:/DATA/cover_square_noreflx.obj", imgCoverTmp)

local modBackground = Render.loadObject("app0:/DATA/planebg.obj", imgBack)
local modDefaultBackground = Render.loadObject("app0:/DATA/planebg.obj", imgBack)
local modFloor = Render.loadObject("app0:/DATA/planefloor.obj", imgFloor)

local modCoverSNESJapan = Render.loadObject("app0:/DATA/covernsnesjapan.obj", imgCoverTmp)
local modCoverSNESJapanNoref = Render.loadObject("app0:/DATA/covernsnesjapan_noreflx.obj", imgCoverTmp)

local modCoverMiddle = Render.loadObject("app0:/DATA/covermiddle.obj", imgCoverTmp)
local modCoverMiddleNoref = Render.loadObject("app0:/DATA/covermiddle_noreflix.obj", imgCoverTmp)


local img_path = ""

fontname = "font-SawarabiGothic-Regular.woff"
fnt20 = Font.load("app0:/DATA/" .. fontname)
fnt22 = Font.load("app0:/DATA/" .. fontname)
fnt25 = Font.load("app0:/DATA/" .. fontname)

Font.setPixelSizes(fnt20, 20)
Font.setPixelSizes(fnt22, 22)
Font.setPixelSizes(fnt25, 25)

-- Escape magic characters
function escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

-- Keyboard
local hasTyped = false

-- Search
local keyboard_search = false
local ret_search = ""

-- Rename
local keyboard_rename = false
local ret_rename = ""

-- Collection name
local keyboard_collection_name_new = false
local ret_collection = ""

-- Collection rename
local keyboard_collection_rename = false
local ret_rename_collection = ""

-- Random game
-- random_game_selected = false


-- Loading progress
-- loading_tasks = 0

-- Pcall for safe import of lua files
    function safe_dofile(file_path)
        local success, result = pcall(dofile, file_path)
        if success then
            return result  -- Return the result if successful
        else
            -- print("Error loading file:", result)  -- Log the error message
            return {}  -- Return an empty table on error
        end
    end

-- Import title info scanned from onelua script
function import_cached_titles()

    if System.doesFileExist (user_DB_Folder .. "sfo_scan_vita.lua") then
        sfo_scan_vita_db = safe_dofile(user_DB_Folder .. "sfo_scan_vita.lua")
    else
        sfo_scan_vita_db = {}
    end

    -- Import onelua sfo scanned psp and psx titles

        if System.doesFileExist (user_DB_Folder .. "sfo_scans_onelua.lua") then
            sfo_scans_onelua = safe_dofile(user_DB_Folder .. "sfo_scans_onelua.lua")
        else
            sfo_scans_onelua = {}
        end

    -- Create empty table for scummvm, populated when scanning later. Should probably belongs somewhere else, but if it ain't broke don't fix it

        scan_scummvm_db = {}
end
import_cached_titles()


function delete_onelua_title_files()
    -- Function used for startup scan on - triggers rescan
    if System.doesFileExist (user_DB_Folder .. "sfo_scan_isos.lua") then
        System.deleteFile(user_DB_Folder .. "sfo_scan_isos.lua")
    end
    if System.doesFileExist (user_DB_Folder .. "sfo_scan_games.lua") then
        System.deleteFile(user_DB_Folder .. "sfo_scan_games.lua")
    end
    if System.doesFileExist (user_DB_Folder .. "sfo_scan_retroarch.lua") then
        System.deleteFile(user_DB_Folder .. "sfo_scan_retroarch.lua")
    end
end

function count_cache_and_reload()
    cache_file_count = System.listDirectory(db_Cache_Folder)
    if #cache_file_count ~= count_of_cache_files then
        -- Files missing - rescan
        cache_all_tables()
        files_table = import_cached_DB()
        import_collections()
    else
        files_table = import_cached_DB()
        import_collections()
    end
end

function delete_cache()
    dofile("app0:addons/printTable.lua")
    delete_tables()

    -- local sfo_scan_isos_lua = "ux0:/data/RetroFlow/TITLES/sfo_scan_isos.lua"
    -- local sfo_scan_games_lua = "ux0:/data/RetroFlow/TITLES/sfo_scan_games.lua"
    -- local sfo_scan_retroarch_lua = "ux0:/data/RetroFlow/TITLES/sfo_scan_retroarch.lua"

    -- if System.doesFileExist(sfo_scan_isos_lua) then
    --     System.deleteFile(sfo_scan_isos_lua)
    -- end
    -- if System.doesFileExist(sfo_scan_games_lua) then
    --     System.deleteFile(sfo_scan_games_lua)
    -- end
    -- if System.doesFileExist(sfo_scan_retroarch_lua) then
    --     System.deleteFile(sfo_scan_retroarch_lua)
    -- end

end

-- Used for crc scan, can keep title files
function delete_cache_keep_titles()
    dofile("app0:addons/printTable.lua")
    delete_tables()
end



-- PRINT TABLE FUNCTIONS
function cache_all_tables()
    dofile("app0:addons/printTable.lua")
    print_tables()
end
function update_cached_table(def_user_db_file, def_table_name)
    dofile("app0:addons/printTable.lua")
    print_table_system((def_user_db_file), (def_table_name))
end
function update_cached_table_recently_played()
    dofile("app0:addons/printTable.lua")
    print_table_recently_played()
end
function update_cached_table_recently_played_pre_launch()
    dofile("app0:addons/printTable.lua")
    print_table_recently_played_pre_launch()
end
function update_cached_table_renamed_games()
    dofile("app0:addons/printTable.lua")
    print_table_renamed_games()
end
function update_cached_table_hidden_games()
    dofile("app0:addons/printTable.lua")
    print_table_hidden_games()
end
function update_cached_table_launch_overrides()
    dofile("app0:addons/printTable.lua")
    print_table_launch_overrides()
end
function print_table_missing_covers()
    dofile("app0:addons/printTable.lua")
    print_missing_covers()
end
function print_table_missing_snaps()
    dofile("app0:addons/printTable.lua")
    print_missing_snaps()
end

function print_onelua_title_files()
    -- Related to startup scan setting - save scanned titles tables to lua file so can be imported when startup scan is off 
    function write_ini(pathini, tbl)
        file = io.open(pathini, "w+")
        file:write("return" .. "\n" .. "{" .. "\n")
        for k, v in pairs((tbl)) do
            file:write('["' .. k .. '"] = {title = "' .. (v.title or "UNK") .. '", titleid = "' .. (v.titleid or "UNK") .. '", category = "' .. (v.category or "UNK") .. '", region = "' .. (v.version or "UNK") .. '", path = "' .. (v.path or "UNK") .. '"},' .. "\n")
        end
        file:write('}')
        file:close()
    end

    -- Separate sfo_scans_onelua entries by path type
    local sfo_scan_isos_db = {}
    local sfo_scan_games_db = {}
    local sfo_scan_retroarch_db = {}

    for k, v in pairs(sfo_scans_onelua) do
        if v.path and string.match(v.path, "pspemu/ISO/") then
            sfo_scan_isos_db[k] = v
        elseif v.path and string.match(v.path, "pspemu/PSP/GAME/") then
            sfo_scan_games_db[k] = v
        else
            sfo_scan_retroarch_db[k] = v
        end
    end

    write_ini(user_DB_Folder .. "sfo_scan_isos.lua", sfo_scan_isos_db)
    write_ini(user_DB_Folder .. "sfo_scan_games.lua", sfo_scan_games_db)
    write_ini(user_DB_Folder .. "sfo_scan_retroarch.lua", sfo_scan_retroarch_db)
end

function CreateUserTitleTable_for_Vita(path, def_table_name)
    file = io.open(path, "w+")
    file:write("return" .. "\n" .. "{" .. "\n")
    for k, v in pairs((def_table_name)) do
        file:write('["' .. v.name .. '"] = {title = "' .. v.title .. '", titleid = "' .. v.titleid .. '", version = "' .. v.version .. '"},' .. "\n")
    end
    file:write('}')
    file:close()
end

-- File reading

    function readAll(file)
        local f = assert(io.open(file, "rb"))
        local content = f:read("*all")
        f:close()
        return content
    end

    ini = ini or {}

    function ini.read(path, section, key, default)
        -- Handle both 3 and 4 parameter calling conventions
        local file_path, section_name, key_name, default_value
        
        if key == nil then
            -- 3 parameters: ini.read(path, key, default)
            file_path = path
            section_name = nil
            key_name = section
            default_value = key or ""
        else
            -- 4 parameters: ini.read(path, section, key, default)
            file_path = path
            section_name = section
            key_name = key
            default_value = default or ""
        end
        
        -- Try to open the file
        local file = io.open(file_path, "r")
        if not file then
            return default_value
        end
        
        local in_section = (section_name == nil)
        local section_header = section_name and ("[" .. section_name .. "]") or nil
        
        for line in file:lines() do
            -- Remove leading and trailing whitespace
            local trimmed = line:match("^%s*(.-)%s*$")
            
            -- Skip comments
            if trimmed:match("^[;#]") then
                goto continue
            end
            
            -- Check for section headers
            if trimmed:match("^%[.*%]$") then
                if section_name then
                    in_section = (trimmed == section_header)
                end
                goto continue
            end
            
            -- Skip if we're not in the right section
            if not in_section then
                goto continue
            end
            
            -- Look for key=value pairs
            local found_key, value = trimmed:match("^([^=]+)=(.*)$")
            if found_key then
                -- Trim whitespace from key and value
                found_key = found_key:match("^%s*(.-)%s*$")
                value = value:match("^%s*(.-)%s*$")
                
                if found_key == key_name then
                    file:close()
                    return value
                end
            end
            
            ::continue::
        end
        
        file:close()
        return default_value
    end


local menuX = 0
local menuY = 0
local showMenu = 0
local showCat = 1 -- Category: 0 = all, 1 = games, 2 = homebrews, 3 = psp, 4 = psx, 5 = N64, 6 = SNES, 7 = NES, 8 = GBA, 9 = GBC, 10 = GB, 11 = MD, 12 = SMS, 13 = GG, 14 = MAME, 15 = AMIGA, 16 = TG16, 17 = TG CD, 18 = PCE, 19 = PCE CD, 20 = NGPC, 21 = Favorites
local showView = 0

local info = System.extractSfo("app0:/sce_sys/param.sfo")
local app_version = info.version
local app_title = info.short_title
local app_category = info.category
local app_titleid = info.titleid
local app_size = 0

local master_index = 1
local p = 1
local oldpad = 0
local delayTouch = 8.0
local delayButton = 8.0
local hideBoxes = 0.3 -- used to be 1
local prvRotY = 0

local gettingCovers = false
local gettingBackgrounds = false
local scanComplete = false
local bgscanComplete = false

-- Init Colors
local black = Color.new(0, 0, 0)
local grey = Color.new(45, 45, 45)
local darkalpha = Color.new(40, 40, 40, 180)
local dark = Color.new(40, 40, 40, 255)
local blackalpha = Color.new(0, 0, 0, 215)
local lightgrey = Color.new(58, 58, 58)
local white = Color.new(255, 255, 255)
local red = Color.new(190, 0, 0)
local blue = Color.new(2, 72, 158)
local yellow = Color.new(225, 184, 0)
local green = Color.new(79, 152, 37)
local purple = Color.new(151, 0, 185)
local darkpurple = Color.new(77, 4, 160)
local orange = Color.new(220, 120, 0)
local bg = Color.new(153, 217, 234)
local themeCol = Color.new(2, 72, 158)
local loading_bar_bg = Color.new(255,255,255,50)
local transparent = Color.new(255, 255, 255, 0)
local timercolor = transparent
local darkgrey = Color.new(61, 68, 80)

local targetX = 0
local xstart = 0
local ystart = 0
local space = 1
local touchdown = 0
local startCovers = false
local inPreview = false
local apptype = 0
local appdir = ""
local getCovers = 0
local getRomDir = 1
local getSnaps = 0
local tmpappcat = 0



-- Flat view layout (Spaced)
fv_left_margin = 70
fv_cover_height = 220
fv_cover_y = (496 - fv_cover_height) / 2 + 10 -- Vertically centre
fv_gutter = 20
fv_border = 5

-- Flat view layout (Tight)
-- fv_left_margin = 75
-- fv_cover_height = 200
-- fv_cover_y = (496 - fv_cover_height) / 2 + 10 -- Vertically centre
-- fv_gutter = 8
-- fv_border = 4

-- Smooth scrolling
quick_scrolling_factor = 0
quick_scrolling_factor_goal = 0

local game_adr_bin_driver = 0
local game_adr_exec_bin = 0
game_adr_plugins = 0
game_adr_speed = 0
game_adr_hm = 0
game_adr_nonpdrm = 0
game_adr_suspend = 0

local collection_number = 0
local xcollection_number = 1

local prevX = 0
local prevZ = 0
local prevRot = 0

local total_all = 0
local total_games = 0
local total_homebrews = 0
local total_favorites = 0
local curTotal = 1

local temp_import = false

-- Settings
local startCategory = 1
local setReflections = 1
local setSounds = 1
local setMusic = 1
local themeColor = 9 -- 0 blue, 1 red, 2 yellow, 3 green, 4 grey, 5 black, 6 purple, 7 darkpurple, 8 orange, 9 dark grey
local menuItems = 3
local setBackground = 1
local setLanguage = 0

local showHomebrews = 1 -- On
local startupScan = 0 -- 0 Off, 1 On
local showRecentlyPlayed = 1 -- On
local showAll = 1 -- On
local Adrenaline_roms = 5 -- All partitions
local Game_Backgrounds = 1 -- On
local setMusicShuffle = 1 -- On

local setSwap_X_O_buttons = 0 -- 0 Off
local setAdrPSButton = 0 -- 0 Menu
local showHidden = 0 -- 0 Off
local showCollections = 1 -- On
startCategory_collection = "not_set"
setTime = 0 -- 24 hour

local filterGames = 0 -- All
local showMissingCovers = 1 -- On
local smoothScrolling = 1 -- On

set2DViews = 1 -- On
setChangeViews = 1 -- On

setCRCScan = 1 -- On
download_artwork_type = 0 -- Covers
showSysApps = 1 -- On

function SaveSettings()

    local file_config = assert(io.open(cur_dir .. "/config.dat", "w"), "Failed to open config.dat")

    if file_config ~= nil then
        settings = {} 

        if startCategory >= 47 then
            Collection_CatNum = startCategory - 46
            if startCategory_collection_renamed ~= nil then
                startCategory_collection = startCategory_collection_renamed
            else
                if collection_files and collection_files[Collection_CatNum] and collection_files[Collection_CatNum].table_name ~= nil then
                    startCategory_collection = collection_files[Collection_CatNum].table_name
                else
                    startCategory_collection = "not_set"
                end

            end
        else
            startCategory_collection = "not_set"
        end

        local settings = 
        "Reflections=" .. setReflections .. " " .. 
        "\nSounds=" .. setSounds .. " " .. 
        "\nColor=" .. themeColor .. " " .. 
        "\nBackground=" .. setBackground .. " " .. 
        "\nLanguage=" .. setLanguage .. " " .. 
        "\nView=" .. showView .. " " .. 
        "\nHomebrews=" .. showHomebrews .. " " .. 
        "\nScan=" .. startupScan .. " " .. 
        "\nCategory=" .. startCategory .. " " .. 
        "\nRecent=" .. showRecentlyPlayed .. " " .. 
        "\nAll=" .. showAll .. " " .. 
        "\nAdrenaline_rom_location=" .. Adrenaline_roms .. " " .. 
        "\nGame_Backgrounds=" .. Game_Backgrounds .. " " .. 
        "\nMusic=" .. setMusic .. " " .. 
        "\nMusic_Shuffle=" .. setMusicShuffle .. " " .. 
        "\nSwap_X_O_buttons=" .. setSwap_X_O_buttons .. " " .. 
        "\nAdrenaline_PS_Button=" .. setAdrPSButton .. " " .. 
        "\nShow_hidden_games=" .. showHidden .. " " .. 
        "\nShow_collections=" .. showCollections .. " " .. 
        "\nFilter_Games=" .. filterGames .. " " .. 
        "\nShow_missing_covers=" .. showMissingCovers .. " " .. 
        "\nSmooth_scrolling=" .. smoothScrolling .. " " .. 
        "\nTwo_D_views=" .. set2DViews .. " " .. 
        "\nChange_views=" .. setChangeViews .. " " .. 
        "\nTime=" .. setTime .. " " .. 
        "\nCRC=" .. setCRCScan .. " " .. 
        "\nShow_System_Apps=" .. showSysApps .. " " .. 
        "\nStartup_Collection=" .. startCategory_collection -- MUST ALWAYS BE LAST -- the config is split into a table using number values which this setting does not have. Need to add proper ini file reading

        file_config:write(settings)
        file_config:close()

    else
    end
end

if System.doesFileExist(cur_dir .. "/config.dat") then
    local file_config = System.openFile(cur_dir .. "/config.dat", FREAD)
    local filesize = System.sizeFile(file_config)
    local str = System.readFile(file_config, filesize)
    System.closeFile(file_config)
    
    -- Convert space seperated setting numbers to values, can be 1 or more digits
    local function tovector(s)
        local settingValue = {}
        s:gsub("\n", " "):gsub('%-?%d+', function(n) settingValue[#settingValue+1] = tonumber(n) end)
        return settingValue
    end

    local settingValue = tovector(str)

    local getReflections = settingValue[1]; if getReflections ~= nil then setReflections = getReflections end
    local getSounds = settingValue[2]; if getSounds ~= nil then setSounds = getSounds end
    local getthemeColor = settingValue[3]; if getthemeColor ~= nil then themeColor = getthemeColor end
    local getBackground = settingValue[4]; if getBackground ~= nil then setBackground = getBackground end
    local getLanguage = settingValue[5]; if getLanguage ~= nil then setLanguage = getLanguage end
    local getView = settingValue[6]; if getView ~= nil then showView = getView end
    local getHomebrews = settingValue[7]; if getHomebrews ~= nil then showHomebrews = getHomebrews end
    local getStartupScan = settingValue[8]; if getStartupScan ~= nil then startupScan = getStartupScan end
    local getCategory = settingValue[9]; if getCategory ~= nil then startCategory = getCategory end
    local getRecent = settingValue[10]; if getRecent ~= nil then showRecentlyPlayed = getRecent end
    local getAll = settingValue[11]; if getAll ~= nil then showAll = getAll end
    local getAdrenaline_rom_location = settingValue[12]; if getAdrenaline_rom_location ~= nil then Adrenaline_roms = getAdrenaline_rom_location end
    local getGame_Backgrounds = settingValue[13]; if getGame_Backgrounds ~= nil then Game_Backgrounds = getGame_Backgrounds end
    local getMusic = settingValue[14]; if getMusic ~= nil then setMusic = getMusic end
    local getMusicShuffle = settingValue[15]; if getMusicShuffle ~= nil then setMusicShuffle = getMusicShuffle end
    local getSwap_X_O_buttons = settingValue[16]; if getSwap_X_O_buttons ~= nil then setSwap_X_O_buttons = getSwap_X_O_buttons end
    local getAdrPSButton = settingValue[17]; if getAdrPSButton ~= nil then setAdrPSButton = getAdrPSButton end
    local getHidden = settingValue[18]; if getHidden ~= nil then showHidden = getHidden end
    local getCollections = settingValue[19]; if getCollections ~= nil then showCollections = getCollections end
    local getFilterGames = settingValue[20]; if getFilterGames ~= nil then filterGames = getFilterGames end
    local getshowMissingCovers = settingValue[21]; if getshowMissingCovers ~= nil then showMissingCovers = getshowMissingCovers end
    local getsmoothScrolling = settingValue[22]; if getsmoothScrolling ~= nil then smoothScrolling = getsmoothScrolling end
    local get2DViews = settingValue[23]; if get2DViews ~= nil then set2DViews = get2DViews end
    local getChangeViews = settingValue[24]; if getChangeViews ~= nil then setChangeViews = getChangeViews end
    local getTime = settingValue[25]; if getTime ~= nil then setTime = getTime end
    local getCRCScan = settingValue[26]; if getCRCScan ~= nil then setCRCScan = getCRCScan end
    local getShowSysApps = settingValue[27]; if getShowSysApps ~= nil then showSysApps = getShowSysApps end
    -- settingValue[26] is startup collection 

    selectedwall = setBackground


    -- Get startup collection table name
    if string.match(str, "Startup_Collection=Collection_") then
        str_minus_preceding_setting = str:match("Startup_Collection..+$")
        startCategory_collection = str_minus_preceding_setting:gsub("Startup_Collection=", ""):gsub(" /n..+", "")
    end


else

    -- Get language number from Vita OS and to translation file number
    if      System.getLanguage() == 0  then setLanguage = 9  -- Japanese
    elseif  System.getLanguage() == 1  then setLanguage = 1  -- English (United States)
    elseif  System.getLanguage() == 2  then setLanguage = 3  -- French
    elseif  System.getLanguage() == 3  then setLanguage = 5  -- Spanish
    elseif  System.getLanguage() == 4  then setLanguage = 2  -- German
    elseif  System.getLanguage() == 5  then setLanguage = 4  -- Italian
    elseif  System.getLanguage() == 6  then setLanguage = 12 -- Dutch
    elseif  System.getLanguage() == 7  then setLanguage = 6  -- Portuguese (Portugal)
    elseif  System.getLanguage() == 8  then setLanguage = 8  -- Russian
    elseif  System.getLanguage() == 9  then setLanguage = 17 -- Korean
    elseif  System.getLanguage() == 10 then setLanguage = 10 -- Chinese (Traditional)
    elseif  System.getLanguage() == 11 then setLanguage = 18 -- Chinese (Simplified)
    elseif  System.getLanguage() == 12 then setLanguage = 15 -- Finnish
    elseif  System.getLanguage() == 13 then setLanguage = 7  -- Swedish
    elseif  System.getLanguage() == 14 then setLanguage = 13 -- Danish
    elseif  System.getLanguage() == 15 then setLanguage = 14 -- Norwegian
    elseif  System.getLanguage() == 16 then setLanguage = 11 -- Polski
    elseif  System.getLanguage() == 17 then setLanguage = 21 -- Portuguese (Brasil)
    elseif  System.getLanguage() == 18 then setLanguage = 0  -- English (United Kingdom)
    elseif  System.getLanguage() == 19 then setLanguage = 16 -- Turkish
    elseif  System.getLanguage() == 20 then setLanguage = 5  -- Spanish (Latin America)
    else setLanguage = 0
    end

    SaveSettings()
end

-- Legacy fix - Languages got added bit by bit and were out of logical order.
    --These two lookups allow the menu to be reordered without affecting people's config files

    -- Language - Lookup 'set language' and cross reference to set the choose language menu
    function xchooseLanguageLookup(setLanguage)
        if     setLanguage == 1     then return 3  -- English (United States)
        elseif setLanguage == 2     then return 1  -- Deutsch - German
        elseif setLanguage == 3     then return 5  -- French
        elseif setLanguage == 4     then return 6  -- Italian
        elseif setLanguage == 5     then return 4  -- Spanish
        elseif setLanguage == 6     then return 12 -- Portuguese (Portugal)
        elseif setLanguage == 7     then return 15 -- Swedish
        elseif setLanguage == 8     then return 13 -- Russian
        elseif setLanguage == 9     then return 17 -- Japanese
        elseif setLanguage == 10    then return 21 -- Chinese (Traditional)
        elseif setLanguage == 11    then return 10 -- Polski
        elseif setLanguage == 12    then return 8  -- Dutch
        elseif setLanguage == 13    then return 0  -- Danish
        elseif setLanguage == 14    then return 9  -- Norwegian
        elseif setLanguage == 15    then return 14 -- Finnish
        elseif setLanguage == 16    then return 16 -- Turkish
        elseif setLanguage == 17    then return 19 -- Korean
        elseif setLanguage == 18    then return 20 -- Chinese (Simplified)
        elseif setLanguage == 19    then return 18 -- Japanese (Ryukyuan)
        elseif setLanguage == 20    then return 7  -- Hungarian
        elseif setLanguage == 21    then return 11 -- Portuguese (Brasil)
        else                             return 2  -- English (United Kingdom)
        end
    end


    -- Language - Lookup 'choose language menu' and cross reference to set the language number
    -- Alphabetical order
    function xsetLanguageLookup(chooseLanguage)
        if     chooseLanguage == 1  then return 2  -- Deutsch - German
        elseif chooseLanguage == 2  then return 0  -- English (United Kingdom)
        elseif chooseLanguage == 3  then return 1  -- English (United States)
        elseif chooseLanguage == 4  then return 5  -- Español - Spanish
        elseif chooseLanguage == 5  then return 3  -- Français - French
        elseif chooseLanguage == 6  then return 4  -- Italiano - Italian
        elseif chooseLanguage == 7  then return 20 -- Magyar - Hungarian
        elseif chooseLanguage == 8  then return 12 -- Nederlands - Dutch
        elseif chooseLanguage == 9  then return 14 -- Norsk - Norwegian
        elseif chooseLanguage == 10 then return 11 -- Polski - Polish
        elseif chooseLanguage == 11 then return 21 -- Portuguese (Brasil)
        elseif chooseLanguage == 12 then return 6  -- Portuguese (Portgual)
        elseif chooseLanguage == 13 then return 8  -- Pусский - Russian
        elseif chooseLanguage == 14 then return 15 -- Suomi - Finnish
        elseif chooseLanguage == 15 then return 7  -- Svenska - Swedish
        elseif chooseLanguage == 16 then return 16 -- Türkçe - Turkish
        elseif chooseLanguage == 17 then return 9  -- 日本語 - Japanese
        elseif chooseLanguage == 18 then return 19 -- 琉球語派 - Japanese (Ryukyuan)
        elseif chooseLanguage == 19 then return 17 -- 한국어 - Korean
        elseif chooseLanguage == 20 then return 18 -- 简体中文 - Chinese (Simplified)
        elseif chooseLanguage == 21 then return 10 -- 繁體中文 - Chinese (Traditional)
        else                             return 13 -- Dansk - Danish
        end
    end

-- Language - Lookup 'set language' and cross reference to set the choose language menu
local chooseLanguage = 0
chooseLanguage = xchooseLanguageLookup(setLanguage)

-- Check if the get info screen needs to be wider for long translations
local wide_getinfoscreen = false
-- French, Hungarian
if setLanguage == 3 or setLanguage == 20 then
    wide_getinfoscreen = true
else
    wide_getinfoscreen = false
end


-- Check for PSP and PSX titles for scanning
if not System.doesFileExist("ux0:/data/RetroFlow/TITLES/sfo_scan_isos.lua") then
    -- Launch Onelua bin to scan titles
    System.launchEboot("app0:/launch_scan.bin")
end


collection_files_start_match = 0

if #collection_files > 0 then
    for i, file in pairs (collection_files) do
        if string.match(file.table_name, startCategory_collection) then
            collection_files_start_match = i
        else
        end
    end

else
end

if collection_files_start_match > 0 then
    showCat = 46 + collection_files_start_match
    startCategory = syscount + collection_files_start_match
else
    showCat = startCategory
end

-- Music - Legacy Fix - Move music files from old directory to new
if System.doesFileExist("ux0:/data/RetroFlow/Music.ogg") then System.rename("ux0:/data/RetroFlow/Music.ogg", "ux0:/data/RetroFlow/MUSIC/Music.ogg") end

-- Music - Scan Music Directory
music_dir = System.listDirectory("ux0:/data/RetroFlow/MUSIC/")

-- Music - Add to music tracks if ogg
music_sequential = {}
for i, file in pairs(music_dir) do
    if not file.directory then
        if string.match(file.name, "%.ogg") then
            file.name = file.name
            table.insert(music_sequential, file)
        end
    else
    end
end

-- Music - Shuffle

-- local track = 1
-- local music_shuffled = {}



function Shuffle(music_sequential)
    math.randomseed( os.time() )
    music_shuffled = {}
    for i = 1, #music_sequential do music_shuffled[i] = music_sequential[i] end
    for i = #music_sequential, 2, -1 do
        local j = math.random(i)
        music_shuffled[i], music_shuffled[j] = music_shuffled[j], music_shuffled[i]
    end
    return music_shuffled
end

-- Music -  
function PlayMusic()

    -- How many tracks?

    -- Just 1 - loop
    if #music_sequential == 1 then
        if System.doesFileExist(cur_dir .. "/MUSIC/" .. music_sequential[track].name) then
            sndMusic = Sound.open(cur_dir .. "/MUSIC/" .. music_sequential[track].name)
            Sound.play(sndMusic, true) -- Loop as only 1 song
        end

    -- More than 1 - don't loop, change track
    elseif #music_sequential > 1 then

        -- Suffle is on
        if setMusicShuffle == 1 then
            
            -- If reached end, go back to track 1
            if track > #music_shuffled then
                track = 1
            end
            if System.doesFileExist(cur_dir .. "/MUSIC/" .. music_shuffled[track].name) then
                sndMusic = Sound.open(cur_dir .. "/MUSIC/" .. music_shuffled[track].name)
                Sound.play(sndMusic, false) -- Don't loop
            end

        -- Suffle is off
        else
            -- If reached end, go back to track 1
            if track > #music_sequential then
                track = 1
            end
            if System.doesFileExist(cur_dir .. "/MUSIC/" .. music_sequential[track].name) then
                sndMusic = Sound.open(cur_dir .. "/MUSIC/" .. music_sequential[track].name)
                Sound.play(sndMusic, false) -- Don't loop
            end
        end
    else

    -- No tracks - do nothing
    end

end

-- Music -  Play if enabled   
if setMusic == 1 then
    if setMusicShuffle == 1 then
        Shuffle(music_sequential)
    else
    end
    track = 1
    PlayMusic()
end


function SetThemeColor()
    if themeColor == 1 then
        themeCol = red
    elseif themeColor == 2 then
        themeCol = yellow
    elseif themeColor == 3 then
        themeCol = green
    elseif themeColor == 4 then
        themeCol = lightgrey
    elseif themeColor == 5 then
        themeCol = black
    elseif themeColor == 6 then
        themeCol = purple
    elseif themeColor == 7 then
        themeCol = darkpurple
    elseif themeColor == 8 then
        themeCol = orange
    elseif themeColor == 9 then
        themeCol = darkgrey
    else
        themeCol = blue -- default blue
    end
end
SetThemeColor()


-- Speed related settings
local cpu_speed = 444 -- Was 333
System.setBusSpeed(222)
System.setGpuSpeed(222)
System.setGpuXbarSpeed(166)
System.setCpuSpeed(cpu_speed)

function OneshotPrint(my_func)
    my_func()
    Screen.flip()
    my_func()
    Screen.flip()
    my_func()
end

local lang_lines = {}
local lang_default = 
{
-- Footer
["Settings"] = "Settings",
["Launch"] = "Launch",
["Details"] = "Details",
["Category"] = "Category",
["View"] = "View",
["Close"] = "Close",
["Select"] = "Select",
["About"] = "About",

-- General settings
["Language_colon"] = "Language: ",
["Homebrews_Category_colon"] = "Homebrews Category: ",
["System_Apps_colon"] = "System Apps: ",
["Recently_Played_colon"] = "Recently Played: ",
["Startup_scan_colon"] = "Startup scan: ",
["On"] = "On",
["Off"] = "Off",

-- Appearance
["Custom_Background_colon"] = "Custom Background: ",
["Reflection_Effect_colon"] = "Reflection Effect: ",
["Smooth_Scrolling_colon"] = "Smooth Scrolling: ",
["Theme_Color_colon"] = "Theme Color: ",
["Red"] = "Red",
["Yellow"] = "Yellow",
["Green"] = "Green",
["Grey"] = "Grey",
["Dark_Grey"] = "Dark Grey",
["Black"] = "Black",
["Purple"] = "Purple",
["Dark_Purple"] = "Dark Purple",
["Orange"] = "Orange",
["Blue"] = "Blue",
["Views_2D_colon"] = "2D Views: ",
["Change_Views_colon"] = "Change Views: ",

-- Audio
["Audio"] = "Audio",
["Sounds_colon"] = "Sounds: ",
["Music_colon"] = "Music: ",
["Shuffle_music_colon"] = "Shuffle music: ",
["Skip_track"] = "Skip track",

-- Startup Categories
["Startup_Category_colon"] = "Startup Category: ",
["Favorites"] = "Favorites",
["Recently_Played"] = "Recently Played",
["PS_Vita"] = "PS Vita",
["Homebrews"] = "Homebrews",
["PSP"] = "PSP",
["PlayStation"] = "PlayStation",
["Nintendo_64"] = "Nintendo 64",
["Super_Nintendo"] = "Super Nintendo",
["Nintendo_Entertainment_System"] = "Nintendo Entertainment System",
["Nintendo_DS"] = "Nintendo DS",
["Game_Boy_Advance"] = "Game Boy Advance",
["Game_Boy_Color"] = "Game Boy Color",
["Game_Boy"] = "Game Boy",
["Sega_Dreamcast"] = "Sega Dreamcast",
["Sega_Mega_Drive"] = "Sega Mega Drive",
["Sega_Master_System"] = "Sega Master System",
["Sega_Game_Gear"] = "Sega Game Gear",
["MAME_2000"] = "MAME 2000",
["Amiga"] = "Amiga",
["TurboGrafx_16"] = "TurboGrafx-16",
["TurboGrafx_CD"] = "TurboGrafx-CD",
["PC_Engine"] = "PC Engine",
["PC_Engine_CD"] = "PC Engine CD",
["Neo_Geo_Pocket_Color"] = "Neo Geo Pocket Color",
["Playstation_Mobile"] = "Playstation Mobile",
["Sega_CD"] = "Sega CD",
["Sega_32X"] = "Sega 32X",
["Commodore_64"] = "Commodore 64",
["WonderSwan_Color"] = "WonderSwan Color",
["WonderSwan"] = "WonderSwan",
["MSX2"] = "MSX2",
["MSX"] = "MSX",
["ZX_Spectrum"] = "ZX Spectrum",
["Atari_7800"] = "Atari 7800",
["Atari_5200"] = "Atari 5200",
["Atari_2600"] = "Atari 2600",
["Atari_Lynx"] = "Atari Lynx",
["ColecoVision"] = "ColecoVision",
["Vectrex"] = "Vectrex",
["FBA_2012"] = "FBA 2012",
["MAME_2003Plus"] = "MAME 2003 Plus",
["Neo_Geo"] = "Neo Geo",
["ScummVM"] = "ScummVM",
["PICO8"] = "PICO-8",
["System_Apps"] = "System Apps",

-- Download
["Download_colon"] = "Download:",
["Covers"] = "Covers",
["Backgrounds"] = "Backgrounds",
["Download_using_CRC_colon"] = "Download using CRC:",
["Extract_PS_Vita_backgrounds"] = "Extract PS Vita backgrounds",
["Extract_PSP_backgrounds"] = "Extract PSP backgrounds",
["Extract_PICO8_backgrounds"] = "Extract PICO-8 backgrounds",

["All"] = "All",
["Internet_Connection_Required"] = "Internet Connection Required",
["Cover"] = "Cover",
["Background"] = "Background",

["Found"] = "Found",
["found_exclamation"] = "found!",
["Cover_not_found"] = "Cover not found",
["Background_not_found"] = "Background not found",
["of"] = " of ",

["Download_colon"] = "Download:",
["Backgrounds"] = "Backgrounds",
["Covers"] = "Covers",

["Downloading_covers"] = "Downloading covers",
["Downloading_backgrounds"] = "Downloading backgrounds",

["No_missing_artwork"] = "No missing artwork",

-- Info Screen
["App_ID_colon"] = "App ID: ",
["Size_colon"] = "Size: ",
["Version_colon"] = "Version: ",
["Download_Cover"] = "Download Cover",
["Download_Background"] = "Download Background",
["Override_Category_colon"] = "Override Category: ",
["Press_X_to_apply_Category"] = "Press X to apply Category",
["Press_O_to_apply_Category"] = "Press O to apply Category",
["Default"] = "Default",
["Favorite"] = "Favorite",
["Rename"] = "Rename",
["PS_Vita_Game"] = "PS Vita Game",
["Homebrew"] = "Homebrew",
["PSP_Game"] = "PSP Game",
["PS1_Game"] = "PlayStation Game",
["N64_Game"] = "Nintendo 64 Game",
["SNES_Game"] = "Super Nintendo Game",
["NES_Game"] = "Nintendo Entertainment System Game",
["NDS_Game"] = "Nintendo DS Game",
["GBA_Game"] = "Game Boy Advance Game",
["GBC_Game"] = "Game Boy Color Game",
["GB_Game"] = "Game Boy Game",
["DC_Game"] = "Sega Dreamcast Game",
["MD_Game"] = "Sega Mega Drive Game",
["SMS_Game"] = "Sega Master System Game",
["GG_Game"] = "Sega Game Gear Game",
["MAME_2000_Game"] = "MAME 2000 Game",
["Amiga_Game"] = "Amiga Game",
["TurboGrafx_16_Game"] = "TurboGrafx-16 Game",
["TurboGrafx_CD_Game"] = "TurboGrafx-CD Game",
["PC_Engine_Game"] = "PC Engine Game",
["PC_Engine_CD_Game"] = "PC Engine CD Game",
["Neo_Geo_Pocket_Color_Game"] = "Neo Geo Pocket Color Game",
["Playstation_Mobile_Game"] = "Playstation Mobile Game",
["SCD_Game"] = "Sega CD Game",
["S32X_Game"] = "Sega 32X Game",
["C64_Game"] = "Commodore 64 Game",
["WSWANCOL_Game"] = "WonderSwan Color Game",
["WSWAN_Game"] = "WonderSwan Game",
["MSX2_Game"] = "MSX2 Game",
["MSX_Game"] = "MSX Game",
["ZXS_Game"] = "ZX Spectrum Game",
["A7800_Game"] = "Atari 7800 Game",
["A5200_Game"] = "Atari 5200 Game",
["A600_Game"] = "Atari 600 Game",
["LYNX_Game"] = "Atari Lynx Game",
["COLECO_Game"] = "ColecoVision Game",
["VECTREX_Game"] = "Vectrex Game",
["FBA2012_Game"] = "FBA 2012 Game",
["MAME2003_Game"] = "MAME 2003 Plus Game",
["Neo_Geo_Game"] = "Neo Geo Game",
["ScummVM_Game"] = "ScummVM Game",
["PICO8_Game"] = "PICO-8 Game",
["System_App"] = "System App",

-- Missing launcher message
["Please_install_RetroFlow_Adrenaline_Launcher"] = "Please install RetroFlow Adrenaline Launcher.",
["The_VPK_is_saved_here"] = "The VPK is saved here",

-- Search
["Search"] = "Search",
["Search_Results"] = "Search Results",
["Search_No_Results"] = "Press select to search again",

-- Random game
["Random_Game"] = "Random Game",

-- Settings Menu
["Categories"] = "Categories",
["Sounds"] = "Sounds",
["Artwork"] = "Artwork",
["Scan_Settings"] = "Scan Settings",
["Adrenaline_roms"] = "Adrenaline games: ",
["All_Category"] = "All Category: ",
["Back_Chevron"] = "<  Back",
["Theme"] = "Theme",
["Game_backgounds_colon"] = "Game Backgrounds: ",

-- Game directories
["Home"] = "Home",
["Directory_not_found"] = "Directory not found",
["Edit_game_directories"] = "Edit game directories...",
["Game_directories"] = "Game directories",
["Use_this_directory"] = "Use this directory",
["Rescan"] = "Rescan",
["Back"] = "Back",

-- Scan progress
["Scanning_titles"] = "Scanning titles...",
["Scanning_games_ellipsis"] = "Scanning games...",
["Scan_complete"] = "Scan complete",
["Reloading_ellipsis"] = "Reloading...",

-- Guides
["Help_and_Guides"] = "Help",

["guide_1_heading"] = "Adding games",
["guide_1_content"] = "Game directories: \nPlace your games in 'ux0:/data/RetroFlow/ROMS/', or to use your own file directories, go to 'Scan Settings' then 'Edit game directories'. \n\nOnce you have added your games, select 'Rescan' to add them to RetroFlow. \n\nFilenames: \nIt's important that your games are named using the 'no-intro' file naming convention, e.g. 'Sonic (USA)', otherwise images won't be downloaded.",

["guide_2_heading"] = "Adrenaline games not loading?",
["guide_2_content"] = "If Adrenaline games aren't loading and you have installed the RetroFlow Adrenaline Launcher, please install AdrBubbleBooterInstaller: https://vitadb.rinnegatamante.it/#/info/307. \n\nOr try installing Adrenaline Bubble Manager: https://github.com/ONElua/AdrenalineBubbleManager/releases/",

["guide_3_heading"] = "Custom game covers & backgrounds",
["guide_3_content"] = "Covers: \nCustom covers can be saved in the game folders here: 'ux0:/data/RetroFlow/COVERS/'. \n\nBackgounds: \nCustom game backgrounds can be saved in the game folders here: 'ux0:/data/RetroFlow/BACKGROUNDS/'. \n\nFilenames:\nThe filename must match the App ID or the App Name Images must be in .png format.",

["guide_4_heading"] = "Custom wallpaper & music",
["guide_4_content"] = "Wallpaper: \nYou can add as many wallpapers as you like by saving them here: 'ux0:/data/RetroFlow/WALLPAPER/'. \nImages must be in .jpg or .png format and the size should be 960px x 544px. \n\nMusic: \nSongs can be added to 'ux0:/data/RetroFlow/MUSIC/'. \nMusic must be in .ogg format.",

["guide_5_heading"] = "Control shortcuts",
["guide_5_content"] = "DPad Up: Skip to favourites category \n\nDPad Down + Square: Go back one category \n\nDPad Down + L/R triggers: Skip games alphabetically",

["guide_6_heading"] = "About",
["guide_6_content"] = "RetroFlow by jimbob4000 is a modified version of the HexFlow app. \n\nThe originalHexFlow app is by VitaHex. Support VitaHex's projects on patreon.com/vitahex \n\nMore information:\nFor more information and full credits, please visit: https://github.com/jimbob4000/RetroFlow-Launcher",

-- Other Settings
["Other_Settings"] = "Other Settings",
["Swap_X_and_O_buttons_colon"] = "Swap X and O buttons: ",
["Adrenaline_PS_button_colon"] = "Adrenaline PS button:",
["Menu"] = "Menu",
["LiveArea"] = "LiveArea",
["Standard"] = "Standard",
["Show_missing_covers_colon"] = "Show missing covers:",
["Time_colon"] = "Time:",
["Time_12hr"] = "12-Hour Clock",
["Time_24hr"] = "24-Hour Clock",

-- Game options
["Options"] = "Options",
["Adrenaline_options"] = "Adrenaline options",
["Driver_colon"] = "Driver: ",
["Execute_colon"] = "Execute: ",
["Plugins_colon"] = "Plugins: ",
["CPU_speed_colon"] = "CPU speed: ",
["High_memory_colon"] = "High memory: ",
["NoDRM_engine_colon"] = "NoDRM engine: ",
["Suspend_threads_colon"] = "Suspend threads: ",
["Enable"] = "Enable",
["Disable"] = "Disable",
["Yes"] = "Yes",
["No"] = "No",
["Save"] = "Save",
["Add_to_favorites"] = "Add to favorites",
["Remove_from_favorites"] = "Remove from favorites",
["Show_hidden_games_colon"] = "Show hidden games:",
["Hide_game"] = "Hide game",
["Unhide_game"] = "Unhide game",
["Remove_from_recently_played"] = "Remove from recently played",
["Retroarch_options"] = "RetroArch options",
["Core_colon"] = "Core:",
["Configure_game_in_DSVita"] = "Configure game in DSVita",

-- Collections
["Collections"] = "Collections",
["Collections_colon"] = "Collections:",
["Add_to_collection"] = "Add to collection",
["New_collection"] = "New collection",
["New_collection_name"] = "New collection name",
["Create"] = "Create",
["Remove_from_collection"] = "Remove from collection",
["No_collections"] = "No collections",
["Delete"] = "Delete",
["Edit_collections"] = "Edit collections",
["Show_collections_colon"] = "Show collections:",
["Customise_game_order"] = "Customise game order",

-- Adrenaline install assets
["RETROLNCR_Install"] = "Installing RetroFlow Adrenaline Launcher vpk...",
["RETROLNCR_Installed"] = "RetroFlow Adrenaline Launcher has been installed.",
["ABB_Install"] = "Installing AdrBubbleBooter plugin...",
["ABB_Installed"] = "AdrBubbleBooter plugin has been installed...",
["ABB_Restart"] = "We need to restart your PS Vita.",
["Restart_Now"] = "Restart Now",
["Restart_Later"] = "Restart Later",

-- Launch messages
["Emulator_not_installed_Adrenaline"] = "You need to install Adrenaline to play this game.",
["Emulator_not_installed_ScummVM"] = "You need to install the ScummVM to play this game.",
["Emulator_not_installed_Pico8"] = "You need to install FAKE-08 to play this game.",
["Emulator_not_installed_Retroarch"] = "You need to install RetroArch to play this game.",
["Emulator_not_installed_DaedalusX64"] = "You need to install DaedalusX64 to play this game.",
["Emulator_not_installed_Flycast"] = "You need to install Flycast to play this game.",
["Emulator_not_installed_DSVita"] = "You need to install DSVita to play this game.",
["Game_not_installed_rescan"] = "This game is not installed, please rescan your games.",

}

-- Define fonts for languages
font_default =                "font-SawarabiGothic-Regular.woff"
font_korean =                 "font-NotoSansCJKkr-Regular-Slim.otf"
font_chinese_simplified =     "font-NotoSansCJKsc-Regular-Slim.otf"
font_chinese_traditional =    "font-NotoSansCJKtc-Regular.otf"



function ChangeFont(new_font)
    if fontname ~= (new_font) then 

        -- Load Standard font
        fontname = (new_font) 
        fnt20 = Font.load("app0:/DATA/" .. (new_font))
        fnt22 = Font.load("app0:/DATA/" .. (new_font))
        fnt25 = Font.load("app0:/DATA/" .. (new_font))

        Font.setPixelSizes(fnt20, 20)
        Font.setPixelSizes(fnt22, 22)
        Font.setPixelSizes(fnt25, 25)

    end
end


function TableConcat(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end


-- GET WALLPAPER - START

-- Add default: workaround hack as game backgrounds only show if setBackground is not 0
wallpaper_table_default =
{
    [1] = 
    {
        ["filename"] = "BG_Default.png",
        ["wallpaper_string"] = lang_lines.Off,
        ["wallpaper_path"] = "app0:/DATA/BG_Default.png",
    },
}

-- Scan wallpaper folder for settings
local wallpaper_table_scanned = {}
files_wallpaper = System.listDirectory("ux0:/data/RetroFlow/WALLPAPER/")
for i, file in pairs(files_wallpaper) do
    if not file.directory then
        if string.match(file.name, "%.png") or string.match(file.name, "%.jpg") then
            wallpaper_name_noExtension = file.name:match("(.+)%..+$")
            -- wallpaper_name_noExtension = file.name
            file.filename = file.name
            file.wallpaper_string = wallpaper_name_noExtension
            file.wallpaper_path = "ux0:/data/RetroFlow/WALLPAPER/" .. file.name
            table.insert(wallpaper_table_scanned, file)
        end
    end
end
table.sort(wallpaper_table_scanned, function(a, b) return (a.filename:lower() < b.filename:lower()) end)

-- Combine default and scanned, so default is number 1
local wallpaper_table_settings = {}
wallpaper_table_settings = TableConcat(wallpaper_table_default, wallpaper_table_scanned)

-- GET WALLPAPER - END


-- Custom Background

-- If setting is for a deleted wallpaper, set to default
if selectedwall == nil then
    selectedwall = 1
end

if selectedwall > #wallpaper_table_settings then
    setBackground = 1
    SaveSettings()
end

local imgCustomBack = imgBack
if selectedwall == 0 or selectedwall > #wallpaper_table_settings then
else
    local selected_wallpaper_path = tostring(wallpaper_table_settings[selectedwall].wallpaper_path)
    if selected_wallpaper_path == nil then
        setBackground = 0
        SaveSettings()
    else
        if System.doesFileExist(wallpaper_table_settings[selectedwall].wallpaper_path) then
            imgCustomBack = Graphics.loadImage(wallpaper_table_settings[selectedwall].wallpaper_path)
            -- Graphics.setImageFilters(imgCustomBack, FILTER_LINEAR, FILTER_LINEAR)
            Render.useTexture(modBackground, imgCustomBack)
        end
    end
end


function ChangeLanguage(def)

    setLanguage = (def)
    if #lang_lines>0 then
        for k in pairs (lang_lines) do
            lang_lines [k] = nil
        end
    end

    lang = "EN.lua"
    if setLanguage == 1 then
        lang = "EN_USA.lua"
        ChangeFont(font_default)
    elseif setLanguage == 2 then
        lang = "DE.lua"
        ChangeFont(font_default)
    elseif setLanguage == 3 then
        lang = "FR.lua"
        ChangeFont(font_default)
    elseif setLanguage == 4 then
        lang = "IT.lua"
        ChangeFont(font_default)
    elseif setLanguage == 5 then
        lang = "SP.lua"
        ChangeFont(font_default)
    elseif setLanguage == 6 then
        lang = "PT.lua"
        ChangeFont(font_default)
    elseif setLanguage == 7 then
        lang = "SW.lua"
        ChangeFont(font_default)
    elseif setLanguage == 8 then
        lang = "RU.lua"
        ChangeFont(font_default)
    elseif setLanguage == 9 then
        lang = "JA.lua"
        ChangeFont(font_default)
    elseif setLanguage == 10 then
        lang = "CN_T.lua"
        ChangeFont(font_chinese_traditional)
    elseif setLanguage == 11 then
        lang = "PL.lua"
        ChangeFont(font_default)
    elseif setLanguage == 12 then
        lang = "NL.lua"
        ChangeFont(font_default)
    elseif setLanguage == 13 then
        lang = "DA.lua"
        ChangeFont(font_default)
    elseif setLanguage == 14 then
        lang = "NO.lua"
        ChangeFont(font_default)
    elseif setLanguage == 15 then
        lang = "FI.lua"
        ChangeFont(font_default)
    elseif setLanguage == 16 then
        lang = "TR.lua"
        ChangeFont(font_default)
    elseif setLanguage == 17 then
        lang = "KO.lua"
        ChangeFont(font_korean)
    elseif setLanguage == 18 then
        lang = "CN_S.lua"
        ChangeFont(font_chinese_simplified)
    elseif setLanguage == 19 then
        lang = "JA_ryu.lua"
        ChangeFont(font_default)
    elseif setLanguage == 20 then
        lang = "HU.lua"
        ChangeFont(font_default)
    elseif setLanguage == 21 then
        lang = "PT_BR.lua"
        ChangeFont(font_default)
    else
        lang = "EN.lua"
        ChangeFont(font_default)
    end
    
    -- Import lang file
    if System.doesFileExist("app0:/translations/" .. lang) then
        langfile = {}
        langfile = "app0:/translations/" .. lang
        -- lang_lines = {}
        lang_lines = dofile(langfile)
    else
        -- If missing use default EN table
        lang_lines = lang_default
    end

    if setLanguage == 2 or setLanguage == 3 or setLanguage == 6 or setLanguage == 8 or setLanguage == 9 or setLanguage == 12 or setLanguage == 16 or setLanguage == 19 or setLanguage == 21 then
    -- German, French, Portugeuse, Russian, Japanese, Turkish, Dutch, Japanese (Ryukyuan) language fix, Portuguese (Brasil)
        setting_x_offset = 460
    else
        -- setting_x_offset = 365
        setting_x_offset = 400
    end

    -- Update wallpaper table string for 'Off'
    wallpaper_table_settings[1].wallpaper_string = lang_lines.Off

    -- Check if the get info screen needs to be wider for long translations
    -- French, Hungarian
    if setLanguage == 3 or setLanguage == 20 then
        wide_getinfoscreen = true
    else
        wide_getinfoscreen = false
    end

end


ChangeLanguage(xsetLanguageLookup(chooseLanguage))


function Swap_X_O_buttons()
    if setSwap_X_O_buttons == 1 then 
        -- Swap buttons is - On

        -- Update buttons
        SCE_CTRL_CROSS_MAP = SCE_CTRL_CIRCLE
        SCE_CTRL_CIRCLE_MAP = SCE_CTRL_CROSS

        -- Swap images
        btnO = Graphics.loadImage("app0:/DATA/x.png")
        btnX = Graphics.loadImage("app0:/DATA/o.png")
    else 
        -- Swap buttons is - Off

        -- Update buttons
        SCE_CTRL_CROSS_MAP = SCE_CTRL_CROSS
        SCE_CTRL_CIRCLE_MAP = SCE_CTRL_CIRCLE

        -- Swap images
        btnX = Graphics.loadImage("app0:/DATA/x.png")
        btnO = Graphics.loadImage("app0:/DATA/o.png")
    end
end
Swap_X_O_buttons()


-- Check model, if PSTV battery wont be shown and affects UI elements
    local pstv = false
    local pstv_offset = 0

    model = System.getModel()
    if string.match(tostring(model), "131072") then
        pstv = true
        if Network.isWifiEnabled() then
            pstv_offset = 110
        else
            pstv_offset = 125
        end
    end

-- Check time setting to offset icons in top
    time24_offset = 0
    if setTime == 1 then
        time24_offset = 25
    end
    
-- Menu Layout
    btnMargin = 32 -- Distance between footer buttons

    -- Setting screen positions

    -- Horizontal positions
    setting_x = 78

    -- Mini menu extra margin
    mini_menu_x_margin = 60

    
    if setLanguage == 2 or setLanguage == 3 or setLanguage == 6 or setLanguage == 8 or setLanguage == 9 or setLanguage == 12 or setLanguage == 16 or setLanguage == 19 or setLanguage == 21 then
    -- German, French, Portugeuse, Russian, Japanese, Turkish, Dutch, Japanese (Ryukyuan) language fix, Portugeuse (Brasil)
        setting_x_offset = 460
    else
        -- setting_x_offset = 365
        setting_x_offset = 400
    end
    setting_x_icon = 75
    setting_x_icon_offset = 115

    -- Vertical positions
    setting_yh = 43 -- Header
    setting_y0 = 92
    setting_y1 = 139
    setting_y2 = 186
    setting_y3 = 233
    setting_y4 = 280
    setting_y5 = 327
    setting_y6 = 374
    setting_y7 = 421
    setting_y8 = 468
    setting_y_smallfont_offset = 2

function vertically_centre_mini_menu(def_menuItems)
    y_available_space = 496
    y_centre_box_height = (def_menuItems + 2) *47 + 3
    y_centre_top_margin = (y_available_space - y_centre_box_height) / 2
    y_centre_selection_start = y_centre_top_margin + 47 + 3
    y_centre_selection_end = y_centre_selection_start + 47
    y_centre_white_line_start = y_centre_top_margin + 47
    y_centre_text_offset = y_centre_top_margin - 32

    -- Round up decimals to next round number
    y_centre_box_height = math.ceil(y_centre_box_height)
    y_centre_top_margin = math.ceil(y_centre_top_margin)
    y_centre_selection_start = math.ceil(y_centre_selection_start)
    y_centre_selection_end = math.ceil(y_centre_selection_end)
    y_centre_white_line_start = math.ceil(y_centre_white_line_start)
    y_centre_text_offset = math.ceil(y_centre_text_offset)
end 

-- Message - Check if RetroFlow Adrenaline Launcher needs to be installed
    if not System.doesAppExist("RETROLNCR") then

        if Adrenaline_roms == 1 then
            adr_partition = "ux0"
        elseif Adrenaline_roms == 2 then
            adr_partition = "ur0"
        elseif Adrenaline_roms == 3 then
            adr_partition = "imc0"
        elseif Adrenaline_roms == 4 then
            adr_partition = "xmc0"
        else 
            adr_partition = "uma0"
        end
    
        if System.doesDirExist(adr_partition  .. ":/pspemu") then
            System.setMessage(lang_lines.Please_install_RetroFlow_Adrenaline_Launcher .. "\n" .. lang_lines.The_VPK_is_saved_here .. "\n\nux0:/app/RETROFLOW/payloads/\nRetroFlow Adrenaline Launcher.vpk", false, BUTTON_OK)
            --                Please install RetroFlow Adrenaline Launcher.     The VPK is saved here:
        else
        end
    end


function PrintCentered(font, x, y, text, color, size)
    text = text:gsub("\n","")
    local width = Font.getTextWidth(font,text)
    Font.print(font, x - width / 2, y, text, color)
end


function FreeMemory()
    if setMusic == 1 then
        if #music_sequential > 1 then
            Sound.close(sndMusic)
        elseif #music_sequential == 1 then
            Sound.close(sndMusic)
        end
    end
    Sound.close(click)
    Graphics.freeImage(imgCoverTmp)
    Graphics.freeImage(btnX)
    Graphics.freeImage(btnT)
    Graphics.freeImage(btnS)
    Graphics.freeImage(btnO)
    Graphics.freeImage(imgWifi)
    Graphics.freeImage(imgBack)
    Graphics.freeImage(imgBattery)
    Graphics.freeImage(imgBatteryCharging)
    Graphics.freeImage(imgBox)
    Graphics.freeImage(imgFavorite_small_on)
    Graphics.freeImage(imgFavorite_large_on)
    Graphics.freeImage(imgFavorite_large_off)
    Graphics.freeImage(imgHidden_large_on)
    Graphics.freeImage(imgHidden_small_on)
    Graphics.freeImage(setting_icon_theme)
    Graphics.freeImage(setting_icon_artwork)
    Graphics.freeImage(setting_icon_categories)
    Graphics.freeImage(setting_icon_language)
    Graphics.freeImage(setting_icon_scanning)
    Graphics.freeImage(setting_icon_search)
    Graphics.freeImage(setting_icon_sounds)
    Graphics.freeImage(setting_icon_about)
    Graphics.freeImage(setting_icon_other)
    Graphics.freeImage(file_browser_folder_open)
    Graphics.freeImage(file_browser_folder_closed)
    Graphics.freeImage(file_browser_file)
    Graphics.freeImage(footer_gradient)
    Graphics.freeImage(setting_icon_sort)
    Graphics.freeImage(setting_icon_sort_up)
    Graphics.freeImage(setting_icon_sort_down)
end


function xCatLookup(CatNum)  -- Credit to BlackSheepBoy69 - CatNum = Showcat
    if CatNum == 1 then         return  games_table
    elseif CatNum == 2 then     return  homebrews_table
    elseif CatNum == 3 then     return  psp_table
    elseif CatNum == 4 then     return  psx_table
    elseif CatNum == 5 then     return  psm_table
    elseif CatNum == 6 then     return  n64_table
    elseif CatNum == 7 then     return  snes_table
    elseif CatNum == 8 then     return  nes_table
    elseif CatNum == 9 then     return  nds_table
    elseif CatNum == 10 then    return  gba_table
    elseif CatNum == 11 then    return  gbc_table
    elseif CatNum == 12 then    return  gb_table
    elseif CatNum == 13 then    return  dreamcast_table
    elseif CatNum == 14 then    return  sega_cd_table
    elseif CatNum == 15 then    return  s32x_table
    elseif CatNum == 16 then    return  md_table
    elseif CatNum == 17 then    return  sms_table
    elseif CatNum == 18 then    return  gg_table
    elseif CatNum == 19 then    return  tg16_table
    elseif CatNum == 20 then    return  tgcd_table
    elseif CatNum == 21 then    return  pce_table
    elseif CatNum == 22 then    return  pcecd_table
    elseif CatNum == 23 then    return  amiga_table
    elseif CatNum == 24 then    return  scummvm_table
    elseif CatNum == 25 then    return  c64_table
    elseif CatNum == 26 then    return  wswan_col_table
    elseif CatNum == 27 then    return  wswan_table
    elseif CatNum == 28 then    return  pico8_table
    elseif CatNum == 29 then    return  msx2_table
    elseif CatNum == 30 then    return  msx1_table
    elseif CatNum == 31 then    return  zxs_table
    elseif CatNum == 32 then    return  atari_7800_table
    elseif CatNum == 33 then    return  atari_5200_table
    elseif CatNum == 34 then    return  atari_2600_table
    elseif CatNum == 35 then    return  atari_lynx_table
    elseif CatNum == 36 then    return  colecovision_table
    elseif CatNum == 37 then    return  vectrex_table
    elseif CatNum == 38 then    return  fba_table
    elseif CatNum == 39 then    return  mame_2003_plus_table
    elseif CatNum == 40 then    return  mame_2000_table
    elseif CatNum == 41 then    return  neogeo_table
    elseif CatNum == 42 then    return  ngpc_table
    elseif CatNum == 43 then    return  sysapps_table
    elseif CatNum == 44 then    return  fav_count
    elseif CatNum == 45 then    return  recently_played_table
    elseif CatNum == 46 then    return  search_results_table -- Table also used for random game selection

    -- COLLECTIONS
    elseif CatNum >= 47 and CatNum <= collection_syscount then
        Collection_CatNum = CatNum - 46
        return _G[collection_files[Collection_CatNum].table_name]

    else             return files_table_no_sysapps -- Hide sys apps from all list
    end
end

-- COLLECTIONS
    function xCollectionTableLookup(def_num)
        Collection_CatNum = (def_num)
        return _G[collection_files[Collection_CatNum].table_name]
    end

    function check_if_game_is_in_collection_table(def_collection_number)
        local key = find_game_table_pos_key(xCollectionTableLookup((def_collection_number)), xCatLookup(showCat)[p].name)
        if key ~= nil then
            return true
        else
            return false
        end
    end


function xCatDbFileLookup(CatNum)  -- Credit to BlackSheepBoy69 - CatNum = Showcat
    if CatNum == 1 then         return  "db_games.lua"
    elseif CatNum == 2 then     return  "db_homebrews.lua"
    elseif CatNum == 3 then     return  "db_psp.lua"
    elseif CatNum == 4 then     return  "db_psx.lua"
    elseif CatNum == 5 then     return  "db_psm.lua"
    elseif CatNum == 6 then     return  "db_n64.lua"
    elseif CatNum == 7 then     return  "db_snes.lua"
    elseif CatNum == 8 then     return  "db_nes.lua"
    elseif CatNum == 9 then     return  "db_nds.lua"
    elseif CatNum == 10 then    return  "db_gba.lua"
    elseif CatNum == 11 then    return  "db_gbc.lua"
    elseif CatNum == 12 then    return  "db_gb.lua"
    elseif CatNum == 13 then    return  "db_dreamcast.lua"
    elseif CatNum == 14 then    return  "db_sega_cd.lua"
    elseif CatNum == 15 then    return  "db_32x.lua"
    elseif CatNum == 16 then    return  "db_md.lua"
    elseif CatNum == 17 then    return  "db_sms.lua"
    elseif CatNum == 18 then    return  "db_gg.lua"
    elseif CatNum == 19 then    return  "db_tg16.lua"
    elseif CatNum == 20 then    return  "db_tgcd.lua"
    elseif CatNum == 21 then    return  "db_pce.lua"
    elseif CatNum == 22 then    return  "db_pcecd.lua"
    elseif CatNum == 23 then    return  "db_amiga.lua"
    elseif CatNum == 24 then    return  "db_scummvm.lua"
    elseif CatNum == 25 then    return  "db_c64.lua"
    elseif CatNum == 26 then    return  "db_wswan_col.lua"
    elseif CatNum == 27 then    return  "db_wswan.lua"
    elseif CatNum == 28 then    return  "db_pico8.lua"
    elseif CatNum == 29 then    return  "db_msx2.lua"
    elseif CatNum == 30 then    return  "db_msx1.lua"
    elseif CatNum == 31 then    return  "db_zxs.lua"
    elseif CatNum == 32 then    return  "db_atari_7800.lua"
    elseif CatNum == 33 then    return  "db_atari_5200.lua"
    elseif CatNum == 34 then    return  "db_atari_2600.lua"
    elseif CatNum == 35 then    return  "db_atari_lynx.lua"
    elseif CatNum == 36 then    return  "db_colecovision.lua"
    elseif CatNum == 37 then    return  "db_vectrex.lua"
    elseif CatNum == 38 then    return  "db_fba.lua"
    elseif CatNum == 39 then    return  "db_mame_2003_plus.lua"
    elseif CatNum == 40 then    return  "db_mame_2000.lua"
    elseif CatNum == 41 then    return  "db_neogeo.lua"
    elseif CatNum == 42 then    return  "db_ngpc.lua"
    elseif CatNum == 43 then    return  "db_sysapps.lua"
    else
    end
    -- elseif CatNum == 44 then    return fav_count
    -- elseif CatNum == 45 then    return recently_played_table
    -- elseif CatNum == 46 then    return search_results_table

    -- -- COLLECTIONS
    -- elseif CatNum >= 47 and CatNum <= collection_syscount then
    --     Collection_CatNum = CatNum - 46
    --     return _G[collection_files[Collection_CatNum].table_name]

    -- else             return files_table
    -- end
end

function xAppNumTableLookup(AppTypeNum)
    if AppTypeNum == 1 then return games_table
    elseif AppTypeNum == 2 then  return psp_table
    elseif AppTypeNum == 3 then  return psx_table
    elseif AppTypeNum == 5 then  return n64_table
    elseif AppTypeNum == 6 then  return snes_table
    elseif AppTypeNum == 7 then  return nes_table
    elseif AppTypeNum == 8 then  return gba_table
    elseif AppTypeNum == 9 then  return gbc_table
    elseif AppTypeNum == 10 then return gb_table
    elseif AppTypeNum == 11 then return dreamcast_table
    elseif AppTypeNum == 12 then return sega_cd_table
    elseif AppTypeNum == 13 then return s32x_table
    elseif AppTypeNum == 14 then return md_table
    elseif AppTypeNum == 15 then return sms_table
    elseif AppTypeNum == 16 then return gg_table
    elseif AppTypeNum == 17 then return tg16_table
    elseif AppTypeNum == 18 then return tgcd_table
    elseif AppTypeNum == 19 then return pce_table
    elseif AppTypeNum == 20 then return pcecd_table
    elseif AppTypeNum == 21 then return amiga_table
    elseif AppTypeNum == 22 then return c64_table
    elseif AppTypeNum == 23 then return wswan_col_table
    elseif AppTypeNum == 24 then return wswan_table
    elseif AppTypeNum == 25 then return msx2_table
    elseif AppTypeNum == 26 then return msx1_table
    elseif AppTypeNum == 27 then return zxs_table
    elseif AppTypeNum == 28 then return atari_7800_table
    elseif AppTypeNum == 29 then return atari_5200_table
    elseif AppTypeNum == 30 then return atari_2600_table
    elseif AppTypeNum == 31 then return atari_lynx_table
    elseif AppTypeNum == 32 then return colecovision_table
    elseif AppTypeNum == 33 then return vectrex_table
    elseif AppTypeNum == 34 then return fba_table
    elseif AppTypeNum == 35 then return mame_2003_plus_table
    elseif AppTypeNum == 36 then return mame_2000_table
    elseif AppTypeNum == 37 then return neogeo_table
    elseif AppTypeNum == 38 then return ngpc_table
    elseif AppTypeNum == 39 then return psm_table
    elseif AppTypeNum == 40 then return scummvm_table
    elseif AppTypeNum == 41 then return pico8_table
    elseif AppTypeNum == 42 then return sysapps_table
    elseif AppTypeNum == 43 then return nds_table
    elseif AppTypeNum == 44 then return fav_count
    elseif AppTypeNum == 45 then return recently_played_table
    elseif AppTypeNum == 46 then return search_results_table
    else return homebrews_table
    end
end

function xAppDbFileLookup(AppTypeNum)
    if AppTypeNum == 1 then return "db_games.lua"
    elseif AppTypeNum == 2 then  return "db_psp.lua"
    elseif AppTypeNum == 3 then  return "db_psx.lua"
    elseif AppTypeNum == 5 then  return "db_n64.lua"
    elseif AppTypeNum == 6 then  return "db_snes.lua"
    elseif AppTypeNum == 7 then  return "db_nes.lua"
    elseif AppTypeNum == 8 then  return "db_gba.lua"
    elseif AppTypeNum == 9 then  return "db_gbc.lua"
    elseif AppTypeNum == 10 then return "db_gb.lua"
    elseif AppTypeNum == 11 then return "db_dreamcast.lua"
    elseif AppTypeNum == 12 then return "db_sega_cd.lua"
    elseif AppTypeNum == 13 then return "db_32x.lua"
    elseif AppTypeNum == 14 then return "db_md.lua"
    elseif AppTypeNum == 15 then return "db_sms.lua"
    elseif AppTypeNum == 16 then return "db_gg.lua"
    elseif AppTypeNum == 17 then return "db_tg16.lua"
    elseif AppTypeNum == 18 then return "db_tgcd.lua"
    elseif AppTypeNum == 19 then return "db_pce.lua"
    elseif AppTypeNum == 20 then return "db_pcecd.lua"
    elseif AppTypeNum == 21 then return "db_amiga.lua"
    elseif AppTypeNum == 22 then return "db_c64.lua"
    elseif AppTypeNum == 23 then return "db_wswan_col.lua"
    elseif AppTypeNum == 24 then return "db_wswan.lua"
    elseif AppTypeNum == 25 then return "db_msx2.lua"
    elseif AppTypeNum == 26 then return "db_msx1.lua"
    elseif AppTypeNum == 27 then return "db_zxs.lua"
    elseif AppTypeNum == 28 then return "db_atari_7800.lua"
    elseif AppTypeNum == 29 then return "db_atari_5200.lua"
    elseif AppTypeNum == 30 then return "db_atari_2600.lua"
    elseif AppTypeNum == 31 then return "db_atari_lynx.lua"
    elseif AppTypeNum == 32 then return "db_colecovision.lua"
    elseif AppTypeNum == 33 then return "db_vectrex.lua"
    elseif AppTypeNum == 34 then return "db_fba.lua"
    elseif AppTypeNum == 35 then return "db_mame_2003_plus.lua"
    elseif AppTypeNum == 36 then return "db_mame_2000.lua"
    elseif AppTypeNum == 37 then return "db_neogeo.lua"
    elseif AppTypeNum == 38 then return "db_ngpc.lua"
    elseif AppTypeNum == 39 then return "db_psm.lua"
    elseif AppTypeNum == 40 then return "db_scummvm.lua"
    elseif AppTypeNum == 41 then return "db_pico8.lua"
    elseif AppTypeNum == 42 then return "db_sysapps.lua"
    elseif AppTypeNum == 43 then return "db_nds.lua"
    else return "db_homebrews.lua"
    end
end

function xAppNumTableLookup_Missing_Cover(AppTypeNum)
    if AppTypeNum == 1 then return "missing_cover_psv"
    elseif AppTypeNum == 2 then  return "missing_cover_psp"
    elseif AppTypeNum == 3 then  return "missing_cover_psx"
    elseif AppTypeNum == 5 then  return "missing_cover_n64"
    elseif AppTypeNum == 6 then  return "missing_cover_snes"
    elseif AppTypeNum == 7 then  return "missing_cover_nes"
    elseif AppTypeNum == 8 then  return "missing_cover_gba"
    elseif AppTypeNum == 9 then  return "missing_cover_gbc"
    elseif AppTypeNum == 10 then return "missing_cover_gb"

    elseif AppTypeNum == 11 then 
        if setLanguage == 0 then -- EN - Blue logo
            return "missing_cover_dreamcast_eur"
        elseif setLanguage == 1 then -- USA - Red logo
            return "missing_cover_dreamcast_usa"
        elseif setLanguage == 9 or setLanguage == 19 then -- Japan - Orange logo
            return "missing_cover_dreamcast_j"
        else -- Blue logo
            return "missing_cover_dreamcast_eur"
        end

    elseif AppTypeNum == 12 then return "missing_cover_sega_cd"
    elseif AppTypeNum == 13 then return "missing_cover_32x"

    elseif AppTypeNum == 14 then
        if setLanguage == 1 then -- USA - Genesis
            return "missing_cover_md_usa"
        else -- Megadrive
            return "missing_cover_md"
        end

    elseif AppTypeNum == 15 then return "missing_cover_sms"
    elseif AppTypeNum == 16 then return "missing_cover_gg"
    elseif AppTypeNum == 17 then return "missing_cover_tg16"
    elseif AppTypeNum == 18 then return "missing_cover_tgcd"
    elseif AppTypeNum == 19 then return "missing_cover_pce"
    elseif AppTypeNum == 20 then return "missing_cover_pcecd"
    elseif AppTypeNum == 21 then return "missing_cover_amiga"
    elseif AppTypeNum == 22 then return "missing_cover_c64"
    elseif AppTypeNum == 23 then return "missing_cover_wswan_col"
    elseif AppTypeNum == 24 then return "missing_cover_wswan"
    elseif AppTypeNum == 25 then return "missing_cover_msx2"
    elseif AppTypeNum == 26 then return "missing_cover_msx1"
    elseif AppTypeNum == 27 then return "missing_cover_zxs"
    elseif AppTypeNum == 28 then return "missing_cover_atari_7800"
    elseif AppTypeNum == 29 then return "missing_cover_atari_5200"
    elseif AppTypeNum == 30 then return "missing_cover_atari_2600"
    elseif AppTypeNum == 31 then return "missing_cover_atari_lynx"
    elseif AppTypeNum == 32 then return "missing_cover_colecovision"
    elseif AppTypeNum == 33 then return "missing_cover_vectrex"
    elseif AppTypeNum == 34 then return "missing_cover_fba"
    elseif AppTypeNum == 35 then return "missing_cover_mame"
    elseif AppTypeNum == 36 then return "missing_cover_mame"
    elseif AppTypeNum == 37 then return "missing_cover_neogeo"
    elseif AppTypeNum == 38 then return "missing_cover_ngpc"
    elseif AppTypeNum == 39 then return "missing_cover_psm"
    elseif AppTypeNum == 40 then return "missing_cover_scummvm"
    elseif AppTypeNum == 41 then return "missing_cover_pico8"
    elseif AppTypeNum == 42 then return "missing_cover_sysapp"
    elseif AppTypeNum == 43 then return "missing_cover_nds"
    else return "missing_cover_homebrew"
    end
end

-- Find game table key
function find_game_table_pos_key(tbl, search)
    for key, data in pairs(tbl) do
       if data.name == (search) then 
          return key
       end
    end
end

-- encode url
function urlencode (str)
   str = string.gsub (str, "([^0-9a-zA-Z !'()*._~-])", -- locale independent
      function (c) return string.format ("%%%%%02X", string.byte(c)) end)
   str = string.gsub (str, " ", "%%%%20")
   str = string.gsub (str, "%(", "%%%%28")
   str = string.gsub (str, "%)", "%%%%29")
   return str
end

-- Manipulate Rom Name - remove region code and url encode spaces for image download
-- function cleanRomNames()
--     -- file.name = {}
--     -- romname_withExtension = file.name
--     romname_noExtension = {}
--     romname_noExtension = romname_withExtension:match("(.+)%..+$")

--     -- remove space before parenthesis " (" then letters and numbers "(.*)", also remove space and square brackets " [.*]"
--     romname_noRegion_noExtension = {}
--     romname_noRegion_noExtension = romname_noExtension:gsub(" %(", "("):gsub('%b()', ''):gsub("%s*%b[]", "")

--     -- encode url
--     romname_url_encoded = {}
--     romname_url_encoded = urlencode (romname_noExtension)

--     -- Check if name contains parenthesis, if yes strip out to show as version
--     if string.find(romname_noExtension, "%(") and string.find(romname_noExtension, "%)") then
        
        
--         -- Remove all text except for within "()"
--         romname_region_initial = {}
--         if romname_noExtension:match("%((.+)%)") ~= nil then
--             romname_region_initial = romname_noExtension:match("%((.+)%)")
--         else
--             romname_region_initial = {}
--         end


--         -- Tidy up remainder when more than one set of parenthesis used, replace  ") (" with ", "
--         if romname_region_initial:gsub("%) %(", ', ') ~= nil then
--             romname_region = romname_region_initial:gsub("%) %(", ', ')
--         else
--             romname_region = " "
--         end

--         -- Tidy up ")(" replace with space - Tosec style names
--         romname_region = romname_region:gsub("%)%(", " ")
        

--     -- If no parenthesis, then add blank to prevent nil error
--     else
--         -- romname_region = " "
--         romname_region = " "
--     end
-- end

function cleanRomNames()
    -- Use the global romname_withExtension that should be set before calling this function
    if not romname_withExtension then
        return -- Exit if no filename provided
    end
    
    romname_noExtension = romname_withExtension:match("(.+)%..+$") or romname_withExtension

    -- remove space before parenthesis " (" then letters and numbers "(.*)", also remove space and square brackets " [.*]"
    romname_noRegion_noExtension = romname_noExtension:gsub(" %(", "("):gsub('%b()', ''):gsub("%s*%b[]", "")

    -- encode url
    romname_url_encoded = urlencode(romname_noExtension)

    -- Check if name contains parenthesis, if yes strip out to show as version
    if string.find(romname_noExtension, "%(") and string.find(romname_noExtension, "%)") then
        
        -- Remove all text except for within "()"
        local romname_region_initial = romname_noExtension:match("%((.+)%)")
        
        if romname_region_initial then
            -- Tidy up remainder when more than one set of parenthesis used, replace  ") (" with ", "
            romname_region = romname_region_initial:gsub("%) %(", ', ')
            -- Tidy up ")(" replace with space - Tosec style names
            romname_region = romname_region:gsub("%)%(", " ")
        else
            romname_region = " "
        end

    -- If no parenthesis, then add blank to prevent nil error
    else
        romname_region = " "
    end
end

function AutoMakeBootBin(def_rom_location, def_driver, def_bin, def_plugins, def_speed, def_hm, def_nonpdrm, def_suspend)

    -- Driver and bin tables
    local drivers = { "ENABLE", "INFERN0", "MARCH33", "NP9660" } -- 0,0,1,2
    local bins = { "ENABLE", "EBOOT.BIN", "EBOOT.OLD", "BOOT.BIN" } -- 0,0,1,2

    -- Cleanup game path for writing to bin (set to lowercase and gsub path)
    local path_game = tostring(def_rom_location)

    if System.doesFileExist(path_game .. "/EBOOT.PBP") then
        path_game = path_game .. "/EBOOT.PBP"
    end

    local path2game = path_game:gsub("/pspemu/", "pspemu/")
    local path2game = string.lower(path2game)
    
    local driver = tostring(def_driver)
    local bin = tostring(def_bin)
    local plugins = def_plugins
    local speed = def_speed
    local hm = def_hm
    local nonpdrm = def_nonpdrm
    local suspend = def_suspend

    -- Copy boot bin for editing
    if System.doesDirExist("ux0:/app/RETROLNCR/data") then

        -- If boot.bin exists, copy and edit
        if System.doesFileExist("app0:payloads/boot.bin") then 
            System.copyFile("app0:payloads/boot.bin", "ux0:/app/RETROLNCR/data/boot.bin")

            local fp = io.open("ux0:/app/RETROLNCR/data/boot.bin", "r+")
            if fp then
                local number = 0
                                    
                -- Driver 
                fp:seek("set",0x04)
                if driver == "INFERN0" then number_driver = "\x00\x00\x00\x00"
                elseif driver == "MARCH33" then number_driver = "\x01\x00\x00\x00"
                elseif driver == "NP9660" then number_driver = "\x02\x00\x00\x00"
                end
                fp:write(number_driver)

                -- Bin Execute
                fp:seek("set",0x08)
                if bin == "EBOOT.BIN" then number_bin = "\x00\x00\x00\x00"
                elseif bin == "EBOOT.OLD" then number_bin = "\x01\x00\x00\x00"
                elseif bin == "BOOT.BIN" then number_bin = "\x02\x00\x00\x00"
                end
                fp:write(number_bin)

                -- Suspend
                if suspend ~= 0 then
                    fp:seek("set", 0x18)
                    if suspend == 1 then number_suspend = "\x01\x00\x00\x00"        -- No
                    else
                        number_suspend = "\x00\x00\x00\x00"                         -- Yes
                    end
                    fp:write(number_suspend)
                end

                -- cpuspeed
                if speed ~= 0 then
                    fp:seek("set", 0x1C)
                    if speed == 1      then number_speed = "\x01\x00\x00\x00"       -- 20/10
                    elseif speed == 2  then number_speed = "\x02\x00\x00\x00"       -- 50/25
                    elseif speed == 3  then number_speed = "\x03\x00\x00\x00"       -- 75/37
                    elseif speed == 4  then number_speed = "\x04\x00\x00\x00"       -- 100/50
                    elseif speed == 5  then number_speed = "\x05\x00\x00\x00"       -- 111/55
                    elseif speed == 6  then number_speed = "\x06\x00\x00\x00"       -- 122/61
                    elseif speed == 7  then number_speed = "\x07\x00\x00\x00"       -- 133/66
                    elseif speed == 8  then number_speed = "\x08\x00\x00\x00"       -- 166/83
                    elseif speed == 9  then number_speed = "\x09\x00\x00\x00"       -- 200/100
                    elseif speed == 10 then number_speed = "\x0A\x00\x00\x00"       -- 222/111
                    elseif speed == 11 then number_speed = "\x0B\x00\x00\x00"       -- 266/133
                    elseif speed == 12 then number_speed = "\x0C\x00\x00\x00"       -- 288/144
                    elseif speed == 13 then number_speed = "\x0D\x00\x00\x00"       -- 300/150
                    elseif speed == 14 then number_speed = "\x0E\x00\x00\x00"       -- 333/166
                    else
                        number_speed = "\x00\x00\x00\x00"                           -- Default
                    end
                    fp:write(number_speed)
                end

                -- Plugins
                if plugins ~= 0 then
                    fp:seek("set", 0x20)
                    if plugins == 1 then number_plugin = "\x01\x00\x00\x00"         -- Enable
                    elseif plugins == 2 then number_plugin = "\x02\x00\x00\x00"     -- Disable
                    else
                        number_plugin = "\x00\x00\x00\x00"                          -- Default
                    end
                    fp:write(number_plugin)
                end

                -- NonpDRM
                if nonpdrm ~= 0 then
                    fp:seek("set", 0x24)
                    if nonpdrm == 1 then number_nonpdrm = "\x01\x00\x00\x00"        -- Enable
                    elseif nonpdrm == 2 then number_nonpdrm = "\x02\x00\x00\x00"    -- Disable
                    else
                        number_nonpdrm = "\x00\x00\x00\x00"                         -- Default
                    end
                    fp:write(number_nonpdrm)
                end

                --HighMemory
                if hm ~= 0 then
                    fp:seek("set", 0x28)
                    if hm == 1 then number_hm = "\x01\x00\x00\x00"                  -- Enable
                    elseif hm == 2 then number_hm = "\x02\x00\x00\x00"              -- Disable
                    else
                        number_hm = "\x00\x00\x00\x00"                              -- Default
                    end
                    fp:write(number_hm)
                end

                -- Path2game
                fp:seek("set",0x40)
                local fill = 256 - #path2game
                for j=1,fill do
                    path2game = path2game..string.char(00)
                end
                fp:write(path2game)

                -- PSbutton 00 Menu 01 LiveArea 02 Standard
                fp:seek("set",0x14)
                if setAdrPSButton == 0 then psbutton_number = "\x00\x00\x00\x00"
                elseif setAdrPSButton == 1 then psbutton_number = "\x01\x00\x00\x00"
                elseif setAdrPSButton == 2 then psbutton_number = "\x02\x00\x00\x00"
                else
                end
                fp:write(psbutton_number)     

                --Close
                fp:close()

            end--fp

            -- System.launchApp("RETROLNCR")
            System.executeUri("psgm:play?titleid=RETROLNCR")
            System.exit()
        else
            -- boot.bin not found
        end
    else
        -- Launcher not found
    end

end

function import_launch_overrides()

    if System.doesFileExist("ux0:/data/RetroFlow/launch_overrides.lua") then
        db_Cache_launch_overrides = "ux0:/data/RetroFlow/launch_overrides.lua"

        db_launch_overrides = {}
        local importLuaFileError = importLuaFile(db_Cache_launch_overrides, db_launch_overrides)

        if importLuaFileError then
            -- File is corrupt, don't import it
        else

            for k, v in ipairs(db_launch_overrides) do

                -- If queries are a legacy fix for new settings that were added
                if v.plugins == nil then
                    v.plugins = game_adr_plugins
                end
                if v.speed == nil then
                    v.speed = game_adr_speed
                end
                if v.hm == nil then
                    v.hm = game_adr_hm
                end
                if v.nonpdrm == nil then
                    v.nonpdrm = game_adr_nonpdrm
                end
                if v.speed == nil then
                    v.suspend = game_adr_suspend
                end


                table.insert(launch_overrides_table, v)
            end

        end

        
    end
end

launch_overrides_table = {}
import_launch_overrides()
launch_check_app_installed = false -- Checks if emulator is installed (prompt to install if not installed)
launch_check_game_available = false -- Checks if game is installed (prompt to rescan if not installed)

function check_app_installed(def_title, def_message)
    -- if System.doesAppExist(def_title) then -- Commented out, not sure if it checks the live area or appdb, could be restricted by bubble limit
    if System.doesDirExist("ux0:/app/" .. def_title) then -- Check ux0 instead
        -- Emulator installed
        launch_check_app_installed = true
    elseif System.doesDirExist("vs0:/app/" .. def_title) then
        -- System app installed
        launch_check_app_installed = true
    else
        -- Not installed, display message
        launch_check_app_installed = false
        status = System.getMessageState()
        if status ~= RUNNING then
            System.setMessage(def_message, false, BUTTON_OK)
        end
    end
end

function check_game_available(def_rom_location)
    if launch_check_app_installed == true then
        if System.doesFileExist(def_rom_location) or System.doesDirExist(def_rom_location) then
            launch_check_game_available = true
        else
            launch_check_game_available = false
            status = System.getMessageState()
            if status ~= RUNNING then
                System.setMessage(lang_lines.Game_not_installed_rescan, false, BUTTON_OK)
            end
        end
    else
    end
end

function check_game_available_appdb(def_titleid)
    -- Check game is installed by checking app db
    db = Database.open("ur0:shell/db/app.db")

    sql_db_search_mame = "\"" .. (def_titleid) .. "\""
    local query_string = "SELECT title FROM tbl_appinfo_icon where titleid is "  .. sql_db_search_mame
    sql_db_search_result = Database.execQuery(db, query_string)

    if next(sql_db_search_result) == nil then
        -- Not found
        launch_check_app_installed = false
    else
        -- Found
        launch_check_app_installed = true
    end
    Database.close(db)

    if launch_check_app_installed == false then
        -- Not installed, display message
        status = System.getMessageState()
        if status ~= RUNNING then
            System.setMessage(lang_lines.Game_not_installed_rescan, false, BUTTON_OK)
        end
    end
end

function prepare_for_launch()
    FreeMemory()
    -- Add to recently played
    AddtoRecentlyPlayed()
    update_cached_table_recently_played_pre_launch()
end

function launch_Adrenaline(def_rom_location, def_rom_title_id, def_rom_filename)

    -- Launch preflight check
    check_app_installed("PSPEMUCFW", lang_lines.Emulator_not_installed_Adrenaline)
    check_game_available(rom_location)

    if launch_check_app_installed and launch_check_game_available == true then
        prepare_for_launch()
        
        -- Check if game has custom launch overrides
        if #launch_overrides_table ~= nil then
            local key = find_game_table_pos_key(launch_overrides_table, (def_rom_title_id))
            if key ~= nil then
                -- Overrides found
                saved_driver = launch_overrides_table[key].driver
                if saved_driver == 1 then 
                    driver = "INFERN0"
                elseif saved_driver == 2 then
                    driver = "MARCH33"
                elseif saved_driver == 3 then
                    driver = "NP9660"
                else
                    driver = "INFERN0"
                end

                saved_bin = launch_overrides_table[key].bin
                if saved_bin == 1 then 
                    bin = "EBOOT.BIN"
                elseif saved_bin == 2 then
                    bin = "EBOOT.OLD"
                elseif saved_bin == 3 then
                    bin = "BOOT.BIN"
                else
                    bin = "EBOOT.BIN"
                end

                plugins = launch_overrides_table[key].plugins
                speed = launch_overrides_table[key].speed
                hm = launch_overrides_table[key].hm
                nonpdrm = launch_overrides_table[key].nonpdrm
                suspend = launch_overrides_table[key].suspend

            else
                -- Overrides not found, use default
                driver = "INFERN0"
                bin = "EBOOT.BIN"
            end
        else
            -- Table is empty, use default
            driver = "INFERN0"
            bin = "EBOOT.BIN"
            plugins = 0
            speed = 0
            hm = 0
            nonpdrm = 0
            suspend = 0
        end

        -- Delete the old Adrenaline inf file
        if  System.doesFileExist(launch_dir_adr .. "data/boot.inf") then
            System.deleteFile(launch_dir_adr .. "data/boot.inf")
        end

        -- Delete the old Adrenaline bin file
        if  System.doesFileExist(launch_dir_adr .. "data/boot.bin") then
            System.deleteFile(launch_dir_adr .. "data/boot.bin")
        end

        AutoMakeBootBin((def_rom_location), driver, bin, plugins, speed, hm, nonpdrm, suspend)

    end
end

function launch_scummvm()
    -- Launch preflight check
    check_app_installed("VSCU00001", lang_lines.Emulator_not_installed_ScummVM)
    check_game_available(rom_location)

    if launch_check_app_installed and launch_check_game_available == true then
        prepare_for_launch()
        System.executeUri("psgm:play?titleid=VSCU00001" .. "&path=" .. rom_location .. "&game_id=" .. rom_title_id)
        System.exit()
    end
end

function launch_pico8()
    -- Launch preflight check
    check_app_installed("FAKE00008", lang_lines.Emulator_not_installed_Pico8)
    check_game_available(rom_location)

    if launch_check_app_installed and launch_check_game_available == true then
        prepare_for_launch()
        System.executeUri("psgm:play?titleid=FAKE00008" .. "&param=" .. rom_location)
        System.exit()
    end
end

function launch_retroarch(def_core_name)
    -- Launch preflight check
    check_app_installed("RETROVITA", lang_lines.Emulator_not_installed_Retroarch)
    check_game_available(rom_location)

    if launch_check_app_installed and launch_check_game_available == true then
        prepare_for_launch()
        System.executeUri("psgm:play?titleid=RETROVITA" .. "&param=" .. (def_core_name) .. "&param2=" .. rom_location)
        System.exit()
    end
end

function launch_DaedalusX64()
    -- Launch preflight check
    check_app_installed("DEDALOX64", lang_lines.Emulator_not_installed_DaedalusX64)
    check_game_available(rom_location)

    if launch_check_app_installed and launch_check_game_available == true then
        prepare_for_launch()
        System.executeUri("psgm:play?titleid=DEDALOX64" .. "&param=" .. rom_location)
        System.exit()
    end
end

function launch_Flycast()
    -- Launch preflight check
    check_app_installed("FLYCASTDC", lang_lines.Emulator_not_installed_Flycast)
    check_game_available(rom_location)

    if launch_check_app_installed and launch_check_game_available == true then
        prepare_for_launch()
        System.executeUri("psgm:play?titleid=FLYCASTDC" .. "&param=" .. rom_location)
        System.exit()
    end
end

function launch_DSVita()
    -- Launch preflight check
    check_app_installed("DSVITA000", lang_lines.Emulator_not_installed_DSVita)
    check_game_available(rom_location)

    if launch_check_app_installed and launch_check_game_available == true then
        prepare_for_launch()
        System.executeUri("psgm:play?titleid=DSVITA000" .. "&param=" .. rom_location)
        System.exit()
    end
end

function launch_psmobile(def_titleid)
    -- Launch preflight check
    check_game_available_appdb(def_titleid)

    if launch_check_app_installed == true then
        prepare_for_launch()
        System.executeUri("psgm:play?titleid=" .. (def_titleid))
        System.exit()
    end
end

function launch_vita_title(def_titleid)
    -- Launch preflight check
    check_app_installed(def_titleid, lang_lines.Game_not_installed_rescan)

    if launch_check_app_installed == true then
        prepare_for_launch()
        System.launchApp(def_titleid)
        System.exit()
    end
end

function launch_vita_sysapp(def_titleid)
    -- Launch preflight check
    check_app_installed(def_titleid, lang_lines.Game_not_installed_rescan)

    if launch_check_app_installed == true then
        
        local uri = {
            ["NPXS10000"] = "near:",            -- Near
            ["NPXS10001"] = "pspy:",            -- Party
            ["NPXS10002"] = "psns:browse?category=STORE-MSF73008-VITAGAMES:",            -- Playstation Store
            ["NPXS10003"] = "wbapp0:",          -- Internet browser
            ["NPXS10004"] = "photo:",           -- Photos
            ["NPXS10008"] = "pstc:",            -- Trophy collection
            ["NPXS10009"] = "music:",           -- Music
            -- ["NPXS10010"] = "video:",           -- Video
            ["NPXS10014"] = "psnmsg:",          -- Messages
            ["NPXS10015"] = "settings_dlg:",    -- Settings
            ["NPXS10072"] = "email:",           -- Email
            ["NPXS10078"] = "scecomboplay:",    -- Cross-Controller
            ["NPXS10091"] = "scecalendar:"      -- Calendar
        }

        -- Check if def_titleid exists in uri table and execute the corresponding URI
        if uri[def_titleid] then
            System.executeUri(uri[def_titleid])
        else

            -- Explanation:
            -- For apps without URI commands, they will fail create a launch txt file, for the launch_sys_app bin.
            -- The bin file uses sceAppMgrLaunchAppByUri(0x40000, TITLEID) to open the app without launching.

            -- Write file for opening with bin
            local file_over = System.openFile(cur_dir .. "/TITLES/system_app_launch.txt", FCREATE)
            System.closeFile(file_over)

            file = io.open(cur_dir .. "/TITLES/system_app_launch.txt", "w")
            file:write(def_titleid)
            file:close()

            -- Launch the bin
            FreeMemory()
            System.launchEboot("app0:/launch_sys_app.bin")
            System.exit()
        end
    end
end


function CreateUserTitleTable_for_File(def_user_db_file, def_table_name)

    table.sort((def_table_name), function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)

    local file_over = System.openFile(user_DB_Folder .. (def_user_db_file), FCREATE)
    System.closeFile(file_over)

    file = io.open(user_DB_Folder .. (def_user_db_file), "w")
    file:write('return {' .. "\n")
    for k, v in pairs((def_table_name)) do

        if v.directory == false then
            file:write('["' .. v.name .. '"] = {name = "' .. v.name_title_search .. '"},' .. "\n")
        end
    end
    file:write('}')
    file:close()

end

function CreateUserTitleTable_for_PSM(def_user_db_file, def_table_name)

    table.sort((def_table_name), function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)

    local file_over = System.openFile(user_DB_Folder .. (def_user_db_file), FCREATE)
    System.closeFile(file_over)

    file = io.open(user_DB_Folder .. (def_user_db_file), "w")
    file:write('return {' .. "\n")
    for k, v in pairs((def_table_name)) do

        file:write('["' .. v.name .. '"] = {title = "' .. v.title .. '", version = "' .. v.version .. '"},' .. "\n")
    end
    file:write('}')
    file:close()

end




function update_md_regional_cover()
    -- Megadrive, update regional missing cover

    if setLanguage == 1 then -- USA - Genesis
        for k, v in pairs(md_table) do
              if v.icon_path=="app0:/DATA/missing_cover_md.png" then
                  v.icon_path="app0:/DATA/missing_cover_md_usa.png"
              end
        end
    else -- Megadrive
        for k, v in pairs(md_table) do
              if v.icon_path=="app0:/DATA/missing_cover_md_usa.png" then
                  v.icon_path="app0:/DATA/missing_cover_md.png"
              end
        end
    end
end

function update_dc_regional_cover()
    -- Dreamcast, update regional missing cover

    if setLanguage == 0 then -- EN - Blue logo
        for k, v in pairs(dreamcast_table) do
              if v.icon_path=="app0:/DATA/missing_cover_dreamcast_usa.png" or v.icon_path=="app0:/DATA/missing_cover_dreamcast_j.png" then
                  v.icon_path="app0:/DATA/missing_cover_dreamcast_eur.png"
              end
        end
    elseif setLanguage == 1 then -- USA - Red logo
        for k, v in pairs(dreamcast_table) do
              if v.icon_path=="app0:/DATA/missing_cover_dreamcast_eur.png" or v.icon_path=="app0:/DATA/missing_cover_dreamcast_j.png" then
                  v.icon_path="app0:/DATA/missing_cover_dreamcast_usa.png"
              end
        end
    elseif setLanguage == 9 or setLanguage == 19 then -- Japan - Orange logo
        for k, v in pairs(dreamcast_table) do
              if v.icon_path=="app0:/DATA/missing_cover_dreamcast_eur.png" or v.icon_path=="app0:/DATA/missing_cover_dreamcast_usa.png" then
                  v.icon_path="app0:/DATA/missing_cover_dreamcast_j.png"
              end
        end
    else -- Blue logo
        for k, v in pairs(dreamcast_table) do
              if v.icon_path=="app0:/DATA/missing_cover_dreamcast_usa.png" or v.icon_path=="app0:/DATA/missing_cover_dreamcast_j.png" then
                  v.icon_path="app0:/DATA/missing_cover_dreamcast_eur.png"
              end
        end
    end
end


-- Check for hidden game names
function check_for_hidden_tag_on_scan(def_file_name, def_app_type)
    if #hidden_games_table ~= nil then
        local key = find_game_table_pos_key(hidden_games_table, (def_file_name))
        if key ~= nil then
            -- Yes - Find in files table
            if hidden_games_table[key].app_type == (def_app_type) then
                
                if hidden_games_table[key].hidden == true then
                    return true
                else
                    return false
                end

            end
        else
          -- No
          return false
        end
    else
        return false
    end
end


function create_fav_count_table(def_table_input)
    -- Note: showHomebrews = 1 -- On
    -- Note: showHidden = 0 -- 0 Off

    fav_count = {}
    for l, file in pairs((def_table_input)) do

        -- Fav, not hidden
        if file.favourite==true and file.hidden==false then

            -- Exlude Homebrews or SysApps if off
            if showHomebrews == 0 or showSysApps == 0 then
                -- ignore homebrew apps
                if file.app_type ~= nil then
                    if file.favourite==true then
                        table.insert(fav_count, file)
                    end
                else
                end

            else
                if file.favourite==true then
                    table.insert(fav_count, file)
                end
            end

        -- Fav hidden
        elseif file.favourite==true and file.hidden==true then

            -- Show hidden is on
            if showHidden==1 then

                -- Exlude Homebrews or SysApps if off
                if showHomebrews == 0 or showSysApps == 0 then
                    -- ignore homebrew apps
                    if file.app_type ~= nil then
                        if file.favourite==true then
                            table.insert(fav_count, file)
                        end
                    else
                    end
                else
                    if file.favourite==true then
                        table.insert(fav_count, file)
                    end
                end
            else
            end
        else
        end
    end
end


function include_game_in_recent(def_app_type, def_game_path, def_name)
    local adr_partition_string = ""

    -- Adrenaline partition settings
    if Adrenaline_roms == 1 then
        adr_partition_string = "ux0:/pspemu"
    elseif Adrenaline_roms == 2 then
        adr_partition_string = "ur0:/pspemu"
    elseif Adrenaline_roms == 3 then
        adr_partition_string = "imc0:/pspemu"
    elseif Adrenaline_roms == 4 then
        adr_partition_string = "xmc0:/pspemu"
    elseif Adrenaline_roms == 5 then
        adr_partition_string = "" -- All partitions
    else 
        adr_partition_string = "uma0:/pspemu"
    end

    -- If adrenaline game and partition selected (not all)
    if (def_app_type) == 2 or (def_app_type) == 3 and Adrenaline_roms <= 4 then
        if string.match((def_game_path), adr_partition_string) then
            -- If game path includes adrenaline partition name, then include
            return true
        else
            -- If game path does not include partition name, then exclude
            return false
        end
    -- If homebrew
    elseif (def_app_type) == 0 then
        if showHomebrews == 1 then
            -- If show homebrew on, include
            return true
        else
            -- If show homebrew off, exclude unless in a collection
            if #temp_hb_collection ~= nil then
                for k, v in pairs(temp_hb_collection) do

                    for key, data in pairs(temp_hb_collection) do
                        if data.name == (def_name) then
                            return true
                        end
                    end
                end
            else
                return false
            end
        end
    else
        -- Include
        return true
    end


end

function import_recently_played()

    local file_over = System.openFile(cur_dir .. "/overrides.dat", FREAD)
    local filesize = System.sizeFile(file_over)
    local str = System.readFile(file_over, filesize)
    System.closeFile(file_over)

    -- RECENTLY PLAYED
    if showRecentlyPlayed == 1 then
        if System.doesFileExist("ux0:/data/RetroFlow/recently_played.lua") then
            db_Cache_recently_played = "ux0:/data/RetroFlow/recently_played.lua"

            local db_recently_played = {}
            local importLuaFileError = importLuaFile(db_Cache_recently_played, db_recently_played)

            if importLuaFileError then
                -- File is corrupt, don't import it
            else

                for k, v in ipairs(db_recently_played) do

                    -- Various fixes on import
                    local key = find_game_table_pos_key(xAppNumTableLookup(v.app_type), v.name)
                    if key ~= nil then

                        -- Legacy fix - Add default app type to recently played table
                        if v.app_type_default ~= nil then
                            v.app_type_default = xAppNumTableLookup(v.app_type)[key].app_type_default
                        end

                        -- Legacy fix - Add hidden to recently played table
                        if v.hidden ~= nil then
                            v.hidden = xAppNumTableLookup(v.app_type)[key].hidden
                        end

                        -- Sync hidden with cached files
                        cached_hidden = xAppNumTableLookup(v.app_type)[key].hidden
                        if cached_hidden == true and v.hidden == false then
                            v.hidden = true
                        end

                        -- Sync favourites with cached files
                        cached_fav = xAppNumTableLookup(v.app_type)[key].favourite
                        if cached_fav == true and v.favourite == false then
                            v.favourite = true
                        end

                        -- Sync cover found with cached files
                        cached_cover = xAppNumTableLookup(v.app_type)[key].cover
                        v.cover = cached_cover

                    else
                    end

                    -- Check rom exists
                    -- If file
                    if v.directory == false then
                        if System.doesFileExist(v.game_path) then
                            if include_game_in_recent(v.app_type, v.game_path, v.name) == true then
                                table.insert(recently_played_table, v)
                                --add blank icon to all
                                v.icon = imgCoverTmp
                                v.icon_path = v.icon_path
                                v.apptitle = v.apptitle
                            end
                        end
                    else
                        -- Not file, is folder
                        if System.doesDirExist(v.game_path) then
                            if include_game_in_recent(v.app_type, v.game_path, v.name) == true then
                                table.insert(recently_played_table, v)
                                --add blank icon to all
                                v.icon = imgCoverTmp
                                v.icon_path = v.icon_path
                                v.apptitle = v.apptitle
                            end
                        end
                    end
                end

                -- apply_overrides_to_recently_played
                if System.doesFileExist(cur_dir .. "/overrides.dat") then
                    
                    for k, v in pairs(recently_played_table) do

                        if string.match(str, v.name .. "=1") then
                            v.app_type=1
                            v.cover_path_online = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PSVita/"
                            v.cover_path_local = "ux0:/data/RetroFlow/COVERS/Sony - PlayStation Vita/"

                            if "ux0:/data/RetroFlow/COVERS/Sony - PlayStation Vita/" .. v.apptitle .. ".png" and System.doesFileExist("ux0:/data/RetroFlow/COVERS/Sony - PlayStation Vita/" .. v.apptitle .. ".png") then
                                v.icon_path = "ux0:/data/RetroFlow/COVERS/Sony - PlayStation Vita/" .. v.apptitle .. ".png" --custom cover by app name
                                v.cover = true
                            elseif "ux0:/data/RetroFlow/COVERS/Sony - PlayStation Vita/" .. v.name .. ".png" and System.doesFileExist("ux0:/data/RetroFlow/COVERS/Sony - PlayStation Vita/" .. v.name .. ".png") then
                                v.icon_path = "ux0:/data/RetroFlow/COVERS/Sony - PlayStation Vita/" .. v.name .. ".png" --custom cover by app id
                                v.cover = true
                            else
                                if System.doesFileExist("ur0:/appmeta/" .. v.name .. "/icon0.png") then
                                    v.icon_path = "ur0:/appmeta/" .. v.name .. "/icon0.png"  --app icon
                                    v.cover = true
                                else
                                    v.icon_path = "app0:/DATA/noimg.png" --blank grey
                                    v.cover = false
                                end
                            end

                        elseif string.match(str, v.name .. "=2") then
                            v.app_type=2
                            v.cover_path_online = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PSP/"
                            v.cover_path_local = "ux0:/data/RetroFlow/COVERS/Sony - PlayStation Portable/"

                            if "ux0:/data/RetroFlow/COVERS/Sony - PlayStation Portable/" .. v.apptitle .. ".png" and System.doesFileExist("ux0:/data/RetroFlow/COVERS/Sony - PlayStation Portable/" .. v.apptitle .. ".png") then
                                v.icon_path = "ux0:/data/RetroFlow/COVERS/Sony - PlayStation Portable/" .. v.apptitle .. ".png" --custom cover by app name
                                v.cover = true
                            elseif "ux0:/data/RetroFlow/COVERS/Sony - PlayStation Portable/" .. v.name .. ".png" and System.doesFileExist("ux0:/data/RetroFlow/COVERS/Sony - PlayStation Portable/" .. v.name .. ".png") then
                                v.icon_path = "ux0:/data/RetroFlow/COVERS/Sony - PlayStation Portable/" .. v.name .. ".png" --custom cover by app id
                                v.cover = true
                            else
                                if System.doesFileExist("app0:/DATA/missing_cover_psp.png") then
                                    v.icon_path = "app0:/DATA/missing_cover_psp.png"  --app icon
                                    v.cover = false
                                else
                                    v.icon_path = "app0:/DATA/noimg.png" --blank grey
                                    v.cover = false
                                end
                            end

                        elseif string.match(str, v.name .. "=3") then
                            v.app_type=3
                            v.cover_path_online = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PS1/"
                            v.cover_path_local = "ux0:/data/RetroFlow/COVERS/Sony - PlayStation/"

                            if "ux0:/data/RetroFlow/COVERS/Sony - PlayStation/" .. v.apptitle .. ".png" and System.doesFileExist("ux0:/data/RetroFlow/COVERS/Sony - PlayStation/" .. v.apptitle .. ".png") then
                                v.icon_path = "ux0:/data/RetroFlow/COVERS/Sony - PlayStation/" .. v.apptitle .. ".png" --custom cover by app name
                                v.cover = true
                            elseif "ux0:/data/RetroFlow/COVERS/Sony - PlayStation/" .. v.name .. ".png" and System.doesFileExist("ux0:/data/RetroFlow/COVERS/Sony - PlayStation/" .. v.name .. ".png") then
                                v.icon_path = "ux0:/data/RetroFlow/COVERS/Sony - PlayStation/" .. v.name .. ".png" --custom cover by app id
                                v.cover = true
                            else
                                if System.doesFileExist("app0:/DATA/missing_cover_psx.png") then
                                    v.icon_path = "app0:/DATA/missing_cover_psx.png"  --app icon
                                    v.cover = false
                                else
                                    v.icon_path = "app0:/DATA/noimg.png" --blank grey
                                    v.cover = false
                                end
                            end

                        elseif string.match(str, v.name .. "=4") then
                            v.app_type=0
                            v.cover_path_online = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/HOMEBREW/"
                            v.cover_path_local = "ux0:/data/RetroFlow/COVERS/Homebrew/"

                            if "ux0:/data/RetroFlow/COVERS/Homebrew/" .. v.apptitle .. ".png" and System.doesFileExist("ux0:/data/RetroFlow/COVERS/Homebrew/" .. v.apptitle .. ".png") then
                                v.icon_path = "ux0:/data/RetroFlow/COVERS/Homebrew/" .. v.apptitle .. ".png" --custom cover by app name
                                v.cover = true
                            elseif "ux0:/data/RetroFlow/COVERS/Homebrew/" .. v.name .. ".png" and System.doesFileExist("ux0:/data/RetroFlow/COVERS/Homebrew/" .. v.name .. ".png") then
                                v.icon_path = "ux0:/data/RetroFlow/COVERS/Homebrew/" .. v.name .. ".png" --custom cover by app id
                                v.cover = true
                            else
                                if System.doesFileExist("ur0:/appmeta/" .. v.name .. "/icon0.png") then
                                    v.icon_path = "ur0:/appmeta/" .. v.name .. "/icon0.png"  --app icon
                                    v.cover = true
                                else
                                    v.icon_path = "app0:/DATA/noimg.png" --blank grey
                                    v.cover = false
                                end
                            end

                        else
                            -- Fix for existing lists which don't have the snap path local entry
                            if v.snap_path_local == nil then
                                v.snap_path_local = ""
                            end 

                        end
                    end
                end

            end
            
        end
    else
    end

    -- Remove hidden games from recent if necessary
    if showHidden == 0 and #recently_played_table ~= nil then
        for l, file in pairs(recently_played_table) do
            if file.hidden == true then
                table.remove(recently_played_table,l)
            else
            end
        end
    end

end


function import_renamed_games()

    renamed_games_table = {}
    if System.doesFileExist("ux0:/data/RetroFlow/renamed_games.lua") then
        db_Cache_renamed_games = "ux0:/data/RetroFlow/renamed_games.lua"

        local db_renamed_games = {}
        local importLuaFileError = importLuaFile(db_Cache_renamed_games, db_renamed_games)

        if importLuaFileError then
            -- File is corrupt, delete it
            System.deleteFile(db_Cache_renamed_games)

        else
            if #db_renamed_games ~= nil then
                for k, v in ipairs(db_renamed_games) do
                    table.insert(renamed_games_table, v)
                end
            end
        end

    end
end

-- COLLECTIONS
    function import_collections()

        -- Only import if show collections is on
        
            if collection_count >= 1 then

                for z, collection_file_num in ipairs(collection_files) do
                    
                    -- Create empty table using custom cat filenames
                    -- Create table
                    _G[collection_file_num.table_name] = {}

                    -- Import lua file into temp table
                    local db_import = {}
                    local importLuaFileError = importLuaFile(collections_dir .. collection_file_num.filename, db_import)

                    if importLuaFileError then
                        -- File is corrupt, don't import

                    else
                        -- Find matching games in files table and insert into custom cat table
                        if #db_import ~= nil then

                            -- Sort by custom sort order if available
                            if db_import[1].custom_sort_order ~= nil then
                                table.sort(db_import, function(a, b) return (tonumber(a.custom_sort_order) < tonumber(b.custom_sort_order)) end)
                            end

                            for l, file in ipairs(db_import) do -- or xapptype lookup
                                local key = find_game_table_pos_key(files_table, file.name)
                                if key ~= nil then
                                    if files_table[key].app_type == file.app_type then
                                        table.insert(_G[collection_file_num.table_name], files_table[key])
                                    end
                                end
                            end
                        end
                    end

                end

            else
            end
        
    end

function import_hidden_games()

    hidden_games_table = {}
    if System.doesFileExist("ux0:/data/RetroFlow/hidden_games.lua") then
        db_Cache_hidden_games = "ux0:/data/RetroFlow/hidden_games.lua"

        local db_hidden_games = {}
        local importLuaFileError = importLuaFile(db_Cache_hidden_games, db_hidden_games)

        if importLuaFileError then
            -- File is corrupt, don't import it
        else
            if #db_hidden_games ~= nil then
                for i, file in ipairs(db_hidden_games) do
                    if file.directory == false then
                        if System.doesFileExist(file.game_path) then
                            table.insert(hidden_games_table, file)
                        else
                        end
                    else
                        if file.app_type == 39 then

                            -- PSM: Check game is installed by checking app db
                                local launch_check_app_installed = false
                                db = Database.open("ur0:shell/db/app.db")

                                sql_db_search_mame = "\"" .. (file.name) .. "\""
                                local query_string = "SELECT title FROM tbl_appinfo_icon where titleid is "  .. sql_db_search_mame
                                sql_db_search_result = Database.execQuery(db, query_string)

                                if next(sql_db_search_result) == nil then
                                    -- Not found
                                    launch_check_app_installed = false
                                else
                                    -- Found
                                    launch_check_app_installed = true
                                end
                                Database.close(db)

                            if launch_check_app_installed == true then
                                table.insert(hidden_games_table, file)
                            end

                        else
                            if System.doesDirExist(file.game_path) then
                                table.insert(hidden_games_table, file)
                            else
                            end
                        end
                        
                    end

                end
            end
        end

    end
end

function count_loading_tasks()

    -- Initial setup

        if Adrenaline_roms == 1 then
            adr_partition = "ux0"
        elseif Adrenaline_roms == 2 then
            adr_partition = "ur0"
        elseif Adrenaline_roms == 3 then
            adr_partition = "imc0"
        elseif Adrenaline_roms == 4 then
            adr_partition = "xmc0"
        else 
            adr_partition = "uma0"
        end

    -- Common functions

            function count_loading_tasks_dir(def_adrenaline_rom_location)
                local files = System.listDirectory((def_adrenaline_rom_location))
                for i, file in pairs(files) do
                    loading_tasks = loading_tasks + 1
                end
            end

            local function add_to_table (def_input_table, def_output_table)
                if next(def_input_table) ~= nil then
                    for i, entry in ipairs(def_input_table) do
                        table.insert(def_output_table, entry)
                    end
                end
            end

    -- Count functions   

            -- Adrenaline Game and ISO folders for PSP and PSX

                if Adrenaline_roms == 1 then
                    adr_partition = "ux0"
                elseif Adrenaline_roms == 2 then
                    adr_partition = "ur0"
                elseif Adrenaline_roms == 3 then
                    adr_partition = "imc0"
                elseif Adrenaline_roms == 4 then
                    adr_partition = "xmc0"
                else 
                    adr_partition = "uma0"
                end

                onelua_scan_required = false

                if Adrenaline_roms == 5 then
                    for k, v in pairs(adr_partition_table) do

                        local game_folder = quickScanGames(tostring(v)  .. ":/pspemu/PSP/GAME", 2, true, ".pbp")
                        if next(game_folder) then
                            add_to_table(game_folder, QuickGameList.adrenaline_games_folder)
                        end
                        local iso_folder = quickScanGames(tostring(v)  .. ":/pspemu/ISO", 2, true, ".iso", ".cso")
                        if next(iso_folder) then
                            add_to_table(iso_folder, QuickGameList.adrenaline_iso_folder)
                        end

                    end
                else
                    local game_folder = quickScanGames(adr_partition  .. ":/pspemu/PSP/GAME", 2, true, ".pbp")
                    if next(game_folder) then
                        add_to_table(game_folder, QuickGameList.adrenaline_games_folder)
                    end

                    local iso_folder = quickScanGames(adr_partition  .. ":/pspemu/ISO", 2, true, ".iso", ".cso")
                    if next(iso_folder) then
                        add_to_table(iso_folder, QuickGameList.adrenaline_iso_folder)
                    end
                end

                QuickGameList.psx_retroarch = quickScanGames(SystemsToScan[4].romFolder, 1, true, ".pbp", ".cue", ".img", ".mdf", ".toc", ".cbn", ".m3u", ".ccd", ".pbp", ".chd")

                if next(QuickGameList.adrenaline_games_folder) ~= nil then
                    for i, file in pairs(QuickGameList.adrenaline_games_folder) do
                        local parent_folder_name = file.path:gsub(".*/([^/]+)/[^/]+$", "%1") -- Returns the parent folder name eg. SCUS94306
                        if sfo_scans_onelua[parent_folder_name] == nil then
                            onelua_scan_required = true
                            break
                        end
                    end
                end
                if next(QuickGameList.adrenaline_iso_folder) ~= nil then
                    for i, file in pairs(QuickGameList.adrenaline_iso_folder) do
                        if sfo_scans_onelua[file.name] == nil then
                            onelua_scan_required = true
                            break
                        end
                    end
                end
                if next(QuickGameList.psx_retroarch) ~= nil then
                    for i, file in pairs(QuickGameList.psx_retroarch) do
                        if string.match(file.name, "%.pbp") or string.match(file.name, "%.PBP") then

                            if file.subfolder then
                                local parent_folder_name = file.path:gsub(".*/([^/]+)/[^/]+$", "%1") -- Returns the parent folder name eg. SCUS94306
                                if sfo_scans_onelua[parent_folder_name] == nil then
                                    onelua_scan_required = true
                                    break
                                end
                            else
                                if sfo_scans_onelua[file.name] == nil then
                                    onelua_scan_required = true
                                    break
                                end
                            end
                        end
                    end
                end

                if onelua_scan_required == true then
                    -- Launch onelua scan to get sfo information from psp and ps1 games
                    delete_onelua_title_files()
                    FreeMemory()
                    System.launchEboot("app0:/launch_scan.bin")
                end

            -- Vita

                QuickGameList.games_table = quickScanVita()
                -- Only inspects directories directly under ux0:/app.
                -- Includes a folder only if the folder name is exactly 9 characters and the file <folder>/sce_sys/param.sfo exists.
                -- Files are excluded (only folders are considered).
                -- If <folder>/menucolor.bin exists, the entry includes adrenaline_bubble = true; otherwise false.

            -- Roms
            
                QuickGameList.n64_table =               quickScanGames(SystemsToScan[5].romFolder, 0)
                QuickGameList.snes_table =              quickScanGames(SystemsToScan[6].romFolder, 0)
                QuickGameList.nes_table =               quickScanGames(SystemsToScan[7].romFolder, 0)
                QuickGameList.gba_table =               quickScanGames(SystemsToScan[8].romFolder, 0)
                QuickGameList.gbc_table =               quickScanGames(SystemsToScan[9].romFolder, 0)
                QuickGameList.gb_table =                quickScanGames(SystemsToScan[10].romFolder, 0)
                QuickGameList.dreamcast_table =         quickScanGames(SystemsToScan[11].romFolder, 1, true, ".cdi", ".gdi")
                QuickGameList.sega_cd_table =           quickScanGames(SystemsToScan[12].romFolder, 1, true, ".chd", ".cue")
                QuickGameList.s32x_table =              quickScanGames(SystemsToScan[13].romFolder, 0)
                QuickGameList.md_table =                quickScanGames(SystemsToScan[14].romFolder, 0)
                QuickGameList.sms_table =               quickScanGames(SystemsToScan[15].romFolder, 0)
                QuickGameList.gg_table =                quickScanGames(SystemsToScan[16].romFolder, 0)
                QuickGameList.tg16_table =              quickScanGames(SystemsToScan[17].romFolder, 0)
                QuickGameList.tgcd_table =              quickScanGames(SystemsToScan[18].romFolder, 0)
                QuickGameList.pce_table =               quickScanGames(SystemsToScan[19].romFolder, 0)
                QuickGameList.pcecd_table =             quickScanGames(SystemsToScan[20].romFolder, 1, true, ".chd", ".cue")
                QuickGameList.amiga_table =             quickScanGames(SystemsToScan[21].romFolder, 0)
                QuickGameList.c64_table =               quickScanGames(SystemsToScan[22].romFolder, 0)
                QuickGameList.wswan_col_table =         quickScanGames(SystemsToScan[23].romFolder, 0)
                QuickGameList.wswan_table =             quickScanGames(SystemsToScan[24].romFolder, 0)
                QuickGameList.msx2_table =              quickScanGames(SystemsToScan[25].romFolder, 0)
                QuickGameList.msx1_table =              quickScanGames(SystemsToScan[26].romFolder, 0)
                QuickGameList.zxs_table =               quickScanGames(SystemsToScan[27].romFolder, 0)
                QuickGameList.atari_7800_table =        quickScanGames(SystemsToScan[28].romFolder, 0)
                QuickGameList.atari_5200_table =        quickScanGames(SystemsToScan[29].romFolder, 0)
                QuickGameList.atari_2600_table =        quickScanGames(SystemsToScan[30].romFolder, 0)
                QuickGameList.atari_lynx_table =        quickScanGames(SystemsToScan[31].romFolder, 0)
                QuickGameList.colecovision_table =      quickScanGames(SystemsToScan[32].romFolder, 0)
                QuickGameList.vectrex_table =           quickScanGames(SystemsToScan[33].romFolder, 0)
                QuickGameList.fba_table =               quickScanGames(SystemsToScan[34].romFolder, 0)
                QuickGameList.mame_2003_plus_table =    quickScanGames(SystemsToScan[35].romFolder, 0)
                QuickGameList.mame_2000_table =         quickScanGames(SystemsToScan[36].romFolder, 0)
                QuickGameList.neogeo_table =            quickScanGames(SystemsToScan[37].romFolder, 0)
                QuickGameList.ngpc_table =              quickScanGames(SystemsToScan[38].romFolder, 0)
                QuickGameList.pico8_table =             quickScanGames(SystemsToScan[41].romFolder, 1, true, ".png")
                QuickGameList.nds_table =               quickScanGames(SystemsToScan[43].romFolder, 0, true, ".nds")
                -- QuickGameList.psm_table =               System.listDirectory("ux0:/psm")

            -- PSM
                QuickGameList.psm_table =               System.listDirectory("ux0:/psm")

            -- System apps

                local sys_app_directory = "vs0:/app"

                -- The sys app filter list
                local filterList = {
                    NPXS10000 = true,
                    NPXS10001 = true,
                    NPXS10002 = true,
                    NPXS10003 = true,
                    NPXS10004 = true,
                    NPXS10006 = true,
                    NPXS10008 = true,
                    NPXS10009 = true,
                    NPXS10010 = true,
                    NPXS10012 = true,
                    NPXS10013 = true,
                    NPXS10014 = true,
                    NPXS10015 = true,
                    NPXS10026 = true,
                    NPXS10072 = true,
                    NPXS10078 = true,
                    NPXS10091 = true,
                    NPXS10094 = true,
                    NPXS10098 = true
                }

                -- Get directory listing
                local sys_app_directory_list = System.listDirectory(sys_app_directory)

                -- Add to sysapps_table table if matches filter
                for i, entry in ipairs(sys_app_directory_list) do
                    if filterList[entry.name] then
                        table.insert(QuickGameList.sysapps_table, entry)
                    end
                end


            -- Count Playstation Mobile

                if System.doesDirExist("ux0:/psm") then
                    count_loading_tasks_dir("ux0:/psm")
                else
                end

            
            -- Count scummvm - read ini and add to table to be iterated in the main scan function

                if System.doesFileExist("ux0:/data/scummvm/scummvm.ini") then
                    scummvm_ini_contents = readAll("ux0:/data/scummvm/scummvm.ini")

                    local function tovector_scummvm(s)
                        scummvm_ini_section = {}
                        -- s:gsub("\n", " "):gsub("%[(%w*)%]", function(n) scummvm_ini_section[#scummvm_ini_section+1] = tostring(n) end)
                        s:gsub("\n", " "):gsub("(%[.-%])", function(n) scummvm_ini_section[#scummvm_ini_section+1] = tostring(n:gsub("%[", ""):gsub("%]", "")) end)
                        return scummvm_ini_section
                    end

                    scummvm_ini_section = tovector_scummvm(scummvm_ini_contents)
                    
                    for k, v in pairs (scummvm_ini_section) do
                        file = {}
                        file.gameid = ini.read("ux0:/data/scummvm/scummvm.ini",tostring(v),"gameid","exclude_game")
                        file.path = ini.read("ux0:/data/scummvm/scummvm.ini",tostring(v),"path","exclude_game")
                        if not string.match(file.gameid, "exclude_game") then
                            table.insert(scan_scummvm_db, file)
                            loading_tasks = loading_tasks + 1
                        end
                    end
                end


        -- Get total count of QuickGameList loading screen
            for k, v in pairs(QuickGameList) do
                if type(v) == "table" then
                    loading_tasks = loading_tasks + #v
                end
            end
end

function update_loading_screen_progress(def)

    loading_progress = loading_progress + 1

    Graphics.initBlend()
    Screen.clear()
    Graphics.drawImage(0, 0, loadingImage)

    local loading_bar_width = 300
    local loading_percent = (loading_progress / loading_tasks) * 100
    local loading_percent_width = (loading_bar_width / 100) * loading_percent

    -- Set max width
    if loading_percent_width >= loading_bar_width then
        loading_percent_width = loading_bar_width
    end

    -- debug print:
        -- PrintCentered(fnt20, 480, 445, lang_lines.Scanning_games_ellipsis .. " - " .. tostring(def), white, 20) -- Scanning games...

    -- normal print:
        PrintCentered(fnt20, 480, 445, lang_lines.Scanning_games_ellipsis, white, 20) -- Scanning games...

    -- Progress bar background
    Graphics.fillRect(330, 630, 490, 496, loading_bar_bg)

    -- Progress bar percent
    Graphics.fillRect(330, 330 + loading_percent_width, 490, 496, white)

    Graphics.termBlend()
    Screen.flip()
    Screen.clear()
end

function update_loading_screen_complete()

    loading_progress = loading_tasks -- set to tasks to move to 100% if stuck)

    Graphics.initBlend()
    Screen.clear()
    Graphics.drawImage(0, 0, loadingImage)

    local loading_bar_width = 300
    local loading_percent = (loading_progress / loading_tasks) * 100
    local loading_percent_width = (loading_bar_width / 100) * loading_percent

    PrintCentered(fnt20, 480, 445, lang_lines.Scan_complete, white, 20) -- Scan complete 

    -- Progress bar background
    Graphics.fillRect(330, 630, 490, 496, loading_bar_bg)

    -- Progress bar percent
    Graphics.fillRect(330, 330 + loading_percent_width, 490, 496, white)

    Graphics.termBlend()
    Screen.flip()
    Screen.clear()
end


function Full_Game_Scan()
    -- dir = System.listDirectory(dir)
    -- vita_table = {}
    folders_table = {}
    files_table = {}
    games_table = {}
    homebrews_table = {}
    psp_table = {}
    psx_table = {}
    n64_table = {}
    snes_table = {}
    nes_table = {}
    nds_table = {}
    gba_table = {}
    gbc_table = {}
    gb_table = {}
    dreamcast_table = {}
    sega_cd_table = {}
    s32x_table = {}
    md_table = {}
    sms_table = {}
    gg_table = {}
    tg16_table = {}
    tgcd_table = {}
    pce_table = {}
    pcecd_table = {}
    amiga_table = {}
    c64_table = {}
    wswan_col_table = {}
    wswan_table = {}
    msx2_table = {}
    msx1_table = {}
    zxs_table = {}
    atari_7800_table = {}
    atari_5200_table = {}
    atari_2600_table = {}
    atari_lynx_table = {}
    colecovision_table = {}
    vectrex_table = {}
    fba_table = {}
    mame_2003_plus_table = {}
    mame_2000_table = {}
    neogeo_table = {} 
    ngpc_table = {}
    psm_table = {}
    scummvm_table = {}
    pico8_table = {}
    sysapps_table = {}
    recently_played_table = {}
    search_results_table = {}
    fav_count = {}
    renamed_games_table = {}
    hidden_games_table = {}
    files_table_no_sysapps = {}

    -- Quickly scan cover directory
        QuickDoesFileExist.covDir = quickScanFiles(covDir, 1, true, ".png")

    loading_progress = 0
    local customCategory = 0
    
    local file_over = System.openFile(cur_dir .. "/overrides.dat", FREAD)
    local filesize = System.sizeFile(file_over)
    local str = System.readFile(file_over, filesize)
    System.closeFile(file_over)

    local fileFav_over = System.openFile(cur_dir .. "/favorites.dat", FREAD)
    local fileFavsize = System.sizeFile(fileFav_over)
    local strFav = System.readFile(fileFav_over, fileFavsize)
    System.closeFile(fileFav_over)


    import_renamed_games()
    import_hidden_games()

    -- Tables to save scanned sfo's
    local new_sfo_cache_table_vita = {}
    

    -- SCAN FUNCTIONS

        function scan_Vita (def_table_name)
            if next(QuickGameList.games_table) == nil then
                else

                for i, file in pairs(QuickGameList.games_table) do

                    local custom_path, custom_path_id, app_type = nil, nil, nil

                    -- Set sfo_read_success to false if sfo is corrupt and cannot be read
                    local sfo_read_success = true

                    if not string.match(file.name, "RETROFLOW") -- Don't index Retroflow
                        and not string.match(file.name, "RETROLNCR") -- Don't index Retroflow Adrenaline Launcher
                        and not string.match(file.name, "ADRLANCHR") -- Don't index Adrenaline Launcher
                        and not string.match(file.name, "PSPEMU" .. "%d") -- Don't index PSPEMU001 games, but include PSPEMUCFW (Adrenaline)
                        then

                        -- Check for cached SFO info
                        sfo_search = sfo_scan_vita_db[file.name]

                        if sfo_search == nil then

                            -- SFO not cached: try to extract the SFO file safely
                            if System.doesFileExist(working_dir .. "/" .. file.name .. "/sce_sys/param.sfo") then

                                -- Try to extract the SFO file safely
                                local sfo_read, info = pcall(System.extractSfo, working_dir .. "/" .. file.name .. "/sce_sys/param.sfo")

                                if not sfo_read then
                                    sfo_read_success = false
                                else
                                    sfo_read_success = true
                                end


                                if sfo_read_success == true then
                                    -- Determine the app title to use, if short title empty, use title, if title also empty use "-"
                                    -- local app_title
                                    if info.short_title and info.short_title:match("%S") then
                                        app_title = info.short_title
                                    elseif info.title and info.title:match("%S") then
                                        app_title = info.title
                                    else
                                        app_title = "-"
                                    end

                                    -- Clean up the title
                                    app_title = app_title:gsub("\n"," "):gsub("™",""):gsub(" ®",""):gsub("®","")

                                    file.titleid = tostring(info.titleid)
                                    file.version = tostring(info.version)
                                else
                                end

                            end
                        else
                            -- SFO found in title cache
                            app_title = sfo_scan_vita_db[file.name].title or "UNK"
                            file.titleid = sfo_scan_vita_db[file.name].titleid or "UNK"
                            file.version = sfo_scan_vita_db[file.name].version or "UNK"
                            sfo_read_success = true
                        end

                        if sfo_read_success == true then

                            -- Don't scan PSP and PSX Bubbles
                            if string.match(file.name, "PSPEMUCFW") then
                                file.adrenaline_bubble = false
                            end
                        
                            -- check if game is in the favorites list
                            if System.doesFileExist(cur_dir .. "/favorites.dat") then
                                if string.find(strFav, file.name,1,true) ~= nil then
                                    file.favourite = true
                                else
                                    file.favourite = false
                                end
                            end


                            file.game_path = (working_dir .. "/" .. file.name)

                            file.filename = file.name
                            file.name = file.name
                            file.title = app_title
                            file.name_online = file.name
                            file.version = file.version
                            file.name_title_search = file.name
                            file.apptitle = app_title
                            file.date_played = 0
                            -- file.directory = true

                            -- Check for renamed game names
                            if #renamed_games_table ~= nil then
                                local key = find_game_table_pos_key(renamed_games_table, file.titleid)
                                if key ~= nil then
                                  -- Yes - Find in files table
                                  app_title = renamed_games_table[key].title
                                  file.title = renamed_games_table[key].title
                                  file.apptitle = renamed_games_table[key].title
                                else
                                  -- No
                                end
                            else
                            end
                            

                            -- Robust filtering: skip adrenaline bubbles early
                            if file.adrenaline_bubble == true then
                                update_loading_screen_progress(loading_progress)
                                goto continue

                            else

                                if string.match(file.name, "PCS") and not string.match(file.name, "PCSI") then
                                    
                                    
                                    --CHECK FOR OVERRIDDEN CATEGORY of VITA game
                                    if System.doesFileExist(cur_dir .. "/overrides.dat") then
                                        
                                        --0 default, 1 vita, 2 psp, 3 psx, 4 homebrew
                                        file.app_type_default=1

                                        -- VITA
                                        if string.match(str, file.name .. "=1") then
                                            table.insert(games_table, file)

                                            table.insert(folders_table, file)
                                            file.app_type=1

                                            -- Check for hidden game names
                                            file.hidden = check_for_hidden_tag_on_scan(file.titleid, file.app_type)

                                            file.cover_path_online = SystemsToScan[1].onlineCoverPathSystem
                                            file.cover_path_local = SystemsToScan[1].localCoverPath
                                            file.snap_path_online = SystemsToScan[1].onlineSnapPathSystem
                                            file.snap_path_local = SystemsToScan[1].localSnapPath

                                            if SystemsToScan[1].localCoverPath .. app_title .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[1].localCoverPath .. app_title .. ".png"] then
                                                img_path = SystemsToScan[1].localCoverPath .. app_title .. ".png" --custom cover by app name
                                                file.cover = true
                                            elseif SystemsToScan[1].localCoverPath .. file.name .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[1].localCoverPath .. file.name .. ".png"] then
                                                img_path = SystemsToScan[1].localCoverPath .. file.name .. ".png" --custom cover by app id
                                                file.cover = true
                                            else
                                                if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                                                    img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
                                                    file.cover = true
                                                else
                                                    img_path = "app0:/DATA/noimg.png" --blank grey
                                                    file.cover = false
                                                end
                                            end

                                        -- PSP
                                        elseif string.match(str, file.name .. "=2") then
                                            table.insert(psp_table, file)

                                            table.insert(folders_table, file)
                                            file.app_type=2

                                            -- Check for hidden game names
                                            file.hidden = check_for_hidden_tag_on_scan(file.titleid, file.app_type)

                                            file.cover_path_online = SystemsToScan[3].onlineCoverPathSystem
                                            file.cover_path_local = SystemsToScan[3].localCoverPath
                                            file.snap_path_online = SystemsToScan[3].onlineSnapPathSystem
                                            file.snap_path_local = SystemsToScan[3].localSnapPath

                                            if SystemsToScan[3].localCoverPath .. app_title .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[3].localCoverPath .. app_title .. ".png"] then
                                                img_path = SystemsToScan[3].localCoverPath .. app_title .. ".png" --custom cover by app name
                                                file.cover = true
                                            elseif SystemsToScan[3].localCoverPath .. file.name .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[3].localCoverPath .. file.name .. ".png"] then
                                                img_path = SystemsToScan[3].localCoverPath .. file.name .. ".png" --custom cover by app id
                                                file.cover = true
                                            else
                                                if System.doesFileExist("app0:/DATA/missing_cover_psp.png") then
                                                    img_path = "app0:/DATA/missing_cover_psp.png"  --app icon
                                                    file.cover = false
                                                else
                                                    img_path = "app0:/DATA/noimg.png" --blank grey
                                                    file.cover = false
                                                end
                                            end

                                        -- PSX
                                        elseif string.match(str, file.name .. "=3") then
                                            table.insert(psx_table, file)

                                            table.insert(folders_table, file)
                                            file.app_type=3

                                            -- Check for hidden game names
                                            file.hidden = check_for_hidden_tag_on_scan(file.titleid, file.app_type)

                                            file.cover_path_online = SystemsToScan[4].onlineCoverPathSystem
                                            file.cover_path_local = SystemsToScan[4].localCoverPath
                                            file.snap_path_online = SystemsToScan[4].onlineSnapPathSystem
                                            file.snap_path_local = SystemsToScan[4].localSnapPath

                                            if SystemsToScan[4].localCoverPath .. app_title .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[4].localCoverPath .. app_title .. ".png"] then
                                                img_path = SystemsToScan[4].localCoverPath .. app_title .. ".png" --custom cover by app name
                                                file.cover = true
                                            elseif SystemsToScan[4].localCoverPath .. file.name .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[4].localCoverPath .. file.name .. ".png"] then
                                                img_path = SystemsToScan[4].localCoverPath .. file.name .. ".png" --custom cover by app id
                                                file.cover = true
                                            else
                                                if System.doesFileExist("app0:/DATA/missing_cover_psx.png") then
                                                    img_path = "app0:/DATA/missing_cover_psx.png"  --app icon
                                                    file.cover = false
                                                else
                                                    img_path = "app0:/DATA/noimg.png" --blank grey
                                                    file.cover = false
                                                end
                                            end

                                        -- HOMEBREW
                                        elseif string.match(str, file.name .. "=4") then
                                            -- Homebrew
                                            table.insert(homebrews_table, file)

                                            table.insert(folders_table, file)
                                            file.app_type=0

                                            -- Check for hidden game names
                                            file.hidden = check_for_hidden_tag_on_scan(file.titleid, file.app_type)

                                            file.cover_path_online = SystemsToScan[2].onlineCoverPathSystem
                                            file.cover_path_local = SystemsToScan[2].localCoverPath
                                            file.snap_path_online = SystemsToScan[2].onlineSnapPathSystem
                                            file.snap_path_local = SystemsToScan[2].localSnapPath

                                            if SystemsToScan[2].localCoverPath .. app_title .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[2].localCoverPath .. app_title .. ".png"] then
                                                img_path = SystemsToScan[2].localCoverPath .. app_title .. ".png" --custom cover by app name
                                                file.cover = true
                                            elseif SystemsToScan[2].localCoverPath .. file.name .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[2].localCoverPath .. file.name .. ".png"] then
                                                img_path = SystemsToScan[2].localCoverPath .. file.name .. ".png" --custom cover by app id
                                                file.cover = true
                                            else
                                                if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                                                    img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
                                                    file.cover = true
                                                else
                                                    img_path = "app0:/DATA/noimg.png" --blank grey
                                                    file.cover = false
                                                end
                                            end

                                        -- DEFAULT - VITA
                                        else
                                            table.insert(games_table, file)

                                            table.insert(folders_table, file)
                                            file.app_type=1

                                            -- Check for hidden game names
                                            file.hidden = check_for_hidden_tag_on_scan(file.titleid, file.app_type)

                                            file.cover_path_local = SystemsToScan[1].localCoverPath
                                            file.cover_path_online = SystemsToScan[1].onlineCoverPathSystem
                                            file.snap_path_online = SystemsToScan[1].onlineSnapPathSystem
                                            file.snap_path_local = SystemsToScan[1].localSnapPath

                                            if SystemsToScan[1].localCoverPath .. app_title .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[1].localCoverPath .. app_title .. ".png"] then
                                                img_path = SystemsToScan[1].localCoverPath .. app_title .. ".png" --custom cover by app name
                                                file.cover = true
                                            elseif SystemsToScan[1].localCoverPath .. file.name .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[1].localCoverPath .. file.name .. ".png"] then
                                                img_path = SystemsToScan[1].localCoverPath .. file.name .. ".png" --custom cover by app id
                                                file.cover = true
                                            else
                                                if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                                                    img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
                                                    file.cover = true
                                                else
                                                    img_path = "app0:/DATA/noimg.png" --blank grey
                                                    file.cover = false
                                                end
                                            end

                                        end

                                    -- NO OVERRIDE - VITA
                                    else
                                        table.insert(games_table, file)

                                        table.insert(folders_table, file)
                                        file.app_type=1

                                        -- Check for hidden game names
                                        file.hidden = check_for_hidden_tag_on_scan(file.titleid, file.app_type)

                                        file.cover_path_online = SystemsToScan[1].onlineCoverPathSystem
                                        file.cover_path_local = SystemsToScan[1].localCoverPath
                                        file.snap_path_online = SystemsToScan[1].onlineSnapPathSystem
                                        file.snap_path_local = SystemsToScan[1].localSnapPath

                                        if SystemsToScan[1].localCoverPath .. app_title .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[1].localCoverPath .. app_title .. ".png"] then
                                            img_path = SystemsToScan[1].localCoverPath .. app_title .. ".png" --custom cover by app name
                                            file.cover = true
                                        elseif SystemsToScan[1].localCoverPath .. file.name .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[1].localCoverPath .. file.name .. ".png"] then
                                            img_path = SystemsToScan[1].localCoverPath .. file.name .. ".png" --custom cover by app id
                                            file.cover = true
                                        else
                                            if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                                                img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
                                                file.cover = true
                                            else
                                                img_path = "app0:/DATA/noimg.png" --blank grey
                                                file.cover = false
                                            end
                                        end

                                    end
                                    --END OVERRIDDEN CATEGORY of Vita game

                                else
                                    
                                    file.app_type_default=0
                                --CHECK FOR OVERRIDDEN CATEGORY of HOMEBREW game
                                    if System.doesFileExist(cur_dir .. "/overrides.dat") then
                                        --0 default, 1 vita, 2 psp, 3 psx, 4 homebrew

                                        -- VITA
                                        if string.match(str, file.name .. "=1") then
                                            table.insert(games_table, file)

                                            table.insert(folders_table, file)
                                            file.app_type=1

                                            -- Check for hidden game names
                                            file.hidden = check_for_hidden_tag_on_scan(file.titleid, file.app_type)

                                            file.cover_path_online = SystemsToScan[1].onlineCoverPathSystem
                                            file.cover_path_local = SystemsToScan[1].localCoverPath
                                            file.snap_path_online = SystemsToScan[1].onlineSnapPathSystem
                                            file.snap_path_local = SystemsToScan[1].localSnapPath

                                            if SystemsToScan[1].localCoverPath .. app_title .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[1].localCoverPath .. app_title .. ".png"] then
                                                img_path = SystemsToScan[1].localCoverPath .. app_title .. ".png" --custom cover by app name
                                                file.cover = true
                                            elseif SystemsToScan[1].localCoverPath .. file.name .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[1].localCoverPath .. file.name .. ".png"] then
                                                img_path = SystemsToScan[1].localCoverPath .. file.name .. ".png" --custom cover by app id
                                                file.cover = true
                                            else
                                                if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                                                    img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
                                                else
                                                    img_path = "app0:/DATA/missing_cover_psv.png" --blank grey
                                                    file.cover = false
                                                end
                                            end

                                        -- PSP
                                        elseif string.match(str, file.name .. "=2") then
                                            table.insert(psp_table, file)

                                            table.insert(folders_table, file)
                                            file.app_type=2

                                            -- Check for hidden game names
                                            file.hidden = check_for_hidden_tag_on_scan(file.titleid, file.app_type)

                                            file.cover_path_online = SystemsToScan[3].onlineCoverPathSystem
                                            file.cover_path_local = SystemsToScan[3].localCoverPath
                                            file.snap_path_online = SystemsToScan[3].onlineSnapPathSystem
                                            file.snap_path_local = SystemsToScan[3].localSnapPath

                                            if SystemsToScan[3].localCoverPath .. app_title .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[3].localCoverPath .. app_title .. ".png"] then
                                                img_path = SystemsToScan[3].localCoverPath .. app_title .. ".png" --custom cover by app name
                                                file.cover = true
                                            elseif SystemsToScan[3].localCoverPath .. file.name .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[3].localCoverPath .. file.name .. ".png"] then
                                                img_path = SystemsToScan[3].localCoverPath .. file.name .. ".png" --custom cover by app id
                                                file.cover = true
                                            else
                                                if System.doesFileExist("app0:/DATA/missing_cover_psp.png") then
                                                    img_path = "app0:/DATA/missing_cover_psp.png"  --app icon
                                                    file.cover = false
                                                else
                                                    img_path = "app0:/DATA/noimg.png" --blank grey
                                                    file.cover = false
                                                end
                                            end
                                        
                                        -- PSX
                                        elseif string.match(str, file.name .. "=3") then
                                            table.insert(psx_table, file)

                                            table.insert(folders_table, file)
                                            file.app_type=3

                                            -- Check for hidden game names
                                            file.hidden = check_for_hidden_tag_on_scan(file.titleid, file.app_type)

                                            file.cover_path_online = SystemsToScan[4].onlineCoverPathSystem
                                            file.cover_path_local = SystemsToScan[4].localCoverPath
                                            file.snap_path_online = SystemsToScan[4].onlineSnapPathSystem
                                            file.snap_path_local = SystemsToScan[4].localSnapPath

                                            if SystemsToScan[4].localCoverPath .. app_title .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[4].localCoverPath .. app_title .. ".png"] then
                                                img_path = SystemsToScan[4].localCoverPath .. app_title .. ".png" --custom cover by app name
                                                file.cover = true
                                            elseif SystemsToScan[4].localCoverPath .. file.name .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[4].localCoverPath .. file.name .. ".png"] then
                                                img_path = SystemsToScan[4].localCoverPath .. file.name .. ".png" --custom cover by app id
                                                file.cover = true
                                            else
                                                if System.doesFileExist("app0:/DATA/missing_cover_psx.png") then
                                                    img_path = "app0:/DATA/missing_cover_psx.png"  --app icon
                                                    file.cover = false
                                                else
                                                    img_path = "app0:/DATA/noimg.png" --blank grey
                                                    file.cover = false
                                                end
                                            end


                                        -- HOMEBREW
                                        elseif string.match(str, file.name .. "=4") then
                                            table.insert(homebrews_table, file)

                                            table.insert(folders_table, file)
                                            file.app_type=0

                                            -- Check for hidden game names
                                            file.hidden = check_for_hidden_tag_on_scan(file.titleid, file.app_type)

                                            file.cover_path_online = SystemsToScan[2].onlineCoverPathSystem
                                            file.cover_path_local = SystemsToScan[2].localCoverPath
                                            file.snap_path_online = SystemsToScan[2].onlineSnapPathSystem
                                            file.snap_path_local = SystemsToScan[2].localSnapPath

                                            if SystemsToScan[2].localCoverPath .. app_title .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[2].localCoverPath .. app_title .. ".png"] then
                                                img_path = SystemsToScan[2].localCoverPath .. app_title .. ".png" --custom cover by app name
                                                file.cover = true
                                            elseif SystemsToScan[2].localCoverPath .. file.name .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[2].localCoverPath .. file.name .. ".png"] then
                                                img_path = SystemsToScan[2].localCoverPath .. file.name .. ".png" --custom cover by app id
                                                file.cover = true
                                            else
                                                if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                                                    img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
                                                    file.cover = true
                                                else
                                                    img_path = "app0:/DATA/noimg.png" --blank grey
                                                    file.cover = false
                                                end
                                            end

                                        -- DEFAULT - HOMEBREW
                                        else
                                            table.insert(homebrews_table, file)

                                            table.insert(folders_table, file)
                                            file.app_type=0

                                            -- Check for hidden game names
                                            file.hidden = check_for_hidden_tag_on_scan(file.titleid, file.app_type)

                                            file.cover_path_online = SystemsToScan[2].onlineCoverPathSystem
                                            file.cover_path_local = SystemsToScan[2].localCoverPath
                                            file.snap_path_online = SystemsToScan[2].onlineSnapPathSystem
                                            file.snap_path_local = SystemsToScan[2].localSnapPath

                                            if SystemsToScan[2].localCoverPath .. app_title .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[2].localCoverPath .. app_title .. ".png"] then
                                                img_path = SystemsToScan[2].localCoverPath .. app_title .. ".png" --custom cover by app name
                                                file.cover = true
                                            elseif SystemsToScan[2].localCoverPath .. file.name .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[2].localCoverPath .. file.name .. ".png"] then
                                                img_path = SystemsToScan[2].localCoverPath .. file.name .. ".png" --custom cover by app id
                                                file.cover = true
                                            else
                                                if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                                                    img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
                                                    file.cover = true
                                                else
                                                    img_path = "app0:/DATA/noimg.png" --blank grey
                                                    file.cover = false
                                                end
                                            end
                                        end

                                    -- NO OVERRIDE - HOMEBREW
                                    else
                                        table.insert(homebrews_table, file)

                                        table.insert(folders_table, file)
                                        file.app_type=0

                                        -- Check for hidden game names
                                        file.hidden = check_for_hidden_tag_on_scan(file.titleid, file.app_type)

                                        file.cover_path_online = SystemsToScan[2].onlineCoverPathSystem
                                        file.cover_path_local = SystemsToScan[2].localCoverPath
                                        file.snap_path_online = SystemsToScan[2].onlineSnapPathSystem
                                        file.snap_path_local = SystemsToScan[2].localSnapPath

                                        if SystemsToScan[2].localCoverPath .. app_title .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[2].localCoverPath .. app_title .. ".png"] then
                                            img_path = SystemsToScan[2].localCoverPath .. app_title .. ".png" --custom cover by app name
                                            file.cover = true
                                        elseif SystemsToScan[2].localCoverPath .. file.name .. ".png" and QuickDoesFileExist.covDir[SystemsToScan[2].localCoverPath .. file.name .. ".png"] then
                                            img_path = SystemsToScan[2].localCoverPath .. file.name .. ".png" --custom cover by app id
                                            file.cover = true
                                        else
                                            if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                                                img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
                                                file.cover = true
                                            else
                                                img_path = "app0:/DATA/noimg.png" --blank grey
                                                file.cover = false
                                            end
                                        end

                                    end
                                    --END OVERRIDDEN CATEGORY of homebrew
                                end

                                table.insert(files_table, count_of_systems, file.app_type)  

                                update_loading_screen_progress(loading_progress)
                                
                                --add blank icon to all
                                file.icon = imgCoverTmp
                                file.icon_path = img_path
                                
                                table.insert(files_table, count_of_systems, file.icon) 
                                table.insert(files_table, count_of_systems, file.apptitle)

                            end

                            ::continue::
                            -- Added for caching sfo scan results
                            table.insert(new_sfo_cache_table_vita, file)

                        else
                        end

                    end

                end
                    
            end

        end

        function scan_PSP_iso_folder (def_adrenaline_rom_location)

            if  System.doesDirExist(def_adrenaline_rom_location) then

                if next(sfo_scans_onelua) == nil then
                else

                    if next(QuickGameList.adrenaline_iso_folder) ~= nil then

                        for i, file in pairs(QuickGameList.adrenaline_iso_folder) do
                            -- local custom_path, custom_path_id, app_type, name, name_online, version, name_title_search = nil, nil, nil, nil, nil, nil, nil

                            if file.path and string.match(file.path, def_adrenaline_rom_location) then

                                -- Get the SFO info from sfo_scans_onelua
                                if sfo_scans_onelua[file.name] ~= nil then

                                    file.title = sfo_scans_onelua[file.name].title or "UNK"
                                    file.titleid = sfo_scans_onelua[file.name].titleid or "UNK"
                                    file.category = sfo_scans_onelua[file.name].category or "UNK"
                                    file.version = sfo_scans_onelua[file.name].region or "UNK"

                                    -- CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME, PBOOT.PBP PG 

                                    -- PSP Official and PSP Homebrew only

                                    if file.category == nil then
                                        -- Legacy fix
                                        delete_cache()
                                        FreeMemory()
                                        Network.term()
                                        dofile("app0:index.lua")

                                    elseif string.match(file.category, "UG") or string.match(file.category, "MG") or string.match(file.category, "EG") then

                                        -- check if game is in the favorites list
                                        if System.doesFileExist(cur_dir .. "/favorites.dat") then
                                            if string.find(strFav, file.name,1,true) ~= nil then
                                                file.favourite = true
                                            elseif string.find(strFav, file.titleid,1,true) ~= nil then
                                                file.favourite = true
                                            else
                                                file.favourite = false
                                            end
                                        end

                                        -- file.launch_argument = ("PATH=ms0:/ISO/" .. file.name)
                                        file.game_path = file.path
                                        file.date_played = 0
                                        file.app_type_default=2

                                        info = file.title
                                        app_title = file.title
                                        file.filename = file.name
                                        file.name = file.titleid
                                        file.title = file.title
                                        file.name_online = file.titleid
                                        file.name_title_search = file.title
                                        file.apptitle = file.title
                                        file.directory = false
                                        file.category = file.category

                                        -- Check for renamed game names
                                        if #renamed_games_table ~= nil then
                                            local key = find_game_table_pos_key(renamed_games_table, file.name)
                                            if key ~= nil then
                                              -- Yes - Find in files table
                                              app_title = renamed_games_table[key].title
                                              file.title = renamed_games_table[key].title
                                              file.apptitle = renamed_games_table[key].title
                                            else
                                              -- No
                                            end
                                        else
                                        end

                                        custom_path = SystemsToScan[3].localCoverPath .. app_title .. ".png"
                                        custom_path_id = SystemsToScan[3].localCoverPath .. file.name .. ".png"

                                        -- OVERRIDES START

                                            if System.doesFileExist(cur_dir .. "/overrides.dat") then
                                                --String:   1 vita, 2 psp, 3 psx, 4 homebrew
                                                --App_type: 1 vita, 2 psp, 3 psx, 0 homebrew                         

                                                -- VITA
                                                if string.match(str, file.name .. "=1") then
                                                    table.insert(games_table, file)

                                                    table.insert(folders_table, file)
                                                    file.app_type=1

                                                    -- Check for hidden game names
                                                    file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                    custom_path = SystemsToScan[1].localCoverPath .. app_title .. ".png"
                                                    custom_path_id = SystemsToScan[1].localCoverPath .. file.name .. ".png"

                                                    file.cover_path_online = SystemsToScan[1].onlineCoverPathSystem
                                                    file.cover_path_local = SystemsToScan[1].localCoverPath
                                                    file.snap_path_online = SystemsToScan[1].onlineSnapPathSystem
                                                    file.snap_path_local = SystemsToScan[1].localSnapPath

                                                    if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                        img_path = custom_path --custom cover by app name
                                                        file.cover = true
                                                    elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                        img_path = custom_path_id --custom cover by app id
                                                        file.cover = true
                                                    else
                                                        if System.doesFileExist("app0:/DATA/missing_cover_psv.png") then
                                                            img_path = "app0:/DATA/missing_cover_psv.png"  --app icon
                                                            file.cover = false
                                                        else
                                                            img_path = "app0:/DATA/noimg.png" --blank grey
                                                            file.cover = false
                                                        end
                                                    end

                                                -- PSP
                                                elseif string.match(str, file.name .. "=2") then
                                                    table.insert(psp_table, file)

                                                    table.insert(folders_table, file)
                                                    file.app_type=2

                                                    -- Check for hidden game names
                                                    file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                    custom_path = SystemsToScan[3].localCoverPath .. app_title .. ".png"
                                                    custom_path_id = SystemsToScan[3].localCoverPath .. file.name .. ".png"

                                                    file.cover_path_online = SystemsToScan[3].onlineCoverPathSystem
                                                    file.cover_path_local = SystemsToScan[3].localCoverPath
                                                    file.snap_path_online = SystemsToScan[3].onlineSnapPathSystem
                                                    file.snap_path_local = SystemsToScan[3].localSnapPath

                                                    if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                        img_path = custom_path --custom cover by app name
                                                        file.cover = true
                                                    elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                        img_path = custom_path_id --custom cover by app id
                                                        file.cover = true
                                                    else
                                                        if System.doesFileExist("app0:/DATA/missing_cover_psp.png") then
                                                            img_path = "app0:/DATA/missing_cover_psp.png"  --app icon
                                                            file.cover = false
                                                        else
                                                            img_path = "app0:/DATA/noimg.png" --blank grey
                                                            file.cover = false
                                                        end
                                                    end
                                                
                                                -- PSX
                                                elseif string.match(str, file.name .. "=3") then
                                                    table.insert(psx_table, file)

                                                    table.insert(folders_table, file)
                                                    file.app_type=3

                                                    -- Check for hidden game names
                                                    file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                    custom_path = SystemsToScan[4].localCoverPath .. app_title .. ".png"
                                                    custom_path_id = SystemsToScan[4].localCoverPath .. file.name .. ".png"

                                                    file.cover_path_online = SystemsToScan[4].onlineCoverPathSystem
                                                    file.cover_path_local = SystemsToScan[4].localCoverPath
                                                    file.snap_path_online = SystemsToScan[4].onlineSnapPathSystem
                                                    file.snap_path_local = SystemsToScan[4].localSnapPath

                                                    if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                        img_path = custom_path --custom cover by app name
                                                        file.cover = true
                                                    elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                        img_path = custom_path_id --custom cover by app id
                                                        file.cover = true
                                                    else
                                                        if System.doesFileExist("app0:/DATA/missing_cover_psx.png") then
                                                            img_path = "app0:/DATA/missing_cover_psx.png"  --app icon
                                                            file.cover = false
                                                        else
                                                            img_path = "app0:/DATA/noimg.png" --blank grey
                                                            file.cover = false
                                                        end
                                                    end

                                                -- HOMEBREW
                                                elseif string.match(str, file.name .. "=4") then
                                                    table.insert(homebrews_table, file)

                                                    table.insert(folders_table, file)
                                                    file.app_type=0

                                                    -- Check for hidden game names
                                                    file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                    custom_path = "ux0:/data/RetroFlow/COVERS/Homebrew/" .. app_title .. ".png"
                                                    custom_path_id = SystemsToScan[2].localCoverPath .. file.name .. ".png"

                                                    file.cover_path_online = SystemsToScan[2].onlineCoverPathSystem
                                                    file.cover_path_local = SystemsToScan[2].localCoverPath
                                                    file.snap_path_online = SystemsToScan[2].onlineSnapPathSystem
                                                    file.snap_path_local = SystemsToScan[2].localSnapPath

                                                    if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                        img_path = custom_path --custom cover by app name
                                                        file.cover = true
                                                    elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                        img_path = custom_path_id --custom cover by app id
                                                        file.cover = true
                                                    else
                                                        if System.doesFileExist("app0:/DATA/icon_homebrew.png") then
                                                            img_path = "app0:/DATA/icon_homebrew.png"  --app icon
                                                            file.cover = false
                                                        else
                                                            img_path = "app0:/DATA/noimg.png" --blank grey
                                                            file.cover = false
                                                        end
                                                    end

                                                -- DEFAULT - PSP
                                                else
                                                    table.insert(psp_table, file)

                                                    table.insert(folders_table, file)
                                                    file.app_type=2

                                                    -- Check for hidden game names
                                                    file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                    custom_path = SystemsToScan[3].localCoverPath .. app_title .. ".png"
                                                    custom_path_id = SystemsToScan[3].localCoverPath .. file.name .. ".png"

                                                    file.cover_path_online = SystemsToScan[3].onlineCoverPathSystem
                                                    file.cover_path_local = SystemsToScan[3].localCoverPath
                                                    file.snap_path_online = SystemsToScan[3].onlineSnapPathSystem
                                                    file.snap_path_local = SystemsToScan[3].localSnapPath

                                                    if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                        img_path = custom_path --custom cover by app name
                                                        file.cover = true
                                                    elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                        img_path = custom_path_id --custom cover by app id
                                                        file.cover = true
                                                    else
                                                        if System.doesFileExist("app0:/DATA/missing_cover_psp.png") then
                                                            img_path = "app0:/DATA/missing_cover_psp.png"  --app icon
                                                            file.cover = false
                                                        else
                                                            img_path = "app0:/DATA/noimg.png" --blank grey
                                                            file.cover = false
                                                        end
                                                    end
                                                end
                                            -- OVERRIDES END

                                            -- NO OVERRIDE - PSP
                                            else
                                                table.insert(psp_table, file)

                                                table.insert(folders_table, file)
                                                file.app_type=2

                                                -- Check for hidden game names
                                                file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                custom_path = SystemsToScan[3].localCoverPath .. app_title .. ".png"
                                                custom_path_id = SystemsToScan[3].localCoverPath .. file.name .. ".png"

                                                file.cover_path_online = SystemsToScan[3].onlineCoverPathSystem
                                                file.cover_path_local = SystemsToScan[3].localCoverPath
                                                file.snap_path_online = SystemsToScan[3].onlineSnapPathSystem
                                                file.snap_path_local = SystemsToScan[3].localSnapPath

                                                if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                    img_path = custom_path --custom cover by app name
                                                    file.cover = true
                                                elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                    img_path = custom_path_id --custom cover by app id
                                                    file.cover = true
                                                else
                                                    if System.doesFileExist("app0:/DATA/missing_cover_psp.png") then
                                                        img_path = "app0:/DATA/missing_cover_psp.png"  --app icon
                                                        file.cover = false
                                                    else
                                                        img_path = "app0:/DATA/noimg.png" --blank grey
                                                        file.cover = false
                                                    end
                                                end
                                            end

                                        update_loading_screen_progress("PSP iso")

                                        table.insert(files_table, count_of_systems, file.app_type) 
                                        table.insert(files_table, count_of_systems, file.name)
                                        table.insert(files_table, count_of_systems, file.title)
                                        table.insert(files_table, count_of_systems, file.name_online)
                                        table.insert(files_table, count_of_systems, file.version)
                                        table.insert(files_table, count_of_systems, file.name_title_search)

                                        --add blank icon to all
                                        file.icon = imgCoverTmp
                                        file.icon_path = img_path
                                        
                                        table.insert(files_table, count_of_systems, file.icon)                     
                                        table.insert(files_table, count_of_systems, file.apptitle)

                                    else
                                    end

                                else

                                end
                                
                            end
                        end

                    else
                    end
                end

            end
        end

        function scan_PSP_game_folder (def_adrenaline_rom_location)

            if  System.doesDirExist(def_adrenaline_rom_location) then

                if next(sfo_scans_onelua) == nil then
                else

                    if next(QuickGameList.adrenaline_games_folder) ~= nil then

                        for i, file in pairs(QuickGameList.adrenaline_games_folder) do
                            -- local custom_path, custom_path_id, app_type, name, name_online, version, name_title_search = nil, nil, nil, nil, nil, nil, nil
                            
                            if file.path and string.match(file.path, def_adrenaline_rom_location) then

                                -- Get parent folder name
                                local last_foldername_in_path = file.path:gsub(".*/([^/]+)/[^/]+$", "%1") -- Gsub returns the parent folder name eg. SCUS94306

                                -- Get the SFO info from sfo_scans_onelua
                                if sfo_scans_onelua[last_foldername_in_path] ~= nil then

                                    local sfo_title = sfo_scans_onelua[last_foldername_in_path].title or "UNK"
                                    file.titleid = sfo_scans_onelua[last_foldername_in_path].titleid or "UNK"
                                    file.category = sfo_scans_onelua[last_foldername_in_path].category or "UNK"
                                    file.version = sfo_scans_onelua[last_foldername_in_path].region or "UNK"
                                    file.title = sfo_title

                                    -- CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME, PBOOT.PBP PG 

                                    -- PSP Official and PSP Homebrew only

                                    if file.category == nil then
                                        -- Legacy fix
                                        delete_cache()
                                        FreeMemory()
                                        Network.term()
                                        dofile("app0:index.lua")

                                    elseif string.match(file.category, "UG") or string.match(file.category, "MG") or string.match(file.category, "EG") then

                                        -- check if game is in the favorites list
                                        if System.doesFileExist(cur_dir .. "/favorites.dat") then
                                            if string.find(strFav, file.titleid,1,true) ~= nil then
                                                file.favourite = true
                                            else
                                                file.favourite = false
                                            end
                                        end

                                        -- file.launch_argument = "PATH=ms0:/PSP/GAME/" .. file.titleid .. "/EBOOT.PBP"
                                        file.game_path = file.path:gsub("/EBOOT.pbp","")
                                        file.date_played = 0
                                        file.app_type_default=2
                                        file.category = file.category

                                        if string.match(file.category, "MG") then
                                            -- Homebrew: Use the parent folder name, some homebrews didn't bother creating proper sfo titles
                                            info = last_foldername_in_path
                                            app_title = last_foldername_in_path
                                            file.filename = last_foldername_in_path
                                            file.name = last_foldername_in_path
                                            file.title = last_foldername_in_path
                                            file.name_online = last_foldername_in_path
                                            file.version = file.region
                                            file.name_title_search = last_foldername_in_path
                                            file.apptitle = last_foldername_in_path
                                            file.directory = true
                                        else
                                            info = file.title
                                            app_title = file.title
                                            file.filename = file.titleid
                                            file.name = file.titleid
                                            file.title = file.title
                                            file.name_online = file.titleid
                                            file.version = file.region
                                            file.name_title_search = file.title
                                            file.apptitle = file.title
                                            file.directory = true
                                        end

                                        -- Check for renamed game names
                                        if #renamed_games_table ~= nil then
                                            local key = find_game_table_pos_key(renamed_games_table, file.name)
                                            if key ~= nil then
                                              -- Yes - Find in files table
                                              app_title = renamed_games_table[key].title
                                              file.title = renamed_games_table[key].title
                                              file.apptitle = renamed_games_table[key].title
                                            else
                                              -- No
                                            end
                                        else
                                        end


                                        -- OVERRIDES START

                                            if System.doesFileExist(cur_dir .. "/overrides.dat") then
                                                --String:   1 vita, 2 psp, 3 psx, 4 homebrew
                                                --App_type: 1 vita, 2 psp, 3 psx, 0 homebrew                         

                                                -- VITA
                                                if string.match(str, file.name .. "=1") then
                                                    table.insert(games_table, file)

                                                    table.insert(folders_table, file)
                                                    file.app_type=1

                                                    -- Check for hidden game names
                                                    file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                    custom_path = SystemsToScan[1].localCoverPath .. app_title .. ".png"
                                                    custom_path_id = SystemsToScan[1].localCoverPath .. file.name .. ".png"

                                                    file.cover_path_online = SystemsToScan[1].onlineCoverPathSystem
                                                    file.cover_path_local = SystemsToScan[1].localCoverPath
                                                    file.snap_path_online = SystemsToScan[1].onlineSnapPathSystem
                                                    file.snap_path_local = SystemsToScan[1].localSnapPath

                                                    if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                        img_path = custom_path --custom cover by app name
                                                        file.cover = true
                                                    elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                        img_path = custom_path_id --custom cover by app id
                                                        file.cover = true
                                                    else
                                                        if System.doesFileExist("app0:/DATA/missing_cover_psv.png") then
                                                            img_path = "app0:/DATA/missing_cover_psv.png"  --app icon
                                                            file.cover = false
                                                        else
                                                            img_path = "app0:/DATA/noimg.png" --blank grey
                                                            file.cover = false
                                                        end
                                                    end

                                                -- PSP
                                                elseif string.match(str, file.name .. "=2") then
                                                    table.insert(psp_table, file)

                                                    table.insert(folders_table, file)
                                                    file.app_type=2

                                                    -- Check for hidden game names
                                                    file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                    custom_path = SystemsToScan[3].localCoverPath .. app_title .. ".png"
                                                    custom_path_id = SystemsToScan[3].localCoverPath .. file.name .. ".png"

                                                    file.cover_path_online = SystemsToScan[3].onlineCoverPathSystem
                                                    file.cover_path_local = SystemsToScan[3].localCoverPath
                                                    file.snap_path_online = SystemsToScan[3].onlineSnapPathSystem
                                                    file.snap_path_local = SystemsToScan[3].localSnapPath

                                                    if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                        img_path = custom_path --custom cover by app name
                                                        file.cover = true
                                                    elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                        img_path = custom_path_id --custom cover by app id
                                                        file.cover = true
                                                    else
                                                        if System.doesFileExist("app0:/DATA/missing_cover_psp.png") then
                                                            img_path = "app0:/DATA/missing_cover_psp.png"  --app icon
                                                            file.cover = false
                                                        else
                                                            img_path = "app0:/DATA/noimg.png" --blank grey
                                                            file.cover = false
                                                        end
                                                    end
                                                
                                                -- PSX
                                                elseif string.match(str, file.name .. "=3") then
                                                    table.insert(psx_table, file)

                                                    table.insert(folders_table, file)
                                                    file.app_type=3

                                                    -- Check for hidden game names
                                                    file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                    custom_path = SystemsToScan[4].localCoverPath .. app_title .. ".png"
                                                    custom_path_id = SystemsToScan[4].localCoverPath .. file.name .. ".png"

                                                    file.cover_path_online = SystemsToScan[4].onlineCoverPathSystem
                                                    file.cover_path_local = SystemsToScan[4].localCoverPath
                                                    file.snap_path_online = SystemsToScan[4].onlineSnapPathSystem
                                                    file.snap_path_local = SystemsToScan[4].localSnapPath

                                                    if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                        img_path = custom_path --custom cover by app name
                                                        file.cover = true
                                                    elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                        img_path = custom_path_id --custom cover by app id
                                                        file.cover = true
                                                    else
                                                        if System.doesFileExist("app0:/DATA/missing_cover_psx.png") then
                                                            img_path = "app0:/DATA/missing_cover_psx.png"  --app icon
                                                            file.cover = false
                                                        else
                                                            img_path = "app0:/DATA/noimg.png" --blank grey
                                                            file.cover = false
                                                        end
                                                    end

                                                -- HOMEBREW
                                                elseif string.match(str, file.name .. "=4") then
                                                    table.insert(homebrews_table, file)

                                                    table.insert(folders_table, file)
                                                    file.app_type=0

                                                    -- Check for hidden game names
                                                    file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                    custom_path = SystemsToScan[2].localCoverPath .. app_title .. ".png"
                                                    custom_path_id = SystemsToScan[2].localCoverPath .. file.name .. ".png"

                                                    file.cover_path_online = SystemsToScan[2].onlineCoverPathSystem
                                                    file.cover_path_local = SystemsToScan[2].localCoverPath
                                                    file.snap_path_online = SystemsToScan[2].onlineSnapPathSystem
                                                    file.snap_path_local = SystemsToScan[2].localSnapPath

                                                    if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                        img_path = custom_path --custom cover by app name
                                                        file.cover = true
                                                    elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                        img_path = custom_path_id --custom cover by app id
                                                        file.cover = true
                                                    else
                                                        if System.doesFileExist("app0:/DATA/icon_homebrew.png") then
                                                            img_path = "app0:/DATA/icon_homebrew.png"  --app icon
                                                            file.cover = false
                                                        else
                                                            img_path = "app0:/DATA/noimg.png" --blank grey
                                                            file.cover = false
                                                        end
                                                    end

                                                -- DEFAULT - PSP
                                                else
                                                    table.insert(psp_table, file)

                                                    table.insert(folders_table, file)
                                                    file.app_type=2

                                                    -- Check for hidden game names
                                                    file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                    custom_path = SystemsToScan[3].localCoverPath .. app_title .. ".png"
                                                    custom_path_id = SystemsToScan[3].localCoverPath .. file.name .. ".png"

                                                    file.cover_path_online = SystemsToScan[3].onlineCoverPathSystem
                                                    file.cover_path_local = SystemsToScan[3].localCoverPath
                                                    file.snap_path_online = SystemsToScan[3].onlineSnapPathSystem
                                                    file.snap_path_local = SystemsToScan[3].localSnapPath

                                                    if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                        img_path = custom_path --custom cover by app name
                                                        file.cover = true
                                                    elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                        img_path = custom_path_id --custom cover by app id
                                                        file.cover = true
                                                    else
                                                        if System.doesFileExist("app0:/DATA/missing_cover_psp.png") then
                                                            img_path = "app0:/DATA/missing_cover_psp.png"  --app icon
                                                            file.cover = false
                                                        else
                                                            img_path = "app0:/DATA/noimg.png" --blank grey
                                                            file.cover = false
                                                        end
                                                    end
                                                end
                                            -- OVERRIDES END

                                            -- NO OVERRIDE - PSP
                                            else
                                                table.insert(psp_table, file)

                                                table.insert(folders_table, file)
                                                file.app_type=2

                                                -- Check for hidden game names
                                                file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                custom_path = SystemsToScan[3].localCoverPath .. app_title .. ".png"
                                                custom_path_id = SystemsToScan[3].localCoverPath .. file.name .. ".png"

                                                file.cover_path_online = SystemsToScan[3].onlineCoverPathSystem
                                                file.cover_path_local = SystemsToScan[3].localCoverPath
                                                file.snap_path_online = SystemsToScan[3].onlineSnapPathSystem
                                                file.snap_path_local = SystemsToScan[3].localSnapPath

                                                if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                    img_path = custom_path --custom cover by app name
                                                    file.cover = true
                                                elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                    img_path = custom_path_id --custom cover by app id
                                                    file.cover = true
                                                else
                                                    if System.doesFileExist("app0:/DATA/missing_cover_psp.png") then
                                                        img_path = "app0:/DATA/missing_cover_psp.png"  --app icon
                                                        file.cover = false
                                                    else
                                                        img_path = "app0:/DATA/noimg.png" --blank grey
                                                        file.cover = false
                                                    end
                                                end
                                            end

                                        update_loading_screen_progress("PSP game folder")

                                        table.insert(files_table, count_of_systems, file.app_type) 
                                        table.insert(files_table, count_of_systems, file.name)
                                        table.insert(files_table, count_of_systems, file.title)
                                        table.insert(files_table, count_of_systems, file.name_online)
                                        table.insert(files_table, count_of_systems, file.version)
                                        table.insert(files_table, count_of_systems, file.name_title_search)

                                        --add blank icon to all
                                        file.icon = imgCoverTmp
                                        file.icon_path = img_path
                                        
                                        table.insert(files_table, count_of_systems, file.icon)                     
                                        table.insert(files_table, count_of_systems, file.apptitle)


                                    else
                                    end

                                else
                                end
                                
                            end
                        end

                    else
                    end

                end

            end
        end

        function scan_PS1_game_folder (def_adrenaline_rom_location)

            if  System.doesDirExist(def_adrenaline_rom_location) then

                if next(sfo_scans_onelua) == nil then
                else
                    
                    if next(QuickGameList.adrenaline_games_folder) ~= nil then
                    
                        for i, file in pairs(QuickGameList.adrenaline_games_folder) do
                            -- local custom_path, custom_path_id, app_type, name, name_online, version, name_title_search = nil, nil, nil, nil, nil, nil, nil

                            if file.path and string.match(file.path, def_adrenaline_rom_location) then

                                -- Get parent folder name
                                local last_foldername_in_path = file.path:gsub(".*/([^/]+)/[^/]+$", "%1") -- Gsub returns the parent folder name eg. SCUS94306

                                -- Get the SFO info from sfo_scans_onelua
                                if sfo_scans_onelua[last_foldername_in_path] ~= nil then

                                    file.title = sfo_scans_onelua[last_foldername_in_path].title or "UNK"
                                    file.titleid = sfo_scans_onelua[last_foldername_in_path].titleid or "UNK"
                                    file.category = sfo_scans_onelua[last_foldername_in_path].category or "UNK"
                                    file.version = sfo_scans_onelua[last_foldername_in_path].region or "UNK"

                                    -- CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME, PBOOT.PBP PG 

                                    -- PSX titles
                                    
                                    if file.category == nil then
                                        -- Legacy fix
                                        delete_cache()
                                        FreeMemory()
                                        Network.term()
                                        dofile("app0:index.lua")

                                    elseif string.match(file.category, "ME") then

                                        -- check if game is in the favorites list
                                        if System.doesFileExist(cur_dir .. "/favorites.dat") then
                                            if string.find(strFav, file.titleid,1,true) ~= nil then
                                                file.favourite = true
                                            else
                                                file.favourite = false
                                            end
                                        end

                                        -- file.launch_argument = ("PATH=ms0:/PSP/GAME/" .. file.titleid .. "/EBOOT.PBP")
                                        file.game_path = file.path:gsub("/EBOOT.pbp","")
                                        file.date_played = 0
                                        file.app_type_default=3

                                        info = file.title
                                        app_title = file.title
                                        file.filename = file.titleid
                                        file.name = file.titleid
                                        file.title = file.title
                                        file.name_online = file.titleid
                                        file.name_title_search = file.title
                                        file.apptitle = file.title
                                        file.directory = false
                                        file.category = file.category

                                        -- Check for renamed game names
                                        if #renamed_games_table ~= nil then
                                            local key = find_game_table_pos_key(renamed_games_table, file.name)
                                            if key ~= nil then
                                              -- Yes - Find in files table
                                              app_title = renamed_games_table[key].title
                                              file.title = renamed_games_table[key].title
                                              file.apptitle = renamed_games_table[key].title
                                            else
                                              -- No
                                            end
                                        else
                                        end


                                        -- OVERRIDES START

                                        if System.doesFileExist(cur_dir .. "/overrides.dat") then
                                            --String:   1 vita, 2 psp, 3 psx, 4 homebrew
                                            --App_type: 1 vita, 2 psp, 3 psx, 0 homebrew                         

                                            -- VITA
                                            if string.match(str, file.name .. "=1") then
                                                table.insert(games_table, file)

                                                table.insert(folders_table, file)
                                                file.app_type=1

                                                -- Check for hidden game names
                                                file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                custom_path = SystemsToScan[1].localCoverPath .. app_title .. ".png"
                                                custom_path_id = SystemsToScan[1].localCoverPath .. file.name .. ".png"

                                                file.cover_path_online = SystemsToScan[1].onlineCoverPathSystem
                                                file.cover_path_local = SystemsToScan[1].localCoverPath
                                                file.snap_path_online = SystemsToScan[1].onlineSnapPathSystem
                                                file.snap_path_local = SystemsToScan[1].localSnapPath

                                                if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                    img_path = custom_path --custom cover by app name
                                                    file.cover = true
                                                elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                    img_path = custom_path_id --custom cover by app id
                                                    file.cover = true
                                                else
                                                    if System.doesFileExist("app0:/DATA/missing_cover_psv.png") then
                                                        img_path = "app0:/DATA/missing_cover_psv.png"  --app icon
                                                        file.cover = false
                                                    else
                                                        img_path = "app0:/DATA/noimg.png" --blank grey
                                                        file.cover = false
                                                    end
                                                end

                                            -- PSP
                                            elseif string.match(str, file.name .. "=2") then
                                                table.insert(psp_table, file)

                                                table.insert(folders_table, file)
                                                file.app_type=2

                                                -- Check for hidden game names
                                                file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                custom_path = SystemsToScan[3].localCoverPath .. app_title .. ".png"
                                                custom_path_id = SystemsToScan[3].localCoverPath .. file.name .. ".png"

                                                file.cover_path_online = SystemsToScan[3].onlineCoverPathSystem
                                                file.cover_path_local = SystemsToScan[3].localCoverPath
                                                file.snap_path_online = SystemsToScan[3].onlineSnapPathSystem
                                                file.snap_path_local = SystemsToScan[3].localSnapPath

                                                if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                    img_path = custom_path --custom cover by app name
                                                    file.cover = true
                                                elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                    img_path = custom_path_id --custom cover by app id
                                                    file.cover = true
                                                else
                                                    if System.doesFileExist("app0:/DATA/missing_cover_psp.png") then
                                                        img_path = "app0:/DATA/missing_cover_psp.png"  --app icon
                                                        file.cover = false
                                                    else
                                                        img_path = "app0:/DATA/noimg.png" --blank grey
                                                        file.cover = false
                                                    end
                                                end
                                            
                                            -- PSX
                                            elseif string.match(str, file.name .. "=3") then
                                                table.insert(psx_table, file)

                                                table.insert(folders_table, file)
                                                file.app_type=3

                                                -- Check for hidden game names
                                                file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                custom_path = SystemsToScan[4].localCoverPath .. app_title .. ".png"
                                                custom_path_id = SystemsToScan[4].localCoverPath .. file.name .. ".png"

                                                file.cover_path_online = SystemsToScan[4].onlineCoverPathSystem
                                                file.cover_path_local = SystemsToScan[4].localCoverPath
                                                file.snap_path_online = SystemsToScan[4].onlineSnapPathSystem
                                                file.snap_path_local = SystemsToScan[4].localSnapPath

                                                if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                    img_path = custom_path --custom cover by app name
                                                    file.cover = true
                                                elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                    img_path = custom_path_id --custom cover by app id
                                                    file.cover = true
                                                else
                                                    if System.doesFileExist("app0:/DATA/missing_cover_psx.png") then
                                                        img_path = "app0:/DATA/missing_cover_psx.png"  --app icon
                                                        file.cover = false
                                                    else
                                                        img_path = "app0:/DATA/noimg.png" --blank grey
                                                        file.cover = false
                                                    end
                                                end

                                            -- HOMEBREW
                                            elseif string.match(str, file.name .. "=4") then
                                                table.insert(homebrews_table, file)

                                                table.insert(folders_table, file)
                                                file.app_type=0

                                                -- Check for hidden game names
                                                file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                custom_path = SystemsToScan[2].localCoverPath .. app_title .. ".png"
                                                custom_path_id = SystemsToScan[2].localCoverPath .. file.name .. ".png"

                                                file.cover_path_online = SystemsToScan[2].onlineCoverPathSystem
                                                file.cover_path_local = SystemsToScan[2].localCoverPath
                                                file.snap_path_online = SystemsToScan[2].onlineSnapPathSystem
                                                file.snap_path_local = SystemsToScan[2].localSnapPath

                                                if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                    img_path = custom_path --custom cover by app name
                                                    file.cover = true
                                                elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                    img_path = custom_path_id --custom cover by app id
                                                    file.cover = true
                                                else
                                                    if System.doesFileExist("app0:/DATA/icon_homebrew.png") then
                                                        img_path = "app0:/DATA/icon_homebrew.png"  --app icon
                                                        file.cover = false
                                                    else
                                                        img_path = "app0:/DATA/noimg.png" --blank grey
                                                        file.cover = false
                                                    end
                                                end

                                            -- DEFAULT - PSX
                                            else
                                                table.insert(psx_table, file)

                                                table.insert(folders_table, file)
                                                file.app_type=3

                                                -- Check for hidden game names
                                                file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                                custom_path = SystemsToScan[4].localCoverPath .. app_title .. ".png"
                                                custom_path_id = SystemsToScan[4].localCoverPath .. file.name .. ".png"

                                                file.cover_path_online = SystemsToScan[4].onlineCoverPathSystem
                                                file.cover_path_local = SystemsToScan[4].localCoverPath
                                                file.snap_path_online = SystemsToScan[4].onlineSnapPathSystem
                                                file.snap_path_local = SystemsToScan[4].localSnapPath

                                                if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                    img_path = custom_path --custom cover by app name
                                                    file.cover = true
                                                elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                    img_path = custom_path_id --custom cover by app id
                                                    file.cover = true
                                                else
                                                    if System.doesFileExist("app0:/DATA/missing_cover_psx.png") then
                                                        img_path = "app0:/DATA/missing_cover_psx.png"  --app icon
                                                        file.cover = false
                                                    else
                                                        img_path = "app0:/DATA/noimg.png" --blank grey
                                                        file.cover = false
                                                    end
                                                end
                                            end
                                        -- OVERRIDES END

                                        -- NO OVERRIDE
                                        else
                                            table.insert(psx_table, file)

                                            table.insert(folders_table, file)
                                            file.app_type=3

                                            -- Check for hidden game names
                                            file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                            custom_path = SystemsToScan[4].localCoverPath .. app_title .. ".png"
                                            custom_path_id = SystemsToScan[4].localCoverPath .. file.name .. ".png"

                                            file.cover_path_online = SystemsToScan[4].onlineCoverPathSystem
                                            file.cover_path_local = SystemsToScan[4].localCoverPath
                                            file.snap_path_online = SystemsToScan[4].onlineSnapPathSystem
                                            file.snap_path_local = SystemsToScan[4].localSnapPath
                                            
                                            if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                                img_path = SystemsToScan[4].localCoverPath .. file.name .. ".png" --custom cover by app name
                                                file.cover = true
                                            elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                                img_path = SystemsToScan[4].localCoverPath .. file.name .. ".png" --custom cover by app id
                                                file.cover = true
                                            else
                                                if System.doesFileExist("app0:/DATA/missing_cover_psx.png") then
                                                    img_path = "app0:/DATA/missing_cover_psx.png"  --app icon
                                                    file.cover = false
                                                else
                                                    img_path = "app0:/DATA/noimg.png" --blank grey
                                                    file.cover = false
                                                end
                                            end
                                        end

                                        update_loading_screen_progress("PS1 game folder")

                                        table.insert(files_table, count_of_systems, file.app_type) 
                                        table.insert(files_table, count_of_systems, file.name)
                                        table.insert(files_table, count_of_systems, file.title)
                                        table.insert(files_table, count_of_systems, file.name_online)
                                        table.insert(files_table, count_of_systems, file.version)
                                        table.insert(files_table, count_of_systems, file.name_title_search)

                                        --add blank icon to all
                                        file.icon = imgCoverTmp
                                        file.icon_path = img_path
                                        
                                        table.insert(files_table, count_of_systems, file.icon)
                                        table.insert(files_table, count_of_systems, file.apptitle)

                                    else
                                    end

                                else
                                end

                            end
                        end

                    else
                    end
                end

            end
        end


        function scan_Rom_PS1_RA_All(def, def_table_name)
            if System.doesDirExist(SystemsToScan[(def)].romFolder) then
                if next(sfo_scans_onelua) ~= nil then
                    if next(QuickGameList.psx_retroarch) then
                        for i, original_file in pairs(QuickGameList.psx_retroarch) do
                            -- Create a copy of the file object to avoid modifying the original
                            local file = {}
                            for k, v in pairs(original_file) do
                                file[k] = v
                            end
                            
                            local custom_path, custom_path_id, app_type, name, title, name_online, version, name_title_search = nil, nil, nil, nil, nil, nil, nil, nil
                            
                            -- Handle EBOOT.PBP files in subfolders
                            if file.name:lower():match("eboot.pbp") and file.subfolder == true then
                                
                                -- Get parent folder name
                                local last_foldername_in_path = file.path:gsub(".*/([^/]+)/[^/]+$", "%1")
                                
                                -- Skip PSP games (PS1 only)
                                if not string.match(last_foldername_in_path, "NPEG")
                                and not string.match(last_foldername_in_path, "NPEH")
                                and not string.match(last_foldername_in_path, "UCES")
                                and not string.match(last_foldername_in_path, "ULES")
                                and not string.match(last_foldername_in_path, "NPUG")
                                and not string.match(last_foldername_in_path, "NPUH")
                                and not string.match(last_foldername_in_path, "UCUS")
                                and not string.match(last_foldername_in_path, "ULUS")
                                and not string.match(last_foldername_in_path, "NPJG")
                                and not string.match(last_foldername_in_path, "NPJH")
                                and not string.match(last_foldername_in_path, "NPHG")
                                and not string.match(last_foldername_in_path, "NPHH")
                                and not string.match(last_foldername_in_path, "UCAS") then
                                    
                                    -- Get the SFO info from sfo_scans_onelua
                                    local sfo_data = sfo_scans_onelua[last_foldername_in_path]
                                    if sfo_data ~= nil then
                                        file.title = sfo_data.title or last_foldername_in_path
                                        file.titleid = sfo_data.titleid or last_foldername_in_path
                                        file.category = sfo_data.category or "ME"
                                        file.version = sfo_data.region or "UNK"
                                        
                                        -- Set specific fields for EBOOT.PBP games
                                        file.filename = last_foldername_in_path
                                        file.name = file.titleid  -- Use titleid for name (e.g., "SLUS00888")
                                        file.name_online = file.titleid
                                        file.name_title_search = file.title
                                        file.apptitle = file.title
                                        
                                        -- Process as EBOOT.PBP game
                                        processPS1Game(file, last_foldername_in_path, def, def_table_name, "PS1 RA EBOOT")
                                    end
                                end
                                
                            -- Handle other .PBP files (not EBOOT.PBP)
                            elseif (string.match(file.name, "%.pbp") or string.match(file.name, "%.PBP")) and not file.name:lower():match("eboot.pbp") then
                                
                                local sfo_data = sfo_scans_onelua[file.name]
                                if sfo_data ~= nil then
                                    local filename_no_extension = file.name:gsub("%.%w+$", "")
                                    
                                    file.title = sfo_data.title or filename_no_extension
                                    file.titleid = sfo_data.titleid or filename_no_extension
                                    file.category = sfo_data.category or "ME"
                                    file.version = sfo_data.region or "UNK"
                                    
                                    -- Set specific fields for standalone PBP games
                                    file.filename = filename_no_extension
                                    file.name = file.titleid  -- Use titleid for name (e.g., "SCUS94244")
                                    file.name_online = file.titleid
                                    file.name_title_search = file.title
                                    file.apptitle = file.title
                                    
                                    -- Process as standalone PBP game
                                    processPS1Game(file, file.name, def, def_table_name, "PS1 RA PBP")
                                end
                                
                            -- Handle other file types (ISO, CUE, etc.)
                            elseif not (string.match(file.name, "%.pbp") or string.match(file.name, "%.PBP")) then
                                
                                -- Use rom name cleaning for non-PBP files
                                romname_withExtension = file.name
                                cleanRomNames()
                                
                                file.filename = file.name
                                file.name = romname_noExtension
                                file.title = romname_noRegion_noExtension
                                file.name_online = romname_url_encoded
                                file.version = romname_region
                                file.apptitle = romname_noRegion_noExtension
                                file.app_type = 3
                                file.app_type_default = 3
                                file.date_played = 0
                                
                                -- Process as ROM file
                                processPS1Game(file, file.name, def, def_table_name, "PS1 RA ROM")
                            end
                        end
                    end
                end
            end
        end

        -- Helper function to process PS1 games consistently
        function processPS1Game(file, lookup_name, def, def_table_name, progress_text)
            -- Common game processing logic
            if System.doesFileExist(cur_dir .. "/favorites.dat") then
                if string.find(strFav, lookup_name, 1, true) ~= nil then
                    file.favourite = true
                else
                    file.favourite = false
                end
            end
            
            file.game_path = file.path
            file.date_played = file.date_played or 0
            file.app_type = 3
            file.app_type_default = 3
            file.directory = false
            
            -- Set default fields if not already set (use existing values if they exist)
            file.filename = file.filename or lookup_name
            file.name = file.name or (file.titleid or lookup_name)  -- Keep existing name if already set
            file.name_online = file.name_online or (file.titleid or lookup_name)
            file.version = file.version or (file.region or "UNK")
            file.name_title_search = file.name_title_search or file.title
            file.apptitle = file.apptitle or file.title
            
            -- Check for renamed game names
            if #renamed_games_table ~= nil then
                local key = find_game_table_pos_key(renamed_games_table, file.name)
                if key ~= nil then
                    file.title = renamed_games_table[key].title
                    file.apptitle = renamed_games_table[key].title
                end
            end
            
            -- Check for hidden game names
            file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)
            
            -- Set up cover paths
            local custom_path = (SystemsToScan[(def)].localCoverPath) .. file.title .. ".png"
            local custom_path_id = (SystemsToScan[(def)].localCoverPath) .. file.name .. ".png"
            
            file.cover_path_online = (SystemsToScan[(def)].onlineCoverPathSystem)
            file.cover_path_local = (SystemsToScan[(def)].localCoverPath)
            file.snap_path_local = (SystemsToScan[(def)].localSnapPath)
            file.snap_path_online = (SystemsToScan[(def)].onlineSnapPathSystem)
            
            -- Set cover image
            if custom_path and QuickDoesFileExist.covDir[custom_path] then
                img_path = custom_path
                file.cover = true
            elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                img_path = custom_path_id
                file.cover = true
            else
                if System.doesFileExist("app0:/DATA/" .. (SystemsToScan[(def)].Missing_Cover)) then
                    img_path = "app0:/DATA/" .. (SystemsToScan[(def)].Missing_Cover)
                else
                    img_path = "app0:/DATA/noimg.png"
                end
                file.cover = false
            end
            
            -- Add to tables
            table.insert(folders_table, file)
            table.insert((def_table_name), file)
            
            update_loading_screen_progress(progress_text)
            
            -- Add to files_table
            table.insert(files_table, count_of_systems, file.app_type)
            table.insert(files_table, count_of_systems, file.name)
            table.insert(files_table, count_of_systems, file.title)
            table.insert(files_table, count_of_systems, file.name_online)
            table.insert(files_table, count_of_systems, file.version)
            table.insert(files_table, count_of_systems, file.name_title_search)
            
            -- Add icon
            file.icon = imgCoverTmp
            file.icon_path = img_path
            
            table.insert(files_table, count_of_systems, file.icon)
            table.insert(files_table, count_of_systems, file.apptitle)
        end


        function Scan_Rom_Simple(def, def_quickscan_table, def_table_name)

            if next(def_quickscan_table) then

                for i, file in pairs(def_quickscan_table) do
                    local custom_path, custom_path_id, app_type, name, title, name_online, version = nil, nil, nil, nil, nil, nil, nil
                    -- Scan files only, ignore temporary files, Windows = "Thumbs.db", Mac = "DS_Store", and "._name" 

                    -- check if game is in the favorites list
                    if System.doesFileExist(cur_dir .. "/favorites.dat") then
                        if string.find(strFav, file.name,1,true) ~= nil then
                            file.favourite = true
                        else
                            file.favourite = false
                        end
                    end

                    file.game_path = ((SystemsToScan[(def)].romFolder) .. "/" .. file.name)

                    romname_withExtension = file.name
                    cleanRomNames()
                    info = romname_noRegion_noExtension
                    app_title = romname_noRegion_noExtension                    
                    
                    table.insert(folders_table, file)
                    --table.insert(games_table, file)

                    if (def) == 43 then
                        -- NDS game, try to extract title ID for artwork matching
                        local ds_file = io.open(file.game_path, "rb")
                        local titleid
                        if ds_file then
                            ds_file:seek("set", 0x0C) -- move to game code
                            local game_code = ds_file:read(4)
                            ds_file:close()

                            local id = (game_code or "") -- e.g. "ABCD"
                            titleid = (id ~= "") and id or "UNK"
                        else
                            titleid = "UNK"
                        end
                        file.titleid = titleid
                        file.name_online = titleid
                    else
                        file.name_online = romname_url_encoded
                    end

                    file.filename = file.name
                    file.name = romname_noExtension
                    file.title = romname_noRegion_noExtension
                    -- file.name_online = romname_url_encoded
                    file.version = romname_region
                    file.apptitle = romname_noRegion_noExtension
                    file.date_played = 0
                    file.snap_path_local = (SystemsToScan[(def)].localSnapPath)
                    file.snap_path_online = (SystemsToScan[(def)].onlineSnapPathSystem)
                    file.app_type=((def))
                    file.app_type_default=((def))
                    file.directory = false

                    -- Check for renamed game names
                    if #renamed_games_table ~= nil then
                        local key = find_game_table_pos_key(renamed_games_table, file.name)
                        if key ~= nil then
                          -- Yes - Find in files table
                          app_title = renamed_games_table[key].title
                          file.title = renamed_games_table[key].title
                          file.apptitle = renamed_games_table[key].title
                        else
                          -- No
                        end
                    else
                    end

                    -- Check for hidden game names
                    file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                    custom_path = (SystemsToScan[(def)].localCoverPath) .. file.title .. ".png"
                    custom_path_id = (SystemsToScan[(def)].localCoverPath) .. file.name .. ".png"

                    table.insert((def_table_name), file)

                    update_loading_screen_progress((def))

                    if custom_path and QuickDoesFileExist.covDir[custom_path] then
                        img_path = (SystemsToScan[(def)].localCoverPath) .. file.title .. ".png" --custom cover by app name
                        file.cover = true
                    elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                        img_path = (SystemsToScan[(def)].localCoverPath) .. file.name .. ".png" --custom cover by app id
                        file.cover = true
                    else
                        if System.doesFileExist("app0:/DATA/" .. (SystemsToScan[(def)].Missing_Cover)) then
                            img_path = "app0:/DATA/" .. (SystemsToScan[(def)].Missing_Cover)  --app icon
                            file.cover = false
                        else
                            img_path = "app0:/DATA/noimg.png" --blank grey
                            file.cover = false
                        end
                    end

                    table.insert(files_table, count_of_systems, file.app_type) 
                    table.insert(files_table, count_of_systems, file.name)
                    table.insert(files_table, count_of_systems, file.title)
                    table.insert(files_table, count_of_systems, file.name_online)
                    table.insert(files_table, count_of_systems, file.version)

                    file.app_type=((def))
                    file.cover_path_online = (SystemsToScan[(def)].onlineCoverPathSystem)
                    file.cover_path_local = (SystemsToScan[(def)].localCoverPath)

                    --add blank icon to all
                    file.icon = imgCoverTmp
                    file.icon_path = img_path
                    
                    table.insert(files_table, count_of_systems, file.icon) 
                    
                    table.insert(files_table, count_of_systems, file.apptitle) 

                end
            
            else
            end
        end

        function Scan_Rom_Filter_Pico8(def, def_quickscan_table, def_table_name)

            if next(def_quickscan_table) then

                for i, file in pairs(def_quickscan_table) do
                    local custom_path, custom_path_id, app_type, name, title, name_online, version = nil, nil, nil, nil, nil, nil, nil

                    -- check if game is in the favorites list
                    if System.doesFileExist(cur_dir .. "/favorites.dat") then
                        if string.find(strFav, file.name,1,true) ~= nil then
                            file.favourite = true
                        else
                            file.favourite = false
                        end
                    end

                    file.game_path = ((SystemsToScan[(def)].romFolder) .. "/" .. file.name)

                    romname_withExtension = file.name
                    cleanRomNames()

                    -- romname_noExtension = romname_noExtension:gsub(".p8", "")
                    romname_noRegion_noExtension = romname_noRegion_noExtension:gsub(".p8", "")

                    info = romname_noRegion_noExtension
                    app_title = romname_noRegion_noExtension
                    
                    
                    --table.insert(games_table, file)
                
                    file.filename = file.name
                    file.name = romname_noExtension
                    file.title = romname_noRegion_noExtension
                    file.name_online = romname_url_encoded
                    file.version = romname_region
                    file.apptitle = romname_noRegion_noExtension
                    file.date_played = 0
                    file.snap_path_local = (SystemsToScan[(def)].localSnapPath)
                    file.snap_path_online = (SystemsToScan[(def)].onlineSnapPathSystem)
                    file.app_type=((def))
                    file.app_type_default=((def))
                    file.directory = false

                    -- Check for renamed game names
                    if #renamed_games_table ~= nil then
                        local key = find_game_table_pos_key(renamed_games_table, file.name)
                        if key ~= nil then
                          -- Yes - Find in files table
                          app_title = renamed_games_table[key].title
                          file.title = renamed_games_table[key].title
                          file.apptitle = renamed_games_table[key].title
                        else
                          -- No
                        end
                    else
                    end

                    -- Check for hidden game names
                    file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                    custom_path = (SystemsToScan[(def)].localCoverPath) .. file.title .. ".png"
                    custom_path_id = (SystemsToScan[(def)].localCoverPath) .. file.name .. ".png"
                    pico_cart_path = file.game_path

                    if custom_path and QuickDoesFileExist.covDir[custom_path] then
                        img_path = (SystemsToScan[(def)].localCoverPath) .. file.title .. ".png" --custom cover by app name
                        file.cover = true
                    elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                        img_path = (SystemsToScan[(def)].localCoverPath) .. file.name .. ".png" --custom cover by app id
                        file.cover = true
                    else
                        if System.doesFileExist(pico_cart_path) then
                            img_path = pico_cart_path
                            file.cover = true
                        else
                            if System.doesFileExist("app0:/DATA/" .. (SystemsToScan[(def)].Missing_Cover)) then
                                img_path = "app0:/DATA/" .. (SystemsToScan[(def)].Missing_Cover)  --app icon
                                file.cover = false
                            else
                                img_path = "app0:/DATA/noimg.png" --blank grey
                                file.cover = false
                            end
                        end
                    end

                    table.insert(folders_table, file)
                    table.insert((def_table_name), file)

                    update_loading_screen_progress((def))

                    table.insert(files_table, count_of_systems, file.app_type) 
                    table.insert(files_table, count_of_systems, file.name)
                    table.insert(files_table, count_of_systems, file.title)
                    table.insert(files_table, count_of_systems, file.name_online)
                    table.insert(files_table, count_of_systems, file.version)

                    file.cover_path_online = (SystemsToScan[(def)].onlineCoverPathSystem)
                    file.cover_path_local = (SystemsToScan[(def)].localCoverPath)

                    --add blank icon to all
                    file.icon = imgCoverTmp
                    file.icon_path = img_path
                    
                    table.insert(files_table, count_of_systems, file.icon) 
                    table.insert(files_table, count_of_systems, file.apptitle) 

                end
            
            else
            end
        end

        function Scan_Rom_DB_Lookup(def, def_quickscan_table, def_table_name, def_user_db_file, def_sql_db_file)
            
            -- Optimization: Pre-compile pattern and cache common values for Amiga
            local amiga_version_pattern = "(_v[%d]+[%p][%d])"
            local is_amiga = (def) == 21
            
            -- Cache frequently accessed values outside the loop
            local system_config = SystemsToScan[def]
            local local_cover_path = system_config.localCoverPath
            local local_snap_path = system_config.localSnapPath
            local online_snap_path = system_config.onlineSnapPathSystem
            local online_cover_path = system_config.onlineCoverPathSystem
            local rom_folder = system_config.romFolder
            local missing_cover = system_config.Missing_Cover
            
            -- Pre-load databases once for the entire function
            local game_title_db = {}
            if System.doesFileExist(user_DB_Folder .. def_user_db_file) then
                game_title_db = safe_dofile(user_DB_Folder .. def_user_db_file) or {}
            end
            
            -- Pre-check for favorites file and read once
            local strFav = ""
            local has_favorites = false
            if System.doesFileExist(cur_dir .. "/favorites.dat") then
                local fileFav_over = System.openFile(cur_dir .. "/favorites.dat", FREAD)
                local fileFavsize = System.sizeFile(fileFav_over)
                strFav = System.readFile(fileFav_over, fileFavsize)
                System.closeFile(fileFav_over)
                has_favorites = true
            end
            
            -- Pre-open SQL database once if it exists
            local db = nil
            local has_sql_db = false
            if System.doesFileExist(cur_dir .. "/DATABASES/" .. def_sql_db_file) then
                db = Database.open(cur_dir .. "/DATABASES/" .. def_sql_db_file)
                has_sql_db = true
            end

            if next(def_quickscan_table) then

                for i, file in pairs(def_quickscan_table) do
                local custom_path, custom_path_id, app_type, name, title, name_online, version, name_title_search = nil, nil, nil, nil, nil, nil, nil, nil
                    -- Scan files only, ignore temporary files, Windows = "Thumbs.db", Mac = "DS_Store", and "._name" 
                if not string.match(file.name, "neogeo") then

                        -- check if game is in the favorites list (optimized)
                        if has_favorites then
                            file.favourite = string.find(strFav, file.name, 1, true) ~= nil
                        else
                            file.favourite = false
                        end

                        file.game_path = rom_folder .. "/" .. file.name

                        local romname_withExtension = file.name
                        local romname_noExtension = romname_withExtension:match("(.+)%..+$")
                        local untouched_romname_noExtension = romname_noExtension

                        -- LOOKUP TITLE ID: Get game name based on titleID, search saved table of data, or sql table of data if titleID not found

                        -- Special lookup string for Amiga WHDLoad (optimized)
                        local normalized_romname = romname_noExtension  -- Keep original as default
                        local is_lha_file = false
                        
                        if is_amiga then
                            local filename_lower = file.name:lower()
                            is_lha_file = filename_lower:sub(-4) == ".lha"  -- Faster than find()
                            
                            if is_lha_file then
                                -- Create normalized version but don't replace original yet
                                local version_match = romname_noExtension:match(amiga_version_pattern)
                                if version_match then
                                    normalized_romname = romname_noExtension:gsub(version_match, "_vX.X", 1)
                                end
                            end
                        end

                        -- Check if scanned titleID is a saved match (try original first)
                        local game_title_db_match = game_title_db[romname_noExtension]
                        
                        -- If original lookup fails and we have a normalized version, try that
                        if game_title_db_match == nil and normalized_romname ~= romname_noExtension then
                            game_title_db_match = game_title_db[normalized_romname]
                            if game_title_db_match then
                                -- Use normalized version for subsequent operations
                                romname_noExtension = normalized_romname
                            end
                        end

                        -- If no cached match found, check SQL database
                        if game_title_db_match == nil then
                            if has_sql_db then
                                -- For Amiga LHA files, always use normalized version for SQL lookup
                                local sql_lookup_name = romname_noExtension
                                if is_amiga and is_lha_file and normalized_romname ~= romname_noExtension then
                                    sql_lookup_name = normalized_romname
                                end

                                local sql_db_search_mame = "\"" .. sql_lookup_name .. "\""
                                local search_term = "SELECT title FROM games where filename is "  .. sql_db_search_mame
                                local sql_db_search_result = Database.execQuery(db, search_term)

                                if next(sql_db_search_result) == nil then
                                    -- Not found; use the original name without extension as fallback
                                    title = untouched_romname_noExtension
                                else
                                    -- Found; use the game name from the full database
                                    title = sql_db_search_result[1].title
                                end
                            else
                                title = untouched_romname_noExtension
                            end

                        -- If found; use the game name from the saved match
                        else
                            title = game_title_db[romname_noExtension].name
                        end

                        local romname_noRegion_noExtension = title:gsub('%b()', '')
                        romname_noRegion_noExtension = romname_noRegion_noExtension:gsub('[ \t]+%f[\r\n%z]', '') -- Removes trailing space

                        -- Check if name contains parenthesis, if yes strip out to show as version
                        local romname_region
                        local paren_start = title:find("%(")
                        if paren_start and title:find("%)", paren_start) then
                            -- Remove all text except for within "()"
                            local romname_region_initial = title:match("%((.+)%)")
                            -- Tidy up remainder when more than one set of parenthesis used, replace  ") (" with ", "
                            romname_region = romname_region_initial:gsub("%) %(", ', ')
                        else
                            romname_region = " "
                        end

                        --end of function

                        local info = romname_noRegion_noExtension
                        local app_title = romname_noRegion_noExtension
                        
                        -- Check for BIOS files once with case-insensitive pattern
                        local title_lower = title:lower()
                        local is_bios = title_lower:find("bios") ~= nil
                        
                        if not is_bios then
                            table.insert(folders_table, file)
                        end

                        -- file.filename = file.name
                        file.filename = file.name

                        if is_amiga then
                            -- Reuse cached values from above
                            if is_lha_file and title:match(amiga_version_pattern) then
                                file.name = title
                                file.name_online = name_title_search
                            else
                                file.name = romname_noExtension
                                file.name_online = romname_noExtension
                            end
                        else
                            file.name = romname_noExtension
                            file.name_online = romname_noExtension
                        end
                        
                        file.title = romname_noRegion_noExtension
                        file.version = romname_region
                        file.name_title_search = title
                        file.apptitle = romname_noRegion_noExtension
                        file.date_played = 0
                        file.snap_path_local = local_snap_path
                        file.snap_path_online = online_snap_path
                        file.app_type = def
                        file.app_type_default = def
                        file.directory = false

                        custom_path = local_cover_path .. file.title .. ".png"
                        custom_path_id = local_cover_path .. untouched_romname_noExtension .. ".png"

                        -- Check for renamed game names
                        if #renamed_games_table ~= nil then
                            local key = find_game_table_pos_key(renamed_games_table, file.name)
                            if key ~= nil then
                              -- Yes - Found in files table
                              file.title = renamed_games_table[key].title
                              file.apptitle = renamed_games_table[key].title
                            end
                        end

                        -- Check for hidden game names
                        file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                        if not is_bios then
                            table.insert(def_table_name, file)
                            update_loading_screen_progress(def)
                        end

                        -- Optimized cover path checking
                        if custom_path and QuickDoesFileExist.covDir[custom_path] then
                            file.icon_path = local_cover_path .. file.title .. ".png"
                            file.cover = true
                        elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                            file.icon_path = local_cover_path .. untouched_romname_noExtension .. ".png"
                            file.cover = true
                        else
                            if System.doesFileExist("app0:/DATA/" .. missing_cover) then
                                file.icon_path = "app0:/DATA/" .. missing_cover
                                file.cover = false
                            else
                                file.icon_path = "app0:/DATA/noimg.png"
                                file.cover = false
                            end
                        end
                        
                        file.app_type = def
                        file.app_type_default = def
                        file.filename = romname_withExtension
                        file.name = untouched_romname_noExtension
                        file.cover_path_online = online_cover_path
                        file.cover_path_local = local_cover_path
                        file.snap_path_local = local_snap_path
                        file.snap_path_online = online_snap_path
                        file.directory = false

                        --add blank icon to all
                        file.icon = imgCoverTmp
                        
                        if not is_bios then
                            table.insert(files_table, count_of_systems, file.icon) 
                            table.insert(files_table, count_of_systems, file.apptitle) 
                        end
                    end
                end

                -- Close database connection if it was opened
                if has_sql_db and db then
                    Database.close(db)
                end

                -- LOOKUP TITLE ID: Delete old file and save new list of matches
                if not System.doesFileExist(user_DB_Folder .. def_user_db_file) then
                    CreateUserTitleTable_for_File(def_user_db_file, def_table_name)
                else
                    System.deleteFile(user_DB_Folder .. def_user_db_file)
                    CreateUserTitleTable_for_File(def_user_db_file, def_table_name)
                end
            end
        end

        function Scan_PSM_DB_Lookup(def, def_quickscan_table, def_table_name, def_user_db_file, def_sql_db_file)

            local psm_directory = "ux0:/psm"
            if next(def_quickscan_table) then

                for i, file in pairs(def_quickscan_table) do
                local custom_path, custom_path_id, app_type, name, title, name_online, version, name_title_search = nil, nil, nil, nil, nil, nil, nil, nil
                    -- Scan files only, ignore temporary files, Windows = "Thumbs.db", Mac = "DS_Store", and "._name" 
                    if file.directory 
                        and string.match(file.name, "NPNA") 
                        or string.match(file.name, "NPOA")
                        or string.match(file.name, "NPPA") then

                            local psm_bubble_installed = false

                            -- check if game is in the favorites list
                            if System.doesFileExist(cur_dir .. "/favorites.dat") then
                                if string.find(strFav, file.name,1,true) ~= nil then
                                    file.favourite = true
                                else
                                    file.favourite = false
                                end
                            end

                            file.game_path = psm_directory .. "/" .. file.name

                            file.titleid = tostring(file.name)

                            -- LOOKUP TITLE ID: Get game name based on titleID, search saved table of data, or sql table of data if titleID not found

                            -- Load previous matches
                            if System.doesFileExist(user_DB_Folder .. (def_user_db_file)) then
                                database_rename_PSM = user_DB_Folder .. (def_user_db_file)
                                psmdb = safe_dofile(database_rename_PSM)
                            else
                                psmdb = {}
                            end

                            -- Check if scanned titleID is a saved match
                            psm_search = psmdb[file.name]

                            -- If no
                            if psm_search == nil then

                                -- Load the full sql database to find the new titleID

                                db = Database.open("ur0:shell/db/app.db")

                                sql_db_search_mame = "\"" .. file.name .. "\""
                                local query_string = "SELECT title FROM tbl_appinfo_icon where titleid is "  .. sql_db_search_mame
                                sql_db_search_result = Database.execQuery(db, query_string)

                                if next(sql_db_search_result) == nil then
                                    -- Not found; use the name without adding a game name
                                    title = file.name
                                else
                                    -- Found; use the game name from the full database
                                    psm_bubble_installed = true
                                    title = sql_db_search_result[1].title
                                end
                                Database.close(db)


                                db = Database.open("ur0:shell/db/app.db")

                                sql_db_search_mame = "\"" .. file.name .. "\""
                                local query_string = "SELECT val FROM tbl_appinfo where key=3168212510 and (tbl_appinfo.titleID is  " .. sql_db_search_mame .. ")"
                                sql_db_search_result = Database.execQuery(db, query_string)

                                if next(sql_db_search_result) == nil then
                                    -- Not found; use the name without adding a game name
                                    version = " "
                                else
                                    -- Found; use the game name from the full database
                                    version = sql_db_search_result[1].val
                                end
                                Database.close(db)


                            -- If found; use the game name from the saved match
                            else
                                psm_bubble_installed = true
                                title = psmdb[file.name].title
                                version = psmdb[file.name].version
                            end
                            
                            if psm_bubble_installed == true then
                                table.insert(folders_table, file)

                                -- file.filename = file.name
                                file.filename = file.name
                                file.name = file.name
                                file.title = title
                                file.name_online = file.name
                                file.version = version
                                file.name_title_search = file.name
                                file.apptitle = title
                                file.date_played = 0
                                file.snap_path_local = (SystemsToScan[(def)].localSnapPath)
                                file.snap_path_online = (SystemsToScan[(def)].onlineSnapPathSystem)
                                file.app_type=((def))
                                file.app_type_default=((def))

                                custom_path = (SystemsToScan[(def)].localCoverPath) .. file.title .. ".png"
                                custom_path_id = (SystemsToScan[(def)].localCoverPath) .. file.name .. ".png"

                                -- Check for renamed game names
                                if #renamed_games_table ~= nil then
                                    local key = find_game_table_pos_key(renamed_games_table, file.name)
                                    if key ~= nil then
                                      -- Yes - Found in files table
                                      file.title = renamed_games_table[key].title
                                      file.apptitle = renamed_games_table[key].title
                                    else
                                      -- No
                                    end
                                else
                                end

                                -- Check for hidden game names
                                file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                                table.insert((def_table_name), file)
                                update_loading_screen_progress((def))

                                if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                    img_path = (SystemsToScan[(def)].localCoverPath) .. file.title .. ".png" --custom cover by app name
                                    file.cover = true
                                elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                    img_path = (SystemsToScan[(def)].localCoverPath) .. file.name .. ".png" --custom cover by app id
                                    file.cover = true
                                else
                                    if System.doesFileExist("ur0:appmeta/" .. file.name .. "/pic0.png") then
                                        img_path = "ur0:appmeta/" .. file.name .. "/pic0.png"  --app icon
                                        file.cover = true
                                    elseif System.doesFileExist("app0:/DATA/" .. (SystemsToScan[(def)].Missing_Cover)) then
                                        img_path = "app0:/DATA/" .. (SystemsToScan[(def)].Missing_Cover)  --app icon
                                        file.cover = false
                                    else
                                        img_path = "app0:/DATA/noimg.png" --blank grey
                                        file.cover = false
                                    end
                                end
                                
                                file.app_type=((def))
                                file.app_type_default=((def))

                                -- file.filename = file.name
                                file.filename = file.titleid
                                file.name = file.titleid
                                file.cover_path_online = (SystemsToScan[(def)].onlineCoverPathSystem)
                                file.cover_path_local = (SystemsToScan[(def)].localCoverPath)
                                file.snap_path_local = (SystemsToScan[(def)].localSnapPath)
                                file.snap_path_online = (SystemsToScan[(def)].onlineSnapPathSystem)

                                --add blank icon to all
                                file.icon = imgCoverTmp
                                file.icon_path = img_path
                                
                                table.insert(files_table, count_of_systems, file.icon) 
                                table.insert(files_table, count_of_systems, file.apptitle)

                            else
                            end

                        end
                    end

                    -- LOOKUP TITLE ID: Delete old file and save new list of matches
                    if not System.doesFileExist(user_DB_Folder .. (def_user_db_file)) then
                        CreateUserTitleTable_for_PSM((def_user_db_file), (def_table_name))
                    else
                        System.deleteFile(user_DB_Folder .. (def_user_db_file))
                        CreateUserTitleTable_for_PSM((def_user_db_file), (def_table_name))
                    end

            else
            end
        end

        function Scan_Scummvm_DB_Lookup(def, def_table_name, def_user_db_file, def_sql_db_file)

            if #scan_scummvm_db > 0 then

                for i, file in pairs(scan_scummvm_db) do

                    local custom_path, custom_path_id, app_type, name, title, name_online, version, name_title_search = nil, nil, nil, nil, nil, nil, nil, nil

                    -- check if game is in the favorites list
                    if System.doesFileExist(cur_dir .. "/favorites.dat") then
                        if string.find(strFav, file.gameid,1,true) ~= nil then
                            file.favourite = true
                        else
                            file.favourite = false
                        end
                    end

                    file.game_path = file.path

                    file.titleid = file.gameid

                    if System.doesFileExist(cur_dir .. "/DATABASES/" .. (def_sql_db_file)) then
                        db = Database.open(cur_dir .. "/DATABASES/" .. (def_sql_db_file))

                        sql_db_search_mame = "\"" .. file.gameid .. "\""
                        search_term = "SELECT title FROM games where filename is "  .. sql_db_search_mame
                        sql_db_search_result = Database.execQuery(db, search_term)

                        if next(sql_db_search_result) == nil then
                            -- Not found; use the name without adding a game name
                            title = file.gameid
                        else
                            -- Found; use the game name from the full database
                            title = sql_db_search_result[1].title
                        end
                        Database.close(db)

                    else
                        title = file.gameid
                    end
                    
                    table.insert(folders_table, file)

                    -- file.filename = file.name
                    file.game_path_folder = file.game_path:gsub(".*:.*/+", '') -- Name of folder in game path - scummvm game folder name
                    file.directory = true
                    file.filename = file.gameid
                    file.name = file.gameid
                    file.title = title
                    file.name_online = file.gameid
                    -- file.version = scummvm_version
                    file.version = ""
                    file.name_title_search = file.gameid
                    file.apptitle = title
                    file.date_played = 0
                    file.snap_path_local = (SystemsToScan[(def)].localSnapPath)
                    file.snap_path_online = (SystemsToScan[(def)].onlineSnapPathSystem)
                    file.app_type=((def))
                    file.app_type_default=((def))

                    custom_path = (SystemsToScan[(def)].localCoverPath) .. file.title .. ".png"
                    custom_path_game_path_folder = (SystemsToScan[(def)].localCoverPath) .. file.game_path_folder .. ".png"
                    custom_path_id = (SystemsToScan[(def)].localCoverPath) .. file.name .. ".png"

                    -- Check for renamed game names
                    if #renamed_games_table ~= nil then
                        local key = find_game_table_pos_key(renamed_games_table, file.name)
                        if key ~= nil then
                          -- Yes - Found in files table
                          file.title = renamed_games_table[key].title
                          file.apptitle = renamed_games_table[key].title
                        else
                          -- No
                        end
                    else
                    end

                    -- Check for hidden game names
                    file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                    table.insert((def_table_name), file)
                    update_loading_screen_progress((def))

                    if custom_path and QuickDoesFileExist.covDir[custom_path] then
                        img_path = (SystemsToScan[(def)].localCoverPath) .. file.title .. ".png" --custom cover by app name
                    elseif custom_path_game_path_folder and System.doesFileExist(custom_path_game_path_folder) then
                        img_path = (SystemsToScan[(def)].localCoverPath) .. file.game_path_folder .. ".png" --custom cover by scummvm game folder name
                        file.cover = true
                    elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                        img_path = (SystemsToScan[(def)].localCoverPath) .. file.name .. ".png" --custom cover by app id
                        file.cover = true
                    else
                        if System.doesFileExist("app0:/DATA/" .. (SystemsToScan[(def)].Missing_Cover)) then
                            img_path = "app0:/DATA/" .. (SystemsToScan[(def)].Missing_Cover)  --app icon
                            file.cover = false
                        else
                            img_path = "app0:/DATA/noimg.png" --blank grey
                            file.cover = false
                        end
                    end
                    
                    file.app_type=((def))
                    file.app_type_default=((def))

                    -- file.filename = file.name 
                    file.filename = file.titleid
                    file.name = file.titleid
                    file.cover_path_online = (SystemsToScan[(def)].onlineCoverPathSystem)
                    file.cover_path_local = (SystemsToScan[(def)].localCoverPath)
                    file.snap_path_local = (SystemsToScan[(def)].localSnapPath)
                    file.snap_path_online = (SystemsToScan[(def)].onlineSnapPathSystem)

                    --add blank icon to all
                    file.icon = imgCoverTmp
                    file.icon_path = img_path
                    
                    table.insert(files_table, count_of_systems, file.icon) 
                    table.insert(files_table, count_of_systems, file.apptitle)

                end

            else
            end
        end

        function Scan_Sys_App_DB_Lookup(def, def_quickscan_table, def_table_name)

            local sys_app_directory = "vs0:/app"

            local filterList = {
                "NPXS10000", "NPXS10001", "NPXS10002", "NPXS10003",
                "NPXS10004", "NPXS10006", "NPXS10008", "NPXS10009",
                "NPXS10010", "NPXS10012", "NPXS10013", "NPXS10014",
                "NPXS10015", "NPXS10026", "NPXS10072", "NPXS10078",
                "NPXS10091", "NPXS10094", "NPXS10098"
            }

            local function isInFilterList(item)
                for _, code in ipairs(filterList) do
                    if string.sub(item, 1, string.len(code)) == code then
                        return true
                    end
                end
                return false
            end

            if next(def_quickscan_table) then

                for i, file in pairs(def_quickscan_table) do
                local custom_path, custom_path_id, app_type, name, title, name_online, version, name_title_search = nil, nil, nil, nil, nil, nil, nil, nil
                    -- Scan files only, ignore temporary files, Windows = "Thumbs.db", Mac = "DS_Store", and "._name" 
                if file.directory and (isInFilterList(file.name)) then

                        local sys_app_installed = false

                        -- check if game is in the favorites list
                        if System.doesFileExist(cur_dir .. "/favorites.dat") then
                            if string.find(strFav, file.name,1,true) ~= nil then
                                file.favourite = true
                            else
                                file.favourite = false
                            end
                        end

                        file.game_path = sys_app_directory .. "/" .. file.name

                        file.titleid = tostring(file.name)

                        -- LOOKUP TITLE ID: Get game name based on titleID, search saved table of data, or sql table of data if titleID not found

                        -- Load the full sql database to find the new titleID

                        db = Database.open("ur0:shell/db/app.db")

                        sql_db_search_mame = "\"" .. file.name .. "\""
                        local query_string = "SELECT title FROM tbl_appinfo_icon where titleid is "  .. sql_db_search_mame
                        sql_db_search_result = Database.execQuery(db, query_string)

                        if next(sql_db_search_result) == nil then

                            
                            -- Cross-Controller workaround - not in db table as part of ps3 app
                            if file.name == "NPXS10078" then
                                if System.doesDirExist("vs0:app/NPXS10012") then
                                    sys_app_installed = true
                                    title = "Cross-Controller"
                                end

                            -- Otherwise not found
                            else
                                title = file.name
                            end
                            
                        else
                            -- Found; use the game name from the full database
                            sys_app_installed = true
                            title = sql_db_search_result[1].title
                        end
                        Database.close(db)

                        
                        if sys_app_installed == true then

                            table.insert(folders_table, file)

                            -- file.filename = file.name
                            file.filename = file.name
                            file.name = file.name
                            file.title = title
                            file.name_online = file.name
                            file.version = " "
                            file.name_title_search = file.name
                            file.apptitle = title
                            file.date_played = 0
                            file.snap_path_local = (SystemsToScan[(def)].localSnapPath)
                            file.snap_path_online = (SystemsToScan[(def)].onlineSnapPathSystem)
                            file.app_type=((def))
                            file.app_type_default=((def))

                            custom_path = (SystemsToScan[(def)].localCoverPath) .. file.title .. ".png"
                            custom_path_id = (SystemsToScan[(def)].localCoverPath) .. file.name .. ".png"

                            -- Check for renamed game names
                            if #renamed_games_table ~= nil then
                                local key = find_game_table_pos_key(renamed_games_table, file.name)
                                if key ~= nil then
                                  -- Yes - Found in files table
                                  file.title = renamed_games_table[key].title
                                  file.apptitle = renamed_games_table[key].title
                                else
                                  -- No
                                end
                            else
                            end

                            -- Check for hidden game names
                            file.hidden = check_for_hidden_tag_on_scan(file.name, file.app_type)

                            table.insert((def_table_name), file)
                            update_loading_screen_progress((def))

                            if custom_path and QuickDoesFileExist.covDir[custom_path] then
                                img_path = (SystemsToScan[(def)].localCoverPath) .. file.title .. ".png" --custom cover by app name
                                file.cover = true
                            elseif custom_path_id and QuickDoesFileExist.covDir[custom_path_id] then
                                img_path = (SystemsToScan[(def)].localCoverPath) .. file.name .. ".png" --custom cover by app id
                                file.cover = true
                            else
                                if System.doesFileExist("vs0:/app/" .. file.name .. "/sce_sys/icon0.png") then
                                    img_path = "vs0:/app/" .. file.name .. "/sce_sys/icon0.png"  --app icon
                                    file.cover = true
                                elseif System.doesFileExist("app0:/DATA/" .. (SystemsToScan[(def)].Missing_Cover)) then
                                    img_path = "app0:/DATA/" .. (SystemsToScan[(def)].Missing_Cover)  --app icon
                                    file.cover = false
                                else
                                    img_path = "app0:/DATA/noimg.png" --blank grey
                                    file.cover = false
                                end
                            end
                            
                            file.app_type=((def))
                            file.app_type_default=((def))

                            -- file.filename = file.name
                            file.filename = file.titleid
                            file.name = file.titleid
                            file.cover_path_online = (SystemsToScan[(def)].onlineCoverPathSystem)
                            file.cover_path_local = (SystemsToScan[(def)].localCoverPath)
                            file.snap_path_local = (SystemsToScan[(def)].localSnapPath)
                            file.snap_path_online = (SystemsToScan[(def)].onlineSnapPathSystem)

                            --add blank icon to all
                            file.icon = imgCoverTmp
                            file.icon_path = img_path
                            
                            table.insert(files_table, count_of_systems, file.icon) 
                            table.insert(files_table, count_of_systems, file.apptitle)

                        else
                        end

                    end
                end

            else
            end
        end


    -- SCAN COMMANDS

        -- Vita

            scan_Vita()

        -- Adrenaline
        
            if Adrenaline_roms == 1 then
                adr_partition = "ux0"
            elseif Adrenaline_roms == 2 then
                adr_partition = "ur0"
            elseif Adrenaline_roms == 3 then
                adr_partition = "imc0"
            elseif Adrenaline_roms == 4 then
                adr_partition = "xmc0"
            else 
                adr_partition = "uma0"
            end

            if Adrenaline_roms == 5 then
                for k, v in pairs(adr_partition_table) do
                    scan_PSP_iso_folder     (tostring(v)  .. ":/pspemu/ISO")
                    scan_PSP_game_folder    (tostring(v)  .. ":/pspemu/PSP/GAME")
                    scan_PS1_game_folder    (tostring(v)  .. ":/pspemu/PSP/GAME")
                end
            else
                scan_PSP_iso_folder     (adr_partition  .. ":/pspemu/ISO")
                scan_PSP_game_folder    (adr_partition  .. ":/pspemu/PSP/GAME")
                scan_PS1_game_folder    (adr_partition  .. ":/pspemu/PSP/GAME")
            end

        -- Roms

            -- Scan_Type            (def,  def_table_name)
            scan_Rom_PS1_RA_All     (4, psx_table) -- Retroarch rom folder exluding pbp formats
            Scan_Rom_Simple         (5, QuickGameList.n64_table,                    n64_table)
            Scan_Rom_Simple         (6, QuickGameList.snes_table,                   snes_table)
            Scan_Rom_Simple         (7, QuickGameList.nes_table,                    nes_table)
            Scan_Rom_Simple         (8, QuickGameList.gba_table,                    gba_table)
            Scan_Rom_Simple         (9, QuickGameList.gbc_table,                    gbc_table)
            Scan_Rom_Simple         (10, QuickGameList.gb_table,                    gb_table)
            Scan_Rom_Simple         (11, QuickGameList.dreamcast_table,             dreamcast_table)
            Scan_Rom_Simple         (12, QuickGameList.sega_cd_table,               sega_cd_table)
            Scan_Rom_Simple         (13, QuickGameList.s32x_table,                  s32x_table)
            Scan_Rom_Simple         (14, QuickGameList.md_table,                    md_table)
            Scan_Rom_Simple         (15, QuickGameList.sms_table,                   sms_table)
            Scan_Rom_Simple         (16, QuickGameList.gg_table,                    gg_table)
            Scan_Rom_Simple         (17, QuickGameList.tg16_table,                  tg16_table)
            Scan_Rom_Simple         (18, QuickGameList.tgcd_table,                  tgcd_table)
            Scan_Rom_Simple         (19, QuickGameList.pce_table,                   pce_table)
            Scan_Rom_Simple         (20, QuickGameList.pcecd_table,                 pcecd_table)
            Scan_Rom_DB_Lookup      (21, QuickGameList.amiga_table,                 amiga_table, "amiga.lua", "amiga.db")
            Scan_Rom_Simple         (22, QuickGameList.c64_table,                   c64_table)
            Scan_Rom_Simple         (23, QuickGameList.wswan_col_table,             wswan_col_table)
            Scan_Rom_Simple         (24, QuickGameList.wswan_table,                 wswan_table)
            Scan_Rom_Simple         (25, QuickGameList.msx2_table,                  msx2_table)
            Scan_Rom_Simple         (26, QuickGameList.msx1_table,                  msx1_table)
            Scan_Rom_Simple         (27, QuickGameList.zxs_table,                   zxs_table)
            Scan_Rom_Simple         (28, QuickGameList.atari_7800_table,            atari_7800_table)
            Scan_Rom_Simple         (29, QuickGameList.atari_5200_table,            atari_5200_table)
            Scan_Rom_Simple         (30, QuickGameList.atari_2600_table,            atari_2600_table)
            Scan_Rom_Simple         (31, QuickGameList.atari_lynx_table,            atari_lynx_table)
            Scan_Rom_Simple         (32, QuickGameList.colecovision_table,          sms_table)
            Scan_Rom_Simple         (33, QuickGameList.vectrex_table,               sms_table)
            Scan_Rom_DB_Lookup      (34, QuickGameList.fba_table,                   fba_table, "fba_2012.lua", "fba_2012.db")
            Scan_Rom_DB_Lookup      (35, QuickGameList.mame_2003_plus_table,        mame_2003_plus_table, "mame_2003_plus.lua", "mame_2003_plus.db")
            Scan_Rom_DB_Lookup      (36, QuickGameList.mame_2000_table,             mame_2000_table, "mame_2000.lua", "mame_2000.db")
            Scan_Rom_DB_Lookup      (37, QuickGameList.neogeo_table,                neogeo_table, "neogeo.lua", "neogeo.db")
            Scan_Rom_Simple         (38, QuickGameList.ngpc_table,                  ngpc_table)
            Scan_PSM_DB_Lookup      (39, QuickGameList.psm_table,                   psm_table, "psm.lua")
            Scan_Scummvm_DB_Lookup  (40, scummvm_table,                             "scummvm.lua", "scummvm.db")
            Scan_Rom_Filter_Pico8   (41, QuickGameList.pico8_table,                 pico8_table)
            Scan_Sys_App_DB_Lookup  (42, QuickGameList.sysapps_table,               sysapps_table)
            Scan_Rom_Simple         (43, QuickGameList.nds_table,                   nds_table)
  
    import_recently_played()
    update_md_regional_cover()
    update_dc_regional_cover()

    table.sort(files_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(folders_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(games_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(homebrews_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(psp_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(psx_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)

    table.sort(n64_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(snes_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(nes_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(nds_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(gba_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(gbc_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(gb_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(dreamcast_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(sega_cd_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(s32x_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(md_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(sms_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(gg_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(tg16_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(tgcd_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(pce_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(pcecd_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(amiga_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(c64_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(wswan_col_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(wswan_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(msx2_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(msx1_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(zxs_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(atari_7800_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(atari_5200_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(atari_2600_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(atari_lynx_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(colecovision_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(vectrex_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(fba_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(mame_2003_plus_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(mame_2000_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(neogeo_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(ngpc_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(psm_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(scummvm_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(pico8_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(sysapps_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)

    table.sort(recently_played_table, function(a, b) return (tonumber(a.date_played) > tonumber(b.date_played)) end)
    
    update_loading_screen_complete()

    -- CACHE ALL TABLES - PRINT AND SAVE
    CreateUserTitleTable_for_Vita(user_DB_Folder .. "sfo_scan_vita.lua", new_sfo_cache_table_vita)

    -- CLEANUP TABLES BEFORE CACHING
        local cleansed_table_count = 1

        function remove_uneccessary_keys_before_cache(def_table)
            if def_table then
                for i, file in ipairs(def_table) do
                    file.adrenaline_bubble = nil
                    file.subfolder = nil
                    file.icon = nil
                    file.size = nil
                end
            end
            cleansed_table_count = cleansed_table_count +1
        end

        while cleansed_table_count <= 45 do
            remove_uneccessary_keys_before_cache(xAppNumTableLookup(cleansed_table_count))
        end


    cache_all_tables()

end


function import_cached_DB_tables(def_user_db_file, def_table_name)
    if System.doesFileExist(db_Cache_Folder .. (def_user_db_file)) then
        db_Cache = db_Cache_Folder .. (def_user_db_file)

        local db_import = {}
        local importLuaFileError = importLuaFile(db_Cache, db_import)
        
        if importLuaFileError then
            -- File is corrupt, delete it
            System.deleteFile(db_Cache)

            -- Start app again to rescan
            FreeMemory()
            Network.term()
            dofile("app0:index.lua")

        else
        -- db_import = dofile(db_Cache)

            for k, v in ipairs(db_import) do

                -- PSM - check for cover on import
                -- Commented out, was preventing custom covers being shown - Can't remember why this was in here?
                -- if v.app_type == 39 then
                --     if System.doesFileExist("ur0:appmeta/" .. v.name .. "/pic0.png") then
                --         img_path = "ur0:appmeta/" .. v.name .. "/pic0.png"  --app icon
                --         v.icon_path = img_path
                --         v.cover = true
                --     end
                -- end

                -- For each game to be imported, cross reference against then hidden games list
                for l, file in ipairs(hidden_games_table) do

                    -- Check the app type matches
                    if file.app_type == v.app_type then

                        -- Check if hidden game is in the import table
                        local key = {}
                        key = find_game_table_pos_key(db_import, file.name)

                        if key ~= nil then
                            -- Game found 
                            -- Update hidden key
                            if file.hidden == true then
                                db_import[key].hidden = true
                            else
                                db_import[key].hidden = false
                            end
                        else
                            -- Game not found
                            -- If showing hidden games, then check the game file / folder exists for adding to the import table
                            if showHidden==1 then
                                if v.directory == false then
                                    if System.doesFileExist(v.game_path) then
                                        table.insert(db_import, file)
                                    end
                                else
                                    if System.doesDirExist(v.game_path) then
                                        table.insert(db_import, file)
                                    end
                                end
                            else
                            end
                        end
                    else
                    end

                end

                -- If hiding games, only import non-hidden games
                if showHidden==0 then
                    if v.hidden==false then

                        -- Show missing covers if off
                        if showMissingCovers == 0 then
                            if v.cover==true then

                                if temp_import ~= true then
                                    table.insert(folders_table, v)
                                end
                                table.insert((def_table_name), v)

                                --add blank icon to all
                                v.icon = imgCoverTmp
                                v.icon_path = v.icon_path

                                v.apptitle = v.apptitle
                                if temp_import ~= true then
                                    table.insert(files_table, count_of_systems, v.apptitle)
                                end
                            else
                            end

                        else
                            if temp_import ~= true then
                                table.insert(folders_table, v)
                            end
                            table.insert((def_table_name), v)

                            --add blank icon to all
                            v.icon = imgCoverTmp
                            v.icon_path = v.icon_path

                            v.apptitle = v.apptitle
                            if temp_import ~= true then
                                table.insert(files_table, count_of_systems, v.apptitle)
                            end
                        end
                    else
                    end
                else
                    -- Show missing covers if off
                    if showMissingCovers == 0 then
                        if v.cover==true then
                            if temp_import ~= true then
                                table.insert(folders_table, v)
                            end
                            table.insert((def_table_name), v)

                            --add blank icon to all
                            v.icon = imgCoverTmp
                            v.icon_path = v.icon_path

                            v.apptitle = v.apptitle
                            if temp_import ~= true then
                                table.insert(files_table, count_of_systems, v.apptitle)
                            end
                        else
                        end

                    else
                        if temp_import ~= true then
                            table.insert(folders_table, v)
                        end
                        table.insert((def_table_name), v)

                        --add blank icon to all
                        v.icon = imgCoverTmp
                        v.icon_path = v.icon_path

                        v.apptitle = v.apptitle
                        if temp_import ~= true then
                            table.insert(files_table, count_of_systems, v.apptitle)
                        end
                    end
                end

            end
        
        end

    end
end

function import_cached_DB_homebrews_in_collections(def_user_db_file, def_table_name)

    if collection_count >= 1 then
        temp_hb_collection = {}
        for z, collection_file_num in ipairs(collection_files) do
            
            -- Import lua file into temp table
            local temp_db_import = {}
            local importLuaFileError = importLuaFile(collections_dir .. collection_file_num.filename, temp_db_import)

            if importLuaFileError then
                -- File is corrupt, delete it
                System.deleteFile(collections_dir .. collection_file_num.filename)
            else
                for l, file in ipairs(temp_db_import) do
                    if file.app_type == 0 then
                        table.insert(temp_hb_collection, file)
                    end
                end
            end

        end

        if System.doesFileExist(db_Cache_Folder .. (def_user_db_file)) then
            db_Cache = db_Cache_Folder .. (def_user_db_file)

            local db_import = {}
            local importLuaFileError = importLuaFile(db_Cache, db_import)
            
            if importLuaFileError then
                -- File is corrupt, delete it
                System.deleteFile(db_Cache)

                -- Start app again to rescan
                FreeMemory()
                Network.term()
                dofile("app0:index.lua")

            else

                for k, v in ipairs(db_import) do

                    -- For each game to be imported, cross reference against then hidden games list
                    for l, file in ipairs(hidden_games_table) do

                        -- Check the app type matches
                        if file.app_type == v.app_type then

                            -- Check if hidden game is in the import table
                            local key = {}
                            key = find_game_table_pos_key(db_import, file.name)

                            if key ~= nil then
                                -- Game found 
                                -- Update hidden key
                                if file.hidden == true then
                                    db_import[key].hidden = true
                                else
                                    db_import[key].hidden = false
                                end
                            else
                                -- Game not found
                                -- If showing hidden games, then check the game file / folder exists for adding to the import table
                                if showHidden==1 then
                                    if v.directory == false then
                                        if System.doesFileExist(v.game_path) then
                                            table.insert(db_import, file)
                                        end
                                    else
                                        if System.doesDirExist(v.game_path) then
                                            table.insert(db_import, file)
                                        end
                                    end
                                else
                                end
                            end
                        else
                        end

                    end

                    -- Import homebrew if in collection
                    for key, data in pairs(temp_hb_collection) do
                        if data.name == v.name then

                            -- If hiding games, only import non-hidden games
                            if showHidden==0 then
                                if v.hidden==false then

                                    -- Show missing covers if off
                                    if showMissingCovers == 0 then
                                        if v.cover==true then
                                            table.insert(folders_table, v)
                                            table.insert(homebrews_table, v)

                                            --add blank icon to all
                                            v.icon = imgCoverTmp
                                            v.icon_path = v.icon_path

                                            v.apptitle = v.apptitle
                                            table.insert(files_table, count_of_systems, v.apptitle)
                                        else
                                        end

                                    else
                                        table.insert(folders_table, v)
                                        table.insert(homebrews_table, v)

                                        --add blank icon to all
                                        v.icon = imgCoverTmp
                                        v.icon_path = v.icon_path

                                        v.apptitle = v.apptitle
                                        table.insert(files_table, count_of_systems, v.apptitle)
                                    end
                                else
                                end
                            else
                                -- Show missing covers if off
                                if showMissingCovers == 0 then
                                    if v.cover==true then
                                        table.insert(folders_table, v)
                                        table.insert(homebrews_table, v)

                                        --add blank icon to all
                                        v.icon = imgCoverTmp
                                        v.icon_path = v.icon_path

                                        v.apptitle = v.apptitle
                                        table.insert(files_table, count_of_systems, v.apptitle)
                                    else
                                    end

                                else
                                    table.insert(folders_table, v)
                                    table.insert(homebrews_table, v)

                                    --add blank icon to all
                                    v.icon = imgCoverTmp
                                    v.icon_path = v.icon_path

                                    v.apptitle = v.apptitle
                                    table.insert(files_table, count_of_systems, v.apptitle)
                                end
                            end

                        end
                    end

                end

            end

        end

    else
    end
end


function import_cached_DB()
    -- dir = System.listDirectory(dir)
    folders_table = {}
    files_table = {}
    games_table = {}
    homebrews_table = {}
    psp_table = {}
    psx_table = {}
    n64_table = {}
    snes_table = {}
    nes_table = {}
    nds_table = {}
    gba_table = {}
    gbc_table = {}
    gb_table = {}
    dreamcast_table = {}
    sega_cd_table = {}
    s32x_table = {}
    md_table = {}
    sms_table = {}
    gg_table = {}
    tg16_table = {}
    tgcd_table = {}
    pce_table = {}
    pcecd_table = {}
    amiga_table = {}
    c64_table = {}
    wswan_col_table = {}
    wswan_table = {}
    msx2_table = {}
    msx1_table = {}
    zxs_table = {}
    atari_7800_table = {}
    atari_5200_table = {}
    atari_2600_table = {}
    atari_lynx_table = {}
    colecovision_table = {}
    vectrex_table = {}
    fba_table = {}
    mame_2003_plus_table = {}
    mame_2000_table = {}
    neogeo_table = {} 
    ngpc_table = {}
    psm_table = {}
    scummvm_table = {}
    pico8_table = {}
    sysapps_table = {}
    recently_played_table = {}
    search_results_table = {}
    fav_count = {}
    renamed_games_table = {}
    hidden_games_table = {}
    files_table_no_sysapps = {}
    

    local file_over = System.openFile(cur_dir .. "/overrides.dat", FREAD)
    local filesize = System.sizeFile(file_over)
    local str = System.readFile(file_over, filesize)
    System.closeFile(file_over)

    import_renamed_games()
    import_hidden_games()


    import_cached_DB_tables("db_games.lua", games_table)
    if showHomebrews == 1 then
        import_cached_DB_tables("db_homebrews.lua", homebrews_table)
    else
        -- Show Homebrew is off - only import if in a collection
        import_cached_DB_homebrews_in_collections("db_homebrews.lua", homebrews_table)
    end
    import_cached_DB_tables("db_psp.lua", psp_table)
    import_cached_DB_tables("db_psx.lua", psx_table)
    import_cached_DB_tables("db_n64.lua", n64_table)
    import_cached_DB_tables("db_snes.lua", snes_table)
    import_cached_DB_tables("db_nes.lua", nes_table)
    import_cached_DB_tables("db_nds.lua", nds_table)
    import_cached_DB_tables("db_gba.lua", gba_table)
    import_cached_DB_tables("db_gbc.lua", gbc_table)
    import_cached_DB_tables("db_gb.lua", gb_table)
    import_cached_DB_tables("db_dreamcast.lua", dreamcast_table)
    import_cached_DB_tables("db_sega_cd.lua", sega_cd_table)
    import_cached_DB_tables("db_32x.lua", s32x_table)
    import_cached_DB_tables("db_md.lua", md_table)
    import_cached_DB_tables("db_sms.lua", sms_table)
    import_cached_DB_tables("db_gg.lua", gg_table)
    import_cached_DB_tables("db_tg16.lua", tg16_table)
    import_cached_DB_tables("db_tgcd.lua", tgcd_table)
    import_cached_DB_tables("db_pce.lua", pce_table)
    import_cached_DB_tables("db_pcecd.lua", pcecd_table)
    import_cached_DB_tables("db_amiga.lua", amiga_table)
    import_cached_DB_tables("db_c64.lua", c64_table)
    import_cached_DB_tables("db_wswan_col.lua", wswan_col_table)
    import_cached_DB_tables("db_wswan.lua", wswan_table)
    import_cached_DB_tables("db_msx2.lua", msx2_table)
    import_cached_DB_tables("db_msx1.lua", msx1_table)
    import_cached_DB_tables("db_zxs.lua", zxs_table)
    import_cached_DB_tables("db_atari_7800.lua", atari_7800_table)
    import_cached_DB_tables("db_atari_5200.lua", atari_5200_table)
    import_cached_DB_tables("db_atari_2600.lua", atari_2600_table)
    import_cached_DB_tables("db_atari_lynx.lua", atari_lynx_table)
    import_cached_DB_tables("db_colecovision.lua", colecovision_table)
    import_cached_DB_tables("db_vectrex.lua", vectrex_table)
    import_cached_DB_tables("db_fba.lua", fba_table)
    import_cached_DB_tables("db_mame_2003_plus.lua", mame_2003_plus_table)
    import_cached_DB_tables("db_mame_2000.lua", mame_2000_table)
    import_cached_DB_tables("db_neogeo.lua", neogeo_table)
    import_cached_DB_tables("db_ngpc.lua", ngpc_table)
    import_cached_DB_tables("db_psm.lua", psm_table)
    import_cached_DB_tables("db_scummvm.lua", scummvm_table)
    import_cached_DB_tables("db_pico8.lua", pico8_table)
    if showSysApps == 1 then
        import_cached_DB_tables("db_sysapps.lua", sysapps_table)
    end
    import_recently_played()
    update_md_regional_cover()
    update_dc_regional_cover()
    

    table.sort(files_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(folders_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(games_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(homebrews_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(psp_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(psx_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)

    table.sort(n64_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(snes_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(nes_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(nds_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(gba_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(gbc_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(gb_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(dreamcast_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(sega_cd_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(s32x_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(md_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(sms_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(gg_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(tg16_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(tgcd_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(pce_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(pcecd_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(amiga_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(c64_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(wswan_col_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(wswan_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(msx2_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(msx1_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(zxs_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(atari_7800_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(atari_5200_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(atari_2600_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(atari_lynx_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(colecovision_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(vectrex_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(fba_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(mame_2003_plus_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(mame_2000_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(neogeo_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(ngpc_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(psm_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(scummvm_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(pico8_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(sysapps_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)

    table.sort(recently_played_table, function(a, b) return (tonumber(a.date_played) > tonumber(b.date_played)) end)

    return_table = TableConcat(folders_table, files_table)

    -- Hide sys apps from all list
    for k, v in ipairs(return_table) do
        if v.app_type ~= 42 then
            table.insert(files_table_no_sysapps, v)
        else
        end
    end

    total_all = #files_table
    total_games = #games_table
    total_homebrews = #homebrews_table
    total_recently_played = #recently_played_table
    
    return return_table

end


function loadImage(img_path)
    imgTmp = Graphics.loadImage(img_path)
end


-- CHECK IF STARTUP SCAN IS ON
-- 0 Off, 1 On
if startupScan == 1 then
    -- Startup scan is ON

    -- Scan folders and games
    count_loading_tasks()
    files_table = Full_Game_Scan()
    files_table = import_cached_DB()
    import_collections()
else
    -- Startup scan is OFF

    -- Check cache files before importing, does the folder exist?
    if  System.doesDirExist(db_Cache_Folder) then

        -- Folder exists - Count files
        cache_file_count = System.listDirectory(db_Cache_Folder)
        if #cache_file_count ~= count_of_cache_files then
            -- Files missing - rescan
            count_loading_tasks()
            files_table = Full_Game_Scan()
            files_table = import_cached_DB()
            import_collections()
        else
            -- Files all pesent - Import Cached Database
            files_table = import_cached_DB()
            import_collections()
        end
    else
        -- Folder missing - rescan
        count_loading_tasks()
        files_table = Full_Game_Scan()
        files_table = import_cached_DB()
        import_collections()
    end
end



-- Get app and game sizes

    -- Shared size formatting function
    local function formatSize(total_bytes)
        local size = total_bytes
        local units = {"B", "KB", "MB", "GB"}
        local unit = 1
        
        -- Convert to next unit when >= 1024, but for GB display when MB >= 1000 for better UX
        while (unit < 3 and size >= 1024.0) or (unit == 3 and size >= 1000.0) do
            if unit < 4 then
                size = size / 1024.0
                unit = unit + 1
            else
                break
            end
        end
        
        if unit == 4 then -- GB - use decimal
            return string.format("%.1f %s", size, units[unit])
        else -- B, KB, MB - use rounded integer
            local rounded = math.floor(size + 0.5)
            return string.format("%d %s", rounded, units[unit])
        end
    end

    function getAppSize(dir)
        local size = 0
        local function get_size(dir)
            local d = System.listDirectory(dir) or {}
            for _, v in ipairs(d) do
                if v.directory then
                    get_size(dir .. "/" .. v.name)
                else
                    size = size + (v.size or 0)
                end
            end
        end
        get_size(dir)
        
        local display_string = formatSize(size)
        
        return display_string
    end

    function getRomSize()
        -- Get rom size for info screen
        if System.doesFileExist(appdir) then
            local tmpfile = System.openFile(appdir, FREAD)
            local size = System.sizeFile(tmpfile)
            System.closeFile(tmpfile)
            
            local display_string = formatSize(size)
            game_size = display_string  -- Set global for backward compatibility
            
            return display_string
        else
            -- Error handling for missing game
            local display_string = "0 B"
            game_size = display_string  -- Set global for backward compatibility
            
            return display_string
        end
    end


function wraptextlength(s, x, indent)
    --https://stackoverflow.com/questions/35006931/lua-line-breaks-in-strings
    x = x or 79
    indent = indent or ""
    local t = {""}
    local function cleanse(s) return s:gsub("@x%d%d%d",""):gsub("@r","") end

    for prefix, word, suffix, newline in s:gmatch("([ \t]*)(%S*)([ \t]*)(\n?)") do
        if #(cleanse(t[#t])) + #prefix + #cleanse(word) > x and #t > 0 then
            table.insert(t, word..suffix) -- add new element
        else -- add to the last element
            t[#t] = t[#t]..prefix..word..suffix
        end
        if #newline > 0 then 
            table.insert(t, "") 
        end
    end

    return indent..table.concat(t, "\n"..indent)
end

function GetPicPath(def_table_name)
    -- Get pic from backgrounds folder, or use default

    -- ScummVM 
    if (def_table_name)[p].app_type == 40 then
        -- Check for image using scummvm game folder name
        if System.doesFileExist((def_table_name)[p].snap_path_local .. (def_table_name)[p].game_path:gsub(".*:.*/+", '') .. ".png") then
            pic_path = (def_table_name)[p].snap_path_local .. (def_table_name)[p].game_path:gsub(".*:.*/+", '') .. ".png"
        elseif System.doesFileExist((def_table_name)[p].snap_path_local .. (def_table_name)[p].title .. ".png") then
            pic_path = (def_table_name)[p].snap_path_local .. (def_table_name)[p].title .. ".png"
        elseif System.doesFileExist((def_table_name)[p].snap_path_local .. (def_table_name)[p].name .. ".png") then
            pic_path = (def_table_name)[p].snap_path_local .. (def_table_name)[p].name .. ".png"
        else
            pic_path = ""
        end

    -- Homebrew
    elseif (def_table_name)[p].app_type == 0 then
        -- Check backgrounds folder
        if System.doesFileExist((def_table_name)[p].snap_path_local .. (def_table_name)[p].title .. ".png") then
            pic_path = (def_table_name)[p].snap_path_local .. (def_table_name)[p].title .. ".png"

        elseif System.doesFileExist((def_table_name)[p].snap_path_local .. (def_table_name)[p].name .. ".png") then
            pic_path = (def_table_name)[p].snap_path_local .. (def_table_name)[p].name .. ".png"

        -- Not found? Then check ur0 pic
        elseif System.doesFileExist("ur0:/appmeta/" .. (def_table_name)[p].name .. "/pic0.png") then
            pic_path = "ur0:/appmeta/" .. (def_table_name)[p].name .. "/pic0.png"

        -- Not found? Check homebew snap folder
        elseif System.doesFileExist((def_table_name)[p].snap_path_local .. (def_table_name)[p].name .. ".png") then
            pic_path = (def_table_name)[p].snap_path_local .. (def_table_name)[p].name .. ".png"

        -- Not found? Check vita snap folder
        elseif System.doesFileExist("ux0:/data/RetroFlow/BACKGROUNDS/Sony - PlayStation Vita/" .. (def_table_name)[p].name .. ".png") then
            pic_path = "ux0:/data/RetroFlow/BACKGROUNDS/Sony - PlayStation Vita/" .. (def_table_name)[p].name .. ".png"

        else
            pic_path = ""

        end 


    -- Other systems
    else
        -- Check backgrounds folder
        if System.doesFileExist((def_table_name)[p].snap_path_local .. (def_table_name)[p].title .. ".png") then
            pic_path = (def_table_name)[p].snap_path_local .. (def_table_name)[p].title .. ".png"

        elseif System.doesFileExist((def_table_name)[p].snap_path_local .. (def_table_name)[p].name .. ".png") then
            pic_path = (def_table_name)[p].snap_path_local .. (def_table_name)[p].name .. ".png"

        -- Not found? Then check ur0 pic
        elseif System.doesFileExist("ur0:/appmeta/" .. (def_table_name)[p].name .. "/pic0.png") then
            pic_path = "ur0:/appmeta/" .. (def_table_name)[p].name .. "/pic0.png"

        -- Not found? Then check vs0 pic
        elseif System.doesFileExist("vs0:/app/" .. (def_table_name)[p].name .. "/sce_sys/pic0.png") then
            pic_path = "vs0:/app/" .. (def_table_name)[p].name .. "/sce_sys/pic0.png"

         -- Not found? Check snap folder
        elseif System.doesFileExist((def_table_name)[p].snap_path_local .. (def_table_name)[p].name .. ".png") then
            pic_path = (def_table_name)[p].snap_path_local .. (def_table_name)[p].name .. ".png"
        else
            pic_path = ""

        end 

    end
end

function xAppIconPathLookup(AppTypeNum)
    if     apptype==1   then 

        -- Vita
        -- Check appmeta first
        if System.doesFileExist(working_dir .. "/" .. xCatLookup(showCat)[p].name .. "/sce_sys/param.sfo") then
            return "ur0:/appmeta/" .. xCatLookup(showCat)[p].name .. "/icon0.png"
        -- If not found, check icons dir
        elseif System.doesFileExist(iconDir .. "Sony - PlayStation Vita/" .. xCatLookup(showCat)[p].name .. ".png") then
            return iconDir .. "Sony - PlayStation Vita/" .. xCatLookup(showCat)[p].name .. ".png"
        -- Still not found, use placeholder icon
        else
            return "app0:/DATA/icon_psv.png"
        end
    elseif apptype==2   then return "app0:/DATA/icon_psp.png"
    elseif apptype==3   then return "app0:/DATA/icon_psx.png"
    elseif apptype==5   then return "app0:/DATA/icon_n64.png"
    elseif apptype==6   then return "app0:/DATA/icon_snes.png"
    elseif apptype==7   then return "app0:/DATA/icon_nes.png"
    elseif apptype==8   then return "app0:/DATA/icon_gba.png"
    elseif apptype==9   then return "app0:/DATA/icon_gbc.png"
    elseif apptype==10  then return "app0:/DATA/icon_gb.png"
    elseif apptype==11  then
        -- Dreamcast
        if setLanguage == 0 then -- EN - Blue logo
            return "app0:/DATA/icon_dreamcast_eur.png"
        elseif setLanguage == 1 then -- USA - Red logo
            return "app0:/DATA/icon_dreamcast_usa.png"
        elseif setLanguage == 9 or setLanguage == 19 then -- Japan - Orange logo
            return "app0:/DATA/icon_dreamcast_j.png"
        else -- Blue logo
            return "app0:/DATA/icon_dreamcast_eur.png"
        end
    elseif apptype==12  then return "app0:/DATA/icon_sega_cd.png"
    elseif apptype==13  then return "app0:/DATA/icon_32x.png"
    elseif apptype==14  then
        -- MD
        if setLanguage == 1 then
            return "app0:/DATA/icon_md_usa.png"
        else
            return "app0:/DATA/icon_md.png"
        end
    elseif apptype==15  then return "app0:/DATA/icon_sms.png"
    elseif apptype==16  then return "app0:/DATA/icon_gg.png"
    elseif apptype==17  then return "app0:/DATA/icon_tg16.png"
    elseif apptype==18  then return "app0:/DATA/icon_tgcd.png"
    elseif apptype==19  then return "app0:/DATA/icon_pce.png"
    elseif apptype==20  then return "app0:/DATA/icon_pcecd.png"
    elseif apptype==21  then return "app0:/DATA/icon_amiga.png"
    elseif apptype==22  then return "app0:/DATA/icon_c64.png"
    elseif apptype==23  then return "app0:/DATA/icon_wswan_col.png"
    elseif apptype==24  then return "app0:/DATA/icon_wswan.png"
    elseif apptype==25  then return "app0:/DATA/icon_msx2.png"
    elseif apptype==26  then return "app0:/DATA/icon_msx1.png"
    elseif apptype==27  then return "app0:/DATA/icon_zxs.png"
    elseif apptype==28  then return "app0:/DATA/icon_atari_7800.png"
    elseif apptype==29  then return "app0:/DATA/icon_atari_5200.png"
    elseif apptype==30  then return "app0:/DATA/icon_atari_2600.png"
    elseif apptype==31  then return "app0:/DATA/icon_atari_lynx.png"
    elseif apptype==32  then return "app0:/DATA/icon_colecovision.png"
    elseif apptype==33  then return "app0:/DATA/icon_vectrex.png"
    elseif apptype==34  then return "app0:/DATA/icon_fba.png"
    elseif apptype==35  then return "app0:/DATA/icon_mame.png"
    elseif apptype==36  then return "app0:/DATA/icon_mame.png"
    elseif apptype==37  then return "app0:/DATA/icon_neogeo.png"
    elseif apptype==38  then return "app0:/DATA/icon_ngpc.png"
    elseif apptype==40  then return "app0:/DATA/icon_scummvm.png"
    elseif apptype==41  then return "app0:/DATA/icon_pico8.png"
    elseif apptype==42  then return "app0:/DATA/icon_psv.png"
    elseif apptype==43  then return "app0:/DATA/icon_nds.png"
    else 
        -- Homebrew 
        return xCatLookup(showCat)[p].icon_path
    end
end


function GetNameAndAppTypeSelected() -- Credit to BlackSheepBoy69 - This gives a massive performance boost VS reading whole app info.
    if #xCatLookup(showCat) > 0 then --if the currently-shown category isn't empty
        app_title = xCatLookup(showCat)[p].apptitle
        apptype = xCatLookup(showCat)[p].app_type -- needed for launching games from mixed categories
        filename = xCatLookup(showCat)[p].filename -- needed for adding to recent
        info = xCatLookup(showCat)[p].name -- added to fix error removing favs
    else
        app_title = "-"
    end


    if showCat == 46 and #search_results_table == 0 then
        if random_game_selected == false then
            app_title = lang_lines.Search_No_Results
        else
            app_title = ""
        end
    end

end


function GetInfoSelected()

    if next(xCatLookup(showCat)) ~= nil then
        -- if showCat == 44 then
        --     create_fav_count_table(files_table)
        -- end

        info = xCatLookup(showCat)[p].name
        app_title = xCatLookup(showCat)[p].title
        apptype = xCatLookup(showCat)[p].app_type
        appdir = xCatLookup(showCat)[p].game_path
        folder = xCatLookup(showCat)[p].directory
        filename = xCatLookup(showCat)[p].filename
        favourite_flag = xCatLookup(showCat)[p].favourite
        hide_game_flag = xCatLookup(showCat)[p].hidden
        game_path = xCatLookup(showCat)[p].game_path

        app_titleid = xCatLookup(showCat)[p].name
        app_version = xCatLookup(showCat)[p].version

        -- Get pic
        GetPicPath(xCatLookup(showCat))
        icon_path = xAppIconPathLookup(xCatLookup(showCat)[p].app_type)
    else
    end

end

function update_recently_played_table_favorite(def)
    for k, v in pairs(recently_played_table) do
        if v.filename==filename then
            v.favourite=(def)
        end
    end
end

function update_favorites_table_system(def_table_name)
    if (def_table_name)[p].favourite == true then 
        (def_table_name)[p].favourite=false
        update_recently_played_table_favorite(false)
    else
        (def_table_name)[p].favourite=true
        update_recently_played_table_favorite(true)
    end
end

function update_favorites_table_favorites(def_table_name)
    if fav_count[p].favourite == true then
        fav_count[p].favourite=false
        for k, v in pairs((def_table_name)) do
              if v.filename==filename then
                  v.favourite=false
              end
        end
        update_recently_played_table_favorite(false)
    else
        fav_count[p].favourite=true
        for k, v in pairs((def_table_name)) do
              if v.filename==filename then
                  v.favourite=true
              end
        end
        update_recently_played_table_favorite(true)
    end
end


function update_favorites_table_recent(def_table_name)
    if recently_played_table[p].favourite == true then
        recently_played_table[p].favourite=false
        for k, v in pairs((def_table_name)) do
              if v.filename==filename then
                  v.favourite=false
              end
        end
    else
        recently_played_table[p].favourite=true
        for k, v in pairs((def_table_name)) do
              if v.filename==filename then
                  v.favourite=true
              end
        end
    end
end


function update_favorites_table_files(def_table_name)
    if files_table[p].favourite == true then
        files_table[p].favourite=false
        for k, v in pairs((def_table_name)) do
              if v.filename==filename then
                  v.favourite=false
              end
        end
    else
        files_table[p].favourite=true
        for k, v in pairs((def_table_name)) do
              if v.filename==filename then
                  v.favourite=true
              end
        end
    end
end



function temp_import_hidden_cats(def_showHiddenCat, def_table_name, def_user_db_file)

    temp_import = true

    -- If homebrew or SysApps are hidden then Temporarily import for caching
    if (def_showHiddenCat) == 0 and #(def_table_name) == 0 then
        local temp_table = {}
        if System.doesFileExist("ux0:/data/RetroFlow/CACHE/" .. (def_user_db_file)) then
            import_cached_DB_tables((def_user_db_file), temp_table)
        else
        end

        if #temp_hb_collection ~= nil then
            for k, v in pairs(temp_table) do

                for key, data in pairs(temp_hb_collection) do
                    if data.name == v.name then
                    else
                        table.insert((def_table_name),k)
                    end
                end
            end
        end

    else
    end

    temp_import = false
end

function temp_import_hidden_cats_cleanup(def_showHiddenCat, def_table_name, def_user_db_file)


    -- Remove hidden games from homebrew and SysApps
    if (def_showHiddenCat) == 0 and #(def_table_name) ~= nil then
        for l, file in pairs((def_table_name)) do
            if file.hidden == true then
                table.remove((def_table_name),l)
            else
            end
        end
    end

    -- Remove homebrew if hidden
    if (def_showHiddenCat) == 0 and #(def_table_name) ~= nil then
        for l, file in pairs(files_table) do
            if file.app_type == 0 then
                table.remove(files_table,l)
            else
            end
        end
        def_table_name = {}
    end

    if (def_showHiddenCat) == 0 then
        import_cached_DB_homebrews_in_collections((def_user_db_file), (def_table_name))
    else
    end
end


function AddOrRemoveFavorite()

    if System.doesFileExist(cur_dir .. "/favorites.dat") then
        local inf = assert(io.open(cur_dir .. "/favorites.dat", "rw"), "Failed to open favorites.dat")
        local lines = ""
        local favoriteExists = false;

        while(true) do
            local line = inf:read("*line")
            if not line then break end
            if string.find(line, filename .. "", 1,true) == nil then
                lines = lines .. line .. "\n"
            else
                favoriteExists = true;
            end
        end
        if not favoriteExists then
            lines = lines .. filename .. "\n"
        end
        inf:close()
        file_override = io.open(cur_dir .. "/favorites.dat", "w")
        file_override:write(lines)
        file_override:close()


        temp_import_hidden_cats(showHomebrews, homebrews_table, "db_homebrews.lua")
        temp_import_hidden_cats(showSysApps, sysapps_table, "db_sysapps.lua")

        -- Update and cache tables

        if showCat >= 1 and showCat <= 41 then
            -- Update live favorites for game category tables and cache
            update_favorites_table_system(xCatLookup(showCat))
            update_cached_table(xCatDbFileLookup(showCat), xCatLookup(showCat))
        
        -- Favourites
        elseif showCat == 44 then
            -- Find game in other tables and update
            update_favorites_table_favorites(xAppNumTableLookup(apptype))
            update_cached_table(xAppDbFileLookup(apptype), xAppNumTableLookup(apptype))

        -- Recent
        elseif showCat == 44 then
            -- Find game in other tables and update
            update_favorites_table_recent(xAppNumTableLookup(apptype))
            update_cached_table(xAppDbFileLookup(apptype), xAppNumTableLookup(apptype))

        -- Search results
        elseif showCat == 46 then
            update_favorites_table_system(search_results_table)

            -- Find game in other tables and update
            update_favorites_table_recent(xAppNumTableLookup(apptype))
            update_cached_table(xAppDbFileLookup(apptype), xAppNumTableLookup(apptype))

        -- Collections
        elseif showCat >= 47 then
            if xCatLookup(showCat)[p].favourite == true then 
                xCatLookup(showCat)[p].favourite=false
            else
                xCatLookup(showCat)[p].favourite=true
            end

            -- Find game in other tables and update
            -- update_favorites_table_favorites(xAppNumTableLookup(apptype))
            update_cached_table(xAppDbFileLookup(apptype), xAppNumTableLookup(apptype))


        -- Update files table
        else
            -- Find game in files tables and update
            update_favorites_table_files(xAppNumTableLookup(apptype))
            update_cached_table(xAppDbFileLookup(apptype), xAppNumTableLookup(apptype))  

        end
        -- update_cached_table("db_files.lua", files_table)
        update_cached_table_recently_played()


        temp_import_hidden_cats_cleanup(showHomebrews, homebrews_table, "db_homebrews.lua")
        temp_import_hidden_cats_cleanup(showSysApps, sysapps_table, "db_sysapps.lua")

        --Reload
        -- FreeIcons()
        -- FreeMemory()
        -- Network.term()

    end

end


function AddOrRemoveHidden(def_hide_game_flag)

    temp_import_hidden_cats(showHomebrews, homebrews_table, "db_homebrews.lua")
    temp_import_hidden_cats(showSysApps, sysapps_table, "db_sysapps.lua")

    -- Recent cat
    if showCat == 45 then

        -- Update recent table
        if #recently_played_table ~= nil then
            recently_played_table[p].hidden=(def_hide_game_flag)
        end
        update_cached_table_recently_played()

        -- Update app type table
        local key = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
        if key ~= nil then
            xAppNumTableLookup(apptype)[key].hidden=(def_hide_game_flag)
            update_cached_table(xAppDbFileLookup(apptype), xAppNumTableLookup(apptype))
        else
        end

    -- Other cats
    else
        -- Update app type table

        -- xAppNumTableLookup(apptype)[p].hidden=(def_hide_game_flag)
        local key = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
        if key ~= nil then
            xAppNumTableLookup(apptype)[key].hidden=(def_hide_game_flag)
        end

        update_cached_table(xAppDbFileLookup(apptype), xAppNumTableLookup(apptype))

        -- Update recent table
        if #recently_played_table ~= nil then
            local key = find_game_table_pos_key(recently_played_table, app_titleid)
            if key ~= nil then
                recently_played_table[key].hidden=(def_hide_game_flag)
                update_cached_table_recently_played()
            else
            end
        else
        end
        
    end

    temp_import_hidden_cats_cleanup(showHomebrews, homebrews_table, "db_homebrews.lua")
    temp_import_hidden_cats_cleanup(showSysApps, sysapps_table, "db_sysapps.lua")

end


function AddtoRecentlyPlayed()

    -- Get system date and time
    day_num, dd, mm, yyyy = System.getDate()
    h,m,s = System.getTime()

    -- Format numbers to double digits
    if string.len(mm) == 1 then mm = "0" .. mm end
    if string.len(dd) == 1 then dd = "0" .. dd end
    if string.len(h) == 1 then h = "0" .. h end
    if string.len(m) == 1 then m = "0" .. m end
    if string.len(s) == 1 then s = "0" .. s end

    -- Create timestamp string
    timestamp = tonumber(yyyy .. mm .. dd .. h .. m .. s)
    
    recently_played_new = {}
    already_played = false

    -- If game in Recently played list - Update timestamp
    for k, v in pairs(recently_played_table) do
        if v.filename==filename then
            already_played = true
            v.date_played=timestamp
        end
    end

    if already_played == false then
        -- Lookup apptype and find relevent table, update timestamp and insert to recent
        for k, v in pairs(xAppNumTableLookup(apptype)) do 
            if v.filename==filename and already_played == false then
                v.date_played=timestamp
                table.insert(recently_played_new, v)
            else
            end
        end
    end

    -- Copy the recently played table to a new table
    for k, v in pairs(recently_played_table) do
        table.insert(recently_played_new, v)
    end


    -- Sort new table by date
    table.sort(recently_played_new, function(a, b) return (tonumber(a.date_played) > tonumber(b.date_played)) end)

    -- Select 20 most recent from new table and add to a newer table ready for saving
    recently_played_pre_launch_table = {}
    for k, v in pairs(recently_played_new) do
        if k < 21 then -- Limit to 20 games
            table.insert(recently_played_pre_launch_table, v)
        end
    end

end


function QuickOverride_Remove_from_current_table()
    if #xAppNumTableLookup(apptype) ~= nil then
        local key = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
        if key ~= nil then
            table.remove(xAppNumTableLookup(apptype), key)
            update_cached_table(xAppDbFileLookup(apptype), xAppNumTableLookup(apptype))
        else
        end
    end
end

function QuickOverride_Vita()
    xAppNumTableLookup(apptype)[key].app_type = 1
    xAppNumTableLookup(apptype)[key].cover_path_online = SystemsToScan[1].onlineCoverPathSystem
    xAppNumTableLookup(apptype)[key].cover_path_local = SystemsToScan[1].localCoverPath
    xAppNumTableLookup(apptype)[key].snap_path_online = SystemsToScan[1].onlineSnapPathSystem
    xAppNumTableLookup(apptype)[key].snap_path_local = SystemsToScan[1].localSnapPath
    -- Cover
    if System.doesFileExist(SystemsToScan[1].localCoverPath .. xAppNumTableLookup(apptype)[key].apptitle .. ".png") then
        xAppNumTableLookup(apptype)[key].icon_path = SystemsToScan[1].localCoverPath .. xAppNumTableLookup(apptype)[key].apptitle .. ".png" --custom cover by app name
        xAppNumTableLookup(apptype)[key].cover = true
    elseif System.doesFileExist(SystemsToScan[1].localCoverPath .. xAppNumTableLookup(apptype)[key].name .. ".png") then
        xAppNumTableLookup(apptype)[key].icon_path = SystemsToScan[1].localCoverPath .. xAppNumTableLookup(apptype)[key].name .. ".png" --custom cover by app id
        xAppNumTableLookup(apptype)[key].cover = true
    elseif System.doesFileExist("ur0:/appmeta/" .. xAppNumTableLookup(apptype)[key].name .. "/icon0.png") then
        xAppNumTableLookup(apptype)[key].icon_path = "ur0:/appmeta/" .. xAppNumTableLookup(apptype)[key].name .. "/icon0.png"  --app icon
        xAppNumTableLookup(apptype)[key].cover = true
    elseif System.doesFileExist("app0:/DATA/missing_cover_psv.png") then
        xAppNumTableLookup(apptype)[key].icon_path = "app0:/DATA/missing_cover_psv.png"
        xAppNumTableLookup(apptype)[key].cover = false
    else
        xAppNumTableLookup(apptype)[key].icon_path = "app0:/DATA/noimg.png" --blank grey
        xAppNumTableLookup(apptype)[key].cover = false
    end
end

function QuickOverride_PSP()
    xAppNumTableLookup(apptype)[key].app_type = 2
    xAppNumTableLookup(apptype)[key].cover_path_online = SystemsToScan[3].onlineCoverPathSystem
    xAppNumTableLookup(apptype)[key].cover_path_local = SystemsToScan[3].localCoverPath
    xAppNumTableLookup(apptype)[key].snap_path_online = SystemsToScan[3].onlineSnapPathSystem
    xAppNumTableLookup(apptype)[key].snap_path_local = SystemsToScan[3].localSnapPath
    -- Cover
    if System.doesFileExist(SystemsToScan[3].localCoverPath .. xAppNumTableLookup(apptype)[key].apptitle .. ".png") then
        xAppNumTableLookup(apptype)[key].icon_path = SystemsToScan[3].localCoverPath .. xAppNumTableLookup(apptype)[key].apptitle .. ".png" --custom cover by app name
        xAppNumTableLookup(apptype)[key].cover = true
    elseif System.doesFileExist(SystemsToScan[3].localCoverPath .. xAppNumTableLookup(apptype)[key].name .. ".png") then
        xAppNumTableLookup(apptype)[key].icon_path = SystemsToScan[3].localCoverPath .. xAppNumTableLookup(apptype)[key].name .. ".png" --custom cover by app id
        xAppNumTableLookup(apptype)[key].cover = true
    elseif System.doesFileExist("app0:/DATA/missing_cover_psp.png") then
        xAppNumTableLookup(apptype)[key].icon_path = "app0:/DATA/missing_cover_psp.png"  --app icon
        xAppNumTableLookup(apptype)[key].cover = false
    else
        xAppNumTableLookup(apptype)[key].icon_path = "app0:/DATA/noimg.png" --blank grey
        xAppNumTableLookup(apptype)[key].cover = false
    end
end

function QuickOverride_PSX()
    xAppNumTableLookup(apptype)[key].app_type = 3
    xAppNumTableLookup(apptype)[key].cover_path_online = SystemsToScan[4].onlineCoverPathSystem
    xAppNumTableLookup(apptype)[key].cover_path_local = SystemsToScan[4].localCoverPath
    xAppNumTableLookup(apptype)[key].snap_path_online = SystemsToScan[4].onlineSnapPathSystem
    xAppNumTableLookup(apptype)[key].snap_path_local = SystemsToScan[4].localSnapPath
    -- Cover
    if System.doesFileExist(SystemsToScan[4].localCoverPath .. xAppNumTableLookup(apptype)[key].apptitle .. ".png") then
        xAppNumTableLookup(apptype)[key].icon_path = SystemsToScan[4].localCoverPath .. xAppNumTableLookup(apptype)[key].apptitle .. ".png" --custom cover by app name
        xAppNumTableLookup(apptype)[key].cover = true
    elseif System.doesFileExist(SystemsToScan[4].localCoverPath .. xAppNumTableLookup(apptype)[key].name .. ".png") then
        xAppNumTableLookup(apptype)[key].icon_path = SystemsToScan[4].localCoverPath .. xAppNumTableLookup(apptype)[key].name .. ".png" --custom cover by app id
        xAppNumTableLookup(apptype)[key].cover = true
    elseif System.doesFileExist("app0:/DATA/missing_cover_psx.png") then
        xAppNumTableLookup(apptype)[key].icon_path = "app0:/DATA/missing_cover_psx.png"  --app icon
        xAppNumTableLookup(apptype)[key].cover = false
    else
        xAppNumTableLookup(apptype)[key].icon_path = "app0:/DATA/noimg.png" --blank grey
        xAppNumTableLookup(apptype)[key].cover = false
    end
end

function QuickOverride_Homebrew()
    xAppNumTableLookup(apptype)[key].app_type = 0
    xAppNumTableLookup(apptype)[key].cover_path_online = SystemsToScan[2].onlineCoverPathSystem
    xAppNumTableLookup(apptype)[key].cover_path_local = SystemsToScan[2].localCoverPath
    xAppNumTableLookup(apptype)[key].snap_path_online = SystemsToScan[2].onlineSnapPathSystem
    xAppNumTableLookup(apptype)[key].snap_path_local = SystemsToScan[2].localSnapPath
    -- Cover
    if System.doesFileExist(SystemsToScan[2].localCoverPath .. xAppNumTableLookup(apptype)[key].apptitle .. ".png") then
        xAppNumTableLookup(apptype)[key].icon_path = SystemsToScan[2].localCoverPath .. xAppNumTableLookup(apptype)[key].apptitle .. ".png" --custom cover by app name
        xAppNumTableLookup(apptype)[key].cover = true
    elseif System.doesFileExist(SystemsToScan[2].localCoverPath .. xAppNumTableLookup(apptype)[key].name .. ".png") then
        xAppNumTableLookup(apptype)[key].icon_path = SystemsToScan[2].localCoverPath .. xAppNumTableLookup(apptype)[key].name .. ".png" --custom cover by app id
        xAppNumTableLookup(apptype)[key].cover = true
    elseif System.doesFileExist("ur0:/appmeta/" .. xAppNumTableLookup(apptype)[key].name .. "/icon0.png") then
        xAppNumTableLookup(apptype)[key].icon_path = "ur0:/appmeta/" .. xAppNumTableLookup(apptype)[key].name .. "/icon0.png"  --app icon
        xAppNumTableLookup(apptype)[key].cover = true
    elseif System.doesFileExist("app0:/DATA/icon_homebrew.png") then
        xAppNumTableLookup(apptype)[key].icon_path = "app0:/DATA/icon_homebrew.png"
        xAppNumTableLookup(apptype)[key].cover = false
    else
        xAppNumTableLookup(apptype)[key].icon_path = "app0:/DATA/noimg.png" --blank grey
        xAppNumTableLookup(apptype)[key].cover = false
    end
end

function QuickOverride_Category(tmpappcat)

    -- Remove current game from table

        if (tmpappcat)==1 then
            -- vita
            if #xAppNumTableLookup(apptype) ~= nil then
                key = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
                if key ~= nil then
                    QuickOverride_Vita()

                    if #recently_played_table ~= nil then
                        key_recent = find_game_table_pos_key(recently_played_table, app_titleid)
                        if key_recent ~= nil then
                            table.remove(recently_played_table,key_recent)
                            table.insert(recently_played_table, xAppNumTableLookup(apptype)[key])
                            update_cached_table_recently_played()
                            recently_played_table = {}
                            import_recently_played()
                        else
                        end
                    end

                    table.insert(games_table, xAppNumTableLookup(apptype)[key])
                    table.sort(games_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
                    update_cached_table("db_games.lua", games_table)
                else
                end
            end

        elseif (tmpappcat)==2 then
            -- psp
            if #xAppNumTableLookup(apptype) ~= nil then
                key = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
                if key ~= nil then
                    QuickOverride_PSP()

                    if #recently_played_table ~= nil then
                        key_recent = find_game_table_pos_key(recently_played_table, app_titleid)
                        if key_recent ~= nil then
                            table.remove(recently_played_table,key_recent)
                            table.insert(recently_played_table, xAppNumTableLookup(apptype)[key])
                            update_cached_table_recently_played()
                            recently_played_table = {}
                            import_recently_played()
                        else
                        end
                    end

                    table.insert(psp_table, xAppNumTableLookup(apptype)[key])
                    table.sort(psp_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
                    update_cached_table("db_psp.lua", psp_table)
                else
                end
            end
            
        elseif (tmpappcat)==3 then
            -- psx
            if #xAppNumTableLookup(apptype) ~= nil then
                key = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
                if key ~= nil then
                    QuickOverride_PSX()

                    if #recently_played_table ~= nil then
                        key_recent = find_game_table_pos_key(recently_played_table, app_titleid)
                        if key_recent ~= nil then
                            table.remove(recently_played_table,key_recent)
                            table.insert(recently_played_table, xAppNumTableLookup(apptype)[key])
                            update_cached_table_recently_played()
                            recently_played_table = {}
                            import_recently_played()
                        else
                        end
                    end

                    table.insert(psx_table, xAppNumTableLookup(apptype)[key])
                    table.sort(psx_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
                    update_cached_table("db_psx.lua", psx_table)
                else
                end
            end
            
        elseif (tmpappcat)==4 then
            -- homebrew
            
            -- If homebrew is hidden then Temporarily import for caching
            if showHomebrews == 0 and #homebrews_table == 0 then
                if System.doesFileExist("ux0:/data/RetroFlow/CACHE/db_homebrews.lua") then
                    import_cached_DB_tables("db_homebrews.lua", homebrews_table)
                else
                end
            else
            end

            if #xAppNumTableLookup(apptype) ~= nil then
                key = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
                if key ~= nil then
                    QuickOverride_Homebrew()

                    if #recently_played_table ~= nil then
                        key_recent = find_game_table_pos_key(recently_played_table, app_titleid)
                        if key_recent ~= nil then
                            table.remove(recently_played_table,key_recent)
                            table.insert(recently_played_table, xAppNumTableLookup(apptype)[key])
                            update_cached_table_recently_played()
                            recently_played_table = {}
                            import_recently_played()
                        else
                        end
                    end

                    table.insert(homebrews_table, xAppNumTableLookup(apptype)[key])
                    table.sort(homebrews_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
                    update_cached_table("db_homebrews.lua", homebrews_table)
                else
                end
            end

            -- Remove homebrew if hidden
            if showHomebrews == 0 and #homebrews_table ~= nil then
                for l, file in pairs(files_table) do
                    if file.app_type == 0 then
                        table.remove(files_table,l)
                    else
                    end
                end
                homebrews_table = {}
            end

            -- Remove hidden games from homebrew
            if showHidden == 0 and #homebrews_table ~= nil then
                for l, file in pairs(homebrews_table) do
                    if file.hidden == true then
                        table.remove(homebrews_table,l)
                    else
                    end
                end
            end
            
        else

        end

        QuickOverride_Remove_from_current_table()

    -- If the last game is overriden, move to 1st to prevent nil error
    if p == curTotal then
        p = 1
        master_index = p
    end

    -- force icon change. Credit BlackSheepBoy69
    -- xCatLookup(showCat)[p].ricon = Graphics.loadImage(xCatLookup(showCat)[p].icon_path)

    -- Error fix for when Homebrew is off, overriding game to homebrew, and on all category - then reload files
    if showHomebrews == 0 and (tmpappcat)==4 and showCat == 0 then
        files_table = import_cached_DB()
        GetInfoSelected()
    end

    GetInfoSelected()
    oldpad = pad -- Prevents it from launching next game accidentally. Credit BlackSheepBoy69
    showMenu = 0

    Render.useTexture(modBackground, imgCustomBack)

    -- Instant cover update - Credit BlackSheepBoy69
    Threads.addTask(xCatLookup(showCat)[p], {
    Type = "ImageLoad",
    Path = xCatLookup(showCat)[p].icon_path,
    Table = xCatLookup(showCat)[p],
    Index = "ricon"
    })

end

function check_for_out_of_bounds()
    curTotal = #xCatLookup(showCat)
    if curTotal == 0 then
        p = 0 
        master_index = p
    end
    if p < 1 then
        p = curTotal
        if p >= 1 then
            master_index = p -- 0
        end
        startCovers = false
        GetInfoSelected()
    elseif p > curTotal then
        p = 1
        master_index = p
        startCovers = false
        GetInfoSelected()
    end
end

function OverrideCategory()
    if System.doesFileExist(cur_dir .. "/overrides.dat") then
        local inf = assert(io.open(cur_dir .. "/overrides.dat", "rw"), "Failed to open overrides.dat")
        local lines = ""
        while(true) do
            local line = inf:read("*line")
            if not line then break end
            
            if not string.find(line, app_titleid .. "", 1) then
                lines = lines .. line .. "\n"
            end
        end
        if tmpappcat>0 then
            lines = lines .. app_titleid .. "=" .. tmpappcat .. "\n"
        end
        inf:close()
        file_override = io.open(cur_dir .. "/overrides.dat", "w")
        file_override:write(lines)
        file_override:close()
        
        if tmpappcat == 0 then
            -- Get default apptype from table
            key = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
            if key ~= nil then
                tmpappcat = xAppNumTableLookup(apptype)[key].app_type_default
                -- If default apptype = 0 (homebrew) set to 4 
                if tmpappcat == 0 then
                    tmpappcat = 4
                end
            else
            end
        end

        QuickOverride_Category(tmpappcat)

    end
end

function DownloadCovers()
    local txt = lang_lines.Downloading_covers .. "..."
    --          Downloading covers
    local old_txt = txt
    local percent = 0
    local old_percent = 0
    local cvrfound = 0
    
    local app_idx = 1
    local running = false
    status = System.getMessageState()
    
    if Network.isWifiEnabled() then

        -- getCovers - 0 All, 1 PSV, 2 PSP, 3 PS1, 4 N64, 5 SNES, 6 NES, 7 GBA, 8 GBC, 9 GB, 10 MD, 11 SMS, 12 GG, 13 MAME, 14 AMIGA, 15 TG16, 16 TGCD, 17 PCE, 18 PCECD, 19 NGPC

        function DownloadCovers_System(def_getCovers, def_table_name, def_lang_lines_Downloading_SysName_covers)
                    
            -- if getCovers == 0 then -- sort all games by system
            --     table.sort(return_table, function(a, b) return (a.app_type < b.app_type) end)
            -- end

            if getCovers==(def_getCovers) and #(def_table_name) > 0 then -- Check getcover number against system
                
                if status ~= RUNNING then
                    if scanComplete == false then
                        System.setMessage("Downloading covers...", true)
                        System.setMessageProgMsg(txt)
                        
                        while app_idx <= #(def_table_name) do

                            if System.getAsyncState() ~= 0 then
                                -- Only downloading missing covers

                                -- Check if cover already exists
                                if System.doesFileExist((def_table_name)[app_idx].cover_path_local .. (def_table_name)[app_idx].name:gsub("%%","%%%%") .. ".png") or System.doesFileExist((def_table_name)[app_idx].cover_path_local .. (def_table_name)[app_idx].apptitle .. ".png") then
                                    -- Found - do nothing
                                else
                                    -- Not found - download

                                    if (def_table_name)[app_idx].app_type == 21 then
                                        -- Amiga fix
                                        Network.downloadFileAsync((def_table_name)[app_idx].cover_path_online .. urlencode((def_table_name)[app_idx].name_title_search) .. ".png", "ux0:/data/RetroFlow/" .. (def_table_name)[app_idx].name:gsub("%%","%%%%") .. ".png")
                                    else
                                        Network.downloadFileAsync((def_table_name)[app_idx].cover_path_online .. (def_table_name)[app_idx].name_online .. ".png", "ux0:/data/RetroFlow/" .. (def_table_name)[app_idx].name:gsub("%%","%%%%") .. ".png")
                                    end
                                    running = true
                                end
                            end
                            if System.getAsyncState() == 1 then
                                Graphics.initBlend()
                                Graphics.termBlend()
                                Screen.flip()
                                running = false
                            end
                            if running == false then

                                -- Check if cover already exists
                                if System.doesFileExist((def_table_name)[app_idx].cover_path_local .. (def_table_name)[app_idx].name .. ".png") or System.doesFileExist((def_table_name)[app_idx].cover_path_local .. (def_table_name)[app_idx].apptitle .. ".png") then
                                    -- Found - move on
                                    cvrfound = cvrfound + 1
                                    percent = (app_idx / #(def_table_name)) * 100
                                    clean_name = (def_table_name)[app_idx].name:gsub("\n","")

                                    if setLanguage == 9 or setLanguage == 10 or setLanguage == 17 or setLanguage == 18 or setLanguage == 19 then
                                        -- Reverse order of numbering xxx/x : Japanese, Chinese (Traditional), Korean, Chinese (Simplified), Japanese (Ryukyuan)
                                        txt = (def_lang_lines_Downloading_SysName_covers) .. "...\n" .. lang_lines.Cover .. " " .. clean_name .. "\n" .. lang_lines.Found .. " " .. #(def_table_name) .. lang_lines.of .. cvrfound
                                    else
                                        -- Normal x/xxx
                                        txt = (def_lang_lines_Downloading_SysName_covers) .. "...\n" .. lang_lines.Cover .. " " .. clean_name .. "\n" .. lang_lines.Found .. " " .. cvrfound .. lang_lines.of .. #(def_table_name)
                                    end

                                    Graphics.initBlend()
                                    Graphics.termBlend()
                                    Screen.flip()
                                    app_idx = app_idx + 1

                                else
                                    -- Cover doesn't already exist- If it has been downloaded, check size and move to directory, then move on
                                    if System.doesFileExist("ux0:/data/RetroFlow/" .. (def_table_name)[app_idx].name .. ".png") then
                                        tmpfile = System.openFile("ux0:/data/RetroFlow/" .. (def_table_name)[app_idx].name .. ".png", FREAD)
                                        size = System.sizeFile(tmpfile)
                                        if size < 1024 then
                                            System.deleteFile("ux0:/data/RetroFlow/" .. (def_table_name)[app_idx].name .. ".png")

                                        else
                                            System.rename("ux0:/data/RetroFlow/" .. (def_table_name)[app_idx].name .. ".png", (def_table_name)[app_idx].cover_path_local .. (def_table_name)[app_idx].name .. ".png")
                                            cvrfound = cvrfound + 1

                                            -- Update table
                                            (def_table_name)[app_idx].icon_path = (def_table_name)[app_idx].cover_path_local .. (def_table_name)[app_idx].name .. ".png"

                                            -- Is the game in the recently played list?
                                            if #recently_played_table ~= nil then
                                                local key = find_game_table_pos_key(recently_played_table, (def_table_name)[app_idx].name)
                                                if key ~= nil then
                                                    -- Yes - Found in files table
                                                    recently_played_table[key].icon_path = (def_table_name)[app_idx].cover_path_local .. (def_table_name)[app_idx].name .. ".png"
                                                else
                                                    -- No
                                                end
                                            else
                                            end
                                            
                                        end
                                        System.closeFile(tmpfile)
                                        
                                        percent = (app_idx / #(def_table_name)) * 100
                                        clean_name = (def_table_name)[app_idx].name:gsub("\n","")


                                        if setLanguage == 9 or setLanguage == 10 or setLanguage == 17 or setLanguage == 18 or setLanguage == 19 then
                                            -- Reverse order of numbering xxx/x : Japanese, Chinese (Traditional), Korean, Chinese (Simplified), Japanese (Ryukyuan)
                                            txt = (def_lang_lines_Downloading_SysName_covers) .. "...\n" .. lang_lines.Cover .. " " .. clean_name .. "\n" .. lang_lines.Found .. " " .. #(def_table_name) .. lang_lines.of .. cvrfound
                                        else
                                            -- Normal x/xxx
                                            txt = (def_lang_lines_Downloading_SysName_covers) .. "...\n" .. lang_lines.Cover .. " " .. clean_name .. "\n" .. lang_lines.Found .. " " .. cvrfound .. lang_lines.of .. #(def_table_name)
                                        end

                                        Graphics.initBlend()
                                        Graphics.termBlend()
                                        Screen.flip()
                                        app_idx = app_idx + 1
                                    end
                                
                                end

                            end
                            
                            if txt ~= old_txt then
                                System.setMessageProgMsg(txt)
                                old_txt = txt
                            end
                            if percent ~= old_percent then
                                System.setMessageProgress(percent)
                                old_percent = percent
                            end
                        end
                        if app_idx >= #(def_table_name) then
                            System.closeMessage()
                            -- scanComplete = true

                            cache_all_tables()
                            update_cached_table_recently_played()
                            
                            -- Redraw covers for current showcat game category 
                            for k in pairs (xCatLookup(showCat)) do
                                Threads.addTask(xCatLookup(showCat)[k], {
                                Type = "ImageLoad",
                                Path = xCatLookup(showCat)[k].icon_path,
                                Table = xCatLookup(showCat)[k],
                                Index = "ricon"
                                })
                            end
                        end
                    else
                    end
                end

            else
                System.setMessage(lang_lines.No_missing_artwork, false, BUTTON_OK)
            end

            if getCovers == 0 then -- sort all games by app title
                table.sort(return_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
            end
        end

        -- If not showing missing covers - temporarily re-enable and import cache so can download - then disable again
        if showMissingCovers == 0 then
            showMissingCovers = 1
            -- Import cache to update
            FreeIcons()
            count_cache_and_reload()
            check_for_out_of_bounds()
            GetNameAndAppTypeSelected()
            showMissingCovers = 0
        end

        DownloadCovers_System(0, missing_artwork_table_covers, lang_lines.Downloading_covers)
        

    else
        if status ~= RUNNING then
            System.setMessage(lang_lines.Internet_Connection_Required, false, BUTTON_OK)
        end
    end

    gettingCovers = false
end


function DownloadSnaps()
    local txt = lang_lines.Downloading_backgrounds .. "..."
    --          Downloading covers
    local old_txt = txt
    local percent = 0
    local old_percent = 0
    local bgfound = 0
    
    local app_idx = 1
    local running = false
    status = System.getMessageState()
    
    if Network.isWifiEnabled() then

        -- getSnaps - 0 All, 1 PSV, 2 PSP, 3 PS1, 4 N64, 5 SNES, 6 NES, 7 GBA, 8 GBC, 9 GB, 10 MD, 11 SMS, 12 GG, 13 MAME, 14 AMIGA, 15 TG16, 16 TGCD, 17 PCE, 18 PCECD, 19 NGPC
        
        function DownloadSnaps_System(def_getSnaps, def_table_name, def_lang_lines_Downloading_SysName_backgrounds)
            if  getSnaps==(def_getSnaps) and #(def_table_name) > 0 then -- Check getcover number against system
                
                if status ~= RUNNING then
                    if bgscanComplete == false then
                        System.setMessage("Downloading backgrounds...", true)
                        System.setMessageProgMsg(txt)
                        
                        while app_idx <= #(def_table_name) do

                            if System.getAsyncState() ~= 0 then
                                -- Only downloading missing backgrounds

                                -- Check if background already exists
                                if System.doesFileExist((def_table_name)[app_idx].snap_path_local .. (def_table_name)[app_idx].name:gsub("%%","%%%%") .. ".png") or System.doesFileExist((def_table_name)[app_idx].snap_path_local .. (def_table_name)[app_idx].apptitle .. ".png") then
                                    -- Found - do nothing
                                else
                                    -- Not found - download

                                    if (def_table_name)[app_idx].snap_path_online:find("libretro") then

                                        name_after_libretro_gsub = {}

                                        -- Libretro - Replace these characters &*/:`<>?\|" with an underscore _ to match libretro naming convention
                                        if (def_table_name)[app_idx].app_type == 21 then
                                            -- Amiga fix
                                            name_after_libretro_gsub = (def_table_name)[app_idx].name_title_search:gsub("[&*/:`<>?\\|\"]+", "_")                                            
                                        else
                                            name_after_libretro_gsub = (def_table_name)[app_idx].name:gsub("[&*/:`<>?\\|\"]+", "_")
                                        end

                                        Network.downloadFileAsync((def_table_name)[app_idx].snap_path_online .. urlencode(name_after_libretro_gsub) .. ".png", "ux0:/data/RetroFlow/" .. (def_table_name)[app_idx].name:gsub("%%","%%%%") .. ".png")

                                    else

                                        -- Not libretro
                                        if (def_table_name)[app_idx].app_type == 21 then
                                            -- Amiga fix
                                            Network.downloadFileAsync((def_table_name)[app_idx].snap_path_online .. urlencode((def_table_name)[app_idx].name_title_search) .. ".png", "ux0:/data/RetroFlow/" .. (def_table_name)[app_idx].name:gsub("%%","%%%%") .. ".png")
                                        else
                                            Network.downloadFileAsync((def_table_name)[app_idx].snap_path_online .. (def_table_name)[app_idx].name_online .. ".png", "ux0:/data/RetroFlow/" .. (def_table_name)[app_idx].name:gsub("%%","%%%%") .. ".png")
                                        end
                                    end

                                    
                                    
                                    running = true
                                end

                            end
                            if System.getAsyncState() == 1 then
                                Graphics.initBlend()
                                Graphics.termBlend()
                                Screen.flip()
                                running = false
                            end
                            if running == false then

                                -- Check if background already exists
                                if System.doesFileExist((def_table_name)[app_idx].snap_path_local .. (def_table_name)[app_idx].name .. ".png") or System.doesFileExist((def_table_name)[app_idx].snap_path_local .. (def_table_name)[app_idx].apptitle .. ".png") then
                                    -- Found - move on
                                    bgfound = bgfound + 1
                                    percent = (app_idx / #(def_table_name)) * 100
                                    clean_name = (def_table_name)[app_idx].name:gsub("\n","")

                                    if setLanguage == 9 or setLanguage == 10 or setLanguage == 17 or setLanguage == 18 or setLanguage == 19 then
                                        -- Reverse order of numbering xxx/x : Japanese, Chinese (Traditional), Korean, Chinese (Simplified), Japanese (Ryukyuan)
                                        txt = (def_lang_lines_Downloading_SysName_backgrounds) .. "...\n" .. lang_lines.Background .. " " .. clean_name .. "\n" .. lang_lines.Found .. " " .. #(def_table_name) .. lang_lines.of .. bgfound
                                    else
                                        -- Normal x/xxx
                                        txt = (def_lang_lines_Downloading_SysName_backgrounds) .. "...\n" .. lang_lines.Background .. " " .. clean_name .. "\n" .. lang_lines.Found .. " " .. bgfound .. lang_lines.of .. #(def_table_name)
                                    end

                                    Graphics.initBlend()
                                    Graphics.termBlend()
                                    Screen.flip()
                                    app_idx = app_idx + 1

                                else 
                                    -- Background doesn't already exist- If it has been downloaded, check size and move to directory, then move on
                                    if System.doesFileExist("ux0:/data/RetroFlow/" .. (def_table_name)[app_idx].name .. ".png") then
                                        tmpfile = System.openFile("ux0:/data/RetroFlow/" .. (def_table_name)[app_idx].name .. ".png", FREAD)
                                        size = System.sizeFile(tmpfile)
                                        if size < 1024 then
                                            System.deleteFile("ux0:/data/RetroFlow/" .. (def_table_name)[app_idx].name .. ".png")
                                        else
                                            System.rename("ux0:/data/RetroFlow/" .. (def_table_name)[app_idx].name .. ".png", (def_table_name)[app_idx].snap_path_local .. (def_table_name)[app_idx].name .. ".png")
                                            bgfound = bgfound + 1
                                            
                                        end
                                        System.closeFile(tmpfile)
                                        
                                        percent = (app_idx / #(def_table_name)) * 100
                                        clean_name = (def_table_name)[app_idx].name:gsub("\n","")

                                        if setLanguage == 9 or setLanguage == 10 or setLanguage == 17 or setLanguage == 18 or setLanguage == 19 then
                                            -- Reverse order of numbering xxx/x : Japanese, Chinese (Traditional), Korean, Chinese (Simplified), Japanese (Ryukyuan)
                                            txt = (def_lang_lines_Downloading_SysName_backgrounds) .. "...\n" .. lang_lines.Background .. " " .. clean_name .. "\n" .. lang_lines.Found .. " " .. #(def_table_name) .. lang_lines.of .. bgfound
                                        else
                                            -- Normal x/xxx
                                            txt = (def_lang_lines_Downloading_SysName_backgrounds) .. "...\n" .. lang_lines.Background .. " " .. clean_name .. "\n" .. lang_lines.Found .. " " .. bgfound .. lang_lines.of .. #(def_table_name)
                                        end

                                        Graphics.initBlend()
                                        Graphics.termBlend()
                                        Screen.flip()
                                        app_idx = app_idx + 1
                                    end
                                end
                                
                            end
                            
                            if txt ~= old_txt then
                                System.setMessageProgMsg(txt)
                                old_txt = txt
                            end
                            if percent ~= old_percent then
                                System.setMessageProgress(percent)
                                old_percent = percent
                            end
                        end
                        if app_idx >= #(def_table_name) then
                            System.closeMessage()
                            -- bgscanComplete = true
                        end
                    else
                    end
                end
            
            else
                System.setMessage(lang_lines.No_missing_artwork, false, BUTTON_OK)
            end
        end

        DownloadSnaps_System(0, missing_artwork_table_backgrounds, lang_lines.Downloading_backgrounds)
        
    else
        if status ~= RUNNING then
            System.setMessage(lang_lines.Internet_Connection_Required, false, BUTTON_OK)
        end
        
    end

    gettingBackgrounds = false
end


function get_cover_scale(icon)

    cover_height = Graphics.getImageHeight(icon)
    cover_width = Graphics.getImageWidth(icon)

    fv_cover_scale = fv_cover_height / cover_height
    fv_cover_scale_px = cover_width * fv_cover_scale

    -- return fv_cover_scale_px
end

cover_widths_x_bonus = 0

local function DrawCover_Flat(x, y, text, color, icon, sel)

    if sel == p then
        Graphics.fillRect(x - fv_border, x + fv_cover_scale_px + fv_border, fv_cover_y - fv_border, fv_cover_y + fv_cover_height + fv_border, white)
    end

    Graphics.setImageFilters(icon, FILTER_LINEAR, FILTER_LINEAR)

    Graphics.drawScaleImage(x, fv_cover_y, icon, fv_cover_scale, fv_cover_height / cover_height)

    -- Add dark overlay to cover left of current
    if sel == master_index -1 then
        Graphics.fillRect(x, x + fv_cover_scale_px, fv_cover_y, fv_cover_y + fv_cover_height, Color.new(0,0,0,75))
    else
    end    
    
end


local function DrawCover_Flat_Smooth(x, y, text, color, icon, sel)
    x = x * (fv_cover_height + fv_gutter) + cover_widths_x_bonus + fv_left_margin

    if sel >= p then
       cover_widths_x_bonus = cover_widths_x_bonus + fv_cover_scale_px - fv_cover_height

    elseif sel == p-1 then
        -- Add dark overlay to cover left of current
        x = x + fv_cover_height - fv_cover_scale_px
        Graphics.fillRect(x, x + fv_cover_scale_px, fv_cover_y, fv_cover_y + fv_cover_height, Color.new(0,0,0,75))
    end

    if sel == p then
        Graphics.fillRect(x - fv_border, x + fv_cover_scale_px + fv_border, fv_cover_y - fv_border, fv_cover_y + fv_cover_height + fv_border, white)
    end

    Graphics.setImageFilters(icon, FILTER_LINEAR, FILTER_LINEAR)

    Graphics.drawScaleImage(x, fv_cover_y, icon, fv_cover_scale, fv_cover_height / cover_height)

    -- Add dark overlay to cover left of current
    if sel == master_index -1 then
        Graphics.fillRect(x, x + fv_cover_scale_px, fv_cover_y, fv_cover_y + fv_cover_height, Color.new(0,0,0,75))
    end    
    
end


local function DrawCover_List(icon)

    local portrait = false
    local landscape = false
    local square = false

    lv_cover_target_size = 300
    lv_cover_x_pos = 614
    lv_cover_y_pos = 146

    cover_height = Graphics.getImageHeight(icon)
    cover_width = Graphics.getImageWidth(icon)

    if cover_height == cover_width then
        square = true
            lv_cover_scale = lv_cover_target_size / cover_height
            lv_cover_scale_px = lv_cover_scale * cover_width
    elseif cover_height > cover_width then
        portrait = true
            lv_cover_scale = lv_cover_target_size / cover_height
            lv_cover_scale_px = lv_cover_scale * cover_width
    else
        landscape = true
            lv_cover_scale = lv_cover_target_size / cover_width
            lv_cover_scale_px = lv_cover_scale * cover_height
    end


    Graphics.setImageFilters(icon, FILTER_LINEAR, FILTER_LINEAR)

    if square == true then
        Graphics.drawScaleImage(lv_cover_x_pos, lv_cover_y_pos, icon, lv_cover_scale, lv_cover_scale)
    end

    if portrait == true then
        Graphics.drawScaleImage(lv_cover_x_pos + ((lv_cover_target_size - lv_cover_scale_px) / 2), lv_cover_y_pos, icon, lv_cover_scale, lv_cover_scale)
    end

    if landscape == true then
        Graphics.drawScaleImage(lv_cover_x_pos, lv_cover_y_pos + ((lv_cover_target_size - lv_cover_scale_px) / 2), icon, lv_cover_scale, lv_cover_scale)
    end

    

end


local function DrawCover(x, y, text, icon, sel, apptype, cur_p)
    rot = 0
    extraz = 0
    extrax = 0
    extray = 0
    zoom = 0
    camX = 0
    Graphics.setImageFilters(icon, FILTER_LINEAR, FILTER_LINEAR)
    
    -- How much around 0 is considered as the middle (where the selected cover is displayed)
    if     showView == 1 then space = 1.6
    elseif showView == 2 then space = 1.6
    elseif showView == 3 then space = 1.5
    elseif showView == 4 then space = 1
    else                      space = 1
    end

    -- N64 and SNES wide box fix
    if showView == 1 then
        if showCat == 6 or showCat == 7 then
            space = 2.5
        end
    end

    side_factor = x / space -- This is 0 when x is in the exact center, and 1 or -1 when x is at a side of the middle zone
    abs_side_factor = math.abs(side_factor)

    dezoom_factor = math.max(abs_side_factor, quick_scrolling_factor)

    if showView == 1 then
        -- flat zoom out view
        zoom = 0

        if smoothScrolling == 1 then
            -- Smooth scrolling is on
            if x > space then
                extraz = 6
                -- N64 and SNES wide box fix
                if showCat == 6 or showCat == 7 then
                    extrax = 1.3
                else
                    extrax = 1
                end
            elseif x < -space then
                extraz = 6
                -- N64 and SNES wide box fix
                if showCat == 6 or showCat == 7 then
                    extrax = -1.3
                else
                    extrax = -1
                end
            else
                extraz = 6 * dezoom_factor
                -- N64 and SNES wide box fix
                if showCat == 6 or showCat == 7 then
                    extrax = 1.3 * side_factor
                else
                    extrax = 1 * side_factor
                end
            end
        else
            -- Smooth scrolling is off
            if x > 0.5 then
                extraz = 6
                -- N64 and SNES wide box fix
                if showCat == 6 or showCat == 7 then
                    extrax = 1.3
                else
                    extrax = 1
                end
            elseif x < -0.5 then
                extraz = 6
                -- N64 and SNES wide box fix
                if showCat == 6 or showCat == 7 then
                    extrax = -1.3
                else
                    extrax = -1
                end
            end
        end

        extray = -0.05 -- Nudge down as vita cover white line sits very close to UI element
    elseif showView == 2 then
        -- zoomin view
        zoom = -1
        extray = -0.6

        if smoothScrolling == 1 then
            -- Smooth scrolling is on
            if x > space then
                rot = -1
                extraz = 0
                extrax = 1
            elseif x < -space then
                rot = 1
                extraz = 0
                extrax = -1
            else
                rot = -side_factor
                extrax =  side_factor
            end
        else
            -- Smooth scrolling is off
            if x > 0.5 then
                rot = -1
                extraz = 0
                extrax = 1
            elseif x < -0.5 then
                rot = 1
                extraz = 0
                extrax = -1
            end
        end

    elseif showView == 3 then
        -- left side view
        zoom = -0.6
        extray = -0.3

        if smoothScrolling == 1 then
            -- Smooth scrolling is on
            if x > space then
                rot = -0.5
                extraz = 2 + (x / 2)
                extrax = 0.6
            elseif x <= space and x > 0 then
                rot = -0.5 * abs_side_factor
                extraz = (2 + (x / 2)) * dezoom_factor
                extrax = 0.6 * abs_side_factor
            elseif x < -space then
                rot = 0.5
                extraz = 2
                extrax = -10
            elseif x >= -space and x < 0 then
                rot = 0.5 * abs_side_factor
                extraz = 2 * dezoom_factor
                extrax = -10 * abs_side_factor
            end
        else
            -- Smooth scrolling is off
            if x > 0.5 then
                rot = -0.5
                extraz = 2 + (x / 2)
                extrax = 0.6
            elseif x < -0.5 then
                rot = 0.5
                extraz = 2
                extrax = -10
            end
        end

        extrax = extrax - 1 --move to the left

    elseif showView == 4 then
        -- scroll around
        zoom = 0

        if smoothScrolling == 1 then
            -- Smooth scrolling is on
            if x > space then
                extraz = 2 + (x / 1.5)
                extrax = 1
            elseif x < -space then
                extraz = 2 - (x / 1.5)
                extrax = -1
            else
                extraz = (2 + (math.abs(x) / 1.5)) * dezoom_factor
                extrax = side_factor
            end
        else
            -- Smooth scrolling is off
            if x > 0.5 then
                extraz = 2 + (x / 1.5)
                extrax = 1
            elseif x < -0.5 then
                extraz = 2 - (x / 1.5)
                extrax = -1
            end
        end
    else
        -- default view
        zoom = 0

        if smoothScrolling == 1 then
            -- Smooth scrolling is on
            if x > space then
                rot = -1
                extraz = 3
                extrax = 1
            elseif x < -space then
                rot = 1
                extraz = 3
                extrax = -1
            else
                rot = -side_factor
                extraz = 3 * dezoom_factor
                extrax = side_factor
            end
        else
            -- Smooth scrolling is off
            if x > 0.5 then
                rot = -1
                extraz = 3
                extrax = 1
            elseif x < -0.5 then
                rot = 1
                extraz = 3
                extrax = -1
            end
        end
    end
    
    Render.setCamera(camX, 0, 0, 0.0, 0.0, 0.0)
    
    
    function closestBox()

        local box_width = Graphics.getImageWidth(icon)
        local box_height = Graphics.getImageHeight(icon)
        local box_pixel_combined = box_height + box_width
        local box_height_dif = (box_height / box_pixel_combined) * 100

        if      box_height_dif >= 59                                then return modCoverSNESJapan   -- Average approx 62.83
        elseif  box_height_dif >= 58     and box_height_dif < 59    then return modCoverMD          -- Average approx 58.5
        elseif  box_height_dif >= 57     and box_height_dif < 58    then return modCoverNES         -- Average approx 57.87
        elseif  box_height_dif >= 55     and box_height_dif < 57    then return modCoverATARI       -- Average approx 57.66
        elseif  box_height_dif >= 54     and box_height_dif < 55    then return modCoverLYNX        -- Average approx 54.51
        elseif  box_height_dif >= 52     and box_height_dif < 54    then return modCoverMiddle      -- Average approx 52
        elseif  box_height_dif >= 48     and box_height_dif < 52    then return modCoverGB          -- Average approx 50.00
        else
            if apptype==5 or apptype==6 or apptype==7 or apptype==8 or apptype==9 or apptype==10 then
                return  modCoverN64 -- Average approx 42.31
            else
                return modCoverGB
            end
        end

    end

    function closestBoxNoref()

        local box_width = Graphics.getImageWidth(icon)
        local box_height = Graphics.getImageHeight(icon)
        local box_pixel_combined = box_height + box_width
        local box_height_dif = (box_height / box_pixel_combined) * 100

        if      box_height_dif >= 59                                then return modCoverSNESJapanNoref   -- Average approx 62.83
        elseif  box_height_dif >= 58     and box_height_dif < 59    then return modCoverMDNoref          -- Average approx 58.5
        elseif  box_height_dif >= 57     and box_height_dif < 58    then return modCoverNESNoref         -- Average approx 57.87
        elseif  box_height_dif >= 55     and box_height_dif < 57    then return modCoverATARINoref       -- Average approx 57.66
        elseif  box_height_dif >= 54     and box_height_dif < 55    then return modCoverLYNXNoref        -- Average approx 54.51
        elseif  box_height_dif >= 52     and box_height_dif < 54    then return modCoverMiddleNoref      -- Average approx 52
        elseif  box_height_dif >= 48     and box_height_dif < 52    then return modCoverGBNoref          -- Average approx 50.00
        else
            if apptype==5 or apptype==6 or apptype==7 or apptype==8 or apptype==9 or apptype==10 then
                return  modCoverN64Noref -- Average approx 42.31
            else
                return modCoverGBNoref
            end
        end

    end



    if hideBoxes <= 0 then
        if apptype==1 then
            -- PSVita Boxes
            if setReflections == 1 then
                Render.useTexture(modCover, icon)
                Render.drawModel(modCover, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                Render.drawModel(modBox, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverNoref, icon)
                Render.drawModel(modCoverNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                Render.drawModel(modBoxNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==2 then
            if setReflections == 1 then
                Render.useTexture(modCoverPSP, icon)
                Render.drawModel(modCoverPSP, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                Render.drawModel(modBoxPSP, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverPSPNoref, icon)
                Render.drawModel(modCoverPSPNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                Render.drawModel(modBoxPSPNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==3 then
            if setReflections == 1 then
                Render.useTexture(modCoverPSX, icon)
                Render.drawModel(modCoverPSX, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                Render.drawModel(modBoxPSX, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverPSXNoref, icon)
                Render.drawModel(modCoverPSXNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                Render.drawModel(modBoxPSXNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==5 or apptype==6 or apptype==7 or apptype==8 or apptype==9 or apptype==10 or apptype==12 or apptype==17 or apptype==18 or apptype==19 or apptype==20 or apptype==21 or apptype==34 or apptype==35 or apptype==36 or apptype==38 or apptype==43 then
            -- Get closest cover: N64, Snes, Nes, GBA, GBC, GB, Sega CD, TG16, TG CD, PCE, PCE CD, Amiga, FBA, Mame 2003, Mame 2000, ScummVM
            if setReflections == 1 then
                Render.useTexture(closestBox(), icon)
                Render.drawModel(closestBox(), x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(closestBoxNoref(), icon)
                Render.drawModel(closestBoxNoref(), x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif  apptype==23 or apptype==24 or apptype==37 or apptype==40 then
            if setReflections == 1 then
                Render.useTexture(modCoverNES, icon)
                Render.drawModel(modCoverNES, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverNESNoref, icon)
                Render.drawModel(modCoverNESNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==11 then
            if setReflections == 1 then
                Render.useTexture(modCoverGB, icon)
                Render.drawModel(modCoverGB, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverGBNoref, icon)
                Render.drawModel(modCoverGBNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==13 or apptype==14 or apptype==15 or apptype==16 then
            if setReflections == 1 then
                Render.useTexture(modCoverMD, icon)
                Render.drawModel(modCoverMD, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverMDNoref, icon)
                Render.drawModel(modCoverMDNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==22 or apptype==25 or apptype==26 or apptype==27 then
            if showCat >= 1 and showCat <= 41 then
                if setReflections == 1 then
                    Render.useTexture(modCoverMD, icon)
                    Render.drawModel(modCoverMD, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                else
                    Render.useTexture(modCoverMDNoref, icon)
                    Render.drawModel(modCoverMDNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                end
            else
                if setReflections == 1 then
                    Render.useTexture(modCoverTAPE, icon)
                    Render.drawModel(modCoverTAPE, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                else
                    Render.useTexture(modCoverTAPENoref, icon)
                    Render.drawModel(modCoverTAPENoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                end
            end
        elseif apptype==28 or apptype==29 or apptype==30 or apptype==32 or apptype==33 then
            if setReflections == 1 then
                Render.useTexture(modCoverATARI, icon)
                Render.drawModel(modCoverATARI, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverATARINoref, icon)
                Render.drawModel(modCoverATARINoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==31 or apptype==41 then
            if setReflections == 1 then
                Render.useTexture(modCoverLYNX, icon)
                Render.drawModel(modCoverLYNX, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverLYNXNoref, icon)
                Render.drawModel(modCoverLYNXNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        else
            -- Homebrew Icon
            if setReflections == 1 then
                Render.useTexture(modCoverHbr, icon)
                Render.drawModel(modCoverHbr, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverHbrNoref, icon)
                Render.drawModel(modCoverHbrNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        end


    else
        -- hideBoxes = hideBoxes - 0.1
    end
end

local FileLoad = {}

function FreeIcons()
    for k, v in pairs(files_table)              do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(games_table)              do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(psp_table)                do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(psx_table)                do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(psm_table)                do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(n64_table)                do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(snes_table)               do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(nes_table)                do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(nds_table)                do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(gba_table)                do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(gbc_table)                do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(gb_table)                 do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end 
    for k, v in pairs(dreamcast_table)          do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end 
    for k, v in pairs(sega_cd_table)            do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end 
    for k, v in pairs(s32x_table)               do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end 
    for k, v in pairs(md_table)                 do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(sms_table)                do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(gg_table)                 do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(tg16_table)               do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(tgcd_table)               do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(pce_table)                do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(pcecd_table)              do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(amiga_table)              do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(scummvm_table)            do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(pico8_table)              do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(c64_table)                do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(wswan_col_table)          do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(wswan_table)              do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(msx2_table)               do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(msx1_table)               do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(zxs_table)                do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(atari_7800_table)         do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(atari_5200_table)         do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(atari_2600_table)         do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(atari_lynx_table)         do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(colecovision_table)       do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(vectrex_table)            do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(fba_table)                do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(mame_2003_plus_table)     do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(mame_2000_table)          do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(neogeo_table)             do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(ngpc_table)               do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(sysapps_table)            do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end

    for k, v in pairs(recently_played_table)    do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(homebrews_table)          do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
    for k, v in pairs(search_results_table)     do FileLoad[v] = nil Threads.remove(v) if v.ricon then Graphics.freeImage(v.ricon) v.ricon = nil end end
end

function DownloadSingleCover()
    cvrfound = 0
    app_idx = p
    running = false
    status = System.getMessageState()
    
    local coverspath = ""
    local onlineCoverspath = ""
    
    if Network.isWifiEnabled() then
        if apptype == 1 then
            coverspath = SystemsToScan[1].localCoverPath
            onlineCoverspath = SystemsToScan[1].onlineCoverPathSystem
        elseif apptype == 2 then
            coverspath = SystemsToScan[3].localCoverPath
            onlineCoverspath = SystemsToScan[3].onlineCoverPathSystem
        elseif apptype == 3 then
            coverspath = SystemsToScan[4].localCoverPath
            onlineCoverspath = SystemsToScan[4].onlineCoverPathSystem
        elseif apptype == 0 then
            coverspath = SystemsToScan[2].localCoverPath
            onlineCoverspath = SystemsToScan[2].onlineCoverPathSystem
        else
            coverspath = SystemsToScan[apptype].localCoverPath
            onlineCoverspath = SystemsToScan[apptype].onlineCoverPathSystem
        end

        if xCatLookup(showCat)[p].app_type == 43 then
            -- NDS
            name_title = xCatLookup(showCat)[p].titleid:gsub("\n","")
        else
            name_title = xCatLookup(showCat)[p].name:gsub("\n","")
        end

        if apptype == 21 then
            -- Amiga fix
            Network.downloadFile(onlineCoverspath .. xCatLookup(showCat)[p].name_title_search:gsub("%%", '%%25'):gsub("%s+", '%%20') .. ".png", "ux0:/data/RetroFlow/" .. name_title .. ".png")
        else
            Network.downloadFile(onlineCoverspath .. name_title:gsub("%%", '%%25'):gsub("%s+", '%%20') .. ".png", "ux0:/data/RetroFlow/" .. name_title .. ".png")
        end  
        
        if System.doesFileExist("ux0:/data/RetroFlow/" .. name_title .. ".png") then
            tmpfile = System.openFile("ux0:/data/RetroFlow/" .. name_title .. ".png", FREAD)
            size = System.sizeFile(tmpfile)
            if size < 1024 then
                System.deleteFile("ux0:/data/RetroFlow/" .. name_title .. ".png")
            else
                System.rename("ux0:/data/RetroFlow/" .. name_title .. ".png", coverspath .. app_titleid .. ".png")
                cvrfound = 1
            end
            System.closeFile(tmpfile)
            -- Delete image if not in covers folder
            if System.doesFileExist("ux0:/data/RetroFlow/" .. app_titleid .. ".png") then
                System.deleteFile("ux0:/data/RetroFlow/" .. app_titleid .. ".png")
            end
        end

        function update_cvrfound_showcats(def_table_name, def_user_db_file)
            local apptitle = (def_table_name)[app_idx].apptitle
            if System.doesFileExist(coverspath .. apptitle .. ".png") then
                (def_table_name)[app_idx].icon_path=coverspath .. apptitle .. ".png"
                (def_table_name)[app_idx].cover = true
            else
                (def_table_name)[app_idx].icon_path=coverspath .. app_titleid .. ".png"
                (def_table_name)[app_idx].cover = true
            end

            -- Instant cover update - Credit BlackSheepBoy69
            Threads.addTask((def_table_name)[app_idx], {
            Type = "ImageLoad",
            Path = (def_table_name)[app_idx].icon_path,
            Table = (def_table_name)[app_idx],
            Index = "ricon"
            })

            update_cached_table((def_user_db_file), (def_table_name))

            -- Update recently played cover if found
            if #recently_played_table ~= nil then
                key = find_game_table_pos_key(recently_played_table, app_titleid)
                if key ~= nil then
                    recently_played_table[key].icon_path=coverspath .. app_titleid .. ".png"
                    recently_played_table[key].cover = true
                    update_cached_table_recently_played()
                else
                end
            else
            end

        end


        function update_cvrfound_showcats_recent()
            local apptitle = recently_played_table[app_idx].apptitle
            if System.doesFileExist(coverspath .. apptitle .. ".png") then
                recently_played_table[app_idx].icon_path=coverspath .. apptitle .. ".png"
                recently_played_table[app_idx].cover = true
            else
                recently_played_table[app_idx].icon_path=coverspath .. app_titleid .. ".png"
                recently_played_table[app_idx].cover = true
            end

            -- Instant cover update - Credit BlackSheepBoy69
            Threads.addTask(recently_played_table[app_idx], {
            Type = "ImageLoad",
            Path = recently_played_table[app_idx].icon_path,
            Table = recently_played_table[app_idx],
            Index = "ricon"
            })

            update_cached_table_recently_played()

            -- Update game's category cover if found
            if #xAppNumTableLookup(apptype) ~= nil then
                key = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
                if key ~= nil then
                    xAppNumTableLookup(apptype)[key].icon_path=coverspath .. app_titleid .. ".png"
                    xAppNumTableLookup(apptype)[key].cover = true
                    update_cached_table(xAppDbFileLookup(apptype), xAppNumTableLookup(apptype))
                else
                end
            else
            end

        end

        function update_cvrfound_showcats_collections()
            local apptitle = xCatLookup(showCat)[app_idx].apptitle
            if System.doesFileExist(coverspath .. apptitle .. ".png") then
                xCatLookup(showCat)[app_idx].icon_path=coverspath .. apptitle .. ".png"
                xCatLookup(showCat)[app_idx].cover = true
            else
                xCatLookup(showCat)[app_idx].icon_path=coverspath .. app_titleid .. ".png"
                xCatLookup(showCat)[app_idx].cover = true
            end

            -- Instant cover update - Credit BlackSheepBoy69
            Threads.addTask(xCatLookup(showCat)[app_idx], {
            Type = "ImageLoad",
            Path = xCatLookup(showCat)[app_idx].icon_path,
            Table = xCatLookup(showCat)[app_idx],
            Index = "ricon"
            })

            -- update_cached_table_recently_played()

            -- Update game's category cover if found
            if #xAppNumTableLookup(apptype) ~= nil then
                key = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
                if key ~= nil then
                    xAppNumTableLookup(apptype)[key].icon_path=coverspath .. app_titleid .. ".png"
                    xAppNumTableLookup(apptype)[key].cover = true
                    update_cached_table(xAppDbFileLookup(apptype), xAppNumTableLookup(apptype))
                else
                end
            else
            end

            -- -- Update game's category cover if found
            -- if #xAppNumTableLookup(apptype) ~= nil then
            --     key = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
            --     if key ~= nil then
            --         xAppNumTableLookup(apptype)[key].icon_path=coverspath .. app_titleid .. ".png"
            --         update_cached_table(xAppDbFileLookup(apptype), xAppNumTableLookup(apptype))
            --     else
            --     end
            -- else
            -- end

        end

        if cvrfound==1 then
            if showCat == 2 then -- Homebrew do nothing
                
            elseif showCat >= 1 and showCat <= 41 then
                -- Normal systems
                update_cvrfound_showcats(xCatLookup(showCat), xCatDbFileLookup(showCat))

            elseif showCat == 44 then 
                -- Favourites
                update_cvrfound_showcats(fav_count, "db_files.lua")

            elseif showCat == 44 then 
                -- Recent
                update_cvrfound_showcats_recent()

            elseif showCat == 46 then 
                -- Search results
                update_cvrfound_showcats(search_results_table, "db_files.lua")

            elseif showCat >= 47 then
                -- Collections

                -- Update main game categories
                update_cvrfound_showcats_collections()

            else
                -- All cat
                update_cvrfound_showcats(files_table, "db_files.lua")
            end


            if status ~= RUNNING then
                -- System.setMessage(lang_lines.Cover .. " " .. name_title .. " " .. lang_lines.found_exclamation, false, BUTTON_OK)
            end
        else
            if status ~= RUNNING then
                System.setMessage(lang_lines.Cover_not_found, false, BUTTON_OK)
            end
        end
        
    else
        if status ~= RUNNING then
            System.setMessage(lang_lines.Internet_Connection_Required, false, BUTTON_OK)
        end
    end
    
    gettingCovers = false
end

function DownloadSingleSnap()
    bgfound = 0
    app_idx = p
    running = false
    status = System.getMessageState()
    
    local snapPath = ""
    local onlineSnapPath = ""
    
    if Network.isWifiEnabled() then
        if apptype == 1 then
            snapPath = SystemsToScan[1].localSnapPath
            onlineSnapPath = SystemsToScan[1].onlineSnapPathSystem
        elseif apptype == 2 then
            snapPath = SystemsToScan[3].localSnapPath
            onlineSnapPath = SystemsToScan[3].onlineSnapPathSystem
        elseif apptype == 3 then
            snapPath = SystemsToScan[4].localSnapPath
            onlineSnapPath = SystemsToScan[4].onlineSnapPathSystem
        elseif apptype == 0 then
            snapPath = SystemsToScan[2].localSnapPath
            onlineSnapPath = SystemsToScan[2].onlineSnapPathSystem
        else
            snapPath = SystemsToScan[apptype].localSnapPath
            onlineSnapPath = SystemsToScan[apptype].onlineSnapPathSystem
        end

        if xCatLookup(showCat)[p].app_type == 43 then
            -- NDS
            name_title = xCatLookup(showCat)[p].titleid:gsub("\n","")
        else
            name_title = xCatLookup(showCat)[p].name:gsub("\n","")
        end

        if onlineSnapPath:find("libretro") then

            name_after_libretro_gsub = {}

            -- Libretro - Replace these characters &*/:`<>?\|" with an underscore _ to match libretro naming convention
            if apptype == 21 then
                -- Amiga fix
                name_after_libretro_gsub = xCatLookup(showCat)[p].name_title_search:gsub("[&*/:`<>?\\|\"]+", "_")
                Network.downloadFile(onlineSnapPath .. xCatLookup(showCat)[p].name_title_search:gsub("[&*/:`<>?\\|\"]+", "_"):gsub("%s+", '%%20') .. ".png", "ux0:/data/RetroFlow/" .. name_title .. ".png")
            else
                name_after_libretro_gsub = name_title:gsub("[&*/:`<>?\\|\"]+", "_")
            end

            Network.downloadFile(onlineSnapPath .. name_after_libretro_gsub:gsub("%s+", '%%20') .. ".png", "ux0:/data/RetroFlow/" .. name_title .. ".png")

        else

            -- Not libretro
            if apptype == 21 then
            -- Amiga fix
                Network.downloadFile(onlineSnapPath .. xCatLookup(showCat)[p].name_title_search:gsub("%s+", '%%20') .. ".png", "ux0:/data/RetroFlow/" .. name_title .. ".png")
            else
                Network.downloadFile(onlineSnapPath .. name_title:gsub("%s+", '%%20') .. ".png", "ux0:/data/RetroFlow/" .. name_title .. ".png")
            end
        end
        

        if System.doesFileExist("ux0:/data/RetroFlow/" .. name_title .. ".png") then
            tmpfile = System.openFile("ux0:/data/RetroFlow/" .. name_title .. ".png", FREAD)
            size = System.sizeFile(tmpfile)
            System.closeFile(tmpfile)
            if size < 1024 then
                System.deleteFile("ux0:/data/RetroFlow/" .. name_title .. ".png")
            else
                System.rename("ux0:/data/RetroFlow/" .. name_title .. ".png", snapPath .. xCatLookup(showCat)[p].name .. ".png")
                bgfound = 1
            end
            -- Delete image if not in covers folder
            if System.doesFileExist("ux0:/data/RetroFlow/" .. name_title .. ".png") then
                System.deleteFile("ux0:/data/RetroFlow/" .. name_title .. ".png")
            end
        end

        if bgfound==1 then

            if showCat == 2 then
                -- Homebrew do nothing
            else
                -- Normal systems
                pic_path = xCatLookup(showCat)[p].snap_path_local .. xCatLookup(showCat)[p].name .. ".png"
            end

            if System.doesFileExist(pic_path) and Game_Backgrounds >= 1 then
                Graphics.freeImage(backTmp)
                backTmp = Graphics.loadImage(pic_path)
                Graphics.setImageFilters(backTmp, FILTER_LINEAR, FILTER_LINEAR)
                Render.useTexture(modBackground, backTmp)
            else
                Render.useTexture(modBackground, imgCustomBack)
            end

            -- Update recently played background if found
            if #recently_played_table ~= nil then
                key = find_game_table_pos_key(recently_played_table, name_title)
                if key ~= nil then
                    recently_played_table[key].snap_path_local=snapPath
                    update_cached_table_recently_played()
                else
                end
            else
            end
            

            if status ~= RUNNING then
                -- System.setMessage(lang_lines.Background .. " " .. name_title .. " " .. lang_lines.found_exclamation, false, BUTTON_OK)
            end
        else
            if status ~= RUNNING then
                System.setMessage(lang_lines.Background_not_found, false, BUTTON_OK)
            end
        end
        
    else
        if status ~= RUNNING then
            System.setMessage(lang_lines.Internet_Connection_Required, false, BUTTON_OK)
        end
    end
    
    gettingBackgrounds = false
end

function drawCategory_icons (def)

    -- Show fav icon if game if a favourite
    favourite_flag = (def)[p].favourite
    if (def)[p].favourite == true then
        Graphics.drawImage(685 - time24_offset + pstv_offset + wifi_offset, 36, imgFavorite_small_on)
    else
    end

    -- Show hidden icon if game is hidden
    hide_game_flag = (def)[p].hidden
    if (def)[p].hidden == true then
        favourite_flag = (def)[p].favourite
        if (def)[p].favourite == true then
            Graphics.drawImage(685 - time24_offset + pstv_offset + wifi_offset - 42, 36, imgHidden_small_on)
        else
            Graphics.drawImage(685 - time24_offset + pstv_offset + wifi_offset, 36, imgHidden_small_on)
        end
    else
    end

end


function drawCategory (def)

    -- Draw flat covers
    if showView == 5 then

        base_y = fv_left_margin
        base_y_left = 0
        cover_widths_x_bonus = 0

        for l, file in pairs((def)) do

            if (def)[p+7] and (def)[p+7].ricon then -- Credit BlackSheepBoy69
                render_distance = 16
            else
                render_distance = 8
            end

            if (l >= master_index) then
                base_x = base_x + space
            end

            -- Draw covers, next and one to left of current
            if (l >= master_index) or (l == master_index -1) then

                if l > p-render_distance and l < p+render_distance+2 or l == master_index -1 then -- Credit BlackSheepBoy69 - Experimental fix.
                    if FileLoad[file] == nil then --add a new check here
                        FileLoad[file] = true
                        Threads.addTask(file, {
                            Type = "ImageLoad",
                            Path = file.icon_path,
                            Table = file,
                            Index = "ricon"
                        })
                    end

                    -- Draw covers to right
                    if (l >= master_index) then
                        if file.ricon ~= nil then
                            get_cover_scale(file.ricon)

                            -- Smooth scrolling disabled until can improve
                            -- if smoothScrolling == 1 then
                            --     DrawCover_Flat_Smooth((l-curTotal-1) + targetX,152,file.name,color, file.ricon, l)            
                            -- else
                            --     DrawCover_Flat(base_y,152,file.name,color, file.ricon, l)
                            -- end
                            DrawCover_Flat(base_y,152,file.name,color, file.ricon, l)

                            if fv_cover_scale_px ~= nil then
                                base_y = base_y + fv_cover_scale_px + fv_gutter
                            end

                            drawCategory_icons((def))
                        else
                            get_cover_scale(file.icon)

                            -- Smooth scrolling disabled until can improve
                            -- if smoothScrolling == 1 then
                            --     DrawCover_Flat_Smooth((l-curTotal-1) + targetX,152,file.name,color, file.icon, l)
                            -- else
                            --     DrawCover_Flat(base_y,152,file.name,color, file.icon, l)
                            -- end
                            DrawCover_Flat(base_y,152,file.name,color, file.icon, l)
                            if fv_cover_scale_px ~= nil then
                                base_y = base_y + fv_cover_scale_px + fv_gutter
                            end
                            
                            drawCategory_icons((def))
                        end


                    -- Draw one previous cover to left
                    elseif (l == master_index -1) then
                        if file.ricon ~= nil then
                            get_cover_scale(file.ricon)
                            if fv_cover_scale_px ~= nil then
                                base_y_left = 0 - fv_cover_scale_px + fv_left_margin - fv_gutter
                                if smoothScrolling == 1 then
                                    DrawCover_Flat_Smooth((l-curTotal-1) + targetX,152,file.name,color, file.ricon, l)
                                else
                                    DrawCover_Flat(base_y_left,152,file.name,color, file.ricon, l)
                                end
                            end
                             
                        else
                            get_cover_scale(file.icon)
                            if fv_cover_scale_px ~= nil then
                                base_y_left = 0 - fv_cover_scale_px + fv_left_margin - fv_gutter
                                if smoothScrolling == 1 then
                                    DrawCover_Flat((l-curTotal-1) + targetX,152,file.name,color, file.icon, l)
                                else
                                    DrawCover_Flat(base_y_left,152,file.name,color, file.icon, l)
                                end
                            end
                            
                        end
                    else
                    end

                else
                    if FileLoad[file] == true then
                        FileLoad[file] = nil
                        Threads.remove(file)
                    end
                    if file.ricon then
                        Graphics.freeImage(file.ricon)
                        file.ricon = nil
                    end
                end

            end

        end


    -- Game list view
    elseif showView == 6 then

        local y = 106

        x_listview = 32

        Graphics.fillRect(0, 960, 93, 96, white)
        Graphics.fillRect(0, 568, 96, 146, themeCol)-- selection
    
        
        -- Write visible menu entries
        for l, file in pairs((def)) do

            if (def)[p+7] and (def)[p+7].ricon then -- Credit BlackSheepBoy69
                render_distance = 16
            else
                render_distance = 8
            end

            if (l >= master_index) then
                base_x = base_x + space
            end

            -- Draw cover
            -- if (l >= p) or (l == p -1) then

                if l > p-render_distance and l < p+render_distance+2 or l == p -1 then -- Credit BlackSheepBoy69 - Experimental fix.
                    if FileLoad[file] == nil then --add a new check here
                        FileLoad[file] = true
                        Threads.addTask(file, {
                            Type = "ImageLoad",
                            Path = file.icon_path,
                            Table = file,
                            Index = "ricon"
                        })
                    end

                    -- Draw cover
                    if (l == p) then
                        if file.ricon ~= nil then
                            DrawCover_List(file.ricon)
                            drawCategory_icons((def))
                        else
                            DrawCover_List(file.icon)
                            drawCategory_icons((def))
                        end
                    end

                else
                    if FileLoad[file] == true then
                        FileLoad[file] = nil
                        Threads.remove(file)
                    end
                    if file.ricon then
                        Graphics.freeImage(file.ricon)
                        file.ricon = nil
                    end
                end

            -- end


            -- Draw list of games
            x = x_listview
            if l >= p and y < 496 then
                if p == l then
                    color = white
                    x = x_listview
                else
                    color = white
                end
                
                -- Trim long game names and add "..."
                    apptitle_len = string.len (file.apptitle)
                    apptitle_len_max = 45
                    if apptitle_len >= apptitle_len_max then
                        apptitle_trimmed = string.sub(file.apptitle, 1, apptitle_len_max) .. "..."
                    else
                        apptitle_trimmed = file.apptitle
                    end

                Font.print(fnt22, x_listview, y, apptitle_trimmed, color)
                y = y + 49
            end

            -- Check for out of bounds in menu
            if p > #(def) then
                p = 1
            elseif i < 1 then
                p = #(def)
            end

        end

    -- Draw covers in 3D obj models
    else

        for l, file in pairs((def)) do

            if (def)[p+7] and (def)[p+7].ricon then -- Credit BlackSheepBoy69
                render_distance = 16
            else
                render_distance = 8
            end

            if (l >= master_index) then
                base_x = base_x + space
            end

            if l > p-render_distance and l < p+render_distance+2 then -- Credit BlackSheepBoy69 - Experimental fix.
                if FileLoad[file] == nil then --add a new check here
                    FileLoad[file] = true
                    Threads.addTask(file, {
                        Type = "ImageLoad",
                        Path = file.icon_path,
                        Table = file,
                        Index = "ricon"
                    })
                end
                if file.ricon ~= nil then
                    --draw visible covers only
                    DrawCover(
                        (targetX + l * space) - (#(def) * space + space), 
                        -0.6, 
                        file.name, 
                        file.ricon, 
                        l==p, -- Credit BlackSheepBoy69 - Uses l==p (which returns as true or false) to say where selector goes.
                        file.app_type,
                        l
                    )

                    drawCategory_icons((def))

                else
                    --draw visible covers only
                    DrawCover(
                        (targetX + l * space) - (#(def) * space + space),
                        -0.6,
                        file.name,
                        file.icon,
                        l==p, -- Credit BlackSheepBoy69 - Uses l==p (which returns as true or false) to say where selector goes.
                        file.app_type,
                        l
                    )         

                    drawCategory_icons((def))
            
                end
            else
                if FileLoad[file] == true then
                    FileLoad[file] = nil
                    Threads.remove(file)
                end
                if file.ricon then
                    Graphics.freeImage(file.ricon)
                    file.ricon = nil
                end
            end
        end

    end
        
    if showView ~= 2 then
        if showView >= 5 then
            -- Font.print(fnt20, fv_left_margin - fv_border, fv_cover_height + fv_cover_y + 60, p .. lang_lines.of .. #(def), white_opaque)
            if showView == 6 then
                if setLanguage == 9 or setLanguage == 10 or setLanguage == 17 or setLanguage == 18 or setLanguage == 19 then
                    -- Reverse order of numbering xxx/x : Japanese, Chinese (Traditional), Korean, Chinese (Simplified), Japanese (Ryukyuan)
                    Font.print(fnt20, 32, 508, #(def) .. lang_lines.of .. p, white)-- Draw total items
                else
                    -- Normal x/xxx
                    Font.print(fnt20, 32, 508, p .. lang_lines.of .. #(def), white)-- Draw total items
                end
            end
        else
            if setLanguage == 9 or setLanguage == 10 or setLanguage == 17 or setLanguage == 18 or setLanguage == 19 then
                -- Reverse order of numbering xxx/x : Japanese, Chinese (Traditional), Korean, Chinese (Simplified), Japanese (Ryukyuan)
                PrintCentered(fnt20, 480, 462, #(def) .. lang_lines.of .. p, white, 20)-- Draw total items
            else
                -- Normal x/xxx
                PrintCentered(fnt20, 480, 462, p .. lang_lines.of .. #(def), white, 20)-- Draw total items
            end
        end
    end
end

functionTime = Timer.getTime(oneLoopTimer)

-- Main loop
while true do
    
    -- Threads update
    Threads.update()
    
    -- Reading input
    pad = Controls.read()
    
    mx, my = Controls.readLeftAnalog()
    
    -- touch input
    x1, y1 = Controls.readTouch()
    
    -- Initializing rendering
    Graphics.initBlend()
    Screen.clear(black)
    
    if delayButton > 0 then
        delayButton = delayButton - 0.1
    else
        delayButton = 0
    end

    if hideBoxes > 0 then
        hideBoxes = hideBoxes - 0.1
    else
        hideBoxes = 0
    end
    
    -- Music
    if setMusic == 1 then

        -- More than 1 track - move to next if the song is over
        if #music_sequential > 1 then
            
            -- Is it playing?

            if Sound.isPlaying(sndMusic) then
                -- Yes - do nothing
            else
                -- No - go to the next track
                track = track + 1 
                PlayMusic()
            end

        -- Only 1 track - do nothing
        else   
        end
    end


    -- Keyboard functions
    
        function keyboard_search_function()

            

            if state ~= RUNNING and hasTyped == true then
                        
                hasTyped = false

                -- Typed text
                ret_search = "" .. Keyboard.getInput()

                -- Bug fix, for when enter pressed without text, do nothing
                if string.len(ret_search) == 0 then
                    state = CANCELED
                    -- Terminating keyboard
                    Keyboard.clear()
                end

                if state == CANCELED then
                else

                    search_results_table = {}
                    -- If already on search category, move away
                    if showCat == 46 then
                        random_game_selected = false -- Workaround, as random games and search use the same table
                        showCat = 0
                    end

                    -- Always reset random_game_selected for search
                    random_game_selected = false

                    -- Typed text
                    -- Converted to upper, lower case and proper case for broader results
                    ret_search_lc = string.lower(ret_search)
                    ret_search_uc = string.upper(ret_search)
                    ret_search_pc = string.gsub(" "..ret_search, "%W%l", string.upper):sub(2)

                    for l, file in pairs(files_table) do
                        if string.match(file.apptitle, escape_pattern(ret_search)) or string.match(file.apptitle, escape_pattern(ret_search_lc)) or string.match(file.apptitle, escape_pattern(ret_search_uc)) or string.match(file.apptitle, escape_pattern(ret_search_pc)) then
                            table.insert(search_results_table, file)
                            table.sort(search_results_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
                            local app_title = search_results_table[1].app_title
                        else
                            local app_title = lang_lines.Search_No_Results -- Workaround - hides last name shown before searching
                        end
                    end

                    showCat = 46
                    p = 1
                    master_index = p
                    showMenu = 0
                    GetNameAndAppTypeSelected()
                end

                -- Terminating keyboard
                keyboard_search = false
                Keyboard.clear()
            else
            end
        end

        function keyboard_rename_function()
            if state ~= RUNNING and hasTyped == true then

                hasTyped = false

                -- Typed text
                ret_rename = "" .. Keyboard.getInput()

                -- Bug fix, for when enter pressed without text, do nothing
                if string.len(ret_rename) == 0 then
                    state = CANCELED
                    -- Terminating keyboard
                    Keyboard.clear()
                end

                -- Bug fix if someone names a game "-", if allowed then they won't be able to rename again.
                if ret_rename == "-" then
                    state = CANCELED
                    -- Terminating keyboard
                    Keyboard.clear()

                    if status ~= RUNNING then
                        System.setMessage("Invalid title", false, BUTTON_OK)
                    end
                    
                end

                if state == CANCELED and keyboard_rename == true then
                else

                    -- Update current table
                    xCatLookup(showCat)[p].apptitle = ret_rename
                    xCatLookup(showCat)[p].title = ret_rename    
                    txtname = ret_rename

                    -- START updating other tables -- 

                    -- Recent
                    if #recently_played_table ~= nil then
                        local key = find_game_table_pos_key(recently_played_table, app_titleid)
                        if key ~= nil then
                            -- Yes - Found in files table
                            recently_played_table[key].title = ret_rename
                            recently_played_table[key].apptitle = ret_rename


                            -- Look for custom cover name - Recent table

                                -- Custom name
                                if System.doesFileExist(recently_played_table[key].cover_path_local .. recently_played_table[key].apptitle .. ".png") then
                                    recently_played_table[key].icon_path = (recently_played_table[key].cover_path_local .. recently_played_table[key].apptitle .. ".png")
                                
                                -- App name
                                elseif System.doesFileExist(recently_played_table[key].cover_path_local .. recently_played_table[key].name .. ".png") then
                                    recently_played_table[key].icon_path = recently_played_table[key].cover_path_local .. recently_played_table[key].name .. ".png"
                                
                                -- Vita ur0 png
                                elseif System.doesFileExist("ur0:/appmeta/" .. recently_played_table[key].name .. "/icon0.png") then
                                    recently_played_table[key].icon_path = "ur0:/appmeta/" .. recently_played_table[key].name .. "/icon0.png"

                                -- Vita vs0 png - sysapp
                                elseif System.doesFileExist("vs0:/app/" .. recently_played_table[key].name .. "/sce_sys/icon0.png") then
                                    recently_played_table[key].icon_path = "vs0:/app/" .. recently_played_table[key].name .. "/sce_sys/icon0.png"

                                -- Pico8 rom folder png
                                elseif recently_played_table[key].app_type == 41 then
                                    recently_played_table[key].icon_path = recently_played_table[key].game_path

                                -- Missing cover png -- find me
                                elseif System.doesFileExist("app0:/DATA/" .. xAppNumTableLookup_Missing_Cover(recently_played_table[key].app_type) .. ".png") then
                                    recently_played_table[key].icon_path = "app0:/DATA/" .. xAppNumTableLookup_Missing_Cover(recently_played_table[key].app_type) .. ".png"

                                -- Fallback - blank grey
                                else
                                    recently_played_table[key].icon_path = "app0:/DATA/noimg.png" --blank grey
                                end


                            -- Look for custom cover name - Game table by app type

                                local key2 = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
                                if key2 ~= nil then

                                    -- Custom name
                                    if System.doesFileExist(xAppNumTableLookup(apptype)[key2].cover_path_local .. recently_played_table[key].apptitle .. ".png") then
                                        xAppNumTableLookup(apptype)[key2].icon_path = xAppNumTableLookup(apptype)[key2].cover_path_local .. recently_played_table[key].apptitle .. ".png"
                                    
                                    -- App name
                                    elseif System.doesFileExist(xAppNumTableLookup(apptype)[key2].cover_path_local .. recently_played_table[key].name .. ".png") then
                                        xAppNumTableLookup(apptype)[key2].icon_path = xAppNumTableLookup(apptype)[key2].cover_path_local .. recently_played_table[key].name .. ".png"
                                    
                                    -- Vita ur0 png
                                    elseif System.doesFileExist("ur0:/appmeta/" .. recently_played_table[key].name .. "/icon0.png") then
                                        xAppNumTableLookup(apptype)[key2].icon_path = "ur0:/appmeta/" .. recently_played_table[key].name .. "/icon0.png"

                                    -- Vita vs0 png - sysapp
                                    elseif System.doesFileExist("vs0:/app/" .. recently_played_table[key].name .. "/sce_sys/icon0.png") then
                                        xAppNumTableLookup(apptype)[key2].icon_path = "vs0:/app/" .. recently_played_table[key].name .. "/sce_sys/icon0.png"

                                    -- Pico8 rom folder png
                                    elseif xAppNumTableLookup(apptype)[key2].app_type == 41 then
                                        xAppNumTableLookup(apptype)[key2].icon_path = xAppNumTableLookup(apptype)[key2].game_path

                                    -- Missing cover png -- find me
                                    elseif System.doesFileExist("app0:/DATA/" .. xAppNumTableLookup_Missing_Cover(recently_played_table[key].app_type) .. ".png") then
                                        xAppNumTableLookup(apptype)[key2].icon_path = "app0:/DATA/" .. xAppNumTableLookup_Missing_Cover(recently_played_table[key].app_type) .. ".png"

                                    -- Fallback - blank grey
                                    else
                                        xAppNumTableLookup(apptype)[key2].icon_path = "app0:/DATA/noimg.png" --blank grey
                                    end
                                else
                                end

                            update_cached_table_recently_played()
                        else
                          -- No
                        end
                    else
                    end

                    -- Favourites
                    if #fav_count ~= nil then
                        local key = find_game_table_pos_key(fav_count, app_titleid)
                        if key ~= nil then
                            -- Yes - Found in files table
                            fav_count[key].title = ret_rename
                            fav_count[key].apptitle = ret_rename
                        else
                            -- No
                        end
                    else
                    end
                    

                    -- Look for custom cover name

                        -- Custom name
                        if System.doesFileExist(xCatLookup(showCat)[p].cover_path_local .. xCatLookup(showCat)[p].apptitle .. ".png") then
                            xCatLookup(showCat)[p].icon_path = xCatLookup(showCat)[p].cover_path_local .. xCatLookup(showCat)[p].apptitle .. ".png"
                        
                        -- App name
                        elseif System.doesFileExist(xCatLookup(showCat)[p].cover_path_local .. xCatLookup(showCat)[p].name .. ".png") then
                            xCatLookup(showCat)[p].icon_path = xCatLookup(showCat)[p].cover_path_local .. xCatLookup(showCat)[p].name .. ".png"
                        
                        -- Vita ur0 png
                        elseif System.doesFileExist("ur0:/appmeta/" .. xCatLookup(showCat)[p].name .. "/icon0.png") then
                            xCatLookup(showCat)[p].icon_path = "ur0:/appmeta/" .. xCatLookup(showCat)[p].name .. "/icon0.png"

                        -- Vita vs0 png - sysapp
                        elseif System.doesFileExist("vs0:/app/" .. xCatLookup(showCat)[p].name .. "/sce_sys/icon0.png") then
                            xCatLookup(showCat)[p].icon_path = "vs0:/app/" .. xCatLookup(showCat)[p].name .. "/sce_sys/icon0.png"

                        -- Pico8 rom folder png
                        elseif xCatLookup(showCat)[p].app_type == 41 then
                            xCatLookup(showCat)[p].icon_path = xCatLookup(showCat)[p].game_path

                        -- Missing cover png -- find me
                        elseif System.doesFileExist("app0:/DATA/" .. xAppNumTableLookup_Missing_Cover(xCatLookup(showCat)[p].app_type) .. ".png") then
                            xCatLookup(showCat)[p].icon_path = "app0:/DATA/" .. xAppNumTableLookup_Missing_Cover(xCatLookup(showCat)[p].app_type) .. ".png"

                        -- Fallback - blank grey
                        else
                            xCatLookup(showCat)[p].icon_path = "app0:/DATA/noimg.png" --blank grey
                        end


                    -- Renamed
                    -- Has the game been renamed before?
                    if #renamed_games_table ~= nil then
                        local key = find_game_table_pos_key(renamed_games_table, app_titleid)
                        if key ~= nil then
                            -- Yes - it's already in the rename list, update it.
                            renamed_games_table[key].title = ret_rename
                        else
                            -- No, it's new, add it to the rename list
                            renamed_game_temp = {}
                            table.insert(renamed_game_temp, {name = app_titleid, title = ret_rename})

                            for i, file in pairs(renamed_game_temp) do
                                table.insert(renamed_games_table, file)
                            end
                        end
                        -- Save the renamed table for importing on restart
                        update_cached_table_renamed_games()
                    else
                    end

                    temp_import_hidden_cats(showHomebrews, homebrews_table, "db_homebrews.lua")
                    temp_import_hidden_cats(showSysApps, sysapps_table, "db_sysapps.lua")

                    -- Apptype table
                    update_cached_table(xAppDbFileLookup(apptype), xAppNumTableLookup(apptype))

                    -- All other tables - re-import cache and rename if match rename table
                    files_table = import_cached_DB()
                    import_collections()

                    -- Get favourites list - so can stay on favourites category if renaming from there
                    create_fav_count_table(return_table)

                    -- END updating other tables -- 

                    -- If show system apps if off and currently viewing system apps when renaming, must have used quick menu.
                    -- Turn on system apps temporarily so can see the result of the rename.
                    if showSysApps == 0 and showCat == 43 then
                        -- Turn on temporarily
                        showSysApps = 1

                        -- Import and jump to menu
                        FreeIcons()
                        count_cache_and_reload()
                        showCat = 43

                        -- Turn off again, the table will be removed when the user changes category (see category controls, square)
                        showSysApps = 0
                    else
                    end

                    -- Get ready for reload - Game position may change due to alphabetical sorting, find its new position
                    if #xCatLookup(showCat) ~= nil then
                        local key = find_game_table_pos_key(xCatLookup(showCat), app_titleid)
                        if key ~= nil then
                            p = key
                            master_index = p
                            -- showMenu = 0
                            
                            -- Instantly move to selection
                            if startCovers == false then
                                targetX = base_x
                                startCovers = true
                                GetInfoSelected()
                            end

                        else
                            showCat = 1
                            p = 1
                            master_index = p
                            -- showMenu = 0
                        end
                    else
                    end

                    GetNameAndAppTypeSelected()
                    -- Render.useTexture(modBackground, imgCustomBack)

                    GetInfoSelected()

                    

                    -- Instant cover update - Credit BlackSheepBoy69
                    Threads.addTask(xCatLookup(showCat)[p], {
                    Type = "ImageLoad",
                    Path = xCatLookup(showCat)[p].icon_path,
                    Table = xCatLookup(showCat)[p],
                    Index = "ricon"
                    })

                end

                keyboard_rename = false
                -- Terminating keyboard
                Keyboard.clear()
            else
            end
        end

        function keyboard_collection_name_new_function()
            if state ~= RUNNING and hasTyped == true then
                    
                hasTyped = false

                -- Typed text
                ret_collection = "" .. Keyboard.getInput()

                -- Bug fix, for when enter pressed without text, do nothing
                if string.len(ret_collection) == 0 then
                    state = CANCELED
                    -- Terminating keyboard
                    Keyboard.clear()
                end

                if state == CANCELED then
                else

                    ret_collection_filename = "Collection_" .. ret_collection:gsub(" ", "_") .. ".lua"


                    local duplicate_name_num = 1
                    function check_if_collection_file_exists(def_duplicate_name_num)
                        if System.doesFileExist(collections_dir .. "Collection_" .. ret_collection:gsub(" ", "_") .. "_(" .. (def_duplicate_name_num) .. ")".. ".lua") then
                            return true
                        else
                            return false
                        end
                    end

                    -- Append number if filename already exists (prevents overwriting a list)
                    if System.doesFileExist(collections_dir .. ret_collection_filename) then
                        
                        while check_if_collection_file_exists(duplicate_name_num) == true do
                            duplicate_name_num = duplicate_name_num + 1  
                        end

                        ret_collection_filename = "Collection_" .. ret_collection:gsub(" ", "_") .. "_(" .. duplicate_name_num .. ")".. ".lua"
                    else
                    end

                    new_collection = {}
                    new_collection = 
                    { 
                        [1] = 
                        {
                            ["apptitle"] = xCatLookup(showCat)[p].title,
                            ["name"] = xCatLookup(showCat)[p].name,
                            ["app_type"] = xCatLookup(showCat)[p].app_type,
                        },
                    }

                    update_cached_collection(ret_collection_filename, new_collection)
                    create_collections_list()
                    -- import_collections()
                    -- count_cache_and_reload()

                    keyboard_collection_name_new = false
                    -- Terminating keyboard
                    Keyboard.clear()

                    FreeIcons()
                    FreeMemory()
                    Network.term()
                    dofile("app0:index.lua")

                end

                keyboard_collection_name_new = false
                -- Terminating keyboard
                Keyboard.clear()
            else
            end
        end

        function keyboard_collection_rename_function()
            if state ~= RUNNING and hasTyped == true then
                    
                hasTyped = false

                -- Typed text
                ret_rename_collection = "" .. Keyboard.getInput()

                -- Bug fix, for when enter pressed without text, do nothing
                if string.len(ret_rename_collection) == 0 then
                    state = CANCELED
                    -- Terminating keyboard
                    Keyboard.clear()
                end

                if state == CANCELED then
                else

                    ret_rename_collection_new_filename = "Collection_" .. ret_rename_collection:gsub(" ", "_") .. ".lua"
                
                    if System.doesFileExist(collections_dir .. keyboard_collection_rename_filename) then
                        System.rename(collections_dir .. keyboard_collection_rename_filename, collections_dir .. ret_rename_collection_new_filename)
                    else
                    end

                    if string.match(startCategory_collection, keyboard_collection_rename_table_name) then
                        startCategory_collection_renamed = "Collection_" .. ret_rename_collection:gsub(" ", "_")
                        SaveSettings()
                    else
                        startCategory_collection_renamed = {}
                    end
                    
                    keyboard_collection_rename = false
                    -- Terminating keyboard
                    Keyboard.clear()

                    FreeIcons()
                    FreeMemory()
                    Network.term()
                    dofile("app0:index.lua")

                end

                keyboard_collection_rename = false
                -- Terminating keyboard
                Keyboard.clear()
            else
            end
        end

    -- Keyboard logic

        state = Keyboard.getState()

        if      keyboard_rename == true     and keyboard_collection_name_new == false   and keyboard_collection_rename == false     then keyboard_rename_function()
        elseif  keyboard_rename == false    and keyboard_collection_name_new == true    and keyboard_collection_rename == false     then keyboard_collection_name_new_function()
        elseif  keyboard_rename == false    and keyboard_collection_name_new == false   and keyboard_collection_rename == true      then keyboard_collection_rename_function()

        else
            keyboard_search_function()
        end


    -- Graphics
    if setBackground >= 1 then
        Render.drawModel(modBackground, 0, 0, -5, 0, 0, 0)-- Draw Background as model
    else
        Render.drawModel(modDefaultBackground, 0, 0, -5, 0, 0, 0)-- Draw Background as model
    end
    
    Graphics.fillRect(0, 960, 496, 544, themeCol)-- footer bottom


-- MENU 0 - GAMES SCREEN
    if showMenu == 0 then
        -- MAIN VIEW

        -- game lst view
        if showView == 6 then
            -- Graphics.fillRect(0, 960, 0, 496, Color.new(0,0,0, (255/100) * 40)) -- Overall fill
            Graphics.fillRect(0, 960, 0, 92, Color.new(0,0,0, math.abs(255/100) * 30)) -- Top bar
            Graphics.fillRect(0, 568, 96, 496, Color.new(0,0,0, math.abs(255/100) * 30)) -- List area - 30% black opacity
            Graphics.fillRect(568, 960, 96, 496, Color.new(0,0,0, math.abs(255/100) * 45)) -- Game image
        end

        -- Header

        wifi_offset = 0
        if Network.isWifiEnabled() then
            Graphics.drawImage(798 + pstv_offset + wifi_offset, 35, imgWifi)-- wifi icon

            if pstv == true then
                pstv_offset = 110
            end

        else
            wifi_offset = 30

            if pstv == true then
                pstv_offset = 125
            end

        end

        h, m, s = System.getTime()

        if setTime == 0 then
            -- 24 hour clock
            Font.print(fnt20, 726 + pstv_offset + wifi_offset, 34, string.format("%02d:%02d", h, m), white)-- Draw time
        else
            -- 12 hour clock
            local ampm = " AM"

            -- Get AM / PM string
            if h < 12 then
                ampm = " AM"
            elseif h >= 12 then
                ampm = " PM"
            else
            end
                
            -- Format 24 hr 2 digits to 12 hr 1 digit
            if h >= 13 then
                h = h -12
            elseif h == 0 then
                h = 12
            end

            -- Load small font for AM/PM string
            if fnt14 == nil then
                fnt14 = Font.load("app0:/DATA/" .. fontname)
                Font.setPixelSizes(fnt14, 14)
            end

            local time12hr = (string.format("%d:%02d", h, m))
            labeltime12hr = Font.getTextWidth(fnt14, time12hr)

            Font.print(fnt20, 726 - time24_offset + pstv_offset + wifi_offset, 34, (string.format("%d:%02d", h, m)), white)-- Draw time
            Font.print(fnt14, 726 - time24_offset + pstv_offset + wifi_offset + labeltime12hr + 15, 40, ampm, white)-- Draw time
        end

        if pstv == false then
            life = System.getBatteryPercentage()
            Font.print(fnt20, 840, 34, life .. "%", white)-- Draw battery

            if System.isBatteryCharging() then
                -- Draw charging icon
                Graphics.drawImage(888, 39, imgBatteryCharging)
            else
                -- Draw normal battery icon
                Graphics.drawImage(888, 39, imgBattery)
                Graphics.fillRect(891, 891 + (life / 5.2), 43, 51, white)
            end

        end

        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Launch)
        label2 = Font.getTextWidth(fnt20, lang_lines.Details)
        label3 = Font.getTextWidth(fnt20, lang_lines.Category)
        label4 = Font.getTextWidth(fnt20, lang_lines.View)
        
        if showCat == 1 then Font.print(fnt22, 32, 34,      lang_lines.PS_Vita, white)
        elseif showCat == 2 then Font.print(fnt22, 32, 34,  lang_lines.Homebrews, white)
        elseif showCat == 3 then Font.print(fnt22, 32, 34,  lang_lines.PSP, white)
        elseif showCat == 4 then Font.print(fnt22, 32, 34,  lang_lines.PlayStation, white)
        elseif showCat == 5 then Font.print(fnt22, 32, 34,  lang_lines.Playstation_Mobile, white)
        elseif showCat == 6 then Font.print(fnt22, 32, 34,  lang_lines.Nintendo_64, white)
        elseif showCat == 7 then Font.print(fnt22, 32, 34,  lang_lines.Super_Nintendo, white)
        elseif showCat == 8 then Font.print(fnt22, 32, 34,  lang_lines.Nintendo_Entertainment_System, white)
        elseif showCat == 9 then Font.print(fnt22, 32, 34,  lang_lines.Nintendo_DS, white)
        elseif showCat == 10 then Font.print(fnt22, 32, 34, lang_lines.Game_Boy_Advance, white)
        elseif showCat == 11 then Font.print(fnt22, 32, 34, lang_lines.Game_Boy_Color, white)
        elseif showCat == 12 then Font.print(fnt22, 32, 34, lang_lines.Game_Boy, white)
        elseif showCat == 13 then Font.print(fnt22, 32, 34, lang_lines.Sega_Dreamcast, white)
        elseif showCat == 14 then Font.print(fnt22, 32, 34, lang_lines.Sega_CD, white)
        elseif showCat == 15 then Font.print(fnt22, 32, 34, lang_lines.Sega_32X, white)
        elseif showCat == 16 then Font.print(fnt22, 32, 34, lang_lines.Sega_Mega_Drive, white)
        elseif showCat == 17 then Font.print(fnt22, 32, 34, lang_lines.Sega_Master_System, white)
        elseif showCat == 18 then Font.print(fnt22, 32, 34, lang_lines.Sega_Game_Gear, white)        
        elseif showCat == 19 then Font.print(fnt22, 32, 34, lang_lines.TurboGrafx_16, white)
        elseif showCat == 20 then Font.print(fnt22, 32, 34, lang_lines.TurboGrafx_CD, white)
        elseif showCat == 21 then Font.print(fnt22, 32, 34, lang_lines.PC_Engine, white)
        elseif showCat == 22 then Font.print(fnt22, 32, 34, lang_lines.PC_Engine_CD, white)
        elseif showCat == 23 then Font.print(fnt22, 32, 34, lang_lines.Amiga, white)
        elseif showCat == 24 then Font.print(fnt22, 32, 34, lang_lines.ScummVM, white)
        elseif showCat == 25 then Font.print(fnt22, 32, 34, lang_lines.Commodore_64, white)
        elseif showCat == 26 then Font.print(fnt22, 32, 34, lang_lines.WonderSwan_Color, white)
        elseif showCat == 27 then Font.print(fnt22, 32, 34, lang_lines.WonderSwan, white)
        elseif showCat == 28 then Font.print(fnt22, 32, 34, lang_lines.PICO8, white)
        elseif showCat == 29 then Font.print(fnt22, 32, 34, lang_lines.MSX2, white)
        elseif showCat == 30 then Font.print(fnt22, 32, 34, lang_lines.MSX, white)
        elseif showCat == 31 then Font.print(fnt22, 32, 34, lang_lines.ZX_Spectrum, white)
        elseif showCat == 32 then Font.print(fnt22, 32, 34, lang_lines.Atari_7800, white)
        elseif showCat == 33 then Font.print(fnt22, 32, 34, lang_lines.Atari_5200, white)
        elseif showCat == 34 then Font.print(fnt22, 32, 34, lang_lines.Atari_2600, white)
        elseif showCat == 35 then Font.print(fnt22, 32, 34, lang_lines.Atari_Lynx, white)
        elseif showCat == 36 then Font.print(fnt22, 32, 34, lang_lines.ColecoVision, white)
        elseif showCat == 37 then Font.print(fnt22, 32, 34, lang_lines.Vectrex, white)
        elseif showCat == 38 then Font.print(fnt22, 32, 34, lang_lines.FBA_2012, white)
        elseif showCat == 39 then Font.print(fnt22, 32, 34, lang_lines.MAME_2003Plus, white)
        elseif showCat == 40 then Font.print(fnt22, 32, 34, lang_lines.MAME_2000, white)
        elseif showCat == 41 then Font.print(fnt22, 32, 34, lang_lines.Neo_Geo, white)
        elseif showCat == 42 then Font.print(fnt22, 32, 34, lang_lines.Neo_Geo_Pocket_Color, white)
        elseif showCat == 43 then Font.print(fnt22, 32, 34, lang_lines.System_Apps, white)  
        elseif showCat == 44 then Font.print(fnt22, 32, 34, lang_lines.Favorites, white)
        elseif showCat == 45 then Font.print(fnt22, 32, 34, lang_lines.Recently_Played, white)
        elseif showCat == 46 then
            if random_game_selected == false then
                Font.print(fnt22, 32, 34, lang_lines.Search_Results, white)
            else
                Font.print(fnt22, 32, 34, lang_lines.Random_Game, white)
            end            
        elseif showCat >= 47 and showCat <= collection_syscount then Collection_CatNum = showCat - 46 Font.print(fnt22, 32, 34, collection_files[Collection_CatNum].display_name, white)

        else Font.print(fnt22, 32, 34, lang_lines.All, white)
        end
    
        if showView ~= 2 then
            if showView == 5 then
                Font.print(fnt22, fv_left_margin - fv_border, fv_cover_height + fv_cover_y + 30, app_title, white)
            elseif showView == 6 then
            else
                Graphics.fillRect(0, 960, 424, 496, black)-- black footer bottom
                PrintCentered(fnt25, 480, 430, app_title, white, 25)-- Draw title
            end
        else
            Graphics.fillRect(0, 960, 496, 544, themeCol)-- footer bottom
            
            -- Add gradient to mask out long names so they don't crash into the footer controls 
            Font.print(fnt22, 24, 506, app_title, white)
            Graphics.drawImage(900-(btnMargin * 8)-label1-label2-label3-label4, 496, footer_gradient, themeCol)
            Graphics.fillRect(900-(btnMargin * 8)-label1-label2-label3-label4+48, 960, 496, 544, themeCol)
        end

        

        Graphics.drawImage(900-label1, 510, btnX)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Launch, white)--Launch

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnT)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Details, white)--Details

        Graphics.drawImage(900-(btnMargin * 4)-label1-label2-label3, 510, btnS)
        Font.print(fnt20, 900+28-(btnMargin * 4)-label1-label2-label3, 508, lang_lines.Category, white)--Category

        if setChangeViews == 1 then
            Graphics.drawImage(900-(btnMargin * 6)-label1-label2-label3-label4, 510, btnO)
            Font.print(fnt20, 900+28-(btnMargin * 6)-label1-label2-label3-label4, 508, lang_lines.View, white)--View
        end
        
        -- Draw Covers
        base_x = 0
        
        if showCat == 44 then
            -- count favorites
            create_fav_count_table(files_table)
            
            drawCategory (fav_count)
            GetNameAndAppTypeSelected() -- Added to refresh names as games removed from fav cat whilst on fav cat

        else
            drawCategory (xCatLookup(showCat))
        end


        -- Smooth move items horizontally
        if targetX ~= base_x then
            if smoothScrolling == 1 then
                if showView == 5 then
                    -- Smooth scrolling disabled until can improve
                    -- targetX = targetX - ((targetX - base_x) * 0.25)
                    targetX = targetX - ((targetX - base_x) * 1)
                else
                    targetX = targetX - ((targetX - base_x) * 0.17)
                end
            else
                targetX = targetX - ((targetX - base_x) * 0.1)
            end
        end


        if smoothScrolling == 1 then
            -- Smooth dezoom factor
            if mx < 64 or mx > 180 then -- Don't zoom on covers if quick scrolling
                quick_scrolling_factor_goal = 1
            else
                quick_scrolling_factor_goal = 0
            end

            if quick_scrolling_factor ~= quick_scrolling_factor_goal then
                quick_scrolling_factor = quick_scrolling_factor - ((quick_scrolling_factor - quick_scrolling_factor_goal) * 0.17)
            end
        end

        -- Instantly move to selection
        if startCovers == false then
            targetX = base_x
            startCovers = true
            GetNameAndAppTypeSelected()
        end
        
        if setReflections==1 then
            floorY = 0
            if showView == 2 then
                floorY = -0.6
            elseif showView == 3 then
                floorY = -0.3
            end
            --Draw half transparent floor for reflection effect
            if showView <= 4 then
                Render.drawModel(modFloor, 0, -0.6+floorY, 0, 0, 0, 0)
            end
        end
        
        prevX = 0
        prevZ = 0
        prevRot = 0
        inPreview = false

-- MENU 1 - GET INFO
    elseif showMenu == 1 then
        
        -- PREVIEW
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select
        label3 = Font.getTextWidth(fnt20, lang_lines.Options)--Options
        -- label4 = Font.getTextWidth(fnt20, lang_lines.Favorite)--Favourite

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.drawImage(900-(btnMargin * 4)-label1-label2-label3, 510, btnT)
        Font.print(fnt20, 900+28-(btnMargin * 4)-label1-label2-label3, 508, lang_lines.Options, white)--Options
        
        if wide_getinfoscreen == true then
            Graphics.fillRect(24, 470+24, 24, 470, darkalpha)
        else
            Graphics.fillRect(24, 470, 24, 470, darkalpha)
        end

        Render.setCamera(0, 0, 0, 0.0, 0.0, 0.0)
        if inPreview == false then
            if not pcall(loadImage, icon_path) then
                iconTmp = imgCoverTmp
            else
                iconTmp = Graphics.loadImage(icon_path)
            end
            -- set pic0 as background
            if System.doesFileExist(pic_path) and Game_Backgrounds >= 1 then
                Graphics.freeImage(backTmp)
                backTmp = Graphics.loadImage(pic_path)
                Graphics.setImageFilters(backTmp, FILTER_LINEAR, FILTER_LINEAR)
                Render.useTexture(modBackground, backTmp)
            else
                Render.useTexture(modBackground, imgCustomBack)
            end
            
            if folder == true then
                if System.doesDirExist(appdir) then
                    game_size, _, app_size = getAppSize(appdir)

                elseif xCatLookup(showCat)[p] and xCatLookup(showCat)[p].app_type == 2 and xCatLookup(showCat)[p].category == "MG" then
                    -- Fix for psp homebrew eboots, get parent directory of EBOOT.PBP
                    local mg_dir = appdir:lower():match("(.+)/eboot%.pbp$")
                    if mg_dir and System.doesDirExist(mg_dir) then
                        game_size, _, app_size = getAppSize(mg_dir)
                    else
                        game_size = "0 B"
                        app_size = 0
                    end
                else
                    game_size = "0 B"
                    app_size = 0
                end
            else
                if string.find(filename, "%.cue") or string.find(filename, "%.gdi") then
                    -- Get game directory by trimming filename from gamepath
                    filename_len = string.len (filename)
                    game_path_len = string.len (appdir)
                    directory_len = game_path_len - filename_len -1
                    game_directory_path = string.sub(appdir, 1, directory_len)

                    if System.doesDirExist(game_directory_path) then
                        game_size, _, app_size = getAppSize(game_directory_path)
                    else
                        game_size = "0 B"
                        app_size = 0
                    end

                else
                    getRomSize()  -- Sets game_size and app_size globals
                end

            end

            -- Get current app version for Vita and Homebrew
            if apptype <= 1 then 
                local sfo_path = appdir .. "/sce_sys/param.sfo"
                if System.doesFileExist(sfo_path) then

                    -- Try to extract the SFO file safely
                    local sfo_read, info = pcall(System.extractSfo, sfo_path)

                    if not sfo_read then
                        sfo_read_success = false
                    else
                        sfo_read_success = true
                    end

                    if sfo_read_success == true then
                        -- app_version = tostring(info.version) or xCatLookup(showCat)[p].version
                        app_version = tostring(info.version) or xCatLookup(showCat)[p].version
                    else
                    end

                end
            else
            end
            
            menuY=0
            tmpappcat=0
            tmpimagecat=0
            inPreview = true
        end
        
        -- animate cover zoom in
        if prevX < 1.4 then
            prevX = prevX + 0.1
        end
        if prevZ < 1 then
            prevZ = prevZ + 0.06
        end
        if prevRot > -0.6 then
            prevRot = prevRot - 0.04
        end
        
        
        -- Rescale icon images to 128px x 128px

        -- Get sizes
        original_w = Graphics.getImageWidth(iconTmp)
        original_h = Graphics.getImageHeight(iconTmp)

        -- Calculate ratio size to use
        if original_w == 128 then ratio_w = 1.0 else ratio_w = 128 / original_w end
        if original_h == 128 then ratio_h = 1.0 else ratio_h = 128 / original_h end

        -- Draw resized image  
        Graphics.drawScaleImage(50, 50, iconTmp, ratio_w, ratio_h)

        -- txtname = string.sub(app_title, 1, 32) .. "\n" .. string.sub(app_title, 33)
        txtname = wraptextlength(app_title, 32)
        
        
        
        function set_cover_image (def_table_name)
            --Graphics.setImageFilters(games_table[p].icon, FILTER_LINEAR, FILTER_LINEAR)
            if (def_table_name)[p].ricon ~= nil then

                local box_width = Graphics.getImageWidth((def_table_name)[p].ricon)
                local box_height = Graphics.getImageHeight((def_table_name)[p].ricon)
                local box_pixel_combined = box_height + box_width
                box_height_dif = (box_height / box_pixel_combined) * 100

                Render.useTexture(modCoverNoref, (def_table_name)[p].ricon) -- games_table
                Render.useTexture(modCoverHbrNoref, (def_table_name)[p].ricon) -- homebrews_table
                Render.useTexture(modCoverPSPNoref, (def_table_name)[p].ricon) -- psp_table
                Render.useTexture(modCoverPSXNoref, (def_table_name)[p].ricon) -- psx_table
                Render.useTexture(modCoverN64Noref, (def_table_name)[p].ricon) -- n64_table
                Render.useTexture(modCoverN64Noref, (def_table_name)[p].ricon) -- snes_table
                Render.useTexture(modCoverNESNoref, (def_table_name)[p].ricon) -- nes_table
                Render.useTexture(modCoverGBNoref, (def_table_name)[p].ricon) -- nds_table
                Render.useTexture(modCoverGBNoref, (def_table_name)[p].ricon) -- gba_table
                Render.useTexture(modCoverGBNoref, (def_table_name)[p].ricon) -- gbc_table
                Render.useTexture(modCoverGBNoref, (def_table_name)[p].ricon) -- gb_table
                Render.useTexture(modCoverGBNoref, (def_table_name)[p].ricon) -- dreamcast_table
                Render.useTexture(modCoverNESNoref, (def_table_name)[p].ricon) -- sega_cd_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- 32x_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- md_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- sms_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- gg_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- tg16_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- tgcd_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- pce_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- pcecd_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- amiga_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].ricon) -- c64_table
                Render.useTexture(modCoverNESNoref, (def_table_name)[p].ricon) -- wswan_col_table
                Render.useTexture(modCoverNESNoref, (def_table_name)[p].ricon) -- wswan_table
                Render.useTexture(modCoverLYNXNoref, (def_table_name)[p].ricon) -- pico8_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].ricon) -- msx2_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].ricon) -- msx1_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].ricon) -- zxs_table
                Render.useTexture(modCoverATARINoref, (def_table_name)[p].ricon) -- atari_7800_table
                Render.useTexture(modCoverATARINoref, (def_table_name)[p].ricon) -- atari_5200_table
                Render.useTexture(modCoverATARINoref, (def_table_name)[p].ricon) -- atari_2600_table
                Render.useTexture(modCoverLYNXNoref, (def_table_name)[p].ricon) -- atari_lynx_table
                Render.useTexture(modCoverATARINoref, (def_table_name)[p].ricon) -- colecovision_table
                Render.useTexture(modCoverATARINoref, (def_table_name)[p].ricon) -- vectrex_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- fba_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- mame_2003_plus_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- mame_2000_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- neogeo_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- ngpc_table
                Render.useTexture(modCoverHbrNoref, (def_table_name)[p].ricon) -- psm_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- scummvm_table
                Render.useTexture(modCoverHbrNoref, (def_table_name)[p].ricon) -- sysapps_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- fav_count
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- recently played
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- search

                Render.useTexture(modCoverSNESJapanNoref, (def_table_name)[p].ricon) -- Snes Japan
                Render.useTexture(modCoverMiddleNoref, (def_table_name)[p].ricon) -- Middle

            else 

                local box_width = Graphics.getImageWidth((def_table_name)[p].icon)
                local box_height = Graphics.getImageHeight((def_table_name)[p].icon)
                local box_pixel_combined = box_height + box_width
                box_height_dif = (box_height / box_pixel_combined) * 100

                Render.useTexture(modCoverNoref, (def_table_name)[p].icon) -- games_table
                Render.useTexture(modCoverHbrNoref, (def_table_name)[p].icon) -- homebrews_table
                Render.useTexture(modCoverPSPNoref, (def_table_name)[p].icon) -- psp_table
                Render.useTexture(modCoverPSXNoref, (def_table_name)[p].icon) -- psx_table
                Render.useTexture(modCoverN64Noref, (def_table_name)[p].icon) -- n64_table
                Render.useTexture(modCoverN64Noref, (def_table_name)[p].icon) -- snes_table
                Render.useTexture(modCoverNESNoref, (def_table_name)[p].icon) -- nes_table
                Render.useTexture(modCoverGBNoref, (def_table_name)[p].icon) -- nds_table
                Render.useTexture(modCoverGBNoref, (def_table_name)[p].icon) -- gba_table
                Render.useTexture(modCoverGBNoref, (def_table_name)[p].icon) -- gbc_table
                Render.useTexture(modCoverGBNoref, (def_table_name)[p].icon) -- gb_table
                Render.useTexture(modCoverGBNoref, (def_table_name)[p].icon) -- dreamcast_table
                Render.useTexture(modCoverNESNoref, (def_table_name)[p].icon) -- sega_cd_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- 32x_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- md_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- sms_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- gg_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- tg16_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- tgcd_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- pce_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- pcecd_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- amiga_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].icon) -- c64_table
                Render.useTexture(modCoverNESNoref, (def_table_name)[p].icon) -- wswan_col_table
                Render.useTexture(modCoverNESNoref, (def_table_name)[p].icon) -- wswan_table
                Render.useTexture(modCoverLYNXNoref, (def_table_name)[p].icon) -- pico8_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].icon) -- msx2_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].icon) -- msx1_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].icon) -- zxs_table
                Render.useTexture(modCoverATARINoref, (def_table_name)[p].icon) -- atari_7800_table
                Render.useTexture(modCoverATARINoref, (def_table_name)[p].icon) -- atari_5200_table
                Render.useTexture(modCoverATARINoref, (def_table_name)[p].icon) -- atari_2600_table
                Render.useTexture(modCoverLYNXNoref, (def_table_name)[p].icon) -- atari_lynx_table
                Render.useTexture(modCoverATARINoref, (def_table_name)[p].icon) -- colecovision_table
                Render.useTexture(modCoverATARINoref, (def_table_name)[p].icon) -- vectrex_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- fba_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- mame_2003_plus_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- mame_2000_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- neogeo_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- ngpc_table
                Render.useTexture(modCoverHbrNoref, (def_table_name)[p].icon) -- psm_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- scummvm_table
                Render.useTexture(modCoverHbrNoref, (def_table_name)[p].icon) -- sysapps_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- fav_count
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- recently played
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- search

                Render.useTexture(modCoverSNESJapanNoref, (def_table_name)[p].icon) -- Snes Japan
                Render.useTexture(modCoverMiddleNoref, (def_table_name)[p].icon) -- Middle


            end
        end
        
        -- Set cover image
        set_cover_image (xCatLookup(showCat))

        function closestBoxNoref_getinfo()

            if      box_height_dif >= 59                                then return modCoverSNESJapanNoref   -- Average approx 62.83
            elseif  box_height_dif >= 58     and box_height_dif < 59    then return modCoverMDNoref          -- Average approx 58.5
            elseif  box_height_dif >= 57     and box_height_dif < 58    then return modCoverNESNoref         -- Average approx 57.87
            elseif  box_height_dif >= 55     and box_height_dif < 57    then return modCoverATARINoref       -- Average approx 57.66
            elseif  box_height_dif >= 54     and box_height_dif < 55    then return modCoverLYNXNoref        -- Average approx 54.51
            elseif  box_height_dif >= 52     and box_height_dif < 54    then return modCoverMiddleNoref      -- Average approx 52
            elseif  box_height_dif >= 48     and box_height_dif < 52    then return modCoverGBNoref          -- Average approx 50.00
            else
                if apptype==5 or apptype==6 then
                    return  modCoverN64Noref -- Average approx 42.31
                else
                    return modCoverGBNoref
                end
            end
        end
        
        local tmpapptype=""
        local tmpcatText=""
        local tmpimageText=""
        -- Draw box
        if apptype==1 then
            Render.drawModel(modCoverNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            Render.drawModel(modBoxNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.PS_Vita_Game 
        elseif apptype==2 then
            Render.drawModel(modCoverPSPNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            Render.drawModel(modBoxPSPNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.PSP_Game 
        elseif apptype==3 then
            Render.drawModel(modCoverPSXNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            Render.drawModel(modBoxPSXNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.PS1_Game 
        elseif apptype==5 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.N64_Game 
        elseif apptype==6 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.SNES_Game 
        elseif apptype==7 then
            Render.drawModel(modCoverNESNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.NES_Game 
        elseif apptype==8 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.GBA_Game 
        elseif apptype==9 then
            Render.drawModel(modCoverGBNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.GBC_Game 
        elseif apptype==10 then
            Render.drawModel(modCoverGBNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.GB_Game
        elseif apptype==11 then
            Render.drawModel(modCoverGBNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.DC_Game
        elseif apptype==12 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.SCD_Game 
        elseif apptype==13 then
            Render.drawModel(modCoverMDNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.S32X_Game 
        elseif apptype==14 then
            Render.drawModel(modCoverMDNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.MD_Game 
        elseif apptype==15 then
            Render.drawModel(modCoverMDNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.SMS_Game 
        elseif apptype==16 then
            Render.drawModel(modCoverMDNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.GG_Game 
        elseif apptype==17 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.TurboGrafx_16_Game 
        elseif apptype==18 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.TurboGrafx_CD_Game 
        elseif apptype==19 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.PC_Engine_Game 
        elseif apptype==20 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.PC_Engine_CD_Game
        elseif apptype==21 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.Amiga_Game
        elseif apptype==22 then
            -- Render.drawModel(modCoverTAPENoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            Render.drawModel(modCoverMDNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.C64_Game
        elseif apptype==23 then
            Render.drawModel(modCoverNESNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.WSWANCOL_Game
        elseif apptype==24 then
            Render.drawModel(modCoverNESNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.WSWAN_Game
        elseif apptype==25 then
            -- Render.drawModel(modCoverTAPENoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            Render.drawModel(modCoverMDNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.MSX2_Game
        elseif apptype==26 then
            -- Render.drawModel(modCoverTAPENoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            Render.drawModel(modCoverMDNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.MSX_Game
        elseif apptype==27 then
            -- Render.drawModel(modCoverTAPENoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            Render.drawModel(modCoverMDNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.ZXS_Game
        elseif apptype==28 then
            Render.drawModel(modCoverATARINoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.A7800_Game
        elseif apptype==29 then
            Render.drawModel(modCoverATARINoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.A5200_Game
        elseif apptype==30 then
            Render.drawModel(modCoverATARINoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.A600_Game
        elseif apptype==31 then
            Render.drawModel(modCoverLYNXNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.LYNX_Game
        elseif apptype==32 then
            Render.drawModel(modCoverATARINoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.COLECO_Game
        elseif apptype==33 then
            Render.drawModel(modCoverATARINoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.VECTREX_Game
        elseif apptype==34 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.FBA2012_Game
        elseif apptype==35 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.MAME2003_Game 
        elseif apptype==36 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.MAME_2000_Game 
        elseif apptype==37 then
            Render.drawModel(modCoverMDNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.Neo_Geo_Game 
        elseif apptype==38 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.Neo_Geo_Pocket_Color_Game 
        elseif apptype==39 then
            Render.drawModel(modCoverHbrNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.Playstation_Mobile_Game
        elseif apptype==40 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.ScummVM_Game
        elseif apptype==41 then
            Render.drawModel(modCoverLYNXNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.PICO8_Game
        elseif apptype==42 then
            Render.drawModel(modCoverHbrNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.System_App
        elseif apptype==43 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.NDS_Game 
        else
            Render.drawModel(modCoverHbrNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.Homebrew 
        end
    
        Font.print(fnt22, 50, 190, txtname, white)-- app name


        -- Show fav icon if game if a favourite
        if favourite_flag == true then
            if wide_getinfoscreen == true then
                Graphics.drawImage(420+24, 50, imgFavorite_large_on)
            else
                Graphics.drawImage(420, 50, imgFavorite_large_on)
            end
        else
            if wide_getinfoscreen == true then
                Graphics.drawImage(420+24, 50, imgFavorite_large_off)
            else
                Graphics.drawImage(420, 50, imgFavorite_large_off)
            end
        end

        if hide_game_flag == true then
            if wide_getinfoscreen == true then
                Graphics.drawImage(380+24, 50, imgHidden_large_on)
            else
                Graphics.drawImage(380, 50, imgHidden_large_on)
            end
        else
        end


        -- 0 Homebrew, 1 vita, 2 psp, 3 psx, 5+ Retro, 34 FBA, 35 Mame 2003+, 36 Mame 2000, 37 NeoGeo, 39 ps mobile

        -- if apptype == 0 or apptype == 1 or apptype == 2 or apptype == 3 or apptype == 39 then
        if apptype == 0 or apptype == 1 or apptype == 39 then
            if string.match (game_path, "pspemu") or string.match (game_path, "ux0:/app/") or string.match (game_path, "ux0:/psm/") then
                Font.print(fnt22, 50, 240, tmpapptype .. "\n" .. lang_lines.App_ID_colon .. app_titleid .. "\n" .. lang_lines.Version_colon .. app_version .. "\n" .. lang_lines.Size_colon .. game_size, white)-- Draw info
                --                                               App ID:                                           Version:                                           Size:
            else
                Font.print(fnt22, 50, 240, tmpapptype .. "\n" .. lang_lines.Version_colon .. app_version .. "\n" .. lang_lines.Size_colon .. game_size, white)-- Draw info
                --                                               Version:                                           Size:
            end
        elseif apptype == 2 or apptype == 3 or apptype == 40 then -- Version removed for psp and psx and scummvm 
            Font.print(fnt22, 50, 240, tmpapptype .. "\n" .. lang_lines.App_ID_colon .. app_titleid .. "\n" .. lang_lines.Size_colon .. game_size, white)-- Draw info

        elseif apptype == 34 or apptype == 35 or apptype == 36 or apptype == 37 or apptype == 41 then 
            Font.print(fnt22, 50, 240, tmpapptype .. "\n" .. lang_lines.Size_colon .. game_size, white)-- Draw info
                --                                           Size:
        elseif apptype == 42 then -- Sys app
            Font.print(fnt22, 50, 240, tmpapptype .. "\n" .. lang_lines.App_ID_colon .. app_titleid, white)-- Draw info
        else
            Font.print(fnt22, 50, 240, tmpapptype .. "\n" .. lang_lines.Version_colon .. app_version .. "\n" .. lang_lines.Size_colon .. game_size, white)-- Draw info
            --                                               Version:                                           Size:
        end


        if tmpappcat==1 then
            tmpcatText = "PS Vita"
        elseif tmpappcat==2 then
            tmpcatText = "PSP"
        elseif tmpappcat==3 then
            tmpcatText = "PS1"
        elseif tmpappcat==4 then
            tmpcatText = lang_lines.Homebrew -- "Homebrew"
        else
            tmpcatText = lang_lines.Default -- Default
        end


        -- Download background - don't show on vita or homebrew

        if apptype == 0 or apptype == 1 then
            tmpimageText = lang_lines.Download_Cover
        elseif apptype == 39 or apptype == 41 or apptype == 42 then
            -- don't show anything for ps mobile, pico8 and sys apps
        else
            if tmpimagecat==1 then
                tmpimageText = lang_lines.Download_Background -- Backgrounds
            else
                tmpimageText = lang_lines.Download_Cover -- Covers
            end
        end

        -- Override not shown for retro & retroarch ps1
        if apptype == 0 or apptype == 1 or apptype == 2 or apptype == 3 then
            if string.match (game_path, "pspemu") or string.match (game_path, "ux0:/app/") then
                menuItems = 1
            else
                menuItems = 0
            end
        else
            menuItems = 0
        end


        -- 0 Homebrew, 1 Vita, 2 PSP, 3 PSX, 5+ Retro

        -- Vita and Homebrew
        -- if folder == true then -- start Disable category override for retro
        if apptype == 0 or apptype == 1 or apptype == 2 or apptype == 3 
        and string.match (game_path, "pspemu") 
        or string.match (game_path, "ux0:/app/") then
             -- start Disable category override for retro
            if menuY==1 then
                if wide_getinfoscreen == true then
                    Graphics.fillRect(24, 470+24, 350 + (menuY * 40), 430 + (menuY * 40), themeCol)-- selection two lines
                else
                    Graphics.fillRect(24, 470, 350 + (menuY * 40), 430 + (menuY * 40), themeCol)-- selection two lines
                end
            else
                if wide_getinfoscreen == true then
                    Graphics.fillRect(24, 470+24, 350 + (menuY * 40), 390 + (menuY * 40), themeCol)-- selection
                else
                    Graphics.fillRect(24, 470, 350 + (menuY * 40), 390 + (menuY * 40), themeCol)-- selection
                end
            end

            if setSwap_X_O_buttons == 1 then 
                -- Swap buttons is - On
                Press_Button_to_apply_Category = tostring(lang_lines.Press_O_to_apply_Category)
            else 
                -- Swap buttons is - Off
                Press_Button_to_apply_Category = tostring(lang_lines.Press_X_to_apply_Category)
            end

            -- Wrap text for wider languages: German, French, Russian, Portuguese, Dutch, Turkish, Hungarian, Portuguese (Brasil)
            if setLanguage == 2 or setLanguage == 3 or setLanguage == 6 or setLanguage == 8 or setLanguage == 12 or setLanguage == 16 or setLanguage == 20 or setLanguage == 21 then
                Font.print(fnt22, 50, 352+40, lang_lines.Override_Category_colon.. "\n< " .. tmpcatText .. " >\n( " .. Press_Button_to_apply_Category .. ")", white)
            else
                Font.print(fnt22, 50, 352+50, lang_lines.Override_Category_colon.. "< " .. tmpcatText .. " >\n( " .. Press_Button_to_apply_Category .. ")", white)
            end


        -- All other systems
        elseif apptype == 39 or apptype == 41 or apptype == 42 then
            -- dont show anything
        else
            if menuY==1 then
            else
                if wide_getinfoscreen == true then
                    Graphics.fillRect(24, 470+24, 350 + (menuY * 40), 390 + (menuY * 40), themeCol)-- selection
                else
                    Graphics.fillRect(24, 470, 350 + (menuY * 40), 390 + (menuY * 40), themeCol)-- selection
                end
            end
            -- Font.print(fnt22, 50, 352+3, "< " .. tmpimageText .. " >", white)
        end

        -- Download background - don't show on vita, homebrew or ps mobile or pico8 or sys app
        if apptype == 0 or apptype == 1 or apptype == 39  or apptype == 41  or apptype == 42 then
            Font.print(fnt22, 50, 352+3, tmpimageText, white)
        else
            Font.print(fnt22, 50, 352+3, "< " .. tmpimageText .. " >", white)
        end
        

        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then
                if menuY == 0 then
                    if tmpimagecat==0 then
                        if gettingCovers == false then
                            gettingCovers = true

                            if setCRCScan == 1 then
    
                                -- Create temporary file for Onelua to recognise as an instruction (OneLua will delete it after finding)
                                -- Covers
                                if not System.doesFileExist(cur_dir .. "/TITLES/missing_covers.lua") then
                                    local file_over = System.openFile(cur_dir .. "/TITLES/missing_covers.lua", FCREATE)
                                    System.writeFile(file_over, " ", 1)
                                    System.closeFile(file_over)
                                end

                                -- Relaunch so OneLua eboot can check file CRC's and download artwork
                                FreeIcons()
                                FreeMemory()
                                System.launchEboot("app0:/launch_scan.bin")
                            else
                                DownloadSingleCover()
                            end

                        end
                    else
                        if gettingBackgrounds == false then
                            gettingBackgrounds = true

                            if setCRCScan == 1 then
                                -- Create temporary file for Onelua to recognise as an instruction (OneLua will delete it after finding)
                                -- Backgrounds
                                if not System.doesFileExist(cur_dir .. "/TITLES/missing_snaps.lua") then
                                    local file_over = System.openFile(cur_dir .. "/TITLES/missing_snaps.lua", FCREATE)
                                    System.writeFile(file_over, " ", 1)
                                    System.closeFile(file_over)
                                end

                                -- Relaunch so OneLua eboot can check file CRC's and download artwork
                                FreeIcons()
                                FreeMemory()
                                System.launchEboot("app0:/launch_scan.bin")
                            else
                                DownloadSingleSnap()
                            end
                            
                        end
                    end
                elseif menuY == 1 then
                    OverrideCategory()
                end

            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                if menuY > 0 then
                    menuY = menuY - 1
                    else
                    menuY=menuItems
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                if menuY < menuItems then
                    menuY = menuY + 1
                    else
                    menuY=0
                end
            elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then
                if menuY==0 then
                    -- Image downloads - cover or background
                    if apptype == 0 or apptype == 1 then
                        tmpimagecat=0
                    else
                        if tmpimagecat > 0 then
                            tmpimagecat = tmpimagecat - 1
                        else
                            tmpimagecat=1
                        end
                    end
                end

                if menuY==1 then
                    -- Vita and Homebrew override
                    if tmpappcat > 0 then
                        tmpappcat = tmpappcat - 1
                    else
                        tmpappcat=4 -- Limited to 4
                    end
                end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
                if menuY==0 then
                    -- Image downloads - cover or background
                    if apptype == 0 or apptype == 1 then
                        tmpimagecat=0
                    else
                        if tmpimagecat > 0 then
                            tmpimagecat = tmpimagecat - 1
                        else
                            tmpimagecat=1
                        end
                    end
                end

                if menuY==1 then
                    -- Vita and Homebrew override
                    if tmpappcat < 4 then  -- Limited to 4
                        tmpappcat = tmpappcat + 1
                    else
                        tmpappcat=0
                    end
                end

            end
        end

-- MENU 2 - SETTINGS
    elseif showMenu == 2 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select
        label3 = Font.getTextWidth(fnt20, lang_lines.Help_and_Guides)--Help and Guides
        label_lang = Font.getTextWidth(fnt20, lang_lines.Language_colon) + 12 --Language


        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.drawImage(900-(btnMargin * 4)-label1-label2-label3, 510, btnT)
        Font.print(fnt20, 900+28-(btnMargin * 4)-label1-label2-label3, 508, lang_lines.Help_and_Guides, white)--Help and Guides

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.Settings, white)--SETTINGS
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection

        menuItems = 7
        
        -- MENU 2 / #0 Search
        Graphics.drawImage(setting_x_icon, setting_y0, setting_icon_search)
        Font.print(fnt22, setting_x_icon_offset, setting_y0, lang_lines.Search, white)--Search
        
        -- MENU 2 / #1 Categories
        Graphics.drawImage(setting_x_icon, setting_y1, setting_icon_categories)
        Font.print(fnt22, setting_x_icon_offset, setting_y1, lang_lines.Categories, white)--Categories

        -- MENU 2 / #2 Appearance
        Graphics.drawImage(setting_x_icon, setting_y2, setting_icon_theme)
        Font.print(fnt22, setting_x_icon_offset, setting_y2, lang_lines.Theme, white)--Theme

        -- MENU 2 / #3 Audio
        Graphics.drawImage(setting_x_icon, setting_y3, setting_icon_sounds)
        Font.print(fnt22, setting_x_icon_offset, setting_y3, lang_lines.Audio, white)--Audio

        -- MENU 2 / #4 Artwork
        Graphics.drawImage(setting_x_icon, setting_y4, setting_icon_artwork)
        Font.print(fnt22, setting_x_icon_offset, setting_y4, lang_lines.Artwork, white)--Artwork

        -- MENU 2 / #5 Scanning
        Graphics.drawImage(setting_x_icon, setting_y5, setting_icon_scanning)
        Font.print(fnt22, setting_x_icon_offset, setting_y5, lang_lines.Scan_Settings, white)--Scanning

        -- MENU 2 / #6 Other Settings
        Graphics.drawImage(setting_x_icon, setting_y6, setting_icon_other)
        Font.print(fnt22, setting_x_icon_offset, setting_y6, lang_lines.Other_Settings, white)--Other Settings

        -- MENU 2 / #7 Language
        Graphics.drawImage(setting_x_icon, setting_y7, setting_icon_language)
        Font.print(fnt22, setting_x_icon_offset, setting_y7, lang_lines.Language_colon, white)--Language

        -- MENU 2 / #7 Language 
        if chooseLanguage == 1 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "Deutsch", white) -- German
            
        elseif chooseLanguage == 2 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "English (United Kingdom)", white) -- English (United Kingdom)

            -- Megadrive, update regional missing cover
            for k, v in pairs(md_table) do
                  if v.icon_path=="app0:/DATA/missing_cover_md_usa.png" then
                      v.icon_path="app0:/DATA/missing_cover_md.png"
                  end
            end
            -- Dreamcast, update regional missing cover - Blue logo
            for k, v in pairs(dreamcast_table) do
                  if v.icon_path=="app0:/DATA/missing_cover_dreamcast_usa.png" or v.icon_path=="app0:/DATA/missing_cover_dreamcast_j.png" then
                      v.icon_path="app0:/DATA/missing_cover_dreamcast_eur.png"
                  end
            end

        elseif chooseLanguage == 3 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "English (United States)", white) -- English (United States)
            -- Megadrive, update regional missing cover
            for k, v in pairs(md_table) do
                  if v.icon_path=="app0:/DATA/missing_cover_md.png" then
                      v.icon_path="app0:/DATA/missing_cover_md_usa.png"
                  end
            end
            -- Dreamcast, update regional missing cover - USA - Red logo
            for k, v in pairs(dreamcast_table) do 
                  if v.icon_path=="app0:/DATA/missing_cover_dreamcast_eur.png" or v.icon_path=="app0:/DATA/missing_cover_dreamcast_j.png" then
                      v.icon_path="app0:/DATA/missing_cover_dreamcast_usa.png"
                  end
            end

        elseif chooseLanguage == 4 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "Español", white) -- Spanish
        elseif chooseLanguage == 5 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, " Français", white) -- French
        elseif chooseLanguage == 6 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "Italiano", white) -- Italian
        elseif chooseLanguage == 7 then
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "Magyar", white) -- Hungarian
        elseif chooseLanguage == 8 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "Nederlands", white) -- Dutch
        elseif chooseLanguage == 9 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "Norsk", white) -- Norwegian
        elseif chooseLanguage == 10 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "Polski", white) -- Polish
        elseif chooseLanguage == 11 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "Português (Brasil)", white) -- Portuguese (Brasil)
        elseif chooseLanguage == 12 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "Português (Portugal)", white) -- Portuguese
        elseif chooseLanguage == 13 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "Pусский", white) -- Russian
        elseif chooseLanguage == 14 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "Suomi", white) -- Finnish
        elseif chooseLanguage == 15 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "Svenska", white) -- Swedish
        elseif chooseLanguage == 16 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "Türkçe", white) -- Turkish
        elseif chooseLanguage == 17 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "日本語", white) -- Japanese
            -- Dreamcast, update regional missing cover - Japan - Orange logo
            for k, v in pairs(dreamcast_table) do
                  if v.icon_path=="app0:/DATA/missing_cover_dreamcast_eur.png" or v.icon_path=="app0:/DATA/missing_cover_dreamcast_usa.png" then
                      v.icon_path="app0:/DATA/missing_cover_dreamcast_j.png"
                  end
            end
        elseif chooseLanguage == 18 then
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "琉球語派", white) -- Japanese (Ryukyuan) 
        elseif chooseLanguage == 19 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "한국어", white) -- Korean
        elseif chooseLanguage == 20 then
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "简体中文", white) -- Chinese (Simplified)
        elseif chooseLanguage == 21 then 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "繁體中文", white) -- Chinese (Traditional)    
        else 
            Font.print(fnt22, setting_x_icon_offset + label_lang, setting_y7, "Dansk", white) -- Danish            
        end

        
        -- MENU 2 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 2 / #0 Search
                if menuY == 0 then
                    -- Search
                    if hasTyped==false then
                        Keyboard.start(tostring(lang_lines.Search), "", 512, TYPE_LATIN, MODE_TEXT)
                        hasTyped=true
                        keyboard_search=true
                    end
                elseif menuY == 1 then -- Categories
                    showMenu = 3 
                    menuY = 0
                elseif menuY == 2 then -- Theme
                    showMenu = 4 
                    menuY = 0
                elseif menuY == 3 then -- Audio
                    showMenu = 12 
                    menuY = 0
                elseif menuY == 4 then -- Artwork
                    showMenu = 5 
                    menuY = 0
                elseif menuY == 5 then -- Scan Settings
                    showMenu = 6 
                    menuY = 0
                elseif menuY == 6 then -- Other Settings
                    showMenu = 19
                    menuY = 0
                elseif menuY == 7 then -- Language
                    if chooseLanguage < 21 then
                        chooseLanguage = chooseLanguage + 1
                    else
                        chooseLanguage = 0
                    end
                    ChangeLanguage(xsetLanguageLookup(chooseLanguage))
                else
                end

                --Save settings
                SaveSettings()

            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY > 0 then
                        menuY = menuY - 1
                        else
                        menuY=menuItems
                    end
                else
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY < menuItems then
                        menuY = menuY + 1
                        else
                        menuY=0
                    end
                else
                end
            elseif (Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE)) then
                showMenu = 7 
                menuY = 0
            end
        end

-- MENU 3 - CATEGORIES
    elseif showMenu == 3 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.Categories, white)--Categories
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection

        menuItems = 7

        -- MENU 3 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back

        -- MENU 3 / #1 Startup Category
        Font.print(fnt22, setting_x, setting_y1, lang_lines.Startup_Category_colon, white)--Startup Category

        if startCategory == 0 then Font.print(fnt22, setting_x_offset, setting_y1,          lang_lines.All, white)--ALL
        elseif startCategory == 1 then Font.print(fnt22, setting_x_offset, setting_y1,      lang_lines.PS_Vita, white)--GAMES
        elseif startCategory == 2 then Font.print(fnt22, setting_x_offset, setting_y1,      lang_lines.Homebrews, white)--HOMEBREWS
        elseif startCategory == 3 then Font.print(fnt22, setting_x_offset, setting_y1,      lang_lines.PSP, white)--PSP
        elseif startCategory == 4 then Font.print(fnt22, setting_x_offset, setting_y1,      lang_lines.PlayStation, white)--PSX
        elseif startCategory == 5 then Font.print(fnt22, setting_x_offset, setting_y1,      lang_lines.Playstation_Mobile, white)--Playstation_Mobile
        elseif startCategory == 6 then Font.print(fnt22, setting_x_offset, setting_y1,      lang_lines.Nintendo_64, white)--N64
        elseif startCategory == 7 then Font.print(fnt22, setting_x_offset, setting_y1,      lang_lines.Super_Nintendo, white)--SNES
        elseif startCategory == 8 then Font.print(fnt22, setting_x_offset, setting_y1,      lang_lines.Nintendo_Entertainment_System, white)--NES
        elseif startCategory == 9 then Font.print(fnt22, setting_x_offset, setting_y1,      lang_lines.Nintendo_DS, white)--NDS
        elseif startCategory == 10 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Game_Boy_Advance, white)--GBA
        elseif startCategory == 11 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Game_Boy_Color, white)--GBC
        elseif startCategory == 12 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Game_Boy, white)--GB
        elseif startCategory == 13 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Sega_Dreamcast, white)--Sega_Dreamcast
        elseif startCategory == 14 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Sega_CD, white)--Sega_CD
        elseif startCategory == 15 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Sega_32X, white)--Sega_32X
        elseif startCategory == 16 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Sega_Mega_Drive, white)--MD
        elseif startCategory == 17 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Sega_Master_System, white)--SMS
        elseif startCategory == 18 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Sega_Game_Gear, white)--GG
        elseif startCategory == 19 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.TurboGrafx_16, white)--TG16
        elseif startCategory == 20 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.TurboGrafx_CD, white)--TGCD
        elseif startCategory == 21 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.PC_Engine, white)--PCE
        elseif startCategory == 22 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.PC_Engine_CD, white)--PCECD
        elseif startCategory == 23 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Amiga, white)--AMIGA
        elseif startCategory == 24 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.ScummVM, white)--ScummVM
        elseif startCategory == 25 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Commodore_64, white)--Commodore_64
        elseif startCategory == 26 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.WonderSwan_Color, white)--WonderSwan_Color
        elseif startCategory == 27 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.WonderSwan, white)--WonderSwan
        elseif startCategory == 28 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.PICO8, white)--PICO8
        elseif startCategory == 29 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.MSX2, white)--MSX2
        elseif startCategory == 30 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.MSX, white)--MSX
        elseif startCategory == 31 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.ZX_Spectrum, white)--ZX_Spectrum
        elseif startCategory == 32 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Atari_7800, white)--Atari_7800
        elseif startCategory == 33 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Atari_5200, white)--Atari_5200
        elseif startCategory == 34 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Atari_2600, white)--Atari_2600
        elseif startCategory == 35 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Atari_Lynx, white)--Atari_Lynx
        elseif startCategory == 36 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.ColecoVision, white)--ColecoVision
        elseif startCategory == 37 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Vectrex, white)--Vectrex
        elseif startCategory == 38 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.FBA_2012, white)--FBA_2012
        elseif startCategory == 39 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.MAME_2003Plus, white)--MAME_2003Plus
        elseif startCategory == 40 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.MAME_2000, white)--MAME_2000
        elseif startCategory == 41 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Neo_Geo, white)--Neo_Geo
        elseif startCategory == 42 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Neo_Geo_Pocket_Color, white)--Neo_Geo_Pocket_Color
        elseif startCategory == 43 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.System_Apps, white)--System Apps
        elseif startCategory == 44 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Favorites, white)--Favorite
        elseif startCategory == 45 then Font.print(fnt22, setting_x_offset, setting_y1,     lang_lines.Recently_Played, white)--Recently Played
        
        elseif startCategory >= 47 then
            Collection_CatNum = startCategory - 46
            Font.print(fnt22, setting_x_offset, setting_y1, collection_files[Collection_CatNum].display_name, white)--Collections
        end

        -- MENU 3 / #2 Show Homebews
        Font.print(fnt22, setting_x, setting_y2, lang_lines.Homebrews_Category_colon, white)--Show Homebrews
        if showHomebrews == 1 then
            Font.print(fnt22, setting_x_offset, setting_y2, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y2, lang_lines.Off, white)--OFF
        end

        -- MENU 3 / #3 Show System Apps
        Font.print(fnt22, setting_x, setting_y3, lang_lines.System_Apps_colon, white)--Show System Apps
        if showSysApps == 1 then
            Font.print(fnt22, setting_x_offset, setting_y3, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y3, lang_lines.Off, white)--OFF
        end

        -- MENU 3 / #4 Recently Played
        Font.print(fnt22, setting_x, setting_y4, lang_lines.Recently_Played_colon, white)--Recently Played
        if showRecentlyPlayed == 1 then
            Font.print(fnt22, setting_x_offset, setting_y4, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y4, lang_lines.Off, white)--OFF
        end

        -- MENU 3 / #5 All Category
        Font.print(fnt22, setting_x, setting_y5, lang_lines.All_Category, white)--All Category
        if showAll == 1 then
            Font.print(fnt22, setting_x_offset, setting_y5, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y5, lang_lines.Off, white)--OFF
        end

        -- MENU 4 / #6 Show hidden games
        Font.print(fnt22, setting_x, setting_y6, lang_lines.Show_hidden_games_colon, white)--Show hidden games
        if showHidden == 1 then
            Font.print(fnt22, setting_x_offset, setting_y6, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y6, lang_lines.Off, white)--OFF
        end

        -- MENU 4 / #7 Show collections
        Font.print(fnt22, setting_x, setting_y7, lang_lines.Show_collections_colon, white)--Show collections
        if showCollections == 1 then
            Font.print(fnt22, setting_x_offset, setting_y7, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y7, lang_lines.Off, white)--OFF
        end

        -- MENU 3 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- count favorites
                create_fav_count_table(files_table)

                if menuY == 0 then -- #0 Back
                    showMenu = 2
                    menuY = 1 -- Categories

                elseif menuY == 1 then -- #1 Startup Category
                    if startCategory < collection_count_of_start_categories then
                        startCategory = startCategory + 1
                    else
                        startCategory = 0
                    end
                    -- Skip empty categories
                    if startCategory == 1 then if   #games_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 2 then if   #homebrews_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 3 then if   #psp_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 4 then if   #psx_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 5 then if   #psm_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 6 then if   #n64_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 7 then if   #snes_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 8 then if   #nes_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 9 then if   #nds_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 10 then if   #gba_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 11 then if  #gbc_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 12 then if  #gb_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 13 then if  #dreamcast_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 14 then if  #sega_cd_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 15 then if  #s32x_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 16 then if  #md_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 17 then if  #sms_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 18 then if  #gg_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 19 then if  #tg16_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 20 then if  #tgcd_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 21 then if  #pce_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 22 then if  #pcecd_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 23 then if  #amiga_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 24 then if  #scummvm_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 25 then if  #c64_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 26 then if  #wswan_col_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 27 then if  #wswan_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 28 then if  #pico8_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 29 then if  #msx2_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 30 then if  #msx1_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 31 then if  #zxs_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 32 then if  #atari_7800_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 33 then if  #atari_5200_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 34 then if  #atari_2600_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 35 then if  #atari_lynx_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 36 then if  #colecovision_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 37 then if  #vectrex_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 38 then if  #fba_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 39 then if  #mame_2003_plus_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 40 then if  #mame_2000_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 41 then if  #neogeo_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 42 then if  #ngpc_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 43 then if  #sysapps_table == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 44 then if  #fav_count == 0 then startCategory = startCategory + 1 end end
                    if startCategory == 46 then startCategory = startCategory + 1 end
                    -- if startCategory == 45 then if #recently_played_table == 0 then startCategory = startCategory + 1 end end

  
                    if startCategory >= 47 and startCategory < collection_count_of_start_categories then
                        if next(xCatLookup(startCategory)) ~= nil then
                        else
                            -- empty
                            startCategory = startCategory + 1
                        end
                    elseif startCategory > 47 and startCategory == collection_count_of_start_categories then
                    else
                    end

                elseif menuY == 2 then -- #2 Show Homebrews
                    if showHomebrews == 1 then
                        showHomebrews = 0
                        -- Import cache to update All games category
                        FreeIcons()
                        count_cache_and_reload()
                        
                        -- If currently on homebrew category view, move to Vita category to hide empty homebrew category
                        if showCat == 2 then
                            showCat = 1
                            p = 1
                            master_index = p
                            GetInfoSelected()
                        else
                            check_for_out_of_bounds()
                            GetInfoSelected()
                        end
                    else
                        showHomebrews = 1
                        -- Import cache to update All games category
                        FreeIcons()
                        count_cache_and_reload()
                        GetInfoSelected()
                    end
                elseif menuY == 3 then -- #3 Show System Apps
                    if showSysApps == 1 then
                        showSysApps = 0
                        -- Import cache to update All games category
                        FreeIcons()
                        count_cache_and_reload()
                        
                        -- If currently on system apps category view, move to Vita category to hide empty homebrew category
                        if showCat == 43 then
                            showCat = 1
                            p = 1
                            master_index = p
                            GetInfoSelected()
                        else
                            check_for_out_of_bounds()
                            GetInfoSelected()
                        end
                    else
                        showSysApps = 1
                        -- Import cache to update All games category
                        FreeIcons()
                        count_cache_and_reload()
                        GetInfoSelected()
                    end
                elseif menuY == 4 then -- #4 Recently Played
                    if showRecentlyPlayed == 1 then -- 0 Off, 1 On
                        showRecentlyPlayed = 0
                        -- Import cache to update All games category
                        FreeIcons()
                        count_cache_and_reload()
                        -- If currently on recent category view, move to Vita category to hide empty recent category
                        if showCat == 45 then
                            curTotal = #recently_played_table
                            if #recently_played_table == 0 then
                                showCat = 1
                            end
                        end
                    else
                        showRecentlyPlayed = 1
                        -- Import cache to update All games category
                        FreeIcons()
                        count_cache_and_reload()
                    end
                elseif menuY == 5 then -- #5 All Category
                    if showAll == 1 then -- 0 Off, 1 On
                        showAll = 0
                        -- Import cache to update All games category
                        FreeIcons()
                        count_cache_and_reload()
                        -- If currently on recent category view, move to Vita category to hide empty recent category
                        if showCat == 0 then
                            showCat = 1
                        end
                    else
                        showAll = 1
                    end

                elseif menuY == 6 then -- #6 Show hidden
                    if showHidden == 1 then
                        showHidden = 0

                        -- If show system apps if off and currently viewing system apps when renaming, must have used quick menu.
                        -- Turn on system apps temporarily so can see the result of the rename.
                        if showSysApps == 0 and showCat == 43 then
                            -- Turn on temporarily
                            showSysApps = 1

                            -- Import and jump to menu
                            FreeIcons()
                            count_cache_and_reload()
                            showCat = 43

                            -- Turn off again, the table will be removed when the user changes category (see category controls, square)
                            showSysApps = 0
                        else
                            -- Import cache to update All games category
                            FreeIcons()
                            count_cache_and_reload()
                        end

                        if showCat == 44 then 
                            create_fav_count_table(files_table)
                        end
                        check_for_out_of_bounds()
                        GetNameAndAppTypeSelected()
                    else
                        showHidden = 1

                        -- If show system apps if off and currently viewing system apps when renaming, must have used quick menu.
                        -- Turn on system apps temporarily so can see the result of the rename.
                        if showSysApps == 0 and showCat == 43 then
                            -- Turn on temporarily
                            showSysApps = 1

                            -- Import and jump to menu
                            FreeIcons()
                            count_cache_and_reload()
                            showCat = 43

                            -- Turn off again, the table will be removed when the user changes category (see category controls, square)
                            showSysApps = 0
                        else
                            -- Import cache to update All games category
                            FreeIcons()
                            count_cache_and_reload()
                        end

                        if showCat == 44 then 
                            create_fav_count_table(files_table)
                        end
                        check_for_out_of_bounds()
                        GetNameAndAppTypeSelected()
                    end

                elseif menuY == 7 then -- #7 Show collections
                    if showCollections == 1 then
                        showCollections = 0
                        
                        if showCat >= 47 and showCat <= collection_syscount then
                            if showAll==0 then
                                showCat = 1
                            else
                                showCat = 0
                            end
                            check_for_out_of_bounds()
                            GetNameAndAppTypeSelected()
                        else
                        end

                    else
                        showCollections = 1
                    end
                end

                --Save settings
                SaveSettings()
                
            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                if menuY > 0 then
                    menuY = menuY - 1
                    else
                    menuY=menuItems
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                if menuY < menuItems then
                    menuY = menuY + 1
                    else
                    menuY=0
                end
            end
        end

-- MENU 4 - THEME
    elseif showMenu == 4 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.Theme, white)--Theme
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection


        menuItems = 6

        -- MENU 4 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back

        -- MENU 4 / #1 Theme Color
        Font.print(fnt22, setting_x, setting_y1,  lang_lines.Theme_Color_colon, white)
        if themeColor == 1 then
            Font.print(fnt22, setting_x_offset, setting_y1, lang_lines.Red, white)--Red
        elseif themeColor == 2 then
            Font.print(fnt22, setting_x_offset, setting_y1, lang_lines.Yellow, white)--Yellow
        elseif themeColor == 3 then
            Font.print(fnt22, setting_x_offset, setting_y1, lang_lines.Green, white)--Green
        elseif themeColor == 4 then
            Font.print(fnt22, setting_x_offset, setting_y1, lang_lines.Dark_Grey, white)-- Dark Grey
        elseif themeColor == 5 then
            Font.print(fnt22, setting_x_offset, setting_y1, lang_lines.Black, white)--Black
        elseif themeColor == 6 then
            Font.print(fnt22, setting_x_offset, setting_y1, lang_lines.Purple, white)--Purple
        elseif themeColor == 7 then
            Font.print(fnt22, setting_x_offset, setting_y1, lang_lines.Dark_Purple, white)--Dark Purple
        elseif themeColor == 8 then
            Font.print(fnt22, setting_x_offset, setting_y1, lang_lines.Orange, white)--Orange
        elseif themeColor == 9 then
            Font.print(fnt22, setting_x_offset, setting_y1, lang_lines.Grey, white)--Grey
        else
            Font.print(fnt22, setting_x_offset, setting_y1, lang_lines.Blue, white)--Blue
        end

        -- MENU 4 / #2 Reflections
        Font.print(fnt22, setting_x, setting_y2, lang_lines.Reflection_Effect_colon, white) -- REFLECTION
        if setReflections == 1 then
            Font.print(fnt22, setting_x_offset, setting_y2, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y2, lang_lines.Off, white)--OFF
        end

        -- MENU 4 / #3 Custom Background
        Font.print(fnt22, setting_x, setting_y3,  lang_lines.Custom_Background_colon, white)

        function wallpaper_print_string (def)
            if setBackground == (def) then
                Font.print(fnt22, setting_x_offset, setting_y3, tostring(wallpaper_table_settings[(def)].wallpaper_string), white) --FILENAME
            end
        end

        if setBackground == 0 then 
            Font.print(fnt22, setting_x_offset, setting_y3, lang_lines.Off, white) --OFF
        else
            wallpaper_print_string (setBackground)
        end

        -- MENU 4 / #4 Smooth scrolling
        Font.print(fnt22, setting_x, setting_y4, lang_lines.Smooth_Scrolling_colon, white) -- Smooth scrolling
        if smoothScrolling == 1 then
            Font.print(fnt22, setting_x_offset, setting_y4, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y4, lang_lines.Off, white)--OFF
        end

        -- MENU 4 / #5 2D Views
        Font.print(fnt22, setting_x, setting_y5, lang_lines.Views_2D_colon, white) -- 2D Views:
        if set2DViews == 1 then
            Font.print(fnt22, setting_x_offset, setting_y5, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y5, lang_lines.Off, white)--OFF
        end

        -- MENU 4 / #6 Change views
        Font.print(fnt22, setting_x, setting_y6, lang_lines.Change_Views_colon, white) -- Change Views:
        if setChangeViews == 1 then
            Font.print(fnt22, setting_x_offset, setting_y6, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y6, lang_lines.Off, white)--OFF
        end


        -- MENU 4 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
    
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then
                if menuY == 0 then -- #0 Back
                    showMenu = 2
                    menuY = 2 -- Theme
                elseif menuY == 1 then -- #1 Theme Color
                    if themeColor < 9 then
                        themeColor = themeColor + 1
                    else
                        themeColor = 0
                    end
                    SetThemeColor()
                elseif menuY == 2 then -- #2 Reflections
                    if setReflections == 1 then
                        setReflections = 0
                    else
                        setReflections = 1
                    end
                elseif menuY == 3 then -- #3 Custom Background
                    bgtotal = #wallpaper_table_settings
                    if setBackground < bgtotal then
                        setBackground = setBackground + 1
                        Graphics.freeImage(imgBack)
                        imgBack = Graphics.loadImage(wallpaper_table_settings[setBackground].wallpaper_path)
                        imgCustomBack = imgBack
                        imgCustomBack = Graphics.loadImage(wallpaper_table_settings[setBackground].wallpaper_path)
                        -- Graphics.loadImage(wallpaper_table_settings[setBackground].wallpaper_path)
                        Render.useTexture(modBackground, imgCustomBack)
                    else
                        setBackground = 1 -- workaround hack as game backgrounds only show if setBackground is not 0
                        Graphics.freeImage(imgBack)
                        imgBack = Graphics.loadImage(wallpaper_table_settings[setBackground].wallpaper_path)
                        imgCustomBack = imgBack
                        imgCustomBack = Graphics.loadImage(wallpaper_table_settings[setBackground].wallpaper_path)
                        -- Graphics.loadImage(wallpaper_table_settings[setBackground].wallpaper_path)
                        Render.useTexture(modBackground, imgCustomBack)
                    end
                elseif menuY == 4 then -- #4 Smooth scrolling
                    if smoothScrolling == 1 then
                        smoothScrolling = 0
                    else
                        smoothScrolling = 1
                    end
                elseif menuY == 5 then -- #5 2D Views
                    if set2DViews == 1 then
                        set2DViews = 0

                        if showView > 4 then
                            showView = 0

                            master_index = p

                            -- Instantly move to selection
                            if startCovers == false then
                                targetX = base_x
                                startCovers = true
                                GetInfoSelected()
                            end
                        end

                    else
                        set2DViews = 1
                    end
                elseif menuY == 6 then -- #6 Change views
                    if setChangeViews == 1 then
                        setChangeViews = 0
                    else
                        setChangeViews = 1
                    end
                end

                --Save settings
                SaveSettings()

            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                if menuY > 0 then
                    menuY = menuY - 1
                    else
                    menuY=menuItems
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                if menuY < menuItems then
                    menuY = menuY + 1
                    else
                    menuY=0
                end
            end
            
        end

-- MENU 5 - ARTWORK
    elseif showMenu == 5 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.Artwork, white)--Artwork
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection

        menuItems = 6

        -- MENU 5 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)-- Back


        -- MENU 5 / #1 Download artwork

        Font.print(fnt22, setting_x, setting_y1, lang_lines.Download_colon, white)
        if download_artwork_type == 0 then
            Font.print(fnt22, setting_x_offset, setting_y1, "<  " .. lang_lines.Covers .."  >", white)
        else
            Font.print(fnt22, setting_x_offset, setting_y1, "<  " .. lang_lines.Backgrounds .."  >", white)
        end


        -- MENU 5 / #2 CRC Download
        Font.print(fnt22, setting_x, setting_y2, lang_lines.Download_using_CRC_colon, white)--Download using CRC
        if setCRCScan == 1 then
            Font.print(fnt22, setting_x_offset, setting_y2, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y2, lang_lines.Off, white)--OFF
        end

        -- MENU 5 / #3 Game Backgrounds
        Font.print(fnt22, setting_x, setting_y3, lang_lines.Game_backgounds_colon, white) -- Game backgounds
        if Game_Backgrounds == 1 then
            Font.print(fnt22, setting_x_offset, setting_y3, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y3, lang_lines.Off, white)--OFF
        end

        -- MENU 5 / #4 Extract Vita backgounds
        Font.print(fnt22, setting_x, setting_y4, lang_lines.Extract_PS_Vita_backgrounds, white) -- Extract PS Vita backgounds

        -- MENU 5 / #5 Extract PSP backgounds
        Font.print(fnt22, setting_x, setting_y5, lang_lines.Extract_PSP_backgrounds, white) -- Extract PSP backgounds

        -- MENU 5 / #6 Extract PICO-8 backgounds
        Font.print(fnt22, setting_x, setting_y6, lang_lines.Extract_PICO8_backgrounds, white) -- Extract PICO-8 backgounds


        -- MENU 5 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 5
                if menuY == 0 then -- #0 Back
                    showMenu = 2
                    menuY = 4 -- Artwork

                elseif menuY == 1 then -- #1 Download artwork

                    if Network.isWifiEnabled() then

                        if setCRCScan == 1 then

                            -- Create temporary file for Onelua to recognise as an instruction (OneLua will delete it after finding)
                            if download_artwork_type == 0 then
                                -- Covers
                                if not System.doesFileExist(cur_dir .. "/TITLES/missing_covers.lua") then
                                    local file_over = System.openFile(cur_dir .. "/TITLES/missing_covers.lua", FCREATE)
                                    System.writeFile(file_over, " ", 1)
                                    System.closeFile(file_over)
                                end
                            else
                                -- Backgrounds
                                if not System.doesFileExist(cur_dir .. "/TITLES/missing_snaps.lua") then
                                    local file_over = System.openFile(cur_dir .. "/TITLES/missing_snaps.lua", FCREATE)
                                    System.writeFile(file_over, " ", 1)
                                    System.closeFile(file_over)
                                end
                            end

                            -- Relaunch so OneLua eboot can check file CRC's and download artwork
                            FreeIcons()
                            FreeMemory()
                            System.launchEboot("app0:/launch_scan.bin")
                        else
                            if download_artwork_type == 0 then
                                -- Covers

                                if gettingCovers == false then
                                    gettingCovers = true

                                    missing_artwork_table_covers = {}
                                    
                                    for l, file in pairs(return_table) do
                                        if file.app_type == 0 or file.app_type == 39 or file.app_type == 41 or file.app_type == 42 then
                                            -- Do nothing - Homebrew, PSM, Pico, Sys app
                                        else
                                            if file.cover == false or string.match(file.icon_path, "%icon0.png") then
                                                table.insert(missing_artwork_table_covers, file)
                                            end
                                        end
                                    end

                                    table.sort(missing_artwork_table_covers, function(a, b) return (a.app_type < b.app_type) end)
                                    DownloadCovers()                                    

                                end


                            else
                                -- Backgrounds

                                if gettingBackgrounds == false then
                                    gettingBackgrounds = true

                                    missing_artwork_table_backgrounds = {}

                                    for l, file in pairs(return_table) do
                                        local missing_snap = false
                                        if file.app_type == 0 or file.app_type == 1 or file.app_type == 39 or file.app_type == 41 or file.app_type == 42 then
                                            -- Do nothing -- Homebrew, Vita, PSM, Pico, Sys app
                                        else
                                            if System.doesFileExist(file.snap_path_local .. file.name .. ".png") then
                                                missing_snap = false
                                            elseif System.doesFileExist(file.snap_path_local .. file.title .. ".png") then
                                                missing_snap = false
                                            else
                                                missing_snap = true
                                            end
                                            if missing_snap == true then
                                                table.insert(missing_artwork_table_backgrounds, file)
                                            end
                                        end
                                    end

                                    table.sort(missing_artwork_table_backgrounds, function(a, b) return (a.app_type < b.app_type) end)
                                    DownloadSnaps()
                                end

                            end
                        end

                    else
                        if status ~= RUNNING then
                            System.setMessage(lang_lines.Internet_Connection_Required, false, BUTTON_OK)
                        end
                    end


                elseif menuY == 2 then -- #2 CRC
                    if setCRCScan == 1 then
                        setCRCScan = 0
                    else
                        setCRCScan = 1
                    end

                elseif menuY == 3 then -- #3 Game Backgrounds
                    if Game_Backgrounds == 1 then
                        Game_Backgrounds = 0
                    else
                        Game_Backgrounds = 1
                    end
                elseif menuY == 4 then -- #4 Extract PS Vita backgrounds
                    FreeIcons()
                    FreeMemory()
                    Network.term()
                    -- Bin file based on copyicons by @cy33hc: https://github.com/cy33hc/copyicons
                    -- Copies icon, pic0, bg, bg0
                    System.launchEboot("app0:/launch_copy_vita_images.bin")

                elseif menuY == 5 then -- #5 Extract PSP backgrounds from iso files
                    -- Create temporary file for Onelua to recognise as an instruction (OneLua will delete it after finding)
                    if not System.doesFileExist(cur_dir .. "/TITLES/onelua_extract_psp.dat") then
                        local file_over = System.openFile(cur_dir .. "/TITLES/onelua_extract_psp.dat", FCREATE)
                        System.writeFile(file_over, " ", 1)
                        System.closeFile(file_over)
                    end
                    -- Relaunch so OneLua eboot can extract the images
                    System.launchEboot("app0:/launch_scan.bin")

                elseif menuY == 6 then -- #6 Pico backgrounds
                    curTotal = #pico8_table
                    if #pico8_table >= 1 then

                        Graphics.initBlend()
                        Screen.clear()
                        Graphics.termBlend()
                        Screen.flip()

                        for i, file in pairs(pico8_table) do

                            -- Create pico8 background from image
                            
                            if not System.doesFileExist(file.snap_path_local .. file.name .. ".png") then
                                -- Missing background - crop pico-8 cart, resize and take screenshot
                                local pico_image = Graphics.loadImage(file.game_path)
                                Graphics.initBlend()
                                Screen.clear()

                                Graphics.drawImageExtended(480, 270, pico_image, 16, 24, 128, 128, 0, 7.5, 4.2)

                                Graphics.termBlend()
                                Screen.flip()
                                System.takeScreenshot(file.snap_path_local .. file.name .. ".png", FORMAT_PNG)

                                
                            else
                                -- Image exists, display it and move onto next
                                local pico_image = Graphics.loadImage(file.snap_path_local .. file.name .. ".png")
                                Graphics.initBlend()
                                Screen.clear()

                                -- Rescale image to fill screen
                                original_w = Graphics.getImageWidth(pico_image)
                                original_h = Graphics.getImageHeight(pico_image)
                                if original_w == 960 then ratio_w = 1.0 else ratio_w = 960 / original_w end
                                if original_h == 544 then ratio_h = 1.0 else ratio_h = 544 / original_h end

                                Graphics.drawScaleImage(0, 0, pico_image, ratio_w, ratio_h)

                                Graphics.termBlend()
                                Screen.flip()

                                Graphics.freeImage(pico_image)
                            end
                            
                        end
                        
                    end


                end

                --Save settings
                SaveSettings()
                
            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                if menuY > 0 then
                    menuY = menuY - 1
                    else
                    menuY=menuItems
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                if menuY < menuItems then
                    menuY = menuY + 1
                    else
                    menuY=0
                end
            elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then

                if menuY==1 then -- #1 Download artwork
                    if download_artwork_type == 1 then
                        download_artwork_type = 0
                    else
                        download_artwork_type = 1
                    end
                end

            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then

                if menuY==1 then -- #1 Download Covers
                    if download_artwork_type == 1 then
                        download_artwork_type = 0
                    else
                        download_artwork_type = 1
                    end
                end
            end
        end

-- MENU 6 - SCAN SETTINGS
    elseif showMenu == 6 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.Scan_Settings, white)--Scan_Settings
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection

        menuItems = 4

        -- MENU 6 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back

        -- MENU 6 / #1 Game directories
        Font.print(fnt22, setting_x, setting_y1, lang_lines.Edit_game_directories, white)--Edit_game_directories 

        -- MENU 6 / #2 Scan on Startup
        Font.print(fnt22, setting_x, setting_y2, lang_lines.Startup_scan_colon, white)--Scan on startup

        if startupScan == 1 then
            Font.print(fnt22, setting_x_offset, setting_y2, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y2, lang_lines.Off, white)--OFF
        end

        -- MENU 6 / #3 Adrenaline_roms
        Font.print(fnt22, setting_x, setting_y3, lang_lines.Adrenaline_roms, white)--Adrenaline_roms 

        if Adrenaline_roms == 1 then
            Font.print(fnt22, setting_x_offset, setting_y3, "<  " .. "ux0"  .. ":/pspemu" .. "  >", white)
        elseif Adrenaline_roms == 2 then
            Font.print(fnt22, setting_x_offset, setting_y3, "<  " .. "ur0"  .. ":/pspemu" .. "  >", white)
        elseif Adrenaline_roms == 3 then
            Font.print(fnt22, setting_x_offset, setting_y3, "<  " .. "imc0" .. ":/pspemu" .. "  >", white)
        elseif Adrenaline_roms == 4 then
            Font.print(fnt22, setting_x_offset, setting_y3, "<  " .. "xmc0" .. ":/pspemu" .. "  >", white)
        elseif Adrenaline_roms == 5 then
            Font.print(fnt22, setting_x_offset, setting_y3, "<  " .. lang_lines.All .. "  >", white)   
        else
            Font.print(fnt22, setting_x_offset, setting_y3, "<  " .. "uma0" .. ":/pspemu" .. "  >", white)
        end

        -- MENU 6 / #4 Rescan
        Font.print(fnt22, setting_x, setting_y4, lang_lines.Rescan, white)--Rescan

        

        -- MENU 6 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 2
                if menuY == 0 then -- #0 Back
                    showMenu = 2
                    menuY = 5 -- Scan settings
                elseif menuY == 1 then -- #1 Game directories
                    showMenu = 8
                    menuY = 0
                elseif menuY == 2 then -- #2 Scan on Startup 
                    if startupScan == 1 then -- 0 Off, 1 On
                        startupScan = 0
                        --Save settings
                        SaveSettings()
                        -- Print to Cache folder
                        print_onelua_title_files() -- Added so rescan not triggered, other cache files exist
                        FreeIcons()
                        count_cache_and_reload()
                    else
                        startupScan = 1
                        --Save settings
                        SaveSettings()
                        FreeIcons()
                        count_cache_and_reload()
                    end
                elseif menuY == 4 then -- #4 Rescan
                        delete_cache()
                        FreeIcons()
                        FreeMemory()
                        Network.term()
                        dofile("app0:index.lua")
                end
            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                if menuY > 0 then
                    menuY = menuY - 1
                    else
                    menuY=menuItems
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                if menuY < menuItems then
                    menuY = menuY + 1
                    else
                    menuY=0
                end
            elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then
                if menuY==3 then -- #3 Adrenaline_roms selection
                    if Adrenaline_roms > 0 then
                        Adrenaline_roms = Adrenaline_roms - 1
                    else
                        Adrenaline_roms = 5
                    end
                    SaveSettings()
                end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
                if menuY==3 then -- #3 Adrenaline_roms selection
                    if Adrenaline_roms < 5 then
                        Adrenaline_roms = Adrenaline_roms + 1
                    else
                        Adrenaline_roms=0
                    end
                    SaveSettings()
                end
            end


        end

-- MENU 7 - ABOUT
    elseif showMenu == 7 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.Help_and_Guides, white)--Help and Guides
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection

        menuItems = 6
        
        -- MENU 7 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back
        
        -- MENU 7 / #1 Guide 1
        Graphics.drawImage(setting_x_icon, setting_y1, setting_icon_about)
        Font.print(fnt22, setting_x_icon_offset, setting_y1, lang_lines.guide_1_heading, white)--Guide 1

        -- MENU 7 / #2 Guide 2
        Graphics.drawImage(setting_x_icon, setting_y2, setting_icon_about)
        Font.print(fnt22, setting_x_icon_offset, setting_y2, lang_lines.guide_2_heading, white)--Guide 2

        -- MENU 7 / #3 Guide 3
        Graphics.drawImage(setting_x_icon, setting_y3, setting_icon_about)
        Font.print(fnt22, setting_x_icon_offset, setting_y3, lang_lines.guide_3_heading, white)--Guide 3

        -- MENU 7 / #4 Guide 4
        Graphics.drawImage(setting_x_icon, setting_y4, setting_icon_about)
        Font.print(fnt22, setting_x_icon_offset, setting_y4, lang_lines.guide_4_heading, white)--Guide 4

        -- MENU 7 / #5 Guide 5
        Graphics.drawImage(setting_x_icon, setting_y5, setting_icon_about)
        Font.print(fnt22, setting_x_icon_offset, setting_y5, lang_lines.guide_5_heading, white)--Guide 5

        -- MENU 7 / #6 Guide 6
        Graphics.drawImage(setting_x_icon, setting_y6, setting_icon_about)
        Font.print(fnt22, setting_x_icon_offset, setting_y6, lang_lines.guide_6_heading, white)--Guide 6

        -- Hidden timer        
        Font.print(fnt20, 10, 508, "Overall load time: " .. (functionTime + oneLoopTime) / 1000 .. " s.  Functions: ".. functionTime / 1000 .. " s.   Main loop: ".. oneLoopTime / 1000 .. " s.", timercolor)


        
        -- MENU 7 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 2 / #0 Search
                if menuY == 0 then -- #0 Back
                    showMenu = 2
                    menuY = 0 -- Search
                elseif menuY == 1 then -- Guide 1
                    showMenu = 13 
                    menuY = 0
                elseif menuY == 2 then -- Guide 2
                    showMenu = 14 
                    menuY = 0
                elseif menuY == 3 then -- Guide 3
                    showMenu = 15 
                    menuY = 0
                elseif menuY == 4 then -- Guide 4
                    showMenu = 16 
                    menuY = 0
                elseif menuY == 5 then -- Guide 5
                    showMenu = 17 
                    menuY = 0
                elseif menuY == 6 then -- Guide 6
                    showMenu = 18 
                    menuY = 0
                else
                end

            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY > 0 then
                        menuY = menuY - 1
                        else
                        menuY=menuItems
                    end
                else
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY < menuItems then
                        menuY = menuY + 1
                        else
                        menuY=0
                    end
                else
                end
            elseif (Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE)) then
                showMenu = 7 
                -- menuY = 0
            elseif (Controls.check(pad, SCE_CTRL_SELECT) and not Controls.check(oldpad, SCE_CTRL_SELECT)) then
                -- How hidden timer
                if timercolor == transparent then
                    timercolor = white
                else
                    timercolor = transparent
                end
                Screen.flip()
            end
        end

-- MENU 8 - EDIT GAME DIRECTORIES
    elseif showMenu == 8 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.Game_directories, white)--Game_directories
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection

        menuItems = 3

        -- MENU 8 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back

        -- MENU 8 / #1 and 2 Game category and directory
            if getRomDir == 1 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Amiga .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Amiga, white)
                filebrowser_heading = lang_lines.Amiga
            elseif getRomDir == 2 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Atari_2600 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Atari_2600, white)
                filebrowser_heading = lang_lines.Atari_2600
            elseif getRomDir == 3 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Atari_5200 .."  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Atari_5200, white)
                filebrowser_heading = lang_lines.Atari_5200
            elseif getRomDir == 4 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Atari_7800 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Atari_7800, white)
                filebrowser_heading = lang_lines.Atari_7800
            elseif getRomDir == 5 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Atari_Lynx .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Atari_Lynx, white)
                filebrowser_heading = lang_lines.Atari_Lynx
            elseif getRomDir == 6 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.ColecoVision .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.ColecoVision, white)
                filebrowser_heading = lang_lines.ColecoVision
            elseif getRomDir == 7 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Commodore_64 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Commodore_64, white)
                filebrowser_heading = lang_lines.Commodore_64
            elseif getRomDir == 8 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.FBA_2012 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.FBA_2012, white)
                filebrowser_heading = lang_lines.FBA_2012
            elseif getRomDir == 9 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Game_Boy_Advance .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Game_Boy_Advance, white)
                filebrowser_heading = lang_lines.Game_Boy_Advance
            elseif getRomDir == 10 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Game_Boy_Color .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Game_Boy_Color, white)
                filebrowser_heading = lang_lines.Game_Boy_Color
            elseif getRomDir == 11 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Game_Boy .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Game_Boy, white)
                filebrowser_heading = lang_lines.Game_Boy
            elseif getRomDir == 12 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.MAME_2000 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.MAME_2000, white)
                filebrowser_heading = lang_lines.MAME_2000
            elseif getRomDir == 13 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.MAME_2003Plus .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.MAME_2003Plus, white)
                filebrowser_heading = lang_lines.MAME_2003Plus
            elseif getRomDir == 14 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.MSX .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.MSX, white)
                filebrowser_heading = lang_lines.MSX
            elseif getRomDir == 15 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.MSX2 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.MSX2, white)
                filebrowser_heading = lang_lines.MSX2
            elseif getRomDir == 16 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Neo_Geo_Pocket_Color .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Neo_Geo_Pocket_Color, white)
                filebrowser_heading = lang_lines.Neo_Geo_Pocket_Color
            elseif getRomDir == 17 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Neo_Geo .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Neo_Geo, white)
                filebrowser_heading = lang_lines.Neo_Geo
            elseif getRomDir == 18 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Nintendo_64 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Nintendo_64, white)
                filebrowser_heading = lang_lines.Nintendo_64
            elseif getRomDir == 19 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Nintendo_DS .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Nintendo_DS, white)
                filebrowser_heading = lang_lines.Nintendo_DS
            elseif getRomDir == 20 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Nintendo_Entertainment_System .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Nintendo_Entertainment_System, white)
                filebrowser_heading = lang_lines.Nintendo_Entertainment_System
            elseif getRomDir == 21 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.PC_Engine_CD .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.PC_Engine_CD, white)
                filebrowser_heading = lang_lines.PC_Engine_CD
            elseif getRomDir == 22 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.PC_Engine .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.PC_Engine, white)
                filebrowser_heading = lang_lines.PC_Engine
            elseif getRomDir == 23 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.PICO8 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Pico8, white)
                filebrowser_heading = lang_lines.PICO8   
            elseif getRomDir == 24 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.PlayStation .. " (RetroArch)" ..  "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.PlayStation, white)
                filebrowser_heading = lang_lines.PlayStation .. " (RetroArch)"
            elseif getRomDir == 25 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Sega_32X .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Sega_32X, white)
                filebrowser_heading = lang_lines.Sega_32X
            elseif getRomDir == 26 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Sega_CD .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Sega_CD, white)
                filebrowser_heading = lang_lines.Sega_CD
            elseif getRomDir == 27 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Sega_Dreamcast .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Sega_Dreamcast, white)
                filebrowser_heading = lang_lines.Sega_Dreamcast
            elseif getRomDir == 28 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Sega_Game_Gear .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Sega_Game_Gear, white)
                filebrowser_heading = lang_lines.Sega_Game_Gear
            elseif getRomDir == 29 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Sega_Master_System .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Sega_Master_System, white)
                filebrowser_heading = lang_lines.Sega_Master_System
            elseif getRomDir == 30 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Sega_Mega_Drive .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Sega_Mega_Drive, white)
                filebrowser_heading = lang_lines.Sega_Mega_Drive
            elseif getRomDir == 31 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Super_Nintendo .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Super_Nintendo, white)
                filebrowser_heading = lang_lines.Super_Nintendo
            elseif getRomDir == 32 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.TurboGrafx_16 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.TurboGrafx_16, white)
                filebrowser_heading = lang_lines.TurboGrafx_16
            elseif getRomDir == 33 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.TurboGrafx_CD .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.TurboGrafx_CD, white)
                filebrowser_heading = lang_lines.TurboGrafx_CD
            elseif getRomDir == 34 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Vectrex .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Vectrex, white)
                filebrowser_heading = lang_lines.Vectrex
            elseif getRomDir == 35 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.WonderSwan_Color .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.WonderSwan_Color, white)
                filebrowser_heading = lang_lines.WonderSwan_Color
            elseif getRomDir == 36 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.WonderSwan .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.WonderSwan, white)
                filebrowser_heading = lang_lines.WonderSwan
            elseif getRomDir == 37 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.ZX_Spectrum .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.ZX_Spectrum, white)
                filebrowser_heading = lang_lines.ZX_Spectrum
            end

        -- MENU 8 / #3 Rescan
        Font.print(fnt22, setting_x, setting_y3, lang_lines.Rescan, white)--Rescan 

        -- MENU 8 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then
                -- MENU 8
                if menuY == 0 then -- #0 Back
                    showMenu = 6
                    menuY = 1
                end
                if menuY == 2 then -- #2 ROM Partitions
                    showMenu = 9
                    menuY = 0
                end
                if menuY == 3 then -- Rescan
                    delete_cache()
                    FreeIcons()
                    FreeMemory()
                    Network.term()
                    dofile("app0:index.lua")
                end
            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                if menuY > 0 then
                    menuY = menuY - 1
                    else
                    menuY=menuItems
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                if menuY < menuItems then
                    menuY = menuY + 1
                    else
                    menuY=0
                end
            elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then
                if menuY==1 then -- #1 category rom directory selection
                    if getRomDir > 1 then
                        getRomDir = getRomDir - 1
                    else
                        getRomDir = 37 -- Update number if add more systems
                    end
                end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
                if menuY==1 then -- #1 category rom directory selection
                    if getRomDir < 37 then -- Update number if add more systems
                        getRomDir = getRomDir + 1
                    else
                        getRomDir=1
                    end
                end
            end

        end

-- MENU 9 - ROM BROWSER PARTITIONS
    elseif showMenu == 9 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Back)--Back
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select
        label3 = Font.getTextWidth(fnt20, lang_lines.Close)--Close

        -- Draw footer
        Graphics.fillRect(0, 960, 496, 544, themeCol)-- footer bottom

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Back, white)--Back

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.drawImage(900-(btnMargin * 4)-label1-label2-label3, 510, btnT)
        Font.print(fnt20, 900+28-(btnMargin * 4)-label1-label2-label3, 508, lang_lines.Close, white)--Close


        Graphics.fillRect(60, 900, 34, 460, darkalpha)--dark background

        Font.print(fnt22, setting_x, setting_yh, filebrowser_heading, white)--Game heading from menu 8
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47 +47), 129 + (menuY * 47 +47), themeCol)-- selection

        -- menuItems = 3

        menuItems = 4
        -- START ROM BROWSER PARTITIONS


            Font.print(fnt20, setting_x, setting_y0 + 2, lang_lines.Home, grey_dir) -- Home
            
            -- MENU 9 / #0 ux0 
            if System.doesDirExist("ux0:/") then
                Graphics.drawImage(setting_x_icon, setting_y1, setting_icon_scanning)
                Font.print(fnt22, setting_x_icon_offset, setting_y1, "ux0:", white)--ux0
            else
                Graphics.drawImage(setting_x_icon, setting_y1, setting_icon_scanning, white_opaque)
                Font.print(fnt22, setting_x_icon_offset, setting_y1, "ux0:", white_opaque)--ux0
            end

            -- MENU 9 / #1 uma0
            if System.doesDirExist("uma0:/") then
                Graphics.drawImage(setting_x_icon, setting_y2, setting_icon_scanning)
                Font.print(fnt22, setting_x_icon_offset, setting_y2, "uma0:", white)--uma0
            else
                Graphics.drawImage(setting_x_icon, setting_y2, setting_icon_scanning, white_opaque)
                Font.print(fnt22, setting_x_icon_offset, setting_y2, "uma0:", white_opaque)--uma0
            end

            -- MENU 9 / #2 imc0
            if System.doesDirExist("imc0:/") then
                Graphics.drawImage(setting_x_icon, setting_y3, setting_icon_scanning)
                Font.print(fnt22, setting_x_icon_offset, setting_y3, "imc0:", white)--imc0
            else
                Graphics.drawImage(setting_x_icon, setting_y3, setting_icon_scanning, white_opaque)
                Font.print(fnt22, setting_x_icon_offset, setting_y3, "imc0:", white_opaque)--imc0
            end

            -- MENU 9 / #3 xmc0
            if System.doesDirExist("xmc0:/") then
                Graphics.drawImage(setting_x_icon, setting_y4, setting_icon_scanning)
                Font.print(fnt22, setting_x_icon_offset, setting_y4, "xmc0:", white)--xmc0
            else
                Graphics.drawImage(setting_x_icon, setting_y4, setting_icon_scanning, white_opaque)
                Font.print(fnt22, setting_x_icon_offset, setting_y4, "xmc0:", white_opaque)--xmc0
            end

            -- MENU 9 / #4 grw0
            if System.doesDirExist("grw0:/") then
                Graphics.drawImage(setting_x_icon, setting_y5, setting_icon_scanning)
                Font.print(fnt22, setting_x_icon_offset, setting_y5, "grw0:", white)--xmc0
            else
                Graphics.drawImage(setting_x_icon, setting_y5, setting_icon_scanning, white_opaque)
                Font.print(fnt22, setting_x_icon_offset, setting_y5, "grw0:", white_opaque)--xmc0
            end


        -- END ROM BROWSER PARTITIONS


        -- MENU 9 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
                -- Check for input
                pad = Controls.read()
                if Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP) then

                    function check_partition_and_go_to_menu()

                        -- If partition exists - scan and go menu
                        if System.doesDirExist(selected_partition) then
                            scripts = System.listDirectory(selected_partition)
                            for k, v in pairs(scripts) do
                                v.previous_directory = false
                                v.save = false
                            end

                            -- Add level up
                            level_up = {}
                            level_up.name = "..."
                            level_up.directory = true
                            level_up.previous_directory = true
                            level_up.save = false
                            table.insert(scripts, 1, level_up) -- ...

                            scripts_sort_by_folder_first()
                            cur_dir_fm = selected_partition
                            showMenu = 11
                            menuY = 0      

                        -- If partition does not exist - go to not found menu
                        else
                            showMenu = 10
                            menuY = 0 
                        end
                    end


                    if menuY == 0 then
                        selected_partition = "ux0:/"
                        selected_partition_menuY = 0
                        check_partition_and_go_to_menu()
                    elseif menuY == 1 then
                        selected_partition = "uma0:/"
                        selected_partition_menuY = 1
                        check_partition_and_go_to_menu()
                    elseif menuY == 2 then
                        selected_partition = "imc0:/"
                        selected_partition_menuY = 2
                        check_partition_and_go_to_menu()
                    elseif menuY == 3 then
                        selected_partition = "xmc0:/"
                        selected_partition_menuY = 3
                        check_partition_and_go_to_menu()
                    elseif menuY == 4 then
                        selected_partition = "grw0:/"
                        selected_partition_menuY = 4
                        check_partition_and_go_to_menu()
                    else
                    end



                elseif Controls.check(pad, SCE_CTRL_CIRCLE_MAP) and not Controls.check(oldpad, SCE_CTRL_CIRCLE_MAP) then
                    oldpad = pad
                    showMenu = 8
                    menuY = 2
                elseif Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) then
                    if menuY > 0 then
                        menuY = menuY - 1
                        else
                        menuY=menuItems
                    end
                elseif Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) then
                    if menuY < menuItems then
                        menuY = menuY + 1
                        else
                        menuY=0
                    end
                elseif Controls.check(pad, SCE_CTRL_TRIANGLE) then
                    -- break
                    showMenu = 8
                    menuY = 2
                end

        end

-- MENU 10 - ROM BROWSER PARTITION NOT FOUND
    elseif showMenu == 10 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Back)--Back
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select
        label3 = Font.getTextWidth(fnt20, lang_lines.Close)--Close

        -- Draw footer
        Graphics.fillRect(0, 960, 496, 544, themeCol)-- footer bottom

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Back, white)--Back

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.drawImage(900-(btnMargin * 4)-label1-label2-label3, 510, btnT)
        Font.print(fnt20, 900+28-(btnMargin * 4)-label1-label2-label3, 508, lang_lines.Close, white)--Close


        Graphics.fillRect(60, 900, 34, 460, darkalpha)--dark background

        Font.print(fnt22, setting_x, setting_yh, filebrowser_heading, white)--Game heading from menu 8
        Graphics.fillRect(60, 900, 78, 81, white)

        -- Graphics.fillRect(60, 900, 89 + (menuY * 50 +50), 150 + (menuY * 50 +50), themeCol)-- selection
        Graphics.fillRect(60, 900, 82 + (menuY * 47 +47), 129 + (menuY * 47 +47), themeCol)-- selection

        menuItems = 0

        Font.print(fnt20, setting_x, setting_y0 + 2, lang_lines.Directory_not_found, grey_dir) -- Directory not found
        Font.print(fnt22, setting_x, setting_y1, "...", white)--Back



        -- MENU 10 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
                -- Check for input
                pad = Controls.read()
                if Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP) then

                    if menuY == 0 then
                        oldpad = pad
                        showMenu = 9
                        menuY = selected_partition_menuY
                    end

                elseif Controls.check(pad, SCE_CTRL_CIRCLE_MAP) and not Controls.check(oldpad, SCE_CTRL_CIRCLE_MAP) then
                    oldpad = pad
                    showMenu = 9
                    menuY = selected_partition_menuY
                elseif Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) then
                    if menuY > 0 then
                        menuY = menuY - 1
                        else
                        menuY=menuItems
                    end
                elseif Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) then
                    if menuY < menuItems then
                        menuY = menuY + 1
                        else
                        menuY=0
                    end
                elseif Controls.check(pad, SCE_CTRL_TRIANGLE) then
                    oldpad = pad
                    showMenu = 9
                    menuY = selected_partition_menuY
                end

        end

-- MENU 11 - ROM BROWSER
    elseif showMenu == 11 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Back)--Back
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select
        label3 = Font.getTextWidth(fnt20, lang_lines.Close)--Close

        Graphics.fillRect(60, 900, 34, 460, darkalpha)--dark background

        Font.print(fnt22, setting_x, setting_yh, filebrowser_heading, white)--Game heading from menu 8
        Graphics.fillRect(60, 900, 78, 81, white)

        -- Graphics.fillRect(60, 900, 150 + (menuY * 46), 200 + (menuY * 46), themeCol)-- selection
        Graphics.fillRect(60, 900, 82 + (menuY * 47 +47), 129 + (menuY * 47 +47), themeCol)-- selection

        -- START ROM BROWSER

            -- Reset y axis for menu blending
            local y = setting_y1
            
            Font.print(fnt20, setting_x, setting_y0 + 2, cur_dir_fm, grey_dir)

            -- Write visible menu entries
            for j, file in pairs(scripts) do
                x = 20
                if j >= i and y < 450 then
                    if i == j then
                        color = white
                        x = 20
                    else
                        color = white
                    end

                    -- No Icon - ...
                    if file.directory == true and file.previous_directory == true then
                        Font.print(fnt22, setting_x, y, file.name, color)

                    -- Icon - Folder Open -- Use this directory
                    elseif file.directory == true and file.save == true then
                        Font.print(fnt22, setting_x_icon_offset, y, file.name, color)
                        Graphics.drawImage(setting_x, y, file_browser_folder_open)

                    -- Icon - Folder Closed
                    elseif file.directory == true and file.save == false and file.previous_directory == false then
                        Font.print(fnt22, setting_x_icon_offset, y, file.name, color)
                        Graphics.drawImage(setting_x, y, file_browser_folder_closed)

                    -- Icon - File
                    elseif file.directory == false then
                        Font.print(fnt22, setting_x_icon_offset, y, file.name, color)
                        Graphics.drawImage(setting_x, y, file_browser_file)

                    else
                    end

                    y = y + 47
                end
            end

        -- END ROM BROWSER


        -- Draw footer ontop of dynamic list
        Graphics.fillRect(0, 960, 496, 544, themeCol)-- footer bottom

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Back, white)--Back

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.drawImage(900-(btnMargin * 4)-label1-label2-label3, 510, btnT)
        Font.print(fnt20, 900+28-(btnMargin * 4)-label1-label2-label3, 508, lang_lines.Close, white)--Close


        menuItems = 0


        -- MENU 11 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            -- START ROM BROWSER

                -- Check for input
                pad = Controls.read()
                if Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP) then

                    if scripts[i].directory == true then

                        
                        if scripts[i].previous_directory == true then
                            -- Action = Move to previous directory
                                if string.len(cur_dir_fm) > string.len(selected_partition) then -- Excluding partition name eg: ux0:/
                                    j=-2
                                    while string.sub(cur_dir_fm,j,j) ~= "/" do
                                        j=j-1
                                    end
                                    cur_dir_fm = string.sub(cur_dir_fm,1,j)

                                    scripts = System.listDirectory(cur_dir_fm)
                                    for k, v in pairs(scripts) do
                                        v.previous_directory = false
                                        v.save = false
                                    end
                                    
                                    -- Add level up
                                    level_up = {}
                                    level_up.name = "..."
                                    level_up.directory = true
                                    level_up.previous_directory = true
                                    level_up.save = false
                                    table.insert(scripts, 1, level_up) -- ...

                                    scripts_sort_by_folder_first()


                                    if string.len(cur_dir_fm) > string.len(selected_partition) then
                                        selection = {}
                                        selection.name = lang_lines.Use_this_directory -- Use_this_directory
                                        selection.directory = true
                                        selection.previous_directory = false
                                        selection.save = true
                                        table.insert(scripts, 2, selection)
                                    end

                                    i = 1
                                end

                                if string.len(cur_dir_fm) == string.len(selected_partition) then
                                    oldpad = pad
                                    showMenu = 9
                                    menuY = selected_partition_menuY
                                end

                        else

                            
                            if scripts[i].save == true then     
                                -- Action = Save directory
                                    cur_dir_fm = string.sub(cur_dir_fm, 1, -2)
                                    if getRomDir == 1 then romUserDir.Amiga = cur_dir_fm
                                    elseif getRomDir == 2 then romUserDir.Atari_2600 = cur_dir_fm
                                    elseif getRomDir == 3 then romUserDir.Atari_5200 = cur_dir_fm
                                    elseif getRomDir == 4 then romUserDir.Atari_7800 = cur_dir_fm
                                    elseif getRomDir == 5 then romUserDir.Atari_Lynx = cur_dir_fm
                                    elseif getRomDir == 6 then romUserDir.ColecoVision = cur_dir_fm
                                    elseif getRomDir == 7 then romUserDir.Commodore_64 = cur_dir_fm
                                    elseif getRomDir == 8 then romUserDir.FBA_2012 = cur_dir_fm
                                    elseif getRomDir == 9 then romUserDir.Game_Boy_Advance = cur_dir_fm
                                    elseif getRomDir == 10 then romUserDir.Game_Boy_Color = cur_dir_fm
                                    elseif getRomDir == 11 then romUserDir.Game_Boy = cur_dir_fm
                                    elseif getRomDir == 12 then romUserDir.MAME_2000 = cur_dir_fm
                                    elseif getRomDir == 13 then romUserDir.MAME_2003Plus = cur_dir_fm
                                    elseif getRomDir == 14 then romUserDir.MSX = cur_dir_fm
                                    elseif getRomDir == 15 then romUserDir.MSX2 = cur_dir_fm
                                    elseif getRomDir == 16 then romUserDir.Neo_Geo_Pocket_Color = cur_dir_fm
                                    elseif getRomDir == 17 then romUserDir.Neo_Geo = cur_dir_fm
                                    elseif getRomDir == 18 then romUserDir.Nintendo_64 = cur_dir_fm
                                    elseif getRomDir == 19 then romUserDir.Nintendo_DS = cur_dir_fm
                                    elseif getRomDir == 20 then romUserDir.Nintendo_Entertainment_System = cur_dir_fm
                                    elseif getRomDir == 21 then romUserDir.PC_Engine_CD = cur_dir_fm
                                    elseif getRomDir == 22 then romUserDir.PC_Engine = cur_dir_fm
                                    elseif getRomDir == 23 then romUserDir.Pico8 = cur_dir_fm
                                    elseif getRomDir == 24 then romUserDir.PlayStation = cur_dir_fm
                                    elseif getRomDir == 25 then romUserDir.Sega_32X = cur_dir_fm
                                    elseif getRomDir == 26 then romUserDir.Sega_CD = cur_dir_fm
                                    elseif getRomDir == 27 then romUserDir.Sega_Dreamcast = cur_dir_fm
                                    elseif getRomDir == 28 then romUserDir.Sega_Game_Gear = cur_dir_fm
                                    elseif getRomDir == 29 then romUserDir.Sega_Master_System = cur_dir_fm
                                    elseif getRomDir == 30 then romUserDir.Sega_Mega_Drive = cur_dir_fm
                                    elseif getRomDir == 31 then romUserDir.Super_Nintendo = cur_dir_fm
                                    elseif getRomDir == 32 then romUserDir.TurboGrafx_16 = cur_dir_fm
                                    elseif getRomDir == 33 then romUserDir.TurboGrafx_CD = cur_dir_fm
                                    elseif getRomDir == 34 then romUserDir.Vectrex = cur_dir_fm
                                    elseif getRomDir == 35 then romUserDir.WonderSwan_Color = cur_dir_fm
                                    elseif getRomDir == 36 then romUserDir.WonderSwan = cur_dir_fm
                                    elseif getRomDir == 37 then romUserDir.ZX_Spectrum = cur_dir_fm
                                    end

                                    print_table_rom_dirs(romUserDir)

                                    
                                    showMenu = 8
                                    menuY = 2
                                    scripts = System.listDirectory(selected_partition)
                                    scripts_sort_by_folder_first()
                                    for k, v in pairs(scripts) do
                                        v.previous_directory = false
                                        v.save = false
                                    end

                                    cur_dir_fm = selected_partition

                            else
                                -- Action = List the directory
                                    cur_dir_fm = cur_dir_fm .. scripts[i].name .. "/"
                                    scripts = System.listDirectory(cur_dir_fm)
                                    for k, v in pairs(scripts) do
                                        v.previous_directory = false
                                        v.save = false
                                    end

                                    scripts_sort_by_folder_first()

                                    level_up = {}
                                    level_up.name = "..."
                                    level_up.directory = true
                                    level_up.previous_directory = true
                                    level_up.save = false
                                    
                                    table.insert(scripts, 1, level_up) -- ...

                                    selection = {}
                                    selection.name = lang_lines.Use_this_directory -- Use_this_directory
                                    selection.directory = true
                                    selection.previous_directory = false
                                    selection.save = true
                                    table.insert(scripts, 2, selection)


                                    i = 1

                            end

                        end


                    end

                elseif Controls.check(pad, SCE_CTRL_CIRCLE_MAP) and not Controls.check(oldpad, SCE_CTRL_CIRCLE_MAP) then
                    
                    local _, dir_level_count = string.gsub(cur_dir_fm, "/", "")
                    if dir_level_count == 1 then
                        oldpad = pad
                        showMenu = 9
                        menuY = selected_partition_menuY
                        scripts = System.listDirectory(selected_partition)
                        scripts_sort_by_folder_first()
                        for k, v in pairs(scripts) do
                            v.previous_directory = false
                            v.save = false
                        end
                        cur_dir_fm = selected_partition
                    else


                        if string.len(cur_dir_fm) > string.len(selected_partition) then -- Excluding partition name eg: ux0:/
                            j=-2
                            while string.sub(cur_dir_fm,j,j) ~= "/" do
                                j=j-1
                            end
                            cur_dir_fm = string.sub(cur_dir_fm,1,j)
                            scripts = System.listDirectory(cur_dir_fm)
                            for k, v in pairs(scripts) do
                                v.previous_directory = false
                                v.save = false
                            end

                            -- Add level up
                            level_up = {}
                            level_up.name = "..."
                            level_up.directory = true
                            level_up.previous_directory = true
                            level_up.save = false
                            table.insert(scripts, 1, level_up) -- ...

                            scripts_sort_by_folder_first()
                           
                            if string.len(cur_dir_fm) > string.len(selected_partition) then -- Excluding partition name eg: ux0:/
                                selection = {}
                                selection.name = lang_lines.Use_this_directory -- Use_this_directory
                                selection.directory = true
                                selection.previous_directory = false
                                selection.save = true
                                table.insert(scripts, 2, selection)
                            end
 
                            i = 1
                        else
                        end

                    end
                elseif Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) then
                    i = i - 1
                elseif Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) then
                    i = i + 1
                elseif Controls.check(pad, SCE_CTRL_TRIANGLE) then
                    -- break
                    showMenu = 8
                    menuY = 2
                    scripts = System.listDirectory(selected_partition)
                    scripts_sort_by_folder_first()
                    for k, v in pairs(scripts) do
                        v.previous_directory = false
                        v.save = false
                    end
                    cur_dir_fm = selected_partition
                end

            -- END ROM BROWSER 

        end

-- MENU 12 - AUDIO
    elseif showMenu == 12 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.Audio, white)--Audio
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection

        -- Hide skip track if no music or only 1 song
        if #music_sequential > 1 then
            menuItems = 4
        else
            menuItems = 3
        end

        -- MENU 12 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back

        -- MENU 12 / #1 SOUNDS
        Font.print(fnt22, setting_x, setting_y1, lang_lines.Sounds_colon, white)--SOUNDS
        if setSounds == 1 then
            Font.print(fnt22, setting_x_offset, setting_y1, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y1, lang_lines.Off, white)--OFF
        end

        -- MENU 12 / #2 MUSIC
        Font.print(fnt22, setting_x, setting_y2, lang_lines.Music_colon, white)--MUSIC
        if setMusic == 1 then
            Font.print(fnt22, setting_x_offset, setting_y2, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y2, lang_lines.Off, white)--OFF
        end

        -- MENU 12 / #3 SHUFFLE MUSIC
        Font.print(fnt22, setting_x, setting_y3, lang_lines.Shuffle_music_colon, white)--SHUFFLE MUSIC
        if setMusicShuffle == 1 then
            Font.print(fnt22, setting_x_offset, setting_y3, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y3, lang_lines.Off, white)--OFF
        end

        -- MENU 12 / #4 SKIP TRACK
        if #music_sequential > 1 then
            Font.print(fnt22, setting_x, setting_y4, lang_lines.Skip_track, white)--SKIP TRACK
        else
        end

        -- MENU 12 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
    
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then
                if menuY == 0 then -- #0 Back
                    showMenu = 2
                    menuY = 3 -- Audio 
                elseif menuY == 1 then -- #1 Sounds
                    if setSounds == 1 then
                        setSounds = 0
                    else
                        setSounds = 1
                    end            
                elseif menuY == 2 then -- #2 Music
                    if setMusic == 1 then
                        setMusic = 0
                        if Sound.isPlaying(sndMusic) then
                            Sound.close(sndMusic)
                        end
                    else
                        setMusic = 1
                        if setMusicShuffle == 1 then
                            Shuffle(music_sequential)
                            track = 1
                            PlayMusic()
                        else
                            track = 1
                            PlayMusic()
                        end
                    end  
                elseif menuY == 3 then -- #3 Shuffle music
                    if setMusicShuffle == 1 then
                        setMusicShuffle = 0
                        if setMusic == 1 then
                            if Sound.isPlaying(sndMusic) then
                                Sound.close(sndMusic)
                                track = 1
                                PlayMusic()
                            end
                        else
                        end
                    else
                        setMusicShuffle = 1
                        if setMusic == 1 then
                            if Sound.isPlaying(sndMusic) then
                                Sound.close(sndMusic)
                                Shuffle(music_sequential)
                                track = 1
                                PlayMusic()
                            end
                        else
                        end
                    end
                elseif menuY == 4 then -- #4 Skip track
                    if setMusic == 1 then
                        if Sound.isPlaying(sndMusic) then
                            Sound.close(sndMusic)
                            track = track + 1 
                            PlayMusic()
                        end
                    else
                    end           
                end

                --Save settings
                SaveSettings()
                
            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                if menuY > 0 then
                    menuY = menuY - 1
                    else
                    menuY=menuItems
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                if menuY < menuItems then
                    menuY = menuY + 1
                    else
                    menuY=0
                end
            end
        end

-- MENU 13 - GUIDE 1
    elseif showMenu == 13 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.guide_1_heading, white)-- Guide 1 Heading
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection

        menuItems = 1
        
        -- MENU 13 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back
        
        -- MENU 13 / #1 Content
        if setLanguage == 8 or setLanguage == 9 or setLanguage == 10 or setLanguage == 17 or setLanguage == 18 or setLanguage == 19 then
            -- Manual text wrapping for non latin alphabets
            Font.print(fnt22, setting_x, setting_y1, lang_lines.guide_1_content, white)-- Guide 1 Content
        else
            Font.print(fnt22, setting_x, setting_y1, wraptextlength(lang_lines.guide_1_content, 75), white)-- Guide 1 Content
        end
        
        -- MENU 13 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 13 / #0 Back
                if menuY == 0 then -- #0 Back
                    showMenu = 7 -- About
                    menuY = 1 -- Guide 1
                end

            end
        end

-- MENU 14 - GUIDE 2
    elseif showMenu == 14 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.guide_2_heading, white)-- Guide 2 Heading
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection

        menuItems = 1
        
        -- MENU 14 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back
        
        -- MENU 14 / #1 Content
        if setLanguage == 8 or setLanguage == 9 or setLanguage == 10 or setLanguage == 17 or setLanguage == 18 or setLanguage == 19 then
            -- Manual text wrapping for non latin alphabets
            Font.print(fnt22, setting_x, setting_y1, lang_lines.guide_2_content, white)-- Guide 2 Content
        else
            Font.print(fnt22, setting_x, setting_y1, wraptextlength(lang_lines.guide_2_content, 75), white)-- Guide 2 Content
        end
        
        -- MENU 14 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 14 / #0 Back
                if menuY == 0 then -- #0 Back
                    showMenu = 7 -- About
                    menuY = 2 -- Guide 2
                end

            end
        end

-- MENU 15 - GUIDE 3
    elseif showMenu == 15 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.guide_3_heading, white)-- Guide 3 Heading
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection

        menuItems = 1
        
        -- MENU 15 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back
        
        -- MENU 15 / #1 Content
        if setLanguage == 8 or setLanguage == 9 or setLanguage == 10 or setLanguage == 17 or setLanguage == 18 or setLanguage == 19 then
            -- Manual text wrapping for non latin alphabets
            Font.print(fnt22, setting_x, setting_y1, lang_lines.guide_3_content, white)-- Guide 3 Content
        else
            Font.print(fnt22, setting_x, setting_y1, wraptextlength(lang_lines.guide_3_content, 75), white)-- Guide 3 Content
        end

        
        -- MENU 15 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 15 / #0 Back
                if menuY == 0 then -- #0 Back
                    showMenu = 7 -- About
                    menuY = 3 -- Guide 3
                end

            end
        end

-- MENU 16 - GUIDE 4
    elseif showMenu == 16 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.guide_4_heading, white)-- Guide 4 Heading
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection

        menuItems = 1
        
        -- MENU 16 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back
        
        -- MENU 16 / #1 Content
        if setLanguage == 8 or setLanguage == 9 or setLanguage == 10 or setLanguage == 17 or setLanguage == 18 or setLanguage == 19 then
            -- Manual text wrapping for non latin alphabets
            Font.print(fnt22, setting_x, setting_y1, lang_lines.guide_4_content, white)-- Guide 4 Content
        else
            Font.print(fnt22, setting_x, setting_y1, wraptextlength(lang_lines.guide_4_content, 75), white)-- Guide 4 Content
        end

        
        -- MENU 16 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 16 / #0 Back
                if menuY == 0 then -- #0 Back
                    showMenu = 7 -- About
                    menuY = 4 -- Guide 4
                end

            end
        end

-- MENU 17 - GUIDE 5
    elseif showMenu == 17 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.guide_5_heading, white)-- Guide 5 Heading
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection

        menuItems = 1
        
        -- MENU 17 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back
        
        -- MENU 17 / #1 Content
        if setLanguage == 8 or setLanguage == 9 or setLanguage == 10 or setLanguage == 17 or setLanguage == 18 or setLanguage == 19 then
            -- Manual text wrapping for non latin alphabets
            Font.print(fnt22, setting_x, setting_y1, lang_lines.guide_5_content, white)-- Guide 5 Content
        else
            Font.print(fnt22, setting_x, setting_y1, wraptextlength(lang_lines.guide_5_content, 75), white)-- Guide 5 Content
        end
        
        -- MENU 17 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 17 / #0 Back
                if menuY == 0 then -- #0 Back
                    showMenu = 7 -- About
                    menuY = 5 -- Guide 5
                end

            end
        end

-- MENU 18 - GUIDE 6
    elseif showMenu == 18 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.guide_6_heading, white)-- Guide 6 Heading
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection

        menuItems = 1
        
        -- MENU 18 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back
        
        -- MENU 18 / #1 Content
        Font.print(fnt22, setting_x, setting_y1, "RetroFlow version " .. appversion, white)-- Guide 6 Content
        
        if setLanguage == 8 or setLanguage == 9 or setLanguage == 10 or setLanguage == 17 or setLanguage == 18 or setLanguage == 19 then
            -- Manual text wrapping for non latin alphabets
            Font.print(fnt22, setting_x, setting_y2, lang_lines.guide_6_content, white)-- Guide 6 Content
        else
            Font.print(fnt22, setting_x, setting_y2, wraptextlength(lang_lines.guide_6_content, 75), white)-- Guide 6 Content
        end

        -- MENU 18 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 18 / #0 Back
                if menuY == 0 then -- #0 Back
                    showMenu = 7 -- About
                    menuY = 6 -- Guide 6
                end

            end
        end

-- MENU 19 - OTHER SETTINGS
    elseif showMenu == 19 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.Other_Settings, white)--Other Settings
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection


        menuItems = 5

        -- MENU 19 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back

        -- MENU 19 / #1 Remap X and O buttons
        Font.print(fnt22, setting_x, setting_y1,  lang_lines.Swap_X_and_O_buttons_colon, white)
        if setSwap_X_O_buttons == 1 then
            Font.print(fnt22, setting_x_offset, setting_y1, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y1, lang_lines.Off, white)--OFF
        end

        -- MENU 19 / #2 Adrenaline PS Button
        Font.print(fnt22, setting_x, setting_y2, lang_lines.Adrenaline_PS_button_colon, white)--Adrenaline PS Button
        if setAdrPSButton == 0 then
            Font.print(fnt22, setting_x_offset, setting_y2, lang_lines.Menu, white)--Menu
        elseif setAdrPSButton == 1 then
            Font.print(fnt22, setting_x_offset, setting_y2, lang_lines.LiveArea, white)--LiveArea
        elseif setAdrPSButton == 2 then
            Font.print(fnt22, setting_x_offset, setting_y2, lang_lines.Standard, white)--Standard
        end

        -- MENU 19 / #3 Show missing covers
        Font.print(fnt22, setting_x, setting_y3,  lang_lines.Show_missing_covers_colon, white)
        if showMissingCovers == 1 then
            Font.print(fnt22, setting_x_offset, setting_y3, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y3, lang_lines.Off, white)--OFF
        end

        -- MENU 19 / #4 Time
        Font.print(fnt22, setting_x, setting_y4, lang_lines.Time_colon, white)--Time
        if setTime == 1 then
            Font.print(fnt22, setting_x_offset, setting_y4, lang_lines.Time_12hr, white)--24-Hour Clock
        else
            Font.print(fnt22, setting_x_offset, setting_y4, lang_lines.Time_24hr, white)--12-Hour Clock
        end

        -- MENU 19 / #5 Edit collections
        Font.print(fnt22, setting_x, setting_y5, lang_lines.Edit_collections, white)--Edit collections

        -- MENU 19 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
    
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then
                if menuY == 0 then -- #0 Back
                    showMenu = 2
                    menuY = 6 -- Other Settings

                elseif menuY == 1 then -- #1 Remap X and O buttons
                    if setSwap_X_O_buttons == 1 then
                        setSwap_X_O_buttons = 0
                    else
                        setSwap_X_O_buttons = 1
                    end
                    Swap_X_O_buttons()
                    oldpad = pad
                    showMenu = 19
                    menuY = 1

                elseif menuY == 2 then -- #2 Adrenaline PS Button
                    if setAdrPSButton < 2 then
                        setAdrPSButton = setAdrPSButton + 1
                    else
                        setAdrPSButton = 0
                    end

                elseif menuY == 3 then -- #3 Show missing covers
                    if showMissingCovers == 1 then

                        -- Show missing covers is now off
                        showMissingCovers = 0
                        

                        -- Does cache contain missing cover info?
                        if games_table[1].cover == nil then

                            -- No, save settings
                            SaveSettings()

                            -- Rescan
                            delete_cache()
                            FreeIcons()
                            FreeMemory()
                            Network.term()
                            dofile("app0:index.lua")
                        else
                            -- Yes, import cache to update
                            FreeIcons()
                            count_cache_and_reload()
                            check_for_out_of_bounds()
                            GetNameAndAppTypeSelected()
                        end

                    else
                        -- Show missing covers is now on
                        showMissingCovers = 1
                        -- Import cache to update
                        FreeIcons()
                        count_cache_and_reload()
                        check_for_out_of_bounds()
                        GetNameAndAppTypeSelected()
                    end
                elseif menuY == 4 then -- #4 Time
                    if setTime == 1 then
                        setTime = 0
                        time24_offset = 0 -- Updates positioning of clock in UI
                    else
                        setTime = 1
                        time24_offset = 25 -- Updates positioning of clock in UI
                    end
                elseif menuY == 5 then -- #5 Edit collections
                    showMenu = 24 
                    menuY = 0
                end

                --Save settings
                SaveSettings()

            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                if menuY > 0 then
                    menuY = menuY - 1
                    else
                    menuY=menuItems
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                if menuY < menuItems then
                    menuY = menuY + 1
                    else
                    menuY=0
                end
            end
            
        end


-- MENU 20 - GAME OPTIONS
    elseif showMenu == 20 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select


        -- GET MENU ITEM COUNT (Some menus app type specific)
            
            menuItems = 3
            
            -- Check for dynamic menu item
            local adrenaline_flag = false
            if apptype == 1 or apptype == 2 or apptype == 3 or apptype == 4 then
                if string.match (xCatLookup(showCat)[p].game_path, "pspemu") and not System.doesFileExist(xCatLookup(showCat)[p].game_path .. "/EBOOT.PBP") then
                    
                    adrenaline_flag = true
                    menuItems = menuItems + 1
                else
                    adrenaline_flag = false
                    menuItems = menuItems
                end
            end

            -- Add extra for remove from recent
            local recent_cat_flag = false
            if showCat == 45 then
                recent_cat_flag = true
                menuItems = menuItems + 1
            else
                if #recently_played_table ~= nil then
                    local key = find_game_table_pos_key(recently_played_table, app_titleid)
                    if key ~= nil then
                        recent_cat_flag = true
                        menuItems = menuItems + 1
                    else
                        recent_cat_flag = false
                    end
                end
            end

            -- Add extra for remove from collection
            remove_from_collection_flag = false

            collection_removal_table = {}
            
            if #collection_files > 0 then
                local check_collection_number = 0
                local count_of_matches = 0
                while check_collection_number < #collection_files do
                    check_collection_number = check_collection_number + 1

                    found = check_if_game_is_in_collection_table(check_collection_number)
                    if found == true then
                        count_of_matches = count_of_matches + 1
                        matched_collection_num = check_collection_number
                        collection_removal_table[count_of_matches]={matched_collection_num = check_collection_number}
                        -- table.insert(collection_removal_table, count_of_matches, matched_collection_num)
                    else
                    end

                end
            end
 
            if #collection_removal_table == 0 then
                remove_from_collection_flag = false
            else
                remove_from_collection_flag = true
                menuItems = menuItems + 1
            end

            if apptype == 43 then
                menuItems = menuItems + 1
            end

            -- Calculate vertical centre
            vertically_centre_mini_menu(menuItems)

        -- GRAPHIC SETUP
        
            -- Apply mini menu margins
            local setting_x = setting_x + mini_menu_x_margin

            -- Draw black overlay
            Graphics.fillRect(0, 960, 0, 540, blackalpha)

            -- Draw footer
            Graphics.fillRect(0, 960, 496, 544, themeCol)

            Graphics.drawImage(900-label1, 510, btnO)
            Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

            Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
            Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select
            
            -- Draw dark overlay
            Graphics.fillRect(60 + mini_menu_x_margin, 900 - mini_menu_x_margin, y_centre_top_margin, y_centre_top_margin + y_centre_box_height, dark)

            -- Draw white line
            Graphics.fillRect(60 + mini_menu_x_margin, 900 - mini_menu_x_margin, y_centre_white_line_start, y_centre_white_line_start + 3, white)
            
            -- Draw selection
            Graphics.fillRect(60 + mini_menu_x_margin, 900 - mini_menu_x_margin, y_centre_selection_start + (menuY * 47), y_centre_selection_end + (menuY * 47), themeCol)-- selection


        -- MENU 20 / Heading
        GetInfoSelected() -- Get game info for heading
        Font.print(fnt22, setting_x, setting_yh + y_centre_text_offset, app_title, white)--Game Options

        -- MENU 20 / #0 Favorites
        if favourite_flag == true then
            Font.print(fnt22, setting_x, setting_y0 + y_centre_text_offset, lang_lines.Remove_from_favorites, white)--Remove from favourites
        else
            Font.print(fnt22, setting_x, setting_y0 + y_centre_text_offset, lang_lines.Add_to_favorites, white)--Add to favourites
        end

        -- MENU 20 / #1 Rename
        Font.print(fnt22, setting_x, setting_y1 + y_centre_text_offset, lang_lines.Rename, white)--Rename

        -- MENU 20 / #2 Hide Game
        if hide_game_flag == true then
            Font.print(fnt22, setting_x, setting_y2 + y_centre_text_offset, lang_lines.Unhide_game, white)--Unhide game
        else
            Font.print(fnt22, setting_x, setting_y2 + y_centre_text_offset, lang_lines.Hide_game, white)--Hide game
        end

        -- MENU 20 / #3 Add to collection
        Font.print(fnt22, setting_x, setting_y3 + y_centre_text_offset, lang_lines.Add_to_collection, white)--Add to collection


        -- MENU 20 / #4 / #5 / #6 - Dynamic based on Remove from collection / Recent Category / Adrenaline options
        if remove_from_collection_flag == true then

            Font.print(fnt22, setting_x, setting_y4 + y_centre_text_offset, lang_lines.Remove_from_collection, white)--Remove from collection

            if recent_cat_flag == true then
                if adrenaline_flag == true then
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Adrenaline_options, white)--Adrenaline options
                    Font.print(fnt22, setting_x, setting_y6 + y_centre_text_offset, lang_lines.Remove_from_recently_played, white)--Remove from recently played
                elseif apptype == 43 then
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Configure_game_in_DSVita, white)-- DSVita configuration
                    Font.print(fnt22, setting_x, setting_y6 + y_centre_text_offset, lang_lines.Remove_from_recently_played, white)--Remove from recently played
                else
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Remove_from_recently_played, white)--Remove from recently played
                end
            else
                if adrenaline_flag == true then
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Adrenaline_options, white)--Adrenaline options
                elseif apptype == 43 then
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Configure_game_in_DSVita, white)-- DSVita configuration
                end
            end

        else

            if recent_cat_flag == true then
                if adrenaline_flag == true then
                    Font.print(fnt22, setting_x, setting_y4 + y_centre_text_offset, lang_lines.Adrenaline_options, white)--Adrenaline options
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Remove_from_recently_played, white)--Remove from recently played
                elseif apptype == 43 then
                    Font.print(fnt22, setting_x, setting_y4 + y_centre_text_offset, lang_lines.Configure_game_in_DSVita, white)-- DSVita configuration
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Remove_from_recently_played, white)--Remove from recently played
                else
                    Font.print(fnt22, setting_x, setting_y4 + y_centre_text_offset, lang_lines.Remove_from_recently_played, white)--Remove from recently played
                end
            else
                if adrenaline_flag == true then
                    Font.print(fnt22, setting_x, setting_y4 + y_centre_text_offset, lang_lines.Adrenaline_options, white)--Adrenaline options
                elseif apptype == 43 then
                    Font.print(fnt22, setting_x, setting_y4 + y_centre_text_offset, lang_lines.Configure_game_in_DSVita, white)-- DSVita configuration
                end
            end

        end
        
        
        
        -- MENU 20 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then


                -- DYNAMIC MENU FUNCTIONS
                    function dynamic_menu_remove_from_collection()
                        showMenu = 23
                        menuY = 0
                    end

                    function dynamic_menu_adrenaline_menu()
                        game_adr_bin_driver = 0
                        game_adr_exec_bin = 0

                        game_adr_plugins = 0
                        game_adr_speed = 0
                        game_adr_hm = 0
                        game_adr_nonpdrm = 0
                        game_adr_suspend = 0

                        -- Get existing settings
                        local key = find_game_table_pos_key(launch_overrides_table, app_titleid)
                        if key ~= nil then
                            -- Yes - it's already in the launch override list, update it.
                            game_adr_bin_driver = launch_overrides_table[key].driver
                            game_adr_exec_bin = launch_overrides_table[key].bin

                            game_adr_plugins = launch_overrides_table[key].plugins
                            game_adr_speed = launch_overrides_table[key].speed
                            game_adr_hm = launch_overrides_table[key].hm
                            game_adr_nonpdrm = launch_overrides_table[key].nonpdrm
                            game_adr_suspend = launch_overrides_table[key].suspend
                        end

                        showMenu = 21
                        menuY = 0
                    end

                    function dynamic_menu_dsvita_config()
                        -- Launch preflight check
                        check_app_installed("DSVITA000", lang_lines.Emulator_not_installed_DSVita)

                        if launch_check_app_installed == true then
                            prepare_for_launch()
                            System.launchApp("DSVITA000")
                            System.exit()
                        end
                    end

                    function dynamic_menu_remove_from_recent()
                        -- remove recent
                        if #recently_played_table ~= nil then
                            if showCat == 45 then
                                -- We are in the recent category, remove the game and save cache
                                table.remove(recently_played_table, p)
                                update_cached_table_recently_played()
                                oldpad = pad -- Prevents it from launching next game accidentally
                                showMenu = 0
                                Render.useTexture(modBackground, imgCustomBack)
                                check_for_out_of_bounds()
                                GetInfoSelected()
                            else
                                -- We are NOT the recent category, Find game in recent table and remove, then save cache
                                key = find_game_table_pos_key(recently_played_table, app_titleid)
                                if key ~= nil then
                                    table.remove(recently_played_table, key)
                                    update_cached_table_recently_played()
                                    GetInfoSelected()
                                    menuY = 0
                                else
                                end
                            end
                        end
                    end

                -- MENU 20
                if menuY == 0 then -- #0 Favorites
                    -- Favourites
                    AddOrRemoveFavorite()

                    -- Update text
                    if favourite_flag == true then
                        favourite_flag = false
                    else
                        favourite_flag = true
                    end

                    -- If on favorite category, go to main screen, otherwise the next fav game is shown
                    if showCat == 44 then
                        check_for_out_of_bounds()
                        GetInfoSelected()
                        oldpad = pad -- Prevents it from launching next game accidentally. Credit BlackSheepBoy69
                        showMenu = 0
                        Render.useTexture(modBackground, imgCustomBack)
                    end
                    
                elseif menuY == 1 then -- #1 Rename
                    -- Rename
                    if hasTyped==false then
                        Keyboard.start(tostring(lang_lines.Rename), app_title:gsub("\n",""), 512, TYPE_LATIN, MODE_TEXT)
                        hasTyped=true
                        keyboard_rename=true
                    end
                    
                elseif menuY == 2 then -- #2 Hide Game
                    
                    GetInfoSelected()

                    -- Update text
                    if hide_game_flag == true then
                        hide_game_flag = false
                    else
                        hide_game_flag = true
                    end

                    -- Update hidden games lua file

                    -- Update other tables in realtime
                    AddOrRemoveHidden(hide_game_flag)

                        -- Check if the hidden game table is empty
                        if #hidden_games_table ~= nil then -- Is not empty

                            -- Check if game is already in the list
                            local key = find_game_table_pos_key(hidden_games_table, app_titleid)
                            if key ~= nil then
                                -- Game found - If set to unhide, then remove from table
                                hidden_games_table[key].hidden = hide_game_flag
                            else
                                -- Game not found, it's new, add it to the hidden list

                                -- Find game in app table, update and add to hidden
                                local key = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
                                if key ~= nil then
                                    table.insert(hidden_games_table, xAppNumTableLookup(apptype)[key])
                                else
                                end

                            end

                        else -- Is empty, add first game to hide 
                            -- Find game in app table, update and add to hidden
                            local key = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
                            if key ~= nil then
                                table.insert(hidden_games_table, xAppNumTableLookup(apptype)[key])
                            else
                            end
                        end

                        -- Clean up the hidden games table by removing unhidden games
                        local i = 1
                        while i <= #hidden_games_table do
                            if hidden_games_table[i].hidden == false then
                                table.remove(hidden_games_table, i)
                            else
                                i = i + 1
                            end
                        end

                        -- Save the cleaned hidden game table for importing on restart
                        update_cached_table_hidden_games()


                    -- If show system apps if off and currently viewing system apps when renaming, must have used quick menu.
                    -- Turn on system apps temporarily so can see the result of the rename.
                    if showSysApps == 0 and showCat == 43 then
                        -- Turn on temporarily
                        showSysApps = 1

                        -- Import and jump to menu
                        FreeIcons()
                        count_cache_and_reload()
                        showCat = 43

                        -- Turn off again, the table will be removed when the user changes category (see category controls, square)
                        showSysApps = 0
                    else
                        FreeIcons()
                        count_cache_and_reload()
                        GetInfoSelected()
                    end

                    if showHidden == 0 then

                        -- Rebuild search results if we're in search category
                        if showCat == 46 and ret_search and random_game_selected == false then
                            -- Store current search results parameters
                            local current_search_text = ret_search
                            local current_search_lc = ret_search_lc
                            local current_search_uc = ret_search_uc
                            local current_search_pc = ret_search_pc

                            -- Clear and rebuild search results
                            search_results_table = {}
                            for l, file in pairs(files_table) do
                                if string.match(file.apptitle, escape_pattern(current_search_text)) or 
                                    string.match(file.apptitle, escape_pattern(current_search_lc)) or 
                                    string.match(file.apptitle, escape_pattern(current_search_uc)) or 
                                    string.match(file.apptitle, escape_pattern(current_search_pc)) and
                                    file.hidden == false then
                                    table.insert(search_results_table, file)
                                end
                            end
                            if search_results_table ~= nil then
                                table.sort(search_results_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
                            end
                        end


                        oldpad = pad -- Prevents it from launching next game accidentally. Credit BlackSheepBoy69
                        showMenu = 0
                        Render.useTexture(modBackground, imgCustomBack)
                        GetNameAndAppTypeSelected()
                    else

                        -- Rebuild favorites table if we're in favorites category
                        if showCat == 44 then
                            create_fav_count_table(files_table)
                        end

                        -- Handle both search results and random game in category 46
                        if showCat == 46 then
                            if random_game_selected then
                                -- Handle random game case
                                search_results_table = {}
                                if random_game then
                                    -- Find and add the random game to the results
                                    for _, file in pairs(files_table) do
                                        if file.name == random_game then
                                            table.insert(search_results_table, file)
                                            break
                                        end
                                    end
                                end
                            elseif ret_search then
                                -- Handle search case
                                local current_search_text = ret_search
                                local current_search_lc = ret_search_lc
                                local current_search_uc = ret_search_uc
                                local current_search_pc = ret_search_pc

                                -- Clear and rebuild search results
                                search_results_table = {}
                                for _, file in pairs(files_table) do
                                    if string.match(file.apptitle, escape_pattern(current_search_text)) or 
                                       string.match(file.apptitle, escape_pattern(current_search_lc)) or 
                                       string.match(file.apptitle, escape_pattern(current_search_uc)) or 
                                       string.match(file.apptitle, escape_pattern(current_search_pc)) then
                                        table.insert(search_results_table, file)
                                    end
                                end
                                table.sort(search_results_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
                            end
                        end


                        -- Handle hiding/unhiding for both search results and random game
                        if showCat == 46 then
                            if random_game_selected and #search_results_table > 0 then
                                -- For random game, update its hidden status in the files_table
                                local game = search_results_table[1]
                                if game then
                                    -- Find the game in the main files table and update its hidden status
                                    for _, file in pairs(files_table) do
                                        if file.name == game.name then
                                            file.hidden = hide_game_flag
                                            -- Update the search results table entry as well
                                            game.hidden = hide_game_flag
                                            break
                                        end
                                    end
                                end
                            elseif not random_game_selected and ret_search then
                                -- For search results, recheck hidden status for all results
                                for _, result in ipairs(search_results_table) do
                                    -- do nothing
                                end
                            end
                        end

                        GetInfoSelected()
                        -- Instant cover update - Credit BlackSheepBoy69
                        Threads.addTask(xCatLookup(showCat)[p], {
                        Type = "ImageLoad",
                        Path = xCatLookup(showCat)[p].icon_path,
                        Table = xCatLookup(showCat)[p],
                        Index = "ricon"
                        })
                    end

                elseif menuY == 3 then 
                    showMenu = 22 -- Add to collection
                    menuY = 0
                elseif menuY == 4 then 
                    -- Dynamic menu
                    if remove_from_collection_flag == true then
                        dynamic_menu_remove_from_collection()
                    else
                        if adrenaline_flag == true then
                            dynamic_menu_adrenaline_menu()
                        elseif apptype == 43 then
                            dynamic_menu_dsvita_config()
                        else
                            if recent_cat_flag == true then
                                dynamic_menu_remove_from_recent()
                            else
                            end
                        end
                    end
                elseif menuY == 5 then
                    if remove_from_collection_flag == true then
                        if adrenaline_flag == true then
                            dynamic_menu_adrenaline_menu()
                        elseif apptype == 43 then
                            dynamic_menu_dsvita_config()
                        else
                            if recent_cat_flag == true then
                                dynamic_menu_remove_from_recent()
                            else
                            end
                        end
                    else
                        dynamic_menu_remove_from_recent()
                    end    
                        
                elseif menuY == 6 then -- #5 - Dynamic based on Recent Category and Adrenaline options
                    if recent_cat_flag == true then
                        dynamic_menu_remove_from_recent()
                    else
                    end                    
                end


            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY > 0 then
                        menuY = menuY - 1
                        else
                        menuY=menuItems
                    end
                else
                end

                
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY < menuItems then
                        menuY = menuY + 1
                        else
                        menuY=0
                    end
                else
                end
            elseif Controls.check(pad, SCE_CTRL_CIRCLE_MAP) and not Controls.check(oldpad, SCE_CTRL_CIRCLE_MAP) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    oldpad = pad
                    GetInfoSelected()
                    showMenu = 1
                    menuY=0
                else
                end
            end
        end



-- MENU 21 - ADRENALINE OPTIONS
    elseif showMenu == 21 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select


        -- GET MENU ITEM COUNT
            
            menuItems = 8
            
        -- Calculate vertical centre
            vertically_centre_mini_menu(menuItems)

        -- GRAPHIC SETUP
        
            -- Apply mini menu margins
            local setting_x = setting_x + mini_menu_x_margin

            -- Draw black overlay
            Graphics.fillRect(0, 960, 0, 540, blackalpha)

            -- Draw footer
            Graphics.fillRect(0, 960, 496, 544, themeCol)

            Graphics.drawImage(900-label1, 510, btnO)
            Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

            Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
            Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select
            
            -- Draw dark overlay
            Graphics.fillRect(60 + mini_menu_x_margin, 900 - mini_menu_x_margin, y_centre_top_margin, y_centre_top_margin + y_centre_box_height, dark)

            -- Draw white line
            Graphics.fillRect(60 + mini_menu_x_margin, 900 - mini_menu_x_margin, y_centre_white_line_start, y_centre_white_line_start + 3, white)
            
            -- Draw selection
            Graphics.fillRect(60 + mini_menu_x_margin, 900 - mini_menu_x_margin, y_centre_selection_start + (menuY * 47), y_centre_selection_end + (menuY * 47), themeCol)-- selection


        -- MENU 21 / Heading
        Font.print(fnt22, setting_x, setting_yh + y_centre_text_offset, lang_lines.Adrenaline_options, white)--Adrenaline options

        -- MENU 21 / #0 Back
        Font.print(fnt22, setting_x, setting_y0 + y_centre_text_offset, lang_lines.Back_Chevron, white)--Back

        -- MENU 21 / #1 Driver
        Font.print(fnt22, setting_x, setting_y1 + y_centre_text_offset, lang_lines.Driver_colon, white)--Driver

        

        -- Menu
        if game_adr_bin_driver == 1 then
            Font.print(fnt22, setting_x_offset, setting_y1 + y_centre_text_offset, "<  " .. "INFERNO" .. "  >", white)
        elseif game_adr_bin_driver == 2 then
            Font.print(fnt22, setting_x_offset, setting_y1 + y_centre_text_offset, "<  " .. "MARCH33" .. "  >", white)
        elseif game_adr_bin_driver == 3 then
            Font.print(fnt22, setting_x_offset, setting_y1 + y_centre_text_offset, "<  " .. "NP9660" .."  >", white)
        else
            if setLanguage == 11 then
                -- Use alternate translation for Polish
                Font.print(fnt22, setting_x_offset, setting_y1 + y_centre_text_offset, "<  " .. lang_lines.Default_alt_translation_2 .. "  >", white)
            else
                Font.print(fnt22, setting_x_offset, setting_y1 + y_centre_text_offset, "<  " .. lang_lines.Default .. "  >", white)
            end
        end

        -- MENU 21 / #2 Execute bin
        Font.print(fnt22, setting_x, setting_y2 + y_centre_text_offset, lang_lines.Execute_colon, white)--Execute

        if game_adr_exec_bin == 1 then
            Font.print(fnt22, setting_x_offset, setting_y2 + y_centre_text_offset, "<  " .. "EBOOT.BIN" .. "  >", white)
        elseif game_adr_exec_bin == 2 then
            Font.print(fnt22, setting_x_offset, setting_y2 + y_centre_text_offset, "<  " .. "EBOOT.OLD" .. "  >", white)
        elseif game_adr_exec_bin == 3 then
            Font.print(fnt22, setting_x_offset, setting_y2 + y_centre_text_offset, "<  " .. "BOOT.BIN" .."  >", white)
        else
            if setLanguage == 11 then
                -- Use alternate translation for Polish
                Font.print(fnt22, setting_x_offset, setting_y2 + y_centre_text_offset, "<  " .. lang_lines.Default_alt_translation_2 .. "  >", white)
            else
                Font.print(fnt22, setting_x_offset, setting_y2 + y_centre_text_offset, "<  " .. lang_lines.Default .. "  >", white)
            end
        end

        -- MENU 21 / #3 Plugins
        Font.print(fnt22, setting_x, setting_y3 + y_centre_text_offset, lang_lines.Plugins_colon, white)--Plugins
        if game_adr_plugins == 1 then
            Font.print(fnt22, setting_x_offset, setting_y3 + y_centre_text_offset, "<  " .. lang_lines.Enable .. "  >", white)
        elseif game_adr_plugins == 2 then
            Font.print(fnt22, setting_x_offset, setting_y3 + y_centre_text_offset, "<  " .. lang_lines.Disable .. "  >", white)
        else
            if setLanguage == 11 then
                -- Use alternate translation for Polish
                Font.print(fnt22, setting_x_offset, setting_y3 + y_centre_text_offset, "<  " .. lang_lines.Default_alt_translation_2 .. "  >", white)
            else
                Font.print(fnt22, setting_x_offset, setting_y3 + y_centre_text_offset, "<  " .. lang_lines.Default .. "  >", white)
            end
        end
        

        -- MENU 21 / #4 CPU speed
        Font.print(fnt22, setting_x, setting_y4 + y_centre_text_offset, lang_lines.CPU_speed_colon, white)--CPU speed
        if game_adr_speed == 1 then
            Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. "20/10" .. "  >", white)
        elseif game_adr_speed == 2 then
            Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. "50/25" .. "  >", white)
        elseif game_adr_speed == 3 then
            Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. "75/37" .. "  >", white)
        elseif game_adr_speed == 4 then
            Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. "100/50" .. "  >", white)
        elseif game_adr_speed == 5 then
            Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. "111/55" .. "  >", white)
        elseif game_adr_speed == 6 then
            Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. "122/61" .. "  >", white)
        elseif game_adr_speed == 7 then
            Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. "133/66" .. "  >", white)
        elseif game_adr_speed == 8 then
            Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. "166/83" .. "  >", white)
        elseif game_adr_speed == 9 then
            Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. "200/100" .. "  >", white)
        elseif game_adr_speed == 10 then
            Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. "222/111" .. "  >", white)
        elseif game_adr_speed == 11 then
            Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. "266/133" .. "  >", white)
        elseif game_adr_speed == 12 then
            Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. "288/144" .. "  >", white)
        elseif game_adr_speed == 13 then
            Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. "300/150" .. "  >", white)
        elseif game_adr_speed == 14 then
            Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. "333/166" .. "  >", white)
        else
            if setLanguage == 11 then
                -- Use alternate translation for Polish
                Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. lang_lines.Default_alt_translation_2 .. "  >", white)
            else
                Font.print(fnt22, setting_x_offset, setting_y4 + y_centre_text_offset, "<  " .. lang_lines.Default .. "  >", white)
            end
        end

        -- MENU 21 / #5 High memory
        Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.High_memory_colon, white)--High memory
        if game_adr_hm == 1 then
            Font.print(fnt22, setting_x_offset, setting_y5 + y_centre_text_offset, "<  " .. lang_lines.Enable .. "  >", white)
        elseif game_adr_hm == 2 then
            Font.print(fnt22, setting_x_offset, setting_y5 + y_centre_text_offset, "<  " .. lang_lines.Disable .. "  >", white)
        else
            if setLanguage == 11 then
                -- Use alternate translation for Polish
                Font.print(fnt22, setting_x_offset, setting_y5 + y_centre_text_offset, "<  " .. lang_lines.Default_alt_translation_2 .. "  >", white)
            else
                Font.print(fnt22, setting_x_offset, setting_y5 + y_centre_text_offset, "<  " .. lang_lines.Default .. "  >", white)
            end
        end

        -- MENU 21 / #6 NoDRM engine
        Font.print(fnt22, setting_x, setting_y6 + y_centre_text_offset, lang_lines.NoDRM_engine_colon, white)--NoDRM engine
        if game_adr_nonpdrm == 1 then
            Font.print(fnt22, setting_x_offset, setting_y6 + y_centre_text_offset, "<  " .. lang_lines.Enable .. "  >", white)
        elseif game_adr_nonpdrm == 2 then
            Font.print(fnt22, setting_x_offset, setting_y6 + y_centre_text_offset, "<  " .. lang_lines.Disable .. "  >", white)
        else
            if setLanguage == 11 then
                -- Use alternate translation for Polish
                Font.print(fnt22, setting_x_offset, setting_y6 + y_centre_text_offset, "<  " .. lang_lines.Default_alt_translation_2 .. "  >", white)
            else
                Font.print(fnt22, setting_x_offset, setting_y6 + y_centre_text_offset, "<  " .. lang_lines.Default .. "  >", white)
            end
        end

        -- MENU 21 / #7 Suspend threads
        Font.print(fnt22, setting_x, setting_y7 + y_centre_text_offset, lang_lines.Suspend_threads_colon, white)--Suspend threads
        if game_adr_suspend == 1 then
            Font.print(fnt22, setting_x_offset, setting_y7 + y_centre_text_offset, "<  " .. lang_lines.No .. "  >", white)
        else
            Font.print(fnt22, setting_x_offset, setting_y7 + y_centre_text_offset, "<  " .. lang_lines.Yes .. "  >", white)
        end

        -- MENU 21 / #8 Save
        Font.print(fnt22, setting_x, setting_y8 + y_centre_text_offset, lang_lines.Save, white)--Save

        
        -- MENU 21 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 21
                if menuY == 0 then -- #0 Back
                    showMenu = 20
                    if remove_from_collection_flag == true then
                        menuY=5
                    else
                        menuY=4
                    end

                elseif menuY == 8 then -- #3 Save the setting
                    
                    if #launch_overrides_table ~= nil then
                        local key = find_game_table_pos_key(launch_overrides_table, app_titleid)
                        if key ~= nil then
                            -- Yes - it's already in the launch override list, update it.
                            launch_overrides_table[key].driver = game_adr_bin_driver
                            launch_overrides_table[key].bin = game_adr_exec_bin
                            launch_overrides_table[key].plugins = game_adr_plugins
                            launch_overrides_table[key].speed = game_adr_speed
                            launch_overrides_table[key].hm = game_adr_hm
                            launch_overrides_table[key].nonpdrm = game_adr_nonpdrm
                            launch_overrides_table[key].suspend = game_adr_suspend

                        else
                            -- No, it's new, add it to the launch override list
                            launch_overrides_temp = {}
                            table.insert(launch_overrides_temp, {
                                name = app_titleid, 
                                driver = game_adr_bin_driver, 
                                bin = game_adr_exec_bin, 
                                plugins = game_adr_plugins,
                                speed = game_adr_speed,
                                hm = game_adr_hm,
                                nonpdrm = game_adr_nonpdrm,
                                suspend = game_adr_suspend,
                                apptitle = app_title, app_type = apptype})

                            for i, file in ipairs(launch_overrides_temp) do
                                table.insert(launch_overrides_table, file)
                            end
                        end
                        -- Save the renamed table for importing on restart
                        update_cached_table_launch_overrides()
                        showMenu = 20
                        if remove_from_collection_flag == true then
                            menuY=5
                        else
                            menuY=4
                        end
                    else
                    end

                    -- Save the setting
                else
                end
            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                if menuY > 0 then
                    menuY = menuY - 1
                    else
                    menuY=menuItems
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                if menuY < menuItems then
                    menuY = menuY + 1
                    else
                    menuY=0
                end
            elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then
                if menuY == 1 then -- #1 Driver
                    if game_adr_bin_driver > 0 then
                        game_adr_bin_driver = game_adr_bin_driver - 1
                    else
                        game_adr_bin_driver = 3
                    end
                elseif menuY == 2 then -- #2 Execute bin
                    if game_adr_exec_bin > 0 then
                        game_adr_exec_bin = game_adr_exec_bin - 1
                    else
                        game_adr_exec_bin = 3
                    end
                elseif menuY == 3 then -- #3 Plugins
                    if game_adr_plugins > 0 then
                        game_adr_plugins = game_adr_plugins - 1
                    else
                        game_adr_plugins = 2
                    end
                elseif menuY == 4 then -- #4 CPU speed
                    if game_adr_speed > 0 then
                        game_adr_speed = game_adr_speed - 1
                    else
                        game_adr_speed = 14
                    end
                elseif menuY == 5 then -- #5 High memory
                    if game_adr_hm > 0 then
                        game_adr_hm = game_adr_hm - 1
                    else
                        game_adr_hm = 2
                    end
                elseif menuY == 6 then -- #6 NoDRM engine
                    if game_adr_nonpdrm > 0 then
                        game_adr_nonpdrm = game_adr_nonpdrm - 1
                    else
                        game_adr_nonpdrm = 2
                    end
                elseif menuY == 7 then -- #7 Suspend threads
                    if game_adr_suspend > 0 then
                        game_adr_suspend = game_adr_suspend - 1
                    else
                        game_adr_suspend = 1
                    end
                else
                end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
                if menuY == 1 then -- #1 Driver
                    if game_adr_bin_driver < 3 then
                        game_adr_bin_driver = game_adr_bin_driver + 1
                    else
                        game_adr_bin_driver = 0
                    end

                elseif menuY == 2 then -- #2 Execute bin
                    if game_adr_exec_bin < 3 then
                        game_adr_exec_bin = game_adr_exec_bin + 1
                    else
                        game_adr_exec_bin = 0
                    end
                elseif menuY == 3 then -- #3 Plugins
                    if game_adr_plugins < 2 then
                        game_adr_plugins = game_adr_plugins + 1
                    else
                        game_adr_plugins = 0
                    end
                elseif menuY == 4 then -- #4 CPU speed
                    if game_adr_speed < 14 then
                        game_adr_speed = game_adr_speed + 1
                    else
                        game_adr_speed = 0
                    end
                elseif menuY == 5 then -- #5 High memory
                    if game_adr_hm < 2 then
                        game_adr_hm = game_adr_hm + 1
                    else
                        game_adr_hm = 0
                    end
                elseif menuY == 6 then -- #6 NoDRM engine
                    if game_adr_nonpdrm < 2 then
                        game_adr_nonpdrm = game_adr_nonpdrm + 1
                    else
                        game_adr_nonpdrm = 0
                    end
                elseif menuY == 7 then -- #7 Suspend threads
                    if game_adr_suspend < 1 then
                        game_adr_suspend = game_adr_suspend + 1
                    else
                        game_adr_suspend = 0
                    end
                else
                end


            elseif Controls.check(pad, SCE_CTRL_CIRCLE_MAP) and not Controls.check(oldpad, SCE_CTRL_CIRCLE_MAP) then
                oldpad = pad
                GetInfoSelected()
                showMenu = 20
                if remove_from_collection_flag == true then
                    menuY=5
                else
                    menuY=4
                end
            end
        end


-- MENU 22 - ADD TO COLLECTION
    elseif showMenu == 22 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select


        -- GET MENU ITEM COUNT
            
            menuItems = 2
            
        -- Calculate vertical centre
            vertically_centre_mini_menu(menuItems)

        -- GRAPHIC SETUP
        
            -- Apply mini menu margins
            local setting_x = setting_x + mini_menu_x_margin

            -- Draw black overlay
            Graphics.fillRect(0, 960, 0, 540, blackalpha)

            -- Draw footer
            Graphics.fillRect(0, 960, 496, 544, themeCol)

            Graphics.drawImage(900-label1, 510, btnO)
            Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

            Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
            Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select
            
            -- Draw dark overlay
            Graphics.fillRect(60 + mini_menu_x_margin, 900 - mini_menu_x_margin, y_centre_top_margin, y_centre_top_margin + y_centre_box_height, dark)

            -- Draw white line
            Graphics.fillRect(60 + mini_menu_x_margin, 900 - mini_menu_x_margin, y_centre_white_line_start, y_centre_white_line_start + 3, white)
            
            -- Draw selection
            Graphics.fillRect(60 + mini_menu_x_margin, 900 - mini_menu_x_margin, y_centre_selection_start + (menuY * 47), y_centre_selection_end + (menuY * 47), themeCol)-- selection


        -- MENU 22 / Heading
        Font.print(fnt22, setting_x, setting_yh + y_centre_text_offset, lang_lines.Add_to_collection, white)--Add to collection

        -- MENU 22 / #0 Back
        Font.print(fnt22, setting_x, setting_y0 + y_centre_text_offset, lang_lines.Back_Chevron, white)--Back

        -- MENU 22 / #1 Collections
        Font.print(fnt22, setting_x, setting_y1 + y_centre_text_offset, lang_lines.Collections_colon, white)--Collections:

        -- Menu
        if collection_number == 0 then 
            Font.print(fnt22, setting_x_offset, setting_y1 + y_centre_text_offset, "<  " .. lang_lines.New_collection .. "  >", white)
        else
            Font.print(fnt22, setting_x_offset, setting_y1 + y_centre_text_offset, "<  " .. collection_files[collection_number].display_name .. "  >", white)
        end


        -- MENU 22 / #3 Add to collection
        Font.print(fnt22, setting_x, setting_y2 + y_centre_text_offset, lang_lines.Add_to_collection, white)--Add to collection

        
        -- MENU 22 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 22
                if menuY == 0 then -- #0 Back
                    showMenu = 20
                    menuY=3

                elseif menuY == 2 then -- #3 Add to collection
                    
                    -- Existing collection
                    if collection_number > 0 then
                        
                        -- Check if game is already in the collection list
                        if check_if_game_is_in_collection_table(collection_number) == false then


                            if xCollectionTableLookup(collection_number)[1].custom_sort_order ~= nil then
                                cc_already_custom = true
                            end

                            -- Create new table of basic info
                            game_info_for_collection = {}

                            if cc_already_custom == true then

                                -- Target collection has custom sorting, include 'custom_sort_order' field and add to the end
                                game_info_for_collection = 
                                { 
                                    [1] = 
                                    {
                                        ["apptitle"] = xCatLookup(showCat)[p].title,
                                        ["name"] = xCatLookup(showCat)[p].name,
                                        ["app_type"] = xCatLookup(showCat)[p].app_type,
                                        ["custom_sort_order"] = #xCollectionTableLookup(collection_number) + 1,
                                    },
                                }
                            else

                                -- Target collection does not have custom sorting, exclude 'custom_sort_order' field
                                game_info_for_collection = 
                                { 
                                    [1] = 
                                    {
                                        ["apptitle"] = xCatLookup(showCat)[p].title,
                                        ["name"] = xCatLookup(showCat)[p].name,
                                        ["app_type"] = xCatLookup(showCat)[p].app_type,
                                    },
                                }
                            end

                            -- Add basic info from games aleady in the collection to the table
                            for i, file in pairs(xCollectionTableLookup(collection_number)) do
                                existing_collection_info = {}
                                existing_collection_info.apptitle = file.title
                                existing_collection_info.name = file.name
                                existing_collection_info.app_type = file.app_type
                                if cc_already_custom == true then
                                    existing_collection_info.custom_sort_order = file.custom_sort_order
                                end
                                table.insert(game_info_for_collection, existing_collection_info)
                            end

                            -- Sort the table and cache
                            table.sort(game_info_for_collection, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
                            update_cached_collection(collection_files[collection_number].filename, game_info_for_collection)
                        end

                        -- Import the cached tables
                        import_collections()

                        GetInfoSelected()
                        oldpad = pad -- Prevents it from launching next game accidentally. Credit BlackSheepBoy69
                        showMenu = 0
                        Render.useTexture(modBackground, imgCustomBack)
                        collection_number = 0
                        -- menuY=3

                    else

                        -- Keyboard input to create table
                        if hasTyped==false then
                            Keyboard.start(tostring(lang_lines.New_collection_name), "", 512, TYPE_LATIN, MODE_TEXT)
                            hasTyped=true
                            keyboard_collection_name_new=true
                        end

                    end

                else
                end
            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY > 0 then
                        menuY = menuY - 1
                        else
                        menuY=menuItems
                    end
                else
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY < menuItems then
                        menuY = menuY + 1
                        else
                        menuY=0
                    end
                else
                end
            elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY == 1 then -- #1 Add to collection
                        
                        if collection_number > 0 then
                            collection_number = collection_number - 1
                        else
                            collection_number = #collection_files
                        end

                    else
                    end
                else
                end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY == 1 then -- #1 Add to collection

                        if collection_number < #collection_files then
                            collection_number = collection_number + 1
                        else
                            collection_number = 0
                        end

                    else
                    end
                else
                end

            elseif Controls.check(pad, SCE_CTRL_CIRCLE_MAP) and not Controls.check(oldpad, SCE_CTRL_CIRCLE_MAP) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    -- collection_number = 0
                    oldpad = pad
                    GetInfoSelected()
                    showMenu = 20
                    menuY=3
                else
                end
            end
        end


-- MENU 23 - REMOVE FROM COLLECTION
    elseif showMenu == 23 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select


        -- GET MENU ITEM COUNT
            
            menuItems = 2
            
        -- Calculate vertical centre
            vertically_centre_mini_menu(menuItems)

        -- GRAPHIC SETUP
        
            -- Apply mini menu margins
            local setting_x = setting_x + mini_menu_x_margin

            -- Draw black overlay
            Graphics.fillRect(0, 960, 0, 540, blackalpha)

            -- Draw footer
            Graphics.fillRect(0, 960, 496, 544, themeCol)

            Graphics.drawImage(900-label1, 510, btnO)
            Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

            Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
            Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select
            
            -- Draw dark overlay
            Graphics.fillRect(60 + mini_menu_x_margin, 900 - mini_menu_x_margin, y_centre_top_margin, y_centre_top_margin + y_centre_box_height, dark)

            -- Draw white line
            Graphics.fillRect(60 + mini_menu_x_margin, 900 - mini_menu_x_margin, y_centre_white_line_start, y_centre_white_line_start + 3, white)
            
            -- Draw selection
            Graphics.fillRect(60 + mini_menu_x_margin, 900 - mini_menu_x_margin, y_centre_selection_start + (menuY * 47), y_centre_selection_end + (menuY * 47), themeCol)-- selection

            
        -- MENU 23 / Heading
        Font.print(fnt22, setting_x, setting_yh + y_centre_text_offset, lang_lines.Remove_from_collection, white)--Remove from collection

        -- MENU 23 / #0 Back
        Font.print(fnt22, setting_x, setting_y0 + y_centre_text_offset, lang_lines.Back_Chevron, white)--Back

        -- MENU 23 / #1 Collections
        Font.print(fnt22, setting_x, setting_y1 + y_centre_text_offset, lang_lines.Collections_colon, white)--Collections:

        -- Menu
        
        if remove_from_collection_flag == false then
            Font.print(fnt22, setting_x_offset, setting_y1 + y_centre_text_offset, lang_lines.No_collections, white) -- No collections
        else
            -- xxxnum = collection_removal_table[xcollection_number].matched_collection_num
            Font.print(fnt22, setting_x_offset, setting_y1 + y_centre_text_offset, "<  " .. collection_files[collection_removal_table[xcollection_number].matched_collection_num].display_name .. "  >", white)
        end


        -- MENU 23 / #3 Remove from collection
        Font.print(fnt22, setting_x, setting_y2 + y_centre_text_offset, lang_lines.Remove_from_collection, white)--Remove from collection

        
        -- MENU 23 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 23
                if menuY == 0 then -- #0 Back
                    showMenu = 20
                    menuY=4

                elseif menuY == 2 then -- #3 Remove from collection

                    -- Existing collection
                    if #collection_removal_table == 0 then
                        
                    else

                           -- Create new table of basic info
                            game_info_for_collection = {}                            

                            -- Check if collection has custom sorting
                            if xCollectionTableLookup(collection_removal_table[xcollection_number].matched_collection_num)[1].custom_sort_order ~= nil then
                                cc_already_custom = true
                            end

                            for i, file in pairs(xCollectionTableLookup(collection_removal_table[xcollection_number].matched_collection_num)) do

                                -- if not string.match (tostring(file.apptitle), tostring(xCatLookup(showCat)[p].apptitle)) then
                                if tostring(file.apptitle) ~= tostring(xCatLookup(showCat)[p].apptitle) then
                                    existing_collection_info = {}
                                    existing_collection_info.apptitle = file.title
                                    existing_collection_info.name = file.name
                                    existing_collection_info.app_type = file.app_type

                                    -- If custom sorting, include field
                                    if cc_already_custom == true then
                                        existing_collection_info.custom_sort_order = file.custom_sort_order
                                    end

                                    table.insert(game_info_for_collection, existing_collection_info)
                                end
                            end

                            -- Is collection now empty?
                            if next(game_info_for_collection) == nil then

                                -- Is empty, delete file

                                local collection_file_path_to_delete = collections_dir .. collection_files[collection_removal_table[xcollection_number].matched_collection_num].filename
                                if System.doesFileExist(collection_file_path_to_delete) then
                                    System.deleteFile(collection_file_path_to_delete)
                                end

                                -- Reload
                                FreeIcons()
                                FreeMemory()
                                Network.term()
                                dofile("app0:index.lua")
                               
                            else

                                -- Is not empty, Sort the table and cache
                                table.sort(game_info_for_collection, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
                                update_cached_collection(collection_files[collection_removal_table[xcollection_number].matched_collection_num].filename, game_info_for_collection)
                            end
                            

                        import_collections()

                        if next(xCatLookup(showCat)) ~= nil then
                        else
                            -- Empty
                            showCat = 0
                        end

                        check_for_out_of_bounds()
                        GetInfoSelected()
                        oldpad = pad -- Prevents it from launching next game accidentally. Credit BlackSheepBoy69
                        showMenu = 0
                        Render.useTexture(modBackground, imgCustomBack)
                        collection_number = 0
                    end

                else
                end
            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                if menuY > 0 then
                    menuY = menuY - 1
                    else
                    menuY=menuItems
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                if menuY < menuItems then
                    menuY = menuY + 1
                    else
                    menuY=0
                end
            elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then
                if menuY == 1 then -- #1 Remove from collection
                    
                    if #collection_removal_table > 0 then
                        if xcollection_number > 1 then
                            xcollection_number = xcollection_number - 1
                        else
                            xcollection_number = #collection_removal_table
                        end
                    end

                else
                end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
                if menuY == 1 then -- #1 Remove from collection

                    if #collection_removal_table > 0 then
                        if xcollection_number < #collection_removal_table then
                            xcollection_number = xcollection_number + 1
                        else
                            xcollection_number = 1
                        end
                    end

                else
                end


            elseif Controls.check(pad, SCE_CTRL_CIRCLE_MAP) and not Controls.check(oldpad, SCE_CTRL_CIRCLE_MAP) then
                -- collection_number = 0
                oldpad = pad
                GetInfoSelected()
                showMenu = 20
                menuY=4
            end
        end


-- MENU 24 - EDIT COLLECTIONS
    elseif showMenu == 24 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.Edit_collections, white)--Edit_collections
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection

        menuItems = 4

        -- MENU 24 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back

        -- Menu
        no_collections_flag = false
        if #collection_files > 0 then
            collections_flag = true
            --collection_number = 1

        else
            collections_flag = false
        end

        -- if collections_flag == true then
        --     local check_collection_number = 0
        --     local count_of_matches = 0
        --     while check_collection_number < #collection_files do
        --         check_collection_number = check_collection_number + 1

        --         found = check_if_game_is_in_collection_table(check_collection_number)
        --         if found == true then
        --             count_of_matches = count_of_matches + 1
        --             matched_collection_num = check_collection_number
        --             collection_removal_table[count_of_matches]={matched_collection_num = check_collection_number}
        --             -- table.insert(collection_removal_table, count_of_matches, matched_collection_num)
        --         else
        --         end

        --     end
        -- end

        -- MENU 24 / #1 Collections
        if collections_flag == true then
            Font.print(fnt22, setting_x, setting_y1, lang_lines.Collections_colon, white)--Collections:
        else
            Font.print(fnt22, setting_x, setting_y1, lang_lines.Collections_colon, white_opaque)--Collections:
        end

        if collections_flag == true then
            Font.print(fnt22, setting_x_offset, setting_y1, "<  " .. collection_files[xcollection_number].display_name .. "  >", white)
        else
            Font.print(fnt22, setting_x_offset, setting_y1, "<  " .. lang_lines.No_collections .. "  >", white_opaque)
        end

        -- MENU 24 / #2 Custom sort order
        if collections_flag == true then
            Font.print(fnt22, setting_x, setting_y2, lang_lines.Customise_game_order, white)--Delete
        else
            Font.print(fnt22, setting_x, setting_y2, lang_lines.Customise_game_order, white_opaque)--Delete
        end

        -- MENU 24 / #3 Rename
        if collections_flag == true then
            Font.print(fnt22, setting_x, setting_y3, lang_lines.Rename, white)--Rename
        else
            Font.print(fnt22, setting_x, setting_y3, lang_lines.Rename, white_opaque)--Rename
        end

        -- MENU 24 / #4 Delete
        if collections_flag == true then
            Font.print(fnt22, setting_x, setting_y4, lang_lines.Delete, white)--Delete
        else
            Font.print(fnt22, setting_x, setting_y4, lang_lines.Delete, white_opaque)--Delete
        end

        
    

        -- MENU 24 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 2
                if menuY == 0 then -- #0 Back
                    showMenu = 19  -- Other settings
                    menuY = 5

                elseif menuY == 2 then -- #2 Custom sort order

                    -- If collections exist
                    if collections_flag == true then
                        showMenu = 26  -- Collection custom sort order
                        menuY = 0
                    else
                    end

                elseif menuY == 3 then -- #3 Rename collection
                    
                    -- If collections exist
                    if collections_flag == true then
                        -- Rename
                        if hasTyped==false then

                            Keyboard.start(tostring(lang_lines.Rename), collection_files[xcollection_number].display_name, 512, TYPE_LATIN, MODE_TEXT)
                            hasTyped=true
                            keyboard_collection_rename=true
                            keyboard_collection_rename_filename = collection_files[xcollection_number].filename
                            keyboard_collection_rename_table_name = collection_files[xcollection_number].table_name
            

                            showMenu = 19  -- Other settings
                            menuY = 3
                            showMenu = 24  -- Edit collections
                            menuY = 3
                        end
                    else
                    end

                elseif menuY == 4 then -- #4 Delete collection

                    -- If collections exist
                    if collections_flag == true then
                        if System.doesFileExist(collections_dir .. collection_files[xcollection_number].filename) then
                            System.deleteFile(collections_dir .. collection_files[xcollection_number].filename)


                            if string.match(startCategory_collection, collection_files[xcollection_number].table_name) then
                                -- startCategory_collection_renamed = {} -- commented out, bug fix for removing coll when coll is set as startcat 
                                startCategory_collection = "not_set"
                                startCategory = 1
                                SaveSettings()
                            else
                            end

                            FreeIcons()
                            FreeMemory()
                            Network.term()
                            dofile("app0:index.lua")
                        else
                        end
                    else
                    end
                
                end
            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY > 0 then
                        menuY = menuY - 1
                        else
                        menuY=menuItems
                    end
                else
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY < menuItems then
                        menuY = menuY + 1
                        else
                        menuY=0
                    end
                else
                end
            elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY == 1 then -- #1 Add to collection
                        
                        if xcollection_number > 1 then
                            xcollection_number = xcollection_number - 1
                        else
                            xcollection_number = #collection_files
                        end

                    else
                    end
                else
                end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY == 1 then -- #1 Add to collection

                        if xcollection_number < #collection_files then
                            xcollection_number = xcollection_number + 1
                        else
                            xcollection_number = 1
                        end

                    else
                    end
                else
                end
            end


        end


-- MENU 25 - FILTER GAMES
    elseif showMenu == 25 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select


        -- GET MENU ITEM COUNT (Some menus app type specific)
            
            menuItems = 4
        
            -- Calculate vertical centre
            vertically_centre_mini_menu(menuItems)

        -- GRAPHIC SETUP
        
            -- Apply mini menu margins
            local setting_x = setting_x + mini_menu_x_margin

            -- Draw black overlay
            Graphics.fillRect(0, 960, 0, 540, blackalpha)

            -- Draw footer
            Graphics.fillRect(0, 960, 496, 544, themeCol)

            Graphics.drawImage(900-label1, 510, btnO)
            Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

            Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
            Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select
            
            -- Draw dark overlay
            Graphics.fillRect(60 + mini_menu_x_margin, 900 - mini_menu_x_margin, y_centre_top_margin, y_centre_top_margin + y_centre_box_height, dark)

            -- Draw white line
            Graphics.fillRect(60 + mini_menu_x_margin, 900 - mini_menu_x_margin, y_centre_white_line_start, y_centre_white_line_start + 3, white)
            
            -- Draw selection
            Graphics.fillRect(60 + mini_menu_x_margin, 900 - mini_menu_x_margin, y_centre_selection_start + (menuY * 47), y_centre_selection_end + (menuY * 47), themeCol)-- selection


        -- MENU 25 / Heading
        Font.print(fnt22, setting_x, setting_yh + y_centre_text_offset, lang_lines.Category, white)--Category

        -- MENU 25 / #0 System Apps
        Graphics.drawImage(setting_x, setting_y0 + y_centre_text_offset, setting_icon_random)
        Font.print(fnt22, setting_x_icon_offset + 70, setting_y0 + y_centre_text_offset, lang_lines.Random_Game, white)--Random Game

        -- MENU 25 / #1 Favorites
        Graphics.drawImage(setting_x, setting_y1 + y_centre_text_offset, setting_icon_heart)
        Font.print(fnt22, setting_x_icon_offset + 70, setting_y1 + y_centre_text_offset, lang_lines.Favorites, white)--Favourites

        -- MENU 25 / #2 Recently Played
        Graphics.drawImage(setting_x, setting_y2 + y_centre_text_offset, setting_icon_categories)
        Font.print(fnt22, setting_x_icon_offset + 70, setting_y2 + y_centre_text_offset, lang_lines.Recently_Played, white)--Recently Played

        -- MENU 25 / #3 System Apps
        Graphics.drawImage(setting_x, setting_y3 + y_centre_text_offset, setting_icon_categories)
        Font.print(fnt22, setting_x_icon_offset + 70, setting_y3 + y_centre_text_offset, lang_lines.System_Apps, white)--System Apps

        -- MENU 25 / #4 Filter games
        Graphics.drawImage(setting_x, setting_y4 + y_centre_text_offset, setting_icon_filter)

        if filterGames == 0 then
            Font.print(fnt22, setting_x_icon_offset + 70, setting_y4 + y_centre_text_offset, "<  " .. lang_lines.All .. "  >", white)
        else
            Font.print(fnt22, setting_x_icon_offset + 70, setting_y4 + y_centre_text_offset, "<  " .. lang_lines.Collections .. "  >", white)
        end

        


        
        -- MENU 25 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                oldpad = pad

                -- MENU 20

                if menuY == 0 then -- #0 Random game

                    function Shuffle(files_table)
                        -- math.randomseed(os.time())
                        math.randomseed(os.clock() * 1000000)
                        local search_results_table = {}

                        -- Create a filtered list of only allowed app types, exclude homebrew and system apps
                        local valid_games = {}
                        for i = 1, #files_table do
                            local app = files_table[i]
                            if app.app_type ~= 0 and app.app_type ~= 42 then
                                table.insert(valid_games, app)
                            end
                        end

                        -- Pick one random game from valid list
                        if #valid_games > 0 then
                            local rand_index = math.random(1, #valid_games)
                            search_results_table[1] = valid_games[rand_index]
                        end

                        return search_results_table
                    end

                    -- Run the shuffle to get one random game
                    search_results_table = Shuffle(files_table)

                    -- Check if a game was added
                    if search_results_table[1] then
                        random_game_selected = true
                        random_game = search_results_table[1].name
                    else
                        random_game_selected = false
                    end

                    -- Proceed only if a game was found
                    if random_game_selected == true then
                        showCat = 46
                        p = 1
                        master_index = p
                        showMenu = 0
                        GetNameAndAppTypeSelected()
                    end

                elseif menuY == 1 then -- #1 Favorites

                    -- Check if there are favourites first
                    create_fav_count_table(files_table)

                    -- Favourites found
                    if #fav_count > 0 then
                        -- Skip to favorites
                        showCat = 44
                        p = 1
                        master_index = p
                        showMenu = 0
                        GetNameAndAppTypeSelected()
                    else
                    -- No favourites, do nothing
                    end

                elseif menuY == 2 then -- #2 Recently Played

                    if #recently_played_table > 0 then
                        -- Skip to recent
                        showCat = 45
                        p = 1
                        master_index = p
                        showMenu = 0
                        GetNameAndAppTypeSelected()
                    else
                    -- No recently played, do nothing
                    end

                elseif menuY == 3 then -- #3 System Apps

                    if showSysApps == 0 then
                        -- System apps hidden, import them

                        -- Turn on temporarily
                        showSysApps = 1

                        -- Import and jump to menu
                        FreeIcons()
                        count_cache_and_reload()
                        showCat = 43
                        p = 1
                        master_index = p
                        showMenu = 0
                        GetNameAndAppTypeSelected()

                        -- Turn off again, the table will be removed when the user changes category (see category controls, square)
                        showSysApps = 0

                    else
                        -- Skip to system apps
                        showCat = 43
                        p = 1
                        master_index = p
                        showMenu = 0
                        GetNameAndAppTypeSelected()
                    end
                    
                elseif menuY == 4 then -- #4 Filter

                    if filterGames == 1 then
                        if collection_count ~= 0 then   
                            showCat = 47
                            p = 1
                            master_index = p
                            showMenu = 0
                            GetNameAndAppTypeSelected()
                        end
                    else
                        if showAll==1 then
                            showCat = 0
                        else
                            showCat = 1
                        end
                        p = 1
                        master_index = p
                        showMenu = 0
                        GetNameAndAppTypeSelected()
                    end

                SaveSettings()
                     
                end



            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                if menuY > 0 then
                    menuY = menuY - 1
                    else
                    menuY=menuItems
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                if menuY < menuItems then
                    menuY = menuY + 1
                    else
                    menuY=0
                end
            elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then
                if menuY == 4 then -- #4 Filter
                    if filterGames > 0 then
                        filterGames = filterGames - 1
                    else
                        filterGames = 1
                    end
                else
                end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
                if menuY == 4 then -- #4 Filter
                    if filterGames < 1 then
                        filterGames = filterGames + 1
                    else
                        filterGames = 0
                    end
                else
                end
            elseif Controls.check(pad, SCE_CTRL_CIRCLE_MAP) and not Controls.check(oldpad, SCE_CTRL_CIRCLE_MAP) then
                
            end
        end



-- MENU 26 - COLLECTION CUSTOM SORT ORDER
    elseif showMenu == 26 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Close, white)--Close

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnT)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Default, white)--Default (Reset)

        Graphics.drawImage(900-(btnMargin * 4)-label1-label2-label3, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 4)-label1-label2-label3, 508, lang_lines.Select, white)--Select

        
        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, collection_files[xcollection_number].display_name, white)--Name of collection
        Graphics.fillRect(60, 900, 78, 81, white)


            function cc_drawList()
                Screen.clear(black)
                
                -- Calculate the start and end indices for the visible items
                local startIdx = math.max(1, cc_scrollPosition + 1)
                local endIdx = math.min(#xCollectionTableLookup(xcollection_number), cc_scrollPosition + cc_maxVisibleItems)

                -- Draw the visible items
                for i = startIdx, endIdx do
                    local yPosition = setting_y0 + ((i - startIdx) * 47)
                    if cc_edit_mode == true then
                        color = white_opaque
                    else
                        color = white
                    end
                    if i == cc_selected then
                        Graphics.fillRect(60, 900, yPosition - 10, yPosition + 38, themeCol)-- selection
                        color = white  -- Highlight selected item in white
                    end
                    if cc_edit_mode == true and i == cc_selected and i < #xCollectionTableLookup(xcollection_number) and i > 1 then
                        Graphics.drawImage(13, yPosition, setting_icon_sort)
                    end
                    if cc_edit_mode == true and i == cc_selected and i == #xCollectionTableLookup(xcollection_number) then
                        Graphics.drawImage(13, yPosition, setting_icon_sort_up)
                    end
                    if cc_edit_mode == true and i == cc_selected and i == 1 then
                        Graphics.drawImage(13, yPosition, setting_icon_sort_down)
                    end

                    Font.print(fnt22, setting_x, yPosition, xCollectionTableLookup(xcollection_number)[i].apptitle, color)
                end
                Screen.flip()
            end

            cc_drawList()  -- Draw the game list

    

        -- MENU 26 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            -- Check for input
            pad = Controls.read()

            -- Capture left analog stick input (rename to avoid conflicts)
            local analogX, analogY = Controls.readLeftAnalog()

            -- Decrease delayButton for scrolling
            if delayButton > 0 then
                delayButton = delayButton - 0.05   -- Slower decrement
            end

            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                if cc_edit_mode == false then
                    cc_edit_mode = true
                else
                    cc_edit_mode = false
                end

            -- Handle upward movement (using Up button or left analog stick up)
            elseif (Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP)) or (analogY < 120 and delayButton < 0.5) then
                
                if cc_edit_mode == true then

                    -- Move selected item Up
                    if cc_selected > 1 and cc_edit_mode == true then
                        local temp = xCollectionTableLookup(xcollection_number)[cc_selected]
                        xCollectionTableLookup(xcollection_number)[cc_selected] = xCollectionTableLookup(xcollection_number)[cc_selected - 1]
                        xCollectionTableLookup(xcollection_number)[cc_selected - 1] = temp

                        cc_selected = cc_selected - 1
                        if cc_selected <= cc_scrollPosition then
                            cc_scrollPosition = cc_scrollPosition - 1
                        end
                    end
                    cc_updated = true
                    cc_reset = false
                else

                    -- Scroll up
                    if cc_selected > 1 then
                        cc_selected = cc_selected - 1
                        if cc_selected <= cc_scrollPosition then
                            cc_scrollPosition = cc_scrollPosition - 1
                        end
                    end
                end

                -- Reset delayButton after scrolling (adjusted to slow it down)
                delayButton = 1.5    -- Increase this value to slow the speed
         
            -- Handle downward movement (using Down button or left analog stick down)
            elseif (Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN)) or (analogY > 140 and delayButton < 0.5) then

                if cc_edit_mode == true then

                    -- Move selected item down
                    if cc_selected < #xCollectionTableLookup(xcollection_number) then
                        local temp = xCollectionTableLookup(xcollection_number)[cc_selected]
                        xCollectionTableLookup(xcollection_number)[cc_selected] = xCollectionTableLookup(xcollection_number)[cc_selected + 1]
                        xCollectionTableLookup(xcollection_number)[cc_selected + 1] = temp

                        cc_selected = cc_selected + 1
                        if cc_selected > cc_scrollPosition + cc_maxVisibleItems then
                            cc_scrollPosition = cc_scrollPosition + 1
                        end

                    end
                    cc_updated = true
                    cc_reset = false

                else

                    -- Scroll down
                    if cc_selected < #xCollectionTableLookup(xcollection_number) then
                        cc_selected = cc_selected + 1
                        if cc_selected > cc_scrollPosition + cc_maxVisibleItems then
                            cc_scrollPosition = cc_scrollPosition + 1
                        end
                    end
                end

                -- Reset delayButton after scrolling (adjusted to slow it down)
                delayButton = 1.5    -- Increase this value to slow the speed
            
            elseif (Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    
                    cc_edit_mode = false

                    -- Reset to alphabetical order
                    table.sort(xCollectionTableLookup(xcollection_number), function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
                    
                    cc_reset = true
                    cc_updated = false
                    cc_scrollPosition = 0
                    cc_selected = 1

                else
                end

            elseif (Controls.check(pad, SCE_CTRL_CIRCLE_MAP) and not Controls.check(oldpad, SCE_CTRL_CIRCLE_MAP)) then

                    -- Save changes

                        -- Filename to save as
                            ret_collection_filename = "Collection_" .. collection_files[xcollection_number].display_name:gsub(" ", "_") .. ".lua"--Name of collection

                        -- Delete old file
                            function check_if_collection_file_exists(def_duplicate_name_num)
                                if System.doesFileExist(collections_dir .. ret_collection_filename) then
                                    System.deleteFile(collections_dir .. ret_collection_filename)
                                end
                            end

                        -- Update table before saving

                            -- Empty table to add to for caching
                                local cc_table_to_print = {}

                            -- Custom sort has been used
                                if cc_updated == true then
                                    for k, v in ipairs(xCollectionTableLookup(xcollection_number)) do
                                        v.custom_sort_order = k
                                    end

                                    for i, item in ipairs(xCollectionTableLookup(xcollection_number)) do
                                        -- Add a new entry to selected_fields_collection with only the desired fields
                                        cc_table_to_print[i] = {
                                            ["app_type"] = item["app_type"],
                                            ["name"] = item["name"],
                                            ["apptitle"] = item["apptitle"],
                                            ["custom_sort_order"] = item["custom_sort_order"],
                                        }
                                    end
                                    update_cached_collection(ret_collection_filename, cc_table_to_print)
                                end

                            -- Has been reset, remove custom sort
                                if cc_reset == true then
                                    for i, item in ipairs(xCollectionTableLookup(xcollection_number)) do
                                        -- Add a new entry to selected_fields_collection with only the desired fields
                                        cc_table_to_print[i] = {
                                            ["app_type"] = item["app_type"],
                                            ["name"] = item["name"],
                                            ["apptitle"] = item["apptitle"],
                                            -- ["custom_sort_order"] = item["custom_sort_order"],
                                        }
                                    end
                                    update_cached_collection(ret_collection_filename, cc_table_to_print)

                                end

                        cc_edit_mode = false
                        cc_scrollPosition = 0
                        cc_selected = 1

                        oldpad = pad
                        showMenu = 24
                        menuY = 2



            elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY == 1 then
                        -- Do something
                    else
                    end
                else
                end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if menuY == 1 then
                        -- Do something
                    else
                    end
                else
                end
            end

            oldpad = pad

        end


-- END OF MENUS
    end

    
    -- Terminating rendering phase
    Graphics.termBlend()
    if showMenu == 1 then
        --Left Analog rotate preview box
        if mx < 64 then
            if prvRotY>-0.5 then
                prvRotY=prvRotY-0.02
            end
        elseif mx > 180 then
            if prvRotY<0.6 then
                prvRotY=prvRotY+0.02
            end
        end
    end

    if showMenu == 11 then
        --Scroll through ROM Browser
        if my < 64 then
            if delayButton < 0.5 then
                delayButton = 1
                i = i - 1
            end
        elseif my > 180 then
            if delayButton < 0.5 then
                delayButton = 1
                i = i + 1
            end
        end
    end

    if showMenu > 1 
        and showMenu ~= 11 -- ROM Browser
        and showMenu ~= 13 -- Guide 1
        and showMenu ~= 14 -- Guide 2
        and showMenu ~= 15 -- Guide 3
        and showMenu ~= 16 -- Guide 4
        and showMenu ~= 17 -- Guide 5
        and showMenu ~= 18 -- Guide 6
        then
        --Scroll through menus
        if my < 64 then
            if delayButton < 0.5 then
                delayButton = 1
                if menuY > 0 then
                    menuY = menuY - 1
                    else
                    menuY=menuItems
                end
            end
        elseif my > 180 then
            if delayButton < 0.5 then
                delayButton = 1
                if menuY < menuItems then
                    menuY = menuY + 1
                    else
                    menuY=0
                end
            end
        end

    end

    --Controls Start
    if showMenu == 0 then
        
        -- Game list view
        if showView == 6 then
            if my < 64 then
                if delayButton < 0.5 then
                    delayButton = 1
                    if setSounds == 1 then
                        Sound.play(click, NO_LOOP)
                    end
                    p = p - 1
                end
            elseif my > 180 then
                if delayButton < 0.5 then
                    delayButton = 1
                    if setSounds == 1 then
                        Sound.play(click, NO_LOOP)
                    end
                    p = p + 1
                end
            end
        else

            --Navigation Left Analog
            if mx < 64 then
                if delayButton < 0.5 then
                    delayButton = 1
                    if setSounds == 1 then
                        Sound.play(click, NO_LOOP)
                    end
                    p = p - 1
                    
                    if p > 0 then
                        GetNameAndAppTypeSelected()
                    end
                    
                    if (p <= master_index) then
                        master_index = p
                    end
                end
            elseif mx > 180 then
                if delayButton < 0.5 then
                    delayButton = 1
                    if setSounds == 1 then
                        Sound.play(click, NO_LOOP)
                    end
                    p = p + 1
                    
                    if p <= curTotal then
                        GetNameAndAppTypeSelected()
                    end
                    
                    if (p >= master_index) then
                        master_index = p
                    end
                end
            end
            
        end
        
        -- Navigation Buttons
        if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then
            state = Keyboard.getState()
            messagestate = System.getMessageState() -- Check if message active - RetroFlow Adrenaline Launcher needs to be installed

            if state ~= RUNNING and messagestate ~= RUNNING then
                if next(xCatLookup(showCat)) ~= nil and gettingCovers == false and app_title~="-" then
                    
                    GetNameAndAppTypeSelected() -- Bug fix for list view not passing launch checks in mixed categories (apptype not found or path? Not sure)

                    if showCat == 1 then
                        if string.match (games_table[p].game_path, "pspemu") then
                            -- Launch adrenaline
                            rom_location = tostring(games_table[p].game_path)
                            rom_title_id = tostring(games_table[p].name)
                            rom_filename = tostring(games_table[p].filename)
                            launch_Adrenaline(rom_location, rom_title_id, rom_filename)
                        else
                            if games_table[p].app_type_default == 3 then
                                -- Launch PS1 retroarch
                                rom_location = (games_table[p].game_path) launch_retroarch(core.PS1)
                            else
                                -- Vita app
                                launch_vita_title(games_table[p].name)
                            end
                        end

                    elseif showCat == 2 then
                        if string.match (homebrews_table[p].game_path, "pspemu") then
                            -- Launch adrenaline
                            rom_location = tostring(homebrews_table[p].game_path)
                            rom_title_id = tostring(homebrews_table[p].name)
                            rom_filename = tostring(homebrews_table[p].filename)
                            launch_Adrenaline(rom_location, rom_title_id, rom_filename)
                        else
                            if homebrews_table[p].app_type_default == 3 then
                                -- Launch PS1 retroarch
                                rom_location = (homebrews_table[p].game_path) launch_retroarch(core.PS1)
                            else
                                -- Vita app
                                launch_vita_title(homebrews_table[p].name)
                            end
                        end

                    elseif showCat == 3 then
                        if string.match (psp_table[p].game_path, "pspemu") then
                            -- Launch adrenaline
                            rom_location = tostring(psp_table[p].game_path)
                            rom_title_id = tostring(psp_table[p].name)
                            rom_filename = tostring(psp_table[p].filename)
                            launch_Adrenaline(rom_location, rom_title_id, rom_filename)
                        else
                            if psp_table[p].app_type_default == 3 then
                                -- Launch PS1 retroarch
                                rom_location = (psp_table[p].game_path) launch_retroarch(core.PS1)
                            else
                                -- Vita app
                                launch_vita_title(psp_table[p].name)
                            end
                        end

                    -- PS1 - Launch adrenaline or retroarch
                    elseif showCat == 4 then
                        if string.match (psx_table[p].game_path, "pspemu") then
                            -- Launch adrenaline
                            rom_location = tostring(psx_table[p].game_path)
                            rom_title_id = tostring(psx_table[p].name)
                            rom_filename = tostring(psx_table[p].filename)
                            launch_Adrenaline(rom_location, rom_title_id, rom_filename)
                        else
                            if psx_table[p].app_type_default == 3 then
                                -- Launch PS1 retroarch
                                rom_location = (psx_table[p].game_path) launch_retroarch(core.PS1)
                            else
                                -- Vita app
                                launch_vita_title(psx_table[p].name)
                            end
                        end

                    -- Start Retro    
                    elseif showCat == 5 then rom_title_id = tostring(psm_table[p].name) launch_psmobile(rom_title_id)
                    elseif showCat == 6 then rom_location = (n64_table[p].game_path) launch_DaedalusX64()
                    elseif showCat == 7 then rom_location = (snes_table[p].game_path) launch_retroarch(core.SNES)
                    elseif showCat == 8 then rom_location = (nes_table[p].game_path) launch_retroarch(core.NES)
                    elseif showCat == 9 then rom_location = (nds_table[p].game_path) launch_DSVita()
                    elseif showCat == 10 then rom_location = (gba_table[p].game_path) launch_retroarch(core.GBA)
                    elseif showCat == 11 then rom_location = (gbc_table[p].game_path) launch_retroarch(core.GBC)
                    elseif showCat == 12 then rom_location = (gb_table[p].game_path) launch_retroarch(core.GB)
                    elseif showCat == 13 then rom_location = (dreamcast_table[p].game_path) launch_Flycast()
                    elseif showCat == 14 then rom_location = (sega_cd_table[p].game_path) launch_retroarch(core.SEGA_CD) 
                    elseif showCat == 15 then rom_location = (s32x_table[p].game_path) launch_retroarch(core.s32X) 
                    elseif showCat == 16 then rom_location = (md_table[p].game_path) launch_retroarch(core.MD)
                    elseif showCat == 17 then rom_location = (sms_table[p].game_path) launch_retroarch(core.SMS)
                    elseif showCat == 18 then rom_location = (gg_table[p].game_path) launch_retroarch(core.GG)
                    elseif showCat == 19 then rom_location = (tg16_table[p].game_path) launch_retroarch(core.TG16)
                    elseif showCat == 20 then rom_location = (tgcd_table[p].game_path) launch_retroarch(core.TGCD)
                    elseif showCat == 21 then rom_location = (pce_table[p].game_path) launch_retroarch(core.PCE)
                    elseif showCat == 22 then rom_location = (pcecd_table[p].game_path) launch_retroarch(core.PCECD)
                    elseif showCat == 23 then rom_location = (amiga_table[p].game_path) launch_retroarch(core.AMIGA)
                    elseif showCat == 24 then rom_title_id = (scummvm_table[p].titleid) rom_location = (scummvm_table[p].game_path) launch_scummvm()
                    elseif showCat == 25 then rom_location = (c64_table[p].game_path) launch_retroarch(core.C64)
                    elseif showCat == 26 then rom_location = (wswan_col_table[p].game_path) launch_retroarch(core.WSWAN_COL)
                    elseif showCat == 27 then rom_location = (wswan_table[p].game_path) launch_retroarch(core.WSWAN)
                    elseif showCat == 28 then rom_location = (pico8_table[p].game_path) launch_pico8()
                    elseif showCat == 29 then rom_location = (msx2_table[p].game_path) launch_retroarch(core.MSX2)
                    elseif showCat == 30 then rom_location = (msx1_table[p].game_path) launch_retroarch(core.MSX1)
                    elseif showCat == 31 then rom_location = (zxs_table[p].game_path) launch_retroarch(core.ZXS)
                    elseif showCat == 32 then rom_location = (atari_7800_table[p].game_path) launch_retroarch(core.ATARI_7800)
                    elseif showCat == 33 then rom_location = (atari_5200_table[p].game_path) launch_retroarch(core.ATARI_5200)
                    elseif showCat == 34 then rom_location = (atari_2600_table[p].game_path) launch_retroarch(core.ATARI_2600)
                    elseif showCat == 35 then rom_location = (atari_lynx_table[p].game_path) launch_retroarch(core.ATARI_LYNX)
                    elseif showCat == 36 then rom_location = (colecovision_table[p].game_path) launch_retroarch(core.COLECOVISION)
                    elseif showCat == 37 then rom_location = (vectrex_table[p].game_path) launch_retroarch(core.VECTREX)
                    elseif showCat == 38 then rom_location = (fba_table[p].game_path) launch_retroarch(core.FBA)
                    elseif showCat == 39 then rom_location = (mame_2003_plus_table[p].game_path) launch_retroarch(core.MAME_2003_PLUS)
                    elseif showCat == 40 then rom_location = (mame_2000_table[p].game_path) launch_retroarch(core.MAME_2000)
                    elseif showCat == 41 then rom_location = (neogeo_table[p].game_path) launch_retroarch(core.NEOGEO)
                    elseif showCat == 42 then rom_location = (ngpc_table[p].game_path) launch_retroarch(core.NGPC)
                    elseif showCat == 43 then rom_location = launch_vita_sysapp(xCatLookup(showCat)[p].name)

                    elseif showCat >= 44 or showCat == 0 then
                        if apptype == 1 or apptype == 2 or apptype == 3 or apptype == 4 then
                            if string.match (xCatLookup(showCat)[p].game_path, "pspemu") then
                                 -- Launch adrenaline
                                rom_location = tostring(xCatLookup(showCat)[p].game_path)
                                rom_title_id = tostring(xCatLookup(showCat)[p].name)
                                rom_filename = tostring(xCatLookup(showCat)[p].filename)
                                launch_Adrenaline(rom_location, rom_title_id, rom_filename)
                            else
                                if xCatLookup(showCat)[p].app_type_default == 3 then
                                    -- Launch PS1 retroarch
                                    rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.PS1)
                                elseif xCatLookup(showCat)[p].app_type_default == 42 then
                                    -- Sys app
                                    launch_vita_sysapp(xCatLookup(showCat)[p].name)
                                else
                                    -- Vita app
                                    launch_vita_title(xCatLookup(showCat)[p].name)
                                end
                            end

                        -- Start Retro    
                        elseif apptype == 5 then rom_location = (xCatLookup(showCat)[p].game_path) launch_DaedalusX64()
                        elseif apptype == 6 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.SNES)
                        elseif apptype == 7 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.NES)
                        elseif apptype == 8 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.GBA)
                        elseif apptype == 9 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.GBC)
                        elseif apptype == 10 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.GB)
                        elseif apptype == 11 then rom_location = (xCatLookup(showCat)[p].game_path) launch_Flycast()
                        elseif apptype == 12 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.SEGA_CD) 
                        elseif apptype == 13 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.s32X) 
                        elseif apptype == 14 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.MD)
                        elseif apptype == 15 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.SMS)
                        elseif apptype == 16 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.GG)
                        elseif apptype == 17 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.TG16)
                        elseif apptype == 18 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.TGCD)
                        elseif apptype == 19 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.PCE)
                        elseif apptype == 20 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.PCECD)
                        elseif apptype == 21 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.AMIGA)
                        elseif apptype == 22 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.C64)
                        elseif apptype == 23 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.WSWAN_COL)
                        elseif apptype == 24 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.WSWAN)
                        elseif apptype == 25 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.MSX2)
                        elseif apptype == 26 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.MSX1)
                        elseif apptype == 27 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.ZXS)
                        elseif apptype == 28 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.ATARI_7800)
                        elseif apptype == 29 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.ATARI_5200)
                        elseif apptype == 30 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.ATARI_2600)
                        elseif apptype == 31 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.ATARI_LYNX)
                        elseif apptype == 32 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.COLECOVISION)
                        elseif apptype == 33 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.VECTREX)
                        elseif apptype == 34 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.FBA)
                        elseif apptype == 35 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.MAME_2003_PLUS)
                        elseif apptype == 36 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.MAME_2000)
                        elseif apptype == 37 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.NEOGEO)
                        elseif apptype == 38 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retroarch(core.NGPC)
                        elseif apptype == 39 then rom_title_id = tostring(xCatLookup(showCat)[p].name) launch_psmobile(rom_title_id)
                        elseif apptype == 40 then rom_title_id = (xCatLookup(showCat)[p].titleid) rom_location = (xCatLookup(showCat)[p].game_path) launch_scummvm()
                        elseif apptype == 41 then rom_location = (xCatLookup(showCat)[p].game_path) launch_pico8()
                        elseif apptype == 42 then rom_location = launch_vita_sysapp(xCatLookup(showCat)[p].name)
                        elseif apptype == 43 then rom_location = (xCatLookup(showCat)[p].game_path) launch_DSVita()
                        else
                            -- Homebrew
                            if string.match (xCatLookup(showCat)[p].game_path, "pspemu") then
                                rom_location = (xCatLookup(showCat)[p].game_path)
                                rom_title_id = (xCatLookup(showCat)[p].name)
                                rom_filename = (xCatLookup(showCat)[p].filename)
                                launch_Adrenaline(rom_location, rom_title_id, rom_filename)
                            else
                                -- Vita app
                                launch_vita_title(xCatLookup(showCat)[p].name)
                            end

                            appdir=working_dir .. "/" .. xCatLookup(showCat)[p].name
                        end
                        
                    end

                    -- if launch_check_app_installed and launch_check_game_available == true then
                    --     System.exit()
                    -- else
                    -- end
                end
            else
            end
        elseif (Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE)) then
            state = Keyboard.getState()
            if state ~= RUNNING then

                if showMenu == 0 and next(xCatLookup(showCat)) ~= nil and app_title~="-" then
                    prvRotY = 0

                    GetInfoSelected() -- Credit to BlackSheepBoy69 - get all info when triangle pressed
                    showMenu = 1
                end
            else
            end
        elseif (Controls.check(pad, SCE_CTRL_START) and not Controls.check(oldpad, SCE_CTRL_START)) then
            state = Keyboard.getState()
            if state ~= RUNNING then
                if showMenu == 0 then
                    showMenu = 2
                    menuY = 0
                end
            else
            end
        -- Select button - Games screen
        elseif (Controls.check(pad, SCE_CTRL_SELECT) and not Controls.check(oldpad, SCE_CTRL_SELECT)) then
            state = Keyboard.getState()
            messagestate = System.getMessageState() -- Check if message active - RetroFlow Adrenaline Launcher needs to be installed

            if state ~= RUNNING then
                -- Search
                if hasTyped==false then
                    Keyboard.start(tostring(lang_lines.Search), "", 512, TYPE_LATIN, MODE_TEXT)
                    hasTyped=true
                    keyboard_search=true
                end
            else
            end
        elseif (Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE)) then
            state = Keyboard.getState()
            if state ~= RUNNING then
                
                -- If system apps were temporarily added to view through the up button quick menu, then remove the table
                if showSysApps == 0 and #sysapps_table >= 1 then
                    FreeIcons()
                    count_cache_and_reload()
                else
                end
                
                if (Controls.check(pad, SCE_CTRL_DOWN)) then

                   -- CATEGORY - Move Backwards

                    -- empty the search results
                    curTotal = #search_results_table   
                    if #search_results_table ~= nil then 
                        search_results_table = {}
                    end

                    if filterGames == 1 then

                        -- Only Collections
                        if collection_count ~= 0 then   
                            -- if showCat < collection_syscount and showCat >= 44 then
                            if showCat >= 47 then
                                showCat = showCat - 1
                            else
                                showCat = collection_syscount
                            end
                        end

                    else

                        -- All categories including collections
                        if showCat > 1 then
                            showCat = showCat - 1
                        elseif showCat == 1 then
                            if showAll==0 then -- All is off
                                if showCollections == 0 then
                                    showCat = count_of_categories
                                else
                                    showCat = collection_syscount
                                end
                            else
                                showCat = 0
                            end
                        elseif showCat == 0 then
                            if showCollections == 0 then
                                showCat = count_of_categories
                            else
                                showCat = collection_syscount
                            end
                        end

                    end



                    if showCat == 46 then
                        curTotal = #search_results_table   
                        if #search_results_table == 0 then 
                            showCat = 45
                        end
                    end

                    if showCat == 45 then 
                        curTotal = #recently_played_table
                        if #recently_played_table == 0 then 
                            showCat = 44
                        end
                    end

                    if showCat == 44 then
                        -- count favorites
                        create_fav_count_table(files_table)

                        curTotal = #fav_count
                        if #fav_count == 0 then 

                            if showSysApps == 1 then
                                showCat = 43
                            else
                                showCat = 42
                            end
                        end
                    end

                    if showCat == 43 then
                        if showSysApps == 0 then
                            showCat = 42
                        end
                    end
                    
                    if showCat >= 3 and showCat <= 42 then
                        showCatTemp = showCat - 1
                        curTotal = #xCatLookup(showCat)

                        if #xCatLookup(showCat) == 0 then         
                            showCat = showCatTemp
                        end
                    end

                    -- if showCat == 43 then curTotal =    #sysapps_table          if      #sysapps_table == 0 then        showCat = 42 end end
                    if showCat == 42 then curTotal =    #ngpc_table             if      #ngpc_table == 0 then           showCat = 41 end end
                    if showCat == 41 then curTotal =    #neogeo_table           if      #neogeo_table == 0 then         showCat = 40 end end
                    if showCat == 40 then curTotal =    #mame_2000_table        if      #mame_2000_table == 0 then      showCat = 39 end end
                    if showCat == 39 then curTotal =    #mame_2003_plus_table   if      #mame_2003_plus_table == 0 then showCat = 38 end end
                    if showCat == 38 then curTotal =    #fba_table              if      #fba_table == 0 then            showCat = 37 end end
                    if showCat == 37 then curTotal =    #vectrex_table          if      #vectrex_table == 0 then        showCat = 36 end end
                    if showCat == 36 then curTotal =    #colecovision_table     if      #colecovision_table == 0 then   showCat = 35 end end
                    if showCat == 35 then curTotal =    #atari_lynx_table       if      #atari_lynx_table == 0 then     showCat = 34 end end
                    if showCat == 34 then curTotal =    #atari_2600_table       if      #atari_2600_table == 0 then     showCat = 33 end end
                    if showCat == 33 then curTotal =    #atari_5200_table       if      #atari_5200_table == 0 then     showCat = 32 end end
                    if showCat == 32 then curTotal =    #atari_7800_table       if      #atari_7800_table == 0 then     showCat = 31 end end
                    if showCat == 31 then curTotal =    #zxs_table              if      #zxs_table == 0 then            showCat = 30 end end
                    if showCat == 30 then curTotal =    #msx1_table             if      #msx1_table == 0 then           showCat = 29 end end
                    if showCat == 29 then curTotal =    #msx2_table             if      #msx2_table == 0 then           showCat = 28 end end
                    if showCat == 28 then curTotal =    #pico8_table            if      #pico8_table == 0 then          showCat = 27 end end
                    if showCat == 27 then curTotal =    #wswan_table            if      #wswan_table == 0 then          showCat = 26 end end
                    if showCat == 26 then curTotal =    #wswan_col_table        if      #wswan_col_table == 0 then      showCat = 25 end end
                    if showCat == 25 then curTotal =    #c64_table              if      #c64_table == 0 then            showCat = 24 end end
                    if showCat == 24 then curTotal =    #scummvm_table          if      #scummvm_table == 0 then        showCat = 23 end end
                    if showCat == 23 then curTotal =    #amiga_table            if      #amiga_table == 0 then          showCat = 22 end end
                    if showCat == 22 then curTotal =    #pcecd_table            if      #pcecd_table == 0 then          showCat = 21 end end
                    if showCat == 21 then curTotal =    #pce_table              if      #pce_table == 0 then            showCat = 20 end end
                    if showCat == 20 then curTotal =    #tgcd_table             if      #tgcd_table == 0 then           showCat = 19 end end
                    if showCat == 19 then curTotal =    #tg16_table             if      #tg16_table == 0 then           showCat = 18 end end
                    if showCat == 18 then curTotal =    #gg_table               if      #gg_table == 0 then             showCat = 17 end end
                    if showCat == 17 then curTotal =    #sms_table              if      #sms_table == 0 then            showCat = 16 end end
                    if showCat == 16 then curTotal =    #md_table               if      #md_table == 0 then             showCat = 15 end end
                    if showCat == 15 then curTotal =    #s32x_table             if      #s32x_table == 0 then           showCat = 14 end end
                    if showCat == 14 then curTotal =    #sega_cd_table          if      #sega_cd_table == 0 then        showCat = 13 end end
                    if showCat == 13 then curTotal =    #dreamcast_table        if      #dreamcast_table == 0 then      showCat = 12 end end
                    if showCat == 12 then curTotal =    #gb_table               if      #gb_table == 0 then             showCat = 11 end end
                    if showCat == 11 then curTotal =    #gbc_table              if      #gbc_table == 0 then            showCat = 10 end end
                    if showCat == 10 then curTotal =    #gba_table              if      #gba_table == 0 then            showCat = 9 end end
                    if showCat == 9 then curTotal =     #nds_table              if      #nds_table == 0 then            showCat = 8 end end
                    if showCat == 8 then curTotal =     #nes_table              if      #nes_table == 0 then            showCat = 7 end end
                    if showCat == 7 then curTotal =     #snes_table             if      #snes_table == 0 then           showCat = 6 end end
                    if showCat == 6 then curTotal =     #n64_table              if      #n64_table == 0 then            showCat = 5 end end
                    if showCat == 5 then curTotal =     #psm_table              if      #psm_table == 0 then            showCat = 4 end end
                    if showCat == 4 then curTotal =     #psx_table              if      #psx_table == 0 then            showCat = 3 end end
                    if showCat == 3 then curTotal =     #psp_table              if      #psp_table == 0 then            showCat = 2 end end
                    
                    -- Skip Homebrew category if disabled
                    if showCat == 2 and showHomebrews==0 then -- HB is off
                        showCat = 1
                    end

                    -- -- Skip Homebrew category if disabled
                    -- if showCat == 41 and showSysApps==0 then -- HB is off
                    --     showCat = 1
                    -- end
                    

                    hideBoxes = 0.8 -- used to be 8
                    p = 1
                    master_index = p
                    startCovers = false
                    GetInfoSelected()
                    FreeIcons()


                else

                    -- CATEGORY - Move Forwards

                    -- empty the search results
                    curTotal = #search_results_table   
                    if #search_results_table ~= nil then 
                        search_results_table = {}
                    end

                    if showCat == 44 then
                        -- count favorites
                        create_fav_count_table(files_table)
                    end

                    if filterGames == 1 then

                        -- Only Collections
                        if collection_count ~= 0 then   
                            if showCat < collection_syscount and showCat >= 44 then

                                if showCat == 44 or showCat == 45 then -- Recent and Fav
                                    showCat = 47
                                else
                                    showCat = showCat + 1
                                end
                            
                            else
                                showCat = 47
                            end
                        end

                    else

                        -- All categories including collections
                        if showCat < collection_syscount then
                            -- Skip All category if disabled
                            if showCat==0 and showAll==0 then 
                                showCat = 1
                            -- Skip Homebrews category if disabled
                            elseif showCat==1 and showHomebrews==0 then
                                showCat = 3
                            elseif showCat==46 then
                                if showAll==0 then
                                    showCat = 1
                                else
                                    showCat = 0
                                end
                            else
                                showCat = showCat + 1
                            end
                        elseif showCat == collection_syscount then
                            if showAll==0 then
                                showCat = 1
                            else
                                showCat = 0
                            end
                        else
                            showCat = 0
                        end


                    end

                    
                    -- Start skip empty categories
                    if showCat == 3 then curTotal =     #psp_table              if      #psp_table == 0 then            showCat = 4 end end
                    if showCat == 4 then curTotal =     #psx_table              if      #psx_table == 0 then            showCat = 5 end end
                    if showCat == 5 then curTotal =     #psm_table              if      #psm_table == 0 then            showCat = 6 end end
                    if showCat == 6 then curTotal =     #n64_table              if      #n64_table == 0 then            showCat = 7 end end
                    if showCat == 7 then curTotal =     #snes_table             if      #snes_table == 0 then           showCat = 8 end end
                    if showCat == 8 then curTotal =     #nes_table              if      #nes_table == 0 then            showCat = 9 end end
                    if showCat == 9 then curTotal =     #nds_table              if      #nds_table == 0 then            showCat = 10 end end
                    if showCat == 10 then curTotal =    #gba_table              if      #gba_table == 0 then            showCat = 11 end end
                    if showCat == 11 then curTotal =    #gbc_table              if      #gbc_table == 0 then            showCat = 12 end end
                    if showCat == 12 then curTotal =    #gb_table               if      #gb_table == 0 then             showCat = 13 end end
                    if showCat == 13 then curTotal =    #dreamcast_table        if      #dreamcast_table == 0 then      showCat = 14 end end
                    if showCat == 14 then curTotal =    #sega_cd_table          if      #sega_cd_table == 0 then        showCat = 15 end end
                    if showCat == 15 then curTotal =    #s32x_table             if      #s32x_table == 0 then           showCat = 16 end end
                    if showCat == 16 then curTotal =    #md_table               if      #md_table == 0 then             showCat = 17 end end
                    if showCat == 17 then curTotal =    #sms_table              if      #sms_table == 0 then            showCat = 18 end end
                    if showCat == 18 then curTotal =    #gg_table               if      #gg_table == 0 then             showCat = 19 end end
                    if showCat == 19 then curTotal =    #tg16_table             if      #tg16_table == 0 then           showCat = 20 end end
                    if showCat == 20 then curTotal =    #tgcd_table             if      #tgcd_table == 0 then           showCat = 21 end end
                    if showCat == 21 then curTotal =    #pce_table              if      #pce_table == 0 then            showCat = 22 end end
                    if showCat == 22 then curTotal =    #pcecd_table            if      #pcecd_table == 0 then          showCat = 23 end end
                    if showCat == 23 then curTotal =    #amiga_table            if      #amiga_table == 0 then          showCat = 24 end end
                    if showCat == 24 then curTotal =    #scummvm_table          if      #scummvm_table == 0 then        showCat = 25 end end
                    if showCat == 25 then curTotal =    #c64_table              if      #c64_table == 0 then            showCat = 26 end end
                    if showCat == 26 then curTotal =    #wswan_col_table        if      #wswan_col_table == 0 then      showCat = 27 end end
                    if showCat == 27 then curTotal =    #wswan_table            if      #wswan_table == 0 then          showCat = 28 end end
                    if showCat == 28 then curTotal =    #pico8_table            if      #pico8_table == 0 then          showCat = 29 end end
                    if showCat == 29 then curTotal =    #msx2_table             if      #msx2_table == 0 then           showCat = 30 end end
                    if showCat == 30 then curTotal =    #msx1_table             if      #msx1_table == 0 then           showCat = 31 end end
                    if showCat == 31 then curTotal =    #zxs_table              if      #zxs_table == 0 then            showCat = 32 end end
                    if showCat == 32 then curTotal =    #atari_7800_table       if      #atari_7800_table == 0 then     showCat = 33 end end
                    if showCat == 33 then curTotal =    #atari_5200_table       if      #atari_5200_table == 0 then     showCat = 34 end end
                    if showCat == 34 then curTotal =    #atari_2600_table       if      #atari_2600_table == 0 then     showCat = 35 end end
                    if showCat == 35 then curTotal =    #atari_lynx_table       if      #atari_lynx_table == 0 then     showCat = 36 end end
                    if showCat == 36 then curTotal =    #colecovision_table     if      #colecovision_table == 0 then   showCat = 37 end end
                    if showCat == 37 then curTotal =    #vectrex_table          if      #vectrex_table == 0 then        showCat = 38 end end
                    if showCat == 38 then curTotal =    #fba_table              if      #fba_table == 0 then            showCat = 39 end end
                    if showCat == 39 then curTotal =    #mame_2003_plus_table   if      #mame_2003_plus_table == 0 then showCat = 40 end end
                    if showCat == 40 then curTotal =    #mame_2000_table        if      #mame_2000_table == 0 then      showCat = 41 end end
                    if showCat == 41 then curTotal =    #neogeo_table           if      #neogeo_table == 0 then         showCat = 42 end end
                    if showCat == 42 then curTotal =    #ngpc_table             if      #ngpc_table == 0 then           showCat = 43 end end
                    if showCat == 43 then curTotal =    #sysapps_table          if      #sysapps_table == 0 then        showCat = 44 end end
                    if showCat == 44 then
                        -- count favorites
                        create_fav_count_table(files_table)

                        curTotal = #fav_count
                        if #fav_count == 0 then showCat = 45
                        end
                    end
                    if showCat == 45 then 
                        curTotal = #recently_played_table
                        if #recently_played_table == 0 then showCat = 46
                        end
                    end
                    
                    if showCat == 46 then
                        curTotal = #search_results_table
                        if #search_results_table == 0 then
                            if collection_count ~= 0 then
                                if showCollections == 0 then
                                    if showAll==0 then
                                        showCat = 1
                                    else
                                        showCat = 0
                                    end
                                else
                                    showCat = 47
                                end
                            else
                                if showAll==0 then
                                    showCat = 1
                                else
                                    showCat = 0
                                end
                            end
                        end
                    end

                    if showCat > 47 and showCat < collection_syscount then
                        if next(xCatLookup(showCat)) ~= nil then
                        else
                            -- empty
                            showCat = showCat + 1
                        end

                    -- elseif showCat > 47 and showCat == collection_syscount then
                    elseif showCat > 47 and showCat == collection_syscount then
                        
                        -- -- empty
                        -- if showAll==0 then
                        --     showCat = 1
                        -- else
                        --     showCat = 0
                        -- end

                    else

                    end


                    hideBoxes = 0.8 -- used to be 8
                    p = 1
                    master_index = p
                    startCovers = false
                    GetInfoSelected()
                    FreeIcons()
                end


            else
            end
        elseif (Controls.check(pad, SCE_CTRL_CIRCLE_MAP) and not Controls.check(oldpad, SCE_CTRL_CIRCLE_MAP)) and setChangeViews == 1 then
            -- VIEW
            
            state = Keyboard.getState()
            if state ~= RUNNING then
                -- don't change view if cancel search

                if set2DViews == 1 then
                    showViewMax = 6
                else
                    showViewMax = 4
                end

                if showView < showViewMax then
                    showView = showView + 1
                else
                    showView = 0

                    master_index = p

                    -- Instantly move to selection
                    if startCovers == false then
                        targetX = base_x
                        startCovers = true
                        GetInfoSelected()
                    end

                end

                

                menuY = 0
                startCovers = false

                --Save settings
                SaveSettings()
            else
            end

        elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then
            if showView ~= 6 then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if setSounds == 1 then
                        Sound.play(click, NO_LOOP)
                    end
                    p = p - 1
                    
                    if p > 0 then
                        GetNameAndAppTypeSelected()
                    end
                    
                    if (p <= master_index) then
                        master_index = p
                    end
                else
                end
            else
            end
        elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
            if showView ~= 6 then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    if setSounds == 1 then
                        Sound.play(click, NO_LOOP)
                    end
                    p = p + 1
                    
                    if p <= curTotal then
                        GetNameAndAppTypeSelected()
                    end
                    
                    if (p >= master_index) then
                        master_index = p
                    end
                else
                end
            else
                state = Keyboard.getState()
                if state ~= RUNNING then

                    -- Filter games
                    showMenu = 25
                    menuY = 0

                else
                end
            end
        elseif (Controls.check(pad, SCE_CTRL_LTRIGGER)) and not (Controls.check(oldpad, SCE_CTRL_LTRIGGER)) then
            state = Keyboard.getState()
            if state ~= RUNNING then
                if setSounds == 1 then
                    Sound.play(click, NO_LOOP)
                end


                    -- Alphabet skip - Backwards: While holding right
                    if (Controls.check(pad, SCE_CTRL_DOWN)) then   
                        
                        -- Original game - Get first character
                        start_letter_backwards = string.upper(string.sub(xCatLookup(showCat)[p].apptitle, 1, 1))
                        
                        -- If less than 5 and not on the first game, move to first position
                        -- if p <= 5 then
                        --     p = 1
                        -- end

                        -- Keep moving until the first letter no longer matches the first letter of the Original game
                        while string.upper(string.sub(xCatLookup(showCat)[p].apptitle, 1, 1)) == start_letter_backwards do
                            
                            -- If we're on the first game, move to the last
                            if p == 1 then
                                p = #xCatLookup(showCat)
                                master_index = p
                            else
                                p = p - 1
                            end

                        end

                        -- We are now at the last game in the character set eg, "Azz", we need to move futher back again to the first
                        last_game_in_char_set = string.upper(string.sub(xCatLookup(showCat)[p].apptitle, 1, 1))

                        -- Keep moving backwards until the first letter no longer matches the last game in the character set, then move forward 1 to reach the first in the character set
                        while string.upper(string.sub(xCatLookup(showCat)[p].apptitle, 1, 1)) == last_game_in_char_set and p >= 2 do
                            p = p - 1
                        end

                        -- If it's a number, go to the first game, otherwise move forwards one to get to the first game in the character set 
                        if string.match (last_game_in_char_set, "%d") then
                            p = 1
                            master_index = p
                        else
                            if p ~= 1 then
                                p = p + 1
                            end
                        end

                    else
                        if showView == 6 then
                            p = p - 8 -- page up in list view
                        else
                            p = p - 5
                        end
                    end

                if p > 0 then
                    GetNameAndAppTypeSelected()
                end
                
                if (p <= master_index) then
                    master_index = p
                end
            else
            end
        elseif (Controls.check(pad, SCE_CTRL_RTRIGGER)) and not (Controls.check(oldpad, SCE_CTRL_RTRIGGER)) then
            state = Keyboard.getState()
            if state ~= RUNNING then
                if setSounds == 1 then
                    Sound.play(click, NO_LOOP)
                end

                    -- Alphabet skip - Forwards: While holding right
                    if (Controls.check(pad, SCE_CTRL_DOWN)) then

                        -- Original game - Get first character
                        start_letter_forward = string.upper(string.sub(xCatLookup(showCat)[p].apptitle, 1, 1))

                        if string.match(start_letter_forward, "%d") then
                            
                            -- If first character is a number - Move to first letter
                            while string.match(string.sub(xCatLookup(showCat)[p].apptitle, 1, 1), "%d") do
                                p = p + 1
                            end

                        else
                            
                            -- If first character is a letter - Keep moving until the first letter no longer matches the first letter of the Original game
                            if string.upper(string.sub(xCatLookup(showCat)[p].apptitle, 1, 1)) ~= nil then
                                while string.upper(string.sub(xCatLookup(showCat)[p].apptitle, 1, 1)) == start_letter_forward and p < #xCatLookup(showCat) do
                                    p = p + 1
                                end
                            end

                        end

                        -- If reached then end - Loop back to first game
                        if p == #xCatLookup(showCat) then
                            p = 1
                            master_index = p
                        end

                    else
                        if showView == 6 then
                            p = p + 8 -- page down in list view
                        else
                            p = p + 5
                        end
                    end
                
                if p <= curTotal then
                    GetNameAndAppTypeSelected()
                end
                
                if (p >= master_index) then
                    master_index = p
                end
            else
            end

        -- game list
        elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
            if showView ~= 6 then
                state = Keyboard.getState()
                if state ~= RUNNING then

                    -- Filter games
                    showMenu = 25
                    menuY = 0

                else
                end
            else
                if setSounds == 1 then
                    Sound.play(click, NO_LOOP)
                end
                p = p - 1
            end

        -- game list
        elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
            if showView == 6 then
                if setSounds == 1 then
                    Sound.play(click, NO_LOOP)
                end
                p = p + 1
            else
            end
        end
        
        -- Touch Input
        if showView ~= 6 then
            if x1 ~= nil then
                if touchdown == 0 and delayTouch < 0.5 then
                    touchdown = 1
                    xstart = x1
                    delayTouch = 5
                end
                if touchdown > 0 and delayTouch > 0.5 then
                    if x1 > xstart + 60 then
                        touchdown = 2
                        xstart = x1
                        p = p - 1
                        if p > 0 then
                            GetNameAndAppTypeSelected()
                        end
                        if (p <= master_index) then
                            master_index = p
                        end
                    elseif x1 < xstart - 60 then
                        touchdown = 2
                        xstart = x1
                        p = p + 1
                        if p <= curTotal then
                            GetNameAndAppTypeSelected()
                        end
                        if (p >= master_index) then
                            master_index = p
                        end
                    
                    end
                end
            end
        else
            if y1 ~= nil then
                if touchdown == 0 and delayTouch < 0.5 then
                    touchdown = 1
                    ystart = y1
                    delayTouch = 5
                end
                if touchdown > 0 and delayTouch > 0.5 then
                    if y1 > ystart + 60 then
                        touchdown = 2
                        ystart = y1
                        p = p - 1
                        if p > 0 then
                            GetNameAndAppTypeSelected()
                        end
                        if (p <= master_index) then
                            master_index = p
                        end
                    elseif y1 < ystart - 60 then
                        touchdown = 2
                        ystart = y1
                        p = p + 1
                        if p <= curTotal then
                            GetNameAndAppTypeSelected()
                        end
                        if (p >= master_index) then
                            master_index = p
                        end
                    
                    end
                end
            end
        end
        
    elseif showMenu > 0 then
        if (Controls.check(pad, SCE_CTRL_CIRCLE_MAP) and not Controls.check(oldpad, SCE_CTRL_CIRCLE_MAP)) then
            status = System.getMessageState()
            if status ~= RUNNING then

                if showMenu == 3 then -- Categories
                    showMenu = 2
                    menuY = 1
                elseif showMenu == 4 then -- Theme
                    showMenu = 2
                    menuY = 2
                elseif showMenu == 5 then -- Artwork
                    showMenu = 2
                    menuY = 4
                elseif showMenu == 6 then -- Scan Settings
                    showMenu = 2
                    menuY = 5
                elseif showMenu == 7 then -- About
                    showMenu = 2
                    menuY = 0
                elseif showMenu == 8 then -- Game directories
                    showMenu = 6 -- Scan Settings
                    menuY = 1
                elseif showMenu == 9 then -- Rom browser partitions
                    showMenu = 8 -- Game directories
                    menuY = 2
                elseif showMenu == 10 then -- Rom browser partitions not found
                    showMenu = 8 -- Game directories
                    menuY = 2
                elseif showMenu == 11 then -- Rom Browser
                    -- Do nothing
                elseif showMenu == 12 then -- Audio
                    showMenu = 2
                    menuY = 3
                elseif showMenu == 13 then -- About - Guide 1
                    showMenu = 7
                    menuY = 1 -- Guide 1
                elseif showMenu == 14 then -- About - Guide 2
                    showMenu = 7
                    menuY = 2 -- Guide 2
                elseif showMenu == 15 then -- About - Guide 3
                    showMenu = 7
                    menuY = 3 -- Guide 3
                elseif showMenu == 16 then -- About - Guide 4
                    showMenu = 7
                    menuY = 4 -- Guide 4
                elseif showMenu == 17 then -- About - Guide 5
                    showMenu = 7
                    menuY = 5 -- Guide 5
                elseif showMenu == 18 then -- About - Guide 6
                    showMenu = 7
                    menuY = 6 -- Guide 6
                elseif showMenu == 19 then -- Other Settings
                    showMenu = 2
                    menuY = 6 -- Other Settings
                elseif showMenu == 20 then -- Game Options
                    showMenu = 1
                    menuY=0
                elseif showMenu == 21 then -- Game Options Adrenaline
                    showMenu = 20
                    menuY=0
                elseif showMenu == 22 then -- Add to collection
                    showMenu = 20
                    menuY=0
                elseif showMenu == 23 then -- Remove from collection
                    showMenu = 20
                    menuY=0
                elseif showMenu == 24 then -- Edit collections
                    showMenu = 19
                    menuY=5
                elseif showMenu == 26 then -- Collection Custom sort order
                    -- showMenu = 24
                    -- menuY=4
                    
                elseif showMenu == 2 then
                    -- If search cancelled with circle, return to settings menu
                    state = Keyboard.getState()
                    if state == RUNNING then
                        showMenu = 2
                        menuY = 0
                    else
                        showMenu = 0
                        menuY = 0
                    end
                else
                    showMenu = 0
                end

                prvRotY = 0
                if setBackground >= 1 then
                    Render.useTexture(modBackground, imgCustomBack)
                end
            end
        end

        -- Triangle button - Game info screen
        if (Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE)) and showMenu == 1 then
            -- Game Options
            showMenu = 20
            menuY = 0
        end

    end
    
    if delayTouch > 0 then
        delayTouch = delayTouch - 0.1
    else
        delayTouch = 0
        touchdown = 0
    end
    -- End Touch
    -- End Controls


    if showCat == 44 then
        -- count favorites
        create_fav_count_table(files_table)
        
        curTotal = #fav_count
        if #fav_count == 0 then
            p = 0
            master_index = p
        end
    else
        curTotal = #xCatLookup(showCat)
        if #xCatLookup(showCat) == 0 then
            p = 0
            master_index = p
        end
    end

    
    -- Check for out of bounds in menu 
    if p < 1 then
        p = curTotal
        if p >= 1 then
            master_index = p -- 0
        end
        startCovers = false
        GetInfoSelected()
    elseif p > curTotal then
        p = 1
        master_index = p
        startCovers = false
        GetInfoSelected()
    end

    -- Check for out of bounds in menu - ROM Browser
    if i > #scripts then
        i = 1
    elseif i < 1 then
        i = #scripts
    end

    if showView == 6 then
        -- Check for out of bounds in - Game list view
        curTotal = #xCatLookup(showCat)

        if p > curTotal then
            p = 1
            master_index = p
            startCovers = false
            GetInfoSelected()
        elseif p < 1 then
            p = curTotal
            master_index = p
            startCovers = false
            GetInfoSelected()
        end
    end

    
    -- Refreshing screen and oldpad
    Screen.waitVblankStart()
    Screen.flip()
    oldpad = pad

    if oneLoopTimer then -- if the timer is running then...
        oneLoopTime = Timer.getTime(oneLoopTimer) -- save the time
        Timer.destroy(oneLoopTimer)
        oneLoopTimer = nil -- clear timer value
    end 
end
