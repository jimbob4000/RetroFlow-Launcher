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
				cached_table_iso = dofile(titles_dir .. "/" .. sfo_scan_isos_lua)
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
			cached_table_iso = dofile(titles_dir .. "/" .. sfo_scan_isos_lua)
		else
			cached_table_iso = {}
		end

		if files.exists(titles_dir .. "/" .. sfo_scan_games_lua) then
			cached_table_games = dofile(titles_dir .. "/" .. sfo_scan_games_lua)
		else
			cached_table_games = {}
		end

		if files.exists(titles_dir .. "/" .. sfo_scan_retroarch_lua) then
			cached_table_retroarch = dofile(titles_dir .. "/" .. sfo_scan_retroarch_lua)
		else
			cached_table_retroarch = {}
		end


	-- Get RetroArch user defined PS1 directory to scan - Get from file, or use default if not found

		if files.exists("ux0:/data/RetroFlow/rom_directories.lua") then
		    -- File exists, import user rom dirs
		    db_romdir = "ux0:/data/RetroFlow/rom_directories.lua"
		    romUserDir = {}
		    romUserDir = dofile(db_romdir)

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

	-- Pre scan folders to get percentage

		local loading_tasks = 0
		local sub_dir_count = 0

		function count_loading_tasks(dir)
			if files.exists((dir)) then
				local dir_count = {}
				local dir_count = files.list((dir))

				-- Scan sub folders for categories lite
				sub_dir_count = 0
				clite_dir_count = 0

				if #dir_count ~= nil then
					for i, file in pairs(dir_count) do

						-- Add categories lite folder contents to loading tasks
						if file.directory == true then
							sub_dir = files.list(file.path)
							for i, file in pairs(sub_dir) do
								if files.exists(file.path .. "/EBOOT.pbp") then
									sub_dir_count = sub_dir_count + 1
								end
								if file.ext == "iso" or file.ext == "cso" then
									sub_dir_count = sub_dir_count + 1
								end
							end
						end

						-- Minus categories lite folders from loading tasks
						if file.directory == true and not files.exists(file.path .. "/EBOOT.pbp") then
							clite_dir_count = clite_dir_count + 1
						end
						if file.directory == true and files.exists(file.path .. "/" .. "%.iso") then
							clite_dir_count = clite_dir_count + 1
						end
						if file.directory == true and files.exists(file.path .. "/" .. "%.cso") then
							clite_dir_count = clite_dir_count + 1
						end

					end
				end
				loading_tasks = loading_tasks + #dir_count + sub_dir_count - clite_dir_count
			end
		end

		function count_loading_tasks_game_dir(dir)
			if files.exists((dir)) then
				local dir_count = {}
				local dir_count = files.listdirs((dir))

				loading_tasks = loading_tasks + #dir_count
			end
		end

		count_loading_tasks("ux0:/pspemu/ISO")
		count_loading_tasks("ur0:/pspemu/ISO")
		count_loading_tasks("imc0:/pspemu/ISO")
		count_loading_tasks("xmc0:/pspemu/ISO")
		count_loading_tasks("uma0:/pspemu/ISO")
		count_loading_tasks_game_dir("ux0:/pspemu/PSP/GAME")
		count_loading_tasks_game_dir("ur0:/pspemu/PSP/GAME")
		count_loading_tasks_game_dir("imc0:/pspemu/PSP/GAME")
		count_loading_tasks_game_dir("xmc0:/pspemu/PSP/GAME")
		count_loading_tasks_game_dir("uma0:/pspemu/PSP/GAME")
		count_loading_tasks(tostring((romUserDir.PlayStation)))

		local loading_progress = 0

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
			file:write('["' .. v.filename .. '"] = {title = "' .. v.title .. '", titleid = "' .. v.titleid .. '", region = "' .. v.region .. '", path = "' .. v.path .. '"},' .. "\n")
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

		function scan_iso_folder(scan_dir)
			local rom_dir = (scan_dir)
			local dir = files.listfiles(rom_dir)
			
			if files.exists(rom_dir) then
				for i, file in pairs(dir) do

					if string.match(file.name, "%.iso") or string.match(file.name, "%.cso") then

						-- Check if game in cached file
						if cached_table_iso[file.name] ~= nil then
							-- Found
						else
							-- Not found, is a new game, scan SFO
							local sfo = {}
							sfo = game.info(file.path)

							-- Error handling for bad sfo files
							if sfo ~= nil then
								if sfo.TITLE and sfo.DISC_ID and sfo.REGION ~= nil then

									-- Cleanup game title
									sfo_title = cleanup_game_title(sfo.TITLE)
									
									file.filename = file.name
									file.title = sfo_title
									file.titleid = sfo.DISC_ID
									file.region = sfo.REGION
									file.path = file.path

									table.insert(table_iso, file)
								else
								end
							end

							update_loading_screen_progress()
						end

					else
					end

				end
			else
			end

			-- Scan sub folders for categories lite
			local rom_dir = (scan_dir)
			local sub_dir = files.listdirs(rom_dir)

			if sub_dir ~= nil then
				for i, subfolder in pairs(sub_dir) do
					subfolder_file = files.listfiles(subfolder.path)

					for i, file in pairs(subfolder_file) do
						if string.match(file.name, "%.iso") or string.match(file.name, "%.cso") then

							-- Check if game in cached file
							if cached_table_iso[file.name] ~= nil then
								-- Found
							else
								-- Not found, is a new game, scan SFO
								local sfo = {}
								sfo = game.info(file.path)

								-- Error handling for bad sfo files
								if sfo ~= nil then
									if sfo.TITLE and sfo.DISC_ID and sfo.REGION ~= nil then

										-- Cleanup game title
										sfo_title = cleanup_game_title(sfo.TITLE)
									
										file.filename = file.name
										file.title = sfo_title
										file.titleid = sfo.DISC_ID
										file.region = sfo.REGION
										file.path = file.path
										
										table.insert(table_iso, file)
									else
									end
								end

								update_loading_screen_progress()
							end

						else
						end
					end
				end
			else
			end

		end

	-- Scan Function - Game folders

		function scan_game_folder(scan_dir)
			local rom_dir = (scan_dir)
			local dir = files.listdirs(rom_dir)

			if files.exists(rom_dir) then
				for i, file in pairs(dir) do
					if files.exists(rom_dir .. "/" .. file.name .. "/EBOOT.pbp") then

						-- Check if game in cached file
						if cached_table_games[file.name] ~= nil then
							-- Found
						else
							-- Not found, is a new game, scan SFO
							local sfo = {}
							sfo = game.info(rom_dir .. "/" .. file.name .. "/EBOOT.pbp")

							if sfo ~= nil then
								-- Cleanup game title
								sfo_title = cleanup_game_title(sfo.TITLE)

								file.filename = file.name
								file.title = sfo_title
								file.titleid = sfo.DISC_ID
								file.region = sfo.REGION
								file.path = file.path .. "/EBOOT.pbp"

								if file.filename and file.title and file.titleid and file.region and file.path ~= nil then
									table.insert(table_games, file)
								else
								end
							end

							update_loading_screen_progress()

						end

					else
					end
				end
			else
			end

			-- Scan sub folders for categories lite
			local rom_dir = (scan_dir)
			local sub_dir = files.listdirs(rom_dir)

			if sub_dir ~= nil then
				for i, subfolder in pairs(sub_dir) do

					local subfolder_file = files.listdirs(subfolder.path)

					if subfolder_file ~= nil then
						for i, file in pairs(subfolder_file) do
							if files.exists(file.path .. "/EBOOT.pbp") then

								-- Check if game in cached file
								if cached_table_games[file.name] ~= nil then
									-- Found
								else
									-- Not found, is a new game, scan SFO
									local sfo = {}
									sfo = game.info(file.path .. "/EBOOT.pbp")

									if sfo ~= nil then
										-- Cleanup game title
										sfo_title = cleanup_game_title(sfo.TITLE)
										
										file.filename = file.name
										file.title = sfo_title
										file.titleid = sfo.DISC_ID
										file.region = sfo.REGION
										file.path = file.path .. "/EBOOT.pbp"

										if file.filename and file.title and file.titleid and file.region and file.path ~= nil then
											table.insert(table_games, file)
										else
										end
									end

									update_loading_screen_progress()

								end

							else
							end
						end
					else
					end
				end
			else
			end

		end

	-- Scan Function - Retroarch PS1 Game folders
		function scan_Rom_PS1_Eboot(scan_dir)
			local rom_dir = (scan_dir)

			if files.exists(rom_dir) then

				-- scan files
				local dir = files.listfiles(rom_dir)

				for i, file in pairs(dir) do

					if string.match(file.name, "%.pbp") or string.match(file.name, "%.PBP") or string.match(file.name, "%.iso") then

						-- Check if game in cached file
						if cached_table_retroarch[file.name] ~= nil then
							-- Found
						else
							-- Not found, is a new game, scan SFO
							local sfo = {}
							sfo = game.info(file.path)

							-- Error handling for bad sfo files
							if sfo ~= nil then
								if sfo.TITLE and sfo.DISC_ID and sfo.REGION ~= nil then

									-- Cleanup game title
									sfo_title = cleanup_game_title(sfo.TITLE)

									file.filename = file.name
									file.title = sfo_title
									file.titleid = sfo.DISC_ID
									file.region = sfo.REGION
									file.path = file.path
									table.insert(table_retroarch, file)
								else
								end
							end

							update_loading_screen_progress()
						end

					else
					end
				end

				-- scan folders
				local sub_dir = files.listdirs(rom_dir)

				for i, subfolder in pairs(sub_dir) do
					subfolder_file = files.listfiles(subfolder.path)

					for i, file in pairs(subfolder_file) do
						if string.match(file.name, "%.pbp") or string.match(file.name, "%.PBP") or string.match(file.name, "%.iso") then

							-- Check if game in cached file
							if cached_table_retroarch[subfolder.name] ~= nil then
								-- Found
							else
								-- Not found, is a new game, scan SFO
								local sfo = {}
								sfo = game.info(file.path)

								-- Error handling for bad sfo files
								if sfo ~= nil then
									if sfo.TITLE and sfo.DISC_ID and sfo.REGION ~= nil then

										-- Cleanup game title
										sfo_title = cleanup_game_title(sfo.TITLE)

										file.filename = subfolder.name
										file.title = sfo_title
										file.titleid = sfo.DISC_ID
										file.region = sfo.REGION
										file.path = file.path
										table.insert(table_retroarch, file)
									else
									end
								end

								update_loading_screen_progress()

							end

						else
						end
					end
				end

			else
			end
		end


	-- Scan Function - Scummvm

		function readAll(file)
		    local f = assert(io.open(file, "rb"))
		    local content = f:read("*all")
		    f:close()
		    return content
		end

		function scan_scummvm()
			if files.exists ("ux0:/data/scummvm/scummvm.ini") then
				scummvm_ini_contents = readAll("ux0:/data/scummvm/scummvm.ini")

				local function tovector(s)
					scummvm_ini_section = {}
					-- s:gsub("\n", " "):gsub("%[(%w*)%]", function(n) scummvm_ini_section[#scummvm_ini_section+1] = tostring(n) end)
					s:gsub("\n", " "):gsub("(%[.-%])", function(n) scummvm_ini_section[#scummvm_ini_section+1] = tostring(n:gsub("%[", ""):gsub("%]", "")) end)
					return scummvm_ini_section
			    end

				scummvm_ini_section = tovector(scummvm_ini_contents)
				
				for k, v in pairs (scummvm_ini_section) do
					file = {}
					file.gameid = ini.read("ux0:/data/scummvm/scummvm.ini",tostring(v),"gameid","exclude_game")
					file.description = ini.read("ux0:/data/scummvm/scummvm.ini",tostring(v),"description","exclude_game")
					file.path = ini.read("ux0:/data/scummvm/scummvm.ini",tostring(v),"path","exclude_game")
					if not string.match(file.gameid, "exclude_game") then
						table.insert(scummvm_info, file)
					end
				end

			end
		end

		function write_ini_scummvm(pathini, tbl)
		    file = io.open(pathini, "w+")
			file:write("return" .. "\n" .. "{" .. "\n")
		    for k, v in pairs((tbl)) do
				file:write('[' .. k .. '] = {gameid = "' .. v.gameid .. '", description = "' .. v.description .. '", path = "' .. v.path .. '"},' .. "\n")

		    end
		    file:write('}')
		    file:close()
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
		update_debug_message("Scanning: ux0:/pspemu/ISO")
		scan_iso_folder ("ux0:/pspemu/ISO")

		update_debug_message("Scanning: ur0:/pspemu/ISO")
		scan_iso_folder ("ur0:/pspemu/ISO")

		update_debug_message("Scanning: imc0:/pspemu/ISO")
		scan_iso_folder ("imc0:/pspemu/ISO")

		update_debug_message("Scanning: xmc0:/pspemu/ISO")
		scan_iso_folder ("xmc0:/pspemu/ISO")

		update_debug_message("Scanning: uma0:/pspemu/ISO")
		scan_iso_folder ("uma0:/pspemu/ISO")

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

		update_debug_message("Scanning: ux0:/pspemu/PSP/GAME")
		scan_game_folder ("ux0:/pspemu/PSP/GAME")

		update_debug_message("Scanning: ur0:/pspemu/PSP/GAME")
		scan_game_folder ("ur0:/pspemu/PSP/GAME")

		update_debug_message("Scanning: imc0:/pspemu/PSP/GAME")
		scan_game_folder ("imc0:/pspemu/PSP/GAME")

		update_debug_message("Scanning: xmc0:/pspemu/PSP/GAME")
		scan_game_folder ("xmc0:/pspemu/PSP/GAME")

		update_debug_message("Scanning: uma0:/pspemu/PSP/GAME")
		scan_game_folder ("uma0:/pspemu/PSP/GAME")

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
		scan_Rom_PS1_Eboot(romUserDir.PlayStation)
		
		update_debug_message("Creating table: retroarch")
		add_cached_games_to_table (cached_table_retroarch, table_retroarch)

		update_debug_message("Sorting table: retroarch")
		if #table_retroarch > 0 then
			table.sort(table_retroarch, function(a, b) return (a.title:lower() < b.title:lower()) end)
		end
		
		update_debug_message("Saving table: retroarch")
		write_ini(tostring(titles_dir .. sfo_scan_retroarch_lua), table_retroarch)

	-- Scan scummvm

		-- ScummVM scan working but disabled
		
		scummvm_info = {}

		update_debug_message("Scanning: ScummVM")
		scan_scummvm()

		update_debug_message("Sorting table: ScummVM")
		if #scummvm_info > 0 then
			table.sort(scummvm_info, function(a, b) return (a.description:lower() < b.description:lower()) end)
		end

		update_debug_message("Saving table: ScummVM")
		write_ini_scummvm(tostring(titles_dir .. "scan_scummvm.lua"), scummvm_info)

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

