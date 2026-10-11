-- RetroFlow Launcher - HexFlow Mod version by jimbob4000
-- Based on HexFlow Launcher  version 0.5 by VitaHEX
-- https://www.patreon.com/vitahex

local oneLoopTimer = Timer.new()

-- Open recovery mode if selected from the livearea
local bootparam = System.getBootParams() or ""

if string.match(bootparam, "recovery") then
    dofile("app0:addons/recovery.lua")
    System.exit()
end

-- Not in recovery mode - continue loading

dofile("app0:addons/threads.lua")

-- Speed related settings - MOVED EARLY for maximum performance impact
local cpu_speed = 444 -- Was 333
System.setBusSpeed(222)
System.setGpuSpeed(222)
System.setGpuXbarSpeed(166)
System.setCpuSpeed(cpu_speed)

-- Initialize sound system early for better performance
Sound.init()

local working_dir = "ux0:/app"
local appversion = "8.5.0"
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

local lang_lines = {}

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
["Atari_ST"] = "ux0:/data/RetroFlow/ROMS/Atari - ST",
["DOS"] = "ux0:/data/RetroFlow/ROMS/DOS",
["EasyRPG"] = "ux0:/data/RetroFlow/ROMS/EasyRPG",
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

print_table_loaded = false
function ensure_print_table_loaded()
    if print_table_loaded == false then
        dofile("app0:addons/printTable.lua")
        print_table_loaded = true
    end
end

function print_table_rom_dirs(def_table_name)
    ensure_print_table_loaded()
    print_table_rom_dirs((def_table_name))
end

-- Create directory: Roms
System.createDirectory(romsMainDir)

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
            romUserDir.PlayStation = romDir_Default.PlayStation
        end

        if romUserDir.Nintendo_DS == nil then
            -- Set to DSVita folder rather than RetroFlow folder as DSVita doesn't support custom directories yet.
            romUserDir.Nintendo_DS = "ux0:/data/dsvita"
        end

        if romUserDir.Nintendo_3DS == nil then
            -- Set to Azahar folder rather than RetroFlow folder as Azahar doesn't support custom directories yet.
            romUserDir.Nintendo_3DS = "ux0:/data/azahar/roms"
        end

        if romUserDir.Pico8 == nil then
            romUserDir.Pico8 = romDir_Default.Pico8
        end

        if romUserDir.Atari_ST == nil then
            romUserDir.Atari_ST = romDir_Default.Atari_ST
        end

        if romUserDir.DOS == nil then
            romUserDir.DOS = romDir_Default.DOS
        end

        if romUserDir.EasyRPG == nil then
            romUserDir.EasyRPG = romDir_Default.EasyRPG
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
        ["localIconPath"] = iconDir .. "Sony - PlayStation Vita" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PSVita/",
        ["onlineSnapPathSystem"] = "",
        ["Missing_Cover"] = "missing_cover_psv.png",
        ["icon"] = "icon_psv.png",
    },
    [2] = 
    {
        ["apptype"] = 0,
        ["table"] = "homebrews_table",
        ["user_db_file"] = "db_homebrews.lua",
        -- ["romFolder"] = "",
        ["localCoverPath"] = covDir .. "Homebrew" .. "/",
        ["localSnapPath"] = snapDir .. "Homebrew" .. "/",
        ["localIconPath"] = iconDir .. "Homebrew" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/HOMEBREW/",
        ["onlineSnapPathSystem"] = "",
        ["Missing_Cover"] = "missing_cover_homebrew.png",
        ["icon"] = "icon_homebrew.png",
    },
    [3] = 
    {
        ["apptype"] = 2,
        ["table"] = "psp_table",
        ["user_db_file"] = "db_psp.lua",
        -- ["romFolder"] = "",
        ["localCoverPath"] = covDir .. "Sony - PlayStation Portable" .. "/",
        ["localSnapPath"] = snapDir .. "Sony - PlayStation Portable" .. "/",
        ["localIconPath"] = iconDir .. "Sony - PlayStation Portable" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PSP/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/PSP/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_psp.png",
        ["icon"] = "icon_psp.png",
    },
    [4] = 
    {
        ["apptype"] = 3,
        ["table"] = "psx_table",
        ["user_db_file"] = "db_psx.lua",
        ["romFolder"] = romUserDir.PlayStation,
        ["localCoverPath"] = covDir .. "Sony - PlayStation" .. "/",
        ["localSnapPath"] = snapDir .. "Sony - PlayStation" .. "/",
        ["localIconPath"] = iconDir .. "Sony - PlayStation" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PS1/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/PS1/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_psx.png",
        ["icon"] = "icon_psx.png",
    },
    [5] = 
    {
        ["apptype"] = 5,
        ["table"] = "n64_table",
        ["user_db_file"] = "db_n64.lua",
        ["romFolder"] = romUserDir.Nintendo_64,
        ["localCoverPath"] = covDir .. "Nintendo - Nintendo 64" .. "/",
        ["localSnapPath"] = snapDir .. "Nintendo - Nintendo 64" .. "/",
        ["localIconPath"] = iconDir .. "Nintendo - Nintendo 64" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/N64/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Nintendo_64/ec7430189022b591a8fb0fa16101201f861363f8/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_n64.png",
        ["icon"] = "icon_n64.png",
    },
    [6] = 
    {
        ["apptype"] = 6,
        ["table"] = "snes_table",
        ["user_db_file"] = "db_snes.lua",
        ["romFolder"] = romUserDir.Super_Nintendo,
        ["localCoverPath"] = covDir .. "Nintendo - Super Nintendo Entertainment System" .. "/",
        ["localSnapPath"] = snapDir .. "Nintendo - Super Nintendo Entertainment System" .. "/",
        ["localIconPath"] = iconDir .. "Nintendo - Super Nintendo Entertainment System" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/SNES/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Super_Nintendo_Entertainment_System/5c469e48755fec26b4b9d651b6962a2cdea3133d/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_snes.png",
        ["icon"] = "icon_snes.png",
    },
    [7] = 
    {
        ["apptype"] = 7,
        ["table"] = "nes_table",
        ["user_db_file"] = "db_nes.lua",
        ["romFolder"] = romUserDir.Nintendo_Entertainment_System,
        ["localCoverPath"] = covDir .. "Nintendo - Nintendo Entertainment System" .. "/",
        ["localSnapPath"] = snapDir .. "Nintendo - Nintendo Entertainment System" .. "/",
        ["localIconPath"] = iconDir .. "Nintendo - Nintendo Entertainment System" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/NES/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Nintendo_Entertainment_System/f4415b21a256bcbe7b30a9d71a571d6ba4815c71/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_nes.png",
        ["icon"] = "icon_nes.png",
    },
    [8] = 
    {
        ["apptype"] = 8,
        ["table"] = "gba_table",
        ["user_db_file"] = "db_gba.lua",
        ["romFolder"] = romUserDir.Game_Boy_Advance,
        ["localCoverPath"] = covDir .. "Nintendo - Game Boy Advance" .. "/",
        ["localSnapPath"] = snapDir .. "Nintendo - Game Boy Advance" .. "/",
        ["localIconPath"] = iconDir .. "Nintendo - Game Boy Advance" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/GBA/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Game_Boy_Advance/fd58a8fae1cec5857393c0405c3d0514c7fdf6cf/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_gba.png",
        ["icon"] = "icon_gba.png",
    },
    [9] = 
    {
        ["apptype"] = 9,
        ["table"] = "gbc_table",
        ["user_db_file"] = "db_gbc.lua",
        ["romFolder"] = romUserDir.Game_Boy_Color,
        ["localCoverPath"] = covDir .. "Nintendo - Game Boy Color" .. "/",
        ["localSnapPath"] = snapDir .. "Nintendo - Game Boy Color" .. "/",
        ["localIconPath"] = iconDir .. "Nintendo - Game Boy Color" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/GBC/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Game_Boy_Color/a0cc546d2b4e2eebefdcf91b90ae3601c377c3ce/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_gbc.png",
        ["icon"] = "icon_gbc.png",
    },
    [10] = 
    {
        ["apptype"] = 10,
        ["table"] = "gb_table",
        ["user_db_file"] = "db_gb.lua",
        ["romFolder"] = romUserDir.Game_Boy,
        ["localCoverPath"] = covDir .. "Nintendo - Game Boy" .. "/",
        ["localSnapPath"] = snapDir .. "Nintendo - Game Boy" .. "/",
        ["localIconPath"] = iconDir .. "Nintendo - Game Boy" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/GB/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Game_Boy/d5ad94ba8c5159381d7f618ec987e609d23ae203/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_gb.png",
        ["icon"] = "icon_gb.png",
    },
    [11] = 
    {
        ["apptype"] = 11,
        ["table"] = "dreamcast_table",
        ["user_db_file"] = "db_dreamcast.lua",
        ["romFolder"] = romUserDir.Sega_Dreamcast,
        ["localCoverPath"] = covDir .. "Sega - Dreamcast" .. "/",
        ["localSnapPath"] = snapDir .. "Sega - Dreamcast" .. "/",
        ["localIconPath"] = iconDir .. "Sega - Dreamcast" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/DC/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/DC/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_dreamcast_eur.png",
        ["icon"] = "icon_dreamcast_eur.png",
    },
    [12] = 
    {
        ["apptype"] = 12,
        ["table"] = "sega_cd_table",
        ["user_db_file"] = "db_sega_cd.lua",
        ["romFolder"] = romUserDir.Sega_CD,
        ["localCoverPath"] = covDir .. "Sega - Mega-CD - Sega CD" .. "/",
        ["localSnapPath"] = snapDir .. "Sega - Mega-CD - Sega CD" .. "/",
        ["localIconPath"] = iconDir .. "Sega - Mega-CD - Sega CD" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/SEGA_CD/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Sega_-_Mega-CD_-_Sega_CD/a8737a2a394645f27415f7346ac2ceb0cfcd0942/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_sega_cd.png",
        ["icon"] = "icon_sega_cd.png",
    },
    [13] = 
    {
        ["apptype"] = 13,
        ["table"] = "s32x_table",
        ["user_db_file"] = "db_32x.lua",
        ["romFolder"] = romUserDir.Sega_32X,
        ["localCoverPath"] = covDir .. "Sega - 32X" .. "/",
        ["localSnapPath"] = snapDir .. "Sega - 32X" .. "/",
        ["localIconPath"] = iconDir .. "Sega - 32X" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/32X/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Sega_-_32X/4deb45e651e29506a7bfc440408b3343f0e1a3ae/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_32x.png",
        ["icon"] = "icon_32x.png",
    },
    [14] = 
    {
        ["apptype"] = 14,
        ["table"] = "md_table",
        ["user_db_file"] = "db_md.lua",
        ["romFolder"] = romUserDir.Sega_Mega_Drive,
        ["localCoverPath"] = covDir .. "Sega - Mega Drive - Genesis" .. "/",
        ["localSnapPath"] = snapDir .. "Sega - Mega Drive - Genesis" .. "/",
        ["localIconPath"] = iconDir .. "Sega - Mega Drive - Genesis" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MD/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Sega_-_Mega_Drive_-_Genesis/6ac232741f979a6f0aa54d077ff392fe170f4725/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_md.png",
        ["icon"] = "icon_md.png",
    },
    [15] = 
    {
        ["apptype"] = 15,
        ["table"] = "sms_table",
        ["user_db_file"] = "db_sms.lua",
        ["romFolder"] = romUserDir.Sega_Master_System,
        ["localCoverPath"] = covDir .. "Sega - Master System - Mark III" .. "/",
        ["localSnapPath"] = snapDir .. "Sega - Master System - Mark III" .. "/",
        ["localIconPath"] = iconDir .. "Sega - Master System - Mark III" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/SMS/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Sega_-_Master_System_-_Mark_III/02f8c7f989db6124475b7e0978c27af8534655eb/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_sms.png",
        ["icon"] = "icon_sms.png",
    },
    [16] = 
    {
        ["apptype"] = 16,
        ["table"] = "gg_table",
        ["user_db_file"] = "db_gg.lua",
        ["romFolder"] = romUserDir.Sega_Game_Gear,
        ["localCoverPath"] = covDir .. "Sega - Game Gear" .. "/",
        ["localSnapPath"] = snapDir .. "Sega - Game Gear" .. "/",
        ["localIconPath"] = iconDir .. "Sega - Game Gear" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/GG/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Sega_-_Game_Gear/b99b424d2adcf5ccd45c372db2c15f01653f2b92/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_gg.png",
        ["icon"] = "icon_gg.png",
    },
    [17] = 
    {
        ["apptype"] = 17,
        ["table"] = "tg16_table",
        ["user_db_file"] = "db_tg16.lua",
        ["romFolder"] = romUserDir.TurboGrafx_16,
        ["localCoverPath"] = covDir .. "NEC - TurboGrafx 16" .. "/",
        ["localSnapPath"] = snapDir .. "NEC - TurboGrafx 16" .. "/",
        ["localIconPath"] = iconDir .. "NEC - TurboGrafx 16" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/TG16/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/NEC_-_PC_Engine_-_TurboGrafx_16/d0d6e27f84d757416799e432154e0adcadb154c9/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_tg16.png",
        ["icon"] = "icon_tg16.png",
    },
    [18] = 
    {
        ["apptype"] = 18,
        ["table"] = "tgcd_table",
        ["user_db_file"] = "db_tgcd.lua",
        ["romFolder"] = romUserDir.TurboGrafx_CD,
        ["localCoverPath"] = covDir .. "NEC - TurboGrafx CD" .. "/",
        ["localSnapPath"] = snapDir .. "NEC - TurboGrafx CD" .. "/",
        ["localIconPath"] = iconDir .. "NEC - TurboGrafx CD" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/TG_CD/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/NEC_-_PC_Engine_CD_-_TurboGrafx-CD/cd554a5cdca862f090e6c3f9510a3b1b6c2d5b38/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_tgcd.png",
        ["icon"] = "icon_tgcd.png",
    },
    [19] = 
    {
        ["apptype"] = 19,
        ["table"] = "pce_table",
        ["user_db_file"] = "db_pce.lua",
        ["romFolder"] = romUserDir.PC_Engine,
        ["localCoverPath"] = covDir .. "NEC - PC Engine" .. "/",
        ["localSnapPath"] = snapDir .. "NEC - PC Engine" .. "/",
        ["localIconPath"] = iconDir .. "NEC - PC Engine" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/PCE/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/NEC_-_PC_Engine_-_TurboGrafx_16/d0d6e27f84d757416799e432154e0adcadb154c9/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_pce.png",
        ["icon"] = "icon_pce.png",
    },
    [20] = 
    {
        ["apptype"] = 20,
        ["table"] = "pcecd_table",
        ["user_db_file"] = "db_pcecd.lua",
        ["romFolder"] = romUserDir.PC_Engine_CD,
        ["localCoverPath"] = covDir .. "NEC - PC Engine CD" .. "/",
        ["localSnapPath"] = snapDir .. "NEC - PC Engine CD" .. "/",
        ["localIconPath"] = iconDir .. "NEC - PC Engine CD" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/PCE_CD/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/NEC_-_PC_Engine_CD_-_TurboGrafx-CD/cd554a5cdca862f090e6c3f9510a3b1b6c2d5b38/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_pcecd.png",
        ["icon"] = "icon_pcecd.png",
    },
    [21] = 
    {
        ["apptype"] = 21,
        ["table"] = "amiga_table",
        ["user_db_file"] = "db_amiga.lua",
        ["romFolder"] = romUserDir.Amiga,
        ["localCoverPath"] = covDir .. "Commodore - Amiga" .. "/",
        ["localSnapPath"] = snapDir .. "Commodore - Amiga" .. "/",
        ["localIconPath"] = iconDir .. "Commodore - Amiga" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/AMIGA/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Commodore_-_Amiga/b6446e83b3dc93446371a5dbfb0f24574eb56461/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_amiga.png",
        ["icon"] = "icon_amiga.png",
    },
    [22] = 
    {
        ["apptype"] = 22,
        ["table"] = "c64_table",
        ["user_db_file"] = "db_c64.lua",
        ["romFolder"] = romUserDir.Commodore_64,
        ["localCoverPath"] = covDir .. "Commodore - 64" .. "/",
        ["localSnapPath"] = snapDir .. "Commodore - 64" .. "/",
        ["localIconPath"] = iconDir .. "Commodore - 64" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/C64/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Commodore_-_64/df90042ef9823d1b0b9d3ec303051f555dca2246/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_c64.png",
        ["icon"] = "icon_c64.png",
    },
    [23] = 
    {
        ["apptype"] = 23,
        ["table"] = "wswan_col_table",
        ["user_db_file"] = "db_wswan_col.lua",
        ["romFolder"] = romUserDir.WonderSwan_Color,
        ["localCoverPath"] = covDir .. "Bandai - WonderSwan Color" .. "/",
        ["localSnapPath"] = snapDir .. "Bandai - WonderSwan Color" .. "/",
        ["localIconPath"] = iconDir .. "Bandai - WonderSwan Color" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/WSWAN_COL/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Bandai_-_WonderSwan_Color/5b57a78fafa4acb8590444c15c116998fcea9dce/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_wswan_col.png",
        ["icon"] = "icon_wswan_col.png",
    },
    [24] = 
    {
        ["apptype"] = 24,
        ["table"] = "wswan_table",
        ["user_db_file"] = "db_wswan.lua",
        ["romFolder"] = romUserDir.WonderSwan,
        ["localCoverPath"] = covDir .. "Bandai - WonderSwan" .. "/",
        ["localSnapPath"] = snapDir .. "Bandai - WonderSwan" .. "/",
        ["localIconPath"] = iconDir .. "Bandai - WonderSwan" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/WSWAN/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Bandai_-_WonderSwan/3913706e173ec5f8c0cdeebd225b16f4dc3dd6c6/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_wswan.png",
        ["icon"] = "icon_wswan.png",
    },
    [25] = 
    {
        ["apptype"] = 25,
        ["table"] = "msx2_table",
        ["user_db_file"] = "db_msx2.lua",
        ["romFolder"] = romUserDir.MSX2,
        ["localCoverPath"] = covDir .. "Microsoft - MSX2" .. "/",
        ["localSnapPath"] = snapDir .. "Microsoft - MSX2" .. "/",
        ["localIconPath"] = iconDir .. "Microsoft - MSX2" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MSX2/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Microsoft_-_MSX2/12d7e10728cc4c3314b8b14b5a9b1892a886d2ab/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_msx2.png",
        ["icon"] = "icon_msx2.png",
    },
    [26] = 
    {
        ["apptype"] = 26,
        ["table"] = "msx1_table",
        ["user_db_file"] = "db_msx1.lua",
        ["romFolder"] = romUserDir.MSX,
        ["localCoverPath"] = covDir .. "Microsoft - MSX" .. "/",
        ["localSnapPath"] = snapDir .. "Microsoft - MSX" .. "/",
        ["localIconPath"] = iconDir .. "Microsoft - MSX" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MSX/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Microsoft_-_MSX/ed54675a51597fd5bf66a45318a273f330b7662f/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_msx1.png",
        ["icon"] = "icon_msx1.png",
    },
    [27] = 
    {
        ["apptype"] = 27,
        ["table"] = "zxs_table",
        ["user_db_file"] = "db_zxs.lua",
        ["romFolder"] = romUserDir.ZX_Spectrum,
        ["localCoverPath"] = covDir .. "Sinclair - ZX Spectrum" .. "/",
        ["localSnapPath"] = snapDir .. "Sinclair - ZX Spectrum" .. "/",
        ["localIconPath"] = iconDir .. "Sinclair - ZX Spectrum" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/ZXS/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Sinclair_-_ZX_Spectrum/d23c953dc9853983fb2fce2b8e96a1ccc08b70e8/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_zxs.png",
        ["icon"] = "icon_zxs.png",
    },
    [28] = 
    {
        ["apptype"] = 28,
        ["table"] = "atari_7800_table",
        ["user_db_file"] = "db_atari_7800.lua",
        ["romFolder"] = romUserDir.Atari_7800,
        ["localCoverPath"] = covDir .. "Atari - 7800" .. "/",
        ["localSnapPath"] = snapDir .. "Atari - 7800" .. "/",
        ["localIconPath"] = iconDir .. "Atari - 7800" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/ATARI_7800/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Atari_-_7800/eff4d49a71a62764dd66d414b1bf7a843f85f7ae/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_atari_7800.png",
        ["icon"] = "icon_atari_7800.png",
    },
    [29] = 
    {
        ["apptype"] = 29,
        ["table"] = "atari_5200_table",
        ["user_db_file"] = "db_atari_5200.lua",
        ["romFolder"] = romUserDir.Atari_5200,
        ["localCoverPath"] = covDir .. "Atari - 5200" .. "/",
        ["localSnapPath"] = snapDir .. "Atari - 5200" .. "/",
        ["localIconPath"] = iconDir .. "Atari - 5200" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/ATARI_5200/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Atari_-_5200/793489381646954046dd1767a1af0fa4f6b86c24/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_atari_5200.png",
        ["icon"] = "icon_atari_5200.png",
    },
    [30] = 
    {
        ["apptype"] = 30,
        ["table"] = "atari_2600_table",
        ["user_db_file"] = "db_atari_2600.lua",
        ["romFolder"] = romUserDir.Atari_2600,
        ["localCoverPath"] = covDir .. "Atari - 2600" .. "/",
        ["localSnapPath"] = snapDir .. "Atari - 2600" .. "/",
        ["localIconPath"] = iconDir .. "Atari - 2600" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/ATARI_2600/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Atari_-_2600/ea2ba38f9bace8e85539d12e2f65e31c797c6585/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_atari_2600.png",
        ["icon"] = "icon_atari_2600.png",
    },
    [31] = 
    {
        ["apptype"] = 31,
        ["table"] = "atari_lynx_table",
        ["user_db_file"] = "db_atari_lynx.lua",
        ["romFolder"] = romUserDir.Atari_Lynx,
        ["localCoverPath"] = covDir .. "Atari - Lynx" .. "/",
        ["localSnapPath"] = snapDir .. "Atari - Lynx" .. "/",
        ["localIconPath"] = iconDir .. "Atari - Lynx" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/ATARI_LYNX/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Atari_-_Lynx/91278444136e9c19f89331421ffe84cce6f82fb9/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_atari_lynx.png",
        ["icon"] = "icon_atari_lynx.png",
    },
    [32] = 
    {
        ["apptype"] = 32,
        ["table"] = "colecovision_table",
        ["user_db_file"] = "db_colecovision.lua",
        ["romFolder"] = romUserDir.ColecoVision,
        ["localCoverPath"] = covDir .. "Coleco - ColecoVision" .. "/",
        ["localSnapPath"] = snapDir .. "Coleco - ColecoVision" .. "/",
        ["localIconPath"] = iconDir .. "Coleco - ColecoVision" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/COLECOVISION/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Coleco_-_ColecoVision/332c63436431ea5fceedf50b94447bb6e7a8e1f5/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_colecovision.png",
        ["icon"] = "icon_colecovision.png",
    },
    [33] = 
    {
        ["apptype"] = 33,
        ["table"] = "vectrex_table",
        ["user_db_file"] = "db_vectrex.lua",
        ["romFolder"] = romUserDir.Vectrex,
        ["localCoverPath"] = covDir .. "GCE - Vectrex" .. "/",
        ["localSnapPath"] = snapDir .. "GCE - Vectrex" .. "/",
        ["localIconPath"] = iconDir .. "GCE - Vectrex" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/VECTREX/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/GCE_-_Vectrex/ed03e5d1214399d2f4429109874b2ad3d8a18709/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_vectrex.png",
        ["icon"] = "icon_vectrex.png",
    },
    [34] = 
    {
        ["apptype"] = 34,
        ["table"] = "fba_table",
        ["user_db_file"] = "db_fba.lua",
        ["romFolder"] = romUserDir.FBA_2012,
        ["localCoverPath"] = covDir .. "FBA 2012" .. "/",
        ["localSnapPath"] = snapDir .. "FBA 2012" .. "/",
        ["localIconPath"] = iconDir .. "FBA 2012" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MAME/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MAME/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_fba.png",
        ["icon"] = "icon_fba.png",
    },
    [35] = 
    {
        ["apptype"] = 35,
        ["table"] = "mame_2003_plus_table",
        ["user_db_file"] = "db_mame_2003_plus.lua",
        ["romFolder"] = romUserDir.MAME_2003Plus,
        ["localCoverPath"] = covDir .. "MAME 2003 Plus" .. "/",
        ["localSnapPath"] = snapDir .. "MAME 2003 Plus" .. "/",
        ["localIconPath"] = iconDir .. "MAME 2003 Plus" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MAME/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MAME/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_mame.png",
        ["icon"] = "icon_mame.png",
    },
    [36] = 
    {
        ["apptype"] = 36,
        ["table"] = "mame_2000_table",
        ["user_db_file"] = "db_mame_2000.lua",
        ["romFolder"] = romUserDir.MAME_2000,
        ["localCoverPath"] = covDir .. "MAME 2000" .. "/",
        ["localSnapPath"] = snapDir .. "MAME 2000" .. "/",
        ["localIconPath"] = iconDir .. "MAME 2000" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MAME/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/MAME/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_mame.png",
        ["icon"] = "icon_mame.png",
    },
    [37] = 
    {
        ["apptype"] = 37,
        ["table"] = "neogeo_table",
        ["user_db_file"] = "db_neogeo.lua",
        ["romFolder"] = romUserDir.Neo_Geo,
        ["localCoverPath"] = covDir .. "SNK - Neo Geo - FBA 2012" .. "/",
        ["localSnapPath"] = snapDir .. "SNK - Neo Geo - FBA 2012" .. "/",
        ["localIconPath"] = iconDir .. "SNK - Neo Geo - FBA 2012" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/NEOGEO/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/NEOGEO/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_neogeo.png",
        ["icon"] = "icon_neogeo.png",
    },
    [38] = 
    {
        ["apptype"] = 38,
        ["table"] = "ngpc_table",
        ["user_db_file"] = "db_ngpc.lua",
        ["romFolder"] = romUserDir.Neo_Geo_Pocket_Color,
        ["localCoverPath"] = covDir .. "SNK - Neo Geo Pocket Color" .. "/",
        ["localSnapPath"] = snapDir .. "SNK - Neo Geo Pocket Color" .. "/",
        ["localIconPath"] = iconDir .. "SNK - Neo Geo Pocket Color" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/NEOGEO_PC/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/SNK_-_Neo_Geo_Pocket_Color/f940bd5da36105397897c093dda77ef06d51cbcf/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_ngpc.png",
        ["icon"] = "icon_ngpc.png",
    },
    [39] = 
    {
        ["apptype"] = 39,
        ["table"] = "psm_table",
        ["user_db_file"] = "db_psm.lua",
        -- ["romFolder"] = "",
        ["localCoverPath"] = covDir .. "Sony - PlayStation Mobile" .. "/",
        ["localSnapPath"] = snapDir .. "Sony - PlayStation Mobile" .. "/",
        ["localIconPath"] = iconDir .. "Sony - PlayStation Mobile" .. "/",
        ["onlineCoverPathSystem"] = "",
        ["onlineSnapPathSystem"] = "",
        ["Missing_Cover"] = "missing_cover_psm.png",
        ["icon"] = "missing_cover_psm.png",
    },
    [40] = 
    {
        ["apptype"] = 40,
        ["table"] = "scummvm_table",
        ["user_db_file"] = "db_scummvm.lua",
        -- ["romFolder"] = "",
        ["localCoverPath"] = covDir .. "ScummVM" .. "/",
        ["localSnapPath"] = snapDir .. "ScummVM" .. "/",
        ["localIconPath"] = iconDir .. "ScummVM" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/SCUMMVM/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/SCUMMVM/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_scummvm.png",
        ["icon"] = "icon_scummvm.png",
    },
    [41] = 
    {
        ["apptype"] = 41,
        ["table"] = "pico8_table",
        ["user_db_file"] = "db_pico8.lua",
        ["romFolder"] = romUserDir.Pico8,
        ["localCoverPath"] = covDir .. "Lexaloffle Games - Pico-8" .. "/",
        ["localSnapPath"] = snapDir .. "Lexaloffle Games - Pico-8" .. "/",
        ["localIconPath"] = iconDir .. "Lexaloffle Games - Pico-8" .. "/",
        ["onlineCoverPathSystem"] = "",
        ["onlineSnapPathSystem"] = "",
        ["Missing_Cover"] = "missing_cover_pico8.png",
        ["icon"] = "icon_pico8.png",
    },
    [42] = 
    {
        ["apptype"] = 42,
        ["table"] = "sysapps_table",
        ["user_db_file"] = "db_sysapps.lua",
        -- ["romFolder"] = "",
        ["localCoverPath"] = covDir .. "System apps" .. "/",
        ["localSnapPath"] = snapDir .. "System apps" .. "/",
        ["localIconPath"] = iconDir .. "System apps" .. "/",
        ["onlineCoverPathSystem"] = "",
        ["onlineSnapPathSystem"] = "",
        ["Missing_Cover"] = "icon_psv.png",
        ["icon"] = "icon_psv.png",
    },
    [43] = 
    {
        ["apptype"] = 43,
        ["table"] = "nds_table",
        ["user_db_file"] = "db_nds.lua",
        ["romFolder"] = romUserDir.Nintendo_DS,
        ["localCoverPath"] = covDir .. "Nintendo - Nintendo DS" .. "/",
        ["localSnapPath"] = snapDir .. "Nintendo - Nintendo DS" .. "/",
        ["localIconPath"] = iconDir .. "Nintendo - Nintendo DS" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/NDS/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/NDS/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_nds.png",
        ["icon"] = "icon_nds.png",
    },
    [44] = 
    {
        ["apptype"] = 44,
        ["table"] = "atari_st_table",
        ["user_db_file"] = "db_atari_st.lua",
        ["romFolder"] = romUserDir.Atari_ST,
        ["localCoverPath"] = covDir .. "Atari - ST" .. "/",
        ["localSnapPath"] = snapDir .. "Atari - ST" .. "/",
        ["localIconPath"] = iconDir .. "Atari - ST" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/ATARI_ST/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/Atari_-_ST/b1ca9b99122b10662c0483d83130526d96fcb557/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_atari_st.png",
        ["icon"] = "icon_atari_st.png",
    },
    [45] = 
    {
        ["apptype"] = 45,
        ["table"] = "dos_table",
        ["user_db_file"] = "db_dos.lua",
        ["romFolder"] = romUserDir.DOS,
        ["localCoverPath"] = covDir .. "DOS" .. "/",
        ["localSnapPath"] = snapDir .. "DOS" .. "/",
        ["localIconPath"] = iconDir .. "DOS" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/DOS/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/libretro-thumbnails/DOS/ff04cf498ae5b9ee503747de77ca9c652ad3ad4d/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_dos.png",
        ["icon"] = "icon_dos.png",
    },
    [46] = 
    {
        ["apptype"] = 46,
        ["table"] = "easyrpg_table",
        ["user_db_file"] = "db_easyrpg.lua",
        ["romFolder"] = romUserDir.EasyRPG,
        ["localCoverPath"] = covDir .. "EasyRPG" .. "/",
        ["localSnapPath"] = snapDir .. "EasyRPG" .. "/",
        ["localIconPath"] = iconDir .. "EasyRPG" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/RPG_MAKER/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/RPG_MAKER/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_easyrpg.png",
        ["icon"] = "icon_easyrpg.png",
    },
    [47] = 
    {
        ["apptype"] = 47,
        ["table"] = "n3ds_table",
        ["user_db_file"] = "db_n3ds.lua",
        ["romFolder"] = romUserDir.Nintendo_3DS,
        ["localCoverPath"] = covDir .. "Nintendo - Nintendo 3DS" .. "/",
        ["localSnapPath"] = snapDir .. "Nintendo - Nintendo 3DS" .. "/",
        ["localIconPath"] = iconDir .. "Nintendo - Nintendo 3DS" .. "/",
        ["onlineCoverPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/3DS/Covers/",
        ["onlineSnapPathSystem"] = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/Retro/3DS/Named_Snaps/",
        ["Missing_Cover"] = "missing_cover_3ds.png",
        ["icon"] = "icon_3ds.png",
    },
    [48] = 
    {
        -- ["apptype"] = 48,
        ["table"] = "fav_count",
        -- ["user_db_file"] = "",
        -- ["romFolder"] = "",
        -- ["localCoverPath"] = "",
        -- ["onlineCoverPathSystem"] = "",
        -- ["Missing_Cover"] = "",
    },
    [49] = 
    {
        -- ["apptype"] = 49,
        ["table"] = "recently_played_table",
        -- ["user_db_file"] = "",
        -- ["romFolder"] = "",
        -- ["localCoverPath"] = "",
        -- ["onlineCoverPathSystem"] = "",
        -- ["Missing_Cover"] = "",
    },
    [50] = 
    {
        -- ["apptype"] = 50,
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
                    local trimmed_ext = ext:match("^%s*(.-)%s*$") -- trim whitespace
                    if trimmed_ext:sub(1,1) == "." then
                        ext_lookup[trimmed_ext:lower()] = true
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