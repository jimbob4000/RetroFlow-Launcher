local db_Cache_Folder = "ux0:/data/RetroFlow/CACHE/"

local db_Cached_File_files = (db_Cache_Folder .. "db_files.lua")
local db_Cached_File_folders = (db_Cache_Folder .. "db_folders.lua")
local db_Cached_File_games = (db_Cache_Folder .. "db_games.lua")
local db_Cached_File_homebrews = (db_Cache_Folder .. "db_homebrews.lua")
local db_Cached_File_ports = (db_Cache_Folder .. "db_ports.lua")
local db_Cached_File_psp = (db_Cache_Folder .. "db_psp.lua")
local db_Cached_File_psx = (db_Cache_Folder .. "db_psx.lua")
local db_Cached_File_n64 = (db_Cache_Folder .. "db_n64.lua")
local db_Cached_File_snes = (db_Cache_Folder .. "db_snes.lua")
local db_Cached_File_nes = (db_Cache_Folder .. "db_nes.lua")
local db_Cached_File_gba = (db_Cache_Folder .. "db_gba.lua")
local db_Cached_File_gbc = (db_Cache_Folder .. "db_gbc.lua")
local db_Cached_File_gb = (db_Cache_Folder .. "db_gb.lua")
local db_Cached_File_md = (db_Cache_Folder .. "db_md.lua")
local db_Cached_File_sms = (db_Cache_Folder .. "db_sms.lua")
local db_Cached_File_gg = (db_Cache_Folder .. "db_gg.lua")
local db_Cached_File_mame = (db_Cache_Folder .. "db_mame.lua")
local db_Cached_File_amiga = (db_Cache_Folder .. "db_amiga.lua")
local db_Cached_File_tg16 = (db_Cache_Folder .. "db_tg16.lua")
local db_Cached_File_pce = (db_Cache_Folder .. "db_pce.lua")
local db_Cached_File_all_games = (db_Cache_Folder .. "db_all_games.lua")


-- PRINT ALL TABLES AT ONCE
function print_tables()

    -- Create directories - Database Cache
    System.createDirectory(db_Cache_Folder)

    -- Delete old files
    if System.doesFileExist(db_Cache_Folder .. "db_files.lua") then     System.deleteFile(db_Cache_Folder .. "db_files.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_folders.lua") then   System.deleteFile(db_Cache_Folder .. "db_folders.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_games.lua") then     System.deleteFile(db_Cache_Folder .. "db_games.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_homebrews.lua") then System.deleteFile(db_Cache_Folder .. "db_homebrews.lua") else end
	if System.doesFileExist(db_Cache_Folder .. "db_ports.lua") then     System.deleteFile(db_Cache_Folder .. "db_ports.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_psp.lua") then       System.deleteFile(db_Cache_Folder .. "db_psp.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_psx.lua") then       System.deleteFile(db_Cache_Folder .. "db_psx.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_snes.lua") then      System.deleteFile(db_Cache_Folder .. "db_snes.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_nes.lua") then       System.deleteFile(db_Cache_Folder .. "db_nes.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_gba.lua") then       System.deleteFile(db_Cache_Folder .. "db_gba.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_gbc.lua") then       System.deleteFile(db_Cache_Folder .. "db_gbc.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_gb.lua") then        System.deleteFile(db_Cache_Folder .. "db_gb.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_md.lua") then        System.deleteFile(db_Cache_Folder .. "db_md.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_sms.lua") then       System.deleteFile(db_Cache_Folder .. "db_sms.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_gg.lua") then        System.deleteFile(db_Cache_Folder .. "db_gg.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_mame.lua") then      System.deleteFile(db_Cache_Folder .. "db_mame.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_amiga.lua") then     System.deleteFile(db_Cache_Folder .. "db_amiga.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_tg16.lua") then      System.deleteFile(db_Cache_Folder .. "db_tg16.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_pce.lua") then       System.deleteFile(db_Cache_Folder .. "db_pce.lua") else end
    if System.doesFileExist(db_Cache_Folder .. "db_all_games.lua") then System.deleteFile(db_Cache_Folder .. "db_all_games.lua") else end

    -- START CREATE DATABASE CACHE

    local db_files = assert(io.open(db_Cached_File_files, "w"))
    printTable(files_table, db_files)
    db_files:close()

    local db_folders = assert(io.open(db_Cached_File_folders, "w"))
    printTable(folders_table, db_folders)
    db_folders:close()

    local db_games = assert(io.open(db_Cached_File_games, "w"))
    printTable(games_table, db_games)
    db_games:close()

    local db_homebrews = assert(io.open(db_Cached_File_homebrews, "w"))
    printTable(homebrews_table, db_homebrews)
    db_homebrews:close()
	
    local db_ports = assert(io.open(db_Cached_File_ports, "w"))
    printTable(ports_table, db_ports)
    db_ports:close()

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

    local db_md = assert(io.open(db_Cached_File_md, "w"))
    printTable(md_table, db_md)
    db_md:close()

    local db_sms = assert(io.open(db_Cached_File_sms, "w"))
    printTable(sms_table, db_sms)
    db_sms:close()

    local db_gg = assert(io.open(db_Cached_File_gg, "w"))
    printTable(gg_table, db_gg)
    db_gg:close()

    local db_mame = assert(io.open(db_Cached_File_mame, "w"))
    printTable(mame_table, db_mame)
    db_mame:close()

    local db_amiga = assert(io.open(db_Cached_File_amiga, "w"))
    printTable(amiga_table, db_amiga)
    db_amiga:close()

    local db_tg16 = assert(io.open(db_Cached_File_tg16, "w"))
    printTable(tg16_table, db_tg16)
    db_tg16:close()

    local db_pce = assert(io.open(db_Cached_File_pce, "w"))
    printTable(pce_table, db_pce)
    db_pce:close()

    local db_all_games = assert(io.open(db_Cached_File_all_games, "w"))
    printTable(all_games_table, db_all_games)
    db_all_games:close()

    -- END CREATE DATABASE CACHE

end


-- PRINT TABLES PER SYSTEM (Useful for when covers are downloaded)

function print_table_files()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_files.lua") then System.deleteFile(db_Cache_Folder .. "db_files.lua") else end
    local db_Cached_File_files = (db_Cache_Folder .. "db_files.lua")
    local db_files = assert(io.open(db_Cached_File_files, "w"))
    printTable(files_table, db_files)
    db_files:close()
end

function print_table_folders()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_folders.lua") then System.deleteFile(db_Cache_Folder .. "db_folders.lua") else end
    local db_Cached_File_folders = (db_Cache_Folder .. "db_folders.lua")
    local db_folders = assert(io.open(db_Cached_File_folders, "w"))
    printTable(folders_table, db_folders)
    db_folders:close()
end   

function print_table_games()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_games.lua") then System.deleteFile(db_Cache_Folder .. "db_games.lua") else end    
    local db_Cached_File_games = (db_Cache_Folder .. "db_games.lua")
    local db_games = assert(io.open(db_Cached_File_games, "w"))
    printTable(games_table, db_games)
    db_games:close()
end

function print_table_homebrews()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_homebrews.lua") then System.deleteFile(db_Cache_Folder .. "db_homebrews.lua") else end    
    local db_Cached_File_homebrews = (db_Cache_Folder .. "db_homebrews.lua")
    local db_homebrews = assert(io.open(db_Cached_File_homebrews, "w"))
    printTable(homebrews_table, db_homebrews)
    db_homebrews:close()
end

function print_table_ports()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_ports.lua") then System.deleteFile(db_Cache_Folder .. "db_ports.lua") else end    
    local db_Cached_File_ports = (db_Cache_Folder .. "db_ports.lua")
    local db_ports = assert(io.open(db_Cached_File_ports, "w"))
    printTable(ports_table, db_ports)
    db_ports:close()
end

function print_table_psp()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_psp.lua") then System.deleteFile(db_Cache_Folder .. "db_psp.lua") else end    
    local db_Cached_File_psp = (db_Cache_Folder .. "db_psp.lua")
    local db_psp = assert(io.open(db_Cached_File_psp, "w"))
    printTable(psp_table, db_psp)
    db_psp:close()
end

function print_table_psx()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_psx.lua") then System.deleteFile(db_Cache_Folder .. "db_psx.lua") else end    
    local db_Cached_File_psx = (db_Cache_Folder .. "db_psx.lua")
    local db_psx = assert(io.open(db_Cached_File_psx, "w"))
    printTable(psx_table, db_psx)
    db_psx:close()
end

function print_table_n64()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_n64.lua") then System.deleteFile(db_Cache_Folder .. "db_n64.lua") else end    
    local db_Cached_File_n64 = (db_Cache_Folder .. "db_n64.lua")
    local db_n64 = assert(io.open(db_Cached_File_n64, "w"))
    printTable(n64_table, db_n64)
    db_n64:close()
end

function print_table_snes()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_snes.lua") then System.deleteFile(db_Cache_Folder .. "db_snes.lua") else end    
    local db_Cached_File_snes = (db_Cache_Folder .. "db_snes.lua")
    local db_snes = assert(io.open(db_Cached_File_snes, "w"))
    printTable(snes_table, db_snes)
    db_snes:close()
end

function print_table_nes()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_nes.lua") then System.deleteFile(db_Cache_Folder .. "db_nes.lua") else end    
    local db_Cached_File_nes = (db_Cache_Folder .. "db_nes.lua")
    local db_nes = assert(io.open(db_Cached_File_nes, "w"))
    printTable(nes_table, db_nes)
    db_nes:close()
end

function print_table_gba()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_gba.lua") then System.deleteFile(db_Cache_Folder .. "db_gba.lua") else end    
    local db_Cached_File_gba = (db_Cache_Folder .. "db_gba.lua")
    local db_gba = assert(io.open(db_Cached_File_gba, "w"))
    printTable(gba_table, db_gba)
    db_gba:close()
end

function print_table_gbc()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_gbc.lua") then System.deleteFile(db_Cache_Folder .. "db_gbc.lua") else end    
    local db_Cached_File_gbc = (db_Cache_Folder .. "db_gbc.lua")
    local db_gbc = assert(io.open(db_Cached_File_gbc, "w"))
    printTable(gbc_table, db_gbc)
    db_gbc:close()
end

function print_table_gb()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_gb.lua") then System.deleteFile(db_Cache_Folder .. "db_gb.lua") else end    
    local db_Cached_File_gb = (db_Cache_Folder .. "db_gb.lua")
    local db_gb = assert(io.open(db_Cached_File_gb, "w"))
    printTable(gb_table, db_gb)
    db_gb:close()
end

function print_table_md()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_md.lua") then System.deleteFile(db_Cache_Folder .. "db_md.lua") else end    
    local db_Cached_File_md = (db_Cache_Folder .. "db_md.lua")
    local db_md = assert(io.open(db_Cached_File_md, "w"))
    printTable(md_table, db_md)
    db_md:close()
end

function print_table_sms()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_sms.lua") then System.deleteFile(db_Cache_Folder .. "db_sms.lua") else end    
    local db_Cached_File_sms = (db_Cache_Folder .. "db_sms.lua")
    local db_sms = assert(io.open(db_Cached_File_sms, "w"))
    printTable(sms_table, db_sms)
    db_sms:close()
end

function print_table_gg()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_gg.lua") then System.deleteFile(db_Cache_Folder .. "db_gg.lua") else end    
    local db_Cached_File_gg = (db_Cache_Folder .. "db_gg.lua")
    local db_gg = assert(io.open(db_Cached_File_gg, "w"))
    printTable(gg_table, db_gg)
    db_gg:close()
end

function print_table_mame()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_mame.lua") then System.deleteFile(db_Cache_Folder .. "db_mame.lua") else end    
    local db_Cached_File_mame = (db_Cache_Folder .. "db_mame.lua")
    local db_mame = assert(io.open(db_Cached_File_mame, "w"))
    printTable(mame_table, db_mame)
    db_mame:close()
end

function print_table_amiga()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_amiga.lua") then System.deleteFile(db_Cache_Folder .. "db_amiga.lua") else end    
    local db_Cached_File_amiga = (db_Cache_Folder .. "db_amiga.lua")
    local db_amiga = assert(io.open(db_Cached_File_amiga, "w"))
    printTable(amiga_table, db_amiga)
    db_amiga:close()
end

function print_table_tg16()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_tg16.lua") then System.deleteFile(db_Cache_Folder .. "db_tg16.lua") else end    
    local db_Cached_File_tg16 = (db_Cache_Folder .. "db_tg16.lua")
    local db_tg16 = assert(io.open(db_Cached_File_tg16, "w"))
    printTable(tg16_table, db_tg16)
    db_tg16:close()
end

function print_table_pce()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_pce.lua") then System.deleteFile(db_Cache_Folder .. "db_pce.lua") else end    
    local db_Cached_File_pce = (db_Cache_Folder .. "db_pce.lua")
    local db_pce = assert(io.open(db_Cached_File_pce, "w"))
    printTable(pce_table, db_pce)
    db_pce:close()
end

function print_table_all_games()
    -- Create directories - Database Cache
    if System.doesFileExist(db_Cache_Folder .. "db_all_games.lua") then System.deleteFile(db_Cache_Folder .. "db_all_games.lua") else end    
    local db_Cached_File_all_games = (db_Cache_Folder .. "db_all_games.lua")
    local db_all_games = assert(io.open(db_Cached_File_all_games, "w"))
    printTable(all_games_table, db_all_games)
    db_all_games:close()
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
