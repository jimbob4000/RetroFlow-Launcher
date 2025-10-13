-- ABOUT

    -- Two lua interpreters are used for RetroFlow.
    -- 'ONElua' is used in this file to scan PSP and PSX game and to extract the game information. Documentation: http://onelua.x10.mx/
    -- 'Lua Player Plus Vita' is used for the main app, rendering and all main functions. Documentation: http://onelua.x10.mx/vita/docs/en/


-- SETUP - INITIAL

    -- Debug mode
        local debug_mode = false -- set to true to view detailed scan progress 

    -- Create Directory: Main

        local cur_dir = "ux0:/data/RetroFlow/"
        files.mkdir ("ux0:/data/RetroFlow/")


    -- Create Directory: Titles to save scanned SFO information

        local titles_dir = "ux0:/data/RetroFlow/TITLES/"
        files.mkdir (titles_dir)    

    -- Filenames for scanned SFO files (PBP, ISO and CSO files scanned)

        local sfo_scan_isos_lua = "sfo_scan_isos.lua"
        local sfo_scan_games_lua = "sfo_scan_games.lua"
        local sfo_scan_retroarch_lua = "sfo_scan_retroarch.lua"
        local user_crc_lua = "user_crc.lua"
        local sfo_scans_onelua = "sfo_scans_onelua.lua"

    -- Setup font
        -- custom_font = font.load("DATA/font.ttf")
        -- if custom_font then font.setdefault(custom_font) end

    -- Check language

        local setLanguage = 0

        if files.exists (cur_dir .. "/config.dat") then
            setLanguage = tonumber(ini.read(cur_dir .. "/config.dat","Language","0"))
        else
            -- If not found then scan
            setLanguage = 1
        end

        local lang_lines = {}
        local lang_default = 
        {
        -- Scan progress
        ["Scanning_titles"] = "Scanning titles...",
        ["Scanning_games_ellipsis"] = "Scanning games...",
        ["Scan_complete"] = "Scan complete",
        ["Reloading_ellipsis"] = "Reloading...",
        -- Adrenaline install assets
        ["RETROLNCR_Install"] = "Installing RetroFlow Adrenaline Launcher vpk...",
        ["RETROLNCR_Installed"] = "RetroFlow Adrenaline Launcher has been installed.",
        ["ABB_Install"] = "Installing AdrBubbleBooter plugin...",
        ["ABB_Installed"] = "AdrBubbleBooter plugin has been installed...",
        ["ABB_Restart"] = "We need to restart your PS Vita.",
        ["Restart_Now"] = "Restart Now",
        ["Restart_Later"] = "Restart Later",
        }

        

        lang = "EN.lua"
        if setLanguage == 1 then
            lang = "EN_USA.lua"
        elseif setLanguage == 2 then
            lang = "DE.lua"
        elseif setLanguage == 3 then
            lang = "FR.lua"
        elseif setLanguage == 4 then
            lang = "IT.lua"
        elseif setLanguage == 5 then
            lang = "SP.lua"
        elseif setLanguage == 6 then
            lang = "PT.lua"
        elseif setLanguage == 7 then
            lang = "SW.lua"
        elseif setLanguage == 8 then
            lang = "RU.lua"
        elseif setLanguage == 9 then
            lang = "JA.lua"
        elseif setLanguage == 10 then
            lang = "CN_T.lua"
        elseif setLanguage == 11 then
            lang = "PL.lua"
        elseif setLanguage == 12 then
            lang = "NL.lua"
        elseif setLanguage == 13 then
            lang = "DA.lua"
        elseif setLanguage == 14 then
            lang = "NO.lua"
        elseif setLanguage == 15 then
            lang = "FI.lua"
        elseif setLanguage == 16 then
            lang = "TR.lua"
        elseif setLanguage == 17 then
            lang = "KO.lua"
        elseif setLanguage == 18 then
            lang = "CN_S.lua"
        elseif setLanguage == 19 then
            lang = "JA_ryu.lua"
        elseif setLanguage == 20 then
            lang = "HU.lua"
        elseif setLanguage == 21 then
            lang = "PT_BR.lua"
        else
            lang = "EN.lua"
        end

        -- Import lang file
        if files.exists("translations/" .. lang) then
            langfile = {}
            langfile = "translations/" .. lang
            -- lang_lines = {}
            lang_lines = dofile(langfile)
        else
            -- If missing use default EN table
            lang_lines = lang_default
        end


    -- Set colors for progress bar

        local green = color.new(0, 255, 0)
        local gradient_start = color.new(0, 0, 0, 150)
        local gradient_end = color.new(0, 0, 0, 0)  


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


-- COMMAND - Download missing artwork using CRC

    if files.exists(titles_dir .. "/" .. "missing_covers.lua") or files.exists(titles_dir .. "/" .. "missing_snaps.lua") then
        dofile("addons/download_artwork.lua")
    end


-- COMMAND - EXTRACT IMAGES: PSP ISO Backgrounds 

    -- Check for temporary file from vita lua, if it exists then extract images
    if files.exists(titles_dir .. "/" .. "onelua_extract_psp.dat") then

        -- Delete file to prevent looping into image extraction on restart
        files.delete(titles_dir .. "/" .. "onelua_extract_psp.dat")

        -- Create Directories: Backgrounds and PSP

            local backgrounds_dir = "ux0:/data/RetroFlow/BACKGROUNDS/"
            files.mkdir (backgrounds_dir)

            local backgrounds_psp_dir = "ux0:/data/RetroFlow/BACKGROUNDS/Sony - PlayStation Portable/"
            files.mkdir (backgrounds_psp_dir)

        -- Import PSP iso table

            if files.exists(titles_dir .. "/" .. sfo_scan_isos_lua) then
                cached_table_iso = safe_dofile(titles_dir .. "/" .. sfo_scan_isos_lua)
            else
                cached_table_iso = {}
            end

            image_extraction_table = {}
            
            for k, v in pairs(cached_table_iso) do
                file = {}
                file.name = k
                file.filename = k
                file.title = v.title
                file.titleid = v.titleid
                file.region = v.region
                file.path = v.path
                table.insert(image_extraction_table, file)

            end


            table.sort(image_extraction_table, function(a, b) return (a.title:lower() < b.title:lower()) end)

        -- Extract images from table

            image_total = #image_extraction_table
            local extracted = 0

            for k, v in pairs(image_extraction_table) do


                -- If image already exists, dont display it
                if files.exists (backgrounds_psp_dir .. v.titleid .. ".png") then

                    -- Extract image
                    -- local pic1 = nil

                    -- pic1 = image.load(backgrounds_psp_dir .. v.titleid .. ".png")

                    -- -- Draw image
                    -- image.resize(pic1, 960, 544)
                    -- image.blit(pic1, 0, 0)

                    -- -- Add dark overlay
                    -- draw.fillrect (0,0,960,544,color.new(0,0,0, 150))
                    -- draw.gradrect (0, 0, 960, 150, gradient_start, gradient_end, 0)

                    -- Update progress and reset screen
                    extracted = extracted + 1
                    screen.print(10,10,tostring(v.title))
                    screen.print(10,30,math.floor((extracted/image_total)*100).."%")
                    draw.fillrect(0,534,((extracted/image_total)*960),10,green)
                    screen.flip()

                    -- Prevent vita from suspending - the screen can dim and turn off
                    power.tick(__POWER_TICK_SUSPEND)

                else

                    -- Extract image
                    
                    -- Image not found, try and extract
                    local pic1 = game.getpic1(v.path)

                    if pic1 then

                        -- Draw image
                        image.resize(pic1, 960, 544)
                        image.blit(pic1, 0, 0)

                        -- Add dark overlay
                        draw.fillrect (0,0,960,544,color.new(0,0,0, 150))
                        draw.gradrect (0, 0, 960, 150, gradient_start, gradient_end, 0)

                        -- Save
                        image.save(pic1, backgrounds_psp_dir .. v.titleid .. ".png", 1)

                        -- Update progress and reset screen
                        extracted = extracted + 1
                        screen.print(10,10,tostring(v.title))
                        screen.print(10,30,math.floor((extracted/image_total)*100).."%")
                        draw.fillrect(0,534,((extracted/image_total)*960),10,green)
                        screen.flip()

                        -- Unload image
                        pic1 = nil
                        collectgarbage("collect")
                        barblit=false

                        -- Prevent vita from suspending - the screen can dim and turn off
                        power.tick(__POWER_TICK_SUSPEND)

                    else
                        -- No image
                        -- Update progress and reset screen
                        extracted = extracted + 1
                        screen.print(10,10,tostring(v.title))
                        screen.print(10,30,math.floor((extracted/image_total)*100).."%")
                        draw.fillrect(0,534,((extracted/image_total)*960),10,green)
                        screen.flip()

                        -- Prevent vita from suspending - the screen can dim and turn off
                        power.tick(__POWER_TICK_SUSPEND)

                    end

                end

                

            end

            -- Turn on the vita display once the scan is complete
            power.display(1)

            -- Launch the main app
            os.execute("app0:eboot.bin")
            dofile("app0:index.lua")

        else
        end



    -- Import cached SF0 files - To check for new games

        if files.exists(titles_dir .. "/" .. sfo_scan_isos_lua) then
            cached_table_iso = safe_dofile(titles_dir .. "/" .. sfo_scan_isos_lua)
        else
            cached_table_iso = {}
        end

        if files.exists(titles_dir .. "/" .. sfo_scan_games_lua) then
            cached_table_games = safe_dofile(titles_dir .. "/" .. sfo_scan_games_lua)
        else
            cached_table_games = {}
        end

        if files.exists(titles_dir .. "/" .. sfo_scan_retroarch_lua) then
            cached_table_retroarch = safe_dofile(titles_dir .. "/" .. sfo_scan_retroarch_lua)
        else
            cached_table_retroarch = {}
        end

        if files.exists(titles_dir .. "/" .. sfo_scans_onelua) then
            cached_table_sfo_scans_onelua = safe_dofile(titles_dir .. "/" .. sfo_scans_onelua)
        else
            cached_table_sfo_scans_onelua = {}
        end

        -- Table for storing all sfo scans so the can be read as a permanent cache for faster scanning
        new_sfo_scans_onelua = {}


    -- Get RetroArch user defined PS1 directory to scan - Get from file, or use default if not found

        if files.exists("ux0:/data/RetroFlow/rom_directories.lua") then
            -- File exists, import user rom dirs
            db_romdir = "ux0:/data/RetroFlow/rom_directories.lua"
            romUserDir = {}
            romUserDir = safe_dofile(db_romdir)

            -- File not empty
            if romUserDir ~= nil then 
                if romUserDir.PlayStation == nil then
                    -- Legacy fix, if playstation retroarch missing, use default
                    romUserDir.PlayStation = "ux0:/data/RetroFlow/ROMS/Sony - PlayStation - RetroArch"
                else
                    -- Has a directory selected, do nothing
                end
            end
        else
        end


-- SETUP - LOADING SCREEN


    -- PRE-SCAN folders to get count of loading tasks and to iterate over tables later to get sfo information

        -- Setup for scanning

            local loading_tasks = 0
            local sub_dir_count = 0
            local loading_progress = 0

            local QuickGameList = {
                adrenaline_games_folder = {},
                adrenaline_iso_folder = {},
                psx_retroarch = {},
            }

            adr_partition_table = {
                [1] = "ux0",
                [2] = "ur0",
                [3] = "imc0",
                [4] = "xmc0",
                [5] = "uma0",
            }


        -- Function: Quick scan games

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
                    
                    local files = files.list(path)
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

        -- Command: Quick scan games

            local function add_to_table (def_input_table, def_output_table)
                if next(def_input_table) ~= nil then
                    for i, entry in ipairs(def_input_table) do
                        table.insert(def_output_table, entry)
                    end
                end
            end
            
            -- Scan all adrenaline partitions
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

            -- Scan retroarch folder
                QuickGameList.psx_retroarch = quickScanGames(tostring((romUserDir.PlayStation)), 1, true, ".pbp")

            -- Get total count of QuickGameList loading screen
                for k, v in pairs(QuickGameList) do
                    if type(v) == "table" then
                        loading_tasks = loading_tasks + #v
                    end
                end


    -- Setup screen and assets

        if setLanguage == 10 then -- Chinese (Traditional)
            custom_font = font.load("DATA/font-NotoSansCJKtc-Regular.otf")
            font_size = 1.2
        elseif setLanguage == 17 then -- Korean 
            custom_font = font.load("DATA/font-NotoSansCJKkr-Regular-Slim.otf")
            font_size = 1.2
        elseif setLanguage == 18 then -- Chinese (Simplified)
            custom_font = font.load("DATA/font-NotoSansCJKsc-Regular-Slim.otf")
            font_size = 1.2
        else
            custom_font = font.load("DATA/font-SawarabiGothic-Regular.ttf")
            font_size = 1
        end

        loading_screen = image.load("DATA/loading.png")
        if loading_screen then loading_screen:blit(0, 0) end
        screen.flip() -- Show Buff

        local white = color.new(255,255,255)
        local black = color.new(0,0,0)
        local loading_bar_bg = color.new(255,255,255,50)


    function update_loading_screen_progress()
        if loading_screen then loading_screen:blit(0, 0) end

        if debug_mode == true then
            screen.print(custom_font, 480, 450, sfo_title, font_size, white, black, __ACENTER) -- Scanning titles...
        else
            screen.print(custom_font, 480, 450, lang_lines.Scanning_titles, font_size, white, black, __ACENTER) -- Scanning titles...
        end

        loading_progress = loading_progress + 1

        loading_bar_width = 300
        loading_percent = (loading_progress/loading_tasks)*100

        -- Set max width
        if loading_percent >= 100 then 
            loading_percent = 100
        end
    
        -- Progress bar background
        draw.fillrect(330,490,loading_bar_width,6,loading_bar_bg)

        -- Progress bar percent
        draw.fillrect(330,490,((loading_bar_width/100)*loading_percent),6,white)


        screen.flip()
    end

    function update_debug_message(def)

        if debug_mode == true then
            if loading_screen then loading_screen:blit(0, 0) end

            screen.print(custom_font, 480, 450, (def), font_size, white, black, __ACENTER) -- Scanning titles...
            
            loading_progress = loading_progress + 1

            loading_bar_width = 300
            loading_percent = (loading_progress/loading_tasks)*100

            -- Set max width
            if loading_percent >= loading_bar_width then
                loading_percent = loading_bar_width
            end
        
            -- Progress bar background
            draw.fillrect(330,490,loading_bar_width,6,loading_bar_bg)

            -- Progress bar percent
            draw.fillrect(330,490,((loading_bar_width/100)*loading_percent),6,white)


            screen.flip()
        else
        end
    end

    function print_loading_complete() 
        if loading_screen then loading_screen:blit(0, 0) end

        screen.print(custom_font, 480, 450, lang_lines.Reloading_ellipsis, font_size, white, black, __ACENTER) -- Reloading...

        loading_progress = loading_tasks -- set to tasks to move to 100% if stuck)

        loading_bar_width = 300
        loading_percent = (loading_progress/loading_tasks)*100

        -- Progress bar background
        draw.fillrect(330,490,loading_bar_width,6,loading_bar_bg)

        -- Progress bar percent
        draw.fillrect(330,490,((loading_bar_width/100)*loading_percent),6,white)

        screen.flip()

        os.delay(1000) -- Wait for a second
    end


-- FUNCTION SAVE 
    
    -- Fix bad sfo titles before saving - Force titles which are split over 2 lines onto 1 line (replacing /n alone doesn't work)
    function removeMultilines(str)
        local lines = str:gmatch("([^\r\n]+)\r?\n?")
        local output = lines()

        for line in lines do
            output = output .. " " .. line
        end
        return output
    end

    -- Export scanned SFO information to cached lua files (files imported as tables later in 'index.lua' for game info)
    function write_ini(pathini, tbl)
        file = io.open(pathini, "w+")
        file:write("return" .. "\n" .. "{" .. "\n")
        for k, v in pairs((tbl)) do
            -- file:write('["' .. v.filename .. '"] = {title = "' .. v.title .. '", titleid = "' .. v.titleid .. '", region = "' .. v.region .. '", path = "' .. v.path .. '"},' .. "\n")
            file:write('["' .. v.filename .. '"] = {title = "' .. (v.title or "UNK") .. '", titleid = "' .. (v.titleid or "UNK") .. '", category = "' .. (v.category or "UNK") .. '", region = "' .. (v.region or "UNK") .. '", path = "' .. (v.path or "") .. '"},' .. "\n")

        end
        file:write('}')
        file:close()
    end


-- FUNCTION SCAN 

    function cleanup_game_title(def_sfo_TITLE)
        local sfo_title = {}
        -- sfo_title = tostring((def_sfo_TITLE)):gsub("™",""):gsub("â„¢",""):gsub(" ®",""):gsub("â€¢",""):gsub("Â®",""):gsub('[Â]',''):gsub('[®]',''):gsub('[â]',''):gsub('[„]',''):gsub('[¢]',''):gsub("„","")
        sfo_title = tostring((def_sfo_TITLE)):gsub("™",""):gsub(" ®",""):gsub("®",""):gsub("\"+", "")

        sfo_title = removeMultilines(sfo_title)
        return sfo_title
    end

    -- Scan Function - ISO folders

        function scan_iso_folder()

            if next(QuickGameList.adrenaline_iso_folder) ~= nil then

                for i, file in pairs(QuickGameList.adrenaline_iso_folder) do

                    -- Check if game in cached file
                    if cached_table_sfo_scans_onelua[file.name] ~= nil then
                        -- Found
                        file.filename = file.name
                        file.path = file.path

                        file.title = cached_table_sfo_scans_onelua[file.name].title or "UNK"
                        file.titleid = cached_table_sfo_scans_onelua[file.name].titleid or "UNK"
                        file.category = cached_table_sfo_scans_onelua[file.name].category or "UNK"
                        file.region = cached_table_sfo_scans_onelua[file.name].region or "UNK"

                        table.insert(table_iso, file)
                        table.insert(new_sfo_scans_onelua, file)
                    else
                        -- Not found, is a new game, scan SFO
                        local sfo = {}
                        sfo = game.info(file.path)

                        -- Error handling for bad sfo files
                        if sfo ~= nil then
                            if sfo.TITLE and sfo.DISC_ID and sfo.REGION and sfo.CATEGORY ~= nil then

                                -- Cleanup game title
                                sfo_title = cleanup_game_title(sfo.TITLE) or "UNK"
                                
                                file.filename = file.name
                                file.path = file.path

                                file.title = sfo_title
                                file.titleid = sfo.DISC_ID or "UNK"
                                file.category = sfo.CATEGORY or "UNK"
                                file.region = sfo.REGION or "UNK"

                                table.insert(table_iso, file)
                                table.insert(new_sfo_scans_onelua, file)
                            else
                            end
                        else
                            -- Fallback, include anyway to prevent boot loop
                            file.filename = file.name
                            file.path = file.path

                            file.title = "UNK"
                            file.titleid = "UNK"
                            file.category = "UNK"
                            file.region = "UNK"

                            table.insert(table_iso, file)
                            table.insert(new_sfo_scans_onelua, file)
                        end
                        update_loading_screen_progress()
                    end

                end
            else
            end

        end

    -- Scan Function - Game folders

        function scan_game_folder()

            if next(QuickGameList.adrenaline_games_folder) ~= nil then
                for i, file in pairs(QuickGameList.adrenaline_games_folder) do

                    -- Get parent folder name
                    local last_foldername_in_path = file.path:gsub(".*/([^/]+)/[^/]+$", "%1") -- Gsub returns the parent folder name eg. SCUS94306

                    -- Check if game in cached file
                    if cached_table_sfo_scans_onelua[last_foldername_in_path] ~= nil then
                        -- Found
                        file.filename = file.name
                        file.path = file.path
                        
                        file.title = cached_table_sfo_scans_onelua[last_foldername_in_path].title or "UNK"
                        file.titleid = cached_table_sfo_scans_onelua[last_foldername_in_path].titleid or "UNK"
                        file.category = cached_table_sfo_scans_onelua[last_foldername_in_path].category or "UNK"
                        file.region = cached_table_sfo_scans_onelua[last_foldername_in_path].region or "UNK"

                        table.insert(table_games, file)
                        table.insert(new_sfo_scans_onelua, file)
                    else
                        -- Not found, is a new game, scan SFO
                        local sfo = {}
                        sfo = game.info(file.path)

                        if sfo ~= nil then
                            -- Cleanup game title
                            sfo_title = cleanup_game_title(sfo.TITLE) or "UNK"

                            file.filename = last_foldername_in_path
                            file.path = file.path

                            if sfo.CATEGORY == "MG" then
                                -- Homebrew - Use folder name for homebrew as many devs didn't bother creating proper sfo files
                                file.title = last_foldername_in_path
                            else
                                file.title = sfo_title
                            end

                            
                            file.titleid = sfo.DISC_ID or "UNK"
                            file.category = sfo.CATEGORY or "UNK"
                            file.region = sfo.REGION or "UNK"

                            if file.filename and file.title and file.titleid and file.region and file.path ~= nil then
                                table.insert(table_games, file)
                                table.insert(new_sfo_scans_onelua, file)
                            else
                            end
                        else
                            -- Fallback, include anyway to prevent boot loop
                            file.filename = last_foldername_in_path
                            file.path = file.path

                            file.title = "UNK"
                            file.titleid = "UNK"
                            file.category = "UNK"
                            file.region = "UNK"

                            table.insert(table_iso, file)
                            table.insert(new_sfo_scans_onelua, file)
                        end
                        
                        update_loading_screen_progress()

                    end


                end
            else
            end

        end

    -- Scan Function - Retroarch PS1 Game folders
        function scan_Rom_PS1_Eboot()

            if next(QuickGameList.psx_retroarch) ~= nil then

                for i, file in pairs(QuickGameList.psx_retroarch) do

                    -- Handle EBOOT.PBP files in subfolders
                    if file.name:lower():match("eboot.pbp") and file.subfolder == true then

                        -- Get parent folder name
                        local last_foldername_in_path = file.path:gsub(".*/([^/]+)/[^/]+$", "%1")

                        -- Check if game in cached file
                        if cached_table_sfo_scans_onelua[last_foldername_in_path] ~= nil then
                            -- Found
                            file.filename = file.name
                            file.path = file.path
                            
                            file.title = cached_table_sfo_scans_onelua[last_foldername_in_path].title or "UNK"
                            file.titleid = cached_table_sfo_scans_onelua[last_foldername_in_path].titleid or "UNK"
                            file.category = cached_table_sfo_scans_onelua[last_foldername_in_path].category or "UNK"
                            file.region = cached_table_sfo_scans_onelua[last_foldername_in_path].region or "UNK"

                            table.insert(table_retroarch, file)
                            table.insert(new_sfo_scans_onelua, file)

                        else
                            -- Not found, is a new game, scan SFO
                            local sfo = {}
                            sfo = game.info(file.path)

                            -- Error handling for bad sfo files
                            if sfo ~= nil then
                                if sfo.TITLE and sfo.DISC_ID and sfo.REGION and sfo.CATEGORY ~= nil then

                                    -- Cleanup game title
                                    sfo_title = cleanup_game_title(sfo.TITLE) or "UNK"

                                    file.filename = last_foldername_in_path
                                    file.path = file.path

                                    file.title = sfo_title
                                    file.titleid = sfo.DISC_ID or "UNK"
                                    file.category = sfo.CATEGORY or "UNK"
                                    file.region = sfo.REGION or "UNK"

                                    table.insert(table_retroarch, file)
                                    table.insert(new_sfo_scans_onelua, file)
                                else
                                end
                            else
                                -- Fallback, include anyway to prevent boot loop
                                file.filename = last_foldername_in_path
                                file.path = file.path

                                file.title = "UNK"
                                file.titleid = "UNK"
                                file.category = "UNK"
                                file.region = "UNK"

                                table.insert(table_iso, file)
                                table.insert(new_sfo_scans_onelua, file)
                            end
                            
                            update_loading_screen_progress()
                        end

                    -- Handle other .PBP files (not EBOOT.PBP)
                    elseif (string.match(file.name, "%.pbp") or string.match(file.name, "%.PBP")) and not file.name:lower():match("eboot.pbp") then

                        -- Check if game in cached file
                        if cached_table_sfo_scans_onelua[file.name] ~= nil then
                            -- Found
                            file.filename = file.name
                            file.path = file.path
                            
                            file.title = cached_table_sfo_scans_onelua[file.name].title or "UNK"
                            file.titleid = cached_table_sfo_scans_onelua[file.name].titleid or "UNK"
                            file.category = cached_table_sfo_scans_onelua[file.name].category or "UNK"
                            file.region = cached_table_sfo_scans_onelua[file.name].region or "UNK"

                            table.insert(table_retroarch, file)
                            table.insert(new_sfo_scans_onelua, file)

                        else
                            -- Not found, is a new game, scan SFO
                            local sfo = {}
                            sfo = game.info(file.path)

                            -- Error handling for bad sfo files
                            if sfo ~= nil then
                                if sfo.TITLE and sfo.DISC_ID and sfo.REGION and sfo.CATEGORY ~= nil then

                                    -- Cleanup game title
                                    sfo_title = cleanup_game_title(sfo.TITLE) or "UNK"

                                    file.filename = file.name
                                    file.path = file.path

                                    file.title = sfo_title
                                    file.titleid = sfo.DISC_ID or "UNK"
                                    file.category = sfo.CATEGORY or "UNK"
                                    file.region = sfo.REGION or "UNK"

                                    table.insert(table_retroarch, file)
                                    table.insert(new_sfo_scans_onelua, file)
                                else
                                end
                            else
                                -- Fallback, include anyway to prevent boot loop
                                file.filename = file.name
                                file.path = file.path

                                file.title = "UNK"
                                file.titleid = "UNK"
                                file.category = "UNK"
                                file.region = "UNK"

                                table.insert(table_iso, file)
                                table.insert(new_sfo_scans_onelua, file)
                            end
                            
                            update_loading_screen_progress()
                        end

                    end

                end

            else
            end
        end


-- FUNCTION IMPORT

    -- Import cached tables into live tables when new game is found

    function add_cached_games_to_table (def_cached_table, def_target_table)
        for k, v in pairs((def_cached_table)) do
            file = {}
            file.name = k
            file.filename = k
            file.title = v.title
            file.titleid = v.titleid
            file.region = v.region
            file.path = v.path
            table.insert((def_target_table), file)

            update_loading_screen_progress()
        end
    end
    

-- FUNCTION READ

    function files.read(path,mode)
        local fp = io.open(path, mode or "r")
        if not fp then return nil end

        local data = fp:read("*a")
        fp:close()
        return data
    end


-- INSTALL MESSAGE
    function install_message(str)
        if loading_screen then loading_screen:blit(0, 0) end
        screen.print(custom_font, 480, 450, str, font_size, white, black, __ACENTER)
        screen.flip()
    end

-- INSTALL RETROFLOW ADRENALINE LAUNCHER IF NOT INSTALLED

    RETROLNCR_VPK = "ux0:app/RETROFLOW/payloads/RetroFlow Adrenaline Launcher.vpk"

    if game.exists("PSPEMUCFW") then
        if not game.exists("RETROLNCR") and files.exists(RETROLNCR_VPK) then
            
            install_message(lang_lines.RETROLNCR_Install) -- Installing RetroFlow Adrenaline Launcher...

            game.install(RETROLNCR_VPK, false)

            install_message(lang_lines.RETROLNCR_Installed) -- RetroFlow Adrenaline Launcher has been installed...
            os.delay(2500) -- Wait for 2.5 seconds
        end
    end


-- CHECK ADRENALINE BUBBLE BOOTER ASSETS ARE INSTALLED, RESTART IF NOT

    -- CRC Checksums and assets

        -- default values modules AdrenalineBooter v1.3 for adrenaline v7.0
        __CRCADRBOOTER  = 0x039095FD
        __CRCKERNEL     = 0xC9F84053
        __CRCUSER       = 0xF5116106
        __CRCVSH        = 0x485293A1
        __CRCBOOTCONV   = 0xD072FE17

        ADRENALINE = "ux0:app/PSPEMUCFW"
        MODULES = {
          { fullpath = ADRENALINE.."/sce_module/adrbubblebooter.suprx",   path = "payloads/abm/sce_module/adrbubblebooter.suprx",   crc = __CRCADRBOOTER },
          { fullpath = ADRENALINE.."/sce_module/adrenaline_kernel.skprx", path = "payloads/abm/sce_module/adrenaline_kernel.skprx", crc = __CRCKERNEL  },
          { fullpath = ADRENALINE.."/sce_module/adrenaline_user.suprx",   path = "payloads/abm/sce_module/adrenaline_user.suprx",   crc = __CRCUSER  },
          { fullpath = ADRENALINE.."/sce_module/adrenaline_vsh.suprx",    path = "payloads/abm/sce_module/adrenaline_vsh.suprx",    crc = __CRCVSH  },
          { fullpath = ADRENALINE.."/sce_module/bootconv.suprx",          path = "payloads/abm/sce_module/bootconv.suprx",          crc = __CRCBOOTCONV }
        }
    
    -- Copy assets if missing or checksums are different, restart Vita

        oncopy = false

        if game.exists("PSPEMUCFW") and files.exists(ADRENALINE) and
            files.exists(ADRENALINE.."/eboot.bin") and files.exists(ADRENALINE.."/eboot.pbp") then

            if not files.exists(ADRENALINE.."/adrenaline.bin") then
                oncopy = true
                files.copy("payloads/abm/bubbles/adrenaline.bin", ADRENALINE)
            end

            if not files.exists(ADRENALINE.."/menucolor.bin") then
                oncopy = true
                files.copy("payloads/abm/bubbles/menucolor.bin", ADRENALINE)
            end

            if not files.exists(ADRENALINE.."/sce_module/adrbubblebooter.suprx") then
                oncopy = true
                files.copy("payloads/abm/sce_module/", ADRENALINE)
            else

                for i=1,#MODULES do
                    if not files.exists(MODULES[i].fullpath) then
                        oncopy = true
                        files.copy(MODULES[i].path, ADRENALINE.."/sce_module/")
                    else
                        if os.crc32(files.read(MODULES[i].fullpath) ) != MODULES[i].crc then
                            oncopy = true
                            files.copy(MODULES[i].path, ADRENALINE.."/sce_module/")
                        end
                    end
                end

            end

            if oncopy then

                install_message(lang_lines.ABB_Install) -- Installing AdrBubbleBooter plugin... - Message displayed after install, backwards I know but simpler, otherwise message is unnecessarily duplicated
                os.delay(2500) -- Wait for 2.5 seconds

                if loading_screen then loading_screen:blit(0, 0) end

                screen.print(custom_font, 480, 400, lang_lines.ABB_Installed, font_size, white, black, __ACENTER) -- AdrBubbleBooter plugin has been installed...
                screen.print(custom_font, 480, 425, lang_lines.ABB_Restart, font_size, white, black, __ACENTER) -- We need to restart your PS Vita

                -- Load button images

                    local btnX = image.load("DATA/x.png")
                    local btnO = image.load("DATA/o.png")

                -- Calculate centre alignment for images and strings

                    image.resize(btnX, 20, 20)
                    image.resize(btnO, 20, 20)

                    msg_btnLabel1 = screen.textwidth(custom_font, lang_lines.Restart_Now, font_size)
                    msg_btnLabel2 = screen.textwidth(custom_font, lang_lines.Restart_Later, font_size)
                    msg_btnMargin = 40 -- Distance between buttons
                    msg_btnPaddingRight = 15
                    msg_btImgWidth = 20
                    msg_btImgYoffset = 2.5

                    msg_overallWidth = msg_btImgWidth + msg_btnPaddingRight + msg_btnLabel1 + msg_btnMargin + msg_btImgWidth + msg_btnPaddingRight + msg_btnLabel2

                    local msg_xpos_cumulative = (960 - msg_overallWidth) / 2

                -- Draw message

                    -- Button X
                    image.blit(btnX, msg_xpos_cumulative, 475 - msg_btImgYoffset)

                    -- String - Restart Now
                    msg_xpos_cumulative = msg_xpos_cumulative + msg_btImgWidth + msg_btnPaddingRight
                    screen.print(custom_font, msg_xpos_cumulative, 475, lang_lines.Restart_Now, font_size, white, black, __ALEFT)

                    -- Button O
                    msg_xpos_cumulative = msg_xpos_cumulative + msg_btnLabel1 + msg_btnMargin
                    image.blit(btnO, msg_xpos_cumulative, 475 - msg_btImgYoffset)

                    -- String - Restart Later
                    msg_xpos_cumulative = msg_xpos_cumulative + msg_btImgWidth + msg_btnPaddingRight
                    screen.print(custom_font, msg_xpos_cumulative, 475, lang_lines.Restart_Later, font_size, white, black, __ALEFT)

                screen.flip()

                while true do
                    buttons.read()
                    if buttons.cross then 
                        power.restart()
                    end 

                    if buttons.circle then 
                        break
                    end 
                end

            else
            end

        else
        end


-- COMMAND - SCAN GAMES

    -- Scan Command - ISO folders

        table_iso = {}
        update_debug_message("Scanning: ISO folders")
        scan_iso_folder ()

        update_debug_message("Creating table: iso")
        add_cached_games_to_table (cached_table_iso, table_iso)

        update_debug_message("Sorting table: iso")
        if #table_iso > 0 then
            table.sort(table_iso, function(a, b) return (a.name:lower() < b.name:lower()) end)
        end

        update_debug_message("Saving table: iso")
        write_ini(tostring(titles_dir .. sfo_scan_isos_lua), table_iso)


    -- Scan Command - Game folders

        table_games = {}

        update_debug_message("Scanning: Game folders")
        scan_game_folder ()

        update_debug_message("Creating table: games")
        add_cached_games_to_table (cached_table_games, table_games)

        update_debug_message("Sorting table: games")
        if #table_games > 0 then
            table.sort(table_games, function(a, b) return (a.title:lower() < b.title:lower()) end)
        end

        update_debug_message("Saving table: games")
        write_ini(tostring(titles_dir .. sfo_scan_games_lua), table_games)

    -- Scan Command - Retroarch PS1 Game folders

        table_retroarch = {}

        update_debug_message("Scanning: romUserDir.PlayStation")
        scan_Rom_PS1_Eboot()
        
        update_debug_message("Creating table: retroarch")
        add_cached_games_to_table (cached_table_retroarch, table_retroarch)

        update_debug_message("Sorting table: retroarch")
        if #table_retroarch > 0 then
            table.sort(table_retroarch, function(a, b) return (a.title:lower() < b.title:lower()) end)
        end
        
        update_debug_message("Saving table: retroarch")
        write_ini(tostring(titles_dir .. sfo_scan_retroarch_lua), table_retroarch)


    -- Write combined sfo file

        write_ini(tostring(titles_dir .. sfo_scans_onelua), new_sfo_scans_onelua)

    -- All scans complete

        print_loading_complete()

        
-- COMMAND - LAUNCH

    -- Debugging
        -- game.open("VITASHELL")

    -- Maybe useful for future - close and launch another app without prompt message
        -- game.launch("RETROLNCR")
        -- game.close("RETROFLOW")

    -- Launch the main app
        os.execute("app0:eboot.bin")

