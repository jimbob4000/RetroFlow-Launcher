-- RetroFlow Launcher - HexFlow Mod version by jimbob4000: https://github.com/jimbob4000/RetroFlow-Launcher. Based on HexFlow Launcher version 0.5 by VitaHEX: https://www.patreon.com/vitahex

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
            n3ds_table = {},
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
            atari_st_table = {},
            dos_table = {},
            easyrpg_table = {},
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
        ensure_print_table_loaded()
        print_table_collection_files((def_collection_files))
    end

    function update_cached_collection(def_user_db_file, def_table_name)
        ensure_print_table_loaded()
        print_table_collection((def_user_db_file), (def_table_name))
    end

    -- Collections: Create directory
        local collections_dir = "ux0:/data/RetroFlow/COLLECTIONS/"
        System.createDirectory(collections_dir)

    -- List directory and insert into collection_files table
        function create_collections_list()
            collection_files = {}
            collection_dir_files = System.listDirectory(collections_dir) or {}
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

        function update_collections_count()
            collection_count = #collection_files
            collection_syscount = syscount + collection_count
            if collection_count == 0 then
                collection_count_of_start_categories = count_of_start_categories
            else
                collection_count_of_start_categories = collection_count + count_of_start_categories + 1
            end
        end

        function add_new_collection_to_memory(def_collection_filename, def_collection_source)
            local collection_file = {}
            collection_file.filename = def_collection_filename
            collection_file.table_name = def_collection_filename:gsub(".lua", "")
            collection_file.display_name = def_collection_filename:gsub(".lua", ""):gsub("Collection_", ""):gsub("_", " ")
            table.insert(collection_files, collection_file)
            table.sort(collection_files, function(a, b) return (a.filename:lower() < b.filename:lower()) end)
            update_collections_count()

            local new_collection_number = 0
            for i, file in ipairs(collection_files) do
                if file.table_name == collection_file.table_name then
                    new_collection_number = i
                    break
                end
            end

            if new_collection_number > 0 then
                _G[collection_files[new_collection_number].table_name] = {}
                for _, source_file in ipairs(def_collection_source) do
                    local matched_file = nil
                    for _, file in ipairs(files_table) do
                        if file.name == source_file.name and file.app_type == source_file.app_type then
                            matched_file = file
                            break
                        end
                    end
                    if matched_file ~= nil then
                        local collection_entry = {}
                        for entry_key, entry_value in pairs(matched_file) do
                            if entry_key ~= "ricon" then
                                collection_entry[entry_key] = entry_value
                            end
                        end
                        if source_file.custom_sort_order ~= nil then
                            collection_entry.custom_sort_order = source_file.custom_sort_order
                        end
                        table.insert(_G[collection_files[new_collection_number].table_name], collection_entry)
                    elseif xCatLookup(showCat) and xCatLookup(showCat)[p] and xCatLookup(showCat)[p].name == source_file.name then
                        local collection_entry = {}
                        for entry_key, entry_value in pairs(xCatLookup(showCat)[p]) do
                            if entry_key ~= "ricon" then
                                collection_entry[entry_key] = entry_value
                            end
                        end
                        if source_file.custom_sort_order ~= nil then
                            collection_entry.custom_sort_order = source_file.custom_sort_order
                        end
                        table.insert(_G[collection_files[new_collection_number].table_name], collection_entry)
                    end
                end
            end

            return new_collection_number
        end



Network.init()


-- Sound system already initialized early in file
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
Graphics.setImageFilters(imgFavorite_small_on, FILTER_LINEAR, FILTER_LINEAR)
Graphics.setImageFilters(imgFavorite_large_on, FILTER_LINEAR, FILTER_LINEAR)
Graphics.setImageFilters(imgFavorite_large_off, FILTER_LINEAR, FILTER_LINEAR)
Graphics.setImageFilters(imgHidden_small_on, FILTER_LINEAR, FILTER_LINEAR)
Graphics.setImageFilters(imgHidden_large_on, FILTER_LINEAR, FILTER_LINEAR)

cart_icon_off = Graphics.loadImage("app0:/DATA/icon-cart.png")
cart_icon_on = Graphics.loadImage("app0:/DATA/icon-cart-inserted.png")
Graphics.setImageFilters(cart_icon_off, FILTER_LINEAR, FILTER_LINEAR)
Graphics.setImageFilters(cart_icon_on, FILTER_LINEAR, FILTER_LINEAR)

file_browser_icons_loaded = false
file_browser_folder_open = nil
file_browser_folder_closed = nil
file_browser_file = nil
category_visibility_icons_loaded = false
category_visibility_checked = nil
category_visibility_unchecked = nil

function load_file_browser_icons_if_needed()
    if file_browser_icons_loaded == false then
        file_browser_folder_open = Graphics.loadImage("app0:/DATA/file-browser-folder-open.png")
        file_browser_folder_closed = Graphics.loadImage("app0:/DATA/file-browser-folder-closed.png")
        file_browser_file = Graphics.loadImage("app0:/DATA/file-browser-file.png")
        file_browser_icons_loaded = true
    end
end

function load_category_visibility_icons_if_needed()
    if category_visibility_icons_loaded == false then
        category_visibility_checked = Graphics.loadImage("app0:/DATA/square-check.png")
        category_visibility_unchecked = Graphics.loadImage("app0:/DATA/square.png")
        Graphics.setImageFilters(category_visibility_checked, FILTER_LINEAR, FILTER_LINEAR)
        Graphics.setImageFilters(category_visibility_unchecked, FILTER_LINEAR, FILTER_LINEAR)
        category_visibility_icons_loaded = true
    end
end

-- OPTIMIZATION: Lazy load setting icons (only when settings menu is accessed)
-- This saves 0.5-1.0 seconds during startup
local setting_icons_loaded = false
setting_icon_theme = nil
setting_icon_artwork = nil
setting_icon_categories = nil
setting_icon_language = nil
setting_icon_scanning = nil
setting_icon_search = nil
setting_icon_sounds = nil
setting_icon_about = nil
setting_icon_other = nil
setting_icon_heart = nil
setting_icon_filter = nil
setting_icon_random = nil
setting_icon_sort = nil
setting_icon_sort_up = nil
setting_icon_sort_down = nil

-- Function to load setting icons when needed
function load_setting_icons_if_needed()
    if not setting_icons_loaded then
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
        setting_icons_loaded = true
    end
end

-- Start of ROM Browser setup

    grey_dir = Color.new(200, 200, 200)
    white_opaque = Color.new(255, 255, 255, 100)
    transparent = Color.new(255, 255, 255, 0)

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
    collection_edit_table = {}

-- End of Custom Collection Sort Scroll list


-- Start of Visible Categories Scroll list
    visible_category_scrollPosition = 0
    visible_category_maxVisibleItems = 8
    visible_category_selected = 1
    visible_category_options = {}
    visible_categories_dirty = false
    visible_categories_requires_reload = false
    visible_collection_scrollPosition = 0
    visible_collection_maxVisibleItems = 8
    visible_collection_selected = 1
    visible_collection_options = {}
    visible_collections_dirty = false
    FileLoad = {}

-- End of Visible Categories Scroll list


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
    if v.localCoverPath then
        System.createDirectory(v.localCoverPath)
    end
end

-- Create directory: Snap Folders
System.createDirectory(snapDir)
for k, v in pairs(SystemsToScan) do
    if v.localSnapPath then
        System.createDirectory(v.localSnapPath)
    end
end

-- Create directory: Icon Folders
System.createDirectory(iconDir)
for k, v in pairs(SystemsToScan) do
    if v.localIconPath then
        System.createDirectory(v.localIconPath)
    end
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
if not System.doesFileExist(db_Folder .. "/scummvm_2026_03.db") then
    System.copyFile("app0:/addons/scummvm_2026_03.db", db_Folder .. "/scummvm_2026_03.db")
end
if not System.doesFileExist(db_Folder .. "/amiga.db") then
    System.copyFile("app0:/addons/amiga.db", db_Folder .. "/amiga.db")
end


-- Table Cache
local db_Cache_Folder = "ux0:/data/RetroFlow/CACHE/"
System.createDirectory(db_Cache_Folder)

function cache_files_complete()
    local cache_files = System.listDirectory(db_Cache_Folder) or {}
    local cache_lookup = {}

    for k, file in pairs(cache_files) do
        if not file.directory then
            cache_lookup[file.name] = true
        end
    end

    for k, v in pairs(SystemsToScan) do
        if v.user_db_file and not cache_lookup[v.user_db_file] then
            return false
        end
    end
    return true
end

-- Copy default backgrounds to wallpaper folder
if not System.doesFileExist(background_dir .. "Aurora.png") then System.copyFile("app0:/DATA/Aurora.png", background_dir .. "Aurora.png") end
if not System.doesFileExist(background_dir .. "Blur 1.jpg") then System.copyFile("app0:/DATA/Blur 1.jpg", background_dir .. "Blur 1.jpg") end
if not System.doesFileExist(background_dir .. "Blur 2.jpg") then System.copyFile("app0:/DATA/Blur 2.jpg", background_dir .. "Blur 2.jpg") end
if not System.doesFileExist(background_dir .. "Blur 3.jpg") then System.copyFile("app0:/DATA/Blur 3.jpg", background_dir .. "Blur 3.jpg") end
if not System.doesFileExist(background_dir .. "Grey.png") then System.copyFile("app0:/DATA/Grey.png", background_dir .. "Grey.png") end


-- EMULATOR CORE MANAGEMENT

    enableEmu4Vita = true -- Version v0.71 now supports launchers

    CoreDefinitions = {

        -- Retroarch cores

            atari800_libretro = {
                display_name = "atari800",
                emulator = "retroarch",
                core_file = "atari800_libretro",
                supported_systems = { "ATARI_5200" }
            },
            bluemsx_libretro = {
                display_name = "blueMSX",
                emulator = "retroarch",
                core_file = "bluemsx_libretro",
                supported_systems = { "COLECOVISION", "MSX1", "MSX2" }
            },
            dosbox_pure_libretro = {
                display_name = "DOSBox-Pure",
                emulator = "retroarch",
                core_file = "dosbox_pure_libretro",
                supported_systems = { "DOS" }
            },
            fbalpha2012_cps1_libretro = {
                display_name = "FB Alpha 2012 CPS-1",
                emulator = "retroarch",
                core_file = "fbalpha2012_cps1_libretro",
                supported_systems = { "FBA" }
            },
            fbalpha2012_cps2_libretro = {
                display_name = "FB Alpha 2012 CPS-2",
                emulator = "retroarch",
                core_file = "fbalpha2012_cps2_libretro",
                supported_systems = { "FBA" }
            },
            fbalpha2012_libretro = {
                display_name = "FB Alpha 2012",
                emulator = "retroarch",
                core_file = "fbalpha2012_libretro",
                supported_systems = { "FBA" }
            },
            fbalpha2012_neogeo_libretro = {
                display_name = "FB Alpha 2012 Neo Geo",
                emulator = "retroarch",
                core_file = "fbalpha2012_neogeo_libretro",
                supported_systems = { "NEOGEO", "FBA" }
            },
            fbneo_libretro = {
                display_name = "FinalBurn Neo",
                emulator = "retroarch",
                core_file = "fbneo_libretro",
                supported_systems = { "NEOGEO" }
            },
            fceumm_libretro = {
                display_name = "FCEUmm",
                emulator = "retroarch",
                core_file = "fceumm_libretro",
                supported_systems = { "NES" }
            },
            fmsx_libretro = {
                display_name = "fMSX",
                emulator = "retroarch",
                core_file = "fmsx_libretro",
                supported_systems = { "MSX1", "MSX2" }
            },
            frodo_libretro = {
                display_name = "Frodo",
                emulator = "retroarch",
                core_file = "frodo_libretro",
                supported_systems = { "C64" }
            },
            fuse_libretro = {
                display_name = "Fuse",
                emulator = "retroarch",
                core_file = "fuse_libretro",
                supported_systems = { "ZXS" }
            },
            gambatte_libretro = {
                display_name = "Gambatte",
                emulator = "retroarch",
                core_file = "gambatte_libretro",
                supported_systems = { "GB", "GBC" }
            },
            gearboy_libretro = {
                display_name = "Gearboy",
                emulator = "retroarch",
                core_file = "gearboy_libretro",
                supported_systems = { "GB", "GBC" }
            },
            genesis_plus_gx_libretro = {
                display_name = "Genesis Plus GX",
                emulator = "retroarch",
                core_file = "genesis_plus_gx_libretro",
                supported_systems = { "GG", "MD", "s32X", "SEGA_CD", "SMS" }
            },
            gpsp_libretro = {
                display_name = "gpSP",
                emulator = "retroarch",
                core_file = "gpsp_libretro",
                supported_systems = { "GBA" }
            },
            handy_libretro = {
                display_name = "Handy",
                emulator = "retroarch",
                core_file = "handy_libretro",
                supported_systems = { "ATARI_LYNX" }
            },
            hatari_libretro = {
                display_name = "Hatari",
                emulator = "retroarch",
                core_file = "hatari_libretro",
                supported_systems = { "ATARI_ST" }
            },
            mame2000_libretro = {
                display_name = "MAME 2000",
                emulator = "retroarch",
                core_file = "mame2000_libretro",
                supported_systems = { "MAME_2000" }
            },
            mame2003_plus_libretro = {
                display_name = "MAME 2003-Plus",
                emulator = "retroarch",
                core_file = "mame2003_plus_libretro",
                supported_systems = { "MAME_2003_PLUS" }
            },
            mednafen_ngp_libretro = {
                display_name = "Beetle NeoPop",
                emulator = "retroarch",
                core_file = "mednafen_ngp_libretro",
                supported_systems = { "NGPC" }
            },
            mednafen_pce_fast_libretro = {
                display_name = "Beetle PCE FAST",
                emulator = "retroarch",
                core_file = "mednafen_pce_fast_libretro",
                supported_systems = { "TG16", "TGCD", "PCE", "PCECD" }
            },
            mednafen_supergrafx_libretro = {
                display_name = "Beetle SuperGrafx",
                emulator = "retroarch",
                core_file = "mednafen_supergrafx_libretro",
                supported_systems = { "TG16", "TGCD", "PCE", "PCECD" }
            },
            mednafen_wswan_libretro = {
                display_name = "Beetle Cygne",
                emulator = "retroarch",
                core_file = "mednafen_wswan_libretro",
                supported_systems = { "WSWAN_COL", "WSWAN" }
            },
            mgba_libretro = {
                display_name = "mGBA",
                emulator = "retroarch",
                core_file = "mgba_libretro",
                supported_systems = { "GBA", "GB", "GBC" }
            },
            nestopia_libretro = {
                display_name = "Nestopia",
                emulator = "retroarch",
                core_file = "nestopia_libretro",
                supported_systems = { "NES" }
            },
            pcsx_rearmed_libretro = {
                display_name = "PCSX ReARMed",
                emulator = "retroarch",
                core_file = "pcsx_rearmed_libretro",
                supported_systems = { "PS1" }
            },
            picodrive_libretro = {
                display_name = "PicoDrive",
                emulator = "retroarch",
                core_file = "picodrive_libretro",
                supported_systems = { "s32X", "MD", "SEGA_CD" }
            },
            prosystem_libretro = {
                display_name = "ProSystem",
                emulator = "retroarch",
                core_file = "prosystem_libretro",
                supported_systems = { "ATARI_7800" }
            },
            puae_libretro = {
                display_name = "PUAE",
                emulator = "retroarch",
                core_file = "puae_libretro",
                supported_systems = { "AMIGA" }
            },
            quicknes_libretro = {
                display_name = "QuickNES",
                emulator = "retroarch",
                core_file = "quicknes_libretro",
                supported_systems = { "NES" }
            },
            race_libretro = {
                display_name = "RACE",
                emulator = "retroarch",
                core_file = "race_libretro",
                supported_systems = { "NGPC" }
            },
            smsplus_libretro = {
                display_name = "SMS Plus GX",
                emulator = "retroarch",
                core_file = "smsplus_libretro",
                supported_systems = { "GG", "SMS" }
            },
            snes9x2002_libretro = {
                display_name = "Snes9x 2002",
                emulator = "retroarch",
                core_file = "snes9x2002_libretro",
                supported_systems = { "SNES" }
            },
            snes9x2005_libretro = {
                display_name = "Snes9x 2005",
                emulator = "retroarch",
                core_file = "snes9x2005_libretro",
                supported_systems = { "SNES" }
            },
            snes9x2005_plus_libretro = {
                display_name = "Snes9x 2005 Plus",
                emulator = "retroarch",
                core_file = "snes9x2005_plus_libretro",
                supported_systems = { "SNES" }
            },
            snes9x2010_libretro = {
                display_name = "Snes9x 2010",
                emulator = "retroarch",
                core_file = "snes9x2010_libretro",
                supported_systems = { "SNES" }
            },
            stella_libretro = {
                display_name = "Stella",
                emulator = "retroarch",
                core_file = "stella_libretro",
                supported_systems = { "ATARI_2600" }
            },
            stella2014_libretro = {
                display_name = "Stella 2014",
                emulator = "retroarch",
                core_file = "stella2014_libretro",
                supported_systems = { "ATARI_2600" }
            },
            tgbdual_libretro = {
                display_name = "TGB Dual",
                emulator = "retroarch",
                core_file = "tgbdual_libretro",
                supported_systems = { "GB", "GBC" }
            },
            uae4arm_libretro = {
                display_name = "UAE4ARM",
                emulator = "retroarch",
                core_file = "uae4arm_libretro",
                supported_systems = { "AMIGA" }
            },
            vba_next_libretro = {
                display_name = "VBA Next",
                emulator = "retroarch",
                core_file = "vba_next_libretro",
                supported_systems = { "GBA" }
            },
            vecx_libretro = {
                display_name = "vecx",
                emulator = "retroarch",
                core_file = "vecx_libretro",
                supported_systems = { "VECTREX" }
            },
            vice_x64_libretro = {
                display_name = "VICE x64, fast",
                emulator = "retroarch",
                core_file = "vice_x64_libretro",
                supported_systems = { "C64" }
            },

        -- Emu4Vita cores

            atari800 = {
                display_name = "Atari800",
                emulator = "emu4vita",
                core_file = "eboot_atari800",
                supported_systems = { "ATARI_5200" }
            },
            bluemsx = {
                display_name = "blueMSX",
                emulator = "emu4vita",
                core_file = "eboot_bluemsx",
                supported_systems = { "COLECOVISION", "MSX1", "MSX2" }
            },
            -- cap32 = {
            --     display_name = "Caprice32",
            --     emulator = "emu4vita",
            --     core_file = "eboot_cap32",
            --     supported_systems = {}
            -- },
            chimerasnes = {
                display_name = "Chimera SNES",
                emulator = "emu4vita",
                core_file = "eboot_chimerasnes",
                supported_systems = { "SNES" }
            },
            -- crocods = {
            --     display_name = "CrocoDS",
            --     emulator = "emu4vita",
            --     core_file = "eboot_crocods",
            --     supported_systems = {}
            -- },
            dosbox_pure = {
                display_name = "DOS BOX Pure",
                emulator = "emu4vita",
                core_file = "eboot_dosbox_pure",
                supported_systems = { "DOS" }
            },
            fba_lite = {
                display_name = "FBA Lite",
                emulator = "emu4vita",
                core_file = "eboot_fba_lite",
                supported_systems = { "FBA" }
            },
            fbalpha2012 = {
                display_name = "FBA 2012",
                emulator = "emu4vita",
                core_file = "eboot_fbalpha2012",
                supported_systems = { "FBA" }
            },
            fbneo = {
                display_name = "FinalBurn Neo",
                emulator = "emu4vita",
                core_file = "eboot_fbneo",
                supported_systems = { "NEOGEO" }
            },
            fceumm = {
                display_name = "FCEUmm",
                emulator = "emu4vita",
                core_file = "eboot_fceumm",
                supported_systems = { "NES" }
            },
            fmsx = {
                display_name = "Marat Fayzullin's fMSX",
                emulator = "emu4vita",
                core_file = "eboot_fmsx",
                supported_systems = { "MSX1", "MSX2" }
            },
            fuse = {
                display_name = "fuse",
                emulator = "emu4vita",
                core_file = "eboot_fuse",
                supported_systems = { "ZXS" }
            },
            gambatte = {
                display_name = "Gambatte",
                emulator = "emu4vita",
                core_file = "eboot_gambatte",
                supported_systems = { "GB", "GBC" }
            },
            genesis_plus_gx = {
                display_name = "Genesis Plus GX",
                emulator = "emu4vita",
                core_file = "eboot_genesis_plus_gx",
                supported_systems = { "GG", "MD", "s32X", "SEGA_CD", "SMS" }
            },
            genesis_plus_gx_wide = {
                display_name = "Genesis Plus GX Wide",
                emulator = "emu4vita",
                core_file = "eboot_genesis_plus_gx_wide",
                supported_systems = { "GG", "MD", "s32X", "SEGA_CD", "SMS" }
            },
            gpsp = {
                display_name = "gpSP",
                emulator = "emu4vita",
                core_file = "eboot_gpsp",
                supported_systems = { "GBA" }
            },
            handy = {
                display_name = "Handy",
                emulator = "emu4vita",
                core_file = "eboot_handy",
                supported_systems = { "ATARI_LYNX" }
            },
            km_fbneo_xtreme_amped = {
                display_name = "FinalBurn Neo Xtreme",
                emulator = "emu4vita",
                core_file = "eboot_km_fbneo_xtreme_amped",
                supported_systems = { "NEOGEO" }
            },
            km_mame2003_xtreme_amped = {
                display_name = "MAME 2003 Xtreme",
                emulator = "emu4vita",
                core_file = "eboot_km_mame2003_xtreme_amped",
                supported_systems = { "MAME_2003_PLUS" }
            },
            mame2000 = {
                display_name = "MAME 2000",
                emulator = "emu4vita",
                core_file = "eboot_mame2000",
                supported_systems = { "MAME_2000" }
            },
            mame2003 = {
                display_name = "MAME 2003",
                emulator = "emu4vita",
                core_file = "eboot_mame2003",
                supported_systems = { "MAME_2003_PLUS" }
            },
            mame2003_plus = {
                display_name = "MAME 2003 Plus",
                emulator = "emu4vita",
                core_file = "eboot_mame2003_plus",
                supported_systems = { "MAME_2003_PLUS" }
            },
            mednafen_lynx = {
                display_name = "Beetle Lynx",
                emulator = "emu4vita",
                core_file = "eboot_mednafen_lynx",
                supported_systems = { "ATARI_LYNX" }
            },
            mednafen_ngp = {
                display_name = "Mednafen NeoPop",
                emulator = "emu4vita",
                core_file = "eboot_mednafen_ngp",
                supported_systems = { "NGPC" }
            },
            mednafen_pce_fast = {
                display_name = "Mednafen PCE Fast",
                emulator = "emu4vita",
                core_file = "eboot_mednafen_pce_fast",
                supported_systems = { "TG16", "TGCD", "PCE", "PCECD" }
            },
            mednafen_supafaust = {
                display_name = "Mednafen Supafaust",
                emulator = "emu4vita",
                core_file = "eboot_mednafen_supafaust",
                supported_systems = { "SNES" }
            },
            mednafen_supergrafx = {
                display_name = "Mednafen SuperGrafx",
                emulator = "emu4vita",
                core_file = "eboot_mednafen_supergrafx",
                supported_systems = { "TG16", "TGCD", "PCE", "PCECD" }
            },
            mednafen_wswan = {
                display_name = "Mednafen Wswan",
                emulator = "emu4vita",
                core_file = "eboot_mednafen_wswan",
                supported_systems = { "WSWAN", "WSWAN_COL" }
            },
            mgba = {
                display_name = "mGBA",
                emulator = "emu4vita",
                core_file = "eboot_mgba",
                supported_systems = { "GBA", "GB", "GBC" }
            },
            -- nekop2 = {
            --     display_name = "Neko Project II",
            --     emulator = "emu4vita",
            --     core_file = "eboot_nekop2",
            --     supported_systems = { "" }
            -- },
            -- neocd = {
            --     display_name = "neocd",
            --     emulator = "emu4vita",
            --     core_file = "eboot_neocd",
            --     supported_systems = { "" }
            -- },
            nestopia = {
                display_name = "Nestopia",
                emulator = "emu4vita",
                core_file = "eboot_nestopia",
                supported_systems = { "NES" }
            },
            -- np2kai = {
            --     display_name = "Neko Project II kai",
            --     emulator = "emu4vita",
            --     core_file = "eboot_np2kai",
            --     supported_systems = { "" }
            -- },
            pcsx_rearmed = {
                display_name = "PCSX ReARMed",
                emulator = "emu4vita",
                core_file = "eboot_pcsx_rearmed",
                supported_systems = { "PS1" }
            },
            picodrive = {
                display_name = "PicoDrive",
                emulator = "emu4vita",
                core_file = "eboot_picodrive",
                supported_systems = { "s32X", "MD", "SEGA_CD" }
            },
            prosystem = {
                display_name = "ProSystem",
                emulator = "emu4vita",
                core_file = "eboot_prosystem",
                supported_systems = { "ATARI_7800" }
            },
            -- px68k = {
            --     display_name = "Portable (x)keropi PRO-68K",
            --     emulator = "emu4vita",
            --     core_file = "eboot_px68k",
            --     supported_systems = { "" }
            -- },
            snes9x = {
                display_name = "Snes9x",
                emulator = "emu4vita",
                core_file = "eboot_snes9x",
                supported_systems = { "SNES" }
            },
            snes9x2005_plus = {
                display_name = "Snes9x 2005",
                emulator = "emu4vita",
                core_file = "eboot_snes9x2005_plus",
                supported_systems = { "SNES" }
            },
            stella2014 = {
                display_name = "Stella 2014",
                emulator = "emu4vita",
                core_file = "eboot_stella2014",
                supported_systems = { "ATARI_2600" }
            },
            tgbdual = {
                display_name = "TGB Dual",
                emulator = "emu4vita",
                core_file = "eboot_tgbdual",
                supported_systems = { "GB", "GBC" }
            },
            uae4arm = {
                display_name = "uae4arm",
                emulator = "emu4vita",
                core_file = "eboot_uae4arm",
                supported_systems = { "AMIGA" }
            },
            vba_next = {
                display_name = "VBA Next",
                emulator = "emu4vita",
                core_file = "eboot_vba_next",
                supported_systems = { "GBA" }
            },
            vecx = {
                display_name = "vecx",
                emulator = "emu4vita",
                core_file = "eboot_vecx",
                supported_systems = { "VECTREX" }
            },
            vice = {
                display_name = "VICE",
                emulator = "emu4vita",
                core_file = "eboot_vice",
                supported_systems = { "C64" }
            },

    }

    if enableEmu4Vita ~= true then
        for core_id, core_info in pairs(CoreDefinitions) do
            if core_info.emulator == "emu4vita" then
                CoreDefinitions[core_id] = nil
            end
        end
    end

    CoreGroups = {}

    for core_id, core_info in pairs(CoreDefinitions) do
        for _, system_id in pairs(core_info.supported_systems) do
            if not CoreGroups[system_id] then
                CoreGroups[system_id] = {}
            end
            table.insert(CoreGroups[system_id], core_id)
        end
    end

    RecommendedCores = {
        SNES = "snes9x2005_libretro",
        NES = "quicknes_libretro",
        GBA = "gpsp_libretro",
        GBC = "gambatte_libretro",
        GB = "gambatte_libretro",
        SEGA_CD = "genesis_plus_gx_libretro",
        s32X = "picodrive_libretro",
        MD = "genesis_plus_gx_libretro",
        SMS = "smsplus_libretro",
        GG = "smsplus_libretro",
        TG16 = "mednafen_pce_fast_libretro",
        TGCD = "mednafen_pce_fast_libretro",
        PCE = "mednafen_pce_fast_libretro",
        PCECD = "mednafen_pce_fast_libretro",
        AMIGA = "puae_libretro",
        C64 = "vice_x64_libretro",
        WSWAN_COL = "mednafen_wswan_libretro",
        WSWAN = "mednafen_wswan_libretro",
        MSX2 = "fmsx_libretro",
        MSX1 = "fmsx_libretro",
        ZXS = "fuse_libretro",
        ATARI_7800 = "prosystem_libretro",
        ATARI_5200 = "atari800_libretro",
        ATARI_2600 = "stella2014_libretro",
        ATARI_LYNX = "handy_libretro",
        COLECOVISION = "bluemsx_libretro",
        VECTREX = "vecx_libretro",
        FBA = "fbalpha2012_libretro",
        MAME_2003_PLUS = "mame2003_plus_libretro",
        MAME_2000 = "mame2000_libretro",
        NEOGEO = "fbalpha2012_neogeo_libretro",
        NGPC = "mednafen_ngp_libretro",
        PS1 = "pcsx_rearmed_libretro",
        ATARI_ST = "hatari_libretro",
        DOS = "dosbox_pure_libretro",
    }

    RecommendedCoresEmu4 = {
        SNES = "snes9x2005_plus",
        NES = "fceumm",
        GBA = "gpsp",
        GBC = "gambatte",
        GB = "gambatte",
        SEGA_CD = "genesis_plus_gx",
        s32X = "picodrive",
        MD = "genesis_plus_gx",
        SMS = "genesis_plus_gx",
        GG = "genesis_plus_gx",
        TG16 = "mednafen_pce_fast",
        TGCD = "mednafen_pce_fast",
        PCE = "mednafen_pce_fast",
        PCECD = "mednafen_pce_fast",
        AMIGA = "uae4arm",
        C64 = "vice",
        WSWAN_COL = "mednafen_wswan",
        WSWAN = "mednafen_wswan",
        MSX2 = "fmsx",
        MSX1 = "fmsx",
        ZXS = "fuse",
        ATARI_7800 = "prosystem",
        ATARI_5200 = "atari800",
        ATARI_2600 = "stella2014",
        ATARI_LYNX = "handy",
        COLECOVISION = "bluemsx",
        VECTREX = "vecx",
        FBA = "fbalpha2012",
        MAME_2003_PLUS = "mame2003_plus",
        MAME_2000 = "mame2000",
        NEOGEO = "fbneo",
        NGPC = "mednafen_ngp",
        PS1 = "pcsx_rearmed",
        -- ATARI_ST = "hatari_libretro",
        DOS = "dosbox_pure",
    }

    GlobalCoreOverrides = {}
    GameCoreOverrides = {}

    function is_recommended_core(system_id, core_id)
        return core_id == (RecommendedCores and RecommendedCores[system_id])
            or core_id == (RecommendedCoresEmu4 and RecommendedCoresEmu4[system_id])
    end

    function get_core_sort_rank(system_id, core_id)
        local core_info = CoreDefinitions and CoreDefinitions[core_id]
        if core_id == (RecommendedCores and RecommendedCores[system_id]) then
            return 1
        elseif core_info and core_info.emulator == "retroarch" then
            return 2
        elseif core_id == (RecommendedCoresEmu4 and RecommendedCoresEmu4[system_id]) then
            return 3
        elseif core_info and core_info.emulator == "emu4vita" then
            return 4
        end
        return 5
    end

    function GetAvailableCores(system_id)
        local cores = {}
        for _, core_id in ipairs(CoreGroups[system_id] or {}) do
            table.insert(cores, core_id)
        end
        table.sort(cores, function(a, b)
            local rank_a = get_core_sort_rank(system_id, a)
            local rank_b = get_core_sort_rank(system_id, b)
            if rank_a ~= rank_b then
                return rank_a < rank_b
            end
            local name_a = CoreDefinitions[a] and CoreDefinitions[a].display_name or a
            local name_b = CoreDefinitions[b] and CoreDefinitions[b].display_name or b
            return name_a:lower() < name_b:lower()
        end)
        return cores
    end

    function GetCoreSourceLabel(core_info)
        if enableEmu4Vita ~= true or not core_info then
            return ""
        end
        if core_info.emulator == "emu4vita" then
            return (lang_lines and lang_lines.Core_source_emu4vita) or " (Emu4Vita++)"
        elseif core_info.emulator == "retroarch" then
            return (lang_lines and lang_lines.Core_source_retroarch) or " (RetroArch)"
        end
        return ""
    end

    function GetCoreDisplayName(core_id)
        local core_info = CoreDefinitions[core_id]
        if core_info then
            return core_info.display_name .. GetCoreSourceLabel(core_info)
        end
        return "Unknown"
    end

    function GetCurrentSystemCore(system_id)
        return GlobalCoreOverrides[system_id] or RecommendedCores[system_id]
    end

    local global_core_config_file = cur_dir .. "/Emulator cores global.lua"
    local game_core_override_file = cur_dir .. "/Emulator cores override.lua"

    SystemsLookup = {
        { id = "PS1",            label_key = "PlayStation",                  rom_dir_key = "PlayStation",                  app_type = 3 },
        { id = "SNES",           label_key = "Super_Nintendo",               rom_dir_key = "Super_Nintendo",               app_type = 6 },
        { id = "NES",            label_key = "Nintendo_Entertainment_System", rom_dir_key = "Nintendo_Entertainment_System", app_type = 7 },
        { id = "GBA",            label_key = "Game_Boy_Advance",             rom_dir_key = "Game_Boy_Advance",             app_type = 8 },
        { id = "GBC",            label_key = "Game_Boy_Color",               rom_dir_key = "Game_Boy_Color",               app_type = 9 },
        { id = "GB",             label_key = "Game_Boy",                     rom_dir_key = "Game_Boy",                     app_type = 10 },
        { id = "SEGA_CD",        label_key = "Sega_CD",                      rom_dir_key = "Sega_CD",                      app_type = 12 },
        { id = "s32X",           label_key = "Sega_32X",                     rom_dir_key = "Sega_32X",                     app_type = 13 },
        { id = "MD",             label_key = "Sega_Mega_Drive",              rom_dir_key = "Sega_Mega_Drive",              app_type = 14 },
        { id = "SMS",            label_key = "Sega_Master_System",           rom_dir_key = "Sega_Master_System",           app_type = 15 },
        { id = "GG",             label_key = "Sega_Game_Gear",               rom_dir_key = "Sega_Game_Gear",               app_type = 16 },
        { id = "TG16",           label_key = "TurboGrafx_16",                rom_dir_key = "TurboGrafx_16",                app_type = 17 },
        { id = "TGCD",           label_key = "TurboGrafx_CD",                rom_dir_key = "TurboGrafx_CD",                app_type = 18 },
        { id = "PCE",            label_key = "PC_Engine",                    rom_dir_key = "PC_Engine",                    app_type = 19 },
        { id = "PCECD",          label_key = "PC_Engine_CD",                 rom_dir_key = "PC_Engine_CD",                 app_type = 20 },
        { id = "AMIGA",          label_key = "Amiga",                        rom_dir_key = "Amiga",                        app_type = 21 },
        { id = "C64",            label_key = "Commodore_64",                 rom_dir_key = "Commodore_64",                 app_type = 22 },
        { id = "WSWAN_COL",      label_key = "WonderSwan_Color",             rom_dir_key = "WonderSwan_Color",             app_type = 23 },
        { id = "WSWAN",          label_key = "WonderSwan",                   rom_dir_key = "WonderSwan",                   app_type = 24 },
        { id = "MSX2",           label_key = "MSX2",                         rom_dir_key = "MSX2",                         app_type = 25 },
        { id = "MSX1",           label_key = "MSX",                          rom_dir_key = "MSX",                          app_type = 26 },
        { id = "ZXS",            label_key = "ZX_Spectrum",                  rom_dir_key = "ZX_Spectrum",                  app_type = 27 },
        { id = "ATARI_7800",     label_key = "Atari_7800",                   rom_dir_key = "Atari_7800",                   app_type = 28 },
        { id = "ATARI_5200",     label_key = "Atari_5200",                   rom_dir_key = "Atari_5200",                   app_type = 29 },
        { id = "ATARI_2600",     label_key = "Atari_2600",                   rom_dir_key = "Atari_2600",                   app_type = 30 },
        { id = "ATARI_LYNX",     label_key = "Atari_Lynx",                   rom_dir_key = "Atari_Lynx",                   app_type = 31 },
        { id = "COLECOVISION",   label_key = "ColecoVision",                 rom_dir_key = "ColecoVision",                 app_type = 32 },
        { id = "VECTREX",        label_key = "Vectrex",                      rom_dir_key = "Vectrex",                      app_type = 33 },
        { id = "FBA",            label_key = "FBA_2012",                     rom_dir_key = "FBA_2012",                     app_type = 34 },
        { id = "MAME_2003_PLUS", label_key = "MAME_2003Plus",                rom_dir_key = "MAME_2003Plus",                app_type = 35 },
        { id = "MAME_2000",      label_key = "MAME_2000",                    rom_dir_key = "MAME_2000",                    app_type = 36 },
        { id = "NEOGEO",         label_key = "Neo_Geo",                      rom_dir_key = "Neo_Geo",                      app_type = 37 },
        { id = "NGPC",           label_key = "Neo_Geo_Pocket_Color",         rom_dir_key = "Neo_Geo_Pocket_Color",         app_type = 38 },
        { id = "ATARI_ST",       label_key = "Atari_ST",                     rom_dir_key = "Atari_ST",                     app_type = 44 },
        { id = "DOS",            label_key = "MS_DOS",                       rom_dir_key = "DOS",                          app_type = 45 },
    }

    SystemFallbackLabels = {
        PlayStation = "PlayStation",
        Super_Nintendo = "Super Nintendo",
        Nintendo_Entertainment_System = "Nintendo Entertainment System",
        Game_Boy_Advance = "Game Boy Advance",
        Game_Boy_Color = "Game Boy Color",
        Game_Boy = "Game Boy",
        Sega_CD = "Sega CD",
        Sega_32X = "Sega 32X",
        Sega_Mega_Drive = "Sega Mega Drive",
        Sega_Master_System = "Sega Master System",
        Sega_Game_Gear = "Sega Game Gear",
        TurboGrafx_16 = "TurboGrafx-16",
        TurboGrafx_CD = "TurboGrafx-CD",
        PC_Engine = "PC Engine",
        PC_Engine_CD = "PC Engine CD",
        Amiga = "Amiga",
        Commodore_64 = "Commodore 64",
        WonderSwan_Color = "WonderSwan Color",
        WonderSwan = "WonderSwan",
        MSX2 = "MSX2",
        MSX = "MSX",
        ZX_Spectrum = "ZX Spectrum",
        Atari_7800 = "Atari 7800",
        Atari_5200 = "Atari 5200",
        Atari_2600 = "Atari 2600",
        Atari_Lynx = "Atari Lynx",
        ColecoVision = "ColecoVision",
        Vectrex = "Vectrex",
        FBA_2012 = "FBA 2012",
        MAME_2003Plus = "MAME 2003 Plus",
        MAME_2000 = "MAME 2000",
        Neo_Geo = "Neo Geo",
        Neo_Geo_Pocket_Color = "Neo Geo Pocket Color",
        Atari_ST = "Atari ST",
        MS_DOS = "MS-DOS",
    }

    AppTypeToSystem = {}

    for _, system in pairs(SystemsLookup) do
        AppTypeToSystem[system.app_type] = system.id
    end

    function core_file_to_path(core_file)
        if not core_file then
            return nil
        end
        if string.find(core_file, "%.self$") then
            return "app0:/" .. core_file
        end
        return "app0:/" .. core_file .. ".self"
    end

    function core_id_to_path(core_id)
        local core_definition = CoreDefinitions and CoreDefinitions[core_id]
        if core_definition then
            return core_file_to_path(core_definition.core_file)
        end
        return nil
    end

    function core_path_to_id(core_path)
        if not core_path or not CoreDefinitions then
            return nil
        end
        for core_id, core_definition in pairs(CoreDefinitions) do
            if core_file_to_path(core_definition.core_file) == core_path then
                return core_id
            end
        end
        return nil
    end

    function save_key_value_table(filename, data)
        local file = io.open(filename, "w+")
        if not file then
            return
        end

        local function lua_escape(value)
            return tostring(value):gsub("\\", "\\\\"):gsub('"', '\\"')
        end

        file:write("return\n{\n")
        for key, value in pairs(data) do
            file:write('\t["' .. lua_escape(key) .. '"] = "' .. lua_escape(value) .. '",\n')
        end
        file:write("}")
        file:close()
    end

    function load_key_value_table(filename)
        if System.doesFileExist(filename) then
            local chunk = loadfile(filename)
            if chunk then
                local success, result = pcall(chunk)
                if success and type(result) == "table" then
                    return result
                end
            end
        end
        return {}
    end

    function save_global_core_overrides()
        save_key_value_table(global_core_config_file, GlobalCoreOverrides)
    end

    function save_game_core_overrides()
        save_key_value_table(game_core_override_file, GameCoreOverrides)
    end

    function reset_global_core_overrides()
        GlobalCoreOverrides = {}
        for system_id, core_id in pairs(RecommendedCores or {}) do
            GlobalCoreOverrides[system_id] = core_id
        end
        save_global_core_overrides()
    end

    function reset_game_core_overrides()
        GameCoreOverrides = {}
        save_game_core_overrides()

        if launch_overrides_table then
            for i = #launch_overrides_table, 1, -1 do
                if launch_overrides_table[i].driver == nil and launch_overrides_table[i].core ~= nil then
                    table.remove(launch_overrides_table, i)
                end
            end
            if update_cached_table_launch_overrides then
                update_cached_table_launch_overrides()
            end
        end
    end

    function load_core_settings()
        if not GlobalCoreOverrides then
            GlobalCoreOverrides = {}
        end
        if not GameCoreOverrides then
            GameCoreOverrides = {}
        end

        if System.doesFileExist(global_core_config_file) then
            GlobalCoreOverrides = load_key_value_table(global_core_config_file)
        else
            reset_global_core_overrides()
        end

        for system_id, core_id in pairs(RecommendedCores or {}) do
            if GlobalCoreOverrides[system_id] == nil or CoreDefinitions == nil or CoreDefinitions[GlobalCoreOverrides[system_id]] == nil then
                GlobalCoreOverrides[system_id] = core_id
            end
        end
        save_global_core_overrides()

        if System.doesFileExist(game_core_override_file) then
            GameCoreOverrides = load_key_value_table(game_core_override_file)
        else
            reset_game_core_overrides()
        end
    end

    function get_system_id_for_app_type(app_type)
        return AppTypeToSystem[app_type]
    end

    function get_game_core_override_key()
        return game_path or rom_location or app_titleid
    end

    function get_core_for_launch(app_type, rom_path, fallback_core_path)
        local core_id = get_core_id_for_launch(app_type, rom_path, fallback_core_path)
        return core_id_to_path(core_id) or fallback_core_path
    end

    function get_core_id_for_launch(app_type, rom_path, fallback_core_path)
        local system_id = get_system_id_for_app_type(app_type)
        local game_override = nil
        if rom_path and GameCoreOverrides then
            game_override = GameCoreOverrides[rom_path]
        end

        if game_override == nil and rom_path and launch_overrides_table then
            for _, data in pairs(launch_overrides_table) do
                if data.game_path == rom_path and data.core_path ~= nil then
                    local legacy_core_id = core_path_to_id(data.core_path)
                    if legacy_core_id then
                        return legacy_core_id
                    end
                end
            end
        end

        local core_id = game_override or (system_id and GetCurrentSystemCore(system_id))
        if core_id and CoreDefinitions and CoreDefinitions[core_id] then
            return core_id
        end
        return core_path_to_id(fallback_core_path)
    end

    function get_core_file_for_launch(app_type, rom_path)
        local core_id = get_core_id_for_launch(app_type, rom_path)
        local core_definition = core_id and CoreDefinitions and CoreDefinitions[core_id]
        return core_definition and core_definition.core_file
    end

    function get_core_display_string(core_id, language_id)
        local display_name = GetCoreDisplayName(core_id)
        if is_recommended_core(emulator_core_settings_system_id, core_id) then
            local recommended_marker = (language_id == 10 or language_id == 18) and "* " or "★ "
            return recommended_marker .. display_name
        end
        return display_name
    end

    function get_core_option_display_name(core_option)
        if core_option and core_option.core_id then
            local core_name = GetCoreDisplayName(core_option.core_id)
            if core_option.is_recommended == true then
                return "★ " .. core_name
            end
            return core_name
        end
        if core_option and core_option.is_recommended == true then
            local recommended_marker = "★ "
            return recommended_marker .. core_option.core_name
        end
        return core_option and core_option.core_name or ""
    end

    function get_system_label(system)
        if not system or not system.label_key then
            return ""
        end

        if lang_lines and lang_lines[system.label_key] then
            return lang_lines[system.label_key]
        elseif SystemFallbackLabels and SystemFallbackLabels[system.label_key] then
            return SystemFallbackLabels[system.label_key]
        end
        return system.label_key:gsub("_", " ")
    end

    function build_emulator_core_platforms()
        emulator_core_platforms = {}
        for _, system in pairs(SystemsLookup) do
            if GetAvailableCores(system.id) and #GetAvailableCores(system.id) > 0 then
                table.insert(emulator_core_platforms, system)
            end
        end
        table.sort(emulator_core_platforms, function(a, b) return get_system_label(a):lower() < get_system_label(b):lower() end)
    end

    function get_core_index_for_system(system_id)
        local available_cores = GetAvailableCores(system_id)
        local selected_core_id = GetCurrentSystemCore(system_id)
        for i, core_id in ipairs(available_cores) do
            if core_id == selected_core_id then
                return i
            end
        end
        return 1
    end

    function set_global_core_for_system(system_id, core_id)
        if system_id and core_id then
            GlobalCoreOverrides[system_id] = core_id
            save_global_core_overrides()
        end
    end

    function rebuild_legacy_core_tables()
        core = {}
        core_overrides = {}

        for _, system in pairs(SystemsLookup) do
            local current_core_id = GetCurrentSystemCore(system.id)
            core[system.id] = core_id_to_path(current_core_id)

            local available_cores = GetAvailableCores(system.id)
            if #available_cores > 1 then
                core_overrides[system.app_type] = {}
                core_overrides[system.app_type][0] = {
                    core_path = core_id_to_path(current_core_id),
                    core_name = GetCoreDisplayName(current_core_id),
                    core_id = current_core_id,
                    is_recommended = is_recommended_core(system.id, current_core_id)
                }

                local override_index = 1
                for _, core_id in ipairs(available_cores) do
                    if core_id ~= current_core_id then
                        core_overrides[system.app_type][override_index] = {
                            core_path = core_id_to_path(core_id),
                            core_name = GetCoreDisplayName(core_id),
                            core_id = core_id,
                            is_recommended = is_recommended_core(system.id, core_id)
                        }
                        override_index = override_index + 1
                    end
                end
            end
        end
    end

    load_core_settings()
    rebuild_legacy_core_tables()

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

imgBox = nil
imgBoxPSP = nil
imgBoxPSX = nil
cover_models_base_loaded = false
cover_models_psp_loaded = false
cover_models_psx_loaded = false
cover_models_n64_loaded = false
cover_models_nes_loaded = false
cover_models_gb_loaded = false
cover_models_nds_loaded = false
cover_models_md_loaded = false
cover_models_tape_loaded = false
cover_models_atari_loaded = false
cover_models_lynx_loaded = false
cover_models_hbr_loaded = false
cover_models_snes_japan_loaded = false
cover_models_middle_loaded = false

function load_base_cover_models_if_needed()
    if cover_models_base_loaded == false then
        imgBox = Graphics.loadImage("app0:/DATA/vita_cover.png")
        modBox = Render.loadObject("app0:/DATA/box.obj", imgBox)
        modCover = Render.loadObject("app0:/DATA/cover.obj", imgCoverTmp)
        modBoxNoref = Render.loadObject("app0:/DATA/box_noreflx.obj", imgBox)
        modCoverNoref = Render.loadObject("app0:/DATA/cover_noreflx.obj", imgCoverTmp)
        cover_models_base_loaded = true
    end
end

function load_psp_cover_models_if_needed()
    if cover_models_psp_loaded == false then
        imgBoxPSP = Graphics.loadImage("app0:/DATA/psp_cover.png")
        modBoxPSP = Render.loadObject("app0:/DATA/boxpsp.obj", imgBoxPSP)
        modCoverPSP = Render.loadObject("app0:/DATA/coverpsp.obj", imgCoverTmp)
        modBoxPSPNoref = Render.loadObject("app0:/DATA/boxpsp_noreflx.obj", imgBoxPSP)
        modCoverPSPNoref = Render.loadObject("app0:/DATA/coverpsp_noreflx.obj", imgCoverTmp)
        cover_models_psp_loaded = true
    end
end

function load_psx_cover_models_if_needed()
    if cover_models_psx_loaded == false then
        imgBoxPSX = Graphics.loadImage("app0:/DATA/psx_cover.png")
        modBoxPSX = Render.loadObject("app0:/DATA/boxpsx.obj", imgBoxPSX)
        modCoverPSX = Render.loadObject("app0:/DATA/coverpsx.obj", imgCoverTmp)
        modBoxPSXNoref = Render.loadObject("app0:/DATA/boxpsx_noreflx.obj", imgBoxPSX)
        modCoverPSXNoref = Render.loadObject("app0:/DATA/coverpsx_noreflx.obj", imgCoverTmp)
        cover_models_psx_loaded = true
    end
end

function load_n64_cover_models_if_needed()
    if cover_models_n64_loaded == false then
        modCoverN64 = Render.loadObject("app0:/DATA/covern64.obj", imgCoverTmp)
        modCoverN64Noref = Render.loadObject("app0:/DATA/covern64_noreflx.obj", imgCoverTmp)
        cover_models_n64_loaded = true
    end
end

function load_nes_cover_models_if_needed()
    if cover_models_nes_loaded == false then
        modCoverNES = Render.loadObject("app0:/DATA/covernes.obj", imgCoverTmp)
        modCoverNESNoref = Render.loadObject("app0:/DATA/covernes_noreflx.obj", imgCoverTmp)
        cover_models_nes_loaded = true
    end
end

function load_gb_cover_models_if_needed()
    if cover_models_gb_loaded == false then
        modCoverGB = Render.loadObject("app0:/DATA/covergb.obj", imgCoverTmp)
        modCoverGBNoref = Render.loadObject("app0:/DATA/covergb_noreflx.obj", imgCoverTmp)
        cover_models_gb_loaded = true
    end
end

function load_nds_cover_models_if_needed()
    if cover_models_nds_loaded == false then
        modCoverNDS = Render.loadObject("app0:/DATA/covernds.obj", imgCoverTmp)
        modCoverNDSNoref = Render.loadObject("app0:/DATA/covernds_noreflx.obj", imgCoverTmp)
        cover_models_nds_loaded = true
    end
end

function load_md_cover_models_if_needed()
    if cover_models_md_loaded == false then
        modCoverMD = Render.loadObject("app0:/DATA/covermd.obj", imgCoverTmp)
        modCoverMDNoref = Render.loadObject("app0:/DATA/covermd_noreflx.obj", imgCoverTmp)
        cover_models_md_loaded = true
    end
end

function load_tape_cover_models_if_needed()
    if cover_models_tape_loaded == false then
        modCoverTAPE = Render.loadObject("app0:/DATA/covertape.obj", imgCoverTmp)
        modCoverTAPENoref = Render.loadObject("app0:/DATA/covertape_noreflx.obj", imgCoverTmp)
        cover_models_tape_loaded = true
    end
end

function load_atari_cover_models_if_needed()
    if cover_models_atari_loaded == false then
        modCoverATARI = Render.loadObject("app0:/DATA/coveratari.obj", imgCoverTmp)
        modCoverATARINoref = Render.loadObject("app0:/DATA/coveratari_noreflx.obj", imgCoverTmp)
        cover_models_atari_loaded = true
    end
end

function load_lynx_cover_models_if_needed()
    if cover_models_lynx_loaded == false then
        modCoverLYNX = Render.loadObject("app0:/DATA/coverlynx.obj", imgCoverTmp)
        modCoverLYNXNoref = Render.loadObject("app0:/DATA/coverlynx_noreflx.obj", imgCoverTmp)
        cover_models_lynx_loaded = true
    end
end

function load_hbr_cover_models_if_needed()
    if cover_models_hbr_loaded == false then
        modCoverHbr = Render.loadObject("app0:/DATA/cover_square.obj", imgCoverTmp)
        modCoverHbrNoref = Render.loadObject("app0:/DATA/cover_square_noreflx.obj", imgCoverTmp)
        cover_models_hbr_loaded = true
    end
end

function load_snes_japan_cover_models_if_needed()
    if cover_models_snes_japan_loaded == false then
        modCoverSNESJapan = Render.loadObject("app0:/DATA/covernsnesjapan.obj", imgCoverTmp)
        modCoverSNESJapanNoref = Render.loadObject("app0:/DATA/covernsnesjapan_noreflx.obj", imgCoverTmp)
        cover_models_snes_japan_loaded = true
    end
end

function load_middle_cover_models_if_needed()
    if cover_models_middle_loaded == false then
        modCoverMiddle = Render.loadObject("app0:/DATA/covermiddle.obj", imgCoverTmp)
        modCoverMiddleNoref = Render.loadObject("app0:/DATA/covermiddle_noreflix.obj", imgCoverTmp)
        cover_models_middle_loaded = true
    end
end

function load_variable_cover_models_if_needed()
    load_snes_japan_cover_models_if_needed()
    load_md_cover_models_if_needed()
    load_nes_cover_models_if_needed()
    load_atari_cover_models_if_needed()
    load_lynx_cover_models_if_needed()
    load_middle_cover_models_if_needed()
    load_gb_cover_models_if_needed()
    load_nds_cover_models_if_needed()
    load_n64_cover_models_if_needed()
end

function load_cover_models_for_app_type(def_apptype)
    if def_apptype == 1 then
        load_base_cover_models_if_needed()
    elseif def_apptype == 2 then
        load_psp_cover_models_if_needed()
    elseif def_apptype == 3 then
        load_psx_cover_models_if_needed()
    elseif def_apptype == 11 then
        load_gb_cover_models_if_needed()
    elseif def_apptype == 5 or def_apptype == 6 or def_apptype == 7 or def_apptype == 8 or def_apptype == 9 or def_apptype == 10 or def_apptype == 12 or def_apptype == 17 or def_apptype == 18 or def_apptype == 19 or def_apptype == 20 or def_apptype == 21 or def_apptype == 34 or def_apptype == 35 or def_apptype == 36 or def_apptype == 38 or def_apptype == 43 or def_apptype == 44 or def_apptype == 45 or def_apptype == 46 or def_apptype == 47 then
        load_variable_cover_models_if_needed()
    elseif def_apptype == 13 or def_apptype == 14 or def_apptype == 15 or def_apptype == 16 then
        load_md_cover_models_if_needed()
    elseif def_apptype == 22 or def_apptype == 25 or def_apptype == 26 or def_apptype == 27 then
        load_md_cover_models_if_needed()
        load_tape_cover_models_if_needed()
    elseif def_apptype == 23 or def_apptype == 24 or def_apptype == 37 or def_apptype == 40 then
        load_nes_cover_models_if_needed()
    elseif def_apptype == 28 or def_apptype == 29 or def_apptype == 30 or def_apptype == 32 or def_apptype == 33 then
        load_atari_cover_models_if_needed()
    elseif def_apptype == 31 or def_apptype == 41 then
        load_lynx_cover_models_if_needed()
    elseif def_apptype == 39 or def_apptype == 42 then
        load_hbr_cover_models_if_needed()
    else
        load_hbr_cover_models_if_needed()
    end
end

function load_all_cover_models_if_needed()
    load_base_cover_models_if_needed()
    load_psp_cover_models_if_needed()
    load_psx_cover_models_if_needed()
    load_variable_cover_models_if_needed()
    load_tape_cover_models_if_needed()
    load_hbr_cover_models_if_needed()
end

local modBackground = Render.loadObject("app0:/DATA/planebg.obj", imgBack)
local modDefaultBackground = Render.loadObject("app0:/DATA/planebg.obj", imgBack)
local modFloor = Render.loadObject("app0:/DATA/planefloor.obj", imgFloor)


local img_path = ""

-- Load fonts

    fontname = "font-SawarabiGothic-Regular.woff"
    font_buffer = Extended.loadFontIntoMemory("app0:/DATA/" .. fontname)

    fnt20 = Extended.loadFontFromMemory(font_buffer)
    fnt22 = Extended.loadFontFromMemory(font_buffer)
    fnt25 = Extended.loadFontFromMemory(font_buffer)

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

-- Import previously scanned sfo info
function import_cached_titles()

    -- Import cached sfos vita
    if System.doesFileExist (user_DB_Folder .. "sfo_scan_vita.lua") then
        sfo_scan_vita_db = safe_dofile(user_DB_Folder .. "sfo_scan_vita.lua")
    else
        sfo_scan_vita_db = {}
    end

    -- Import cached sfos vita psp and psx titles
    if System.doesFileExist (user_DB_Folder .. "sfo_scan_psp_psx.lua") then
        sfo_scan_adrenaline_db_cached = safe_dofile(user_DB_Folder .. "sfo_scan_psp_psx.lua")
    else
        sfo_scan_adrenaline_db_cached = {}
    end
end


function count_cache_and_reload()
    if cache_files_complete() == false then
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
    ensure_print_table_loaded()
    delete_tables()
end

-- Used for crc scan, can keep title files
function delete_cache_keep_titles()
    ensure_print_table_loaded()
    delete_tables()
end



-- PRINT TABLE FUNCTIONS
function cache_all_tables()
    ensure_print_table_loaded()
    print_tables()
end
function update_cached_table(def_user_db_file, def_table_name)
    ensure_print_table_loaded()
    print_table_system((def_user_db_file), (def_table_name))
end
function update_cached_table_recently_played()
    sync_recently_played_full_from_visible()
    ensure_print_table_loaded()
    print_table_recently_played()
end
function update_cached_table_recently_played_pre_launch()
    ensure_print_table_loaded()
    print_table_recently_played_pre_launch()
end
function update_cached_table_renamed_games()
    ensure_print_table_loaded()
    print_table_renamed_games()
end
function update_cached_table_hidden_games()
    ensure_print_table_loaded()
    print_table_hidden_games()
end
function update_cached_table_launch_overrides()
    ensure_print_table_loaded()
    print_table_launch_overrides()
end
function print_table_missing_covers()
    ensure_print_table_loaded()
    print_missing_covers()
end
function print_table_missing_snaps()
    ensure_print_table_loaded()
    print_missing_snaps()
end

function print_sfo_cache_adrenaline()
    -- Related to startup scan setting - save scanned titles tables to lua file so can be imported when startup scan is off 
    function write_ini(pathini, tbl)
        file = io.open(pathini, "w+")
        file:write("return" .. "\n" .. "{" .. "\n")
        for k, v in pairs((tbl)) do
            file:write('["' .. v.sfo_cache_key .. '"] = {title = "' .. (v.title or "UNK") .. '", titleid = "' .. (v.titleid or "UNK") .. '", category = "' .. (v.category or "UNK") .. '", region = "' .. (v.version or "UNK") .. '", path = "' .. (v.path or "UNK") .. '"},' .. "\n")
        end
        file:write('}')
        file:close()
    end

    write_ini(user_DB_Folder .. "sfo_scan_psp_psx.lua", new_sfo_cache_adrenaline)
end

function print_sfo_cache_vita()
    function write_ini(pathini, tbl)
        file = io.open(pathini, "w+")
        file:write("return" .. "\n" .. "{" .. "\n")
        for k, v in pairs((tbl)) do
            file:write('["' .. v.name .. '"] = {title = "' .. v.title .. '", titleid = "' .. v.titleid .. '", version = "' .. v.version .. '"},' .. "\n")
        end
        file:write('}')
        file:close()
    end

    write_ini(user_DB_Folder .. "sfo_scan_vita.lua", new_sfo_cache_table_vita)
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

-- Cartridge runtime polling state
local last_inserted_titleid = nil
local cartridge_state_initialized = false
local cartridge_poll_frame = 0
local cartridge_games = {}

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
local restart_after_frame = false

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
loading_bar_bg = Color.new(255,255,255,50)
transparent = Color.new(255, 255, 255, 0)
timercolor = transparent
darkgrey = Color.new(61, 68, 80)
 
img_loader_green = Color.new(0, 255, 0)
img_loader_blackalpha = Color.new(0, 0, 0, 150)

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
local fav_count_dirty = true

-- Settings
START_CATEGORY_LAST_PLAYED = 49
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
setScanCartridges = 0 -- 0 Off, 1 On
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
showMissingCovers = 1 -- On
local smoothScrolling = 1 -- On

set2DViews = 1 -- On
setChangeViews = 1 -- On

setCRCScan = 1 -- On
setPSPExtractBG = 0 -- 0 Off

setShowCores = 0 -- 0 Off

download_artwork_type = 0 -- Covers
showSysApps = 1 -- On

crc_db_tables = {}
crc_results_table = {}
user_crc_table = {}

function SaveSettings()

    local file_config = assert(io.open(cur_dir .. "/config.dat", "w"), "Failed to open config.dat")

    if file_config ~= nil then
        settings = {} 

        if startCategory >= 51 then
            Collection_CatNum = startCategory - 50
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
        "\nExtract_PSP_backgrounds=" .. setPSPExtractBG .. " " .. 
        "\nShow_cores=" .. setShowCores .. " " .. 
        "\nScan_cartridges" .. setScanCartridges .. " " .. 
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

    -- Error handling: validate startCategory against ShowCat count
    -- If getCategory is higher than available categories, default to 0
    if startCategory >= 51 then
        -- For collection categories, validate the collection exists
        local Collection_CatNum = startCategory - 50
        if collection_files == nil or collection_files[Collection_CatNum] == nil then
            startCategory = 0
        end
    elseif startCategory ~= START_CATEGORY_LAST_PLAYED and startCategory > collection_count_of_start_categories then
        -- If startCategory exceeds available categories, default to 0
        startCategory = 0
    end

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
    local getPSPExtractBG = settingValue[28]; if getPSPExtractBG ~= nil then setPSPExtractBG = getPSPExtractBG end
    local getShowCores = settingValue[29]; if getShowCores ~= nil then setShowCores = getShowCores end
    local getScanCartridges = settingValue[30]; if getScanCartridges ~= nil then setScanCartridges = getScanCartridges end
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

local hidden_categories_file = cur_dir .. "/hidden_categories.lua"
local hidden_collections_file = cur_dir .. "/hidden_collections.lua"
HiddenCategories = {}
HiddenCollections = {}

CategoryVisibilityDefinitions = {
    { showcat = 0, key = "All", label_key = "All" },
    { showcat = 1, key = "PS_Vita", label_key = "PS_Vita", app_type = 1 },
    { showcat = 2, key = "Homebrews", label_key = "Homebrews", app_type = 0 },
    { showcat = 3, key = "PSP", label_key = "PSP", app_type = 2 },
    { showcat = 4, key = "PlayStation", label_key = "PlayStation", app_type = 3 },
    { showcat = 5, key = "Playstation_Mobile", label_key = "Playstation_Mobile", app_type = 39 },
    { showcat = 6, key = "Nintendo_64", label_key = "Nintendo_64", app_type = 5 },
    { showcat = 7, key = "Super_Nintendo", label_key = "Super_Nintendo", app_type = 6 },
    { showcat = 8, key = "Nintendo_Entertainment_System", label_key = "Nintendo_Entertainment_System", app_type = 7 },
    { showcat = 9, key = "Nintendo_3DS", label_key = "Nintendo_3DS", app_type = 47 },
    { showcat = 10, key = "Nintendo_DS", label_key = "Nintendo_DS", app_type = 43 },
    { showcat = 11, key = "Game_Boy_Advance", label_key = "Game_Boy_Advance", app_type = 8 },
    { showcat = 12, key = "Game_Boy_Color", label_key = "Game_Boy_Color", app_type = 9 },
    { showcat = 13, key = "Game_Boy", label_key = "Game_Boy", app_type = 10 },
    { showcat = 14, key = "Sega_Dreamcast", label_key = "Sega_Dreamcast", app_type = 11 },
    { showcat = 15, key = "Sega_CD", label_key = "Sega_CD", app_type = 12 },
    { showcat = 16, key = "Sega_32X", label_key = "Sega_32X", app_type = 13 },
    { showcat = 17, key = "Sega_Mega_Drive", label_key = "Sega_Mega_Drive", app_type = 14 },
    { showcat = 18, key = "Sega_Master_System", label_key = "Sega_Master_System", app_type = 15 },
    { showcat = 19, key = "Sega_Game_Gear", label_key = "Sega_Game_Gear", app_type = 16 },
    { showcat = 20, key = "TurboGrafx_16", label_key = "TurboGrafx_16", app_type = 17 },
    { showcat = 21, key = "TurboGrafx_CD", label_key = "TurboGrafx_CD", app_type = 18 },
    { showcat = 22, key = "PC_Engine", label_key = "PC_Engine", app_type = 19 },
    { showcat = 23, key = "PC_Engine_CD", label_key = "PC_Engine_CD", app_type = 20 },
    { showcat = 24, key = "Amiga", label_key = "Amiga", app_type = 21 },
    { showcat = 25, key = "ScummVM", label_key = "ScummVM", app_type = 40 },
    { showcat = 26, key = "EasyRPG", label_key = "EasyRPG", app_type = 46 },
    { showcat = 27, key = "MS_DOS", label_key = "MS_DOS", app_type = 45 },
    { showcat = 28, key = "Commodore_64", label_key = "Commodore_64", app_type = 22 },
    { showcat = 29, key = "WonderSwan_Color", label_key = "WonderSwan_Color", app_type = 23 },
    { showcat = 30, key = "WonderSwan", label_key = "WonderSwan", app_type = 24 },
    { showcat = 31, key = "PICO8", label_key = "PICO8", app_type = 41 },
    { showcat = 32, key = "MSX2", label_key = "MSX2", app_type = 25 },
    { showcat = 33, key = "MSX", label_key = "MSX", app_type = 26 },
    { showcat = 34, key = "ZX_Spectrum", label_key = "ZX_Spectrum", app_type = 27 },
    { showcat = 35, key = "Atari_ST", label_key = "Atari_ST", app_type = 44 },
    { showcat = 36, key = "Atari_7800", label_key = "Atari_7800", app_type = 28 },
    { showcat = 37, key = "Atari_5200", label_key = "Atari_5200", app_type = 29 },
    { showcat = 38, key = "Atari_2600", label_key = "Atari_2600", app_type = 30 },
    { showcat = 39, key = "Atari_Lynx", label_key = "Atari_Lynx", app_type = 31 },
    { showcat = 40, key = "ColecoVision", label_key = "ColecoVision", app_type = 32 },
    { showcat = 41, key = "Vectrex", label_key = "Vectrex", app_type = 33 },
    { showcat = 42, key = "FBA_2012", label_key = "FBA_2012", app_type = 34 },
    { showcat = 43, key = "MAME_2003Plus", label_key = "MAME_2003Plus", app_type = 35 },
    { showcat = 44, key = "MAME_2000", label_key = "MAME_2000", app_type = 36 },
    { showcat = 45, key = "Neo_Geo", label_key = "Neo_Geo", app_type = 37 },
    { showcat = 46, key = "Neo_Geo_Pocket_Color", label_key = "Neo_Geo_Pocket_Color", app_type = 38 },
    { showcat = 47, key = "System_Apps", label_key = "System_Apps", app_type = 42 },
    { showcat = 48, key = "Favorites", label_key = "Favorites" },
    { showcat = 49, key = "Recently_Played", label_key = "Recently_Played" },
}

CategoryVisibilityByShowCat = {}
AppTypeToShowCat = {}

for _, category in pairs(CategoryVisibilityDefinitions) do
    CategoryVisibilityByShowCat[category.showcat] = category
    if category.app_type ~= nil then
        AppTypeToShowCat[category.app_type] = category.showcat
    end
end

function load_hidden_categories()
    HiddenCategories = {}

    if System.doesFileExist(hidden_categories_file) then
        local success, result = pcall(dofile, hidden_categories_file)
        if success and type(result) == "table" then
            HiddenCategories = result
        end
    end
end

function save_hidden_categories()
    local file = io.open(hidden_categories_file, "w+")
    if not file then
        return
    end

    local function lua_escape(value)
        return tostring(value):gsub("\\", "\\\\"):gsub('"', '\\"')
    end

    file:write("return\n{\n")
    for key, hidden in pairs(HiddenCategories) do
        if hidden == true then
            file:write('\t["' .. lua_escape(key) .. '"] = true,\n')
        end
    end
    file:write("}")
    file:close()
end

function load_hidden_collections()
    HiddenCollections = {}

    if System.doesFileExist(hidden_collections_file) then
        local success, result = pcall(dofile, hidden_collections_file)
        if success and type(result) == "table" then
            HiddenCollections = result
        end
    end
end

function save_hidden_collections()
    local file = io.open(hidden_collections_file, "w+")
    if not file then
        return
    end

    local function lua_escape(value)
        return tostring(value):gsub("\\", "\\\\"):gsub('"', '\\"')
    end

    file:write("return\n{\n")
    for key, hidden in pairs(HiddenCollections) do
        if hidden == true then
            file:write('\t["' .. lua_escape(key) .. '"] = true,\n')
        end
    end
    file:write("}")
    file:close()
end

function collection_visibility_key(def_collection_num)
    if collection_files and collection_files[def_collection_num] then
        return collection_files[def_collection_num].table_name
    end
    return nil
end

function is_collection_visible(def_collection_num)
    local key = collection_visibility_key(def_collection_num)
    return showCollections == 1 and key ~= nil and HiddenCollections[key] ~= true
end

function set_collection_visible(def_collection_num, def_visible)
    local key = collection_visibility_key(def_collection_num)
    if key then
        if def_visible then
            HiddenCollections[key] = nil
        else
            HiddenCollections[key] = true
        end
    end
end

function set_all_collections_visible(def_visible)
    if collection_files then
        for collection_num = 1, #collection_files do
            set_collection_visible(collection_num, def_visible)
        end
    end
    showCollections = def_visible and 1 or 0
end

function build_visible_collection_options()
    visible_collection_options = {}

    if collection_files and #collection_files > 0 then
        table.insert(visible_collection_options, { action = "show_all", display_name = lang_lines.Show_all })
        table.insert(visible_collection_options, { action = "hide_all", display_name = lang_lines.Hide_all })

        for collection_num, collection_file in ipairs(collection_files) do
            table.insert(visible_collection_options, {
                collection_num = collection_num,
                key = collection_file.table_name,
                display_name = collection_file.display_name,
            })
        end
    end
end

function move_visible_collection_selection(def_direction)
    if #visible_collection_options == 0 then
        visible_collection_selected = 1
        return
    end

    visible_collection_selected = visible_collection_selected + def_direction

    if visible_collection_selected < 1 then
        visible_collection_selected = #visible_collection_options
    elseif visible_collection_selected > #visible_collection_options then
        visible_collection_selected = 1
    end
end

function count_enabled_collections()
    local total = 0
    if collection_files then
        for collection_num = 1, #collection_files do
            local key = collection_visibility_key(collection_num)
            if key ~= nil and HiddenCollections[key] ~= true then
                total = total + 1
            end
        end
    end
    return total
end

function save_visible_collection_settings()
    if count_enabled_collections() == 0 then
        showCollections = 0
    else
        showCollections = 1
    end

    save_hidden_collections()
    normalize_startup_category()
    SaveSettings()
    normalize_current_category(1)
    check_for_out_of_bounds()
    GetNameAndAppTypeSelected()
end

function category_visibility_key(def_showcat)
    local category = CategoryVisibilityByShowCat[def_showcat]
    return category and category.key or nil
end

function is_category_visible(def_showcat)
    if def_showcat == nil then
        return false
    elseif def_showcat == 50 then
        return false
    elseif def_showcat == 0 then
        return showAll == 1
    elseif def_showcat == 2 then
        return showHomebrews == 1
    elseif def_showcat == 47 then
        return showSysApps == 1
    elseif def_showcat == 49 then
        return showRecentlyPlayed == 1
    elseif def_showcat >= 51 then
        return is_collection_visible(def_showcat - 50)
    end

    local key = category_visibility_key(def_showcat)
    return key ~= nil and HiddenCategories[key] ~= true
end

function set_category_visible(def_showcat, def_visible)
    if def_showcat == 0 then
        showAll = def_visible and 1 or 0
    elseif def_showcat == 2 then
        showHomebrews = def_visible and 1 or 0
    elseif def_showcat == 47 then
        showSysApps = def_visible and 1 or 0
    elseif def_showcat == 49 then
        showRecentlyPlayed = def_visible and 1 or 0
    else
        local key = category_visibility_key(def_showcat)
        if key then
            if def_visible then
                HiddenCategories[key] = nil
            else
                HiddenCategories[key] = true
            end
        end
    end
end

function get_category_label(def_category)
    local category = CategoryVisibilityByShowCat[def_category]
    if category and lang_lines and lang_lines[category.label_key] then
        return lang_lines[category.label_key]
    elseif category and category.label_key then
        return category.label_key:gsub("_", " ")
    end
    return lang_lines.PS_Vita
end

function build_visible_category_options()
    visible_category_options = {}
    for _, category in pairs(CategoryVisibilityDefinitions) do
        category.display_name = get_category_label(category.showcat)
        table.insert(visible_category_options, category)
    end
    table.sort(visible_category_options, function(a, b)
        local function sort_rank(category)
            if category.showcat == 0 then
                return 1
            elseif category.showcat == 2 then
                return 2
            elseif category.showcat == 47 then
                return 3
            elseif category.showcat == 48 then
                return 4
            elseif category.showcat == 49 then
                return 5
            end
            return 6
        end

        local rank_a = sort_rank(a)
        local rank_b = sort_rank(b)
        if rank_a ~= rank_b then
            return rank_a < rank_b
        end

        local key_a = (a.label_key or a.key or ""):gsub("_", " "):lower()
        local key_b = (b.label_key or b.key or ""):gsub("_", " "):lower()
        return key_a < key_b
    end)
end

function move_visible_category_selection(def_direction)
    if #visible_category_options == 0 then
        visible_category_selected = 1
        return
    end

    visible_category_selected = visible_category_selected + def_direction

    if visible_category_selected < 1 then
        visible_category_selected = #visible_category_options
    elseif visible_category_selected > #visible_category_options then
        visible_category_selected = 1
    end
end

function count_visible_base_categories()
    local total = 0
    for _, category in pairs(CategoryVisibilityDefinitions) do
        if category.showcat ~= 0 and category.showcat ~= 48 and category.showcat ~= 49 and is_category_visible(category.showcat) == true then
            total = total + 1
        end
    end
    return total
end

function ensure_at_least_one_visible_category()
    if count_visible_base_categories() == 0 then
        set_category_visible(1, true)
    end
end

function category_has_items(def_showcat)
    if def_showcat == 48 then
        refresh_fav_count_table()
    end

    local category_table = xCatLookup(def_showcat)
    return category_table ~= nil and #category_table > 0
end

function is_category_selectable(def_showcat)
    if is_category_visible(def_showcat) ~= true then
        return false
    elseif def_showcat == 0 then
        return true
    elseif def_showcat >= 51 then
        return category_has_items(def_showcat)
    end
    return category_has_items(def_showcat)
end

function step_category(def_showcat, def_direction)
    local max_category = collection_syscount or count_of_categories

    if filterGames == 1 then
        if collection_count == 0 then
            return def_showcat
        elseif def_direction > 0 then
            if def_showcat >= 51 and def_showcat < max_category then
                return def_showcat + 1
            end
            return 51
        else
            if def_showcat > 51 and def_showcat <= max_category then
                return def_showcat - 1
            end
            return max_category
        end
    end

    if def_direction > 0 then
        if def_showcat == 0 then
            return 1
        elseif def_showcat < max_category then
            return def_showcat + 1
        elseif showAll == 1 then
            return 0
        end
        return 1
    else
        if def_showcat == 0 then
            return max_category
        elseif def_showcat > 1 then
            return def_showcat - 1
        elseif showAll == 1 then
            return 0
        end
        return max_category
    end
end

function find_next_selectable_category(def_direction, def_start_showcat)
    local current = def_start_showcat or showCat
    local max_checks = (collection_syscount or count_of_categories) + 2

    for checked = 1, max_checks do
        if is_category_selectable(current) == true then
            return current
        end
        current = step_category(current, def_direction)
    end

    return 1
end

function normalize_current_category(def_direction)
    if is_category_selectable(showCat) ~= true then
        showCat = find_next_selectable_category(def_direction or 1, step_category(showCat, def_direction or 1))
    end
end

function change_category(def_direction)
    search_results_table = {}

    showCat = find_next_selectable_category(def_direction, step_category(showCat, def_direction))
    normalize_current_category(def_direction)

    hideBoxes = 0.8 -- used to be 8
    p = 1
    master_index = p
    startCovers = false
    quick_scrolling_factor = 0
    quick_scrolling_factor_goal = 0
    flat_view_scroll_x = 0
    flat_view_target_x = 0
    GetInfoSelected()
    FreeIcons()
end

function save_visible_category_settings()
    ensure_at_least_one_visible_category()
    save_hidden_categories()
    normalize_startup_category()
    SaveSettings()

    if visible_categories_dirty == true then
        FreeIcons()
        startCovers = false
        startup_cover_prewarm_pending = true
        flat_view_scroll_x = 0
        flat_view_target_x = 0
    end

    rebuild_mixed_category_visibility_tables()
    normalize_current_category(1)
    check_for_out_of_bounds()
    GetNameAndAppTypeSelected()
end

load_hidden_categories()
load_hidden_collections()

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

if collection_files_start_match > 0 and is_collection_visible(collection_files_start_match) == true then
    showCat = 50 + collection_files_start_match
    startCategory = syscount + collection_files_start_match
else
    showCat = startCategory
end

music_sequential = {}
music_shuffled = {}
music_initialized = false
track = 1

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

function init_music_if_needed()
    if music_initialized == false then
        music_initialized = true

        -- Music - Legacy Fix - Move music files from old directory to new
        if System.doesFileExist("ux0:/data/RetroFlow/Music.ogg") then System.rename("ux0:/data/RetroFlow/Music.ogg", "ux0:/data/RetroFlow/MUSIC/Music.ogg") end

        -- Music - Scan Music Directory
        music_dir = System.listDirectory("ux0:/data/RetroFlow/MUSIC/") or {}

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

        -- Music - Play if enabled
        if setMusic == 1 then
            if setMusicShuffle == 1 then
                Shuffle(music_sequential)
            else
            end
            track = 1
            PlayMusic()
        end
    end
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


-- Speed related settings (MOVED TO TOP OF FILE)

function OneshotPrint(my_func)
    my_func()
    Screen.flip()
    my_func()
    Screen.flip()
    my_func()
end

lang_lines = {}
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

-- Categories
["Edit_category_visibility"] = "Edit category visibility",
["Startup_Category_colon"] = "Startup category: ",
["Last_played_game"] = "Last played game",
["Favorites"] = "Favorites",
["Recently_Played"] = "Recently Played",
["PS_Vita"] = "PS Vita",
["Homebrews"] = "Homebrews",
["PSP"] = "PSP",
["PlayStation"] = "PlayStation",
["Nintendo_64"] = "Nintendo 64",
["Super_Nintendo"] = "Super Nintendo",
["Nintendo_Entertainment_System"] = "Nintendo Entertainment System",
["Nintendo_3DS"] = "Nintendo 3DS",
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
["Atari_ST"] = "Atari ST",
["MS_DOS"] = "MS-DOS",
["EasyRPG"] = "EasyRPG",

-- Download
["Download_colon"] = "Download:",
["Covers"] = "Covers",
["Backgrounds"] = "Backgrounds",
["Download_using_CRC_colon"] = "Download using CRC:",
["Extract_PS_Vita_backgrounds"] = "Extract PS Vita backgrounds:",
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
["N3DS_Game"] = "Nintendo 3DS Game",
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
["Atari_ST_Game"] = "Atari ST Game",
["MS_DOS_Game"] = "MS-DOS Game",
["EasyRPG_Game"] = "EasyRPG Game",

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

["guide_2_heading"] = "Why did I get an Adrenaline warning?",
["guide_2_content"] = "RetroFlow did not recognise your installed Adrenaline module set. PSP and PS1 games will still be shown, but they may not launch correctly.\n\nIf games do not launch, update RetroFlow when a newer version is available.",

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
["Show_RetroArch_cores_colon"] = "Show RetroArch cores:",

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
["Edit_collection_visibility"] = "Edit collection visibility",
["Show_all"] = "Show all",
["Hide_all"] = "Hide all",

-- Adrenaline install assets
["RETROLNCR_Install"] = "Installing RetroFlow Adrenaline Launcher vpk...",
["RETROLNCR_Installed"] = "RetroFlow Adrenaline Launcher has been installed.",
["ABB_Install"] = "Installing AdrBubbleBooter plugin...",
["ABB_Installed"] = "AdrBubbleBooter plugin has been installed...",
["ABB_Restart"] = "We need to restart your PS Vita.",
["Restart_Now"] = "Restart Now",
["Restart_Later"] = "Restart Later",
["Install_Official_Adrenaline"] = "Install Adrenaline v7 by TheOfficialFloW to enable PSP and PS1 games.",
["Adrenaline_Unsupported"] = "Your Adrenaline module set is not recognised. PSP and PS1 games may not launch.",

-- Launch messages
["Emulator_not_installed_Adrenaline"] = "You need to install Adrenaline to play this game.",
["Emulator_not_installed_ScummVM"] = "You need to install the ScummVM to play this game.",
["Emulator_not_installed_Pico8"] = "You need to install FAKE-08 to play this game.",
["Emulator_not_installed_Retroarch"] = "You need to install RetroArch to play this game.",
["Emulator_not_installed_DaedalusX64"] = "You need to install DaedalusX64 to play this game.",
["Emulator_not_installed_Flycast"] = "You need to install Flycast to play this game.",
["Emulator_not_installed_Azahar"] = "You need to install Azahar to play this game.",
["Emulator_not_installed_DSVita"] = "You need to install DSVita to play this game.",
["Emulator_not_installed_EasyRPG"] = "You need to install EasyRPG to play this game.",
["Emulator_not_installed_Emu4Vita"] = "You need to install Emu4Vita++ to play this game.",
["Game_not_installed_rescan"] = "This game is not installed, please rescan your games.",
["Insert_cartridge_try_again"] = "Please insert the game cartridge and try again.",

-- Cartridges
["Scan_Vita_cartridges_colon"] = "Scan Vita cartridges:",

-- Emulator core strings
["Show_game_core_menu_colon"] = "Show game core menu:",
["Global_core_settings"] = "Global core settings",
["Platform_colon"] = "Platform:",
["Emulator_core"] = "Emulator core",
["Core_colon"] = "Core:",
["Global_core_colon"] = "Global core:",
["Reset_platform_core"] = "Reset platform core",
["Reset_all_platform_cores"] = "Reset all platform cores",
["Reset_all_game_overrides"] = "Reset all game overrides",
["Star_Recommended_core"] = "★ Recommended core",
["Use_Global"] = "Use Global",
["Core_source_retroarch"] = " (RetroArch)",
["Core_source_emu4vita"] = " (Emu4Vita++)",

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
        font_buffer = Extended.loadFontIntoMemory("app0:/DATA/" .. fontname)

        fnt20 = Extended.loadFontFromMemory(font_buffer)
        fnt22 = Extended.loadFontFromMemory(font_buffer)
        fnt25 = Extended.loadFontFromMemory(font_buffer)

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
files_wallpaper = System.listDirectory("ux0:/data/RetroFlow/WALLPAPER/") or {}
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

    if setLanguage == 2 or setLanguage == 3 or setLanguage == 5 or setLanguage == 6 or setLanguage == 8 or setLanguage == 9 or setLanguage == 12 or setLanguage == 16 or setLanguage == 19 or setLanguage == 20 or setLanguage == 21 then
    -- German, French, Spanish, Portugeuse, Russian, Japanese, Turkish, Dutch, Japanese (Ryukyuan) Hungarian, Portuguese (Brasil)
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

    
    if setLanguage == 2 or setLanguage == 3 or setLanguage == 5 or setLanguage == 6 or setLanguage == 8 or setLanguage == 9 or setLanguage == 12 or setLanguage == 16 or setLanguage == 19 or setLanguage == 20 or setLanguage == 21 then
    -- German, French, Spanish, Portugeuse, Russian, Japanese, Turkish, Dutch, Japanese (Ryukyuan) Hungarian, Portuguese (Brasil)
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



function PrintCentered(font, x, y, text, color, size)
    text = text:gsub("\n","")
    local width = Font.getTextWidth(font,text)
    Font.print(font, x - width / 2, y, text, color)
end


-- Adrenaline launcher setup

    function install_message(str)
        Graphics.initBlend()
        Screen.clear()
        Graphics.drawImage(0, 0, loadingImage)
        PrintCentered(fnt20, 480, 445, str, white, 20)
        Graphics.termBlend()
        Screen.flip()
        Screen.clear()
    end
    

    adrenaline_compatibilty = false
    adrenaline_family = nil
    adrenaline_state = "unsupported"
    adrenaline_target_module_source = nil
    adrenaline_target_signature = nil

    adrenaline_module_names = {
        "adrbubblebooter.suprx",
        "adrenaline_kernel.skprx",
        "adrenaline_user.suprx",
        "adrenaline_vsh.suprx",
        "bootconv.suprx",
    }

    adrenaline_signature_theflow_v7 = {
        ["adrenaline_kernel.skprx"] = "20f7c5cd",
        ["adrenaline_user.suprx"]   = "5487a9c3",
        ["adrenaline_vsh.suprx"]    = "fa85cd74",
    }

    adrenaline_signature_theflow_lman = {
        ["adrbubblebooter.suprx"]   = "039095fd",
        ["adrenaline_kernel.skprx"] = "c9f84053",
        ["adrenaline_user.suprx"]   = "f5116106",
        ["adrenaline_vsh.suprx"]    = "485293a1",
        ["bootconv.suprx"]          = "d072fe17",
    }
    
    -- ABM 6.20.1 shipped the menu-label fix before the direct-IFTU build. It is
    -- accepted as a known legacy state and upgraded to the current fixed stack.
    adrenaline_signature_theflow_menu_fix_legacy = {
        ["adrbubblebooter.suprx"]   = "039095fd",
        ["adrenaline_kernel.skprx"] = "c9f84053",
        ["adrenaline_user.suprx"]   = "9e1b321a",
        ["adrenaline_vsh.suprx"]    = "485293a1",
        ["bootconv.suprx"]          = "d072fe17",
    }

    -- Default installation: TheOfficialFloW/Adrenaline v7 with the menu-label and
    -- direct-IFTU fixes.
    adrenaline_signature_theflow_menu_fix = {
        ["adrbubblebooter.suprx"]   = "039095fd",
        ["adrenaline_kernel.skprx"] = "21bd6d72",
        ["adrenaline_user.suprx"]   = "2c6fb429",
        ["adrenaline_vsh.suprx"]    = "485293a1",
        ["bootconv.suprx"]          = "d072fe17",
    }

    adrenaline_signature_isage_802 = {
        ["adrenaline_kernel.skprx"] = "3b998f83",
        ["adrenaline_user.suprx"]   = "eddf100e",
        ["adrenaline_vsh.suprx"]    = "cae14c01",
    }

    adrenaline_signature_isagecompat = {
        ["adrbubblebooter.suprx"]   = "02c3104e",
        ["adrenaline_kernel.skprx"] = "373bd9d6",
        ["adrenaline_user.suprx"]   = "6c4b9257",
        ["adrenaline_vsh.suprx"]    = "2a23114d",
        ["bootconv.suprx"]          = "84bf1418",
    }

    -- Known per-family core values let Adrenaline bubble compatibility safely finish an interrupted update,
    -- while still refusing arbitrary or cross-family module combinations.
    adrenaline_known_theflow_core = {
        ["adrenaline_kernel.skprx"] = { "20f7c5cd", "c9f84053", "21bd6d72" },
        ["adrenaline_user.suprx"]   = { "5487a9c3", "f5116106", "9e1b321a", "2c6fb429" },
        ["adrenaline_vsh.suprx"]    = { "fa85cd74", "485293a1" },
    }

    adrenaline_known_isage_core = {
        ["adrenaline_kernel.skprx"] = { "3b998f83", "373bd9d6" },
        ["adrenaline_user.suprx"]   = { "eddf100e", "cb75a035", "6c4b9257" },
        ["adrenaline_vsh.suprx"]    = { "cae14c01", "2a23114d" },
    }

    function adrenaline_crc(path)
        if not System.doesFileExist(path) then return nil end
        local crc = Extended.crc32File(path)
        if crc == nil then return nil end
        return string.lower(tostring(crc))
    end

    function adrenaline_read_module_crcs()
        local installed = {}
        for i=1,#adrenaline_module_names do
            local name = adrenaline_module_names[i]
            installed[name] = adrenaline_crc(ADRENALINE.."/sce_module/"..name)
        end
        return installed
    end

    function adrenaline_matches_signature(installed, signature)
        for name, crc in pairs(signature) do
            if installed[name] ~= crc then
                return false
            end
        end
        return true
    end

    function adrenaline_contains_crc(values, crc)
        if crc == nil then return false end
        for i=1,#values do
            if values[i] == crc then return true end
        end
        return false
    end

    function adrenaline_matches_known_core(installed, known)
        for name, values in pairs(known) do
            if not adrenaline_contains_crc(values, installed[name]) then
                return false
            end
        end
        return true
    end

    function Detect_Adrenaline_Family()
        ADRENALINE = "ux0:app/PSPEMUCFW"

        if not System.doesAppExist("PSPEMUCFW") then
            return nil, "unsupported"
        end

        local installed = adrenaline_read_module_crcs()

        if adrenaline_matches_signature(installed, adrenaline_signature_theflow_menu_fix) then
            return "theflow", "theflow-menu-label-fix"
        elseif adrenaline_matches_signature(installed, adrenaline_signature_theflow_lman) then
            return "theflow", "theflow-lman"
        elseif adrenaline_matches_signature(installed, adrenaline_signature_theflow_menu_fix_legacy) then
            return "theflow", "theflow-menu-label-fix-legacy"
        elseif adrenaline_matches_signature(installed, adrenaline_signature_isagecompat) then
            return "isage", "isage-isagecompat"
        elseif adrenaline_matches_signature(installed, adrenaline_signature_theflow_v7) then
            return "theflow", "theflow-v7"
        elseif adrenaline_matches_signature(installed, adrenaline_signature_isage_802) then
            return "isage", "isage-v8.0.2"
        elseif adrenaline_matches_known_core(installed, adrenaline_known_theflow_core) then
            return "theflow", "theflow-incomplete"
        elseif adrenaline_matches_known_core(installed, adrenaline_known_isage_core) then
            return "isage", "isage-incomplete"
        end

        return nil, "unsupported"
    end

    function Set_Adrenaline_Target_Files()
        adrenaline_target_module_source = nil
        adrenaline_target_signature = nil

        if adrenaline_family == "theflow" then
            adrenaline_target_module_source = "app0:payloads/abm/modules/sce_module_abm_v7/"
            adrenaline_target_signature = adrenaline_signature_theflow_menu_fix
        elseif adrenaline_family == "isage" then
            adrenaline_target_module_source = "app0:payloads/abm/modules/sce_module_abm_8.0.2/"
            adrenaline_target_signature = adrenaline_signature_isagecompat
        end
    end

    function Check_Adrenaline_Compatibility()
        adrenaline_compatibilty = false
        ADRENALINE = "ux0:app/PSPEMUCFW"

        adrenaline_family, adrenaline_state = Detect_Adrenaline_Family()
        if adrenaline_family ~= nil then
            adrenaline_compatibilty = true
            Set_Adrenaline_Target_Files()
        else
            adrenaline_compatibilty = false
        end

        -- NOTIFICATION ABOUT WRONG ADRENALINE VERSION

            -- Create file to act as a flag for a one-time dialog message

                local adr_notification_file = cur_dir .. "/adr_compatability.dat"
                local adr_notification_file_exists = System.doesFileExist(adr_notification_file)

                if adrenaline_compatibilty == false and adr_notification_file_exists == false then

                    -- Notify that the wrong version of Adrenaline is installed
                    if System.doesAppExist("PSPEMUCFW") then
                        status = System.getMessageState()
                        if status ~= RUNNING then
                            System.setMessage(lang_lines.Adrenaline_Unsupported, false, BUTTON_OK)
                        end
                    end

                    -- Create file
                    local file_over = System.openFile(adr_notification_file, FCREATE)
                    if file_over then
                        System.closeFile(file_over)
                    end
                    adr_notification_file_exists = true

                end

            -- Remove notification file if adrenaline is compatible

                if adrenaline_compatibilty == true and adr_notification_file_exists == true then
                    -- Delete file
                    if System.doesFileExist(adr_notification_file) then
                        System.deleteFile(adr_notification_file)
                        adr_notification_file_exists = false
                    end
                end

    end

    function Setup_Adrenaline()

        -- Install RetroFlow Adrenaline Launcher if needed
            if not System.doesAppExist("RETROLNCR") then
 
                RETROLNCR_VPK = "app0:payloads/RetroFlow Adrenaline Launcher.vpk"

                if System.doesAppExist("PSPEMUCFW") then
                    if System.doesFileExist(RETROLNCR_VPK) then
                        
                        install_message(lang_lines.RETROLNCR_Install) -- Installing RetroFlow Adrenaline Launcher...

                        System.installVpk(RETROLNCR_VPK)

                        install_message(lang_lines.RETROLNCR_Installed) -- RetroFlow Adrenaline Launcher has been installed...
                        System.wait(2500000) -- Wait for 2.5 seconds
                    end
                end

            end

        -- Check Adrenaline Bubble Booter assets are installed, restart if not

            -- CRC Checksums and assets

                ADRENALINE = "ux0:app/PSPEMUCFW"
                if adrenaline_target_module_source == nil or adrenaline_target_signature == nil then
                    adrenaline_family, adrenaline_state = Detect_Adrenaline_Family()
                    Set_Adrenaline_Target_Files()
                end

                MODULES = {}
                if adrenaline_target_module_source ~= nil and adrenaline_target_signature ~= nil then
                    for i=1,#adrenaline_module_names do
                        local module_name = adrenaline_module_names[i]
                        table.insert(MODULES, {
                            file_adr = ADRENALINE.."/sce_module/"..module_name,
                            file_payload = adrenaline_target_module_source..module_name,
                            crc = adrenaline_target_signature[module_name],
                        })
                    end
                end
            
            -- Copy assets if missing or CRC's are different, restart Vita

                oncopy = false

                if System.doesAppExist("PSPEMUCFW") and System.doesDirExist(ADRENALINE) and
                    System.doesFileExist(ADRENALINE.."/eboot.bin") and System.doesFileExist(ADRENALINE.."/eboot.pbp") then

                    if not System.doesFileExist(ADRENALINE.."/adrenaline.bin") then
                        oncopy = true
                        System.copyFile("app0:payloads/abm/bubbles/adrenaline.bin", ADRENALINE.."/adrenaline.bin")
                    end

                    if not System.doesFileExist(ADRENALINE.."/menucolor.bin") then
                        oncopy = true
                        System.copyFile("app0:payloads/abm/bubbles/menucolor.bin", ADRENALINE.."/menucolor.bin")
                    end

                    for i=1,#MODULES do
                        -- If file doesn't exist, copy payload file to destination
                        if not System.doesFileExist(MODULES[i].file_adr) then
                            oncopy = true
                            System.copyFile(MODULES[i].file_payload, MODULES[i].file_adr)
                        else
                            -- Check CRC
                            if Extended.crc32File(MODULES[i].file_adr) ~= MODULES[i].crc then
                                -- CRC doesn't match, copy payload file to destination
                                oncopy = true
                                if System.doesFileExist(MODULES[i].file_adr) then
                                    -- Delete file before copying
                                    System.deleteFile(MODULES[i].file_adr)
                                end
                                System.copyFile(MODULES[i].file_payload, MODULES[i].file_adr)
                            end
                        end
                    end

                    if oncopy then

                        install_message(lang_lines.ABB_Install) -- Installing AdrBubbleBooter plugin... - Message displayed after install, backwards I know but simpler, otherwise message is unnecessarily duplicated
                        System.wait(2500000) -- Wait for 2.5 seconds

                        Graphics.initBlend()
                        Screen.clear()
                        Graphics.drawImage(0, 0, loadingImage)

                        PrintCentered(fnt20, 480, 400, lang_lines.ABB_Installed, white, 20) -- AdrBubbleBooter plugin has been installed...
                        PrintCentered(fnt20, 480, 425, lang_lines.ABB_Restart, white, 20) -- We need to restart your PS Vita

                        -- Calculate centre alignment for images and strings

                            msg_btnLabel1 = Font.getTextWidth(fnt20, lang_lines.Restart_Now) -- Restart Now
                            msg_btnLabel2 = Font.getTextWidth(fnt20, lang_lines.Restart_Later) -- Restart Later
                            msg_btnMargin = 40 -- Distance between buttons
                            msg_btnPaddingRight = 15
                            msg_btImgWidth = 20
                            msg_btImgYoffset = 2.5

                            msg_overallWidth = msg_btImgWidth + msg_btnPaddingRight + msg_btnLabel1 + msg_btnMargin + msg_btImgWidth + msg_btnPaddingRight + msg_btnLabel2

                            local msg_xpos_cumulative = (960 - msg_overallWidth) / 2

                        -- Button X
                        Graphics.setImageFilters(btnX, FILTER_LINEAR, FILTER_LINEAR)
                        Graphics.drawImage(msg_xpos_cumulative, 480 - msg_btImgYoffset, btnX)

                        -- String - Restart Now
                        msg_xpos_cumulative = msg_xpos_cumulative + msg_btImgWidth + msg_btnPaddingRight
                        Font.print(fnt20, msg_xpos_cumulative, 475, lang_lines.Restart_Now, white)

                        -- Button O
                        msg_xpos_cumulative = msg_xpos_cumulative + msg_btnLabel1 + msg_btnMargin

                        Graphics.setImageFilters(btnO, FILTER_LINEAR, FILTER_LINEAR)
                        Graphics.drawImage(msg_xpos_cumulative, 480 - msg_btImgYoffset, btnO)

                        -- String - Restart Later
                        msg_xpos_cumulative = msg_xpos_cumulative + msg_btImgWidth + msg_btnPaddingRight
                        Font.print(fnt20, msg_xpos_cumulative, 475, lang_lines.Restart_Later, white)

                        Graphics.termBlend()
                        Screen.flip()
                        Screen.clear()

                        -- Controls
                        while true do
                            pad = Controls.read()
                            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then
                                System.reboot()
                            elseif Controls.check(pad, SCE_CTRL_CIRCLE_MAP) and not Controls.check(oldpad, SCE_CTRL_CIRCLE_MAP) then
                                oldpad = pad
                                break
                            end
                        end

                    else
                    end

                else
                end

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
    if imgBox then Graphics.freeImage(imgBox) end
    if imgBoxPSP then Graphics.freeImage(imgBoxPSP) end
    if imgBoxPSX then Graphics.freeImage(imgBoxPSX) end
    Graphics.freeImage(imgFavorite_small_on)
    Graphics.freeImage(imgFavorite_large_on)
    Graphics.freeImage(imgFavorite_large_off)
    Graphics.freeImage(imgHidden_large_on)
    Graphics.freeImage(imgHidden_small_on)
    Graphics.freeImage(cart_icon_on)
    Graphics.freeImage(cart_icon_off)
    
    -- Only free setting icons if they were loaded
    if setting_icons_loaded then
        Graphics.freeImage(setting_icon_theme)
        Graphics.freeImage(setting_icon_artwork)
        Graphics.freeImage(setting_icon_categories)
        Graphics.freeImage(setting_icon_language)
        Graphics.freeImage(setting_icon_scanning)
        Graphics.freeImage(setting_icon_search)
        Graphics.freeImage(setting_icon_sounds)
        Graphics.freeImage(setting_icon_about)
        Graphics.freeImage(setting_icon_other)
        Graphics.freeImage(setting_icon_heart)
        Graphics.freeImage(setting_icon_filter)
        Graphics.freeImage(setting_icon_random)
        Graphics.freeImage(setting_icon_sort)
        Graphics.freeImage(setting_icon_sort_up)
        Graphics.freeImage(setting_icon_sort_down)
    end
    
    if file_browser_icons_loaded == true then
        Graphics.freeImage(file_browser_folder_open)
        Graphics.freeImage(file_browser_folder_closed)
        Graphics.freeImage(file_browser_file)
    end
    
    if category_visibility_icons_loaded == true then
        Graphics.freeImage(category_visibility_checked)
        Graphics.freeImage(category_visibility_unchecked)
    end
    Graphics.freeImage(footer_gradient)
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
    elseif CatNum == 9 then     return  n3ds_table
    elseif CatNum == 10 then    return  nds_table
    elseif CatNum == 11 then    return  gba_table
    elseif CatNum == 12 then    return  gbc_table
    elseif CatNum == 13 then    return  gb_table
    elseif CatNum == 14 then    return  dreamcast_table
    elseif CatNum == 15 then    return  sega_cd_table
    elseif CatNum == 16 then    return  s32x_table
    elseif CatNum == 17 then    return  md_table
    elseif CatNum == 18 then    return  sms_table
    elseif CatNum == 19 then    return  gg_table
    elseif CatNum == 20 then    return  tg16_table
    elseif CatNum == 21 then    return  tgcd_table
    elseif CatNum == 22 then    return  pce_table
    elseif CatNum == 23 then    return  pcecd_table
    elseif CatNum == 24 then    return  amiga_table
    elseif CatNum == 25 then    return  scummvm_table
    elseif CatNum == 26 then    return  easyrpg_table
    elseif CatNum == 27 then    return  dos_table
    elseif CatNum == 28 then    return  c64_table
    elseif CatNum == 29 then    return  wswan_col_table
    elseif CatNum == 30 then    return  wswan_table
    elseif CatNum == 31 then    return  pico8_table
    elseif CatNum == 32 then    return  msx2_table
    elseif CatNum == 33 then    return  msx1_table
    elseif CatNum == 34 then    return  zxs_table
    elseif CatNum == 35 then    return  atari_st_table  
    elseif CatNum == 36 then    return  atari_7800_table
    elseif CatNum == 37 then    return  atari_5200_table
    elseif CatNum == 38 then    return  atari_2600_table
    elseif CatNum == 39 then    return  atari_lynx_table
    elseif CatNum == 40 then    return  colecovision_table
    elseif CatNum == 41 then    return  vectrex_table
    elseif CatNum == 42 then    return  fba_table
    elseif CatNum == 43 then    return  mame_2003_plus_table
    elseif CatNum == 44 then    return  mame_2000_table
    elseif CatNum == 45 then    return  neogeo_table
    elseif CatNum == 46 then    return  ngpc_table
    elseif CatNum == 47 then    return  sysapps_table
    elseif CatNum == 48 then    return  fav_count
    elseif CatNum == 49 then    return  recently_played_table
    elseif CatNum == 50 then    return  search_results_table -- Table also used for random game selection

    -- COLLECTIONS
    elseif CatNum >= 51 and CatNum <= collection_syscount then
        Collection_CatNum = CatNum - 50
        return _G[collection_files[Collection_CatNum].table_name]

    else             return files_table_no_sysapps -- Hide sys apps from all list
    end
end

function xCatTableNameLookup(CatNum)
    if CatNum == 0 then
        return "files_table_no_sysapps"
    elseif CatNum >= 51 and CatNum <= collection_syscount then
        local Collection_CatNum = CatNum - 50
        if collection_files[Collection_CatNum] then
            return collection_files[Collection_CatNum].table_name
        end
    elseif SystemsToScan[CatNum] and SystemsToScan[CatNum].table then
        return SystemsToScan[CatNum].table
    end

    return nil
end

-- STARTUP CATEGORY - Keep the settings label in one place for both drawing and left/right changes.
function startup_category_label(def_category)
    if def_category >= 51 then
        local Collection_CatNum = def_category - 50
        if collection_files[Collection_CatNum] then
            return collection_files[Collection_CatNum].display_name
        end
    elseif def_category == START_CATEGORY_LAST_PLAYED then
        return lang_lines.Last_played_game
    end

    return get_category_label(def_category)
end

-- STARTUP CATEGORY - Build selectable startup categories, respecting category visibility settings.
function startup_category_options()
    local options = {}

    if is_category_visible(0) == true then
        table.insert(options, 0)
    end

    for cat_num = 1, count_of_start_categories do
        if is_category_visible(cat_num) == true then
            table.insert(options, cat_num)
        end
    end

    if #options == 0 then
        table.insert(options, 1)
    end

    table.insert(options, START_CATEGORY_LAST_PLAYED)

    if collection_files then
        for Collection_CatNum = 1, #collection_files do
            if is_collection_visible(Collection_CatNum) == true then
            table.insert(options, 50 + Collection_CatNum)
            end
        end
    end

    return options
end

-- STARTUP CATEGORY - Fall back to PS Vita only if the saved category is disabled by settings.
function normalize_startup_category()
    if startCategory ~= START_CATEGORY_LAST_PLAYED and is_category_visible(startCategory) ~= true then
        local options = startup_category_options()
        startCategory = options[1] or 1
    elseif startCategory ~= START_CATEGORY_LAST_PLAYED and startCategory > collection_syscount then
        local options = startup_category_options()
        startCategory = options[1] or 1
    end

    return startCategory
end

-- STARTUP CATEGORY - Move the setting with left/right controls instead of changing it on Cross.
function change_startup_category(def_direction)
    local options = startup_category_options()
    local current_index = 1

    for key, category in ipairs(options) do
        if category == startCategory then
            current_index = key
            break
        end
    end

    current_index = current_index + def_direction

    if current_index < 1 then
        current_index = #options
    elseif current_index > #options then
        current_index = 1
    end

    startCategory = options[current_index]
end

-- LAST PLAYED GAME - Convert a saved table name back to the live category number used by showCat.
-- Collections are resolved by table name so startup survives collection reordering.
function xCatNumFromTableName(def_table_name)
    if def_table_name == "files_table_no_sysapps" or def_table_name == "files_table" then
        return 0
    end

    for cat_num, system in pairs(SystemsToScan) do
        if cat_num ~= START_CATEGORY_LAST_PLAYED and system.table == def_table_name then
            return cat_num
        end
    end

    if collection_files and collection_syscount then
        for collection_showcat = 51, collection_syscount do
            local Collection_CatNum = collection_showcat - 50
            if collection_files[Collection_CatNum] and collection_files[Collection_CatNum].table_name == def_table_name then
                return collection_showcat
            end
        end
    end

    return nil
end

-- LAST PLAYED GAME - Temporary categories such as search/random should restore to the game's real system table.
-- xAppNumTableLookup already knows that mapping, so use it and then find the matching category.
function xCatTableNameFromAppType(def_app_type)
    local app_table = xAppNumTableLookup(def_app_type)

    if app_table == nil then
        return nil
    end

    for cat_num = 1, count_of_categories do
        if cat_num ~= START_CATEGORY_LAST_PLAYED and xCatLookup(cat_num) == app_table then
            return xCatTableNameLookup(cat_num)
        end
    end

    return nil
end

-- LAST PLAYED GAME - Check if a restored category is currently allowed by category visibility settings.
function last_played_showcat_is_visible(def_showcat, recent_game)
    if recent_game and recent_game.hidden == true and showHidden == 0 then
        return false
    end

    return is_category_visible(def_showcat) == true
end

-- LAST PLAYED GAME - Prefer the original launch category, but fall back to app type when that category is hidden.
function resolve_last_played_showcat(recent_game)
    if recent_game == nil then
        return nil
    end

    local launch_table_name = recent_game.last_played_table
    local launch_showcat = nil

    if launch_table_name ~= nil and launch_table_name ~= "search_results_table" then
        launch_showcat = xCatNumFromTableName(launch_table_name)
    end

    if last_played_showcat_is_visible(launch_showcat, recent_game) then
        return launch_showcat
    end

    local app_type_table_name = xCatTableNameFromAppType(recent_game.app_type)
    local app_type_showcat = app_type_table_name and xCatNumFromTableName(app_type_table_name)

    if last_played_showcat_is_visible(app_type_showcat, recent_game) then
        return app_type_showcat
    end

    return nil
end

-- LAST PLAYED GAME - Find a previously launched game in a rebuilt table without relying on one field only.
-- Paths are best, with filename/name as fallbacks for older recently_played entries.
function find_game_table_pos_key_by_recent(tbl, recent_game)
    if not tbl or not recent_game then
        return nil
    end

    for key, data in pairs(tbl) do
        if (recent_game.game_path and data.game_path == recent_game.game_path)
            or (recent_game.filename and data.filename == recent_game.filename)
            or (recent_game.name and data.name == recent_game.name) then
            return key
        end
    end

    return nil
end

-- LAST PLAYED GAME - Apply a startup jump and reset cover scrolling so the first draw starts around that game.
function set_startup_position(def_showcat, def_position)
    showCat = def_showcat
    p = def_position
    master_index = p
    startCovers = false
    targetX = 0
    quick_scrolling_factor = 0
    quick_scrolling_factor_goal = 0
    flat_view_scroll_x = 0
    flat_view_target_x = 0
    flat_cleanup_table = nil
    flat_cleanup_start = nil
    flat_cleanup_end = nil
    startup_cover_prewarm_pending = true
end

-- LAST PLAYED GAME - Resolve the "Last Played Game" startup option after all regular/collection tables exist.
function apply_last_played_startup_category()
    if startCategory ~= START_CATEGORY_LAST_PLAYED then
        return
    end

    local fallback_cat = 1 -- Vita
    local fallback_pos = 1 -- First game in Vita table
    local recently_played_was_hidden = showRecentlyPlayed == 0

    if recently_played_was_hidden then
        recently_played_table = {}
        import_recently_played(true)
        table.sort(recently_played_table, function(a, b) return (tonumber(a.date_played) > tonumber(b.date_played)) end)
    end

    local last_played = recently_played_table and recently_played_table[1]
    local launch_showcat = resolve_last_played_showcat(last_played)

    if launch_showcat == 48 then
        refresh_fav_count_table()
    end

    if launch_showcat ~= nil then
        local launch_table = xCatLookup(launch_showcat)
        local launch_pos = find_game_table_pos_key_by_recent(launch_table, last_played)

        if launch_pos ~= nil then
            set_startup_position(launch_showcat, launch_pos)
            if recently_played_was_hidden then
                recently_played_table = {}
            end
            return
        end
    end

    if recently_played_was_hidden then
        recently_played_table = {}
    end

    set_startup_position(fallback_cat, fallback_pos)
end

-- COLLECTIONS
    function xCollectionTableLookup(def_num)
        Collection_CatNum = (def_num)
        return _G[collection_files[Collection_CatNum].table_name]
    end

    function load_collection_edit_table(def_num)
        collection_edit_table = {}

        if collection_files and collection_files[def_num] then
            importLuaFile(collections_dir .. collection_files[def_num].filename, collection_edit_table)
        end

        return collection_edit_table
    end

    function xCollectionEditTableLookup()
        return collection_edit_table or {}
    end

    function check_if_game_is_in_collection_table(def_collection_number, def_name)
        local key = find_game_table_pos_key(xCollectionTableLookup((def_collection_number)), (def_name))
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
    elseif CatNum == 9 then     return  "db_n3ds.lua"  
    elseif CatNum == 10 then    return  "db_nds.lua"
    elseif CatNum == 11 then    return  "db_gba.lua"
    elseif CatNum == 12 then    return  "db_gbc.lua"
    elseif CatNum == 13 then    return  "db_gb.lua"
    elseif CatNum == 14 then    return  "db_dreamcast.lua"
    elseif CatNum == 15 then    return  "db_sega_cd.lua"
    elseif CatNum == 16 then    return  "db_32x.lua"
    elseif CatNum == 17 then    return  "db_md.lua"
    elseif CatNum == 18 then    return  "db_sms.lua"
    elseif CatNum == 19 then    return  "db_gg.lua"
    elseif CatNum == 20 then    return  "db_tg16.lua"
    elseif CatNum == 21 then    return  "db_tgcd.lua"
    elseif CatNum == 22 then    return  "db_pce.lua"
    elseif CatNum == 23 then    return  "db_pcecd.lua"
    elseif CatNum == 24 then    return  "db_amiga.lua"
    elseif CatNum == 25 then    return  "db_scummvm.lua"
    elseif CatNum == 26 then    return  "db_easyrpg.lua"
    elseif CatNum == 27 then    return  "db_dos.lua"
    elseif CatNum == 28 then    return  "db_c64.lua"
    elseif CatNum == 29 then    return  "db_wswan_col.lua"
    elseif CatNum == 30 then    return  "db_wswan.lua"
    elseif CatNum == 31 then    return  "db_pico8.lua"
    elseif CatNum == 32 then    return  "db_msx2.lua"
    elseif CatNum == 33 then    return  "db_msx1.lua"
    elseif CatNum == 34 then    return  "db_zxs.lua"
    elseif CatNum == 35 then    return  "db_atari_st.lua"
    elseif CatNum == 36 then    return  "db_atari_7800.lua"
    elseif CatNum == 37 then    return  "db_atari_5200.lua"
    elseif CatNum == 38 then    return  "db_atari_2600.lua"
    elseif CatNum == 39 then    return  "db_atari_lynx.lua"
    elseif CatNum == 40 then    return  "db_colecovision.lua"
    elseif CatNum == 41 then    return  "db_vectrex.lua"
    elseif CatNum == 42 then    return  "db_fba.lua"
    elseif CatNum == 43 then    return  "db_mame_2003_plus.lua"
    elseif CatNum == 44 then    return  "db_mame_2000.lua"
    elseif CatNum == 45 then    return  "db_neogeo.lua"
    elseif CatNum == 46 then    return  "db_ngpc.lua"
    elseif CatNum == 47 then    return  "db_sysapps.lua"
    else
    end
    -- elseif CatNum == 48 then    return fav_count
    -- elseif CatNum == 49 then    return recently_played_table
    -- elseif CatNum == 50 then    return search_results_table

    -- -- COLLECTIONS
    -- elseif CatNum >= 51 and CatNum <= collection_syscount then
    --     Collection_CatNum = CatNum - 50
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
    elseif AppTypeNum == 44 then return atari_st_table
    elseif AppTypeNum == 45 then return dos_table
    elseif AppTypeNum == 46 then return easyrpg_table
    elseif AppTypeNum == 47 then return n3ds_table
    elseif AppTypeNum == 48 then return fav_count
    elseif AppTypeNum == 49 then return recently_played_table
    elseif AppTypeNum == 50 then return search_results_table
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
    elseif AppTypeNum == 44 then return "db_atari_st.lua"
    elseif AppTypeNum == 45 then return "db_dos.lua"
    elseif AppTypeNum == 46 then return "db_easyrpg.lua"
    elseif AppTypeNum == 47 then return "db_n3ds.lua"
    else return "db_homebrews.lua"
    end
end

function xAppNumCRCLookupDB(AppTypeNum)
    -- Lookup CRC lua file to load
    
    if AppTypeNum == 5 then      return "crc_db_n64.lua"                -- n64_table
    elseif AppTypeNum == 6 then  return "crc_db_snes.lua"               -- snes_table
    elseif AppTypeNum == 7 then  return "crc_db_nes.lua"                -- nes_table
    elseif AppTypeNum == 8 then  return "crc_db_gba.lua"                -- gba_table
    elseif AppTypeNum == 9 then  return "crc_db_gbc.lua"                -- gbc_table
    elseif AppTypeNum == 10 then return "crc_db_gb.lua"                 -- gb_table
    elseif AppTypeNum == 13 then return "crc_db_32x.lua"                -- s32x_table
    elseif AppTypeNum == 14 then return "crc_db_md.lua"                 -- md_table
    elseif AppTypeNum == 15 then return "crc_db_sms.lua"                -- sms_table
    elseif AppTypeNum == 16 then return "crc_db_gg.lua"                 -- gg_table
    elseif AppTypeNum == 17 then return "crc_db_pce_tg16.lua"           -- tg16_table   
    elseif AppTypeNum == 19 then return "crc_db_pce_tg16.lua"           -- pce_table
    elseif AppTypeNum == 23 then return "crc_db_wswan_col.lua"          -- wswan_col_table
    elseif AppTypeNum == 24 then return "crc_db_wswan.lua"              -- wswan_table
    elseif AppTypeNum == 25 then return "crc_db_msx2.lua"               -- msx2_table
    elseif AppTypeNum == 26 then return "crc_db_msx1.lua"               -- msx1_table
    elseif AppTypeNum == 28 then return "crc_db_atari_7800.lua"         -- atari_7800_table
    elseif AppTypeNum == 29 then return "crc_db_atari_5200.lua"         -- atari_5200_table
    elseif AppTypeNum == 30 then return "crc_db_atari_2600.lua"         -- atari_2600_table
    elseif AppTypeNum == 31 then return "crc_db_atari_lynx.lua"         -- atari_lynx_table
    elseif AppTypeNum == 32 then return "crc_db_colecovision.lua"       -- colecovision_table
    elseif AppTypeNum == 33 then return "crc_db_vectrex.lua"            -- vectrex_table
    elseif AppTypeNum == 38 then return "crc_db_ngpc.lua"               -- ngpc_table

    -- elseif AppTypeNum == 0 then return "crc_db_games.lua"            -- homebrews_table
    -- elseif AppTypeNum == 1 then return "crc_db_games.lua"            -- games_table
    -- elseif AppTypeNum == 2 then  return "crc_db_psp.lua"             -- psp_table
    -- elseif AppTypeNum == 3 then  return "crc_db_psx.lua"             -- psx_table
    -- elseif AppTypeNum == 11 then return "crc_db_dreamcast.lua"       -- dreamcast_table
    -- elseif AppTypeNum == 12 then return "crc_db_sega_cd.lua"         -- sega_cd_table
    -- elseif AppTypeNum == 18 then return "crc_db_tgcd.lua"            -- tgcd_table
    -- elseif AppTypeNum == 20 then return "crc_db_pcecd.lua"           -- pcecd_table
    -- elseif AppTypeNum == 21 then return "crc_db_amiga.lua"           -- amiga_table
    -- elseif AppTypeNum == 22 then return "crc_db_c64.lua"             -- c64_table
    -- elseif AppTypeNum == 27 then return "crc_db_zxs.lua"             -- zxs_table
    -- elseif AppTypeNum == 34 then return "crc_db_fba.lua"             -- fba_table
    -- elseif AppTypeNum == 35 then return "crc_db_fba.lua"             -- mame_2003_plus_table
    -- elseif AppTypeNum == 36 then return "crc_db_mame_2000.lua"       -- mame_2000_table
    -- elseif AppTypeNum == 37 then return "crc_db_neogeo.lua"          -- neogeo_table
    -- elseif AppTypeNum == 39 then return "crc_db_psm.lua"             -- psm_table
    -- elseif AppTypeNum == 40 then return "crc_db_scummvm.lua"         -- scummvm_table
    -- elseif AppTypeNum == 41 then return "crc_db_pico8.lua"           -- pico8_table
    -- elseif AppTypeNum == 42 then return "crc_db_sysapps.lua"         -- sysapps_table
    -- elseif AppTypeNum == 43 then return "crc_db_nds.lua"             -- nds_table
    -- elseif AppTypeNum == 44 then return "crc_db_atari_st.lua"        -- atari_st_table
    -- elseif AppTypeNum == 45 then return "crc_db_dos.lua"             -- dos_table
    -- elseif AppTypeNum == 46 then return "crc_db_easyrpg.lua"         -- easyrpg_table
    -- elseif AppTypeNum == 47 then return "crc_db_n3ds.lua"             -- n3ds_table
    else
        return false
    end
end

function xAppNumLookup_Cover_Path_Local(AppTypeNum)
    if AppTypeNum == 0 then return SystemsToScan[2].localCoverPath       -- Homebrew
    elseif AppTypeNum == 2 then return SystemsToScan[3].localCoverPath   -- PSP
    elseif AppTypeNum == 3 then return SystemsToScan[4].localCoverPath   -- PSX
    else return SystemsToScan[AppTypeNum].localCoverPath                 -- All other systems
    end
end

function xAppNumLookup_Cover_Path_Online(AppTypeNum)
    if AppTypeNum == 0 then return SystemsToScan[2].onlineCoverPathSystem       -- Homebrew
    elseif AppTypeNum == 2 then return SystemsToScan[3].onlineCoverPathSystem   -- PSP
    elseif AppTypeNum == 3 then return SystemsToScan[4].onlineCoverPathSystem   -- PSX
    else return SystemsToScan[AppTypeNum].onlineCoverPathSystem                 -- All other systems
    end
end

function xAppNumLookup_Snap_Path_Local(AppTypeNum)
    if AppTypeNum == 0 then return SystemsToScan[2].localSnapPath       -- Homebrew
    elseif AppTypeNum == 2 then return SystemsToScan[3].localSnapPath   -- PSP
    elseif AppTypeNum == 3 then return SystemsToScan[4].localSnapPath   -- PSX
    else return SystemsToScan[AppTypeNum].localSnapPath                 -- All other systems
    end
end

function xAppNumLookup_Snap_Path_Online(AppTypeNum)
    if AppTypeNum == 0 then return SystemsToScan[2].onlineSnapPathSystem       -- Homebrew
    elseif AppTypeNum == 2 then return SystemsToScan[3].onlineSnapPathSystem   -- PSP
    elseif AppTypeNum == 3 then return SystemsToScan[4].onlineSnapPathSystem   -- PSX
    else return SystemsToScan[AppTypeNum].onlineSnapPathSystem                 -- All other systems
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
    elseif AppTypeNum == 44 then return "missing_cover_atari_st"
    elseif AppTypeNum == 45 then return "missing_cover_dos"
    elseif AppTypeNum == 46 then return "missing_cover_easyrpg"
    elseif AppTypeNum == 47 then return "missing_cover_3ds"
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
      function (c) return string.format ("%%%02X", string.byte(c)) end)
   str = string.gsub (str, " ", "%%20")
   str = string.gsub (str, "%(", "%%28")
   str = string.gsub (str, "%)", "%%29")
   return str
end

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

-- Write a small Adrenaline boot.bin setting as a 32-bit little-endian integer.
function AdrenalineBootInt32(value)
    value = tonumber(value) or 0
    return string.char(value, 0, 0, 0)
end

-- Boot values for both Adrenaline v7 (LMAN) and isage v8:

adrenaline_driver_boot_values = {
    ["NP9660"] = 0,
    ["INFERNO"] = 1,
    ["MARCH33"] = 2,
}

-- Convert RetroFlow's driver name to ABM's fixed raw boot.bin driver value.
function AdrenalineDriverToBootValue(def_driver)
    local driver = tostring(def_driver):upper()
    return adrenaline_driver_boot_values[driver] or adrenaline_driver_boot_values["NP9660"]
end

-- Mark boot.bin as using ABM's fixed driver mapping so ABM will not treat it as a legacy LMAN bubble. Not required but done for completeness.
function WriteAdrenalineBootDriverMarker(fp)
    fp:seek("set", 0x2C)
    fp:write("BBD1")
end

function AutoMakeBootBin(def_rom_location, def_driver, def_bin, def_plugins, def_speed, def_hm, def_nonpdrm, def_suspend)

    -- Driver and bin tables
    local drivers = { "ENABLE", "INFERNO", "MARCH33", "NP9660" } -- Default, INFERNO, MARCH33, NP9660
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
                -- Driver 
                fp:seek("set",0x04)
                fp:write(AdrenalineBootInt32(AdrenalineDriverToBootValue(driver)))
                WriteAdrenalineBootDriverMarker(fp)

                -- Bin Execute
                fp:seek("set",0x08)
                if bin == "EBOOT.BIN" then number_bin = 0
                elseif bin == "EBOOT.OLD" then number_bin = 1
                elseif bin == "BOOT.BIN" then number_bin = 2
                else
                    number_bin = 0
                end
                fp:write(AdrenalineBootInt32(number_bin))

                -- Suspend
                if suspend ~= 0 then
                    fp:seek("set", 0x18)
                    if suspend == 1 then number_suspend = 1        -- No
                    else
                        number_suspend = 0                         -- Yes
                    end
                    fp:write(AdrenalineBootInt32(number_suspend))
                end

                -- cpuspeed
                if speed ~= 0 then
                    fp:seek("set", 0x1C)
                    if speed == 1      then number_speed = 1       -- 20/10
                    elseif speed == 2  then number_speed = 2       -- 50/25
                    elseif speed == 3  then number_speed = 3       -- 75/37
                    elseif speed == 4  then number_speed = 4       -- 100/50
                    elseif speed == 5  then number_speed = 5       -- 111/55
                    elseif speed == 6  then number_speed = 6       -- 122/61
                    elseif speed == 7  then number_speed = 7       -- 133/66
                    elseif speed == 8  then number_speed = 8       -- 166/83
                    elseif speed == 9  then number_speed = 9       -- 200/100
                    elseif speed == 10 then number_speed = 10      -- 222/111
                    elseif speed == 11 then number_speed = 11      -- 266/133
                    elseif speed == 12 then number_speed = 12      -- 288/144
                    elseif speed == 13 then number_speed = 13      -- 300/150
                    elseif speed == 14 then number_speed = 14      -- 333/166
                    else
                        number_speed = 0                           -- Default
                    end
                    fp:write(AdrenalineBootInt32(number_speed))
                end

                -- Plugins
                if plugins ~= 0 then
                    fp:seek("set", 0x20)
                    if plugins == 1 then number_plugin = 1         -- Enable
                    elseif plugins == 2 then number_plugin = 2     -- Disable
                    else
                        number_plugin = 0                          -- Default
                    end
                    fp:write(AdrenalineBootInt32(number_plugin))
                end

                -- NonpDRM
                if nonpdrm ~= 0 then
                    fp:seek("set", 0x24)
                    if nonpdrm == 1 then number_nonpdrm = 1        -- Enable
                    elseif nonpdrm == 2 then number_nonpdrm = 2    -- Disable
                    else
                        number_nonpdrm = 0                         -- Default
                    end
                    fp:write(AdrenalineBootInt32(number_nonpdrm))
                end

                --HighMemory
                if hm ~= 0 then
                    fp:seek("set", 0x28)
                    if hm == 1 then number_hm = 1                  -- Enable
                    elseif hm == 2 then number_hm = 2              -- Disable
                    else
                        number_hm = 0                              -- Default
                    end
                    fp:write(AdrenalineBootInt32(number_hm))
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
                if setAdrPSButton == 0 then psbutton_number = 0
                elseif setAdrPSButton == 1 then psbutton_number = 1
                elseif setAdrPSButton == 2 then psbutton_number = 2
                else
                    psbutton_number = 0
                end
                fp:write(AdrenalineBootInt32(psbutton_number))

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

            -- Older RetroFlow/LMAN bubbles used incorrect driver labels:
            -- INFERNO launched NP9660, MARCH33 launched INFERNO, and NP9660 launched MARCH33.
            -- Migrate old driver selections to reflect correct driver name.
            -- Store a schema marker in launch_overrides.lua so this one-time migration cannot run again.
            -- To aid downgrading RetroFlow: Old overrides will be preserved in the backup file 'launch_overrides_before_abm_driver_fix.lua'.

            local schema = db_launch_overrides._schema or {}
            local migrate_adrenaline_drivers = schema.adrenaline_driver_labels == nil

            for i = #db_launch_overrides, 1, -1 do
                local v = db_launch_overrides[i]

                if v.driver ~= nil then
                    if migrate_adrenaline_drivers then
                        -- Preserve the real driver used by old LMAN-labelled bubbles.
                        if v.driver == 1 then
                            v.driver = 3 -- Old INFERNO label was actually NP9660
                        elseif v.driver == 2 then
                            v.driver = 1 -- Old MARCH33 label was actually INFERNO
                        elseif v.driver == 3 then
                            v.driver = 2 -- Old NP9660 label was actually MARCH33
                        end
                    end

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
                    if v.suspend == nil then
                        v.suspend = game_adr_suspend
                    end
                else
                    if v.core == 0 then
                        -- Remove retroarch entries with no overrides
                        table.remove(db_launch_overrides, i)
                        goto continue
                    end
                end

                table.insert(launch_overrides_table, v)

                ::continue::
            end

            if migrate_adrenaline_drivers then
                local backup_launch_overrides = "ux0:/data/RetroFlow/launch_overrides_before_abm_driver_fix.lua"
                if not System.doesFileExist(backup_launch_overrides) then
                    System.copyFile(db_Cache_launch_overrides, backup_launch_overrides)
                end

                launch_overrides_table._schema = schema
                launch_overrides_table._schema.adrenaline_driver_labels = "abm_fixed_v1"

                update_cached_table_launch_overrides()
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
    elseif System.doesDirExist("gro0:/app/" .. def_title) then -- Check gro0 instead
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

    check_app_installed("RETROLNCR", lang_lines.Please_install_RetroFlow_Adrenaline_Launcher .. "\n" .. lang_lines.The_VPK_is_saved_here .. "\n\nux0:/app/RETROFLOW/payloads/\nRetroFlow Adrenaline Launcher.vpk")
    if launch_check_app_installed == false then
        goto continue
    end

    -- Launch preflight check
    check_app_installed("PSPEMUCFW", lang_lines.Emulator_not_installed_Adrenaline)
    if launch_check_app_installed == false then
        goto continue
    end

    check_game_available(rom_location)

    if launch_check_game_available == true then
        prepare_for_launch()
        
        -- Check if game has custom launch overrides
        if #launch_overrides_table ~= nil then
            local key = find_game_table_pos_key(launch_overrides_table, (def_rom_title_id))
            if key ~= nil then
                -- Overrides found
                saved_driver = launch_overrides_table[key].driver
                if saved_driver == 1 then 
                    driver = "INFERNO"
                elseif saved_driver == 2 then
                    driver = "MARCH33"
                elseif saved_driver == 3 then
                    driver = "NP9660"
                else
                    driver = "NP9660"
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
                driver = "NP9660"
                bin = "EBOOT.BIN"
                plugins = 0
                speed = 0
                hm = 0
                nonpdrm = 0
                suspend = 0
            end
        else
            -- Table is empty, use default
            driver = "NP9660"
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

        -- Delete the old Adrenaline config file (isage config breaks adrenaline 7)
        if  System.doesFileExist(launch_dir_adr .. "data/config.bin") then
            System.deleteFile(launch_dir_adr .. "data/config.bin")
        end

        AutoMakeBootBin((def_rom_location), driver, bin, plugins, speed, hm, nonpdrm, suspend)

    end
    ::continue::
end

function launch_scummvm()
    -- Launch preflight check
    check_app_installed("VSCU00001", lang_lines.Emulator_not_installed_ScummVM)
    if launch_check_app_installed == false then
        goto continue
    end

    check_game_available(rom_location)

    if launch_check_game_available == true then
        prepare_for_launch()
        System.executeUri("psgm:play?titleid=VSCU00001" .. "&path=" .. rom_location .. "&game_id=" .. rom_title_id)
        System.exit()
    end
    ::continue::
end

function launch_pico8()
    -- Launch preflight check
    check_app_installed("FAKE00008", lang_lines.Emulator_not_installed_Pico8)
    if launch_check_app_installed == false then
        goto continue
    end

    check_game_available(rom_location)

    if launch_check_game_available == true then
        prepare_for_launch()
        System.executeUri("psgm:play?titleid=FAKE00008" .. "&param=" .. rom_location)
        System.exit()
    end
    ::continue::
end

function launch_retroarch(def_core_name)
    -- Launch preflight check
    check_app_installed("RETROVITA", lang_lines.Emulator_not_installed_Retroarch)
    if launch_check_app_installed == false then
        goto continue
    end

    check_game_available(rom_location)

    if launch_check_game_available == true then
        prepare_for_launch()

        local selected_core_path = get_core_for_launch(apptype, rom_location, def_core_name)

        if GameCoreOverrides[rom_location] == nil and #launch_overrides_table ~= nil then
            -- Legacy per-game overrides are still honoured.
            local key = nil
            for k, data in pairs(launch_overrides_table) do
                if data.game_path == rom_location then
                    key = k
                    break
                end
            end
            if key ~= nil and launch_overrides_table[key].core_path ~= nil then
                selected_core_path = launch_overrides_table[key].core_path
            end
        end

        if selected_core_path ~= nil then
            System.executeUri("psgm:play?titleid=RETROVITA" .. "&param=" .. selected_core_path .. "&param2=" .. rom_location)
            System.exit()
        else
            System.executeUri("psgm:play?titleid=RETROVITA" .. "&param=" .. (def_core_name) .. "&param2=" .. rom_location)
            System.exit()
        end
    end
    ::continue::
end

function emu4_uri_encode(value)
    value = tostring(value)
    value = value:gsub("\n", "\r\n")
    value = value:gsub("([^%w%-_%.~:/])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    return value
end

function launch_emu4vita(def_core_name)
    -- Launch preflight check
    check_app_installed("EMU4VPLUS", lang_lines.Emulator_not_installed_Emu4Vita)
    if launch_check_app_installed == false then
        goto continue
    end

    check_game_available(rom_location)

    if launch_check_game_available == true then
        prepare_for_launch()

        local selected_core_file = get_core_file_for_launch(apptype, rom_location)

        if selected_core_file ~= nil then
            selected_core_file = string.gsub(selected_core_file, "^eboot_", "")
            System.executeUri("psgm:play?titleid=EMU4VPLUS" .. "&core=" .. emu4_uri_encode(selected_core_file) .. "&rom=" .. emu4_uri_encode(rom_location))
            System.exit()
        end
    end
    ::continue::
end

function launch_retro_emulator(def_core_name)

    local core_id = get_core_id_for_launch(apptype, rom_location, def_core_name)
    local core_info = core_id and CoreDefinitions and CoreDefinitions[core_id]

    if core_info and core_info.emulator == "emu4vita" and enableEmu4Vita == true then
        launch_emu4vita(def_core_name)
    else
        launch_retroarch(def_core_name)
    end

end

function launch_DaedalusX64()
    -- Launch preflight check
    check_app_installed("DEDALOX64", lang_lines.Emulator_not_installed_DaedalusX64)
    if launch_check_app_installed == false then
        goto continue
    end

    check_game_available(rom_location)

    if launch_check_game_available == true then
        prepare_for_launch()
        System.executeUri("psgm:play?titleid=DEDALOX64" .. "&param=" .. rom_location)
        System.exit()
    end
    ::continue::
end

function launch_Flycast()
    -- Launch preflight check
    check_app_installed("FLYCASTDC", lang_lines.Emulator_not_installed_Flycast)
    if launch_check_app_installed == false then
        goto continue
    end

    check_game_available(rom_location)

    if launch_check_game_available == true then
        prepare_for_launch()
        System.executeUri("psgm:play?titleid=FLYCASTDC" .. "&param=" .. rom_location)
        System.exit()
    end
    ::continue::
end

function launch_DSVita()
    -- Launch preflight check
    check_app_installed("DSVITA000", lang_lines.Emulator_not_installed_DSVita)
    if launch_check_app_installed == false then
        goto continue
    end

    check_game_available(rom_location)

    if launch_check_game_available == true then
        prepare_for_launch()
        System.executeUri("psgm:play?titleid=DSVITA000" .. "&param=" .. rom_location)
        System.exit()
    end
    ::continue::
end

function launch_Azahar()
    -- Launch preflight check
    check_app_installed("AZAHARPSV", lang_lines.Emulator_not_installed_Azahar)
    if launch_check_app_installed == false then
        goto continue
    end

    check_game_available(rom_location)

    if launch_check_game_available == true then
        prepare_for_launch()
        System.executeUri("psgm:play?titleid=AZAHARPSV" .. "&param=" .. rom_location)
        System.exit()
    end
    ::continue::
end

function launch_EasyRPG()
    -- Launch preflight check
    check_app_installed("EASYRPG01", lang_lines.Emulator_not_installed_EasyRPG)
    if launch_check_app_installed == false then
        goto continue
    end

    check_game_available(rom_location)

    if launch_check_game_available == true then
        prepare_for_launch()
        System.executeUri("psgm:play?titleid=EASYRPG01" .. "&project-path=" .. rom_location)
        System.exit()
    end
    ::continue::
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

    -- Cartidge games
    local cartridge_flag = xCatLookup(showCat)[p].cartridge

    -- Launch preflight check
    if cartridge_flag == true then
        check_app_installed(def_titleid, lang_lines.Insert_cartridge_try_again)
    else
        check_app_installed(def_titleid, lang_lines.Game_not_installed_rescan)
    end

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
            -- Launch command unkown, open app without launching as normal launch causes error
            Extended.executeUriNPXS("psgm:play?titleid=" .. def_titleid)
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


-- CRC Download functions

    function crc_download_mode_path_local()
        if download_mode_covers == true then 
            return "cover_path_local"
        else
            return "snap_path_local"
        end
    end

    function crc_download_mode_path_online()
        if download_mode_covers == true then 
            return "cover_path_online"
        else
            return "snap_path_online"
        end
    end
    
    function crc_download_load_previous_crc_matches()

        -- Ensure user_crc_table exists globally
        if type(user_crc_table) ~= "table" then
            user_crc_table = {}
        end

        local user_crc_file = "ux0:/data/RetroFlow/TITLES/user_crc.lua"

        -- Check if the user_crc.lua file exists
        if System.doesFileExist(user_crc_file) then
            -- Load file and check for errors
            local importLuaFileError = importLuaFile(user_crc_file, user_crc_table)

            if importLuaFileError then
                -- File has errors, delete it
                System.deleteFile(user_crc_file)
            end
        end

        -- Ensure crc_results_table exists
        if type(crc_results_table) ~= "table" then
            crc_results_table = {}
        end

        -- Populate crc_results_table if user_crc_table is not empty
        if next(user_crc_table) ~= nil then
            for k, v in pairs(user_crc_table) do
                local crc_info = {}
                crc_info.game_path = tostring(k)
                crc_info.app_type = v.app_type
                crc_info.crc = v.crc
                crc_info.crc_name = v.crc_name
                table.insert(crc_results_table, crc_info)
            end
        else
        end
    end

    function crc32_chunks(file_path)
        local chunk_size = 16384
        local file = io.open(file_path, "rb")
        if not file then
            return nil
        end
        local crc32 = 0
        while true do
            local chunk = file:read(chunk_size)
            if not chunk then break end
            crc32 = Extended.crc32(chunk, crc32)
        end
        file:close()
        return string.format("%08x", crc32 % 0x100000000)
    end

    function crc_download_print_crc_results_table()
        -- Print CRC results to table, skipping duplicate game_path entries
        if #crc_results_table > 0 then
            table.sort(crc_results_table, function(a, b) return (a.game_path:lower() < b.game_path:lower()) end)
            local user_crc_lua_path = tostring(user_DB_Folder .. "user_crc.lua")

            local seen = {}
            local file, err = io.open(user_crc_lua_path, "w+")
                if not file then
                    Graphics.initBlend()
                    Screen.clear()
                    Graphics.debugPrint(10, 10, "io.open error: " .. tostring(err), Color.new(255, 255, 255))
                    Graphics.termBlend()
                    Screen.flip()
                    return
                end
            file:write("return" .. "\n" .. "{" .. "\n")
            for k, v in pairs(crc_results_table) do
                if not seen[v.game_path] then
                    file:write('\t["' .. v.game_path .. '"] =\n\t{\n\t\t["crc"] = "' .. v.crc .. '",\n\t\t["crc_name"] = "' .. v.crc_name .. '",\n\t\t["app_type"] = ' .. v.app_type .. ',\n\t},' .. "\n")
                    seen[v.game_path] = true
                end
            end
            file:write('}')
            file:close()
        else
        end
    end

    function crc_download_crc_matched_name(file)

        if xAppNumCRCLookupDB(file.app_type) == false then

            -- CRC unavailable for this system 
            return nil

        else

            -- Check is CRC is saved from previous scan in the user CRC table
            local crc_checked_before = false
            
            if #user_crc_table ~= nil then
                if user_crc_table[file.game_path] ~= nil 
                    and user_crc_table[file.game_path].crc ~= nil then
                    crc_checked_before = true
                else
                end
            else
            end


            if crc_checked_before == false then

                -- File has not been scanned before, is not in the user crc database

                -- CRC file available - Load CRC file for DB
                    local app_type = file.app_type
                    if not crc_db_tables[file.app_type] or next(crc_db_tables[file.app_type]) == nil then
                        local db_file = xAppNumCRCLookupDB(file.app_type)
                        if db_file then
                            local crc_db_path = "app0:/addons/crc/" .. db_file
                            if System.doesFileExist(crc_db_path) then
                                crc_db_tables[file.app_type] = dofile(crc_db_path)
                            else
                                crc_db_tables[file.app_type] = {}
                            end
                        else
                            crc_db_tables[file.app_type] = {}
                        end
                    end


                -- Get file CRC - Offset bytes for NES and N64, read whole file for everything else 

                if string.match(file.filename, "%.zip") then

                    -- Read contents of archive file
                    archive_contents = {}
                    archive_contents = Extended.archiveGetContents(tostring(file.game_path))

                    -- Check contents of zip file   
                    if not archive_contents or #archive_contents == 0 then
                        file.crc_result = "nil"

                    elseif #archive_contents == 1 then
                        -- If there is only one file, then check the CRC
                        local filename = archive_contents[1]  -- This is the filename string
                        System.extractFromZip(file.game_path, filename, "ux0:/data/RetroFlow/" .. filename)
                        local extracted_file = "ux0:/data/RetroFlow/" .. filename

                        if System.doesFileExist(extracted_file) then
                            if file.app_type == 5 then
                                -- N64 - Lookup header CRC
                                local f = assert(io.open(extracted_file, "rb"))
                                f:seek("cur", 0x10)
                                local bytes = f:read(4)
                                f:close()
                                if bytes then
                                    local bytestring = ""
                                    for b in string.gmatch(bytes, ".") do
                                        bytestring = bytestring .. string.format("%02X", string.byte(b))
                                    end
                                    file.crc_result = bytestring
                                else
                                    file.crc_result = "nil"
                                end
                            elseif file.app_type == 7 then
                                -- NES - Offset first 10 bytes
                                local f = io.open(extracted_file, "rb")
                                f:seek("cur", 0x10)
                                local tmp = f:read("*all")
                                f:close()
                                file.crc_result = tmp and string.format("%08x", Extended.crc32(tmp) % 0x100000000) or "nil"
                            else
                                -- All other types: CRC32 of whole file
                                file.crc_result = crc32_chunks(extracted_file) or "nil"
                            end
                            System.deleteFile(extracted_file)
                        else
                            file.crc_result = "nil"
                        end

                    else
                        file.crc_result = "nil"
                    end

                else

                    if file.app_type == 5 then
                        -- N64 - Lookup header CRC
                        local f = assert(io.open(file.game_path, "rb"))
                        f:seek("cur", 0x10)
                        local bytes = f:read(4)
                        f:close()
                        if bytes then
                            local bytestring = ""
                            for b in string.gmatch(bytes, ".") do
                                bytestring = bytestring .. string.format("%02X", string.byte(b))
                            end
                            file.crc_result = bytestring
                        else
                            file.crc_result = "nil"
                        end

                    elseif file.app_type == 7 then
                        -- NES - Offset first 10 bytes
                        local f = io.open(file.game_path, "rb")
                        f:seek("cur", 0x10)
                        local tmp = f:read("*all")
                        f:close()
                        file.crc_result = tmp and string.format("%08x", Extended.crc32(tmp) % 0x100000000) or "nil"

                    else
                        -- All other types: CRC32 of whole file
                        file.crc_result = crc32_chunks(file.game_path) or "nil"
                    end

                end

                -- Add to table for saving to user crc file
                    local crc_info = {}
                    crc_info.game_path = file.game_path
                    crc_info.filename = file.filename
                    crc_info.app_type = file.app_type
                    crc_info.crc = file.crc_result
                    crc_info.name = file.name

                    local crc_db_match = nil
                    if crc_db_tables[file.app_type] and crc_db_tables[file.app_type][file.crc_result] then
                        crc_db_match = crc_db_tables[file.app_type][file.crc_result].name
                    else
                        -- no crc found in database 
                    end

                    if crc_db_match == nil then
                        crc_info.crc_name = ""
                    else
                        crc_info.crc_name = crc_db_match
                        table.insert(crc_results_table, crc_info)
                    end
                    

            else
                -- File has been scanned before, use the CRC from the user crc database
                file.crc_result = user_crc_table[file.game_path].crc
            end

            -- Return name for downloading image now we have completed the crc lookups
            if crc_checked_before and user_crc_table[file.game_path] and user_crc_table[file.game_path].crc_name and user_crc_table[file.game_path].crc_name ~= "" then
                -- Old - Game matched previously
                return user_crc_table[file.game_path].crc_name
            elseif crc_db_tables[file.app_type] and crc_db_tables[file.app_type][file.crc_result] then
                -- New - With match
                return crc_db_tables[file.app_type][file.crc_result].name
            else
                -- New - No match
                return nil
            end

        end
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


fav_count_dirty = true
-- fav_count is a cached filtered view of files_table.
-- Set fav_count_dirty = true whenever something changes that could alter
-- which games should appear in Favorites, or their order/content.
-- refresh_fav_count_table() rebuilds the cache only when needed.



function is_game_system_visible(def_game)
    if def_game == nil then
        return false
    end

    local showcat = AppTypeToShowCat[def_game.app_type]
    if showcat == nil then
        return true
    end

    return is_category_visible(showcat) == true
end

function include_game_in_search_results(def_game)
    if def_game == nil or def_game.apptitle == nil then
        return false
    elseif def_game.hidden == true and showHidden == 0 then
        return false
    end

    return is_game_system_visible(def_game) == true
end

function game_matches_search(def_game, def_search, def_search_lc, def_search_uc, def_search_pc)
    if include_game_in_search_results(def_game) ~= true then
        return false
    end

    return string.match(def_game.apptitle, escape_pattern(def_search))
        or string.match(def_game.apptitle, escape_pattern(def_search_lc))
        or string.match(def_game.apptitle, escape_pattern(def_search_uc))
        or string.match(def_game.apptitle, escape_pattern(def_search_pc))
end

function create_fav_count_table(def_table_input)
    -- Note: showHomebrews = 1 -- On
    -- Note: showHidden = 0 -- 0 Off

    fav_count = {}
    for l, file in pairs((def_table_input)) do

        -- Fav, not hidden
        if file.favourite==true and file.hidden==false and is_game_system_visible(file) == true then
            table.insert(fav_count, file)

        -- Fav hidden
        elseif file.favourite==true and file.hidden==true and is_game_system_visible(file) == true then

            -- Show hidden is on
            if showHidden==1 then
                table.insert(fav_count, file)
            else
            end
        else
        end
    end
    fav_count_dirty = false
end

function refresh_fav_count_table()
    if fav_count_dirty == true then
        create_fav_count_table(files_table)
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

function include_game_in_visible_recent(def_recent_game)
    if def_recent_game == nil then
        return false
    elseif def_recent_game.hidden == true and showHidden == 0 then
        return false
    end

    return is_game_system_visible(def_recent_game) == true
end

function rebuild_visible_recently_played_table()
    recently_played_table = {}

    if recently_played_full_table == nil then
        recently_played_full_table = {}
    end

    for k, v in ipairs(recently_played_full_table) do
        if include_game_in_visible_recent(v) == true then
            table.insert(recently_played_table, v)
            v.icon = imgCoverTmp
            v.icon_path = v.icon_path
            v.apptitle = v.apptitle
        end
    end

end

function rebuild_visible_all_category_table()
    FileLoad = FileLoad or {}
    files_table_no_sysapps = {}
    return_table = {}

    for k, v in ipairs(folders_table or {}) do
        if type(v) == "table" then
            table.insert(return_table, v)
        end

        if type(v) == "table" and v.app_type ~= 42 and is_game_system_visible(v) == true then
            if v.ricon == nil then
                FileLoad[v] = nil
            end
            table.insert(files_table_no_sysapps, v)
        else
        end
    end

    files_table = return_table
end

function rebuild_mixed_category_visibility_tables()
    rebuild_visible_all_category_table()
    rebuild_visible_recently_played_table()
    fav_count_dirty = true
    refresh_fav_count_table()
    import_collections()
end

function sync_recently_played_full_from_visible()
    if recently_played_full_table == nil then
        recently_played_full_table = {}
    end

    for k, v in ipairs(recently_played_table) do
        local key = find_game_table_pos_key(recently_played_full_table, v.name)
        if key ~= nil then
            recently_played_full_table[key] = v
        else
            table.insert(recently_played_full_table, v)
        end
    end
end

function remove_recently_played_full_entry(def_name)
    if recently_played_full_table == nil then
        return
    end

    local key = find_game_table_pos_key(recently_played_full_table, def_name)
    if key ~= nil then
        table.remove(recently_played_full_table, key)
    end
end

function import_recently_played(def_force_import)

    if showRecentlyPlayed ~= 1 and def_force_import ~= true then
        return
    end

    recently_played_full_table = {}

    local file_over = System.openFile(cur_dir .. "/overrides.dat", FREAD)
    local filesize = System.sizeFile(file_over)
    local str = System.readFile(file_over, filesize)
    System.closeFile(file_over)

    -- RECENTLY PLAYED
    -- Forced imports are temporary/internal reads for Last Played startup and launch updates.
    if System.doesFileExist("ux0:/data/RetroFlow/recently_played.lua") then
        db_Cache_recently_played = "ux0:/data/RetroFlow/recently_played.lua"

            local db_recently_played = {}
            local importLuaFileError = importLuaFile(db_Cache_recently_played, db_recently_played)

            if importLuaFileError then
                -- File is corrupt, don't import it
            else

                for k, v in ipairs(db_recently_played) do

                    -- Various fixes on import
                    local app_table = xAppNumTableLookup(v.app_type)
                    local key = find_game_table_pos_key(app_table, v.name)

                    if key ~= nil then

                        local cached_table_entry = app_table[key]

                        -- Legacy fix - Add default app type to recently played table
                        if v.app_type_default ~= nil then
                            v.app_type_default = cached_table_entry.app_type_default
                        end

                        -- Legacy fix - Add hidden to recently played table
                        if v.hidden ~= nil then
                            v.hidden = cached_table_entry.hidden
                        end

                        -- Sync hidden with cached files
                        local cached_hidden = cached_table_entry.hidden
                        if cached_hidden == true and v.hidden == false then
                            v.hidden = true
                        end

                        -- Sync favourites with cached files
                        local cached_fav = cached_table_entry.favourite
                        if cached_fav == true and v.favourite == false then
                            v.favourite = true
                        end

                        -- Sync cover found with cached files
                        local cached_cover = cached_table_entry.cover
                        if cached_cover then
                            v.cover = cached_cover
                        end

                        -- Sync icon path with cached files
                        local cached_icon_path = cached_table_entry.icon_path
                        if cached_icon_path then
                            v.icon_path = cached_icon_path
                        end

                    else
                    end

                    -- Check rom exists
                    -- If file
                    if v.directory == false then
                        if System.doesFileExist(v.game_path) then
                            if include_game_in_recent(v.app_type, v.game_path, v.name) == true then
                                table.insert(recently_played_full_table, v)
                            end
                        end
                    else
                        -- Not file, is folder
                        if System.doesDirExist(v.game_path) then
                            if include_game_in_recent(v.app_type, v.game_path, v.name) == true then

                                if setScanCartridges == 0 and v.cartridge == true then
                                    -- ignore cartidges if scan cartridges is off
                                else
                                    table.insert(recently_played_full_table, v)
                                end             
                            end
                        end
                    end
                end

                -- apply_overrides_to_recently_played
                if System.doesFileExist(cur_dir .. "/overrides.dat") then
                    
                    for k, v in pairs(recently_played_full_table) do

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

    rebuild_visible_recently_played_table()

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

                local files_lookup = {}
                for i, file in ipairs(files_table) do
                    if file.name and file.app_type then
                        if files_lookup[file.name] == nil then
                            files_lookup[file.name] = {}
                        end
                        if files_lookup[file.name][file.app_type] == nil then
                            files_lookup[file.name][file.app_type] = file
                        end
                    end
                end

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
                                local matched_file = files_lookup[file.name] and files_lookup[file.name][file.app_type]
                                if matched_file ~= nil and is_game_system_visible(matched_file) == true then
                                        local collection_entry = {}
                                        for entry_key, entry_value in pairs(matched_file) do
                                            if entry_key ~= "ricon" then
                                                collection_entry[entry_key] = entry_value
                                            end
                                        end
                                        collection_entry.ricon = nil
                                        if file.custom_sort_order ~= nil then
                                            collection_entry.custom_sort_order = file.custom_sort_order
                                        end
                                        table.insert(_G[collection_file_num.table_name], collection_entry)
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
                            if System.doesDirExist(file.game_path) or System.doesFileExist(file.game_path) then
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

                if Adrenaline_roms == 5 then
                    for k, v in pairs(adr_partition_table) do

                        local game_folder = quickScanGames(tostring(v)  .. ":/pspemu/PSP/GAME", 2, true, ".pbp")
                        if next(game_folder) then
                            add_to_table(game_folder, QuickGameList.adrenaline_games_folder)
                        end
                        local iso_folder = quickScanGames(tostring(v)  .. ":/pspemu/ISO", 2, true, ".iso", ".cso", ".zso", ".dax")
                        if next(iso_folder) then
                            add_to_table(iso_folder, QuickGameList.adrenaline_iso_folder)
                        end

                    end
                else
                    local game_folder = quickScanGames(adr_partition  .. ":/pspemu/PSP/GAME", 2, true, ".pbp")
                    if next(game_folder) then
                        add_to_table(game_folder, QuickGameList.adrenaline_games_folder)
                    end

                    local iso_folder = quickScanGames(adr_partition  .. ":/pspemu/ISO", 2, true, ".iso", ".cso", ".zso", ".dax")
                    if next(iso_folder) then
                        add_to_table(iso_folder, QuickGameList.adrenaline_iso_folder)
                    end
                end

                QuickGameList.psx_retroarch = quickScanGames(SystemsToScan[4].romFolder, 1, true, ".pbp", ".cue", ".img", ".mdf", ".toc", ".cbn", ".m3u", ".ccd", ".pbp", ".chd")

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
                QuickGameList.dreamcast_table =         quickScanGames(SystemsToScan[11].romFolder, 1, true, ".cdi", ".gdi", ".chd")
                QuickGameList.sega_cd_table =           quickScanGames(SystemsToScan[12].romFolder, 1, true, ".chd", ".cue")
                QuickGameList.s32x_table =              quickScanGames(SystemsToScan[13].romFolder, 0)
                QuickGameList.md_table =                quickScanGames(SystemsToScan[14].romFolder, 0)
                QuickGameList.sms_table =               quickScanGames(SystemsToScan[15].romFolder, 0)
                QuickGameList.gg_table =                quickScanGames(SystemsToScan[16].romFolder, 0)
                QuickGameList.tg16_table =              quickScanGames(SystemsToScan[17].romFolder, 0)
                QuickGameList.tgcd_table =              quickScanGames(SystemsToScan[18].romFolder, 1, true, ".chd", ".cue")
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
                QuickGameList.atari_st_table =          quickScanGames(SystemsToScan[44].romFolder, 0)
                QuickGameList.dos_table =               quickScanGames(SystemsToScan[45].romFolder, 0, true, ".zip")
                QuickGameList.easyrpg_table =           quickScanGames(SystemsToScan[46].romFolder, 0)
                QuickGameList.n3ds_table =              quickScanGames(SystemsToScan[47].romFolder, 0)
                -- QuickGameList.psm_table =               System.listDirectory("ux0:/psm")

            -- PSM
                QuickGameList.psm_table =               System.listDirectory("ux0:/psm") or {}

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
                    
                    scan_scummvm_db = {}
                    for k, v in pairs (scummvm_ini_section) do
                        file = {}
                        file.gameid = ini.read("ux0:/data/scummvm/scummvm.ini",tostring(v),"gameid","exclude_game")
                        file.path = ini.read("ux0:/data/scummvm/scummvm.ini",tostring(v),"path","exclude_game")
                        if not string.match(file.gameid, "exclude_game") then
                            table.insert(scan_scummvm_db, file)
                            loading_tasks = loading_tasks + 1
                        end
                    end
                else
                    scan_scummvm_db = {}
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
    -- Import cached titles only when actually scanning
    import_cached_titles()
    
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
    n3ds_table = {}
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
    atari_st_table = {}
    dos_table = {}
    easyrpg_table = {}
    sysapps_table = {}
    recently_played_full_table = {}
    recently_played_table = {}
    search_results_table = {}
    fav_count = {}
    fav_count_dirty = true
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
    new_sfo_cache_table_vita = {}
    new_sfo_cache_adrenaline = {}

    -- SFO tools

        -- Fix bad sfo titles before saving - Force titles which are split over 2 lines onto 1 line (replacing /n alone doesn't work)
        function removeMultilines(str)
            local lines = str:gmatch("([^\r\n]+)\r?\n?")
            local output = lines()

            for line in lines do
                output = output .. " " .. line
            end
            return output
        end

        function cleanup_game_title(def_sfo_TITLE)
            local sfo_title = {}
            sfo_title = tostring((def_sfo_TITLE))
                :gsub("™","")
                :gsub(" ®","")
                :gsub("®","")
                :gsub("â€¢", " ")
                :gsub("\"+", "")
            sfo_title = removeMultilines(sfo_title)
            return sfo_title
        end
    

    -- SCAN FUNCTIONS

        function scan_Vita (def_table_name)
            if next(QuickGameList.games_table) == nil then
                else

                for i, file in ipairs(QuickGameList.games_table) do

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
                            if renamed_games_table and #renamed_games_table > 0 then
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
                                                    -- Try to decrypt and copy icon0
                                                    local image_copied = Extended.copyIconToAppmeta(file.path)
                                                    if image_copied == true then
                                                        img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"
                                                    end

                                                    if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                                                       img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
                                                        file.cover = true
                                                    else
                                                        img_path = "app0:/DATA/noimg.png" --blank grey
                                                        file.cover = false
                                                    end

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

                                                    -- Try to decrypt and copy icon0
                                                    local image_copied = Extended.copyIconToAppmeta(file.path)
                                                    if image_copied == true then
                                                        img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"
                                                    end

                                                    if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                                                       img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
                                                        file.cover = true
                                                    else
                                                        img_path = "app0:/DATA/noimg.png" --blank grey
                                                        file.cover = false
                                                    end
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

                                                    -- Try to decrypt and copy icon0
                                                    local image_copied = Extended.copyIconToAppmeta(file.path)
                                                    if image_copied == true then
                                                        img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"
                                                    end

                                                    if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                                                       img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
                                                        file.cover = true
                                                    else
                                                        img_path = "app0:/DATA/noimg.png" --blank grey
                                                        file.cover = false
                                                    end
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

                                                -- Try to decrypt and copy icon0
                                                local image_copied = Extended.copyIconToAppmeta(file.path)
                                                if image_copied == true then
                                                    img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"
                                                end

                                                if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                                                   img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
                                                    file.cover = true
                                                else
                                                    img_path = "app0:/DATA/noimg.png" --blank grey
                                                    file.cover = false
                                                end
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

                                                    -- Try to decrypt and copy icon0
                                                    local image_copied = Extended.copyIconToAppmeta(file.path)
                                                    if image_copied == true then
                                                        img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"
                                                    end

                                                    if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                                                       img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
                                                        file.cover = true
                                                    else
                                                        img_path = "app0:/DATA/noimg.png" --blank grey
                                                        file.cover = false
                                                    end
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
                                                    -- Try to decrypt and copy icon0
                                                    local image_copied = Extended.copyIconToAppmeta(file.path)
                                                    if image_copied == true then
                                                        img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"
                                                    end

                                                    if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                                                       img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
                                                        file.cover = true
                                                    else
                                                        img_path = "app0:/DATA/noimg.png" --blank grey
                                                        file.cover = false
                                                    end
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
                                                -- Try to decrypt and copy icon0
                                                local image_copied = Extended.copyIconToAppmeta(file.path)
                                                if image_copied == true then
                                                    img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"
                                                end

                                                if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                                                   img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
                                                    file.cover = true
                                                else
                                                    img_path = "app0:/DATA/noimg.png" --blank grey
                                                    file.cover = false
                                                end
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

        function scan_Vita_Cartridges (def_table_name)
            if next(QuickGameList.games_table) == nil then
                else

                -- SCAN FOR INSERTED GAME CARTRIDGE
                    function get_inserted_cartridge_titleId()
                        local app_dir = "gro0:/app"
                        if not System.doesDirExist(app_dir) then
                            return nil
                        end

                        local entries = System.listDirectory(app_dir)
                        if not entries then
                            return nil
                        end

                        for _, entry in pairs(entries) do
                            if entry.directory and entry.name ~= "." and entry.name ~= ".." and string.len(entry.name) == 9 then
                                local game_path = app_dir .. "/" .. entry.name
                                if System.doesFileExist(game_path .. "/eboot.bin") and System.doesFileExist(game_path .. "/sce_sys/param.sfo") then
                                    return entry.name
                                end
                            end
                        end

                        return nil
                    end

                    local detected_titleId = get_inserted_cartridge_titleId()

                -- SCAN APP.DB FOR VITA GAMES
                    db = Database.open("ur0:shell/db/app.db")

                    local query_string = "SELECT titleId, title FROM tbl_appinfo_icon WHERE titleId LIKE 'PCS%' AND titleId NOT LIKE 'PCSI%'"
                    local appdb_vita_results = Database.execQueryExtended(db, query_string)

                    Database.close(db)

                -- CREATE TABLE OF LIKELY CARTRIDGES

                    -- Compare Vita Games to "ux0:/app" folders to see in installed.
                    -- If missing, then likey to be a physical game cartridge
                    
                    local scanned_cartridge_games = {}

                    local installed_lookup = {}

                    for _, dir in pairs(QuickGameList.games_table) do
                        installed_lookup[dir.name] = true
                    end

                    for i, file in pairs(appdb_vita_results) do

                        if not installed_lookup[file.titleId] then
                            
                            -- Clean up the title
                            app_title = file.title:gsub("\n"," "):gsub("™",""):gsub(" ®",""):gsub("®","")

                            scanned_cartridge_games[file.titleId] = {
                                title = app_title,
                                titleid = file.titleId,
                                name = file.titleId,
                                cartridge = true,
                                cartridge_inserted = false
                            }

                            if file.titleId == detected_titleId then
                                scanned_cartridge_games[file.titleId].cartridge_inserted = true
                            end
                        end
                    end

                for i, file in pairs(scanned_cartridge_games) do

                    local custom_path, custom_path_id, app_type = nil, nil, nil

                    -- check if game is in the favorites list
                    if System.doesFileExist(cur_dir .. "/favorites.dat") then
                        if string.find(strFav, file.name,1,true) ~= nil then
                            file.favourite = true
                        else
                            file.favourite = false
                        end
                    end

                    file.game_path = ("gro0:/app/" .. file.name)

                    file.directory = true
                    file.filename = file.name
                    file.name = file.name
                    file.title = file.title
                    file.name_online = file.name
                    file.version = "UNK"
                    file.name_title_search = file.name
                    file.apptitle = file.title
                    file.date_played = 0
                    -- file.directory = true

                    -- Check for renamed game names
                    if renamed_games_table and #renamed_games_table > 0 then
                        local key = find_game_table_pos_key(renamed_games_table, file.titleId)
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
                    table.insert(games_table, file)

                    table.insert(folders_table, file)
                    file.app_type=1

                    -- Check for hidden game names
                    file.hidden = check_for_hidden_tag_on_scan(file.titleId, file.app_type)

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
                                

                    table.insert(files_table, count_of_systems, file.app_type)  

                    update_loading_screen_progress(loading_progress)
                    
                    --add blank icon to all
                    file.icon = imgCoverTmp
                    file.icon_path = img_path
                    
                    table.insert(files_table, count_of_systems, file.icon)
                    table.insert(files_table, count_of_systems, file.apptitle)
                end

                -- Store cartridge game references for runtime polling
                for titleid, game in pairs(scanned_cartridge_games) do
                    cartridge_games[titleid] = game
                end

            end

        end
        

        function scan_PSP_iso_folder (def_adrenaline_rom_location)

            if System.doesDirExist(def_adrenaline_rom_location) then

                if next(QuickGameList.adrenaline_iso_folder) ~= nil then

                    for i, file in ipairs(QuickGameList.adrenaline_iso_folder) do
                        -- local custom_path, custom_path_id, app_type, name, name_online, version, name_title_search = nil, nil, nil, nil, nil, nil, nil

                        if file.path and string.match(file.path, def_adrenaline_rom_location) then

                            local sfo_cache_key = file.name

                            -- Check if sfo is in cache
                            if sfo_scan_adrenaline_db_cached[sfo_cache_key] ~= nil then
                                -- Found
                                file.title = sfo_scan_adrenaline_db_cached[file.name].title or "UNK"
                                file.titleid = sfo_scan_adrenaline_db_cached[file.name].titleid or "UNK"
                                file.category = sfo_scan_adrenaline_db_cached[file.name].category or "UNK"
                                file.version = sfo_scan_adrenaline_db_cached[file.name].region or "UNK"
                                file.sfo_cache_key = sfo_cache_key

                                table.insert(new_sfo_cache_adrenaline, file)

                            else
                                -- SFO not cached: try to extract the SFO file safely
                                local sfo_read, sfo = pcall(Extended.extractSfoPSPX, file.path)

                                -- Error handling for bad sfo files
                                if sfo_read and sfo ~= nil and next(sfo) ~= nil then

                                    -- Cleanup game title
                                    sfo_title = cleanup_game_title(sfo.TITLE) or "UNK"
                                    
                                    file.title = sfo_title
                                    file.titleid = sfo.DISC_ID or "UNK"
                                    file.category = sfo.CATEGORY or "UNK"
                                    file.version = "UNK"
                                    file.sfo_cache_key = sfo_cache_key

                                    table.insert(new_sfo_cache_adrenaline, file)
                                else
                                    -- Fallback
                                    file.title = file.name
                                    file.titleid = "UNK"
                                    file.category = "UNK"
                                    file.region = "UNK"
                                    file.sfo_cache_key = sfo_cache_key

                                    table.insert(new_sfo_cache_adrenaline, file)
                                end

                            end


                            -- CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME, PBOOT.PBP PG 

                            -- PSP Official and PSP Homebrew only

                            if string.find(file.category, "UG", 1, true) or string.find(file.category, "MG", 1, true) or string.find(file.category, "EG", 1, true) then

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
                                if renamed_games_table and #renamed_games_table > 0 then
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
                            
                        end
                    end

                else
                end

            end
        end

        function scan_PSP_game_folder (def_adrenaline_rom_location)

            if System.doesDirExist(def_adrenaline_rom_location) then

                if next(QuickGameList.adrenaline_games_folder) ~= nil then

                    -- Pre-process: Group files by parent folder and apply filtering
                    local files_by_folder = {}
                    local keep_files = {} -- Set of files to keep (indexed by file index)
                    
                    -- Group files by parent folder
                    for i, file in ipairs(QuickGameList.adrenaline_games_folder) do
                        if file.path and string.match(file.path, def_adrenaline_rom_location) then
                            -- Extract root game folder relative to GAME directory
                            local relative = file.path:gsub("^" .. def_adrenaline_rom_location .. "/?", "")
                            local game_root = relative:match("^([^/]+)")

                            local parent_folder = game_root
                            if not files_by_folder[parent_folder] then
                                files_by_folder[parent_folder] = {}
                            end
                            table.insert(files_by_folder[parent_folder], {index = i, entry = file})
                        end
                    end
                    
                    -- Apply filtering per folder: keep only main eboot.pbp if multiple exist
                    for folder_name, folder_files in pairs(files_by_folder) do
                        if #folder_files > 1 then
                            -- Multiple files in this folder - apply filtering
                            local main_entry = nil
                            local shortest_depth = math.huge
                            
                            for _, item in ipairs(folder_files) do
                                local entry = item.entry
                                if entry.name:lower() == "eboot.pbp" then
                                    local depth = select(2, entry.path:gsub("/", ""))
                                    if depth < shortest_depth then
                                        shortest_depth = depth
                                        main_entry = item
                                    end
                                end
                            end
                            
                            -- Keep only the main entry if found
                            if main_entry then
                                -- keep only the best EBOOT
                                keep_files[main_entry.index] = true
                            else
                                -- No EBOOT found — keep only if single file
                                if #folder_files == 1 then
                                    keep_files[folder_files[1].index] = true
                                end
                            end
                        else
                            -- Only one file, keep it
                            keep_files[folder_files[1].index] = true
                        end
                    end

                    for i, file in ipairs(QuickGameList.adrenaline_games_folder) do
                        -- Skip if filtered out
                        if not keep_files[i] then
                            update_loading_screen_progress("PSP game folder")
                            goto continue_pbp_skipped
                        end
                        
                        if file.path and string.match(file.path, def_adrenaline_rom_location) then

                            -- Exclude DLC
                            if string.match(string.lower(file.name), "param.pbp") then
                                update_loading_screen_progress("PSP game folder")
                                goto continue_dlc_skipped

                            else

                                -- Get parent folder name
                                local last_foldername_in_path = file.path:gsub(".*/([^/]+)/[^/]+$", "%1") -- Gsub returns the parent folder name eg. SCUS94306

                                local sfo_cache_key = last_foldername_in_path

                                -- Check if sfo is in cache
                                if sfo_scan_adrenaline_db_cached[sfo_cache_key] ~= nil then
                                    -- Found
                                    local sfo_title = sfo_scan_adrenaline_db_cached[last_foldername_in_path].title or "UNK"
                                    file.titleid = sfo_scan_adrenaline_db_cached[last_foldername_in_path].titleid or "UNK"
                                    file.category = sfo_scan_adrenaline_db_cached[last_foldername_in_path].category or "UNK"
                                    file.version = sfo_scan_adrenaline_db_cached[last_foldername_in_path].region or "UNK"
                                    file.title = sfo_title
                                    file.sfo_cache_key = sfo_cache_key
                                else
                                    -- SFO not cached: try to extract the SFO file safely
                                    local sfo_read, sfo = pcall(Extended.extractSfoPSPX, file.path)

                                    -- Error handling for bad sfo files
                                    if sfo_read and sfo ~= nil and next(sfo) ~= nil then
                                        -- Cleanup game title
                                        sfo_title = cleanup_game_title(sfo.TITLE) or "UNK"

                                        if sfo.CATEGORY == "MG" then
                                            -- Homebrew - Use folder name for homebrew as many devs didn't bother creating proper sfo files
                                            file.title = last_foldername_in_path
                                        else
                                            file.title = sfo_title
                                        end

                                        file.titleid = sfo.DISC_ID or "UNK"
                                        file.category = sfo.CATEGORY or "UNK"
                                        file.version = "UNK"
                                        file.sfo_cache_key = sfo_cache_key

                                        if file.filename and file.title and file.titleid and file.region and file.path ~= nil then
                                            table.insert(new_sfo_cache_adrenaline, file)
                                        else
                                        end
                                    else
                                        -- Fallback, include anyway to prevent boot loop
                                        file.title = last_foldername_in_path
                                        file.titleid = "UNK"
                                        file.category = "UNK"
                                        file.version = "UNK"
                                        file.sfo_cache_key = sfo_cache_key

                                        table.insert(new_sfo_cache_adrenaline, file)
                                    end

                                end

                                -- CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME, PBOOT.PBP PG 

                                -- PSP Official and PSP Homebrew only

                                if string.find(file.category, "UG", 1, true) or string.find(file.category, "MG", 1, true) or string.find(file.category, "EG", 1, true) then

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

                                    if string.find(file.category, "MG", 1, true) then
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
                                    if renamed_games_table and #renamed_games_table > 0 then
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

                            end

                            ::continue_dlc_skipped::

                        end

                        ::continue_pbp_skipped::
                    end

                else
                end

            end
        end

        function scan_PS1_game_folder (def_adrenaline_rom_location)

            if System.doesDirExist(def_adrenaline_rom_location) then
              
                if next(QuickGameList.adrenaline_games_folder) ~= nil then
                
                    for i, file in ipairs(QuickGameList.adrenaline_games_folder) do
                        -- local custom_path, custom_path_id, app_type, name, name_online, version, name_title_search = nil, nil, nil, nil, nil, nil, nil

                        if file.path and string.match(file.path, def_adrenaline_rom_location) then

                            -- Get parent folder name
                            local last_foldername_in_path = file.path:gsub(".*/([^/]+)/[^/]+$", "%1") -- Gsub returns the parent folder name eg. SCUS94306

                            local sfo_cache_key = last_foldername_in_path

                            -- Check if sfo is in cache
                            if sfo_scan_adrenaline_db_cached[sfo_cache_key] ~= nil then
                                -- Found
                                file.title = sfo_scan_adrenaline_db_cached[last_foldername_in_path].title or "UNK"
                                file.titleid = sfo_scan_adrenaline_db_cached[last_foldername_in_path].titleid or "UNK"
                                file.category = sfo_scan_adrenaline_db_cached[last_foldername_in_path].category or "UNK"
                                file.version = sfo_scan_adrenaline_db_cached[last_foldername_in_path].region or "UNK"
                                file.sfo_cache_key = sfo_cache_key

                                table.insert(new_sfo_cache_adrenaline, file)

                            else
                                -- SFO not cached: try to extract the SFO file safely
                                local sfo_read, sfo = pcall(Extended.extractSfoPSPX, file.path)

                                -- Error handling for bad sfo files
                                if sfo_read and sfo ~= nil and next(sfo) ~= nil then

                                    -- Cleanup game title
                                    sfo_title = cleanup_game_title(sfo.TITLE) or "UNK"

                                    file.title = sfo_title or "UNK"
                                    file.titleid = sfo.DISC_ID or "UNK"
                                    file.category = sfo.CATEGORY or "UNK"
                                    file.version = "UNK"
                                    file.sfo_cache_key = sfo_cache_key

                                    table.insert(new_sfo_cache_adrenaline, file)
                                else
                                    -- Fallback, include anyway to prevent boot loop
                                    file.title = last_foldername_in_path
                                    file.titleid = "UNK"
                                    file.category = "UNK"
                                    file.version = "UNK"
                                    file.sfo_cache_key = sfo_cache_key

                                    table.insert(new_sfo_cache_adrenaline, file)
                                end


                            end

                            -- CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME, PBOOT.PBP PG 

                            -- PSX titles

                            if string.find(file.category, "ME", 1, true) then

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
                                if renamed_games_table and #renamed_games_table > 0 then
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



                        end
                    end

                else
                end

            end
        end


        function scan_Rom_PS1_RA_All(def, def_table_name)
            if System.doesDirExist(SystemsToScan[(def)].romFolder) then

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
                            
                            local sfo_cache_key = last_foldername_in_path

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
                                
                                -- Get the SFO info from sfo_scan_adrenaline_db_cached
                                local sfo_data = sfo_scan_adrenaline_db_cached[sfo_cache_key]

                                -- Check if sfo is in cache
                                if sfo_data ~= nil then
                                    -- Found
                                    file.title = sfo_data.title or last_foldername_in_path
                                    file.titleid = sfo_data.titleid or last_foldername_in_path
                                    file.category = sfo_data.category or "ME"
                                    file.version = sfo_data.region or "UNK"
                                    file.sfo_cache_key = sfo_cache_key

                                    table.insert(new_sfo_cache_adrenaline, file)
                                    
                                else
                                    -- SFO not cached: try to extract the SFO file safely
                                    local sfo_read, sfo = pcall(Extended.extractSfoPSPX, file.path)

                                    -- Error handling for bad sfo files
                                    if sfo_read and sfo ~= nil and next(sfo) ~= nil then

                                        -- Cleanup game title
                                        sfo_title = cleanup_game_title(sfo.TITLE) or "UNK"
                                        
                                        file.title = sfo_title or last_foldername_in_path
                                        file.titleid = sfo.DISC_ID or "UNK"
                                        file.category = sfo.CATEGORY or "UNK"
                                        file.version = "UNK"
                                        file.sfo_cache_key = sfo_cache_key

                                        table.insert(new_sfo_cache_adrenaline, file)
                                    else
                                        -- Fallback
                                        file.title = last_foldername_in_path
                                        file.titleid = "UNK"
                                        file.category = "UNK"
                                        file.version = "UNK"
                                        file.sfo_cache_key = sfo_cache_key

                                        table.insert(new_sfo_cache_adrenaline, file)
                                    end

                                end
                                -- Set specific fields for EBOOT.PBP games
                                file.filename = last_foldername_in_path
                                file.name = file.titleid  -- Use titleid for name (e.g., "SLUS00888")
                                file.name_online = file.titleid
                                file.name_title_search = file.title
                                file.apptitle = file.title
                                
                                -- Process as EBOOT.PBP game
                                processPS1Game(file, last_foldername_in_path, def, def_table_name, "PS1 RA EBOOT")
                            end
                            
                        -- Handle other .PBP files (not EBOOT.PBP)
                        elseif (string.match(file.name, "%.pbp") or string.match(file.name, "%.PBP")) and not file.name:lower():match("eboot.pbp") then
                            
                            local sfo_data = sfo_scan_adrenaline_db_cached[file.name]
                            local filename_no_extension = file.name:gsub("%.%w+$", "")

                            local sfo_cache_key = file.name

                            -- Check if sfo is in cache
                            if sfo_data ~= nil then
                                
                                file.title = sfo_data.title or filename_no_extension
                                file.titleid = sfo_data.titleid or filename_no_extension
                                file.category = sfo_data.category or "ME"
                                file.version = sfo_data.region or "UNK"
                                file.sfo_cache_key = sfo_cache_key

                                table.insert(new_sfo_cache_adrenaline, file)

                            else
                                -- SFO not cached: try to extract the SFO file safely
                                local sfo_read, sfo = pcall(Extended.extractSfoPSPX, file.path)

                                -- Error handling for bad sfo files
                                if sfo_read and sfo ~= nil and next(sfo) ~= nil then

                                    -- Cleanup game title
                                    sfo_title = cleanup_game_title(sfo.TITLE) or "UNK"
                                    
                                    file.title = sfo_title or filename_no_extension
                                    file.titleid = sfo.DISC_ID or "UNK"
                                    file.category = sfo.CATEGORY or "UNK"
                                    file.version = "UNK"
                                    file.sfo_cache_key = sfo_cache_key

                                    table.insert(new_sfo_cache_adrenaline, file)
                                else
                                    -- Fallback
                                    file.title = filename_no_extension
                                    file.titleid = "UNK"
                                    file.category = "UNK"
                                    file.version = "UNK"
                                    file.sfo_cache_key = sfo_cache_key

                                    table.insert(new_sfo_cache_adrenaline, file)
                                end                                    
                            end

                            -- Set specific fields for standalone PBP games
                            file.filename = filename_no_extension
                            file.name = file.titleid  -- Use titleid for name (e.g., "SCUS94244")
                            file.name_online = file.titleid
                            file.name_title_search = file.title
                            file.apptitle = file.title
                            
                            -- Process as standalone PBP game
                            processPS1Game(file, file.name, def, def_table_name, "PS1 RA PBP")

                            
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
            if renamed_games_table and #renamed_games_table > 0 then
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

                    file.game_path = file.path

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
                            ds_file:seek("set", 0x0C) -- move directly to 4-character game code
                            local game_code = ds_file:read(4)
                            ds_file:close()

                            local id = (game_code or "") -- e.g. "ABCD"
                            titleid = (id ~= "") and id or "UNK"
                        else
                            titleid = "UNK"
                        end
                        file.titleid = titleid
                        file.name_online = titleid

                    elseif (def) == 47 then

                        -- 3DS game, try to extract product code for artwork matching

                        local titleid = "UNK"

                        if string.match(file.name, "%.3ds") or string.match(file.name, "%.cci") then
                            local n3ds_file = io.open(file.game_path, "rb")

                            if n3ds_file then
                                n3ds_file:seek("set", 0x4156) -- move directly to 4-character game code 
                                local id = n3ds_file:read(4)
                                n3ds_file:close()

                                titleid = (id ~= "") and id or "UNK"
                            else
                                titleid = "UNK"
                            end

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
                    if renamed_games_table and #renamed_games_table > 0 then
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

                    file.game_path = file.path

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
                    if renamed_games_table and #renamed_games_table > 0 then
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
                        if renamed_games_table and #renamed_games_table > 0 then
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
                                if renamed_games_table and #renamed_games_table > 0 then
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

                    if System.doesDirExist(file.path) then

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
                        if renamed_games_table and #renamed_games_table > 0 then
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
                        
                    else
                    end

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
                            if renamed_games_table and #renamed_games_table > 0 then
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

            scan_Vita_Cartridges()

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
            Scan_Rom_Simple         (32, QuickGameList.colecovision_table,          colecovision_table)
            Scan_Rom_Simple         (33, QuickGameList.vectrex_table,               vectrex_table)
            Scan_Rom_DB_Lookup      (34, QuickGameList.fba_table,                   fba_table, "fba_2012.lua", "fba_2012.db")
            Scan_Rom_DB_Lookup      (35, QuickGameList.mame_2003_plus_table,        mame_2003_plus_table, "mame_2003_plus.lua", "mame_2003_plus.db")
            Scan_Rom_DB_Lookup      (36, QuickGameList.mame_2000_table,             mame_2000_table, "mame_2000.lua", "mame_2000.db")
            Scan_Rom_DB_Lookup      (37, QuickGameList.neogeo_table,                neogeo_table, "neogeo.lua", "neogeo.db")
            Scan_Rom_Simple         (38, QuickGameList.ngpc_table,                  ngpc_table)
            Scan_PSM_DB_Lookup      (39, QuickGameList.psm_table,                   psm_table, "psm.lua")
            Scan_Scummvm_DB_Lookup  (40, scummvm_table,                             "scummvm.lua", "scummvm_2026_03.db")
            Scan_Rom_Filter_Pico8   (41, QuickGameList.pico8_table,                 pico8_table)
            Scan_Sys_App_DB_Lookup  (42, QuickGameList.sysapps_table,               sysapps_table)
            Scan_Rom_Simple         (43, QuickGameList.nds_table,                   nds_table)
            Scan_Rom_Simple         (44, QuickGameList.atari_st_table,              atari_st_table)
            Scan_Rom_Simple         (45, QuickGameList.dos_table,                   dos_table)
            Scan_Rom_Simple         (46, QuickGameList.easyrpg_table,               easyrpg_table)
            Scan_Rom_Simple         (47, QuickGameList.n3ds_table,                  n3ds_table)
  
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
    table.sort(n3ds_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
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
    table.sort(atari_st_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(dos_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(easyrpg_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(sysapps_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)

    table.sort(recently_played_table, function(a, b) return (tonumber(a.date_played) > tonumber(b.date_played)) end)
    rebuild_visible_all_category_table()
    
    update_loading_screen_complete()

    -- CACHE ALL TABLES - PRINT AND SAVE
    print_sfo_cache_vita()
    print_sfo_cache_adrenaline()

    -- CLEANUP TABLES BEFORE CACHING
        local cleansed_table_count = 1

        function remove_uneccessary_keys_before_cache(def_table)
            if def_table then
                for i, file in ipairs(def_table) do
                    file.adrenaline_bubble = nil
                    file.subfolder = nil
                    file.icon = nil
                    file.size = nil
                    file.sfo_cache_key = nil
                end
            end
            cleansed_table_count = cleansed_table_count +1
        end

        while cleansed_table_count <= 49 do
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

                -- Don't import Vita cartridges if scan cartidges is off.
                if setScanCartridges == 0 then
                    if v.cartridge == true then
                        goto continue
                    end
                end

                -- Initialize cartridge insertion state on import
                if v.cartridge == true then
                    if v.titleid == last_inserted_titleid then
                        v.cartridge_inserted = true
                    else
                        v.cartridge_inserted = false
                    end
                    cartridge_games[v.titleid] = v
                end

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

                ::continue::

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
    n3ds_table = {}
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
    atari_st_table = {}
    dos_table = {}
    easyrpg_table = {}
    sysapps_table = {}
    recently_played_full_table = {}
    recently_played_table = {}
    search_results_table = {}
    fav_count = {}
    fav_count_dirty = true
    renamed_games_table = {}
    hidden_games_table = {}
    files_table_no_sysapps = {}
    

    import_renamed_games()
    import_hidden_games()

    -- Check Adrenaline modules. Unknown sets are warned about but PSP/PS1 games remain visible.
    Check_Adrenaline_Compatibility()

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
    import_cached_DB_tables("db_n3ds.lua", n3ds_table)
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
    import_cached_DB_tables("db_atari_st.lua", atari_st_table)
    import_cached_DB_tables("db_dos.lua", dos_table)
    import_cached_DB_tables("db_easyrpg.lua", easyrpg_table)
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
    table.sort(n3ds_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
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
    table.sort(atari_st_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(dos_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(easyrpg_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(sysapps_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)

    table.sort(recently_played_table, function(a, b) return (tonumber(a.date_played) > tonumber(b.date_played)) end)

    rebuild_visible_all_category_table()

    total_all = #files_table
    total_games = #games_table
    total_homebrews = #homebrews_table
    total_recently_played = #recently_played_table
    
    if adrenaline_compatibilty == true then
        -- Setup Adrenaline (CRC validation and VPK installation) - moved here to only run during scanning
        Setup_Adrenaline()
    end
    
    return return_table

end


function loadImage(img_path)
    imgTmp = Graphics.loadImage(img_path)
end

local image_loadable_cache = {}

local function is_loadable_image(img_path)
    if img_path == nil or img_path == "" then
        return false
    end

    if image_loadable_cache[img_path] ~= nil then
        return image_loadable_cache[img_path]
    end

    if not System.doesFileExist(img_path) then
        image_loadable_cache[img_path] = false
        return false
    end

    local success, image = pcall(Graphics.loadImage, img_path)
    if success and image then
        Graphics.freeImage(image)
        image_loadable_cache[img_path] = true
        return true
    end

    image_loadable_cache[img_path] = false
    return false
end

function LoadBackgroundTextureFromPath(def_pic_path)
    if def_pic_path == nil or def_pic_path == "" or not System.doesFileExist(def_pic_path) then
        Render.useTexture(modBackground, imgCustomBack)
        return false
    end

    -- Detach the old game background before freeing/replacing it to avoid Vita GPU texture crashes.
    Render.useTexture(modBackground, imgCustomBack)
    if backTmp ~= nil then
        Graphics.freeImage(backTmp)
        backTmp = nil
    end

    local success, loadedImage = pcall(Graphics.loadImage, def_pic_path)
    if success and loadedImage then
        backTmp = loadedImage
        Graphics.setImageFilters(backTmp, FILTER_LINEAR, FILTER_LINEAR)
        Render.useTexture(modBackground, backTmp)
        return true
    end

    Render.useTexture(modBackground, imgCustomBack)
    return false
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
        if cache_files_complete() == false then
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

apply_last_played_startup_category()



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