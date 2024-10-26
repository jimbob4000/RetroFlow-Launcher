local db_Cache_Folder = "ux0:/data/RetroFlow/CACHE/"

local db_Cached_File_files = (db_Cache_Folder .. "db_files.lua")
local db_Cached_File_folders = (db_Cache_Folder .. "db_folders.lua")
local db_Cached_File_all_games = (db_Cache_Folder .. "db_all_games.lua")

local db_Cached_File_games = (db_Cache_Folder .. "db_games.lua")
local db_Cached_File_homebrews = (db_Cache_Folder .. "db_homebrews.lua")
local db_Cached_File_psp = (db_Cache_Folder .. "db_psp.lua")
local db_Cached_File_psx = (db_Cache_Folder .. "db_psx.lua")
local db_Cached_File_n64 = (db_Cache_Folder .. "db_n64.lua")
local db_Cached_File_snes = (db_Cache_Folder .. "db_snes.lua")
local db_Cached_File_nes = (db_Cache_Folder .. "db_nes.lua")
local db_Cached_File_gba = (db_Cache_Folder .. "db_gba.lua")
local db_Cached_File_gbc = (db_Cache_Folder .. "db_gbc.lua")
local db_Cached_File_gb = (db_Cache_Folder .. "db_gb.lua")
local db_Cached_File_dreamcast = (db_Cache_Folder .. "db_dreamcast.lua")
local db_Cached_File_sega_cd = (db_Cache_Folder .. "db_sega_cd.lua")
local db_Cached_File_32x = (db_Cache_Folder .. "db_32x.lua")
local db_Cached_File_md = (db_Cache_Folder .. "db_md.lua")
local db_Cached_File_sms = (db_Cache_Folder .. "db_sms.lua")
local db_Cached_File_gg = (db_Cache_Folder .. "db_gg.lua")
local db_Cached_File_tg16 = (db_Cache_Folder .. "db_tg16.lua")
local db_Cached_File_tgcd = (db_Cache_Folder .. "db_tgcd.lua")
local db_Cached_File_pce = (db_Cache_Folder .. "db_pce.lua")
local db_Cached_File_pcecd = (db_Cache_Folder .. "db_pcecd.lua")
local db_Cached_File_amiga = (db_Cache_Folder .. "db_amiga.lua")
local db_Cached_File_c64 = (db_Cache_Folder .. "db_c64.lua")
local db_Cached_File_wswan_col = (db_Cache_Folder .. "db_wswan_col.lua")
local db_Cached_File_wswan = (db_Cache_Folder .. "db_wswan.lua")
local db_Cached_File_msx2 = (db_Cache_Folder .. "db_msx2.lua")
local db_Cached_File_msx1 = (db_Cache_Folder .. "db_msx1.lua")
local db_Cached_File_zxs = (db_Cache_Folder .. "db_zxs.lua")
local db_Cached_File_atari_7800 = (db_Cache_Folder .. "db_atari_7800.lua")
local db_Cached_File_atari_5200 = (db_Cache_Folder .. "db_atari_5200.lua")
local db_Cached_File_atari_2600 = (db_Cache_Folder .. "db_atari_2600.lua")
local db_Cached_File_atari_lynx = (db_Cache_Folder .. "db_atari_lynx.lua")
local db_Cached_File_colecovision = (db_Cache_Folder .. "db_colecovision.lua")
local db_Cached_File_vectrex = (db_Cache_Folder .. "db_vectrex.lua")
local db_Cached_File_fba = (db_Cache_Folder .. "db_fba.lua")
local db_Cached_File_mame_2003_plus = (db_Cache_Folder .. "db_mame_2003_plus.lua")
local db_Cached_File_mame_2000 = (db_Cache_Folder .. "db_mame_2000.lua")
local db_Cached_File_neogeo = (db_Cache_Folder .. "db_neogeo.lua")
local db_Cached_File_ngpc = (db_Cache_Folder .. "db_ngpc.lua")
local db_Cached_File_psm = (db_Cache_Folder .. "db_psm.lua")
local db_Cached_File_scummvm = (db_Cache_Folder .. "db_scummvm.lua")
local db_Cached_File_pico8 = (db_Cache_Folder .. "db_pico8.lua")
local db_Cached_File_sysapps = (db_Cache_Folder .. "db_sysapps.lua")
-- local db_Cached_File_favorites = (db_Cache_Folder .. "db_favorites.lua")


function delete_tables()
    -- List directory
    db_Cached_Files = System.listDirectory(db_Cache_Folder)

    -- Delete old files
    for i, file in pairs(db_Cached_Files) do
        if file.directory then
            System.deleteDirectory(db_Cache_Folder .. file.name)
        else
            System.deleteFile(db_Cache_Folder .. file.name)
        end
    end
end

-- PRINT ALL TABLES AT ONCE 
function print_tables()

    -- Create directories - Database Cache
    System.createDirectory(db_Cache_Folder)

    -- Delete old files
    delete_tables()
    
    -- START CREATE DATABASE CACHE

    -- local db_files = assert(io.open(db_Cached_File_files, "w"))
    -- printTable(files_table, db_files)
    -- db_files:close()

    -- local db_folders = assert(io.open(db_Cached_File_folders, "w"))
    -- printTable(folders_table, db_folders)
    -- db_folders:close()

    local db_games = assert(io.open(db_Cached_File_games, "w"))
    printTable(games_table, db_games)
    db_games:close()

    local db_homebrews = assert(io.open(db_Cached_File_homebrews, "w"))
    printTable(homebrews_table, db_homebrews)
    db_homebrews:close()

    local db_psp = assert(io.open(db_Cached_File_psp, "w"))
    printTable(psp_table, db_psp)
    db_psp:close()

    local db_psx = assert(io.open(db_Cached_File_psx, "w"))
    printTable(psx_table, db_psx)
    db_psx:close()

    local db_n64 = assert(io.open(db_Cached_File_n64, "w"))
    printTable(n64_table, db_n64)
    db_n64:close()

    local db_snes = assert(io.open(db_Cached_File_snes, "w"))
    printTable(snes_table, db_snes)
    db_snes:close()

    local db_nes = assert(io.open(db_Cached_File_nes, "w"))
    printTable(nes_table, db_nes)
    db_nes:close()

    local db_gba = assert(io.open(db_Cached_File_gba, "w"))
    printTable(gba_table, db_gba)
    db_gba:close()

    local db_gbc = assert(io.open(db_Cached_File_gbc, "w"))
    printTable(gbc_table, db_gbc)
    db_gbc:close()

    local db_gb = assert(io.open(db_Cached_File_gb, "w"))
    printTable(gb_table, db_gb)
    db_gb:close()

    local db_dreamcast = assert(io.open(db_Cached_File_dreamcast, "w"))
    printTable(dreamcast_table, db_dreamcast)
    db_dreamcast:close()

    local db_sega_cd = assert(io.open(db_Cached_File_sega_cd, "w"))
    printTable(sega_cd_table, db_sega_cd)
    db_sega_cd:close()

    local db_sega_32x = assert(io.open(db_Cached_File_32x, "w"))
    printTable(s32x_table, db_sega_32x)
    db_sega_32x:close()

    local db_md = assert(io.open(db_Cached_File_md, "w"))
    printTable(md_table, db_md)
    db_md:close()

    local db_sms = assert(io.open(db_Cached_File_sms, "w"))
    printTable(sms_table, db_sms)
    db_sms:close()

    local db_gg = assert(io.open(db_Cached_File_gg, "w"))
    printTable(gg_table, db_gg)
    db_gg:close()

    local db_tg16 = assert(io.open(db_Cached_File_tg16, "w"))
    printTable(tg16_table, db_tg16)
    db_tg16:close()

    local db_tgcd = assert(io.open(db_Cached_File_tgcd, "w"))
    printTable(tgcd_table, db_tgcd)
    db_tgcd:close()

    local db_pce = assert(io.open(db_Cached_File_pce, "w"))
    printTable(pce_table, db_pce)
    db_pce:close()

    local db_pcecd = assert(io.open(db_Cached_File_pcecd, "w"))
    printTable(pcecd_table, db_pcecd)
    db_pcecd:close()

    local db_amiga = assert(io.open(db_Cached_File_amiga, "w"))
    printTable(amiga_table, db_amiga)
    db_amiga:close()

    local db_c64 = assert(io.open(db_Cached_File_c64, "w"))
    printTable(c64_table, db_c64)
    db_c64:close()

    local db_wswan_col = assert(io.open(db_Cached_File_wswan_col, "w"))
    printTable(wswan_col_table, db_wswan_col)
    db_wswan_col:close()

    local db_wswan = assert(io.open(db_Cached_File_wswan, "w"))
    printTable(wswan_table, db_wswan)
    db_wswan:close()

    local db_msx2 = assert(io.open(db_Cached_File_msx2, "w"))
    printTable(msx2_table, db_msx2)
    db_msx2:close()

    local db_msx1 = assert(io.open(db_Cached_File_msx1, "w"))
    printTable(msx1_table, db_msx1)
    db_msx1:close()

    local db_zxs = assert(io.open(db_Cached_File_zxs, "w"))
    printTable(zxs_table, db_zxs)
    db_zxs:close()

    local db_atari_7800 = assert(io.open(db_Cached_File_atari_7800, "w"))
    printTable(atari_7800_table, db_atari_7800)
    db_atari_7800:close()

    local db_atari_5200 = assert(io.open(db_Cached_File_atari_5200, "w"))
    printTable(atari_5200_table, db_atari_5200)
    db_atari_5200:close()

    local db_atari_2600 = assert(io.open(db_Cached_File_atari_2600, "w"))
    printTable(atari_2600_table, db_atari_2600)
    db_atari_2600:close()

    local db_atari_lynx = assert(io.open(db_Cached_File_atari_lynx, "w"))
    printTable(atari_lynx_table, db_atari_lynx)
    db_atari_lynx:close()

    local db_colecovision = assert(io.open(db_Cached_File_colecovision, "w"))
    printTable(colecovision_table, db_colecovision)
    db_colecovision:close()

    local db_vectrex = assert(io.open(db_Cached_File_vectrex, "w"))
    printTable(vectrex_table, db_vectrex)
    db_vectrex:close()

    local db_fba = assert(io.open(db_Cached_File_fba, "w"))
    printTable(fba_table, db_fba)
    db_fba:close()

    local db_mame_2003_plus = assert(io.open(db_Cached_File_mame_2003_plus, "w"))
    printTable(mame_2003_plus_table, db_mame_2003_plus)
    db_mame_2003_plus:close()

    local db_mame_2000 = assert(io.open(db_Cached_File_mame_2000, "w"))
    printTable(mame_2000_table, db_mame_2000)
    db_mame_2000:close()

    local db_neogeo = assert(io.open(db_Cached_File_neogeo, "w"))
    printTable(neogeo_table, db_neogeo)
    db_neogeo:close()

    local db_ngpc = assert(io.open(db_Cached_File_ngpc, "w"))
    printTable(ngpc_table, db_ngpc)
    db_ngpc:close()

    local db_psm = assert(io.open(db_Cached_File_psm, "w"))
    printTable(psm_table, db_psm)
    db_psm:close()

    local db_scummvm = assert(io.open(db_Cached_File_scummvm, "w"))
    printTable(scummvm_table, db_scummvm)
    db_scummvm:close()

    local db_pico8 = assert(io.open(db_Cached_File_pico8, "w"))
    printTable(pico8_table, db_pico8)
    db_pico8:close()

    local db_sysapps = assert(io.open(db_Cached_File_sysapps, "w"))
    printTable(sysapps_table, db_sysapps)
    db_sysapps:close()

    -- local db_favorites = assert(io.open(db_Cached_File_favorites, "w"))
    -- printTable(favorites_table, db_favorites)
    -- db_favorites:close()

    -- END CREATE DATABASE CACHE

end


-- PRINT TABLES PER SYSTEM (Useful for when covers are downloaded)


function print_table_system(def_user_db_file, def_table_name)
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. (def_user_db_file)) then System.deleteFile(db_Cache_Folder .. (def_user_db_file)) else end
    local db_Cached_File_files = (db_Cache_Folder .. (def_user_db_file))
    local db_files = assert(io.open(db_Cached_File_files, "w"))
    printTable((def_table_name), db_files)
    db_files:close()
end

function print_table_recently_played()
    local db_Cached_File_recently_played = "ux0:/data/RetroFlow/recently_played.lua"

    -- Create directories - Database Cache
    if System.doesFileExist(db_Cached_File_recently_played) then System.deleteFile(db_Cached_File_recently_played) else end
    local db_recently_played = assert(io.open(db_Cached_File_recently_played, "w"))
    printTable(recently_played_table, db_recently_played)
    db_recently_played:close()
end

function print_table_recently_played_pre_launch()
    local db_Cached_File_recently_played = "ux0:/data/RetroFlow/recently_played.lua"

    -- Create directories - Database Cache
    if System.doesFileExist(db_Cached_File_recently_played) then System.deleteFile(db_Cached_File_recently_played) else end
    local db_recently_played = assert(io.open(db_Cached_File_recently_played, "w"))
    printTable(recently_played_pre_launch_table, db_recently_played)
    db_recently_played:close()
end

function print_table_renamed_games()
    local db_Cached_File_renamed_games = "ux0:/data/RetroFlow/renamed_games.lua"

    -- Create directories - Database Cache
    if System.doesFileExist(db_Cached_File_renamed_games) then System.deleteFile(db_Cached_File_renamed_games) else end
    local db_renamed_games = assert(io.open(db_Cached_File_renamed_games, "w"))
    printTable(renamed_games_table, db_renamed_games)
    db_renamed_games:close()
end

function print_table_launch_overrides()
    local db_Cached_File_launch_overrides = "ux0:/data/RetroFlow/launch_overrides.lua"

    -- Create directories - Database Cache
    if System.doesFileExist(db_Cached_File_launch_overrides) then System.deleteFile(db_Cached_File_launch_overrides) else end
    local db_launch_overrides = assert(io.open(db_Cached_File_launch_overrides, "w"))
    printTable(launch_overrides_table, db_launch_overrides)
    db_launch_overrides:close()
end

function print_table_hidden_games()
    local db_Cached_File_hidden_games = "ux0:/data/RetroFlow/hidden_games.lua"

    -- Create directories - Database Cache
    if System.doesFileExist(db_Cached_File_hidden_games) then System.deleteFile(db_Cached_File_hidden_games) else end
    local db_hidden_games = assert(io.open(db_Cached_File_hidden_games, "w"))
    printTable(hidden_games_table, db_hidden_games)
    db_hidden_games:close()
end

function print_table_rom_dirs(def_table_name)
    local db_Cached_File_rom_directories = "ux0:/data/RetroFlow/rom_directories.lua"

    -- Create directories - Database Cache
    if System.doesFileExist(db_Cached_File_rom_directories) then System.deleteFile(db_Cached_File_rom_directories) else end
    local db_rom_directories = assert(io.open(db_Cached_File_rom_directories, "w"))
    table.sort((def_table_name), function(a, b) return (a.v:lower() < b.v:lower()) end)
    printTable((def_table_name), db_rom_directories)
    db_rom_directories:close()
end

function print_table_collection_files(def_table_name)
    local db_Cached_File_collections = "ux0:/data/RetroFlow/collections.lua"

    -- Create directories - Database Cache
    if System.doesFileExist(db_Cached_File_collections) then System.deleteFile(db_Cached_File_collections) else end
    local db_collections = assert(io.open(db_Cached_File_collections, "w"))
    -- table.sort((def_table_name), function(a, b) return (a.v:lower() < b.v:lower()) end)
    printTable((def_table_name), db_collections)
    db_collections:close()
end

function print_table_collection(def_user_db_file, def_table_name)
    local db_Cached_Folder_collections = "ux0:/data/RetroFlow/COLLECTIONS/"
    if System.doesFileExist(db_Cached_Folder_collections .. (def_user_db_file)) then System.deleteFile(db_Cached_Folder_collections .. (def_user_db_file)) else end
    local db_Cached_File_collections = (db_Cached_Folder_collections .. (def_user_db_file))
    local db_file_collection = assert(io.open(db_Cached_File_collections, "w"))
    printTable((def_table_name), db_file_collection)
    db_file_collection:close()
end

function print_missing_covers()
    local db_Cached_File_missing_covers = "ux0:/data/RetroFlow/TITLES/missing_covers.lua"

    -- Create directories - Database Cache
    if System.doesFileExist(db_Cached_File_missing_covers) then System.deleteFile(db_Cached_File_missing_covers) else end
    local db_missing_covers = assert(io.open(db_Cached_File_missing_covers, "w"))
    printTable(missing_artwork_table, db_missing_covers)
    db_missing_covers:close()
end

function print_missing_snaps()
    local db_Cached_File_missing_snaps = "ux0:/data/RetroFlow/TITLES/missing_snaps.lua"

    -- Create directories - Database Cache
    if System.doesFileExist(db_Cached_File_missing_snaps) then System.deleteFile(db_Cached_File_missing_snaps) else end
    local db_missing_snaps = assert(io.open(db_Cached_File_missing_snaps, "w"))
    printTable(missing_artwork_table, db_missing_snaps)
    db_missing_snaps:close()
end

-- MAIN PRINT FUNCTION

--[[
Source and credit: https://gist.github.com/marcotrosi/163b9e890e012c6a460a

Notes:
A simple function to print tables or to write tables into files.
Great for debugging but also for data storage.
When writing into files the 'return' keyword will be added automatically,
so the tables can be loaded with 'dofile()' into a variable.
The basic datatypes table, string, number, boolean and nil are supported.
The tables can be nested and have number and string indices.
This function has no protection when writing files without proper permissions and
when datatypes other then the supported ones are used.
--]]

-- t = table
-- f = filename [optional]
function printTable(t, f)

   local function printTableHelper(obj, cnt)

      local cnt = cnt or 0

      if type(obj) == "table" then

         io.write("\n", string.rep("\t", cnt), "{\n")
         cnt = cnt + 1

         for k,v in pairs(obj) do

            if string.match(k, "ricon") then -- Custom edit - ricon removed (breaks single cover download)
            k = nil -- removes table key and entry
            else
               if type(k) == "string" then
                  io.write(string.rep("\t",cnt), '["'..k..'"]', ' = ')
               end

               if type(k) == "number" then
                  io.write(string.rep("\t",cnt), "["..k.."]", " = ")
               end
            end

            printTableHelper(v, cnt)
            io.write(",\n")
         end

         cnt = cnt-1
         io.write(string.rep("\t", cnt), "}")

      elseif type(obj) == "string" then
         io.write(string.format("%q", obj))

      else
         io.write(tostring(obj))
      end 
   end

   if f == nil then
      printTableHelper(t)
   else
      io.output(f)
      io.write("return")
      printTableHelper(t)
      io.output(io.stdout)
   end
end
