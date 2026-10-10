local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zwunio/euphoria/main/lib.lua"))()

local window = library:window({
	name = "euphoria",
	size = UDim2.new(0, 560, 0, 620),
})

local main = window:tab({ name = "main" })
local settings = window:tab({ name = "settings" })

local left = main:section({ name = "elements", side = "left" })
local right = main:section({ name = "more", side = "right" })

left:toggle({ name = "enabled", flag = "enabled", default = false })
left:slider({ name = "speed", flag = "speed", min = 0, max = 100, intervals = 1, default = 50, suffix = "%" })
left:dropdown({ name = "mode", flag = "mode", items = { "normal", "fast", "slow" }, default = "normal" })
left:colorpicker({ name = "accent color", flag = "accent_color", color = Color3.fromRGB(200, 200, 200), alpha = 1 })
left:button({
	name = "notify",
	callback = function()
		library:notification({ text = "hello from euphoria", time = 3 })
	end,
})

right:toggle({ name = "another toggle", flag = "another_toggle", default = true })
right:slider({ name = "fov", flag = "fov", min = 30, max = 120, intervals = 1, default = 70, suffix = "°" })
right:colorpicker({ name = "esp color", flag = "esp_color", color = Color3.fromRGB(255, 80, 80), alpha = 0.85 })

local configs = settings:section({ name = "configs", side = "left" })
local themes_sec = settings:section({ name = "theme", side = "right" })

configs:textbox({ flag = "config_name", placeholder = "config name", default = "default" })
local config_list = configs:dropdown({ name = "saved configs", flag = "selected_config", items = {} })
library.config_holder = config_list
library:config_list_update()

configs:button({
	name = "save config",
	callback = function()
		local name = library.flags["config_name"]
		if not name or name == "" then return end
		writefile(library.directory .. library.config_folder .. "/" .. name .. ".cfg", library:get_config())
		library:config_list_update()
	end,
})

configs:button({
	name = "load config",
	callback = function()
		local name = library.flags["selected_config"]
		if type(name) == "table" then name = name[1] end
		if not name then return end
		local path = library.directory .. library.config_folder .. "/" .. name .. ".cfg"
		if isfile(path) then library:load_config(readfile(path)) end
	end,
})

themes_sec:colorpicker({
	name = "accent",
	flag = "theme_accent",
	color = Color3.fromRGB(200, 200, 200),
	alpha = 1,
	callback = function(color)
		library:update_theme("accent", color)
	end,
})
