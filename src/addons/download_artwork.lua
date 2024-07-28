-- ABOUT

	-- 'ONElua' is used in this file. Documentation: http://onelua.x10.mx/


-- SETUP - INITIAL

		local cur_dir = "ux0:/data/RetroFlow/"
		local user_crc_lua = "user_crc.lua"
		local titles_dir = "ux0:/data/RetroFlow/TITLES/"
		local db_Cache_Folder = "ux0:/data/RetroFlow/CACHE/"
		local setCRCScan = 1 -- 1 is On
		local has_artwork = false

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
		["of"] = " of ",
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


		function update_cached_table(def_user_db_file, def_table_name)
			dofile("addons/printTable_onelua.lua")
			print_table_system((def_user_db_file), (def_table_name))
		end



-- COMMAND - FILE CRC CHECK: Download missing covers

	local missing_artwork_count = 0
	local download_mode_covers = false
	local download_mode_snaps = false

	if files.exists(titles_dir .. "/" .. "missing_covers.lua") then
		download_mode_covers = true
	end
	if files.exists(titles_dir .. "/" .. "missing_snaps.lua") then
		download_mode_snaps = true
	end


	function download_mode_path_local()
		if download_mode_covers == true then 
			return "cover_path_local"
		else
			return "snap_path_local"
		end
	end

	function download_mode_path_online()
		if download_mode_covers == true then 
			return "cover_path_online"
		else
			return "snap_path_online"
		end
	end

	-- Check for temporary file from vita lua, if it exists then extract images
	if download_mode_covers == true or download_mode_snaps == true then

		function import_cached_DB_tables(def_user_db_file, def_table_name)
		    if files.exists(db_Cache_Folder .. (def_user_db_file)) then

		        db_Cache = db_Cache_Folder .. (def_user_db_file)

		        local db_import = {}
		        db_import = dofile(db_Cache)

		        for l, file in pairs(db_import) do

		        	if download_mode_snaps == true then
			        	local missing_snap = false
	                    if files.exists(file.snap_path_local .. file.name .. ".png") then
	                        missing_snap = false
	                        file.snap = true
	                    elseif files.exists(file.snap_path_local .. file.title .. ".png") then
	                        missing_snap = false
	                        file.snap = true
	                    else
	                        missing_snap = true
	                        file.snap = false
	                        missing_artwork_count = missing_artwork_count + 1
	                    end
	                else
	                	if file.cover == false or string.match(file.icon_path, "%icon0.png") then
	                		missing_artwork_count = missing_artwork_count + 1
	                	end
	                end

		        	table.insert((def_table_name), file)
		        end

		    end
		end

		function import_cached_DB()

		    games_table = {}
		    homebrews_table = {}
		    psp_table = {}
		    psx_table = {}
		    n64_table = {}
		    snes_table = {}
		    nes_table = {}
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

		    import_cached_DB_tables("db_games.lua", games_table)
		    -- import_cached_DB_tables("db_homebrews.lua", homebrews_table)
		    import_cached_DB_tables("db_psp.lua", psp_table)
		    import_cached_DB_tables("db_psx.lua", psx_table)
		    import_cached_DB_tables("db_n64.lua", n64_table)
		    import_cached_DB_tables("db_snes.lua", snes_table)
		    import_cached_DB_tables("db_nes.lua", nes_table)
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
		    -- import_cached_DB_tables("db_psm.lua", psm_table)
		    import_cached_DB_tables("db_scummvm.lua", scummvm_table)
		    

		    table.sort(games_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
		    -- table.sort(homebrews_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
		    table.sort(psp_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
		    table.sort(psx_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)

		    table.sort(n64_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
		    table.sort(snes_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
		    table.sort(nes_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
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
		    -- table.sort(psm_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
		    table.sort(scummvm_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
		    -- table.sort(pico8_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)

		end

		-- Delete temp files to prevent looping into crc check on restart

		if download_mode_covers == true then
			files.delete(titles_dir .. "/" .. "missing_covers.lua")
        else
			files.delete(titles_dir .. "/" .. "missing_snaps.lua")
        end

        -- Import cached tables
        import_cached_DB()

		-- Import recently played table - will need to update any new covers found
		recently_played_table = {}
        if files.exists("ux0:/data/RetroFlow/recently_played.lua") then
        	recently_played_table = dofile("ux0:/data/RetroFlow/recently_played.lua")
        else
        end

	    -- List of CRC lookups available
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
		    -- elseif AppTypeNum == 42 then return fav_count
		    -- elseif AppTypeNum == 43 then return recently_played_table
		    -- elseif AppTypeNum == 44 then return search_results_table
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
		    else return "db_homebrews.lua"
		    end
		end

		function xAppNumCRCLookupDB(AppTypeNum)
			-- Lookup CRC lua file to load
			
		    if AppTypeNum == 5 then      return "crc_db_n64.lua"    			-- n64_table
		    elseif AppTypeNum == 6 then  return "crc_db_snes.lua"    			-- snes_table
		    elseif AppTypeNum == 7 then  return "crc_db_nes.lua"    			-- nes_table
		    elseif AppTypeNum == 8 then  return "crc_db_gba.lua"    			-- gba_table
		    elseif AppTypeNum == 9 then  return "crc_db_gbc.lua"    			-- gbc_table
		    elseif AppTypeNum == 10 then return "crc_db_gb.lua"    				-- gb_table
		    elseif AppTypeNum == 13 then return "crc_db_32x.lua"    			-- s32x_table
		    elseif AppTypeNum == 14 then return "crc_db_md.lua"    				-- md_table
		    elseif AppTypeNum == 15 then return "crc_db_sms.lua"    			-- sms_table
		    elseif AppTypeNum == 16 then return "crc_db_gg.lua"    				-- gg_table
		    elseif AppTypeNum == 17 then return "crc_db_pce_tg16.lua"    		-- tg16_table	
		    elseif AppTypeNum == 19 then return "crc_db_pce_tg16.lua"     		-- pce_table
		    elseif AppTypeNum == 23 then return "crc_db_wswan_col.lua"    		-- wswan_col_table
		    elseif AppTypeNum == 24 then return "crc_db_wswan.lua"    			-- wswan_table
		    elseif AppTypeNum == 25 then return "crc_db_msx2.lua"    			-- msx2_table
		    elseif AppTypeNum == 26 then return "crc_db_msx1.lua"    			-- msx1_table
		    elseif AppTypeNum == 28 then return "crc_db_atari_7800.lua"    		-- atari_7800_table
		    elseif AppTypeNum == 29 then return "crc_db_atari_5200.lua"    		-- atari_5200_table
		    elseif AppTypeNum == 30 then return "crc_db_atari_2600.lua"    		-- atari_2600_table
		    elseif AppTypeNum == 31 then return "crc_db_atari_lynx.lua"    		-- atari_lynx_table
		    elseif AppTypeNum == 32 then return "crc_db_colecovision.lua"   	-- colecovision_table
		    elseif AppTypeNum == 33 then return "crc_db_vectrex.lua"    		-- vectrex_table
		    elseif AppTypeNum == 38 then return "crc_db_ngpc.lua"    			-- ngpc_table

		    -- elseif AppTypeNum == 0 then return "crc_db_games.lua"        	-- homebrews_table
		    -- elseif AppTypeNum == 1 then return "crc_db_games.lua"        	-- games_table
		    -- elseif AppTypeNum == 2 then  return "crc_db_psp.lua"   			-- psp_table
		    -- elseif AppTypeNum == 3 then  return "crc_db_psx.lua"   			-- psx_table
		    -- elseif AppTypeNum == 11 then return "crc_db_dreamcast.lua" 		-- dreamcast_table
		    -- elseif AppTypeNum == 12 then return "crc_db_sega_cd.lua" 		-- sega_cd_table
		    -- elseif AppTypeNum == 18 then return "crc_db_tgcd.lua"   			-- tgcd_table
		    -- elseif AppTypeNum == 20 then return "crc_db_pcecd.lua"   		-- pcecd_table
		    -- elseif AppTypeNum == 21 then return "crc_db_amiga.lua"   		-- amiga_table
		    -- elseif AppTypeNum == 22 then return "crc_db_c64.lua"   			-- c64_table
		    -- elseif AppTypeNum == 27 then return "crc_db_zxs.lua"   			-- zxs_table
		    -- elseif AppTypeNum == 34 then return "crc_db_fba.lua"   			-- fba_table
		    -- elseif AppTypeNum == 35 then return "crc_db_fba.lua"   			-- mame_2003_plus_table
		    -- elseif AppTypeNum == 36 then return "crc_db_mame_2000.lua"   	-- mame_2000_table
		    -- elseif AppTypeNum == 37 then return "crc_db_neogeo.lua"   		-- neogeo_table
		    -- elseif AppTypeNum == 39 then return "crc_db_psm.lua"   			-- psm_table
		    -- elseif AppTypeNum == 40 then return "crc_db_scummvm.lua"   		-- scummvm_table
		    -- elseif AppTypeNum == 41 then return "crc_db_pico8.lua"   		-- pico8_table
		    else
		    	return false
		    end
		end

		-- Read function for CRC
		function files.read(path,mode)
			local fp = io.open(path, mode or "r")
			if not fp then return nil end

			local data = fp:read("*a")
			fp:close()
			return data
		end

		-- Function to reformat CRC result
		function Dec2Hex(nValue)
			if type(nValue) == "string" then
				nValue = String.ToNumber(nValue);
			end
			nHexVal = string.format("%x", nValue);  -- %X returns uppercase hex, %x gives lowercase letters
			sHexVal = nHexVal.."";

			-- Adds missing zero infront on CRC code
			if string.len(sHexVal) == 7 then
			    sHexVal = tostring("0" .. sHexVal)
			end

			return sHexVal;
		end

		-- URL encode game name - differs from vita lua
		function urlencode (str)
			str = string.gsub (str, "([^0-9a-zA-Z !'()*._~-])", -- locale independent
			function (c) return string.format ("%%%02X", string.byte(c)) end)
			str = string.gsub (str, " ", "%%20")
			str = string.gsub (str, "%(", "%%28")
			str = string.gsub (str, "%)", "%%29")

			-- -- Fix for amphersand resulting in 404
			-- if string.match(str, "%%26") then
			-- 	str = string.gsub (str, "%%26", "&")
			-- else
			-- end
			
	       return str
	    end

	    function draw_downloaded_artwork(artwork_file_dest_path)

			local artwork_img = image.load(artwork_file_dest_path)

		    -- image.resize(getfile_ret, 960, 544)
		    if artwork_img then
				-- image.blit(pic1, 0, 0)

				-- get_artwork_scale
				
			    local portrait = false
			    local landscape = false
			    local square = false

			    artwork_width = image.getw(artwork_img)
			    artwork_height = image.geth(artwork_img)

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

			    -- Scale image by percent
			    image.scale(artwork_img, artwork_scale_percentage)

			    -- Get size of scaled image
			    scaled_artwork_width = image.getw(artwork_img)
			    scaled_artwork_height = image.geth(artwork_img)

			    -- Vertical and horizontal centred X and Y position
			    artwork_x_pos = (vita_screen_width - scaled_artwork_width) / 2
			    artwork_y_pos = (vita_screen_height - scaled_artwork_height) / 2

			    -- Draw scaled image
			    image.blit(artwork_img, artwork_x_pos, artwork_y_pos)

			    -- Add dark overlay for snaps
			    if download_mode_snaps == true then
					draw.fillrect (0,0,960,544,color.new(0,0,0, 150))
					draw.gradrect (0, 0, 960, 150, gradient_start, gradient_end, 0)
				end

			else
			end

		end


		function importLuaFile(filename)

			-- Funcion used to fix: Unexpected symbol near eof, unfinished string near eof
		    local status, chunk = pcall(loadfile, filename)
		    if not status then
		        -- print("Error loading Lua file:", chunk)
		        return nil
		    end
		    
		    local success, result = pcall(chunk)
		    if not success then
		        -- print("Error executing Lua file:", result)
		        return nil
		    end
		    
		    return result
		end

		-- Check CRC for files with missing covers
		if missing_artwork_count >= 1 then

			missing_artwork_total = missing_artwork_count
			local crcs_checked = 0
			local artwork_found_count = 0

			-- Update progress and reset screen
			function crc_progress_bar_update()
				crcs_checked = crcs_checked + 1
				-- screen.print(10,30,math.floor((crcs_checked/missing_artwork_total)*100).."%")
				-- draw.fillrect(0,534,((crcs_checked/missing_artwork_total)*960),10,green)
			end

			-- Load previous CRC matches
			user_crc_table = {}

		    
			if files.exists(titles_dir .. "/" .. user_crc_lua) then 

				-- Load file and check for errors
				local importFileNoError = importLuaFile(titles_dir .. "/" .. user_crc_lua)

				if importFileNoError then
				    -- File has no errors, import
				    user_crc_table = dofile(titles_dir .. user_crc_lua)
				else
				    -- File has errors, delete it
				    files.delete(titles_dir .. "/" .. user_crc_lua)
				end

			else
			end


		    local crc_results_table = {}

		    for k, v in pairs(user_crc_table) do
				local crc_info = {}
		    	crc_info.filename = tostring(k)
                crc_info.app_type = v.app_type
                crc_info.crc = v.crc
                crc_info.crc_name = v.crc_name
                table.insert(crc_results_table, crc_info)
			end

			-- Check CRC
			local syscount = 44
			local current_crc_apptype = 1

			while current_crc_apptype <= syscount do

				if #xAppNumTableLookup(current_crc_apptype) > 0 then

					local update_cache_needed = false


					if xAppNumCRCLookupDB(current_crc_apptype) ~= false and setCRCScan == 1 then

						-- CRC file available - Load CRC file for DB

						local crc_db_table = {}

						if files.exists("addons/crc/" .. xAppNumCRCLookupDB(current_crc_apptype)) then     
					        crc_db_table = dofile("addons/crc/" .. xAppNumCRCLookupDB(current_crc_apptype))
					    else
					    end


					    -- Check CRC
					    for i, file in pairs(xAppNumTableLookup(current_crc_apptype)) do
							
							-- Check if missing artwork

							if download_mode_covers == true then
								has_artwork = file.cover
							else
								has_artwork = file.snap
							end

							if has_artwork == false then

						    	-- Check is CRC is saved from previous scan in the user CRC table
						    	local crc_checked_before = false
						    	
						    	if #user_crc_table ~= nil then
						    		if user_crc_table[file.filename] ~= nil 
						    			and user_crc_table[file.filename].crc ~= nil 
						    			and user_crc_table[file.filename].app_type == current_crc_apptype then
						    			crc_checked_before = true
						    		else
						    		end
							    else
							    end


						    	if crc_checked_before == false then
						    	
						    		-- File has not been scanned before, is not in the user crc database

							    	-- Get file CRC - Offset bytes for NES, read whole file for everything else

							    	if string.match(file.filename, "%.zip") or string.match(file.filename, "%.rar") then

							    		-- Read contents of archive file
										archive_contents = {}
										archive_contents = files.scan(tostring(file.game_path))

										-- Check contents of zip file	
										if archive_contents == nil then
											-- Empty zip file skip crc check
											file.crc_result = "nil"
										elseif #archive_contents == 0 then
											-- Empty zip file skip crc check
											file.crc_result = "nil"
										elseif #archive_contents == 1 then
											-- If there is only one file, then check the CRC

												-- Extract file so can be read with byte offset
												files.extractfile (tostring(file.game_path), tostring(archive_contents[1].name), "ux0:/data/RetroFlow/")
												extracted_file = tostring("ux0:/data/RetroFlow/" .. archive_contents[1].name)

											if current_crc_apptype == 5 then

												-- N64 - Lookup header CRC
												local f = assert(io.open(tostring(extracted_file), "rb"))
												-- Offset first 10 bytes and get only 4 blocks for N64
												f:seek ("cur", 0x10)
											    local block = 4
											    local bytestring = ""
											    local bytes = f:read(block)

												if not bytes then break end
												for b in string.gfind(bytes, ".") do
													new_byte = string.format("%02X", string.byte(b))
													bytestring = bytestring .. new_byte
												end

											    file.crc_result = bytestring

											elseif current_crc_apptype == 7 then
												
												-- Offset first 10 bytes for NES
									    		f = io.open(tostring(extracted_file))
												f:seek ("cur", 0x10)
												local tmp = tostring(f:read("*all"))
												f:close()

												file.crc_result = Dec2Hex(os.crc32(tmp) )

											else
												-- -- Read the file into RAM without extracting
												-- archive_game = tostring(files.extractbuffer(tostring(file.game_path), tostring(archive_contents[1].name)) )
												-- file.crc_result = Dec2Hex(os.crc32(archive_game) )

												-- Read the whole file

													-- Function to calculate CRC32 in chunks
													local function crc32_file(file_path)
													    -- local chunk_size = 4096 -- 4 KB per chunk
													    local chunk_size = 16384 -- Increased chunk size to 16 KB for fewer I/O operations
													    local file = io.open(file_path, "rb")
													    if not file then
													    	-- Error: Could not open file, move on
													        file.crc_result = "nil"
													    end
													    
													    local crc32 = 0 -- Initialize CRC32 with zero
													    while true do
													        local chunk = file:read(chunk_size)
													        if not chunk then break end
													        crc32 = os.crc32(chunk, crc32) -- Update CRC32 with each chunk
													    end
													    file:close()
													    return Dec2Hex(crc32)
													end

													-- Convert the game path to a string
													local filetoread = tostring(extracted_file)

													-- Calculate the CRC32 checksum using chunked reading
													local crc_result, err = crc32_file(filetoread)

													-- Handle the result
													if not crc_result then
													    -- Error: Move on
													    file.crc_result = "nil"
													else
													    file.crc_result = crc_result
													end

											end

											-- Delete extacted file
											files.delete(extracted_file)

										else						
										end

									elseif not string.match(file.filename, "%.7z") then

										if current_crc_apptype == 5 then
											-- N64 - Lookup header CRC
											
											local f = assert(io.open(tostring(file.game_path), "rb"))
											-- Offset first 10 bytes and get only 4 blocks for N64
											f:seek ("cur", 0x10)
										    local block = 4
										    local bytestring = ""
										    local bytes = f:read(block)

											if not bytes then break end
											for b in string.gfind(bytes, ".") do
												new_byte = string.format("%02X", string.byte(b))
												bytestring = bytestring .. new_byte
											end

										    file.crc_result = bytestring

										elseif current_crc_apptype == 7 then
								    		-- Offset first 10 bytes for NES
								    		f = io.open(tostring(file.game_path))
											f:seek ("cur", 0x10)
											local tmp = tostring(f:read("*all"))
											f:close()

											file.crc_result = Dec2Hex(os.crc32(tmp) )

								    	else

											-- Read the whole file

												-- Function to calculate CRC32 in chunks
												local function crc32_file(file_path)
												    -- local chunk_size = 4096 -- 4 KB per chunk
												    local chunk_size = 16384 -- Increased chunk size to 16 KB for fewer I/O operations
												    local file = io.open(file_path, "rb")
												    if not file then
												    	-- Error: Could not open file, move on
												        file.crc_result = "nil"
												    end
												    
												    local crc32 = 0 -- Initialize CRC32 with zero
												    while true do
												        local chunk = file:read(chunk_size)
												        if not chunk then break end
												        crc32 = os.crc32(chunk, crc32) -- Update CRC32 with each chunk
												    end
												    file:close()
												    return Dec2Hex(crc32)
												end

												-- Convert the game path to a string
												local filetoread = tostring(file.game_path)

												-- Calculate the CRC32 checksum using chunked reading
												local crc_result, err = crc32_file(filetoread)

												-- Handle the result
												if not crc_result then
												    -- Error: Move on
												    file.crc_result = "nil"
												else
												    file.crc_result = crc_result
												end

								    	end

								    else
								    	-- Is probably an incompatible 7z file, do nothing
								    	file.crc_result = "nil"
									end

								else
									-- File has been scanned before, use the CRC from the user crc database
									file.crc_result = user_crc_table[file.filename].crc
								end


						    	-- Find matching CRC in database
						    	crc_db_match = crc_db_table[file.crc_result]

						    	if crc_db_match == nil then

						    		-- No match found - download artwork using filename instead

					    				local artwork_found = false

						    			local artwork_file_url = tostring(file[download_mode_path_online()] .. urlencode(file.name) .. ".png")
						    			local artwork_file_tmp = tostring("ux0:/data/RetroFlow/" .. file.name .. ".png")
						    			local artwork_file_dest_dir = tostring(file[download_mode_path_local()])
						    			local artwork_file_dest_path = tostring(file[download_mode_path_local()] .. file.name .. ".png")

						    			http.download(artwork_file_url, artwork_file_tmp)

						    			-- Check filesize of download, if large enough, move to artwork dir, if not then delete
						    			if files.exists(artwork_file_tmp) then

						    				size = files.size(artwork_file_tmp)
								            if size < 1024 then
								            	files.delete(artwork_file_tmp)
								            else
								            	-- artwork sucessfully downloaded
								            	artwork_found = true
								            	update_cache_needed = true
								            	files.move(artwork_file_tmp, artwork_file_dest_dir)
								            	artwork_found_count = artwork_found_count + 1

								            	if artwork_found == true then

								            		-- Update table with cover

														if download_mode_covers == true then
										            		file.icon_path=artwork_file_dest_path
													        file.cover = true
													    end
								            		
								            		-- Check if in recently played

									            		-- Find game table key
														function find_game_table_pos_key(tbl, search)
														    for key, data in pairs(tbl) do
														       if data.filename == (search) then 
														          return key
														       end
														    end
														end

										            	-- Update recently played cover if found
										            	if download_mode_covers == true then
												            if #recently_played_table ~= nil then
												                key = find_game_table_pos_key(recently_played_table, file.filename)
												                if key ~= nil then
												                    recently_played_table[key].icon_path=artwork_file_dest_path
												                    recently_played_table[key].cover = true

												                    -- Print recently played table
												                    function update_cached_table_recently_played()
																	    dofile("addons/printTable_onelua.lua")
																	    print_table_recently_played()
																	end
																	update_cached_table_recently_played()

												                else
												                end
												            else
												            end
												        else
												        end
										        else
										        end

								            end
								            -- Delete image if not in artwork folder
								            if files.exists(artwork_file_tmp) then
								            	files.delete(artwork_file_tmp)
								            end
								        end

					    				-- Draw artwork
						    			if files.exists (artwork_file_dest_path) then
						    				draw_downloaded_artwork(artwork_file_dest_path)
										end

					    			-- Print result

					    			crc_progress_bar_update()
							    	-- screen.print(10,10,tostring(file.filename))
							    	screen.print(10,10,tostring(file.title))
							    	screen.print(10,35,tostring(crcs_checked) .. lang_lines.of .. tostring(missing_artwork_total))
									-- if crc_checked_before == true then
									-- 	screen.print(10,60,tostring("CRC: " .. file.crc_result))
									-- 	screen.print(10,85,tostring("Cached CRC - No match"))
									-- else
									-- 	screen.print(10,60,tostring("CRC: " .. file.crc_result))
									-- 	screen.print(10,85,tostring("New CRC - No match"))
										
									-- end

									screen.flip()

									-- Unload image
									artwork_img = nil
									collectgarbage("collect")
									barblit=false

									-- Prevent vita from suspending - the screen can dim and turn off
									power.tick(__POWER_TICK_SUSPEND)



						    	else

					    			-- Match found, download artwork

					    				local artwork_found = false

						    			local artwork_file_url = tostring(file[download_mode_path_online()] .. urlencode(crc_db_table[file.crc_result].name) .. ".png")
						    			local artwork_file_tmp = tostring("ux0:/data/RetroFlow/" .. file.name .. ".png")
						    			local artwork_file_dest_dir = tostring(file[download_mode_path_local()])
						    			local artwork_file_dest_path = tostring(file[download_mode_path_local()] .. file.name .. ".png")

						    			http.download(artwork_file_url, artwork_file_tmp)

						    			-- Check filesize of download, if large enough, move to artwork dir, if not then delete
						    			if files.exists(artwork_file_tmp) then

						    				size = files.size(artwork_file_tmp)
								            if size < 1024 then
								            	files.delete(artwork_file_tmp)
								            else
								            	-- artwork sucessfully downloaded
								            	artwork_found = true
								            	update_cache_needed = true
								            	files.move(artwork_file_tmp, artwork_file_dest_dir)
								            	artwork_found_count = artwork_found_count + 1

								            	-- If artwork not found, try using filename instead
								            	if artwork_found == false then
									            	local artwork_file_url = tostring(file[download_mode_path_online()] .. urlencode(file.name) .. ".png")
									    			local artwork_file_tmp = tostring("ux0:/data/RetroFlow/" .. file.name .. ".png")
									    			local artwork_file_dest_dir = tostring(file[download_mode_path_local()])
									    			local artwork_file_dest_path = tostring(file[download_mode_path_local()] .. file.name .. ".png")

									    			http.download(artwork_file_url, artwork_file_tmp)

									    			if files.exists(artwork_file_tmp) then

									    				size = files.size(artwork_file_tmp)
											            if size < 1024 then
											            	files.delete(artwork_file_tmp)
											            else
											            	-- artwork sucessfully downloaded
											            	artwork_found = true
											            	update_cache_needed = true
											            	files.move(artwork_file_tmp, artwork_file_dest_dir)
											            	artwork_found_count = artwork_found_count + 1
											            end

									    			end

									    		end

								            	if artwork_found == true then
								            		
								            		-- Update table with cover

														if download_mode_covers == true then
										            		file.icon_path=artwork_file_dest_path
													        file.cover = true
													    end

													-- Check if in recently played

									            		-- Find game table key
														function find_game_table_pos_key(tbl, search)
														    for key, data in pairs(tbl) do
														       if data.filename == (search) then 
														          return key
														       end
														    end
														end

										            	-- Update recently played cover if found
										            	if download_mode_covers == true then
												            if #recently_played_table ~= nil then
												                key = find_game_table_pos_key(recently_played_table, file.filename)
												                if key ~= nil then
												                    recently_played_table[key].icon_path=artwork_file_dest_path
												                    recently_played_table[key].cover = true

												                    -- Print recently played table
												                    function update_cached_table_recently_played()
																	    dofile("addons/printTable_onelua.lua")
																	    print_table_recently_played()
																	end
																	update_cached_table_recently_played()

												                else
												                end
												            else
												            end
												        else
												        end

										        else
										        end

								            end
								            -- Delete image if not in artwork folder
								            if files.exists(artwork_file_tmp) then
								            	files.delete(artwork_file_tmp)
								            end
								        end


					    				-- Draw artwork
						    			if files.exists (artwork_file_dest_path) then
						    				draw_downloaded_artwork(artwork_file_dest_path)
										end

					    			-- Print result

					    			crc_progress_bar_update()
							    	-- screen.print(10,10,tostring(file.filename))
							    	screen.print(10,10,tostring(file.title))
							    	screen.print(10,35,tostring(crcs_checked) .. lang_lines.of .. tostring(missing_artwork_total))
							    	-- if crc_checked_before == true then
							    	-- 	screen.print(10,60,tostring("CRC: " .. file.crc_result))
									-- 	screen.print(10,85,tostring("Cached CRC - Match"))
									-- else
									-- 	screen.print(10,60,tostring("CRC: " .. file.crc_result))
									-- 	screen.print(10,85,tostring("New CRC - Match"))
									-- end

									screen.flip()

									-- Unload image
									artwork_img = nil
									collectgarbage("collect")
									barblit=false

									-- Prevent vita from suspending - the screen can dim and turn off
									power.tick(__POWER_TICK_SUSPEND)
						    		
						    	end

						    	-- Add to table for saving to user crc file

						    	if crc_checked_before == false and not string.match(file.filename, "%.7z") then

						    		local crc_info = {}

							    	crc_info.filename = file.filename
		                            crc_info.app_type = file.app_type
		                            crc_info.crc = file.crc_result
		                            crc_info.name = file.name

		                            local crc_db_match = crc_db_table[file.crc_result]
							    	if crc_db_match == nil then
							    		crc_info.crc_name = ""
							    	else
							    		crc_info.crc_name = crc_db_table[file.crc_result].name
							    	end
		                            
		                            table.insert(crc_results_table, crc_info)
		                        else

		                        end

	                    	end
					    	
					    end

						-- Empty table
						crc_db_table = {}

						-- Move into next system
						if current_crc_apptype < syscount then
							if update_cache_needed == true then
								-- game.open("VITASHELL")
								update_cached_table(xAppDbFileLookup(current_crc_apptype), xAppNumTableLookup(current_crc_apptype))
							end
							current_crc_apptype = current_crc_apptype + 1
						end


					else

						-- Not a CRC lookup

						-- Try to download artwork without CRC
					    for i, file in pairs(xAppNumTableLookup(current_crc_apptype)) do

					    	-- Check if missing artwork

							
							if download_mode_covers == true then
								if current_crc_apptype == 1 then
									if file.cover == false or string.match(file.icon_path, "%icon0.png") then
										has_artwork = false
									else
										has_artwork = true
									end
								else		
									has_artwork = file.cover
								end
							else
								has_artwork = file.snap
							end

					    	
							if has_artwork == false then
					    		
					    		local artwork_found = false

						    	-- Amiga use title for search
						    	if current_crc_apptype == 21 then
						    		artwork_file_url = tostring(file[download_mode_path_online()] .. urlencode(file.name_title_search) .. ".png")
						    		romname_noExtension = file.filename:match("(.+)%..+$")
						    		artwork_file_tmp = tostring("ux0:/data/RetroFlow/" .. romname_noExtension .. ".png")
					    			artwork_file_dest_dir = tostring(file[download_mode_path_local()])
					    			artwork_file_dest_path = tostring(file[download_mode_path_local()] .. romname_noExtension .. ".png")
					    			http.download(artwork_file_url, artwork_file_tmp)
						    	else
						    		artwork_file_url = tostring(file[download_mode_path_online()] .. urlencode(file.name) .. ".png")
						    		artwork_file_tmp = tostring("ux0:/data/RetroFlow/" .. file.name .. ".png")
					    			artwork_file_dest_dir = tostring(file[download_mode_path_local()])
					    			artwork_file_dest_path = tostring(file[download_mode_path_local()] .. file.name .. ".png")
					    			http.download(artwork_file_url, artwork_file_tmp)
						    	end


				    			-- Check filesize of download, if large enough, move to artwork dir, if not then delete
				    			if files.exists(artwork_file_tmp) then

				    				size = files.size(artwork_file_tmp)
						            if size < 1024 then
						            	files.delete(artwork_file_tmp)
						            else
						            	-- artwork sucessfully downloaded
								        artwork_found = true
								        update_cache_needed = true
						            	files.move(artwork_file_tmp, artwork_file_dest_dir)
						            	artwork_found_count = artwork_found_count + 1

						            	if artwork_found == true then

						            		-- Update table with cover

												if download_mode_covers == true then
								            		file.icon_path=artwork_file_dest_path
											        file.cover = true
											    end

											-- Check if in recently played

							            		-- Find game table key
												function find_game_table_pos_key(tbl, search)
												    for key, data in pairs(tbl) do
												       if data.filename == (search) then 
												          return key
												       end
												    end
												end

												-- Update recently played cover if found
												if download_mode_covers == true then
										            if #recently_played_table ~= nil then
										                key = find_game_table_pos_key(recently_played_table, file.filename)
										                if key ~= nil then
										                    recently_played_table[key].icon_path=artwork_file_dest_path
										                    recently_played_table[key].cover = true

										                    -- Print recently played table
										                    function update_cached_table_recently_played()
															    dofile("addons/printTable_onelua.lua")
															    print_table_recently_played()
															end
															update_cached_table_recently_played()

										                else
										                end
										            else
										            end
										        else
										        end

									    else
									    end

						            end
						            -- Delete image if not in covers folder
						            if files.exists(artwork_file_tmp) then
						            	files.delete(artwork_file_tmp)
						            end
						        end


						        -- Draw artwork
				    			if files.exists (artwork_file_dest_path) then
				    				draw_downloaded_artwork(artwork_file_dest_path)
								end

			    				-- Print result

				    			crc_progress_bar_update()
						    	-- screen.print(10,10,tostring(file.name))
						    	screen.print(10,10,tostring(file.title))
						    	screen.print(10,35,tostring(crcs_checked) .. lang_lines.of .. tostring(missing_artwork_total))
						    	-- screen.print(10,60,tostring("CRC unavailable"))
								
								screen.flip()

								-- Unload image
								artwork_img = nil
								collectgarbage("collect")
								barblit=false

								-- Prevent vita from suspending - the screen can dim and turn off
								power.tick(__POWER_TICK_SUSPEND)

						    end
		    				
					    	
					    end

						-- Move into next system
						if current_crc_apptype < syscount then
							if update_cache_needed == true then
								-- game.open("VITASHELL")
								update_cached_table(xAppDbFileLookup(current_crc_apptype), xAppNumTableLookup(current_crc_apptype))
							end
							current_crc_apptype = current_crc_apptype + 1
						end

					end

				else
					current_crc_apptype = current_crc_apptype + 1
				end

			end


            -- Print CRC results to table
            if #crc_results_table > 0 then
            	table.sort(crc_results_table, function(a, b) return (a.filename:lower() < b.filename:lower()) end)
				local user_crc_lua_path = tostring(titles_dir .. user_crc_lua)

				file = io.open(user_crc_lua_path, "w+")
				file:write("return" .. "\n" .. "{" .. "\n")
			    for k, v in pairs(crc_results_table) do
					file:write('\t["' .. v.filename .. '"] =\n\t{\n\t\t["crc"] = "' .. v.crc .. '",\n\t\t["crc_name"] = "' .. v.crc_name .. '",\n\t\t["app_type"] = ' .. v.app_type .. ',\n\t},' .. "\n")
					-- file:write('\t["' .. v.filename .. '"] =\n\t{\n\t\t["name"] = "' .. v.name .. '",\n\t\t["crc_name"] = "' .. v.crc_name .. '",\n\t\t["crc"] = "' .. v.crc .. '",\n\t\t["app_type"] = ' .. v.app_type .. ',\n\t},' .. "\n")

			    end
			    file:write('}')
			    file:close()
			else
			end

			-- Turn on the vita display once the scan is complete
			power.display(1)

			-- Launch the main app
			os.execute("app0:eboot.bin")
			dofile("app0:index.lua")


		else
			-- There aren't any missing covers - Launch the main app

			screen.print(10,10,tostring(lang_lines.No_missing_artwork))
			screen.flip()

			os.delay(2000)

			os.execute("app0:eboot.bin")
			dofile("app0:index.lua")
		end

	else
		-- Do nothing
	end
