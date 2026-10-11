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
        elseif is_loadable_image("ur0:/appmeta/" .. (def_table_name)[p].name .. "/pic0.png") then
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


    -- Vita apps and system apps
    elseif (def_table_name)[p].app_type == 1 or (def_table_name)[p].app_type == 42 then
        -- Check backgrounds folder
        if System.doesFileExist((def_table_name)[p].snap_path_local .. (def_table_name)[p].title .. ".png") then
            pic_path = (def_table_name)[p].snap_path_local .. (def_table_name)[p].title .. ".png"

        elseif System.doesFileExist((def_table_name)[p].snap_path_local .. (def_table_name)[p].name .. ".png") then
            pic_path = (def_table_name)[p].snap_path_local .. (def_table_name)[p].name .. ".png"

        -- Not found? Then check installed app pic0 locations
        elseif is_loadable_image("ur0:/appmeta/" .. (def_table_name)[p].name .. "/pic0.png") then
            pic_path = "ur0:/appmeta/" .. (def_table_name)[p].name .. "/pic0.png"

        elseif is_loadable_image("vs0:/app/" .. (def_table_name)[p].name .. "/sce_sys/pic0.png") then
            pic_path = "vs0:/app/" .. (def_table_name)[p].name .. "/sce_sys/pic0.png"

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
        else
            pic_path = ""

        end 

    end
end

function xAppIconPathLookup(AppTypeNum)


    if apptype==0 then 
        -- Homebrew
        local icon_filename = xCatLookup(showCat)[p].titleid

        if icon_filename then

            -- Check icons dir
            if System.doesFileExist(SystemsToScan[2].localIconPath .. icon_filename .. ".png") then
                return SystemsToScan[2].localIconPath .. icon_filename .. ".png"

            -- Check covers dir
            elseif System.doesFileExist(SystemsToScan[2].localCoverPath .. icon_filename .. ".png") then
                return SystemsToScan[2].localCoverPath .. icon_filename .. ".png"

            -- Then check appmeta
            elseif System.doesFileExist("ur0:/appmeta/" .. icon_filename .. "/icon0.png") then
                return "ur0:/appmeta/" .. icon_filename .. "/icon0.png"

            -- Still not found, use placeholder icon
            else
                return "app0:/DATA/" .. SystemsToScan[2].icon
            end
            
        else
            return "app0:/DATA/" .. SystemsToScan[2].icon
        end

    elseif apptype==1 then 
        -- Vita
        local icon_filename = xCatLookup(showCat)[p].titleid

        if icon_filename then

            -- Check icons dir
            if System.doesFileExist(SystemsToScan[1].localIconPath .. icon_filename .. ".png") then
                return SystemsToScan[1].localIconPath .. icon_filename .. ".png"

            -- Then check appmeta
            elseif System.doesFileExist("ur0:/appmeta/" .. icon_filename .. "/icon0.png") then
                return "ur0:/appmeta/" .. icon_filename .. "/icon0.png"

            -- Still not found, use placeholder icon
            else
                return "app0:/DATA/" .. SystemsToScan[1].icon
            end

        else
            return "app0:/DATA/" .. SystemsToScan[1].icon
        end

    elseif apptype == 2 then
        -- PSP
        local icon_filename = xCatLookup(showCat)[p].titleid

        -- Check icons dir, if not found use placeholder icon
        if icon_filename and System.doesFileExist(SystemsToScan[3].localIconPath .. icon_filename .. ".png") then
            return SystemsToScan[3].localIconPath .. icon_filename .. ".png"
        else
            return "app0:/DATA/" .. SystemsToScan[3].icon
        end

    elseif apptype == 3 then
        -- PSX
        local icon_filename = xCatLookup(showCat)[p].titleid

        -- Check icons dir, if not found use placeholder icon
        if icon_filename and System.doesFileExist(SystemsToScan[4].localIconPath .. icon_filename .. ".png") then
            return SystemsToScan[4].localIconPath .. icon_filename .. ".png"
        else
            return "app0:/DATA/" .. SystemsToScan[4].icon
        end

    elseif apptype == 39 then
        -- PSM
        local icon_filename = xCatLookup(showCat)[p].titleid

        if icon_filename then

            -- Check icons dir
            if System.doesFileExist(SystemsToScan[39].localIconPath .. icon_filename .. ".png") then
                return SystemsToScan[39].localIconPath .. icon_filename .. ".png"

            -- Then check appmeta
            elseif System.doesFileExist("ur0:/appmeta/" .. icon_filename .. "/pic0.png") then
                return "ur0:/appmeta/" .. icon_filename .. "/pic0.png"

            -- Still not found, use placeholder icon
            else
                return "app0:/DATA/" .. SystemsToScan[39].icon
            end

        else
            return "app0:/DATA/" .. SystemsToScan[39].icon
        end

    elseif apptype==42 then 
        -- System apps
        local icon_filename = xCatLookup(showCat)[p].titleid

        if icon_filename then

            -- Check icons dir
            if System.doesFileExist(SystemsToScan[42].localIconPath .. icon_filename .. ".png") then
                return SystemsToScan[42].localIconPath .. icon_filename .. ".png"

            -- Check covers dir
            elseif System.doesFileExist(SystemsToScan[42].localCoverPath .. icon_filename .. ".png") then
                return SystemsToScan[42].localCoverPath .. icon_filename .. ".png"

            -- Then check vs0
            elseif System.doesFileExist("vs0:/app/" .. icon_filename .. "/sce_sys/icon0.png") then
                return "vs0:/app/" .. icon_filename .. "/sce_sys/icon0.png"

            -- Still not found, use placeholder icon
            else
                return "app0:/DATA/" .. SystemsToScan[42].icon
            end
            
        else
            return "app0:/DATA/" .. SystemsToScan[42].icon
        end

    else
        -- Other systems
        local icon_filename = xCatLookup(showCat)[p].name

        -- Check icons dir, if not found use placeholder icon (regional specific based on language)
        if icon_filename and System.doesFileExist(SystemsToScan[apptype].localIconPath .. icon_filename .. ".png") then
            return SystemsToScan[apptype].localIconPath .. icon_filename .. ".png"
        else
            if apptype == 11 then
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
            elseif apptype == 14 then
                -- MD
                if setLanguage == 1 then
                    return "app0:/DATA/icon_md_usa.png"
                else
                    return "app0:/DATA/icon_md.png"
                end
            else
                return "app0:/DATA/" .. SystemsToScan[apptype].icon
            end
        end

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


    if showCat == 50 and #search_results_table == 0 then
        if random_game_selected == false then
            app_title = lang_lines.Search_No_Results
        else
            app_title = ""
        end
    end

end


function GetInfoSelected()

    if next(xCatLookup(showCat)) ~= nil then
        -- if showCat == 48 then
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
    if recently_played_full_table ~= nil then
        for k, v in pairs(recently_played_full_table) do
            if v.filename==filename then
                v.favourite=(def)
            end
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
                        table.insert((def_table_name),v)
                        break
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
            if type(file) == "table" and file.hidden == true then
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

        if showCat >= 1 and showCat <= 46 then
            -- Update live favorites for game category tables and cache
            update_favorites_table_system(xCatLookup(showCat))
            update_cached_table(xCatDbFileLookup(showCat), xCatLookup(showCat))
        
        -- Favourites
        elseif showCat == 48 then
            -- Find game in other tables and update
            update_favorites_table_favorites(xAppNumTableLookup(apptype))
            update_cached_table(xAppDbFileLookup(apptype), xAppNumTableLookup(apptype))

        -- Recent
        elseif showCat == 49 then
            -- Find game in other tables and update
            update_favorites_table_recent(xAppNumTableLookup(apptype))
            update_cached_table(xAppDbFileLookup(apptype), xAppNumTableLookup(apptype))

        -- Search results
        elseif showCat == 50 then
            update_favorites_table_system(search_results_table)

            -- Find game in other tables and update
            update_favorites_table_recent(xAppNumTableLookup(apptype))
            update_cached_table(xAppDbFileLookup(apptype), xAppNumTableLookup(apptype))

        -- Collections
        elseif showCat >= 51 then
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
        fav_count_dirty = true


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
    fav_count_dirty = true

    -- Recent cat
    if showCat == 49 then

        -- Update recent table
        if #recently_played_table ~= nil then
            recently_played_table[p].hidden=(def_hide_game_flag)
        end
        if recently_played_full_table ~= nil then
            local key = find_game_table_pos_key(recently_played_full_table, app_titleid)
            if key ~= nil then
                recently_played_full_table[key].hidden=(def_hide_game_flag)
            end
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

        if recently_played_full_table ~= nil then
            local key = find_game_table_pos_key(recently_played_full_table, app_titleid)
            if key ~= nil then
                recently_played_full_table[key].hidden=(def_hide_game_flag)
            end
        end

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

function update_hidden_state_in_table(def_table, def_name, def_hide_game_flag, def_remove_hidden)
    if def_table == nil then
        return
    end

    local i = 1
    while i <= #def_table do
        local file = def_table[i]
        if type(file) == "table" and file.name == def_name then
            file.hidden = def_hide_game_flag
            if def_remove_hidden == true and def_hide_game_flag == true then
                table.remove(def_table, i)
            else
                i = i + 1
            end
        else
            i = i + 1
        end
    end
end

function refresh_after_hide_unhide(def_name, def_app_type, def_hide_game_flag)
    local remove_hidden = showHidden == 0 and def_hide_game_flag == true

    update_hidden_state_in_table(xAppNumTableLookup(def_app_type), def_name, def_hide_game_flag, remove_hidden)
    update_hidden_state_in_table(files_table, def_name, def_hide_game_flag, remove_hidden)
    update_hidden_state_in_table(folders_table, def_name, def_hide_game_flag, remove_hidden)
    update_hidden_state_in_table(files_table_no_sysapps, def_name, def_hide_game_flag, remove_hidden)
    update_hidden_state_in_table(recently_played_full_table, def_name, def_hide_game_flag, false)
    update_hidden_state_in_table(recently_played_table, def_name, def_hide_game_flag, remove_hidden)
    update_hidden_state_in_table(search_results_table, def_name, def_hide_game_flag, remove_hidden)

    if collection_files ~= nil then
        for _, collection_file in ipairs(collection_files) do
            if collection_file.table_name ~= nil then
                update_hidden_state_in_table(_G[collection_file.table_name], def_name, def_hide_game_flag, remove_hidden)
            end
        end
    end

    fav_count_dirty = true
    if showCat == 48 then
        refresh_fav_count_table()
    end

    check_for_out_of_bounds()
    if p > 0 and xCatLookup(showCat)[p] ~= nil then
        GetInfoSelected()
        GetNameAndAppTypeSelected()
    else
        GetNameAndAppTypeSelected()
    end
end


function AddtoRecentlyPlayed()

    local recently_played_was_hidden = showRecentlyPlayed == 0

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
    local last_played_table = xCatTableNameLookup(showCat)

    -- LAST PLAYED GAME
    if last_played_table == "search_results_table" then
        local app_type_table_name = xCatTableNameFromAppType(apptype)
        if app_type_table_name ~= nil then
            last_played_table = app_type_table_name
        end
    end

    -- LAST PLAYED GAME
    -- If the visible Recently Played category is hidden, import the saved list temporarily so launch updates preserve it.
    if recently_played_was_hidden then
        recently_played_table = {}
        import_recently_played(true)
    end

    if recently_played_full_table == nil then
        recently_played_full_table = {}
    end
    
    recently_played_new = {}
    already_played = false

    -- If game in Recently played list - Update timestamp
    for k, v in pairs(recently_played_full_table) do
        if v.filename==filename then
            already_played = true
            v.date_played=timestamp
            v.last_played_table=last_played_table
        end
    end

    if already_played == false then
        -- Lookup apptype and find relevent table, update timestamp and insert to recent
        for k, v in pairs(xAppNumTableLookup(apptype)) do 
            if v.filename==filename and already_played == false then
                v.date_played=timestamp
                v.last_played_table=last_played_table
                table.insert(recently_played_new, v)
            else
            end
        end
    end

    -- Copy the recently played table to a new table
    for k, v in pairs(recently_played_full_table) do
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

    recently_played_full_table = recently_played_pre_launch_table
    rebuild_visible_recently_played_table()

    if recently_played_was_hidden then
        recently_played_table = {}
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

function QuickOverride_Update_recently_played(def_game)
    if #recently_played_table ~= nil then
        local key_recent = find_game_table_pos_key(recently_played_table, app_titleid)
        if key_recent ~= nil then
            QuickOverride_Sync_loaded_entry(recently_played_table, def_game)
            update_cached_table_recently_played()
        else
        end
    end
    QuickOverride_Sync_loaded_entry(recently_played_full_table, def_game)
end

function QuickOverride_Sync_loaded_entry(def_table, def_game)
    if def_table == nil or def_game == nil then
        return
    end

    local key = find_game_table_pos_key(def_table, def_game.name)
    if key ~= nil then
        def_table[key].app_type = def_game.app_type
        def_table[key].cover_path_online = def_game.cover_path_online
        def_table[key].cover_path_local = def_game.cover_path_local
        def_table[key].snap_path_online = def_game.snap_path_online
        def_table[key].snap_path_local = def_game.snap_path_local
        def_table[key].icon_path = def_game.icon_path
        def_table[key].cover = def_game.cover
    end
end

function QuickOverride_Remove_loaded_entry(def_table, def_name)
    if def_table == nil then
        return
    end

    local key = find_game_table_pos_key(def_table, def_name)
    if key ~= nil then
        table.remove(def_table, key)
    end
end

function QuickOverride_Sync_loaded_views(def_game)
    QuickOverride_Sync_loaded_entry(files_table, def_game)
    QuickOverride_Sync_loaded_entry(folders_table, def_game)
    QuickOverride_Sync_loaded_entry(files_table_no_sysapps, def_game)
    QuickOverride_Sync_loaded_entry(fav_count, def_game)
    QuickOverride_Sync_loaded_entry(recently_played_full_table, def_game)
    QuickOverride_Sync_loaded_entry(recently_played_table, def_game)
    QuickOverride_Sync_loaded_entry(search_results_table, def_game)

    if collection_files ~= nil then
        for _, collection_file in ipairs(collection_files) do
            if collection_file.table_name ~= nil then
                QuickOverride_Sync_loaded_entry(_G[collection_file.table_name], def_game)
            end
        end
    end

    fav_count_dirty = true
end

function QuickOverride_Save_collection_membership(def_collection_file, def_collection_table)
    local collection_to_save = {}
    if def_collection_file == nil or def_collection_table == nil then
        return
    end

    for _, file in ipairs(def_collection_table) do
        if type(file) == "table" then
            local collection_entry = {}
            collection_entry.apptitle = file.apptitle or file.title
            collection_entry.name = file.name
            collection_entry.app_type = file.app_type
            if file.custom_sort_order ~= nil then
                collection_entry.custom_sort_order = file.custom_sort_order
            end
            table.insert(collection_to_save, collection_entry)
        end
    end

    update_cached_collection(def_collection_file, collection_to_save)
end

function QuickOverride_Save_loaded_collections(def_game)
    if def_game == nil then
        return
    end

    if collection_files ~= nil then
        for _, collection_file in ipairs(collection_files) do
            if collection_file.table_name ~= nil then
                local collection_table = _G[collection_file.table_name]
                if collection_table ~= nil and find_game_table_pos_key(collection_table, def_game.name) ~= nil then
                    QuickOverride_Save_collection_membership(collection_file.filename, collection_table)
                end
            end
        end
    end
end

function QuickOverride_Remove_from_loaded_views(def_name)
    QuickOverride_Remove_loaded_entry(files_table, def_name)
    QuickOverride_Remove_loaded_entry(folders_table, def_name)
    QuickOverride_Remove_loaded_entry(files_table_no_sysapps, def_name)
    QuickOverride_Remove_loaded_entry(fav_count, def_name)
    QuickOverride_Remove_loaded_entry(search_results_table, def_name)
end

function QuickOverride_Remove_from_loaded_collections(def_name)
    if collection_files ~= nil then
        for _, collection_file in ipairs(collection_files) do
            if collection_file.table_name ~= nil then
                QuickOverride_Remove_loaded_entry(_G[collection_file.table_name], def_name)
            end
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
    local overridden_game = nil

        if (tmpappcat)==1 then
            -- vita
            if #xAppNumTableLookup(apptype) ~= nil then
                key = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
                if key ~= nil then
                    QuickOverride_Vita()
                    overridden_game = xAppNumTableLookup(apptype)[key]

                    QuickOverride_Update_recently_played(overridden_game)

                    table.insert(games_table, overridden_game)
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
                    overridden_game = xAppNumTableLookup(apptype)[key]

                    QuickOverride_Update_recently_played(overridden_game)

                    table.insert(psp_table, overridden_game)
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
                    overridden_game = xAppNumTableLookup(apptype)[key]

                    QuickOverride_Update_recently_played(overridden_game)

                    table.insert(psx_table, overridden_game)
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
                    overridden_game = xAppNumTableLookup(apptype)[key]

                    QuickOverride_Update_recently_played(overridden_game)

                    table.insert(homebrews_table, overridden_game)
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
        QuickOverride_Sync_loaded_views(overridden_game)
        QuickOverride_Save_loaded_collections(overridden_game)

    -- If the last game is overriden, move to 1st to prevent nil error
    if p == curTotal then
        p = 1
        master_index = p
    end

    -- force icon change. Credit BlackSheepBoy69
    -- xCatLookup(showCat)[p].ricon = Graphics.loadImage(xCatLookup(showCat)[p].icon_path)

    -- Error fix for when Homebrew is off, overriding game to homebrew, and on all category - then reload files
    if showHomebrews == 0 and (tmpappcat)==4 and showCat == 0 then
        QuickOverride_Remove_from_loaded_views(app_titleid)
        check_for_out_of_bounds()
    end

    if showHomebrews == 0 and (tmpappcat)==4 then
        QuickOverride_Remove_from_loaded_collections(app_titleid)
        check_for_out_of_bounds()
    end

    GetInfoSelected()
    oldpad = pad -- Prevents it from launching next game accidentally. Credit BlackSheepBoy69
    showMenu = 0

    Render.useTexture(modBackground, imgCustomBack)

    -- Instant cover update - Credit BlackSheepBoy69
    if xCatLookup(showCat)[p] ~= nil then
        Threads.addTask(xCatLookup(showCat)[p], {
        Type = "ImageLoad",
        Path = xCatLookup(showCat)[p].icon_path,
        Table = xCatLookup(showCat)[p],
        Index = "ricon"
        })
    end

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


function DownloadArtwork(missing_artwork_table)

    Graphics.initBlend()
    Screen.clear()
    Graphics.termBlend()
    Screen.flip()

    -- Check CRC for files with missing covers
    if next(missing_artwork_table) ~= nil then

        -- Setup
            crc_download_load_previous_crc_matches()

            missing_artwork_total = #missing_artwork_table
            local crcs_checked = 0
            local artwork_found_count = 0

        -- Update progress and reset screen
            function crc_download_progress_bar_update()
                crcs_checked = crcs_checked + 1
                -- Font.print(fnt22, 10, 35, math.floor((crcs_checked/missing_artwork_total)*100).."%", white)
                -- Graphics.fillRect(0, (crcs_checked/missing_artwork_total)*960, 534, 544, img_loader_green)
            end

        for i, file in pairs(missing_artwork_table) do

            -- CHECK CRC
                
                if setCRCScan == 1 and xAppNumCRCLookupDB(file.app_type) ~= false then

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

                    crc_result = crc_download_crc_matched_name(file)
                else
                    crc_result = nil
                end
                
                if crc_result then
                    game_name_online = crc_result:gsub("\n", "")
                else
                    if file.app_type == 43 or file.app_type == 47 then
                        -- 3DS and DS
                        game_name_online = file.titleid:gsub("\n", "")
                    else
                        game_name_online = file.name:gsub("\n", "")
                    end
                end

                local artwork_found = false
                local artwork_name_candidates = {}
                local artwork_name_lookup = {}
                local online_artwork_path = file[crc_download_mode_path_online()] or ""
                artwork_file_dest_path = tostring(file[crc_download_mode_path_local()] .. file.name .. ".png")

                local function add_artwork_name_candidate(def_name)
                    local candidate = tostring(def_name or ""):gsub("\n", "")
                    if candidate ~= "" and artwork_name_lookup[candidate] ~= true then
                        table.insert(artwork_name_candidates, candidate)
                        artwork_name_lookup[candidate] = true
                    end
                end

                add_artwork_name_candidate(game_name_online)
                -- Background repos often use display/no-intro titles. When CRC is off,
                -- also try the title fields instead of only the ROM filename.
                if download_mode_snaps == true then
                    add_artwork_name_candidate(file.title)
                    add_artwork_name_candidate(file.apptitle)
                    add_artwork_name_candidate(file.name_title_search)
                else
                    add_artwork_name_candidate(file.name)
                end

                if online_artwork_path ~= "" then
                    for _, artwork_name_candidate in ipairs(artwork_name_candidates) do
                        if artwork_found == false then
                            artwork_file_url = ""

                            if online_artwork_path:find("libretro") then

                                -- Libretro - Replace these characters &*/:`<>?\|" with an underscore _ to match libretro naming convention
                                if file.app_type == 21 and file.name_title_search ~= nil then
                                    name_after_libretro_gsub = file.name_title_search:gsub("[&*/:`<>?\\|\"]+", "_")
                                else
                                    name_after_libretro_gsub = artwork_name_candidate:gsub("[&*/:`<>?\\|\"]+", "_")
                                end

                                artwork_file_url = tostring(online_artwork_path .. urlencode(name_after_libretro_gsub) .. ".png")

                            else
                                -- Not libretro
                                if file.app_type == 21 and file.name_title_search ~= nil then
                                   artwork_file_url = tostring(online_artwork_path .. urlencode(file.name_title_search) .. ".png")
                                else
                                    artwork_file_url = tostring(online_artwork_path .. urlencode(artwork_name_candidate) .. ".png")
                                end
                                
                            end
                            
                            local artwork_tmp_name = artwork_name_candidate:gsub("[/:\\]+", "_")
                            artwork_file_tmp = tostring("ux0:/data/RetroFlow/" .. artwork_tmp_name .. ".png")

                            Network.downloadFile(artwork_file_url, artwork_file_tmp)

                            -- Check filesize of download, if large enough, move to artwork dir, if not then delete
                            if System.doesFileExist(artwork_file_tmp) then

                                tmpfile = System.openFile(artwork_file_tmp, FREAD)
                                size = System.sizeFile(tmpfile)
                                if tmpfile then
                                    System.closeFile(tmpfile)
                                end
                                if size < 1024 then
                                    System.deleteFile(artwork_file_tmp)
                                else
                                    -- artwork sucessfully downloaded
                                    artwork_found = true
                                    System.rename(artwork_file_tmp, artwork_file_dest_path)
                                    artwork_found_count = artwork_found_count + 1
                                end

                                -- Delete image if not in artwork folder
                                if System.doesFileExist(artwork_file_tmp) then
                                    System.deleteFile(artwork_file_tmp) 
                                end
                            end
                        end
                    end
                end

                if artwork_found == true then
                    
                    -- Update table with cover
                        if download_mode_covers == true then
                            file.icon_path=artwork_file_dest_path
                            file.cover = true
                        end

                    -- Check if in recently played and update recently played cover if found
                        if download_mode_covers == true then
                            if #recently_played_table ~= nil then
                                key = find_game_table_pos_key(recently_played_table, file.filename)
                                if key ~= nil then
                                    recently_played_table[key].icon_path=artwork_file_dest_path
                                    recently_played_table[key].cover = true
                                end
                            end
                        end
                end


                -- Print result

                    Graphics.initBlend()
                    Screen.clear()

                    -- Draw artwork
                    if System.doesFileExist(artwork_file_dest_path) then

                        artwork_img = Graphics.loadImage(artwork_file_dest_path)

                        if artwork_img then

                            -- get_artwork_scale
                            
                            local portrait = false
                            local landscape = false
                            local square = false

                            artwork_width = Graphics.getImageWidth(artwork_img)
                            artwork_height = Graphics.getImageHeight(artwork_img)

                            vita_screen_width = 960
                            vita_screen_height = 544

                            if download_mode_covers == true then
                                artwork_width_max = 300
                                artwork_height_max = 300
                            else
                                artwork_width_max = 480
                                artwork_height_max = 300
                            end

                          
                            if artwork_height == artwork_width then
                                square = true
                                artwork_scale_percentage = (artwork_height_max / artwork_height) * 100

                            elseif artwork_height > artwork_width then
                                portrait = true
                                artwork_scale_percentage = (artwork_height_max / artwork_height) * 100
                            else
                                landscape = true
                                artwork_scale_percentage = (artwork_width_max / artwork_width) * 100
                            end

                            -- Vertical and horizontal centred X and Y position
                            local scale = artwork_scale_percentage / 100
                            artwork_x_pos = (vita_screen_width - artwork_width * scale) / 2
                            artwork_y_pos = (vita_screen_height - artwork_height * scale) / 2

                            -- Draw scaled image
                            Graphics.drawScaleImage(artwork_x_pos, artwork_y_pos, artwork_img, scale, scale)

                            -- Add dark overlay for snaps
                            -- if download_mode_snaps == true then
                            --     Graphics.fillRect(0, 960, 0, 544, img_loader_blackalpha)
                            -- end
                            Graphics.fillRect(0, 960, 0, 544, img_loader_blackalpha)

                        else
                        end
                    end

                    crc_download_progress_bar_update()

                    Font.print(fnt22, 10, 10, tostring(file.title), white)

                    if setLanguage == 9 or setLanguage == 10 or setLanguage == 17 or setLanguage == 18 or setLanguage == 19 then
                        -- Reverse order of numbering xxx/x : Japanese, Chinese (Traditional), Korean, Chinese (Simplified), Japanese (Ryukyuan)
                        Font.print(fnt22, 10, 35, tostring(missing_artwork_total) .. lang_lines.of .. tostring(crcs_checked), white)
                    else
                        -- Normal x/xxx
                        Font.print(fnt22, 10, 35, tostring(crcs_checked) .. lang_lines.of .. tostring(missing_artwork_total), white)
                    end
                    
                    Graphics.termBlend()
                    Screen.flip()

                    -- Unload image
                    if artwork_img then
                        Graphics.freeImage(artwork_img)
                        artwork_img = nil
                    end

                    -- Prevent vita from suspending - the screen can dim and turn off
                    System.resetTimer(AUTO_SUSPEND_TIMER)                
                
        end

        -- Update CRC user table
        crc_download_print_crc_results_table()

        -- Cache all tables
        cache_all_tables()
        update_cached_table_recently_played()
        
        if download_mode_covers == true and artwork_found_count > 0 then
            -- Downloaded covers change icon_path while old placeholder textures may still be cached.
            -- Clear loaded cover textures so the games screen reloads from the updated paths.
            FreeIcons()
            startCovers = false
            startup_cover_prewarm_pending = true

            -- Refresh cover widths for current category after downloading covers (only needed for flat view)
            if showView == 5 then
                refresh_current_category_cover_widths()
            end
        end

        -- Turn on the vita display once the scan is complete
        -- Extended.DisplayPower(1)

        gettingCovers = false
        gettingBackgrounds = false

    else
        -- There aren't any missing covers/snaps
        Graphics.initBlend()
        Screen.clear()
        Font.print(fnt22, 10, 10, tostring(lang_lines.No_missing_artwork), white)
        Graphics.termBlend()
        Screen.flip()
        System.wait(2000000)

        gettingCovers = false
        gettingBackgrounds = false
    end
end


function get_cover_scale(icon)

    cover_height = Graphics.getImageHeight(icon)
    cover_width = Graphics.getImageWidth(icon)

    fv_cover_scale = fv_cover_height / cover_height
    fv_cover_scale_px = cover_width * fv_cover_scale

    -- return fv_cover_scale_px
end

-- Predict cover width based on app type using common cover dimensions
function get_predicted_cover_width(app_type, icon_path)
    -- Common cover sizes before scaling:
    -- PSP = 180w x 320h, Vita = 250w x 320h, NDS = 278w x 250h
    
    local predicted_width = fv_cover_height -- Default square fallback
    
    if app_type == 1 then 
        -- Vita
        if icon_path and string.find(icon_path, "ur0:/appmeta/") then
            predicted_width = fv_cover_height  -- Keep square for app icons
        else
            predicted_width = math.floor((250 / 320) * fv_cover_height + 0.5)
        end

    elseif app_type == 2 then 
        -- PSP
        predicted_width = math.floor((180 / 320) * fv_cover_height + 0.5)

    elseif app_type == 5 or app_type == 6 then 
        -- n64, snes
        predicted_width = math.floor((300 / 220) * fv_cover_height + 0.5)

    elseif app_type == 7 or app_type == 15 or app_type == 23 or app_type == 24 or app_type == 37 or app_type == 38 then 
        -- nes, sms, wswan, wswan col, neogeo, ngpc
        predicted_width = math.floor((223 / 320) * fv_cover_height + 0.5)

    elseif app_type == 13 or app_type == 14 or app_type == 16 then 
        -- 32x, md, gamegear
        predicted_width = math.floor((227 / 320) * fv_cover_height + 0.5)

    elseif app_type == 17 then -- tg16
        predicted_width = math.floor((223 / 293) * fv_cover_height + 0.5)

    elseif app_type == 21 or app_type == 40 or app_type == 44 or app_type == 45 or app_type == 46 then 
        -- amiga, scummvm, atari st, dos, easyrpg
        predicted_width = math.floor((223 / 270) * fv_cover_height + 0.5) -- approx

    elseif app_type == 22 or app_type == 25 or app_type == 26 or app_type == 27 then 
        -- c64, mx2, mx1, zxs
        predicted_width = math.floor((180 / 250) * fv_cover_height + 0.5)

    elseif app_type == 28 or app_type == 29 or app_type == 30 or app_type == 32 or app_type == 33 then 
        -- atari 7800, atari 5200, atari 2600, coleco, vectrex
        predicted_width = math.floor((235 / 320) * fv_cover_height + 0.5)

    elseif app_type == 31 then -- atari lynx
        predicted_width = math.floor((267 / 320) * fv_cover_height + 0.5)

    elseif app_type == 34 or app_type == 35 or app_type == 36 then 
        -- fba, mame, mame, 
        predicted_width = math.floor((223 / 300) * fv_cover_height + 0.5)

    elseif app_type == 39 then 
        -- psm
        if icon_path and string.find(icon_path, "ur0:/appmeta/") then
            predicted_width = fv_cover_height  -- Keep square for app icons
        else
            predicted_width = math.floor((854 / 480) * fv_cover_height + 0.5)
        end

    elseif app_type == 41 then -- pico8
        predicted_width = math.floor((160 / 205) * fv_cover_height + 0.5)

    elseif app_type == 43 or app_type == 47 then -- 3ds, ds
        predicted_width = math.floor((278 / 250) * fv_cover_height + 0.5)

    else 
        -- Square, psx, gba, gbc, gb, dreamcast, pce, pcecd, tgcd, sega cd (sizes vary), sysapp
        predicted_width = fv_cover_height
    end
    
    return predicted_width
end

-- Refresh precomputed width for a specific game after cover download
function refresh_cover_width(file)
    if file and file.icon_path then
        local cover_path = file.icon_path
        if cover_path and System.doesFileExist(cover_path) then
            local width, height = Extended.getPNGDimensions(cover_path)
            if width and height then
                local cover_scale = fv_cover_height / height
                file.precomputed_width = math.floor(width * cover_scale + 0.5)
            else
                -- Fallback to predicted width if dimensions can't be read
                file.precomputed_width = get_predicted_cover_width(file.app_type or 0, file.icon_path)
            end
        else
            -- Cover doesn't exist, use predicted width
            file.precomputed_width = get_predicted_cover_width(file.app_type or 0, file.icon_path)
        end
    end
end

-- Refresh precomputed widths for all games in current category
function refresh_current_category_cover_widths()
    if xCatLookup(showCat) then
        for k, file in pairs(xCatLookup(showCat)) do
            refresh_cover_width(file)
        end
    end
end

-- Pre-compute cover widths using PNG dimensions (smart lazy loading)
function precompute_cover_widths_range(def, start_idx, end_idx)
    for i = math.max(1, start_idx), math.min(#def, end_idx) do
        local file = def[i]
        
        -- Skip if already computed
        if not file.precomputed_width then
            local cover_path = file.icon_path
            if cover_path and System.doesFileExist(cover_path) then
                local width, height = Extended.getPNGDimensions(cover_path)
                if width and height then
                    local cover_scale = fv_cover_height / height
                    file.precomputed_width = math.floor(width * cover_scale + 0.5)
                else
                    -- Use predicted width based on app type instead of square default
                    file.precomputed_width = get_predicted_cover_width(file.app_type or 0, file.icon_path)
                end
            else
                -- Use predicted width based on app type instead of square default
                file.precomputed_width = get_predicted_cover_width(file.app_type or 0, file.icon_path)
            end
        end
    end
end

-- Smart precomputation around current position
function smart_precompute_covers(def, current_pos)
    local batch_size = 50  -- Process 50 covers at a time
    
    -- Adaptive lookahead based on likely cover widths
    -- PSP/Vita covers are narrower, so we need more lookahead
    local lookahead = 40   -- Increased from 25 to handle more covers on screen
    if #def > 0 and def[1] then
        -- Check app type to adjust lookahead
        if def[1].app_type == 1 or def[1].app_type == 2 then  -- Vita or PSP
            lookahead = 60  -- Even more for narrow covers
        end
    end
    
    -- Compute range around current position
    local start_range = current_pos - lookahead
    local end_range = current_pos + lookahead
    
    precompute_cover_widths_range(def, start_range, end_range)
    
    -- Enhanced wraparound precomputation
    local wraparound_size = 25  -- Increased from 10
    
    -- If we're near the beginning, also pre-compute some from the end (for wraparound)
    if current_pos <= wraparound_size and #def > 100 then
        precompute_cover_widths_range(def, #def - wraparound_size, #def)
    end
    
    -- If we're near the end, also pre-compute some from the beginning (for wraparound)
    if current_pos >= #def - wraparound_size and #def > 100 then
        precompute_cover_widths_range(def, 1, wraparound_size)
    end
end

-- Background precomputation for idle time
function background_precompute_covers(def, current_pos)
    -- Initialize background computation state if needed
    if not background_compute_index then
        background_compute_index = 1
        background_compute_direction = 1  -- 1 for forward, -1 for backward
    end
    
    -- Only process a few covers per frame to avoid lag
    local covers_per_frame = 3
    local processed = 0
    
    while processed < covers_per_frame and background_compute_index >= 1 and background_compute_index <= #def do
        local file = def[background_compute_index]
        
        -- Only compute if not already done
        if not file.precomputed_width then
            local cover_path = file.icon_path
            if cover_path and System.doesFileExist(cover_path) then
                local width, height = Extended.getPNGDimensions(cover_path)
                if width and height then
                    local cover_scale = fv_cover_height / height
                    file.precomputed_width = math.floor(width * cover_scale + 0.5)
                else
                    -- Use predicted width based on app type instead of square default
                    file.precomputed_width = get_predicted_cover_width(file.app_type or 0, file.icon_path)
                end
            else
                -- Use predicted width based on app type instead of square default
                file.precomputed_width = get_predicted_cover_width(file.app_type or 0, file.icon_path)
            end
            processed = processed + 1
        end
        
        -- Move to next index
        background_compute_index = background_compute_index + background_compute_direction
        
        -- Change direction when reaching ends
        if background_compute_index > #def then
            background_compute_direction = -1
            background_compute_index = #def - 1
        elseif background_compute_index < 1 then
            background_compute_direction = 1
            background_compute_index = 2
        end
    end
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
    -- Keep fractional precision for smoother movement
    local precise_x = x * (fv_cover_height + fv_gutter) + cover_widths_x_bonus + fv_left_margin

    if sel >= p then
       cover_widths_x_bonus = cover_widths_x_bonus + fv_cover_scale_px - fv_cover_height

    elseif sel == p-1 then
        -- Add dark overlay to cover left of current
        precise_x = precise_x + fv_cover_height - fv_cover_scale_px
        -- Use math.floor for overlay positioning to prevent gaps
        Graphics.fillRect(math.floor(precise_x), math.floor(precise_x) + fv_cover_scale_px, fv_cover_y, fv_cover_y + fv_cover_height, Color.new(0,0,0,75))
    end

    if sel == p then
        -- Use math.floor for border to prevent gaps
        Graphics.fillRect(math.floor(precise_x) - fv_border, math.floor(precise_x) + fv_cover_scale_px + fv_border, fv_cover_y - fv_border, fv_cover_y + fv_cover_height + fv_border, white)
    end

    Graphics.setImageFilters(icon, FILTER_LINEAR, FILTER_LINEAR)

    -- Use precise positioning for the actual cover image
    Graphics.drawScaleImage(precise_x, fv_cover_y, icon, fv_cover_scale, fv_cover_height / cover_height)

    -- Add dark overlay to cover left of current
    if sel == master_index -1 then
        Graphics.fillRect(math.floor(precise_x), math.floor(precise_x) + fv_cover_scale_px, fv_cover_y, fv_cover_y + fv_cover_height, Color.new(0,0,0,75))
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
    load_cover_models_for_app_type(apptype)

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

        if apptype == 43 or apptype == 47 then
            return modCoverNDS
        end

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
        elseif  box_height_dif >= 47     and box_height_dif < 48    then return modCoverNDS         -- 278:250 = 47.35
        else
            if apptype==5 or apptype==6 or apptype==7 or apptype==8 or apptype==9 or apptype==10 then
                return  modCoverN64 -- Average approx 42.31
            else
                return modCoverGB
            end
        end

    end

    function closestBoxNoref()

        if apptype == 43 or apptype == 47 then
            return modCoverNDSNoref
        end

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
        elseif  box_height_dif >= 47     and box_height_dif < 48    then return modCoverNDSNoref         -- 278:250 = 47.35
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
        elseif apptype==5 or apptype==6 or apptype==7 or apptype==8 or apptype==9 or apptype==10 or apptype==12 or apptype==17 or apptype==18 or apptype==19 or apptype==20 or apptype==21 or apptype==34 or apptype==35 or apptype==36 or apptype==38 or apptype==43 or apptype==44 or apptype==45 or apptype==46 or apptype==47 then
            -- Get closest cover: N64, Snes, Nes, GBA, GBC, GB, Sega CD, TG16, TG CD, PCE, PCE CD, Amiga, FBA, Mame 2003, Mame 2000, nds, atari st, dos, easyrpg
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

FileLoad = FileLoad or {}
flat_cleanup_table = nil
flat_cleanup_start = nil
flat_cleanup_end = nil
deferred_free_images = {}
deferred_free_image_lookup = {}

function queue_deferred_free_image(image)
    if image and deferred_free_image_lookup[image] ~= true then
        table.insert(deferred_free_images, image)
        deferred_free_image_lookup[image] = true
    end
end

-- Frees cover textures one frame after Lua tables stop referencing them, giving
-- pending GXM draw work and cancelled async image loads time to finish cleanly.
function process_deferred_free_images()
    for k, image in ipairs(deferred_free_images) do
        Graphics.freeImage(image)
    end

    deferred_free_images = {}
    deferred_free_image_lookup = {}
end

function free_loaded_icon(file)
    if file then
        if FileLoad[file] == true then
            FileLoad[file] = nil
            Threads.remove(file)
        end
        if file.ricon then
            queue_deferred_free_image(file.ricon)
            file.ricon = nil
        end
    end
end

-- LAST PLAYED GAME - Queue a cover through the existing threaded image loader, but only once per file.
function queue_cover_image_load(file)
    if file and FileLoad[file] == nil then
        FileLoad[file] = true
        Threads.addTask(file, {
            Type = "ImageLoad",
            Path = file.icon_path,
            Table = file,
            Index = "ricon"
        })
    end
end

-- LAST PLAYED GAME - On a last-played startup jump, load the selected cover first, then nearby covers.
-- The range is clamped so jumps near the start/end of a table do not overrun.
function prewarm_covers_around_position(def)
    if not startup_cover_prewarm_pending or not def or #def == 0 or p < 1 or p > #def then
        return
    end

    startup_cover_prewarm_pending = false

    local range = 8
    queue_cover_image_load(def[p])

    for offset = 1, range do
        local right_idx = p + offset
        local left_idx = p - offset

        if right_idx <= #def then
            queue_cover_image_load(def[right_idx])
        end

        if left_idx >= 1 then
            queue_cover_image_load(def[left_idx])
        end
    end
end

function FreeIcons()
    Threads.bumpGeneration()

    flat_cleanup_table = nil
    flat_cleanup_start = nil
    flat_cleanup_end = nil

    local icon_tables = {
        files_table, games_table, psp_table, psx_table, psm_table, n64_table,
        snes_table, nes_table, n3ds_table, nds_table, gba_table, gbc_table, gb_table,
        dreamcast_table, sega_cd_table, s32x_table, md_table, sms_table,
        gg_table, tg16_table, tgcd_table, pce_table, pcecd_table, amiga_table,
        scummvm_table, pico8_table, c64_table, wswan_col_table, wswan_table,
        msx2_table, msx1_table, zxs_table, atari_7800_table, atari_5200_table,
        atari_2600_table, atari_lynx_table, colecovision_table, vectrex_table,
        fba_table, mame_2003_plus_table, mame_2000_table, neogeo_table,
        ngpc_table, atari_st_table, dos_table, easyrpg_table, sysapps_table,
        recently_played_table, homebrews_table, search_results_table
    }

    for k, icon_table in ipairs(icon_tables) do
        for l, v in pairs(icon_table or {}) do
            free_loaded_icon(v)
        end
    end

    if collection_count > 0 then
        for collection_showcat = 51, collection_syscount do
            for k, v in pairs(xCatLookup(collection_showcat) or {}) do
                free_loaded_icon(v)
            end
        end
    end

end

function DownloadSingleCover()
    cvrfound = 0
    app_idx = p
    running = false
    status = System.getMessageState()
    
    local coverspath = ""
    local onlineCoverspath = ""
    
    if Network.isWifiEnabled() then
        
        coverspath = xAppNumLookup_Cover_Path_Local(xCatLookup(showCat)[p].app_type)
        onlineCoverspath = xAppNumLookup_Cover_Path_Online(xCatLookup(showCat)[p].app_type)

        if setCRCScan == 1 then

            if xAppNumCRCLookupDB(xCatLookup(showCat)[p].app_type) == false then
                -- CRC unavailable for this system
                if xCatLookup(showCat)[p].app_type == 43 or xCatLookup(showCat)[p].app_type == 47 then
                    -- NDS
                    name_title = xCatLookup(showCat)[p].titleid:gsub("\n","")
                else
                    name_title = xCatLookup(showCat)[p].name:gsub("\n","")
                end
            else
                -- CRC available, try to match
                crc_download_load_previous_crc_matches()
                local crc_result = crc_download_crc_matched_name(xCatLookup(showCat)[p])
                if crc_result then
                    name_title = crc_result:gsub("\n", "")
                else
                    name_title = app_titleid:gsub("\n", "")
                end
            end

        else
            if xCatLookup(showCat)[p].app_type == 43 or xCatLookup(showCat)[p].app_type == 47 then
                -- NDS
                name_title = xCatLookup(showCat)[p].titleid:gsub("\n","")
            else
                name_title = xCatLookup(showCat)[p].name:gsub("\n","")
            end
        end

        if onlineCoverspath:find("libretro") then

            name_after_libretro_gsub = {}

            -- Libretro - Replace these characters &*/:`<>?\|" with an underscore _ to match libretro naming convention
            if apptype == 21 then
                -- Amiga fix
                name_after_libretro_gsub = xCatLookup(showCat)[p].name_title_search:gsub("[&*/:`<>?\\|\"]+", "_")
                Network.downloadFile(onlineCoverspath .. xCatLookup(showCat)[p].name_title_search:gsub("[&*/:`<>?\\|\"]+", "_"):gsub("%s+", '%%20') .. ".png", "ux0:/data/RetroFlow/" .. name_title .. ".png")
            else
                name_after_libretro_gsub = name_title:gsub("[&*/:`<>?\\|\"]+", "_")
            end

            Network.downloadFile(onlineCoverspath .. name_after_libretro_gsub:gsub("%s+", '%%20') .. ".png", "ux0:/data/RetroFlow/" .. name_title .. ".png")

        else

            -- Not libretro
            if apptype == 21 then
            -- Amiga fix
                Network.downloadFile(onlineCoverspath .. xCatLookup(showCat)[p].name_title_search:gsub("%s+", '%%20') .. ".png", "ux0:/data/RetroFlow/" .. name_title .. ".png")
            else
                Network.downloadFile(onlineCoverspath .. name_title:gsub("%s+", '%%20') .. ".png", "ux0:/data/RetroFlow/" .. name_title .. ".png")
            end
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

        end

        if cvrfound==1 then
            if showCat == 2 then -- Homebrew do nothing
                
            elseif showCat >= 1 and showCat <= 46 then
                -- Normal systems
                update_cvrfound_showcats(xCatLookup(showCat), xCatDbFileLookup(showCat))

            elseif showCat == 48 then 
                -- Favourites
                update_cvrfound_showcats(fav_count, "db_files.lua")

            elseif showCat == 49 then 
                -- Recent
                update_cvrfound_showcats_recent()

            elseif showCat == 50 then 
                -- Search results
                update_cvrfound_showcats(search_results_table, "db_files.lua")

            elseif showCat >= 51 then
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
    
    -- Refresh cover width for the current game after download (only needed for flat view)
    if showView == 5 and xCatLookup(showCat) and xCatLookup(showCat)[p] then
        refresh_cover_width(xCatLookup(showCat)[p])
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

        snapPath = xAppNumLookup_Snap_Path_Local(xCatLookup(showCat)[p].app_type)
        onlineSnapPath = xAppNumLookup_Snap_Path_Online(xCatLookup(showCat)[p].app_type)

        if setCRCScan == 1 then

            if xAppNumCRCLookupDB(xCatLookup(showCat)[p].app_type) == false then
                -- CRC unavailable for this system
                if xCatLookup(showCat)[p].app_type == 43 or xCatLookup(showCat)[p].app_type == 47 then
                    -- NDS
                    name_title = xCatLookup(showCat)[p].titleid:gsub("\n","")
                else
                    name_title = xCatLookup(showCat)[p].name:gsub("\n","")
                end
            else
                -- CRC available, try to match
                crc_download_load_previous_crc_matches()
                local crc_result = crc_download_crc_matched_name(xCatLookup(showCat)[p])
                if crc_result then
                    name_title = crc_result:gsub("\n", "")
                else
                    name_title = app_titleid:gsub("\n", "")
                end
            end
     
        else
            if xCatLookup(showCat)[p].app_type == 43 or xCatLookup(showCat)[p].app_type == 47 then
                -- NDS
                name_title = xCatLookup(showCat)[p].titleid:gsub("\n","")
            else
                name_title = xCatLookup(showCat)[p].name:gsub("\n","")
            end
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
            -- Delete image if not in snap folder
            if System.doesFileExist("ux0:/data/RetroFlow/" .. name_title .. ".png") then
                System.deleteFile("ux0:/data/RetroFlow/" .. name_title .. ".png")
            end
        end

        if bgfound==1 then

            -- Avoid loading the downloaded PNG into a GPU texture in the same frame as the HTTP write/rename.
            -- The info screen will rebuild pic_path and load it through the normal background path on the next frame.
            Render.useTexture(modBackground, imgCustomBack)
            inPreview = false
            GetInfoSelected()

            -- Update recently played background if found
            -- if #recently_played_table ~= nil then
            --     key = find_game_table_pos_key(recently_played_table, name_title)
            --     if key ~= nil then
            --         recently_played_table[key].snap_path_local=snapPath
            --         update_cached_table_recently_played()
            --     else
            --     end
            -- else
            -- end
            

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

    local icon_x = 685 - time24_offset + pstv_offset + wifi_offset
    local icon_y = 36
    local icon_space = 37

    local function draw_next_icon(icon)
        Graphics.drawImage(icon_x, icon_y, icon)
        icon_x = icon_x - icon_space
    end

    favourite_flag = (def)[p].favourite
    cartridge_flag = (def)[p].cartridge
    hide_game_flag = (def)[p].hidden
    
    if cartridge_flag == true then
        if (def)[p].cartridge_inserted == true then
            draw_next_icon(cart_icon_on)
        else
            draw_next_icon(cart_icon_off)
        end
    end

    if favourite_flag == true then
        draw_next_icon(imgFavorite_small_on)
    end

    if hide_game_flag == true then
        draw_next_icon(imgHidden_small_on)
    end

end


function drawCategory (def)
    prewarm_covers_around_position(def)

    -- Draw flat covers - SMART LAZY PRE-COMPUTATION
    if showView == 5 then

        -- Common render distance calculation
        local render_distance
        if (def)[p+7] and (def)[p+7].ricon then -- Credit BlackSheepBoy69
            render_distance = 16
        else
            render_distance = 8
        end

        if smoothScrolling == 1 then
            -- Gradual background precomputation to avoid lag spikes
            -- Process a few covers per frame instead of all at once
            if p > 1 then
                -- Process only 2-3 covers per frame to spread the work
                local covers_per_frame = 3
                local start_idx = math.max(1, p - 10)
                local end_idx = math.min(#def, start_idx + covers_per_frame - 1)
                
                -- Rotate through covers around current position
                local frame_offset = (p % 10)  -- Simple rotation based on current position
                start_idx = start_idx + (frame_offset * covers_per_frame) % 20
                end_idx = math.min(#def, start_idx + covers_per_frame - 1)
                
                precompute_cover_widths_range(def, start_idx, end_idx)
            end

            -- Initialize smooth scrolling with safe defaults
            if not flat_view_scroll_x then
                flat_view_scroll_x = 0
                flat_view_target_x = 0
                -- Will be corrected to proper position after cover_positions is calculated
            end

            -- Calculate positions efficiently (only for visible range + buffer)
            render_distance = 20  -- Override for smooth scrolling
            local visible_start = math.max(1, p - render_distance)
            local visible_end = math.min(#def, p + render_distance)
            
            -- Calculate cumulative position up to visible range
            local cumulative_x = 0
            local cover_gap = 20
            
            -- Fast calculation to get to the visible range start
            for i = 1, visible_start - 1 do
                local cover_width = def[i].precomputed_width or get_predicted_cover_width(def[i].app_type or 0, def[i].icon_path)
                cumulative_x = cumulative_x + cover_width + cover_gap
            end
            
            -- Store the start position for selected cover calculation
            local start_offset = cumulative_x
            
            -- Calculate positions for visible range
            local cover_positions = {}
            for i = visible_start, visible_end do
                cover_positions[i] = cumulative_x
                local cover_width = def[i].precomputed_width or get_predicted_cover_width(def[i].app_type or 0, def[i].icon_path)
                cumulative_x = cumulative_x + cover_width + cover_gap
            end

            -- Calculate position for selected cover (if not in visible range, estimate)
            local selected_cover_pos
            if cover_positions[p] then
                selected_cover_pos = cover_positions[p]
            else
                -- Estimate position for out-of-range selection (for big jumps)
                selected_cover_pos = start_offset
                for i = visible_start, p do
                    local cover_width = def[i].precomputed_width or get_predicted_cover_width(def[i].app_type or 0, def[i].icon_path)
                    if i < p then
                        selected_cover_pos = selected_cover_pos + cover_width + cover_gap
                    end
                end
            end
            
            -- Fix initial position on first load to prevent startup animation jump
            if flat_view_scroll_x == 0 and flat_view_target_x == 0 then
                local initial_target = -selected_cover_pos + fv_left_margin
                flat_view_scroll_x = initial_target
                flat_view_target_x = initial_target
            end
            
            local target_scroll = -selected_cover_pos + fv_left_margin
            
            -- Update target when selection changes
            if target_scroll ~= flat_view_target_x then
                flat_view_target_x = target_scroll
            end

            -- Smooth scrolling animation (or instant if disabled)
            local distance = flat_view_target_x - flat_view_scroll_x
            if math.abs(distance) > 0.5 then
                flat_view_scroll_x = flat_view_scroll_x + distance * 0.08
            else
                flat_view_scroll_x = flat_view_target_x
            end

            -- Draw covers in visible range
            for l = visible_start, visible_end do
                local file = def[l]
                
                -- Ensure image is loaded
                if FileLoad[file] == nil then
                    FileLoad[file] = true
                    Threads.addTask(file, {
                        Type = "ImageLoad",
                        Path = file.icon_path,
                        Table = file,
                        Index = "ricon"
                    })
                end

                -- Get the appropriate icon
                local icon = file.ricon or file.icon
                if icon then
                    -- Calculate final position using pre-computed width for positioning
                    local cover_x = cover_positions[l] + flat_view_scroll_x
                    local precomputed_width = file.precomputed_width or get_predicted_cover_width(file.app_type or 0, file.icon_path)

                    -- Only draw if visible on screen
                    if cover_x + precomputed_width > -50 and cover_x < 1010 then
                        -- Use precomputed_width for border (which includes predicted width fallback)
                        local render_width = precomputed_width

                        -- Draw white border for selected cover using predicted/computed dimensions
                        if l == p then
                            Graphics.fillRect(cover_x - fv_border, cover_x + render_width + fv_border, 
                                            fv_cover_y - fv_border, fv_cover_y + fv_cover_height + fv_border, white)
                        end

                        -- Set image filters and draw cover with predicted dimensions
                        Graphics.setImageFilters(icon, FILTER_LINEAR, FILTER_LINEAR)
                        
                        -- Check if this is the default placeholder image (always scale to predicted width)
                        if icon == imgCoverTmp or not file.precomputed_width then
                            -- Scale to predicted width for uncomputed covers or default placeholder
                            Graphics.drawScaleImage(cover_x, fv_cover_y, icon, render_width / Graphics.getImageWidth(icon), fv_cover_height / Graphics.getImageHeight(icon))
                        else
                            -- Use actual scale for computed covers
                            local cover_height = Graphics.getImageHeight(icon)
                            local cover_scale = fv_cover_height / cover_height
                            Graphics.drawScaleImage(cover_x, fv_cover_y, icon, cover_scale, fv_cover_height / cover_height)
                        end

                        -- Add dark overlay to cover left of current with very subtle fade-in
                        if l == p - 1 then
                            local distance = math.abs(flat_view_target_x - flat_view_scroll_x)
                            local fade_start_distance = 20  -- Start fading in when 20 pixels away
                            
                            if distance < fade_start_distance then
                                -- Calculate opacity with slower, more subtle progression
                                local opacity_factor = 1 - (distance / fade_start_distance)
                                -- Use quadratic easing for slower start
                                opacity_factor = opacity_factor * opacity_factor
                                local overlay_opacity = math.floor(75 * opacity_factor)
                                
                                if overlay_opacity > 2 then  -- Draw even very faint overlays
                                    Graphics.fillRect(cover_x, cover_x + render_width, fv_cover_y, fv_cover_y + fv_cover_height, Color.new(0,0,0,overlay_opacity))
                                end
                            end
                        end

                        -- Draw category icons for current cover
                        if l == p then
                            drawCategory_icons(def)
                        end
                    end
                end
            end

        else
            -- Non-smooth scrolling mode - original rendering logic
            base_y = fv_left_margin
            base_y_left = 0
            cover_widths_x_bonus = 0

            for l, file in pairs((def)) do
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
                                DrawCover_Flat(base_y,152,file.name,color, file.ricon, l)

                                if fv_cover_scale_px ~= nil then
                                    base_y = base_y + fv_cover_scale_px + fv_gutter
                                end
                            else
                                get_cover_scale(file.icon)
                                DrawCover_Flat(base_y,152,file.name,color, file.icon, l)
                                if fv_cover_scale_px ~= nil then
                                    base_y = base_y + fv_cover_scale_px + fv_gutter
                                end
                            end

                        -- Draw one previous cover to left
                        elseif (l == master_index -1) then
                            if file.ricon ~= nil then
                                get_cover_scale(file.ricon)
                                if fv_cover_scale_px ~= nil then
                                    base_y_left = 0 - fv_cover_scale_px + fv_left_margin - fv_gutter
                                    DrawCover_Flat(base_y_left,152,file.name,color, file.ricon, l)
                                end
                            else
                                get_cover_scale(file.icon)
                                if fv_cover_scale_px ~= nil then
                                    base_y_left = 0 - fv_cover_scale_px + fv_left_margin - fv_gutter
                                    DrawCover_Flat(base_y_left,152,file.name,color, file.icon, l)
                                end
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
                end
            end
        end

        -- Common cleanup for both modes - only clean up images outside render distance
        local cleanup_start, cleanup_end
        if smoothScrolling == 1 then
            cleanup_start = math.max(1, p - 20)
            cleanup_end = math.min(#def, p + 20)
        else
            cleanup_start = math.max(1, p - render_distance)
            cleanup_end = math.min(#def, p + render_distance + 2)
        end

        if flat_cleanup_table ~= def then
            for k, v in pairs(def) do
                if k < cleanup_start or k > cleanup_end then
                    free_loaded_icon(v)
                end
            end
        elseif flat_cleanup_start ~= cleanup_start or flat_cleanup_end ~= cleanup_end then
            local old_start = flat_cleanup_start or cleanup_start
            local old_end = flat_cleanup_end or cleanup_end

            for k = old_start, old_end do
                if k < cleanup_start or k > cleanup_end then
                    free_loaded_icon(def[k])
                end
            end
        end

        flat_cleanup_table = def
        flat_cleanup_start = cleanup_start
        flat_cleanup_end = cleanup_end


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
                        else
                            DrawCover_List(file.icon)
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
        
    -- Draw status icons for the selected game once per frame
    if #def > 0 and p > 0 and p <= #def then
        drawCategory_icons(def)
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

-- Function to detect inserted Vita cartridge
function get_inserted_cartridge_titleid()
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

function find_cartridge_in_table(def_table, def_titleid)
    if not def_table or not def_titleid then
        return nil
    end

    for idx = 1, #def_table do
        local game = def_table[idx]
        if game and (game.titleid == def_titleid or game.name == def_titleid or game.filename == def_titleid) then
            return idx
        end
    end

    return nil
end

function sync_cartridge_state_in_table(def_table, def_titleid, def_inserted)
    if not def_table or not def_titleid then
        return
    end

    for idx = 1, #def_table do
        local game = def_table[idx]
        if game and (game.titleid == def_titleid or game.name == def_titleid or game.filename == def_titleid) then
            game.cartridge_inserted = def_inserted
        end
    end
end

function sync_cartridge_state(def_titleid, def_inserted)
    if not def_titleid then
        return
    end

    if cartridge_games[def_titleid] then
        cartridge_games[def_titleid].cartridge_inserted = def_inserted
    end

    sync_cartridge_state_in_table(games_table, def_titleid, def_inserted)
    sync_cartridge_state_in_table(files_table, def_titleid, def_inserted)
    sync_cartridge_state_in_table(files_table_no_sysapps, def_titleid, def_inserted)
    sync_cartridge_state_in_table(recently_played_table, def_titleid, def_inserted)
    sync_cartridge_state_in_table(fav_count, def_titleid, def_inserted)

    if collection_files and collection_syscount then
        for collection_showcat = 51, collection_syscount do
            sync_cartridge_state_in_table(xCatLookup(collection_showcat), def_titleid, def_inserted)
        end
    end
end

function current_category_supports_cartridge_jump()
    return showCat == 0 or showCat == 1 or showCat == 48 or showCat == 49 or (showCat >= 51 and showCat <= collection_syscount)
end

function skip_empty_collection_categories(def_direction)
    if collection_count == 0 or showCat < 51 or showCat > collection_syscount then
        return
    end

    local checked_collections = 0
    local collection_table = xCatLookup(showCat)
    while showCat >= 51 and showCat <= collection_syscount and (collection_table == nil or next(collection_table) == nil) and checked_collections < collection_count do
        if def_direction > 0 then
            if showCat < collection_syscount then
                showCat = showCat + 1
            elseif filterGames == 1 then
                showCat = 51
            elseif showAll == 0 then
                showCat = 1
            else
                showCat = 0
            end
        else
            if showCat > 51 then
                showCat = showCat - 1
            elseif filterGames == 1 then
                showCat = collection_syscount
            else
                showCat = 50
            end
        end

        checked_collections = checked_collections + 1
        collection_table = xCatLookup(showCat)
    end

    if showCat >= 51 and showCat <= collection_syscount and (collection_table == nil or next(collection_table) == nil) then
        if showAll == 0 then
            showCat = 1
        else
            showCat = 0
        end
    end
end

-- Poll cartridge insertion state and handle state changes
function poll_cartridge_state()
    cartridge_poll_frame = cartridge_poll_frame + 1
    if cartridge_poll_frame < 120 then
        return
    end

    cartridge_poll_frame = 0
    local detected_titleid = get_inserted_cartridge_titleid()

    -- Check if the insertion state has actually changed
    -- Either a different cartridge is inserted, or the same cartridge was removed and re-inserted
    local state_changed = false

    if detected_titleid ~= last_inserted_titleid then
        state_changed = true
    elseif detected_titleid and cartridge_games[detected_titleid] and not cartridge_games[detected_titleid].cartridge_inserted then
        -- Same cartridge but it was removed and is now re-inserted
        state_changed = true
    end

    if state_changed then
        -- Cartridge state has changed

        -- Step 1: Clear previous inserted state if it exists
        sync_cartridge_state(last_inserted_titleid, false)

        -- Step 2: Set newly inserted cartridge state if detected
        if detected_titleid and cartridge_games[detected_titleid] then

            -- Known cartridge in live cache
            sync_cartridge_state(detected_titleid, true)

        elseif detected_titleid then
            
            -- Cartridge not in live cache, may not be installed in app.db (only installed when returning to livearea), cleaner to get user to rescan
            -- Do nothing
            goto continue
        end

        -- Step 3: Update tracker
        last_inserted_titleid = detected_titleid

        -- Step 4: Trigger UI update - stay in current relevant category when possible
        if detected_titleid then
            local target_table = nil
            local target_idx = nil

            if current_category_supports_cartridge_jump() then
                if showCat == 48 then
                    refresh_fav_count_table()
                end

                target_table = xCatLookup(showCat)
                target_idx = find_cartridge_in_table(target_table, detected_titleid)
            end

            -- If the inserted game is not in the current relevant category, jump to Vita.
            if not target_idx then
                showCat = 1
                target_table = xCatLookup(1)
                target_idx = find_cartridge_in_table(target_table, detected_titleid)
            end

            if target_table and #target_table > 0 then
                -- If not found by titleid, try to find by matching the newly inserted state
                if not target_idx then
                    for idx = 1, #target_table do
                        if target_table[idx] and target_table[idx].cartridge == true and target_table[idx].cartridge_inserted == true then
                            target_idx = idx
                            break
                        end
                    end
                end

                -- Last resort: just jump to end of list
                p = target_idx or #target_table
                master_index = p

                GetNameAndAppTypeSelected()
            end
        end

        ::continue::

    end
end

-- Capture function load time before main loop starts (major performance optimization)
functionTime = Timer.getTime(oneLoopTimer)

-- Main loop
while true do

    -- Initialize cartridge insertion state on first frame only
    if cartridge_state_initialized == false then
        last_inserted_titleid = get_inserted_cartridge_titleid()

        -- Sync cartridge_inserted state for all known cartridges
        for titleid, game in pairs(cartridge_games) do
            if titleid == last_inserted_titleid then
                sync_cartridge_state(titleid, true)
            else
                sync_cartridge_state(titleid, false)
            end
        end
        cartridge_state_initialized = true
        -- Do NOT jump on startup - only jump when new cartridge is inserted via polling
    end

    -- Threads update
    Threads.update()
    process_deferred_free_images()
    
    -- Reading input
    pad = Controls.read()
    
    -- Reset D-pad counters on button release (using previous frame's oldpad)
    if not Controls.check(pad, SCE_CTRL_LEFT) and Controls.check(oldpad, SCE_CTRL_LEFT) then
        dpadHeldLeft = 0
    end
    if not Controls.check(pad, SCE_CTRL_RIGHT) and Controls.check(oldpad, SCE_CTRL_RIGHT) then
        dpadHeldRight = 0
    end
    if not Controls.check(pad, SCE_CTRL_UP) and Controls.check(oldpad, SCE_CTRL_UP) then
        dpadHeldUp = 0
    end
    if not Controls.check(pad, SCE_CTRL_DOWN) and Controls.check(oldpad, SCE_CTRL_DOWN) then
        dpadHeldDown = 0
    end
    
    mx, my = Controls.readLeftAnalog()

    -- Vita Cartridge Runtime Polling
    if setScanCartridges == 1 then
        poll_cartridge_state()
    end

    -- Idle detection for background precomputation (only for flat view)
    if showView == 5 then
        -- Initialize idle tracking variables
        if not last_selection_p then
            last_selection_p = p
            idle_frame_count = 0
        end
        
        -- Track if user is idle (not changing selection and animation settled)
        local animation_distance = 0
        if flat_view_scroll_x and flat_view_target_x then
            animation_distance = math.abs(flat_view_target_x - flat_view_scroll_x)
        end
        local user_idle = (p == last_selection_p) and (animation_distance < 1)
        
        -- Check for any user input to reset idle state immediately
        if Controls.check(pad, SCE_CTRL_LEFT) or Controls.check(pad, SCE_CTRL_RIGHT) or 
           Controls.check(pad, SCE_CTRL_UP) or Controls.check(pad, SCE_CTRL_DOWN) or
           Controls.check(pad, SCE_CTRL_CROSS) or Controls.check(pad, SCE_CTRL_CIRCLE) or
           Controls.check(pad, SCE_CTRL_TRIANGLE) or Controls.check(pad, SCE_CTRL_SQUARE) or
           mx < 64 or mx > 180 or my < 64 or my > 180 then
            idle_frame_count = 0
        elseif user_idle then
            idle_frame_count = idle_frame_count + 1
            -- Start background computation after being idle for 30 frames (~0.5 seconds)
            if idle_frame_count > 30 and def then
                background_precompute_covers(def, p)
            end
        else
            idle_frame_count = 0
        end
        
        -- Always update last selection for next frame comparison
        last_selection_p = p
    end
    
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
                    if showCat == 50 then
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
                        if game_matches_search(file, ret_search, ret_search_lc, ret_search_uc, ret_search_pc) then
                            table.insert(search_results_table, file)
                            local app_title = search_results_table[1].app_title
                        else
                            local app_title = lang_lines.Search_No_Results -- Workaround - hides last name shown before searching
                        end
                    end
                    table.sort(search_results_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)

                    showCat = 50
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

                    -- Rename game in native category so rebuilt views inherit the change
                    local key = find_game_table_pos_key(xAppNumTableLookup(apptype), app_titleid)
                    if key ~= nil then
                        -- Yes - Found in files table
                        xAppNumTableLookup(apptype)[key].title = ret_rename
                        xAppNumTableLookup(apptype)[key].apptitle = ret_rename
                    else
                        -- No
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
                    if renamed_games_table then
                        local key = find_game_table_pos_key(renamed_games_table, app_titleid)
                        if key ~= nil then
                            -- Yes - it's already in the rename list, update it.
                            renamed_games_table[key].title = ret_rename
                        else
                            -- No, it's new, add it to the rename list
                            table.insert(renamed_games_table, {name = app_titleid, title = ret_rename})
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
                    fav_count_dirty = true
                    refresh_fav_count_table()

                    -- END updating other tables -- 

                    -- If show system apps if off and currently viewing system apps when renaming, must have used quick menu.
                    -- Turn on system apps temporarily so can see the result of the rename.
                    if showSysApps == 0 and showCat == 46 then
                        -- Turn on temporarily
                        showSysApps = 1

                        -- Import and jump to menu
                        FreeIcons()
                        count_cache_and_reload()
                        showCat = 46

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

                    if next(search_results_table) ~= nil then

                        -- Add search results table to collection
                        local search_results_collection_info = {}
                        for k, v in pairs(search_results_table) do
                            local search_results_collection_info = {
                                apptitle = v.title,
                                name = v.name,
                                app_type = v.app_type,
                            }
                            table.insert(new_collection, search_results_collection_info)
                        end

                    else

                        -- Individual game to add to collection
                        new_collection = 
                        { 
                            [1] = 
                            {
                                ["apptitle"] = xCatLookup(showCat)[p].title,
                                ["name"] = xCatLookup(showCat)[p].name,
                                ["app_type"] = xCatLookup(showCat)[p].app_type,
                            },
                        }

                    end

                    update_cached_collection(ret_collection_filename, new_collection)
        
                    if next(search_results_table) ~= nil then

                        -- Reload collections and set current category to our new collection which has been created from the search table
                        create_collections_list()

                        table.sort(collection_files, function(a, b) return (a.filename:lower() < b.filename:lower()) end)
                        update_collections_count()
                        import_collections()

                        keyboard_collection_name_new = false
                        -- Terminating keyboard
                        Keyboard.clear()

                        local new_collection_table_name = ret_collection_filename:gsub(".lua", "")
                        local new_collection_number = 0
                        for i, file in pairs(collection_files) do
                            if file.table_name == new_collection_table_name then
                                new_collection_number = i
                                break
                            end
                        end

                        if new_collection_number > 0 then
                            showCollections = 1
                            set_collection_visible(new_collection_number, true)
                            save_visible_collection_settings()
                            showCat = 50 + new_collection_number -- Collection showCat values start at 51
                            p = 1
                            master_index = p
                            GetNameAndAppTypeSelected()
                            GetInfoSelected()

                            if xCatLookup(showCat) and xCatLookup(showCat)[p] then
                                Threads.addTask(xCatLookup(showCat)[p], {
                                Type = "ImageLoad",
                                Path = xCatLookup(showCat)[p].icon_path,
                                Table = xCatLookup(showCat)[p],
                                Index = "ricon"
                                })
                            end
                        end

                        oldpad = pad -- Prevents it from launching next game accidentally. Credit BlackSheepBoy69
                        showMenu = 0
                        Render.useTexture(modBackground, imgCustomBack)

                        -- Empty the search results table
                        for k in pairs(search_results_table) do
                            search_results_table[k] = nil
                        end
                        mode_add_search_results = false

                    else
                        keyboard_collection_name_new = false
                        -- Terminating keyboard
                        Keyboard.clear()

                        FreeIcons()
                        local new_collection_number = add_new_collection_to_memory(ret_collection_filename, new_collection)

                        if new_collection_number > 0 then
                            showCollections = 1
                            set_collection_visible(new_collection_number, true)
                            save_visible_collection_settings()
                            showCat = 50 + new_collection_number -- Collection showCat values start at 51
                            p = 1
                            master_index = p
                            GetNameAndAppTypeSelected()
                            GetInfoSelected()

                            if xCatLookup(showCat) and xCatLookup(showCat)[p] then
                                Threads.addTask(xCatLookup(showCat)[p], {
                                Type = "ImageLoad",
                                Path = xCatLookup(showCat)[p].icon_path,
                                Table = xCatLookup(showCat)[p],
                                Index = "ricon"
                                })
                            end
                        end

                        oldpad = pad -- Prevents it from launching next game accidentally. Credit BlackSheepBoy69
                        showMenu = 0
                        Render.useTexture(modBackground, imgCustomBack)
                    end

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

                    local old_path = collections_dir .. keyboard_collection_rename_filename
                    local new_path = collections_dir .. ret_rename_collection_new_filename
                    local temp_path = collections_dir .. "__temp_collection.lua"
                
                    if System.doesFileExist(old_path) then
                        -- Step 1: rename to temp
                        System.rename(old_path, temp_path)
                        -- Step 2: rename to final (with correct case)
                        System.rename(temp_path, new_path)
                    else
                    end

                    local new_collection_table_name = ret_rename_collection_new_filename:gsub(".lua", "")
                    if HiddenCollections[keyboard_collection_rename_table_name] == true then
                        HiddenCollections[new_collection_table_name] = true
                    end
                    HiddenCollections[keyboard_collection_rename_table_name] = nil
                    save_hidden_collections()

                    if string.match(startCategory_collection, keyboard_collection_rename_table_name) then
                        startCategory_collection_renamed = new_collection_table_name
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
        elseif showCat == 9 then Font.print(fnt22, 32, 34,  lang_lines.Nintendo_3DS, white)
        elseif showCat == 10 then Font.print(fnt22, 32, 34, lang_lines.Nintendo_DS, white)
        elseif showCat == 11 then Font.print(fnt22, 32, 34, lang_lines.Game_Boy_Advance, white)
        elseif showCat == 12 then Font.print(fnt22, 32, 34, lang_lines.Game_Boy_Color, white)
        elseif showCat == 13 then Font.print(fnt22, 32, 34, lang_lines.Game_Boy, white)
        elseif showCat == 14 then Font.print(fnt22, 32, 34, lang_lines.Sega_Dreamcast, white)
        elseif showCat == 15 then Font.print(fnt22, 32, 34, lang_lines.Sega_CD, white)
        elseif showCat == 16 then Font.print(fnt22, 32, 34, lang_lines.Sega_32X, white)
        elseif showCat == 17 then Font.print(fnt22, 32, 34, lang_lines.Sega_Mega_Drive, white)
        elseif showCat == 18 then Font.print(fnt22, 32, 34, lang_lines.Sega_Master_System, white)
        elseif showCat == 19 then Font.print(fnt22, 32, 34, lang_lines.Sega_Game_Gear, white)        
        elseif showCat == 20 then Font.print(fnt22, 32, 34, lang_lines.TurboGrafx_16, white)
        elseif showCat == 21 then Font.print(fnt22, 32, 34, lang_lines.TurboGrafx_CD, white)
        elseif showCat == 22 then Font.print(fnt22, 32, 34, lang_lines.PC_Engine, white)
        elseif showCat == 23 then Font.print(fnt22, 32, 34, lang_lines.PC_Engine_CD, white)
        elseif showCat == 24 then Font.print(fnt22, 32, 34, lang_lines.Amiga, white)
        elseif showCat == 25 then Font.print(fnt22, 32, 34, lang_lines.ScummVM, white)
        elseif showCat == 26 then Font.print(fnt22, 32, 34, lang_lines.EasyRPG, white)
        elseif showCat == 27 then Font.print(fnt22, 32, 34, lang_lines.MS_DOS, white)
        elseif showCat == 28 then Font.print(fnt22, 32, 34, lang_lines.Commodore_64, white)
        elseif showCat == 29 then Font.print(fnt22, 32, 34, lang_lines.WonderSwan_Color, white)
        elseif showCat == 30 then Font.print(fnt22, 32, 34, lang_lines.WonderSwan, white)
        elseif showCat == 31 then Font.print(fnt22, 32, 34, lang_lines.PICO8, white)
        elseif showCat == 32 then Font.print(fnt22, 32, 34, lang_lines.MSX2, white)
        elseif showCat == 33 then Font.print(fnt22, 32, 34, lang_lines.MSX, white)
        elseif showCat == 34 then Font.print(fnt22, 32, 34, lang_lines.ZX_Spectrum, white)
        elseif showCat == 35 then Font.print(fnt22, 32, 34, lang_lines.Atari_ST, white)
        elseif showCat == 36 then Font.print(fnt22, 32, 34, lang_lines.Atari_7800, white)
        elseif showCat == 37 then Font.print(fnt22, 32, 34, lang_lines.Atari_5200, white)
        elseif showCat == 38 then Font.print(fnt22, 32, 34, lang_lines.Atari_2600, white)
        elseif showCat == 39 then Font.print(fnt22, 32, 34, lang_lines.Atari_Lynx, white)
        elseif showCat == 40 then Font.print(fnt22, 32, 34, lang_lines.ColecoVision, white)
        elseif showCat == 41 then Font.print(fnt22, 32, 34, lang_lines.Vectrex, white)
        elseif showCat == 42 then Font.print(fnt22, 32, 34, lang_lines.FBA_2012, white)
        elseif showCat == 43 then Font.print(fnt22, 32, 34, lang_lines.MAME_2003Plus, white)
        elseif showCat == 44 then Font.print(fnt22, 32, 34, lang_lines.MAME_2000, white)
        elseif showCat == 45 then Font.print(fnt22, 32, 34, lang_lines.Neo_Geo, white)
        elseif showCat == 46 then Font.print(fnt22, 32, 34, lang_lines.Neo_Geo_Pocket_Color, white)
        elseif showCat == 47 then Font.print(fnt22, 32, 34, lang_lines.System_Apps, white)  
        elseif showCat == 48 then Font.print(fnt22, 32, 34, lang_lines.Favorites, white)
        elseif showCat == 49 then Font.print(fnt22, 32, 34, lang_lines.Recently_Played, white)
        elseif showCat == 50 then
            if random_game_selected == false then
                Font.print(fnt22, 32, 34, lang_lines.Search_Results, white)
            else
                Font.print(fnt22, 32, 34, lang_lines.Random_Game, white)
            end            
        elseif showCat >= 51 and showCat <= collection_syscount then Collection_CatNum = showCat - 50 Font.print(fnt22, 32, 34, collection_files[Collection_CatNum].display_name, white)

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
        
        if showCat == 48 then
            refresh_fav_count_table()
            
            drawCategory (fav_count)
            GetNameAndAppTypeSelected() -- Added to refresh names as games removed from fav cat whilst on fav cat

        else
            drawCategory (xCatLookup(showCat))
        end


        -- Smooth move items horizontally
        if targetX ~= base_x then
            local distance = targetX - base_x
            local abs_distance = math.abs(distance)
            
            if smoothScrolling == 1 then
                if showView == 5 then
                    -- Film strip smooth scrolling - slower gentle movement
                    local easing_factor = 0.02  -- Slower smooth movement (was 0.06)
                    local min_movement = 0.18    -- Smaller minimum step (was 0.3)
                    
                    -- Factor in cover width for consistency
                    local cover_width_factor = 1.0
                    if fv_cover_scale_px then
                        cover_width_factor = math.min(1.2, math.max(0.9, fv_cover_scale_px / 200))
                    end
                    
                    easing_factor = easing_factor * cover_width_factor
                    min_movement = min_movement * cover_width_factor
                    
                    local movement = distance * easing_factor
                    
                    if abs_distance > min_movement then
                        if math.abs(movement) < min_movement then
                            movement = (distance > 0) and min_movement or -min_movement
                        end
                        targetX = targetX - movement
                    else
                        targetX = base_x  -- Snap to target when very close
                    end
                else
                    targetX = targetX - ((targetX - base_x) * 0.17)
                end
            else
                targetX = targetX - ((targetX - base_x) * 0.1)
            end
        end


        if smoothScrolling == 1 then
            -- Smooth dezoom factor
            if mx < 64 or mx > 180 or (dpadHeldLeft and dpadHeldLeft > 1) or (dpadHeldRight and dpadHeldRight > 1) then -- Don't zoom on covers if quick scrolling
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
                if apptype == 0 or apptype == 1 then
                    -- Try to decrypt and copy icon0
                    local image_copied = Extended.copyIconToAppmeta(game_path)
                    if image_copied then
                        if not pcall(Graphics.loadImage, "ur0:/appmeta/" .. app_titleid .. "/icon0.png") then
                            iconTmp = Graphics.loadImage("app0:/DATA/noimg.png")
                        else
                            iconTmp = Graphics.loadImage("ur0:/appmeta/" .. app_titleid .. "/icon0.png")
                        end
                    else
                        iconTmp = Graphics.loadImage("app0:/DATA/noimg.png")
                    end
                else
                    iconTmp = Graphics.loadImage("app0:/DATA/noimg.png")
                end
            else
                iconTmp = Graphics.loadImage(icon_path)
            end


            -- Draw background image

            if Game_Backgrounds >= 1 then

                -- PSP
                if apptype == 2 and setPSPExtractBG == 1 then

                    -- Use PIC1 instead of normal snap

                    local pic1_path = snapDir .. "Sony - PlayStation Portable/" .. app_titleid .. "_PIC1.png"

                    -- Does Pic1 already exist in the background directory
                    if System.doesFileExist(pic1_path) then
                        pic_path = pic1_path
                    else

                        if string.match(game_path:lower(), "%.iso$") or string.match(game_path:lower(), "%.cso$") or string.match(game_path:lower(), "%.zso$") or string.match(game_path:lower(), "%.dax$") then

                            -- Try to extract PIC1 from PSP game
                            local extracted_pic = Extended.pspGetPic1(game_path, pic1_path)
                            if extracted_pic then
                                local success, image = pcall(Graphics.loadImage, pic1_path)
                                if success and image then
                                    Graphics.freeImage(image)
                                    pic_path = pic1_path
                                end
                            end
                        end
                    end

                -- Vita and homebrew
                elseif (apptype == 0 or apptype == 1) then

                    if not System.doesFileExist(pic_path) then

                        -- Try to decrypt and copy pic0
                        local copy_success, image_copied = pcall(Extended.copyPicToAppmeta, game_path)
                        local copied_pic_path = "ur0:/appmeta/" .. app_titleid .. "/pic0.png"
                        if copy_success and image_copied == true and is_loadable_image(copied_pic_path) then
                            pic_path = copied_pic_path
                        else
                            if System.doesFileExist(copied_pic_path) and not is_loadable_image(copied_pic_path) then
                                pcall(System.deleteFile, copied_pic_path)
                            end

                            -- Try safely loading the bg image from the ux0 app livearea
                            local pic_path_ux0_livearea_bg = "ux0:/app/" .. app_titleid .. "/sce_sys/livearea/contents/bg.png"
                            if is_loadable_image(pic_path_ux0_livearea_bg) then
                                pic_path = pic_path_ux0_livearea_bg
                            else
                                -- Try safely loading the bg image from the ux0 app livearea
                                local pic_path_ux0_livearea_bg = "ux0:/app/" .. app_titleid .. "/sce_sys/livearea/contents/bg0.png"
                                if is_loadable_image(pic_path_ux0_livearea_bg) then
                                    pic_path = pic_path_ux0_livearea_bg
                                end
                            end
                        end
                    end
                end

                -- set pic0 as background
                if System.doesFileExist(pic_path) then
                    LoadBackgroundTextureFromPath(pic_path)

                elseif apptype == 41 then
                    -- Pico8 - try to crop the game cart to create a tenporary background image
                    local fullImage = Graphics.loadImage(game_path)

                    backTmp = Extended.cropImage(fullImage, 16, 24, 128, 128) -- x start point, y start point, overall size
                    Graphics.freeImage(fullImage)
                    Graphics.setImageFilters(backTmp, FILTER_LINEAR, FILTER_LINEAR)
                    Render.useTexture(modBackground, backTmp)

                    -- Save for future use
                    Graphics.saveImage(backTmp, SystemsToScan[41].localSnapPath .. filename, FORMAT_PNG)

                else
                    Render.useTexture(modBackground, imgCustomBack)
                end

            else
                Render.useTexture(modBackground, imgCustomBack)
            end


            
            if folder == true then
                if System.doesDirExist(appdir) then
                    game_size, _, app_size = getAppSize(appdir)

                elseif xCatLookup(showCat)[p] and xCatLookup(showCat)[p].app_type == 2 then
                    -- PSP EBOOT entries can be marked as folders while game_path points to EBOOT.PBP.
                    local eboot_dir = appdir:match("(.+)/[Ee][Bb][Oo][Oo][Tt]%.[Pp][Bb][Pp]$")
                    if eboot_dir and System.doesDirExist(eboot_dir) then
                        game_size, _, app_size = getAppSize(eboot_dir)
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
                Render.useTexture(modCoverNDSNoref, (def_table_name)[p].ricon) -- n3ds_table
                Render.useTexture(modCoverNDSNoref, (def_table_name)[p].ricon) -- nds_table
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
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- scummvm_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- easyrpg_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- dos_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].ricon) -- c64_table
                Render.useTexture(modCoverNESNoref, (def_table_name)[p].ricon) -- wswan_col_table
                Render.useTexture(modCoverNESNoref, (def_table_name)[p].ricon) -- wswan_table
                Render.useTexture(modCoverLYNXNoref, (def_table_name)[p].ricon) -- pico8_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].ricon) -- msx2_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].ricon) -- msx1_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].ricon) -- zxs_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].ricon) -- atari_st_table
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
                Render.useTexture(modCoverNDSNoref, (def_table_name)[p].icon) -- n3ds_table
                Render.useTexture(modCoverNDSNoref, (def_table_name)[p].icon) -- nds_table
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
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- scummvm_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- easyrpg_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- dos_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].icon) -- c64_table
                Render.useTexture(modCoverNESNoref, (def_table_name)[p].icon) -- wswan_col_table
                Render.useTexture(modCoverNESNoref, (def_table_name)[p].icon) -- wswan_table
                Render.useTexture(modCoverLYNXNoref, (def_table_name)[p].icon) -- pico8_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].icon) -- msx2_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].icon) -- msx1_table
                Render.useTexture(modCoverTAPENoref, (def_table_name)[p].icon) -- zxs_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- atari_st_table
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
                Render.useTexture(modCoverHbrNoref, (def_table_name)[p].icon) -- sysapps_table
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- fav_count
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- recently played
                Render.useTexture(modCoverMDNoref, (def_table_name)[p].icon) -- search

                Render.useTexture(modCoverSNESJapanNoref, (def_table_name)[p].icon) -- Snes Japan
                Render.useTexture(modCoverMiddleNoref, (def_table_name)[p].icon) -- Middle


            end
        end
        
        -- Set cover image
        load_all_cover_models_if_needed()
        set_cover_image (xCatLookup(showCat))

        function closestBoxNoref_getinfo()

            if apptype == 43 or apptype == 47 then
                return modCoverNDSNoref
            end

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
        elseif apptype==44 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.Atari_ST
        elseif apptype==45 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.MS_DOS
        elseif apptype==46 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.EasyRPG
        elseif apptype==47 then
            Render.drawModel(closestBoxNoref_getinfo(), prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.N3DS_Game
        else
            Render.drawModel(modCoverHbrNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            tmpapptype = lang_lines.Homebrew 
        end
    
        Font.print(fnt22, 50, 190, txtname, white)-- app name

        -- Draw conditional icons

            local icon_x = 420
            if wide_getinfoscreen == true then
                icon_x = icon_x + 24
            end
            local icon_y = 50
            local icon_space = 37

            local function draw_next_icon(icon)
                Graphics.drawImage(icon_x, icon_y, icon)
                icon_x = icon_x - icon_space
            end

            if cartridge_flag == true then
                if xCatLookup(showCat)[p].cartridge_inserted == true then
                    draw_next_icon(cart_icon_on)
                else
                    draw_next_icon(cart_icon_off)
                end
            end

            if favourite_flag == true then
                draw_next_icon(imgFavorite_large_on)
            else
                draw_next_icon(imgFavorite_large_off)
            end

            if hide_game_flag == true then
                draw_next_icon(imgHidden_small_on)
            end


        -- 0 Homebrew, 1 vita, 2 psp, 3 psx, 5+ Retro, 34 FBA, 35 Mame 2003+, 36 Mame 2000, 37 NeoGeo, 39 ps mobile

        -- if apptype == 0 or apptype == 1 or apptype == 2 or apptype == 3 or apptype == 39 then
        if apptype == 0 or apptype == 1 or apptype == 39 then
            if string.match (game_path, "pspemu") or string.match (game_path, "ux0:/app/") or string.match (game_path, "ux0:/psm/") then
                Font.print(fnt22, 50, 240, tmpapptype .. "\n" .. lang_lines.App_ID_colon .. app_titleid .. "\n" .. lang_lines.Version_colon .. app_version .. "\n" .. lang_lines.Size_colon .. game_size, white)-- Draw info
                --                                               App ID:                                           Version:                                           Size:
            -- Vita cartridge
            elseif string.match (game_path, "gro0:/app/") then
                Font.print(fnt22, 50, 240, tmpapptype .. "\n" .. lang_lines.App_ID_colon .. app_titleid .. "\n" .. lang_lines.Size_colon .. game_size, white)-- Draw info
                --                                               App ID:                                           Size:

            else
                Font.print(fnt22, 50, 240, tmpapptype .. "\n" .. lang_lines.Version_colon .. app_version .. "\n" .. lang_lines.Size_colon .. game_size, white)-- Draw info
                --                                               Version:                                           Size:
            end
        elseif apptype == 2 or apptype == 3 or apptype == 40 then -- Version removed for psp and psx, scummvm
            Font.print(fnt22, 50, 240, tmpapptype .. "\n" .. lang_lines.App_ID_colon .. app_titleid .. "\n" .. lang_lines.Size_colon .. game_size, white)-- Draw info

        elseif apptype == 34 or apptype == 35 or apptype == 36 or apptype == 37 or apptype == 41 or apptype == 46 then 
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
        local valid_type =
            apptype == 0
            or apptype == 1
            or apptype == 2
            or apptype == 3

        local valid_path =
            string.match(game_path, "pspemu")
            or string.match(game_path, "ux0:/app/")

        if valid_type and valid_path then
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

                    has_artwork = false
                    download_mode_covers = false
                    download_mode_snaps = false
                    missing_artwork_count = 0

                    if tmpimagecat==0 then
                        if gettingCovers == false then
                            gettingCovers = true

                            download_mode_covers = true
                            DownloadSingleCover()
                        end
                    else
                        if gettingBackgrounds == false then
                            gettingBackgrounds = true

                            download_mode_snaps = true
                            DownloadSingleSnap()               
                        end
                    end

                    if setCRCScan == 1 then
                        crc_download_print_crc_results_table()
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
        
        -- Load setting icons when entering settings menu (lazy loading optimization)
        load_setting_icons_if_needed()
        
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

        menuItems = 5

        -- MENU 3 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back

        -- MENU 3 / #1 Startup Category
        Font.print(fnt22, setting_x, setting_y1, lang_lines.Startup_Category_colon, white)--Startup Category
        Font.print(fnt22, setting_x_offset, setting_y1, "<  " .. startup_category_label(startCategory) .. "  >", white)

        -- MENU 3 / #2 Visible categories
        Font.print(fnt22, setting_x, setting_y2, lang_lines.Edit_category_visibility, white)

        -- MENU 3 / #3 Visible collections
        Font.print(fnt22, setting_x, setting_y3, lang_lines.Edit_collection_visibility, white)

        -- MENU 3 / #4 Edit collections
        Font.print(fnt22, setting_x, setting_y4, lang_lines.Edit_collections, white)--Edit collections

        -- MENU 3 / #5 Show hidden games
        Font.print(fnt22, setting_x, setting_y5, lang_lines.Show_hidden_games_colon, white)--Show hidden games
        if showHidden == 1 then
            Font.print(fnt22, setting_x_offset, setting_y5, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y5, lang_lines.Off, white)--OFF
        end

        -- MENU 3 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- count favorites
                refresh_fav_count_table()

                if menuY == 0 then -- #0 Back
                    showMenu = 2
                    menuY = 1 -- Categories

                elseif menuY == 2 then -- #2 Visible categories
                    build_visible_category_options()
                    showMenu = 29
                    visible_category_selected = visible_category_selected or 1
                    visible_category_scrollPosition = visible_category_scrollPosition or 0
                    menuY = 0

                elseif menuY == 3 then -- #3 Visible collections
                    build_visible_collection_options()
                    showMenu = 30
                    visible_collection_selected = visible_collection_selected or 1
                    visible_collection_scrollPosition = visible_collection_scrollPosition or 0
                    menuY = 0

                elseif menuY == 4 then -- #4 Edit collections
                    showMenu = 24
                    menuY = 0

                elseif menuY == 5 then -- #5 Show hidden
                    if showHidden == 1 then
                        showHidden = 0

                        -- If show system apps if off and currently viewing system apps when renaming, must have used quick menu.
                        -- Turn on system apps temporarily so can see the result of the rename.
                        if showSysApps == 0 and showCat == 46 then
                            -- Turn on temporarily
                            showSysApps = 1

                            -- Import and jump to menu
                            FreeIcons()
                            count_cache_and_reload()
                            showCat = 46

                            -- Turn off again, the table will be removed when the user changes category (see category controls, square)
                            showSysApps = 0
                        else
                            -- Import cache to update All games category
                            FreeIcons()
                            count_cache_and_reload()
                        end

                        if showCat == 48 then 
                            fav_count_dirty = true
                            refresh_fav_count_table()
                        end
                        check_for_out_of_bounds()
                        GetNameAndAppTypeSelected()
                    else
                        showHidden = 1

                        -- If show system apps if off and currently viewing system apps when renaming, must have used quick menu.
                        -- Turn on system apps temporarily so can see the result of the rename.
                        if showSysApps == 0 and showCat == 46 then
                            -- Turn on temporarily
                            showSysApps = 1

                            -- Import and jump to menu
                            FreeIcons()
                            count_cache_and_reload()
                            showCat = 46

                            -- Turn off again, the table will be removed when the user changes category (see category controls, square)
                            showSysApps = 0
                        else
                            -- Import cache to update All games category
                            FreeIcons()
                            count_cache_and_reload()
                        end

                        if showCat == 48 then 
                            fav_count_dirty = true
                            refresh_fav_count_table()
                        end
                        check_for_out_of_bounds()
                        GetNameAndAppTypeSelected()
                    end

                end

                normalize_startup_category()

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
                if menuY == 1 then
                    change_startup_category(-1)
                    SaveSettings()
                end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
                if menuY == 1 then
                    change_startup_category(1)
                    SaveSettings()
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

        menuItems = 4

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

        -- MENU 5 / #4 Extract PSP backgounds
        Font.print(fnt22, setting_x, setting_y4, lang_lines.Extract_PSP_backgrounds, white) -- Extract PSP backgounds
        if setPSPExtractBG == 1 then
            Font.print(fnt22, setting_x_offset, setting_y4, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y4, lang_lines.Off, white)--OFF
        end


        -- MENU 5 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 5
                if menuY == 0 then -- #0 Back
                    showMenu = 2
                    menuY = 4 -- Artwork

                elseif menuY == 1 then -- #1 Download artwork

                    has_artwork = false
                    download_mode_covers = false
                    download_mode_snaps = false
                    missing_artwork_count = 0

                    if Network.isWifiEnabled() then

                        if download_artwork_type == 0 then
                            -- Covers
                            download_mode_covers = true

                            if gettingCovers == false then
                                gettingCovers = true

                                missing_artwork_table_covers = {}
                                
                                for l, file in pairs(return_table) do

                                    if file.app_type == 0 or file.app_type == 39 or file.app_type == 41 or file.app_type == 42 then
                                        -- Do nothing - Homebrew, PSM, Pico, Sys app
                                    else
                                        if file.cover == false or string.match(file.icon_path, "%icon0.png") then
                                            file.cover_path_local = xAppNumLookup_Cover_Path_Local(file.app_type)
                                            file.cover_path_online = xAppNumLookup_Cover_Path_Online(file.app_type)
                                            table.insert(missing_artwork_table_covers, file)
                                        end
                                    end
                                end

                                -- table.sort(missing_artwork_table_covers, function(a, b) return (a.app_type < b.app_type) end)

                                table.sort(missing_artwork_table_covers, function(a, b)
                                    if a.app_type == b.app_type then
                                        return (a.apptitle or ""):lower() < (b.apptitle or ""):lower()
                                    else
                                        return a.app_type < b.app_type
                                    end
                                end)

                                DownloadArtwork(missing_artwork_table_covers)
                            end

                        else
                            -- Backgrounds
                            download_mode_snaps = true

                            if gettingBackgrounds == false then
                                gettingBackgrounds = true

                                missing_artwork_table_backgrounds = {}

                                -- Scan all background images
                                QuickDoesFileExist.snapDir = quickScanFiles(snapDir, 1, true, ".png")

                                for l, file in pairs(return_table) do
                                    local missing_snap = false
                                    if file.app_type == 0 or file.app_type == 1 or file.app_type == 39 or file.app_type == 41 or file.app_type == 42 then
                                        -- Do nothing -- Homebrew, Vita, PSM, Pico, Sys app
                                    else
                                        if QuickDoesFileExist.snapDir[xAppNumLookup_Snap_Path_Local(file.app_type) .. file.name .. ".png"] then
                                            missing_snap = false
                                        elseif QuickDoesFileExist.snapDir[xAppNumLookup_Snap_Path_Local(file.app_type) .. file.title .. ".png"] then
                                            missing_snap = false
                                        else
                                            missing_snap = true
                                        end
                                        if missing_snap == true then
                                            file.snap_path_local = xAppNumLookup_Snap_Path_Local(file.app_type)
                                            file.snap_path_online = xAppNumLookup_Snap_Path_Online(file.app_type)
                                            table.insert(missing_artwork_table_backgrounds, file)
                                        end
                                    end
                                end

                                -- table.sort(missing_artwork_table_backgrounds, function(a, b) return (a.app_type < b.app_type) end)

                                table.sort(missing_artwork_table_backgrounds, function(a, b)
                                    if a.app_type == b.app_type then
                                        return (a.apptitle or ""):lower() < (b.apptitle or ""):lower()
                                    else
                                        return a.app_type < b.app_type
                                    end
                                end)
                                
                                DownloadArtwork(missing_artwork_table_backgrounds)
                                
                                -- Rescan snaps
                                -- QuickDoesFileExist.snapDir = quickScanFiles(snapDir, 1, true, ".png")
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

                elseif menuY == 4 then -- #5 Extract PSP backgrounds from iso and cso files
                    if setPSPExtractBG == 1 then
                        setPSPExtractBG = 0
                    else
                        setPSPExtractBG = 1
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

        menuItems = 5

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

        -- MENU 6 / #3 Scan cartridges
        Font.print(fnt22, setting_x, setting_y3, lang_lines.Scan_Vita_cartridges_colon, white)--Scan cartridges

        if setScanCartridges == 1 then
            Font.print(fnt22, setting_x_offset, setting_y3, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y3, lang_lines.Off, white)--OFF
        end

        -- MENU 6 / #4 Adrenaline_roms
        Font.print(fnt22, setting_x, setting_y4, lang_lines.Adrenaline_roms, white)--Adrenaline_roms 

        if Adrenaline_roms == 1 then
            Font.print(fnt22, setting_x_offset, setting_y4, "<  " .. "ux0"  .. ":/pspemu" .. "  >", white)
        elseif Adrenaline_roms == 2 then
            Font.print(fnt22, setting_x_offset, setting_y4, "<  " .. "ur0"  .. ":/pspemu" .. "  >", white)
        elseif Adrenaline_roms == 3 then
            Font.print(fnt22, setting_x_offset, setting_y4, "<  " .. "imc0" .. ":/pspemu" .. "  >", white)
        elseif Adrenaline_roms == 4 then
            Font.print(fnt22, setting_x_offset, setting_y4, "<  " .. "xmc0" .. ":/pspemu" .. "  >", white)
        elseif Adrenaline_roms == 5 then
            Font.print(fnt22, setting_x_offset, setting_y4, "<  " .. lang_lines.All .. "  >", white)   
        else
            Font.print(fnt22, setting_x_offset, setting_y4, "<  " .. "uma0" .. ":/pspemu" .. "  >", white)
        end

        -- MENU 6 / #5 Rescan
        Font.print(fnt22, setting_x, setting_y5, lang_lines.Rescan, white)--Rescan

        

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
                        FreeIcons()
                        count_cache_and_reload()
                    else
                        startupScan = 1
                        --Save settings
                        SaveSettings()
                        FreeIcons()
                        count_cache_and_reload()
                    end
                elseif menuY == 3 then -- #3 Scan Cartridges 
                    if setScanCartridges == 1 then -- 0 Off, 1 On
                        setScanCartridges = 0
                        SaveSettings()
                        FreeIcons()

                        -- Reimport cache, cartidges will be skipped
                        count_cache_and_reload()
                        check_for_out_of_bounds()
                        GetNameAndAppTypeSelected()
                    else
                        setScanCartridges = 1
                        SaveSettings()
                        FreeIcons()

                        -- Reimport cache, cartidges will be included
                        count_cache_and_reload()
                        check_for_out_of_bounds()
                        GetNameAndAppTypeSelected()
                    end
                elseif menuY == 5 then -- #4 Rescan
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
                if menuY==4 then -- #3 Adrenaline_roms selection
                    if Adrenaline_roms > 0 then
                        Adrenaline_roms = Adrenaline_roms - 1
                    else
                        Adrenaline_roms = 5
                    end
                    SaveSettings()
                end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
                if menuY==4 then -- #3 Adrenaline_roms selection
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
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Atari_ST .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Atari_ST, white)
                filebrowser_heading = lang_lines.Atari_ST
            elseif getRomDir == 7 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.ColecoVision .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.ColecoVision, white)
                filebrowser_heading = lang_lines.ColecoVision
            elseif getRomDir == 8 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Commodore_64 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Commodore_64, white)
                filebrowser_heading = lang_lines.Commodore_64
            elseif getRomDir == 9 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.EasyRPG .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.EasyRPG, white)
                filebrowser_heading = lang_lines.EasyRPG
            elseif getRomDir == 10 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.FBA_2012 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.FBA_2012, white)
                filebrowser_heading = lang_lines.FBA_2012
            elseif getRomDir == 11 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Game_Boy_Advance .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Game_Boy_Advance, white)
                filebrowser_heading = lang_lines.Game_Boy_Advance
            elseif getRomDir == 12 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Game_Boy_Color .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Game_Boy_Color, white)
                filebrowser_heading = lang_lines.Game_Boy_Color
            elseif getRomDir == 13 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Game_Boy .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Game_Boy, white)
                filebrowser_heading = lang_lines.Game_Boy
            elseif getRomDir == 14 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.MAME_2000 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.MAME_2000, white)
                filebrowser_heading = lang_lines.MAME_2000
            elseif getRomDir == 15 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.MAME_2003Plus .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.MAME_2003Plus, white)
                filebrowser_heading = lang_lines.MAME_2003Plus
            elseif getRomDir == 16 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.MS_DOS .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.DOS, white)
                filebrowser_heading = lang_lines.MS_DOS
            elseif getRomDir == 17 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.MSX .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.MSX, white)
                filebrowser_heading = lang_lines.MSX
            elseif getRomDir == 18 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.MSX2 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.MSX2, white)
                filebrowser_heading = lang_lines.MSX2
            elseif getRomDir == 19 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Neo_Geo_Pocket_Color .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Neo_Geo_Pocket_Color, white)
                filebrowser_heading = lang_lines.Neo_Geo_Pocket_Color
            elseif getRomDir == 20 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Neo_Geo .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Neo_Geo, white)
                filebrowser_heading = lang_lines.Neo_Geo
            elseif getRomDir == 21 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Nintendo_3DS .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Nintendo_3DS, white)
                filebrowser_heading = lang_lines.Nintendo_3DS
            elseif getRomDir == 22 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Nintendo_64 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Nintendo_64, white)
                filebrowser_heading = lang_lines.Nintendo_64
            elseif getRomDir == 23 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Nintendo_DS .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Nintendo_DS, white)
                filebrowser_heading = lang_lines.Nintendo_DS
            elseif getRomDir == 24 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Nintendo_Entertainment_System .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Nintendo_Entertainment_System, white)
                filebrowser_heading = lang_lines.Nintendo_Entertainment_System
            elseif getRomDir == 25 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.PC_Engine_CD .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.PC_Engine_CD, white)
                filebrowser_heading = lang_lines.PC_Engine_CD
            elseif getRomDir == 26 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.PC_Engine .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.PC_Engine, white)
                filebrowser_heading = lang_lines.PC_Engine
            elseif getRomDir == 27 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.PICO8 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Pico8, white)
                filebrowser_heading = lang_lines.PICO8   
            elseif getRomDir == 28 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.PlayStation .. " (RetroArch)" ..  "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.PlayStation, white)
                filebrowser_heading = lang_lines.PlayStation .. " (RetroArch)"
            elseif getRomDir == 29 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Sega_32X .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Sega_32X, white)
                filebrowser_heading = lang_lines.Sega_32X
            elseif getRomDir == 30 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Sega_CD .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Sega_CD, white)
                filebrowser_heading = lang_lines.Sega_CD
            elseif getRomDir == 31 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Sega_Dreamcast .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Sega_Dreamcast, white)
                filebrowser_heading = lang_lines.Sega_Dreamcast
            elseif getRomDir == 32 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Sega_Game_Gear .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Sega_Game_Gear, white)
                filebrowser_heading = lang_lines.Sega_Game_Gear
            elseif getRomDir == 33 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Sega_Master_System .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Sega_Master_System, white)
                filebrowser_heading = lang_lines.Sega_Master_System
            elseif getRomDir == 34 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Sega_Mega_Drive .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Sega_Mega_Drive, white)
                filebrowser_heading = lang_lines.Sega_Mega_Drive
            elseif getRomDir == 35 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Super_Nintendo .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Super_Nintendo, white)
                filebrowser_heading = lang_lines.Super_Nintendo
            elseif getRomDir == 36 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.TurboGrafx_16 .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.TurboGrafx_16, white)
                filebrowser_heading = lang_lines.TurboGrafx_16
            elseif getRomDir == 37 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.TurboGrafx_CD .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.TurboGrafx_CD, white)
                filebrowser_heading = lang_lines.TurboGrafx_CD
            elseif getRomDir == 38 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.Vectrex .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.Vectrex, white)
                filebrowser_heading = lang_lines.Vectrex
            elseif getRomDir == 39 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.WonderSwan_Color .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.WonderSwan_Color, white)
                filebrowser_heading = lang_lines.WonderSwan_Color
            elseif getRomDir == 40 then
                Font.print(fnt22, setting_x, setting_y1, "<  " .. lang_lines.WonderSwan .. "  >", white)
                Font.print(fnt20, setting_x, setting_y2 + setting_y_smallfont_offset, romUserDir.WonderSwan, white)
                filebrowser_heading = lang_lines.WonderSwan
            elseif getRomDir == 41 then
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
                        getRomDir = 41 -- Update number if add more systems
                    end
                end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
                if menuY==1 then -- #1 category rom directory selection
                    if getRomDir < 41 then -- Update number if add more systems
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
        load_file_browser_icons_if_needed()
        
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
                                    elseif getRomDir == 6 then romUserDir.Atari_ST = cur_dir_fm
                                    elseif getRomDir == 7 then romUserDir.ColecoVision = cur_dir_fm
                                    elseif getRomDir == 8 then romUserDir.Commodore_64 = cur_dir_fm
                                    elseif getRomDir == 9 then romUserDir.EasyRPG = cur_dir_fm
                                    elseif getRomDir == 10 then romUserDir.FBA_2012 = cur_dir_fm
                                    elseif getRomDir == 11 then romUserDir.Game_Boy_Advance = cur_dir_fm
                                    elseif getRomDir == 12 then romUserDir.Game_Boy_Color = cur_dir_fm
                                    elseif getRomDir == 13 then romUserDir.Game_Boy = cur_dir_fm
                                    elseif getRomDir == 14 then romUserDir.MAME_2000 = cur_dir_fm
                                    elseif getRomDir == 15 then romUserDir.MAME_2003Plus = cur_dir_fm
                                    elseif getRomDir == 16 then romUserDir.DOS = cur_dir_fm
                                    elseif getRomDir == 17 then romUserDir.MSX = cur_dir_fm
                                    elseif getRomDir == 18 then romUserDir.MSX2 = cur_dir_fm
                                    elseif getRomDir == 19 then romUserDir.Neo_Geo_Pocket_Color = cur_dir_fm
                                    elseif getRomDir == 20 then romUserDir.Neo_Geo = cur_dir_fm
                                    elseif getRomDir == 21 then romUserDir.Nintendo_3DS = cur_dir_fm
                                    elseif getRomDir == 22 then romUserDir.Nintendo_64 = cur_dir_fm
                                    elseif getRomDir == 23 then romUserDir.Nintendo_DS = cur_dir_fm
                                    elseif getRomDir == 24 then romUserDir.Nintendo_Entertainment_System = cur_dir_fm
                                    elseif getRomDir == 25 then romUserDir.PC_Engine_CD = cur_dir_fm
                                    elseif getRomDir == 26 then romUserDir.PC_Engine = cur_dir_fm
                                    elseif getRomDir == 27 then romUserDir.Pico8 = cur_dir_fm
                                    elseif getRomDir == 28 then romUserDir.PlayStation = cur_dir_fm
                                    elseif getRomDir == 29 then romUserDir.Sega_32X = cur_dir_fm
                                    elseif getRomDir == 30 then romUserDir.Sega_CD = cur_dir_fm
                                    elseif getRomDir == 31 then romUserDir.Sega_Dreamcast = cur_dir_fm
                                    elseif getRomDir == 32 then romUserDir.Sega_Game_Gear = cur_dir_fm
                                    elseif getRomDir == 33 then romUserDir.Sega_Master_System = cur_dir_fm
                                    elseif getRomDir == 34 then romUserDir.Sega_Mega_Drive = cur_dir_fm
                                    elseif getRomDir == 35 then romUserDir.Super_Nintendo = cur_dir_fm
                                    elseif getRomDir == 36 then romUserDir.TurboGrafx_16 = cur_dir_fm
                                    elseif getRomDir == 37 then romUserDir.TurboGrafx_CD = cur_dir_fm
                                    elseif getRomDir == 38 then romUserDir.Vectrex = cur_dir_fm
                                    elseif getRomDir == 39 then romUserDir.WonderSwan_Color = cur_dir_fm
                                    elseif getRomDir == 40 then romUserDir.WonderSwan = cur_dir_fm
                                    elseif getRomDir == 41 then romUserDir.ZX_Spectrum = cur_dir_fm
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
                    dpadHeldUp = 0  -- Reset counter on new press
                elseif Controls.check(pad, SCE_CTRL_UP) then
                    -- Initialize and increment held counter for continuous scrolling
                    dpadHeldUp = (dpadHeldUp or 0) + 0.05
                    
                    -- Continuous scroll mode after initial delay
                    if dpadHeldUp > 1 and delayButton < 0.05 then
                        delayButton = 0.7  -- Repeat delay for continuous scrolling
                        i = i - 1
                    end
                elseif Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) then
                    i = i + 1
                    dpadHeldDown = 0  -- Reset counter on new press
                elseif Controls.check(pad, SCE_CTRL_DOWN) then
                    -- Initialize and increment held counter for continuous scrolling
                    dpadHeldDown = (dpadHeldDown or 0) + 0.05
                    
                    -- Continuous scroll mode after initial delay
                    if dpadHeldDown > 1 and delayButton < 0.05 then
                        delayButton = 0.7  -- Repeat delay for continuous scrolling
                        i = i + 1
                    end
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
                
                -- Reset D-pad held counters when buttons are released
                if not Controls.check(pad, SCE_CTRL_UP) then
                    dpadHeldUp = 0
                end
                if not Controls.check(pad, SCE_CTRL_DOWN) then
                    dpadHeldDown = 0
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


        menuItems = 6

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

        -- MENU 19 / #4 Show core override menu
        Font.print(fnt22, setting_x, setting_y4, lang_lines.Show_game_core_menu_colon, white)--Show core override menu:
        if setShowCores == 1 then
            Font.print(fnt22, setting_x_offset, setting_y4, lang_lines.On, white)--ON
        else
            Font.print(fnt22, setting_x_offset, setting_y4, lang_lines.Off, white)--OFF
        end

        -- MENU 19 / #5 Time
        Font.print(fnt22, setting_x, setting_y5, lang_lines.Time_colon, white)--Time
        if setTime == 1 then
            Font.print(fnt22, setting_x_offset, setting_y5, lang_lines.Time_12hr, white)--24-Hour Clock
        else
            Font.print(fnt22, setting_x_offset, setting_y5, lang_lines.Time_24hr, white)--12-Hour Clock
        end

        -- MENU 19 / #6 Global core settings
        Font.print(fnt22, setting_x, setting_y6, lang_lines.Global_core_settings, white)--Global core settings

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
                
                elseif menuY == 4 then -- #4 Show core override menu
                    if setShowCores == 1 then
                        setShowCores = 0
                    else
                        setShowCores = 1
                    end

                elseif menuY == 5 then -- #5 Time
                    if setTime == 1 then
                        setTime = 0
                        time24_offset = 0 -- Updates positioning of clock in UI
                    else
                        setTime = 1
                        time24_offset = 25 -- Updates positioning of clock in UI
                    end
                elseif menuY == 6 then -- #6 Change emulator cores
                    showMenu = 28 
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
            if showCat == 49 then
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

                    found = check_if_game_is_in_collection_table(check_collection_number, xCatLookup(showCat)[p].name)
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
                if xcollection_number > #collection_removal_table then
                    xcollection_number = #collection_removal_table
                end
                if xcollection_number < 1 then
                    xcollection_number = 1
                end
                menuItems = menuItems + 1
            end

            local core_options_flag = false
            if adrenaline_flag == false and (apptype == 43 or (setShowCores == 1 and core_overrides[apptype])) then
                -- Alternative RetroArch cores, DSVita
                core_options_flag = true
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
                elseif core_options_flag == true and core_overrides[apptype] and setShowCores == 1 then
                    -- Alternative RetroArch cores
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Emulator_core, white)-- Emulator core
                    Font.print(fnt22, setting_x, setting_y6 + y_centre_text_offset, lang_lines.Remove_from_recently_played, white)--Remove from recently played
                elseif core_options_flag == true and apptype == 43 then
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Configure_game_in_DSVita, white)-- DSVita configuration
                    Font.print(fnt22, setting_x, setting_y6 + y_centre_text_offset, lang_lines.Remove_from_recently_played, white)--Remove from recently played
                else
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Remove_from_recently_played, white)--Remove from recently played
                end
            else
                if adrenaline_flag == true then
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Adrenaline_options, white)--Adrenaline options
                elseif core_options_flag == true and core_overrides[apptype] and setShowCores == 1 then
                    -- Alternative RetroArch cores
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Emulator_core, white)-- Emulator core
                elseif core_options_flag == true and apptype == 43 then
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Configure_game_in_DSVita, white)-- DSVita configuration
                end
            end

        else

            if recent_cat_flag == true then
                if adrenaline_flag == true then
                    Font.print(fnt22, setting_x, setting_y4 + y_centre_text_offset, lang_lines.Adrenaline_options, white)--Adrenaline options
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Remove_from_recently_played, white)--Remove from recently played
                elseif core_options_flag == true and core_overrides[apptype] and setShowCores == 1 then
                    -- Alternative RetroArch cores
                    Font.print(fnt22, setting_x, setting_y4 + y_centre_text_offset, lang_lines.Emulator_core, white)-- Emulator core
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Remove_from_recently_played, white)--Remove from recently played
                elseif core_options_flag == true and apptype == 43 then
                    Font.print(fnt22, setting_x, setting_y4 + y_centre_text_offset, lang_lines.Configure_game_in_DSVita, white)-- DSVita configuration
                    Font.print(fnt22, setting_x, setting_y5 + y_centre_text_offset, lang_lines.Remove_from_recently_played, white)--Remove from recently played
                else
                    Font.print(fnt22, setting_x, setting_y4 + y_centre_text_offset, lang_lines.Remove_from_recently_played, white)--Remove from recently played
                end
            else
                if adrenaline_flag == true then
                    Font.print(fnt22, setting_x, setting_y4 + y_centre_text_offset, lang_lines.Adrenaline_options, white)--Adrenaline options
                elseif core_options_flag == true and core_overrides[apptype] and setShowCores == 1 then
                    -- Alternative RetroArch cores
                    Font.print(fnt22, setting_x, setting_y4 + y_centre_text_offset, lang_lines.Emulator_core, white)-- Emulator core
                elseif core_options_flag == true and apptype == 43 then
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

                    function dynamic_menu_retroarch_core()
                        game_core = 0

                        -- Get existing settings
                        local override_core_id = GameCoreOverrides[get_game_core_override_key()]
                        if override_core_id and core_overrides[apptype] then
                            for core_index, core_info in pairs(core_overrides[apptype]) do
                                if core_info.core_id == override_core_id then
                                    game_core = core_index
                                    break
                                end
                            end
                        else
                            local key = find_game_table_pos_key(launch_overrides_table, app_titleid)
                            if key ~= nil then
                                -- Yes - it's already in the launch override list, update it.
                                game_core = launch_overrides_table[key].core
                            end
                        end

                        showMenu = 27
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
                            if showCat == 49 then
                                -- We are in the recent category, remove the game and save cache
                                remove_recently_played_full_entry(app_titleid)
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
                                    remove_recently_played_full_entry(app_titleid)
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
                        fav_count_dirty = true

                        -- If on favorite category, go to main screen, otherwise the next fav game is shown
                    if showCat == 48 then
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


                    FreeIcons()
                    refresh_after_hide_unhide(app_titleid, apptype, hide_game_flag)

                    if showHidden == 0 then

                        -- Rebuild search results if we're in search category
                        if showCat == 50 and ret_search and random_game_selected == false then
                            -- Store current search results parameters
                            local current_search_text = ret_search
                            local current_search_lc = ret_search_lc
                            local current_search_uc = ret_search_uc
                            local current_search_pc = ret_search_pc

                            -- Clear and rebuild search results
                            search_results_table = {}
                            for l, file in pairs(files_table) do
                                if game_matches_search(file, current_search_text, current_search_lc, current_search_uc, current_search_pc) then
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
                        if showCat == 48 then
                            fav_count_dirty = true
                            refresh_fav_count_table()
                        end

                        -- Handle both search results and random game in category 50
                        if showCat == 50 then
                            if random_game_selected then
                                -- Handle random game case
                                search_results_table = {}
                                if random_game then
                                    -- Find and add the random game to the results
                                    for _, file in pairs(files_table) do
                                        if file.name == random_game and include_game_in_search_results(file) == true then
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
                                    if game_matches_search(file, current_search_text, current_search_lc, current_search_uc, current_search_pc) then
                                        table.insert(search_results_table, file)
                                    end
                                end
                                table.sort(search_results_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
                            end
                        end


                        -- Handle hiding/unhiding for both search results and random game
                        if showCat == 50 then
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
                        elseif core_options_flag == true and core_overrides[apptype] and setShowCores == 1 then
                            -- Alternative RetroArch cores
                            dynamic_menu_retroarch_core()
                        elseif core_options_flag == true and apptype == 43 then
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
                        elseif core_options_flag == true and core_overrides[apptype] and setShowCores == 1 then
                            -- Alternative RetroArch cores
                            dynamic_menu_retroarch_core()
                        elseif core_options_flag == true and apptype == 43 then
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
        
        local mode_add_search_results = false

        if next(search_results_table) ~= nil then
            mode_add_search_results = true
        end

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

                    if mode_add_search_results == false then
                        showMenu = 20
                        menuY=3
                    else
                        showMenu = 25
                        menuY=5
                    end

                elseif menuY == 2 and mode_add_search_results == false then -- #3 Add individual game to collection
                    
                    -- Existing collection
                    if collection_number > 0 then
                        
                        -- Check if game is already in the collection list
                        if check_if_game_is_in_collection_table(collection_number, xCatLookup(showCat)[p].name) == false then


                            if xCollectionTableLookup(collection_number)[1].custom_sort_order ~= nil then
                                cc_already_custom = true
                            else
                                cc_already_custom = false
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
                            if cc_already_custom == true then
                                table.sort(game_info_for_collection, function(a, b) return (tonumber(a.custom_sort_order) < tonumber(b.custom_sort_order)) end)
                            else
                                table.sort(game_info_for_collection, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
                            end

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

                elseif menuY == 2 and mode_add_search_results == true then -- #3 Add search results to collection
                    
                    -- Existing collection
                    if collection_number > 0 then
                        
                        -- Create new table of basic info
                        local game_info_for_collection = {}

                        -- Check if collection is using custom sort order
                        if xCollectionTableLookup(collection_number)[1].custom_sort_order ~= nil then
                            cc_already_custom = true
                            cc_already_custom_count = #xCollectionTableLookup(collection_number)
                        else
                            cc_already_custom = false
                        end

                        for k, v in pairs(search_results_table) do

                            local individual_game = {}

                            -- Check if game is already in the collection list
                            if check_if_game_is_in_collection_table(collection_number, v.name) == false then

                                if cc_already_custom == true then

                                    -- Target collection has custom sorting, include 'custom_sort_order' field and add to the end

                                    cc_already_custom_count = cc_already_custom_count + 1
                                    
                                    individual_game = {
                                        apptitle = v.title,
                                        name = v.name,
                                        app_type = v.app_type,
                                        custom_sort_order = cc_already_custom_count,
                                    }
                                    table.insert(game_info_for_collection, individual_game)

                                else

                                    -- Target collection does not have custom sorting, exclude 'custom_sort_order' field
                                    individual_game = {
                                        apptitle = v.title,
                                        name = v.name,
                                        app_type = v.app_type,
                                    }
                                    table.insert(game_info_for_collection, individual_game)
                                end
                            end

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
                        if cc_already_custom == true then
                            table.sort(game_info_for_collection, function(a, b) return (tonumber(a.custom_sort_order) < tonumber(b.custom_sort_order)) end)
                        else
                            table.sort(game_info_for_collection, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
                        end

                        update_cached_collection(collection_files[collection_number].filename, game_info_for_collection)

                        -- Import the cached tables
                        import_collections()

                        oldpad = pad -- Prevents it from launching next game accidentally. Credit BlackSheepBoy69
                        showCollections = 1
                        set_collection_visible(collection_number, true)
                        save_visible_collection_settings()
                        showCat = 50 + collection_number -- this number should correspond to the showcat number for the category the games were just added to
                        p = 1
                        master_index = p
                        showMenu = 0
                        GetNameAndAppTypeSelected()
                        Render.useTexture(modBackground, imgCustomBack)
                        collection_number = 0

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
            if xcollection_number > #collection_removal_table then
                xcollection_number = #collection_removal_table
            end
            if xcollection_number < 1 then
                xcollection_number = 1
            end
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

                            if xcollection_number > #collection_removal_table then
                                xcollection_number = #collection_removal_table
                            end
                            if xcollection_number < 1 then
                                xcollection_number = 1
                            end

                            -- Create new table of basic info
                            game_info_for_collection = {}                            

                            -- Check if collection has custom sorting
                            if xCollectionTableLookup(collection_removal_table[xcollection_number].matched_collection_num)[1].custom_sort_order ~= nil then
                                cc_already_custom = true
                            else
                                cc_already_custom = false
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

                                restart_after_frame = true
                               
                            else

                                -- Is not empty, Sort the table and cache
                                table.sort(game_info_for_collection, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
                                update_cached_collection(collection_files[collection_removal_table[xcollection_number].matched_collection_num].filename, game_info_for_collection)
                            end
                            

                        if restart_after_frame == false then
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

        --         found = check_if_game_is_in_collection_table(check_collection_number, xCatLookup(showCat)[p].name)
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
                    showMenu = 3  -- Categories
                    menuY = 4

                elseif menuY == 2 then -- #2 Custom sort order

                    -- If collections exist
                    if collections_flag == true then
                        load_collection_edit_table(xcollection_number)
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
                            HiddenCollections[collection_files[xcollection_number].table_name] = nil
                            save_hidden_collections()
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
        
        -- Load setting icons when entering filter games menu (lazy loading optimization)
        load_setting_icons_if_needed()
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        local mode_add_search_results = false

        if next(search_results_table) ~= nil then
            mode_add_search_results = true
        end


        -- GET MENU ITEM COUNT (Some menus app type specific)
            
            menuItems = 4

            if mode_add_search_results == true then
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

        -- MENU 25 / #5 Dynamic - Add search results to collection
        if mode_add_search_results == true then
            Graphics.drawImage(setting_x, setting_y5 + y_centre_text_offset, setting_icon_categories)
            Font.print(fnt22, setting_x_icon_offset + 70, setting_y5 + y_centre_text_offset, lang_lines.Add_to_collection, white)--Add to collection
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
                            if app.app_type ~= 0 and app.app_type ~= 42 and include_game_in_search_results(app) == true then
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
                        showCat = 50
                        p = 1
                        master_index = p
                        showMenu = 0
                        GetNameAndAppTypeSelected()
                    end

                elseif menuY == 1 then -- #1 Favorites

                    -- Check if there are favourites first
                    refresh_fav_count_table()

                    -- Favourites found
                    if #fav_count > 0 then
                        -- Skip to favorites
                        showCat = 48
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
                        showCat = 49
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
                        showCat = 47
                        p = 1
                        master_index = p
                        showMenu = 0
                        GetNameAndAppTypeSelected()

                        -- Turn off again, the table will be removed when the user changes category (see category controls, square)
                        showSysApps = 0

                    else
                        -- Skip to system apps
                        showCat = 47
                        p = 1
                        master_index = p
                        showMenu = 0
                        GetNameAndAppTypeSelected()
                    end
                    
                elseif menuY == 4 then -- #4 Filter

                    if filterGames == 1 then
                        if collection_count ~= 0 then   
                            showCat = find_next_selectable_category(1, 51)
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

                elseif menuY == 5 then -- #5 Save search results to collection

                    showMenu = 22 -- Add to collection
                    menuY = 0

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


-- MENU 29 - VISIBLE CATEGORIES
    elseif showMenu == 29 then

        load_category_visibility_icons_if_needed()
        build_visible_category_options()

        label1 = Font.getTextWidth(fnt20, lang_lines.Back)--Back
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Back, white)--Back

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.Edit_category_visibility, white)
        Graphics.fillRect(60, 900, 78, 81, white)

        if #visible_category_options == 0 then
            visible_category_selected = 1
            visible_category_scrollPosition = 0
        else
            if visible_category_selected < 1 then
                visible_category_selected = 1
            elseif visible_category_selected > #visible_category_options then
                visible_category_selected = #visible_category_options
            end

            if visible_category_scrollPosition < 0 then
                visible_category_scrollPosition = 0
            elseif visible_category_selected <= visible_category_scrollPosition then
                visible_category_scrollPosition = visible_category_selected - 1
            elseif visible_category_selected > visible_category_scrollPosition + visible_category_maxVisibleItems then
                visible_category_scrollPosition = visible_category_selected - visible_category_maxVisibleItems
            end
        end

        menuY = visible_category_selected - visible_category_scrollPosition - 1
        if menuY < 0 then
            menuY = 0
        elseif menuY > visible_category_maxVisibleItems - 1 then
            menuY = visible_category_maxVisibleItems - 1
        end
        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)

        local visible_category_y = setting_y0
        for list_index = visible_category_scrollPosition + 1, #visible_category_options do
            if visible_category_y < 450 then
                local category = visible_category_options[list_index]
                local icon = category_visibility_unchecked
                local color = white_opaque
                if is_category_visible(category.showcat) == true then
                    icon = category_visibility_checked
                    color = white
                end
                Graphics.drawImage(setting_x, visible_category_y, icon, color)
                Font.print(fnt22, setting_x_icon_offset, visible_category_y, category.display_name, color)
                visible_category_y = visible_category_y + 47
            end
        end

        menuItems = 0

        status = System.getMessageState()
        if status ~= RUNNING then

            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then
                oldpad = pad
                local category = visible_category_options[visible_category_selected]
                if category then
                    set_category_visible(category.showcat, not is_category_visible(category.showcat))
                    ensure_at_least_one_visible_category()
                    if category.showcat == 2 or category.showcat == 47 then
                        visible_categories_requires_reload = true
                    end
                    visible_categories_dirty = true
                end
            elseif Controls.check(pad, SCE_CTRL_CIRCLE_MAP) and not Controls.check(oldpad, SCE_CTRL_CIRCLE_MAP) then
                oldpad = pad
                if visible_categories_requires_reload == true then
                    FreeIcons()
                    count_cache_and_reload()
                end
                save_visible_category_settings()
                visible_categories_dirty = false
                visible_categories_requires_reload = false
                visible_category_selected = 1
                visible_category_scrollPosition = 0
                showMenu = 3
                menuY = 2
            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                move_visible_category_selection(-1)
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                move_visible_category_selection(1)
            end
        end


-- MENU 30 - VISIBLE COLLECTIONS
    elseif showMenu == 30 then

        load_category_visibility_icons_if_needed()
        build_visible_collection_options()

        label1 = Font.getTextWidth(fnt20, lang_lines.Back)--Back
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

        Graphics.drawImage(900-label1, 510, btnO)
        Font.print(fnt20, 900+28-label1, 508, lang_lines.Back, white)--Back

        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, 510, btnX)
        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, 508, lang_lines.Select, white)--Select

        Graphics.fillRect(60, 900, 34, 460, darkalpha)

        Font.print(fnt22, setting_x, setting_yh, lang_lines.Edit_collection_visibility, white)
        Graphics.fillRect(60, 900, 78, 81, white)

        if #visible_collection_options == 0 then
            visible_collection_selected = 1
            visible_collection_scrollPosition = 0
        else
            if visible_collection_selected < 1 then
                visible_collection_selected = 1
            elseif visible_collection_selected > #visible_collection_options then
                visible_collection_selected = #visible_collection_options
            end

            if visible_collection_scrollPosition < 0 then
                visible_collection_scrollPosition = 0
            elseif visible_collection_selected <= visible_collection_scrollPosition then
                visible_collection_scrollPosition = visible_collection_selected - 1
            elseif visible_collection_selected > visible_collection_scrollPosition + visible_collection_maxVisibleItems then
                visible_collection_scrollPosition = visible_collection_selected - visible_collection_maxVisibleItems
            end
        end

        menuY = visible_collection_selected - visible_collection_scrollPosition - 1
        if menuY < 0 then
            menuY = 0
        elseif menuY > visible_collection_maxVisibleItems - 1 then
            menuY = visible_collection_maxVisibleItems - 1
        end
        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)

        if #visible_collection_options == 0 then
            Font.print(fnt22, setting_x, setting_y0, lang_lines.No_collections, white_opaque)
        else
            local visible_collection_y = setting_y0
            for list_index = visible_collection_scrollPosition + 1, #visible_collection_options do
                if visible_collection_y < 450 then
                    local collection_option = visible_collection_options[list_index]
                    if collection_option.action ~= nil then
                        Font.print(fnt22, setting_x, visible_collection_y, collection_option.display_name, white)
                    else
                        local icon = category_visibility_unchecked
                        local color = white_opaque
                        if is_collection_visible(collection_option.collection_num) == true then
                            icon = category_visibility_checked
                            color = white
                        end
                        Graphics.drawImage(setting_x, visible_collection_y, icon, color)
                        Font.print(fnt22, setting_x_icon_offset, visible_collection_y, collection_option.display_name, color)
                    end
                    visible_collection_y = visible_collection_y + 47
                end
            end
        end

        menuItems = 0

        status = System.getMessageState()
        if status ~= RUNNING then

            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then
                oldpad = pad
                local collection_option = visible_collection_options[visible_collection_selected]
                if collection_option then
                    if collection_option.action == "show_all" then
                        set_all_collections_visible(true)
                    elseif collection_option.action == "hide_all" then
                        set_all_collections_visible(false)
                    elseif collection_option.collection_num ~= nil then
                        if is_collection_visible(collection_option.collection_num) == true then
                            set_collection_visible(collection_option.collection_num, false)
                        else
                            showCollections = 1
                            set_collection_visible(collection_option.collection_num, true)
                        end
                    end
                    visible_collections_dirty = true
                    save_visible_collection_settings()
                    visible_collections_dirty = false
                end
            elseif Controls.check(pad, SCE_CTRL_CIRCLE_MAP) and not Controls.check(oldpad, SCE_CTRL_CIRCLE_MAP) then
                oldpad = pad
                if visible_collections_dirty == true then
                    save_visible_collection_settings()
                end
                visible_collections_dirty = false
                visible_collection_selected = 1
                visible_collection_scrollPosition = 0
                showMenu = 3
                menuY = 3
            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                move_visible_collection_selection(-1)
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                move_visible_collection_selection(1)
            end
        end


-- MENU 26 - COLLECTION CUSTOM SORT ORDER
    elseif showMenu == 26 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Default)--Default
        label3 = Font.getTextWidth(fnt20, lang_lines.Select)--Select

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
                local endIdx = math.min(#xCollectionEditTableLookup(), cc_scrollPosition + cc_maxVisibleItems)

                -- Draw the visible items
                for i = startIdx, endIdx do
                    local collection_item = xCollectionEditTableLookup()[i]
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
                    if cc_edit_mode == true and i == cc_selected and i < #xCollectionEditTableLookup() and i > 1 then
                        Graphics.drawImage(13, yPosition, setting_icon_sort)
                    end
                    if cc_edit_mode == true and i == cc_selected and i == #xCollectionEditTableLookup() then
                        Graphics.drawImage(13, yPosition, setting_icon_sort_up)
                    end
                    if cc_edit_mode == true and i == cc_selected and i == 1 then
                        Graphics.drawImage(13, yPosition, setting_icon_sort_down)
                    end

                    if collection_item then
                        Font.print(fnt22, setting_x, yPosition, collection_item.apptitle or collection_item.name or "", color)
                    end
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
                        local temp = xCollectionEditTableLookup()[cc_selected]
                        xCollectionEditTableLookup()[cc_selected] = xCollectionEditTableLookup()[cc_selected - 1]
                        xCollectionEditTableLookup()[cc_selected - 1] = temp

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
                dpadHeldUp = 0  -- Reset counter on new press
                
            -- D-pad UP continuous scrolling
            elseif Controls.check(pad, SCE_CTRL_UP) then
                -- Initialize and increment held counter for continuous scrolling
                dpadHeldUp = (dpadHeldUp or 0) + 0.05
                
                -- Continuous scroll mode after initial delay
                if dpadHeldUp > 1 and delayButton < 0.05 then
                    delayButton = 0.7  -- Repeat delay for continuous scrolling
                    
                    if cc_edit_mode == true then
                        -- Move selected item Up
                        if cc_selected > 1 and cc_edit_mode == true then
                            local temp = xCollectionEditTableLookup()[cc_selected]
                            xCollectionEditTableLookup()[cc_selected] = xCollectionEditTableLookup()[cc_selected - 1]
                            xCollectionEditTableLookup()[cc_selected - 1] = temp

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
                end
         
            -- Handle downward movement (using Down button or left analog stick down)
            elseif (Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN)) or (analogY > 140 and delayButton < 0.5) then

                if cc_edit_mode == true then

                    -- Move selected item down
                    if cc_selected < #xCollectionEditTableLookup() then
                        local temp = xCollectionEditTableLookup()[cc_selected]
                        xCollectionEditTableLookup()[cc_selected] = xCollectionEditTableLookup()[cc_selected + 1]
                        xCollectionEditTableLookup()[cc_selected + 1] = temp

                        cc_selected = cc_selected + 1
                        if cc_selected > cc_scrollPosition + cc_maxVisibleItems then
                            cc_scrollPosition = cc_scrollPosition + 1
                        end

                    end
                    cc_updated = true
                    cc_reset = false

                else

                    -- Scroll down
                    if cc_selected < #xCollectionEditTableLookup() then
                        cc_selected = cc_selected + 1
                        if cc_selected > cc_scrollPosition + cc_maxVisibleItems then
                            cc_scrollPosition = cc_scrollPosition + 1
                        end
                    end
                end

                -- Reset delayButton after scrolling (adjusted to slow it down)
                delayButton = 1.5    -- Increase this value to slow the speed
                dpadHeldDown = 0  -- Reset counter on new press
                
            -- D-pad DOWN continuous scrolling
            elseif Controls.check(pad, SCE_CTRL_DOWN) then
                -- Initialize and increment held counter for continuous scrolling
                dpadHeldDown = (dpadHeldDown or 0) + 0.05
                
                -- Continuous scroll mode after initial delay
                if dpadHeldDown > 1 and delayButton < 0.05 then
                    delayButton = 0.7  -- Repeat delay for continuous scrolling
                    
                    if cc_edit_mode == true then
                        -- Move selected item down
                        if cc_selected < #xCollectionEditTableLookup() then
                            local temp = xCollectionEditTableLookup()[cc_selected]
                            xCollectionEditTableLookup()[cc_selected] = xCollectionEditTableLookup()[cc_selected + 1]
                            xCollectionEditTableLookup()[cc_selected + 1] = temp

                            cc_selected = cc_selected + 1
                            if cc_selected > cc_scrollPosition + cc_maxVisibleItems then
                                cc_scrollPosition = cc_scrollPosition + 1
                            end
                        end
                        cc_updated = true
                        cc_reset = false
                    else
                        -- Scroll down
                        if cc_selected < #xCollectionEditTableLookup() then
                            cc_selected = cc_selected + 1
                            if cc_selected > cc_scrollPosition + cc_maxVisibleItems then
                                cc_scrollPosition = cc_scrollPosition + 1
                            end
                        end
                    end
                end
            
            elseif (Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE)) then
                state = Keyboard.getState()
                if state ~= RUNNING then
                    
                    cc_edit_mode = false

                    -- Reset to alphabetical order
                    table.sort(xCollectionEditTableLookup(), function(a, b) return ((a.apptitle or a.name or ""):lower() < (b.apptitle or b.name or ""):lower()) end)
                    
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
                                    for k, v in ipairs(xCollectionEditTableLookup()) do
                                        v.custom_sort_order = k
                                    end

                                    for i, item in ipairs(xCollectionEditTableLookup()) do
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
                                    for i, item in ipairs(xCollectionEditTableLookup()) do
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
                        collection_edit_table = {}
                        import_collections()

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
            
            -- Reset D-pad held counters when buttons are released (for collection sort)
            if not Controls.check(pad, SCE_CTRL_UP) then
                dpadHeldUp = 0
            end
            if not Controls.check(pad, SCE_CTRL_DOWN) then
                dpadHeldDown = 0
            end

            oldpad = pad

        end


-- MENU 27 - RETROARCH CORE OPTIONS
    elseif showMenu == 27 then
        
        -- SETTINGS
        -- Footer buttons and icons
        -- Get text widths for positioning
        label1 = Font.getTextWidth(fnt20, lang_lines.Close)--Close
        label2 = Font.getTextWidth(fnt20, lang_lines.Select)--Select


        -- GET MENU ITEM COUNT
            
            menuItems = 3

            if core_overrides[apptype] then
                core_total = #core_overrides[apptype]
            else
                core_total = 0
            end
            if game_core == nil or game_core > core_total then
                game_core = 0
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


        -- MENU 21 / Heading
        Font.print(fnt22, setting_x, setting_yh + y_centre_text_offset, lang_lines.Emulator_core, white)--Emulator core

        -- MENU 21 / #0 Back
        Font.print(fnt22, setting_x, setting_y0 + y_centre_text_offset, lang_lines.Back_Chevron, white)--Back

        -- MENU 21 / #1 Core
        Font.print(fnt22, setting_x, setting_y1 + y_centre_text_offset, lang_lines.Core_colon, white)--core

        -- MENU 21 / #2 Core
        Font.print(fnt22, setting_x, setting_y2 + y_centre_text_offset, lang_lines.Global_core_colon, white)--Global core

        

        -- Menu
        -- Get global core name
        local setting_x_core = 360
        local global_core_name = core_overrides[apptype] and get_core_option_display_name(core_overrides[apptype][0]) or ""
        if game_core >= 1 and core_overrides[apptype] and core_overrides[apptype][game_core] then
            Font.print(fnt22, setting_x_core, setting_y1 + y_centre_text_offset, "<  " .. get_core_option_display_name(core_overrides[apptype][game_core]) .. "  >", white)
        elseif core_overrides[apptype] and core_overrides[apptype][0] then
            Font.print(fnt22, setting_x_core, setting_y1 + y_centre_text_offset, "<  " .. lang_lines.Use_Global .. "  >", white) -- Use Global
        end

        Font.print(fnt22, setting_x_core, setting_y2 + y_centre_text_offset, global_core_name, white)


        -- MENU 27 / #3 Save
        Font.print(fnt22, setting_x, setting_y3 + y_centre_text_offset, lang_lines.Save, white)--Save

        
        -- MENU 27 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then

                -- MENU 27
                if menuY == 0 then -- #0 Back
                    showMenu = 20
                    if remove_from_collection_flag == true then
                        menuY=5
                    else
                        menuY=4
                    end

                elseif menuY == 3 then -- #3 Save the setting
                    local selected_core = core_overrides[apptype] and core_overrides[apptype][game_core]
                    local override_key = get_game_core_override_key()
                    if selected_core and override_key then
                        if game_core == 0 then
                            GameCoreOverrides[override_key] = nil
                        else
                            GameCoreOverrides[override_key] = selected_core.core_id
                        end
                        save_game_core_overrides()
                    end

                    if #launch_overrides_table ~= nil then
                        local key = find_game_table_pos_key(launch_overrides_table, app_titleid)
                        if key ~= nil then
                            if game_core == 0 then
                                table.remove(launch_overrides_table, key)
                            else
                                -- Yes - it's already in the launch override list, update it.
                                launch_overrides_table[key].core = game_core
                                launch_overrides_table[key].core_path = selected_core and selected_core.core_path or nil
                            end

                        elseif game_core ~= 0 then
                            -- No, it's new, add it to the launch override list
                            launch_overrides_temp = {}
                            table.insert(launch_overrides_temp, {
                                name = app_titleid, 
                                core = game_core, 
                                core_path = selected_core and selected_core.core_path or nil,
                                apptitle = app_title, 
                                app_type = apptype,
                                game_path = game_path,
                            })

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
                if menuY == 1 then -- #1 core
                    if game_core > 0 then
                        game_core = game_core - 1
                    else
                        game_core = core_total
                    end
                end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
                if menuY == 1 then -- #1 core
                    if game_core < core_total then
                        game_core = game_core + 1
                    else
                        game_core = 0
                    end
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


-- MENU 28 - EMULATOR CORE SETTINGS
    elseif showMenu == 28 then
        build_emulator_core_platforms()
        if emulator_core_settings_platform_index == nil then
            emulator_core_settings_platform_index = 1
        end
        if emulator_core_settings_platform_index > #emulator_core_platforms then
            emulator_core_settings_platform_index = 1
        end
        if emulator_core_settings_platform_index < 1 then
            emulator_core_settings_platform_index = #emulator_core_platforms
        end

        local selected_platform = emulator_core_platforms[emulator_core_settings_platform_index]
        emulator_core_settings_system_id = selected_platform and selected_platform.id or nil
        local available_cores = emulator_core_settings_system_id and GetAvailableCores(emulator_core_settings_system_id) or {}
        local selected_core_index = emulator_core_settings_system_id and get_core_index_for_system(emulator_core_settings_system_id) or 1
        local selected_core_id = available_cores[selected_core_index]
        local selected_platform_label = get_system_label(selected_platform)
        local selected_core_label = selected_core_id and get_core_display_string(selected_core_id, setLanguage) or ""
        
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

        Font.print(fnt22, setting_x, setting_yh, lang_lines.Global_core_settings, white)--Global core settings
        Graphics.fillRect(60, 900, 78, 81, white)

        Graphics.fillRect(60, 900, 82 + (menuY * 47), 129 + (menuY * 47), themeCol)-- selection


        menuItems = 5

        -- MENU 28 / #0 Back
        Font.print(fnt22, setting_x, setting_y0, lang_lines.Back_Chevron, white)--Back

        -- MENU 28 / #1 Platform
        Font.print(fnt22, setting_x, setting_y1, lang_lines.Platform_colon, white)--Platform:
        if #emulator_core_platforms > 1 then
            Font.print(fnt22, setting_x_offset, setting_y1, "<  " .. selected_platform_label .. "  >", white)
        else
            Font.print(fnt22, setting_x_offset, setting_y1, selected_platform_label, white)
        end

        -- MENU 28 / #2 Core
        Font.print(fnt22, setting_x, setting_y2, lang_lines.Core_colon, white)--Core
        if #available_cores > 1 then
            Font.print(fnt22, setting_x_offset, setting_y2, "<  " .. selected_core_label .. "  >", white)
        else
            Font.print(fnt22, setting_x_offset, setting_y2, selected_core_label, white)
        end

        -- MENU 28 / #3 Reset platform core to recommended
        Font.print(fnt22, setting_x, setting_y3, lang_lines.Reset_platform_core, white)--Reset platform core

        -- MENU 28 / #4 Reset all platform cores to recommended
        Font.print(fnt22, setting_x, setting_y4, lang_lines.Reset_all_platform_cores, white)--Reset all platform cores

        -- MENU 28 / #5 Reset all game overrides
        Font.print(fnt22, setting_x, setting_y5, lang_lines.Reset_all_game_overrides, white)--Reset all game overrides

        -- MENU 28 / #8 Reset all game overrides
        Font.print(fnt22, setting_x, setting_y7, lang_lines.Star_Recommended_core, white_opaque)--★ Recommended core

        

        -- MENU 28 - FUNCTIONS
        status = System.getMessageState()
        if status ~= RUNNING then
    
            if (Controls.check(pad, SCE_CTRL_CROSS_MAP) and not Controls.check(oldpad, SCE_CTRL_CROSS_MAP)) then
                if menuY == 0 then -- #0 Back
                    showMenu = 19
                    menuY = 6 -- Other Settings
                elseif menuY == 3 then -- #3 Reset to recommended core
                    if emulator_core_settings_system_id and RecommendedCores[emulator_core_settings_system_id] then
                        set_global_core_for_system(emulator_core_settings_system_id, RecommendedCores[emulator_core_settings_system_id])
                        rebuild_legacy_core_tables()
                    end
                elseif menuY == 4 then -- #4 Restore all recommended cores
                    reset_global_core_overrides()
                    rebuild_legacy_core_tables()
                elseif menuY == 5 then -- #5 Clear all game overrides
                    reset_game_core_overrides()
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
                if menuY == 1 then
                    if #emulator_core_platforms > 1 then
                        if emulator_core_settings_platform_index > 1 then
                            emulator_core_settings_platform_index = emulator_core_settings_platform_index - 1
                        else
                            emulator_core_settings_platform_index = #emulator_core_platforms
                        end
                    end
                elseif menuY == 2 then
                    if #available_cores > 1 then
                        if selected_core_index > 1 then
                            selected_core_index = selected_core_index - 1
                        else
                            -- selected_core_index = #available_cores
                        end
                        set_global_core_for_system(emulator_core_settings_system_id, available_cores[selected_core_index])
                        rebuild_legacy_core_tables()
                    end
                end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
                if menuY == 1 then
                    if #emulator_core_platforms > 1 then
                        if emulator_core_settings_platform_index < #emulator_core_platforms then
                            emulator_core_settings_platform_index = emulator_core_settings_platform_index + 1
                        else
                            emulator_core_settings_platform_index = 1
                        end
                    end
                elseif menuY == 2 then
                    if #available_cores > 1 then
                        if selected_core_index < #available_cores then
                            selected_core_index = selected_core_index + 1
                        else
                            -- selected_core_index = 1
                        end
                        set_global_core_for_system(emulator_core_settings_system_id, available_cores[selected_core_index])
                        rebuild_legacy_core_tables()
                    end
                end
            elseif Controls.check(pad, SCE_CTRL_CIRCLE_MAP) and not Controls.check(oldpad, SCE_CTRL_CIRCLE_MAP) then
                oldpad = pad
                showMenu = 19
                menuY = 6
            end
            
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

    if showMenu == 29 then
        --Scroll through Visible Categories
        if my < 64 then
            if delayButton < 0.5 then
                delayButton = 1
                move_visible_category_selection(-1)
            end
        elseif my > 180 then
            if delayButton < 0.5 then
                delayButton = 1
                move_visible_category_selection(1)
            end
        end

        if Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) then
            dpadHeldUp = 0
        elseif Controls.check(pad, SCE_CTRL_UP) then
            dpadHeldUp = (dpadHeldUp or 0) + 0.05
            if dpadHeldUp > 1 and delayButton < 0.05 then
                delayButton = 0.7
                move_visible_category_selection(-1)
            end
        elseif Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) then
            dpadHeldDown = 0
        elseif Controls.check(pad, SCE_CTRL_DOWN) then
            dpadHeldDown = (dpadHeldDown or 0) + 0.05
            if dpadHeldDown > 1 and delayButton < 0.05 then
                delayButton = 0.7
                move_visible_category_selection(1)
            end
        end
    end

    if showMenu == 30 then
        --Scroll through Visible Collections
        if my < 64 then
            if delayButton < 0.5 then
                delayButton = 1
                move_visible_collection_selection(-1)
            end
        elseif my > 180 then
            if delayButton < 0.5 then
                delayButton = 1
                move_visible_collection_selection(1)
            end
        end

        if Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) then
            dpadHeldUp = 0
        elseif Controls.check(pad, SCE_CTRL_UP) then
            dpadHeldUp = (dpadHeldUp or 0) + 0.05
            if dpadHeldUp > 1 and delayButton < 0.05 then
                delayButton = 0.7
                move_visible_collection_selection(-1)
            end
        elseif Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) then
            dpadHeldDown = 0
        elseif Controls.check(pad, SCE_CTRL_DOWN) then
            dpadHeldDown = (dpadHeldDown or 0) + 0.05
            if dpadHeldDown > 1 and delayButton < 0.05 then
                delayButton = 0.7
                move_visible_collection_selection(1)
            end
        end
    end

    if showMenu > 1 
        and showMenu ~= 11 -- ROM Browser
        and showMenu ~= 29 -- Visible Categories
        and showMenu ~= 30 -- Visible Collections
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
        
        -- D-pad menu scrolling with continuous scrolling
        if Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) then
            dpadHeldUp = 0
        elseif Controls.check(pad, SCE_CTRL_UP) then
            -- Initialize and increment held counter for continuous scrolling
            dpadHeldUp = (dpadHeldUp or 0) + 0.05
            
            -- Continuous scroll mode after initial delay
            if dpadHeldUp > 1 and delayButton < 0.05 then
                delayButton = 0.7  -- Repeat delay for continuous scrolling
                if menuY > 0 then
                    menuY = menuY - 1
                else
                    menuY = menuItems
                end
            end
        elseif Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) then
            dpadHeldDown = 0
        elseif Controls.check(pad, SCE_CTRL_DOWN) then
            -- Initialize and increment held counter for continuous scrolling
            dpadHeldDown = (dpadHeldDown or 0) + 0.05
            
            -- Continuous scroll mode after initial delay
            if dpadHeldDown > 1 and delayButton < 0.05 then
                delayButton = 0.7  -- Repeat delay for continuous scrolling
                if menuY < menuItems then
                    menuY = menuY + 1
                else
                    menuY = 0
                end
            end
        end
        
        -- Reset D-pad held counters when buttons are released (for menu navigation)
        if not Controls.check(pad, SCE_CTRL_UP) then
            dpadHeldUp = 0
        end
        if not Controls.check(pad, SCE_CTRL_DOWN) then
            dpadHeldDown = 0
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
                                rom_location = (games_table[p].game_path) launch_retro_emulator(core.PS1)
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
                                rom_location = (homebrews_table[p].game_path) launch_retro_emulator(core.PS1)
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
                                rom_location = (psp_table[p].game_path) launch_retro_emulator(core.PS1)
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
                                rom_location = (psx_table[p].game_path) launch_retro_emulator(core.PS1)
                            else
                                -- Vita app
                                launch_vita_title(psx_table[p].name)
                            end
                        end

                    -- Start Retro    
                    elseif showCat == 5 then rom_title_id = tostring(psm_table[p].name) launch_psmobile(rom_title_id)
                    elseif showCat == 6 then rom_location = (n64_table[p].game_path) launch_DaedalusX64()
                    elseif showCat == 7 then rom_location = (snes_table[p].game_path) launch_retro_emulator(core.SNES)
                    elseif showCat == 8 then rom_location = (nes_table[p].game_path) launch_retro_emulator(core.NES)
                    elseif showCat == 9 then rom_location = (n3ds_table[p].game_path) launch_Azahar()
                    elseif showCat == 10 then rom_location = (nds_table[p].game_path) launch_DSVita()
                    elseif showCat == 11 then rom_location = (gba_table[p].game_path) launch_retro_emulator(core.GBA)
                    elseif showCat == 12 then rom_location = (gbc_table[p].game_path) launch_retro_emulator(core.GBC)
                    elseif showCat == 13 then rom_location = (gb_table[p].game_path) launch_retro_emulator(core.GB)
                    elseif showCat == 14 then rom_location = (dreamcast_table[p].game_path) launch_Flycast()
                    elseif showCat == 15 then rom_location = (sega_cd_table[p].game_path) launch_retro_emulator(core.SEGA_CD) 
                    elseif showCat == 16 then rom_location = (s32x_table[p].game_path) launch_retro_emulator(core.s32X) 
                    elseif showCat == 17 then rom_location = (md_table[p].game_path) launch_retro_emulator(core.MD)
                    elseif showCat == 18 then rom_location = (sms_table[p].game_path) launch_retro_emulator(core.SMS)
                    elseif showCat == 19 then rom_location = (gg_table[p].game_path) launch_retro_emulator(core.GG)
                    elseif showCat == 20 then rom_location = (tg16_table[p].game_path) launch_retro_emulator(core.TG16)
                    elseif showCat == 21 then rom_location = (tgcd_table[p].game_path) launch_retro_emulator(core.TGCD)
                    elseif showCat == 22 then rom_location = (pce_table[p].game_path) launch_retro_emulator(core.PCE)
                    elseif showCat == 23 then rom_location = (pcecd_table[p].game_path) launch_retro_emulator(core.PCECD)
                    elseif showCat == 24 then rom_location = (amiga_table[p].game_path) launch_retro_emulator(core.AMIGA)
                    elseif showCat == 25 then rom_title_id = (scummvm_table[p].titleid) rom_location = (scummvm_table[p].game_path) launch_scummvm()
                    elseif showCat == 26 then rom_location = (easyrpg_table[p].game_path) launch_EasyRPG()
                    elseif showCat == 27 then rom_location = (dos_table[p].game_path) launch_retro_emulator(core.DOS)
                    elseif showCat == 28 then rom_location = (c64_table[p].game_path) launch_retro_emulator(core.C64)
                    elseif showCat == 29 then rom_location = (wswan_col_table[p].game_path) launch_retro_emulator(core.WSWAN_COL)
                    elseif showCat == 30 then rom_location = (wswan_table[p].game_path) launch_retro_emulator(core.WSWAN)
                    elseif showCat == 31 then rom_location = (pico8_table[p].game_path) launch_pico8()
                    elseif showCat == 32 then rom_location = (msx2_table[p].game_path) launch_retro_emulator(core.MSX2)
                    elseif showCat == 33 then rom_location = (msx1_table[p].game_path) launch_retro_emulator(core.MSX1)
                    elseif showCat == 34 then rom_location = (zxs_table[p].game_path) launch_retro_emulator(core.ZXS)
                    elseif showCat == 35 then rom_location = (atari_st_table[p].game_path) launch_retro_emulator(core.ATARI_ST)
                    elseif showCat == 36 then rom_location = (atari_7800_table[p].game_path) launch_retro_emulator(core.ATARI_7800)
                    elseif showCat == 37 then rom_location = (atari_5200_table[p].game_path) launch_retro_emulator(core.ATARI_5200)
                    elseif showCat == 38 then rom_location = (atari_2600_table[p].game_path) launch_retro_emulator(core.ATARI_2600)
                    elseif showCat == 39 then rom_location = (atari_lynx_table[p].game_path) launch_retro_emulator(core.ATARI_LYNX)
                    elseif showCat == 40 then rom_location = (colecovision_table[p].game_path) launch_retro_emulator(core.COLECOVISION)
                    elseif showCat == 41 then rom_location = (vectrex_table[p].game_path) launch_retro_emulator(core.VECTREX)
                    elseif showCat == 42 then rom_location = (fba_table[p].game_path) launch_retro_emulator(core.FBA)
                    elseif showCat == 43 then rom_location = (mame_2003_plus_table[p].game_path) launch_retro_emulator(core.MAME_2003_PLUS)
                    elseif showCat == 44 then rom_location = (mame_2000_table[p].game_path) launch_retro_emulator(core.MAME_2000)
                    elseif showCat == 45 then rom_location = (neogeo_table[p].game_path) launch_retro_emulator(core.NEOGEO)
                    elseif showCat == 46 then rom_location = (ngpc_table[p].game_path) launch_retro_emulator(core.NGPC)
                    elseif showCat == 47 then rom_location = launch_vita_sysapp(xCatLookup(showCat)[p].name)

                    elseif showCat >= 48 or showCat == 0 then
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
                                    rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.PS1)
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
                        elseif apptype == 6 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.SNES)
                        elseif apptype == 7 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.NES)
                        elseif apptype == 8 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.GBA)
                        elseif apptype == 9 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.GBC)
                        elseif apptype == 10 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.GB)
                        elseif apptype == 11 then rom_location = (xCatLookup(showCat)[p].game_path) launch_Flycast()
                        elseif apptype == 12 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.SEGA_CD) 
                        elseif apptype == 13 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.s32X) 
                        elseif apptype == 14 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.MD)
                        elseif apptype == 15 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.SMS)
                        elseif apptype == 16 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.GG)
                        elseif apptype == 17 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.TG16)
                        elseif apptype == 18 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.TGCD)
                        elseif apptype == 19 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.PCE)
                        elseif apptype == 20 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.PCECD)
                        elseif apptype == 21 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.AMIGA)
                        elseif apptype == 22 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.C64)
                        elseif apptype == 23 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.WSWAN_COL)
                        elseif apptype == 24 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.WSWAN)
                        elseif apptype == 25 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.MSX2)
                        elseif apptype == 26 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.MSX1)
                        elseif apptype == 27 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.ZXS)
                        elseif apptype == 28 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.ATARI_7800)
                        elseif apptype == 29 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.ATARI_5200)
                        elseif apptype == 30 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.ATARI_2600)
                        elseif apptype == 31 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.ATARI_LYNX)
                        elseif apptype == 32 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.COLECOVISION)
                        elseif apptype == 33 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.VECTREX)
                        elseif apptype == 34 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.FBA)
                        elseif apptype == 35 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.MAME_2003_PLUS)
                        elseif apptype == 36 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.MAME_2000)
                        elseif apptype == 37 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.NEOGEO)
                        elseif apptype == 38 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.NGPC)
                        elseif apptype == 39 then rom_title_id = tostring(xCatLookup(showCat)[p].name) launch_psmobile(rom_title_id)
                        elseif apptype == 40 then rom_title_id = (xCatLookup(showCat)[p].titleid) rom_location = (xCatLookup(showCat)[p].game_path) launch_scummvm()
                        elseif apptype == 41 then rom_location = (xCatLookup(showCat)[p].game_path) launch_pico8()
                        elseif apptype == 42 then rom_location = launch_vita_sysapp(xCatLookup(showCat)[p].name)
                        elseif apptype == 43 then rom_location = (xCatLookup(showCat)[p].game_path) launch_DSVita()
                        elseif apptype == 44 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.ATARI_ST)
                        elseif apptype == 45 then rom_location = (xCatLookup(showCat)[p].game_path) launch_retro_emulator(core.DOS)
                        elseif apptype == 46 then rom_location = (xCatLookup(showCat)[p].game_path) launch_EasyRPG()
                        elseif apptype == 47 then rom_location = (xCatLookup(showCat)[p].game_path) launch_Azahar()

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
                
                if Controls.check(pad, SCE_CTRL_DOWN) then
                    change_category(-1)
                else
                    change_category(1)
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
                end
            end
        elseif (Controls.check(pad, SCE_CTRL_LEFT)) then
            if showView ~= 6 then
                -- Initialize and increment held counter for continuous scrolling
                dpadHeldLeft = (dpadHeldLeft or 0) + 0.05
                
                -- Continuous scroll mode after initial delay
                if dpadHeldLeft > 1 and delayButton < 0.05 then
                    delayButton = 0.55  -- Repeat delay for continuous scrolling
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
                    end
                end
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
                end
            else
                if delayButton < 0.05 then
                    delayButton = 0.4
                    state = Keyboard.getState()
                    if state ~= RUNNING then

                        -- Filter games
                        showMenu = 25
                        menuY = 0

                    else
                    end
                end
            end
        elseif (Controls.check(pad, SCE_CTRL_RIGHT)) then
            if showView ~= 6 then
                -- Initialize and increment held counter for continuous scrolling
                dpadHeldRight = (dpadHeldRight or 0) + 0.05
                
                -- Continuous scroll mode after initial delay
                if dpadHeldRight > 1 and delayButton < 0.05 then
                    delayButton = 0.55  -- Repeat delay for continuous scrolling
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
                    end
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
        elseif (Controls.check(pad, SCE_CTRL_UP)) then
            if showView == 6 then
                -- Initialize and increment held counter for continuous scrolling
                dpadHeldUp = (dpadHeldUp or 0) + 0.05
                
                -- Continuous scroll mode after initial delay
                if dpadHeldUp > 1 and delayButton < 0.05 then
                    delayButton = 0.55  -- Repeat delay for continuous scrolling
                    if setSounds == 1 then
                        Sound.play(click, NO_LOOP)
                    end
                    p = p - 1
                end
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
        elseif (Controls.check(pad, SCE_CTRL_DOWN)) then
            if showView == 6 then
                -- Initialize and increment held counter for continuous scrolling
                dpadHeldDown = (dpadHeldDown or 0) + 0.05
                
                -- Continuous scroll mode after initial delay
                if dpadHeldDown > 1 and delayButton < 0.05 then
                    delayButton = 0.55  -- Repeat delay for continuous scrolling
                    if setSounds == 1 then
                        Sound.play(click, NO_LOOP)
                    end
                    p = p + 1
                end
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
                    showMenu = 3
                    menuY=4
                elseif showMenu == 29 then -- Visible Categories
                    if visible_categories_requires_reload == true then
                        FreeIcons()
                        count_cache_and_reload()
                    end
                    save_visible_category_settings()
                    visible_categories_dirty = false
                    visible_categories_requires_reload = false
                    visible_category_selected = 1
                    visible_category_scrollPosition = 0
                    showMenu = 3
                    menuY=2
                elseif showMenu == 30 then -- Visible Collections
                    if visible_collections_dirty == true then
                        save_visible_collection_settings()
                    end
                    visible_collections_dirty = false
                    visible_collection_selected = 1
                    visible_collection_scrollPosition = 0
                    showMenu = 3
                    menuY=3
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


    if showCat == 48 then
        refresh_fav_count_table()
        
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

    if restart_after_frame == true then
        restart_after_frame = false
        FreeIcons()
        FreeMemory()
        Network.term()
        dofile("app0:index.lua")
    end

    if oneLoopTimer then -- Only run timer check once at end of initialization
        oneLoopTime = Timer.getTime(oneLoopTimer) -- save the time
        Timer.destroy(oneLoopTimer)
        oneLoopTimer = nil -- clear timer value - prevents frame-by-frame timer overhead
    end 

    init_music_if_needed()
end
