-- RetroFlow Recovery Tools

-- SPEED SETTINGS

	local cpu_speed = 444 -- Was 333
	System.setBusSpeed(222)
	System.setGpuSpeed(222)
	System.setGpuXbarSpeed(166)
	System.setCpuSpeed(cpu_speed)

-- FOLDERS

	local working_dir = "ux0:/app"

	function System.currentDirectory(dir)
	    if dir == nil then
	        return working_dir
	    else
	        working_dir = dir
	    end
	end

	local folder_retroflow_root = "ux0:/data/RetroFlow"
	local folder_retroflow = folder_retroflow_root .. "/"
	local folder_cache = folder_retroflow .. "CACHE/"
	local folder_databases = folder_retroflow .. "DATABASES/"
	local folder_titles = folder_retroflow .. "TITLES/"
	local file_config = folder_retroflow .. "config.dat"

-- APP INFO

	local app_version = ""
	local sfo_ok, info = pcall(System.extractSfo, "app0:/sce_sys/param.sfo")
	if sfo_ok and info and info.version then
		app_version = info.version
	end

-- DATE AND TIME

	function gettimestamp()
		-- Time
		local h, m, s = System.getTime()

		-- Date
		local day_num, d, month, y = System.getDate()

		-- Format string
		local timestamp = y .. "_" .. string.format("%02d", month) .. "_" .. string.format("%02d", d) .. "_" .. string.format("%02d", h) .. string.format("%02d", m) .. string.format("%02d", s)

		return timestamp
	end

-- UI

	-- Layout
		local menuX = 0
		local menuY = 0
		local menuItems = 3

		setting_x = 24
		setting_x_offset = 400
	    setting_yh = 18 -- Header
	    setting_y0 = 60
	    setting_y1 = 112
	    setting_y2 = 159
	    setting_y3 = 206
	    setting_y4 = 253
	    setting_y5 = 300
	    setting_y6 = 347
	    setting_y7 = 394
	    setting_y8 = 441
	    setting_y_smallfont_offset = 2
	    btnMargin = 32
	    menu_down_offset = 8
	    screen_down_offset = 10
	    footer_y = 500

	    function PrintCentered(font, x, y, text, color, size)
		    text = tostring(text or ""):gsub("\n","")
		    local width = Font.getTextWidth(font,text)
		    Font.print(font, x - width / 2, y, text, color)
		end

		function wraptextlength(s, x, indent)
		    x = x or 79
		    indent = indent or ""
		    local t = {""}
		    local function cleanse(s) return s:gsub("@x%d%d%d",""):gsub("@r","") end

		    for prefix, word, suffix, newline in tostring(s or ""):gmatch("([ \t]*)(%S*)([ \t]*)(\n?)") do
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

		function PrintWrapped(font, x, y, text, color)
			local wrapped_text = wraptextlength(text, 72)
			for line in wrapped_text:gmatch("([^\n]*)\n?") do
				if line ~= "" then
					Font.print(font, x, y, line, color)
				end
				y = y + 27
			end
		end

		function CountWrappedLines(text)
			local wrapped_text = wraptextlength(text, 72)
			local line_count = 0

			for line in wrapped_text:gmatch("([^\n]*)\n?") do
				if line ~= "" then
					line_count = line_count + 1
				end
			end

			if line_count < 1 then
				line_count = 1
			end

			return line_count
		end

	-- Defaults
		local showMenu = 0
		local oldpad = 0
		local delayButton = 0
		local dpadHeldUp = 0
		local dpadHeldDown = 0
		local result_title = ""
		local result_info = ""
		local reset_backup_path = ""

	-- Colors

		local white = Color.new(255, 255, 255)
		local black = Color.new(0, 0, 0)
		local grey = Color.new(58, 58, 58)
		local black = Color.new(0, 0, 0)
        -- local dark_grey = Color.new(22, 22, 22)
		local white_opaque = Color.new(255, 255, 255, 175)
		themeCol = grey

-- IMAGES

	local btnX = Graphics.loadImage("app0:/DATA/x.png")
	local btnO = Graphics.loadImage("app0:/DATA/o.png")

-- FONTS

	local font_default = "font-SawarabiGothic-Regular.woff"
	local font_korean = "font-NotoSansCJKkr-Regular-Slim.otf"
	local font_chinese_simplified = "font-NotoSansCJKsc-Regular-Slim.otf"
	local font_chinese_traditional = "font-NotoSansCJKtc-Regular.otf"
	local fontname = ""
	local font_buffer = nil
	local fnt20 = nil
	local fnt22 = nil
	local fnt25 = nil

	function ChangeFont(new_font)
	    if fontname ~= new_font then 

	        -- Load Standard font
	        fontname = new_font
	        font_buffer = Extended.loadFontIntoMemory("app0:/DATA/" .. fontname)

	        fnt20 = Extended.loadFontFromMemory(font_buffer)
	        fnt22 = Extended.loadFontFromMemory(font_buffer)
	        fnt25 = Extended.loadFontFromMemory(font_buffer)

	        Font.setPixelSizes(fnt20, 20)
	        Font.setPixelSizes(fnt22, 22)
	        Font.setPixelSizes(fnt25, 25)

	    end
	end

-- LANGUAGE

	local setLanguage = 0
	local lang_lines = {}

	local lang_default = {

		-- Footer
		["Close"] = "Close",
		["Select"] = "Select",
		["Back"] = "Back",
		["Confirm"] = "Confirm",
		["Cancel"] = "Cancel",

		-- Main screen
		["Recovery_Tools"] = "Recovery Tools",
		["Recovery_Tools_Info"] = "Use these tools if RetroFlow no longer starts correctly.",
		["Exit"] = "Exit",

		-- Delete Cache
		["Delete_Cache"] = "Delete Cache",
		["Info_Delete_Cache"] = "Delete cached titles, databases and generated cache files. They will be rebuilt automatically.",
		["Confirm_Delete_Cache"] = "All cache files will be deleted.",
		["Success_Delete_Cache"] = "Cache deleted successfully.",
		["Failed_Delete_Cache"] = "Unable to delete cache.",

		-- Reset Config
		["Reset_Config"] = "Reset Configuration",
		["Info_Config"] = "Delete RetroFlow settings and return to default settings on next launch.",
		["Confirm_Config"] = "RetroFlow settings will be reset.",
		["Success_Config"] = "Configuration reset successfully.",
		["Failed_Config"] = "Unable to reset configuration.",

		-- Full Reset
		["Full_Reset"] = "Full Reset",
		["Info_Full_Reset"] = "Reset RetroFlow to its default state.",
		["Confirm_Full_Reset"] = "Your current data will be backed up. Your ROMs and images will not be deleted.",
		["Success_Full_Reset"] = "Your previous RetroFlow data has been saved here:",
		["Failed_Full_Reset"] = "Unable to create backup folder.",
		["No_Data_Folder"] = "RetroFlow data folder was not found.",

	}

	-- Get Vita's system language
	local system_lang = System.getLanguage()

	if      system_lang == 0  then setLanguage = 9  -- Japanese
    elseif  system_lang == 1  then setLanguage = 1  -- English (United States)
    elseif  system_lang == 2  then setLanguage = 3  -- French
    elseif  system_lang == 3  then setLanguage = 5  -- Spanish
    elseif  system_lang == 4  then setLanguage = 2  -- German
    elseif  system_lang == 5  then setLanguage = 4  -- Italian
    elseif  system_lang == 6  then setLanguage = 12 -- Dutch
    elseif  system_lang == 7  then setLanguage = 6  -- Portuguese (Portugal)
    elseif  system_lang == 8  then setLanguage = 8  -- Russian
    elseif  system_lang == 9  then setLanguage = 17 -- Korean
    elseif  system_lang == 10 then setLanguage = 10 -- Chinese (Traditional)
    elseif  system_lang == 11 then setLanguage = 18 -- Chinese (Simplified)
    elseif  system_lang == 12 then setLanguage = 15 -- Finnish
    elseif  system_lang == 13 then setLanguage = 7  -- Swedish
    elseif  system_lang == 14 then setLanguage = 13 -- Danish
    elseif  system_lang == 15 then setLanguage = 14 -- Norwegian
    elseif  system_lang == 16 then setLanguage = 11 -- Polski
    elseif  system_lang == 17 then setLanguage = 21 -- Portuguese (Brasil)
    elseif  system_lang == 18 then setLanguage = 0  -- English (United Kingdom)
    elseif  system_lang == 19 then setLanguage = 16 -- Turkish
    elseif  system_lang == 20 then setLanguage = 5  -- Spanish (Latin America)
    else setLanguage = 0
    end

	function ChangeLanguage(def)

	    setLanguage = def
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

	    -- Import lang file from app0 only. Fill missing recovery strings from English.
	    if System.doesFileExist("app0:/translations/" .. lang) then
	        langfile = "app0:/translations/" .. lang
	        lang_lines = dofile(langfile)
	        if lang_lines == nil then
	        	lang_lines = lang_default
	        end
	    else
	        lang_lines = lang_default
	    end

	    for k, v in pairs(lang_default) do
	    	if lang_lines[k] == nil then
	    		lang_lines[k] = v
	    	end
	    end

	end

	ChangeLanguage(setLanguage)

-- CONTROLS

	SCE_CTRL_CROSS_MAP = SCE_CTRL_CROSS
	SCE_CTRL_CIRCLE_MAP = SCE_CTRL_CIRCLE

	function Pressed(def_button)
		return Controls.check(pad, def_button) and not Controls.check(oldpad, def_button)
	end

-- DRAWING

	function DrawHeader(def_header)
		Font.print(fnt22, setting_x, setting_yh, def_header, white)
		Graphics.fillRect(0, 960, 52 + screen_down_offset, 55 + screen_down_offset, white)

		if app_version ~= "" then
			local app_version_string = "v" .. app_version
			local app_version_width = Font.getTextWidth(fnt22, app_version_string)
			Font.print(fnt22, 960 - setting_x - app_version_width, setting_yh, app_version_string, white_opaque)
		end
	end

	function DrawFooter(def_select, def_back)
		local label1 = Font.getTextWidth(fnt22, def_back)

        Graphics.drawImage(900-label1, footer_y, btnO)
        Font.print(fnt20, 900+28-label1, footer_y - 2, def_back, white)

        if def_select ~= nil and def_select ~= "" then
			local label2 = Font.getTextWidth(fnt22, def_select)
	        Graphics.drawImage(900-(btnMargin * 2)-label1-label2, footer_y, btnX)
	        Font.print(fnt20, 900+28-(btnMargin * 2)-label1-label2, footer_y - 2, def_select, white)
	    end
	end

	function DrawMenuItem(def_y, def_text, def_selected)
		def_y = def_y + screen_down_offset
		if def_selected then
			Graphics.fillRect(0, 960, def_y - 10, def_y + 35, themeCol)
		end
		Font.print(fnt22, setting_x, def_y, def_text, white)
	end

	function DrawResult()
		DrawHeader(result_title)
		PrintWrapped(fnt22, setting_x, setting_y0 + menu_down_offset + screen_down_offset, result_info, white)
		DrawFooter(nil, lang_lines.Back)
	end

-- FILE FUNCTIONS

	function DeleteFileAndCheck(def_file)
		if not System.doesFileExist(def_file) then
			return true
		end

		System.deleteFile(def_file)

		if System.doesFileExist(def_file) then
			return false
		else
			return true
		end
	end

	function DeleteFolderAndCheck(def_folder)
		if not System.doesDirExist(def_folder) then
			return true
		end

		if System.deleteDirectory then
			System.deleteDirectory(def_folder)
		end

		if System.doesDirExist(def_folder) then
			return false
		else
			return true
		end
	end

	function ClearFolderFiles(def_folder)
		if not System.doesDirExist(def_folder) then
			System.createDirectory(def_folder)
			return true
		end

		local success = true
		local folder_files = System.listDirectory(def_folder) or {}

		for i, file in pairs(folder_files) do
			local file_path = def_folder .. file.name

			if file.directory then
				-- Clear and delete subfolders, but keep the main cache folders.
				if not ClearFolderFiles(file_path .. "/") then
					success = false
				end
				if not DeleteFolderAndCheck(file_path) then
					success = false
				end
			else
				if not DeleteFileAndCheck(file_path) then
					success = false
				end
			end
		end

		System.createDirectory(def_folder)
		return success
	end

	function DeleteCache()
		local success = true

		if not ClearFolderFiles(folder_cache) then success = false end
		if not ClearFolderFiles(folder_databases) then success = false end
		if not ClearFolderFiles(folder_titles) then success = false end

		if success then
			result_title = lang_lines.Delete_Cache
			result_info = lang_lines.Success_Delete_Cache
		else
			result_title = lang_lines.Delete_Cache
			result_info = lang_lines.Failed_Delete_Cache
		end

		showMenu = 4
	end

	function ResetConfiguration()
		local success = DeleteFileAndCheck(file_config)

		result_title = lang_lines.Reset_Config
		if success then
			result_info = lang_lines.Success_Config
		else
			result_info = lang_lines.Failed_Config
		end

		showMenu = 4
	end

	function FullReset()
		result_title = lang_lines.Full_Reset

		if not System.doesDirExist(folder_retroflow_root) then
			result_info = lang_lines.No_Data_Folder
			showMenu = 4
			return
		end

		reset_backup_path = "ux0:/data/RetroFlow_backup_" .. gettimestamp()
		local backup_count = 0

		while System.doesDirExist(reset_backup_path) do
			backup_count = backup_count + 1
			reset_backup_path = "ux0:/data/RetroFlow_backup_" .. gettimestamp() .. "_" .. backup_count
		end

		System.rename(folder_retroflow_root, reset_backup_path)

		if System.doesDirExist(reset_backup_path) and not System.doesDirExist(folder_retroflow_root) then
			result_info = lang_lines.Success_Full_Reset .. "\n" .. reset_backup_path .. "/"
		else
			result_info = lang_lines.Failed_Full_Reset
		end

		showMenu = 4
	end

	function FreeMemory()
		if btnX then Graphics.freeImage(btnX) end
		if btnO then Graphics.freeImage(btnO) end
		btnX = nil
		btnO = nil
		font_buffer = nil
		fnt20 = nil
		fnt22 = nil
		fnt25 = nil
		collectgarbage("collect")
	end

-- Main loop
while true do


	-- Reading input
    pad = Controls.read()
    mx, my = Controls.readLeftAnalog()

    -- Initializing rendering
    Graphics.initBlend()
    Screen.clear(black)
    Graphics.fillRect(0, 960, 0, 544, black)

-- MENU 0 - INTRO SCREEN
    if showMenu == 0 then
    
	    
    	-- MENU DRAWING

	        DrawHeader(lang_lines.Recovery_Tools)
	        PrintWrapped(fnt22, setting_x, setting_y0 + menu_down_offset + screen_down_offset, lang_lines.Recovery_Tools_Info, white_opaque)

	        local info_line_count = CountWrappedLines(lang_lines.Recovery_Tools_Info)
	        local menu_text_offset = (info_line_count - 1) * 27

	        DrawMenuItem(setting_y1 + menu_down_offset + menu_text_offset, lang_lines.Delete_Cache, menuY == 0)
	        DrawMenuItem(setting_y2 + menu_down_offset + menu_text_offset, lang_lines.Reset_Config, menuY == 1)
	        DrawMenuItem(setting_y3 + menu_down_offset + menu_text_offset, lang_lines.Full_Reset, menuY == 2)
	        DrawMenuItem(setting_y4 + menu_down_offset + menu_text_offset, lang_lines.Exit, menuY == 3)

	        DrawFooter(lang_lines.Select, lang_lines.Close)

        -- MENU FUNCTIONS
	        
	        if Pressed(SCE_CTRL_CROSS_MAP) then

                if menuY == 0 then -- Delete cache
                    showMenu = 1
                elseif menuY == 1 then -- Reset Configuration
                    showMenu = 2
                elseif menuY == 2 then -- Full Reset
                    showMenu = 3
                elseif menuY == 3 then -- Exit
                	FreeMemory()
                    System.exit()
                end

	        elseif Pressed(SCE_CTRL_CIRCLE_MAP) then
	        	FreeMemory()
                System.exit()
	        end


	elseif showMenu == 1 then -- Delete cache

  		-- MENU DRAWING

  			DrawHeader(lang_lines.Delete_Cache)
  			PrintWrapped(fnt22, setting_x, setting_y0 + menu_down_offset + screen_down_offset, lang_lines.Info_Delete_Cache .. "\n\n" .. lang_lines.Confirm_Delete_Cache, white)
  			DrawFooter(lang_lines.Confirm, lang_lines.Cancel)

  		-- MENU FUNCTIONS
	            
            if Pressed(SCE_CTRL_CROSS_MAP) then
                DeleteCache()

            elseif Pressed(SCE_CTRL_CIRCLE_MAP) then
                showMenu = 0
                menuY = 0
            end

  	elseif showMenu == 2 then -- Reset Configuration

  		-- MENU DRAWING

  			DrawHeader(lang_lines.Reset_Config)
  			PrintWrapped(fnt22, setting_x, setting_y0 + menu_down_offset + screen_down_offset, lang_lines.Info_Config .. "\n\n" .. lang_lines.Confirm_Config, white)
  			DrawFooter(lang_lines.Confirm, lang_lines.Cancel)

  		-- MENU FUNCTIONS
	            
            if Pressed(SCE_CTRL_CROSS_MAP) then
                ResetConfiguration()

            elseif Pressed(SCE_CTRL_CIRCLE_MAP) then
                showMenu = 0
                menuY = 1
            end

  	elseif showMenu == 3 then -- Full Reset

  		-- MENU DRAWING

  			DrawHeader(lang_lines.Full_Reset)
  			PrintWrapped(fnt22, setting_x, setting_y0 + menu_down_offset + screen_down_offset, lang_lines.Info_Full_Reset .. "\n\n" .. lang_lines.Confirm_Full_Reset, white)
  			DrawFooter(lang_lines.Confirm, lang_lines.Cancel)

  		-- MENU FUNCTIONS
	            
            if Pressed(SCE_CTRL_CROSS_MAP) then
                FullReset()

            elseif Pressed(SCE_CTRL_CIRCLE_MAP) then
                showMenu = 0
                menuY = 2
            end

  	elseif showMenu == 4 then -- Result

  		-- MENU DRAWING

  			DrawResult()

  		-- MENU FUNCTIONS
	            
            if Pressed(SCE_CTRL_CROSS_MAP) or Pressed(SCE_CTRL_CIRCLE_MAP) then
                showMenu = 0
            end

  	-- END OF MENUS
  	end


  	-- Terminating rendering phase
    Graphics.termBlend()


    -- Scroll through main menu only
    if showMenu == 0 then
        if delayButton > 0 then
            delayButton = delayButton - 0.1
            if delayButton < 0 then
                delayButton = 0
            end
        end

        if my < 64 then
            if delayButton < 0.5 then
                delayButton = 1
                if menuY > 0 then
                    menuY = menuY - 1
                else
                    menuY = menuItems
                end
            end
        elseif my > 180 then
            if delayButton < 0.5 then
                delayButton = 1
                if menuY < menuItems then
                    menuY = menuY + 1
                else
                    menuY = 0
                end
            end
        end


	    -- D-pad menu scrolling with continuous scrolling
	    if Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) then
	        if menuY > 0 then
	            menuY = menuY - 1
	        else
	            menuY = menuItems
	        end
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
	        if menuY < menuItems then
	            menuY = menuY + 1
	        else
	            menuY = 0
	        end
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
	    
	    -- Reset D-pad held counters when buttons are released
	    if not Controls.check(pad, SCE_CTRL_UP) then
	        dpadHeldUp = 0
	    end
	    if not Controls.check(pad, SCE_CTRL_DOWN) then
	        dpadHeldDown = 0
	    end
	end


    -- Refreshing screen and oldpad
    Screen.waitVblankStart()
    Screen.flip()
    oldpad = pad

end
