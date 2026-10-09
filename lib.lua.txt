local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local ws = game:GetService("Workspace")
local http_service = game:GetService("HttpService")
local gui_service = game:GetService("GuiService")
local lighting = game:GetService("Lighting")
local run = game:GetService("RunService")
local stats = game:GetService("Stats")
local coregui = game:GetService("CoreGui")
local debris = game:GetService("Debris")
local tween_service = game:GetService("TweenService")
local rs = game:GetService("ReplicatedStorage")

local vec2 = Vector2.new
local vec3 = Vector3.new
local dim2 = UDim2.new
local dim = UDim.new
local rect = Rect.new
local cfr = CFrame.new

local color = Color3.new
local rgb = Color3.fromRGB
local hex = Color3.fromHex
local hsv = Color3.fromHSV
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new

local camera = ws.CurrentCamera
local lp = players.LocalPlayer
local mouse = lp:GetMouse()
local gui_offset = gui_service:GetGuiInset().Y

local max = math.max
local floor = math.floor
local min = math.min
local abs = math.abs

local CONFIG_FOLDER = "/cfgs"

if getgenv().library then
	getgenv().library:unload()
end

getgenv().library = {
	flags = {},
	config_flags = {},
	connections = {},
	notifications = {},
	instances = {},
	main_frame = {},
	config_holder,
	current_tab,
	first_tab_set = false,
	current_element_open,
	open_menus = {},
	open_keybind_menus = {},
	dock_button_holder,
	gui,
	sin = 0,
	keybind_path,
	panel_open = false,

	directory = "solvent",
	folders = {
		"/fonts",
		CONFIG_FOLDER,
	},
	font,
	config_folder = CONFIG_FOLDER,
}

local flags = library.flags
local config_flags = library.config_flags

local themes = {
	preset = {
		["outline"] = rgb(20, 22, 28),
		["inline"] = rgb(28, 32, 42),
		["accent"] = rgb(200, 200, 200),
		["contrast"] = rgb(35, 40, 52),
		["text"] = rgb(220, 220, 220),
		["unselected_text"] = rgb(120, 125, 135),
		["text_outline"] = rgb(0, 0, 0),
		["glow"] = rgb(200, 200, 200),
	},

	utility = {
		["outline"] = {
			["BackgroundColor3"] = {},
			["Color"] = {},
		},
		["inline"] = {
			["BackgroundColor3"] = {},
		},
		["accent"] = {
			["BackgroundColor3"] = {},
			["TextColor3"] = {},
			["ImageColor3"] = {},
			["BorderColor3"] = {},
			["ScrollBarImageColor3"] = {},
		},
		["contrast"] = {
			["Color"] = {},
		},
		["text"] = {
			["TextColor3"] = {},
		},
		["text_outline"] = {
			["Color"] = {},
		},
		["glow"] = {
			["ImageColor3"] = {},
		},
	},
}

local keys = {
	[Enum.KeyCode.LeftShift] = "LS",
	[Enum.KeyCode.RightShift] = "RS",
	[Enum.KeyCode.LeftControl] = "LC",
	[Enum.KeyCode.RightControl] = "RC",
	[Enum.KeyCode.Insert] = "INS",
	[Enum.KeyCode.Backspace] = "BS",
	[Enum.KeyCode.Return] = "Ent",
	[Enum.KeyCode.LeftAlt] = "LA",
	[Enum.KeyCode.RightAlt] = "RA",
	[Enum.KeyCode.CapsLock] = "CAPS",
	[Enum.KeyCode.One] = "1",
	[Enum.KeyCode.Two] = "2",
	[Enum.KeyCode.Three] = "3",
	[Enum.KeyCode.Four] = "4",
	[Enum.KeyCode.Five] = "5",
	[Enum.KeyCode.Six] = "6",
	[Enum.KeyCode.Seven] = "7",
	[Enum.KeyCode.Eight] = "8",
	[Enum.KeyCode.Nine] = "9",
	[Enum.KeyCode.Zero] = "0",
	[Enum.KeyCode.KeypadOne] = "Num1",
	[Enum.KeyCode.KeypadTwo] = "Num2",
	[Enum.KeyCode.KeypadThree] = "Num3",
	[Enum.KeyCode.KeypadFour] = "Num4",
	[Enum.KeyCode.KeypadFive] = "Num5",
	[Enum.KeyCode.KeypadSix] = "Num6",
	[Enum.KeyCode.KeypadSeven] = "Num7",
	[Enum.KeyCode.KeypadEight] = "Num8",
	[Enum.KeyCode.KeypadNine] = "Num9",
	[Enum.KeyCode.KeypadZero] = "Num0",
	[Enum.KeyCode.Minus] = "-",
	[Enum.KeyCode.Equals] = "=",
	[Enum.KeyCode.Tilde] = "~",
	[Enum.KeyCode.LeftBracket] = "[",
	[Enum.KeyCode.RightBracket] = "]",
	[Enum.KeyCode.RightParenthesis] = ")",
	[Enum.KeyCode.LeftParenthesis] = "(",
	[Enum.KeyCode.Semicolon] = ",",
	[Enum.KeyCode.Quote] = "'",
	[Enum.KeyCode.BackSlash] = "\\",
	[Enum.KeyCode.Comma] = ",",
	[Enum.KeyCode.Period] = ".",
	[Enum.KeyCode.Slash] = "/",
	[Enum.KeyCode.Asterisk] = "*",
	[Enum.KeyCode.Plus] = "+",
	[Enum.KeyCode.Period] = ".",
	[Enum.KeyCode.Backquote] = "`",
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",
	[Enum.KeyCode.Escape] = "ESC",
	[Enum.KeyCode.Space] = "SPC",
}

library.__index = library

for _, path in next, library.folders do
	makefolder(library.directory .. path)
end

if not isfile(library.directory .. "/fonts/main.ttf") then
	writefile(
		library.directory .. "/fonts/main.ttf",
		game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/fs-tahoma-8px.ttf")
	)
end

local tahoma = {
	name = "SmallestPixel7",
	faces = {
		{
			name = "Regular",
			weight = 400,
			style = "normal",
			assetId = getcustomasset(library.directory .. "/fonts/main.ttf"),
		},
	},
}

if not isfile(library.directory .. "/fonts/main_encoded.ttf") then
	writefile(library.directory .. "/fonts/main_encoded.ttf", http_service:JSONEncode(tahoma))
end

library.font = Font.new(getcustomasset(library.directory .. "/fonts/main_encoded.ttf"), Enum.FontWeight.Regular)

function library.to_screen_point(position)
	return camera:WorldToViewportPoint(position)
end

function library:unload()
	library.__unloaded = true
	library.gui:Destroy()

	for _, connection in library.connections do
		connection:Disconnect()
	end

	for _, item in library.instances do
		item:Destroy()
	end

	getgenv().library = nil
end

function library:convert_string_rgb(str)
	local values = {}

	for value in string.gmatch(str, "[^,]+") do
		table.insert(values, tonumber(value))
	end

	if #values == 4 then
		local r, g, b, a = values[1], values[2], values[3], values[4]

		return r, g, b, a
	else
		library:notification({ text = "Input a correct RGBA value (in the format 255, 255, 255, 0.5)" })
	end
end

function library:connection(signal, callback)
	local connection = signal:Connect(callback)

	table.insert(library.connections, connection)

	return connection
end

function library:make_resizable(frame)
	local Frame = Instance.new("TextButton")
	Frame.Position = dim2(1, -10, 1, -10)
	Frame.BorderColor3 = rgb(0, 0, 0)
	Frame.Size = dim2(0, 10, 0, 10)
	Frame.BorderSizePixel = 0
	Frame.BackgroundColor3 = rgb(255, 255, 255)
	Frame.Parent = frame
	Frame.BackgroundTransparency = 1
	Frame.Text = ""

	local resizing = false
	local start_size
	local start
	local og_size = frame.Size

	Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			start = input.Position
			start_size = frame.Size
		end
	end)

	Frame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = false
		end
	end)

	library:connection(uis.InputChanged, function(input, game_event)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mouse_pos = vec2(mouse.X, mouse.Y)
			local viewport_x = camera.ViewportSize.X
			local viewport_y = camera.ViewportSize.Y

			current_size = dim2(
				start_size.X.Scale,
				math.clamp(start_size.X.Offset + (input.Position.X - start.X), og_size.X.Offset, viewport_x),
				start_size.Y.Scale,
				math.clamp(start_size.Y.Offset + (input.Position.Y - start.Y), og_size.Y.Offset, viewport_y)
			)
			frame.Size = current_size
		end
	end)
end

function library:new_item(class, properties)
	local ins = Instance.new(class)

	for _, v in next, properties do
		ins[_] = v
	end

	table.insert(library.instances, ins)

	return ins
end

function library:animation(text)
	local pattern = {}
	for i = 1, tonumber(text:len()) do
		table.insert(pattern, string.sub(text, 1, i))
	end
	for i = tonumber(text:len()) - 1, 0, -1 do
		table.insert(pattern, string.sub(text, 1, i))
	end
	return pattern
end

function library:convert_enum(enum)
	local enum_parts = {}

	for part in string.gmatch(enum, "[%w_]+") do
		table.insert(enum_parts, part)
	end

	local enum_table = Enum
	for i = 2, #enum_parts do
		local enum_item = enum_table[enum_parts[i]]

		enum_table = enum_item
	end

	return enum_table
end

function library:config_list_update()
	if not library.config_holder then
		return
	end

	local list = {}

	for _, file in next, listfiles(library.directory .. library.config_folder) do
		local normalized = tostring(file):gsub("\\", "/")
		local name = normalized:match("([^/]+)%.cfg$")

		if name and name ~= "" then
			list[#list + 1] = name
		end
	end

	library.config_holder:refresh_options(list)
end

function library:get_config()
	local Config = {}

	for _, v in flags do
		if type(v) == "table" and v.key then
			Config[_] = { active = v.active, mode = v.mode, key = tostring(v.key) }
		elseif type(v) == "table" and v["Transparency"] and v["Color"] then
			Config[_] = { Transparency = v["Transparency"], Color = v["Color"]:ToHex() }
		else
			Config[_] = v
		end
	end

	return http_service:JSONEncode(Config)
end

function library:load_config(config_json)
	local config = http_service:JSONDecode(config_json)

	for _, v in next, config do
		local function_set = library.config_flags[_]

		-- always update the stored flags so logic that reads flags sees the loaded value
		if type(v) == "table" and v["Transparency"] and v["Color"] then
			flags[_] = { Transparency = v["Transparency"], Color = hex(v["Color"]) }
		else
			flags[_] = v
		end

		-- if a setter exists, invoke it to update UI/state; otherwise the flag value alone is enough
		if type(function_set) == "function" then
			pcall(function()
				if type(v) == "table" and v["Transparency"] and v["Color"] then
					function_set(hex(v["Color"]), v["Transparency"])
				else
					function_set(v)
				end
			end)
		end
	end
end

function library:round(number, float)
	local multiplier = 1 / (float or 1)
	return math.floor(number * multiplier + 0.5) / multiplier
end

function library:apply_theme(instance, theme, property)
	table.insert(themes.utility[theme][property], instance)
end

function library:update_theme(theme, color)
	for _, property in next, themes.utility[theme] do
		for m, object in next, property do
			if object[_] == themes.preset[theme] or object.ClassName == "UIGradient" then
				object[_] = color
			end
		end
	end

	themes.preset[theme] = color
end

function library:connection(signal, callback)
	local connection = signal:Connect(callback)

	table.insert(library.connections, connection)

	return connection
end

function library:create(instance, options)
	local ins = Instance.new(instance)

	for prop, value in next, options do
		ins[prop] = value
	end

	return ins
end

function library:make_draggable(frame)
	local dragging = false
	local dragInput
	local dragStart
	local startPos
	local moveConnection
	local endConnection

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then return end
			
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			moveConnection = uis.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					update(input)
				end
			end)

			endConnection = uis.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
					if moveConnection then
						moveConnection:Disconnect()
						moveConnection = nil
					end
					if endConnection then
						endConnection:Disconnect()
						endConnection = nil
					end
				end
			end)
		end
	end)
end

library.gui = library:create("ScreenGui", {
	Enabled = true,
	Parent = coregui,
	Name = "",
	DisplayOrder = 2,
	ZIndexBehavior = 1,
})

function library:window(properties)
	local cfg = {
		name = properties.Name or properties.name or properties.Title or properties.title or "sp4m.wtf",
		size = properties.Size or properties.size or dim2(0, 500, 0, 650),
	}

	local animated_text = library:animation("solvent")

	local __holder = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 20),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		ZIndex = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})

	local inline1 = library:create("Frame", {
		Parent = __holder,
		Name = "",
		Active = true,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, ((#animated_text / 2) * 7) + 25, 0, 40),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})
	library:make_draggable(inline1)

	local accent_line = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BorderColor3 = Color3.fromRGB(34, 34, 34),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = themes.preset.accent,
	})

	library:apply_theme(accent_line, "accent", "BackgroundColor3")

	local depth = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 0, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	local inline2 = library:create("Frame", {
		Parent = inline1,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -4, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local main = library:create("Frame", {
		Parent = inline2,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(57, 57, 57),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local tab_inline = library:create("Frame", {
		Parent = main,
		Name = "",
		Position = UDim2.new(0, 6, 0, 6),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -12, 1, -12),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(19, 19, 19),
	})

	local tabs = library:create("Frame", {
		Parent = tab_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local name = library:create("TextLabel", {
		Parent = tabs,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "suicide",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Center,
		BorderSizePixel = 0,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local TEXT_ANIMATION_GRADIENT = library:create("UIGradient", {
		Parent = name,
		Name = "",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.01, themes.preset.accent),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		}),
	})

	local glow = library:create("ImageLabel", {
		Parent = accent_line,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, -20),
		Size = UDim2.new(1, 40, 0, 42),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	library:apply_theme(glow, "accent", "ImageColor3")

	task.spawn(function()
		while true do
			if __holder.Visible then
				for i = 1, #animated_text do
					task.wait(0.2)
					name.Text = animated_text[i]
				end
			end
			task.wait(0.2)
		end
	end)

	local inline1 = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		Active = true,
		Position = UDim2.new(0.5, -cfg.size.X.Offset / 2, 0.5, -cfg.size.Y.Offset / 2),
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		ZIndex = 2,
		Size = cfg.size,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})
	library:make_draggable(inline1)
	table.insert(library.main_frame, inline1)
	local WINDOW_PATH = inline1
	library:make_resizable(inline1)

	local inline2 = library:create("Frame", {
		Parent = inline1,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -4, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local main = library:create("Frame", {
		Parent = inline2,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(57, 57, 57),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local tab_buttons = library:create("Frame", {
		Parent = main,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 4),
		Size = UDim2.new(1, -32, 0, 0),
		ZIndex = 2,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	cfg["tab_holder"] = tab_buttons

	local list = library:create("UIListLayout", {
		Parent = tab_buttons,
		Name = "",
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local tab_inline = library:create("Frame", {
		Parent = main,
		Name = "",
		Position = UDim2.new(0, 15, 0, 33),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -30, 1, -48),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(19, 19, 19),
	})

	local tabs = library:create("Frame", {
		Parent = tab_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	cfg["tab_instance_holder"] = tabs

	local accent_line = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BorderColor3 = Color3.fromRGB(34, 34, 34),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = themes.preset.accent,
	})

	library:apply_theme(accent_line, "accent", "BackgroundColor3")

	local name = library:create("TextLabel", {
		Parent = inline1,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = cfg.name,
		TextStrokeTransparency = 0.5,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, -1),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 2,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local glow = library:create("ImageLabel", {
		Parent = inline1,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, -20),
		Size = UDim2.new(1, 40, 0, 42),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})
	library:apply_theme(glow, "accent", "ImageColor3")

	local depth = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 0, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	local holder = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, 20, 0, 0),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		ZIndex = 2,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})

task.spawn(function()
	while true do
		if (not library) or library.__unloaded or (not flags) then
			break
		end

		if flags["color_picker_anim_speed"] then
			library.sin = math.abs(math.sin(tick() * flags["color_picker_anim_speed"]))

			TEXT_ANIMATION_GRADIENT.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(math.abs(math.sin(tick())), themes.preset.accent),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
			})
		end
		task.wait()
	end
end)

	local esp_preview = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		Visible = false,
		Active = true,
		Position = UDim2.new(
			0,
			inline1.AbsolutePosition.X + inline1.AbsoluteSize.X + 8,
			0,
			inline1.AbsolutePosition.Y + 1
		),
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		Size = UDim2.new(0, 328, 0, 376),
		BackgroundColor3 = Color3.fromRGB(56, 56, 56),
	})
	library:make_draggable(esp_preview)
	library:make_resizable(esp_preview)

	local name = library:create("TextLabel", {
		Parent = esp_preview,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "esp preview",
		TextStrokeTransparency = 0.5,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, -1),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 2,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = name,
		Name = "",
	})

	local main = library:create("Frame", {
		Parent = esp_preview,
		Name = "",
		Position = UDim2.new(0, 4, 0, 4),
		BorderColor3 = Color3.fromRGB(26, 26, 26),
		Size = UDim2.new(1, -8, 1, -8),
		BorderSizePixel = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	library:create("UIStroke", {
		Parent = main,
		Name = "",
		Color = Color3.fromRGB(57, 57, 57),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local tabs = library:create("Frame", {
		Parent = main,
		Name = "",
		Position = UDim2.new(0, 8, 0, 8),
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		Size = UDim2.new(1, -16, 1, -16),
		BorderSizePixel = 2,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	library:create("UIStroke", {
		Parent = tabs,
		Name = "",
		Color = Color3.fromRGB(57, 57, 57),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local hitpart = library:create("Frame", {
		Parent = tabs,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 2, 0, 20),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local head = library:create("Frame", {
		Parent = hitpart,
		Name = "",
		Position = UDim2.new(0.5, -25, 0, 16),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 50, 0, 44),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local torso = library:create("Frame", {
		Parent = hitpart,
		Name = "",
		Position = UDim2.new(0.5, -42, 0, 64),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 84, 0, 90),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local l_arm = library:create("Frame", {
		Parent = hitpart,
		Name = "",
		Position = UDim2.new(0.5, -86, 0, 64),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 40, 0, 90),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local r_arm = library:create("Frame", {
		Parent = hitpart,
		Name = "",
		Position = UDim2.new(0.5, 46, 0, 64),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 40, 0, 90),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local r_leg = library:create("Frame", {
		Parent = hitpart,
		Name = "",
		Position = UDim2.new(0.5, 2, 0, 158),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 40, 0, 90),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local l_leg = library:create("Frame", {
		Parent = hitpart,
		Name = "",
		Position = UDim2.new(0.5, -42, 0, 158),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 40, 0, 90),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local hrp = library:create("Frame", {
		Parent = hrp_out,
		Name = "",
		Position = UDim2.new(0, 4, 0, 4),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -8, 1, -8),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local glow_patterns = {}

	for _, v in next, hitpart:GetChildren() do
		local glow = library:create("ImageLabel", {
			Parent = v,
			Name = "",
			Visible = false,
			ImageColor3 = themes.preset.accent,
			ScaleType = Enum.ScaleType.Slice,
			ImageTransparency = 0.8999999761581421,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Image = "http://www.roblox.com/asset/?id=18245826428",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, -20, 0, -20),
			Size = UDim2.new(1, 40, 1, 40),
			ZIndex = 2,
			BorderSizePixel = 0,
			SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
		})

		library:apply_theme(glow, "accent", "ImageColor3")

		table.insert(glow_patterns, glow)
	end

	function cfg.preview_chams(bool)
		for _, glow in next, glow_patterns do
			glow.Visible = bool
		end

		for _, part in next, hitpart:GetChildren() do
			part.BackgroundColor3 = bool and themes.preset.accent or Color3.fromRGB(38, 38, 38)
		end
	end

	local player = library:create("Frame", {
		Parent = tabs,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 43, 0, 28),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -86, 1, -106),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local line_holder = library:create("Frame", {
		Parent = player,
		Name = "",
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 50,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local box_outline = library:create("Frame", {
		Parent = line_holder,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -1, 0, -1),
		ZIndex = 50,
		Size = UDim2.new(1, 2, 1, 2),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local BoxLine2 = library:create("UIStroke", {
		Parent = box_outline,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local box_color = library:create("UIStroke", {
		Parent = line_holder,
		Name = "",
		Color = Color3.fromRGB(255, 255, 255),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local corner_box = library:create("Frame", {
		Parent = line_holder,
		Name = "",
		Visible = false,
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local top_left = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0, 1, 0.30000001192092896, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local top_right = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0, 1, 0.30000001192092896, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local bottom_left = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0.4000000059604645, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local bottom_right = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -1, 1, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0.4000000059604645, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local bottom_left2 = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0, 1, 0.30000001192092896, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local bottom_right2 = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0, 1, 0.30000001192092896, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local top_left2 = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		AnchorPoint = Vector2.new(0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0.4000000059604645, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local top_right2 = library:create("Frame", {
		Parent = corner_box,
		Name = "",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -1, 0, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 50,
		Size = UDim2.new(0.4000000059604645, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	function cfg.preview_corner_boxes(bool)
		corner_box.Visible = bool == "Corner" and true or false
		BoxLine2.Enabled = bool == "Corner" and false or true
		box_outline.Visible = bool == "Corner" and false or true
		box_color.Enabled = bool == "Corner" and false or true
	end

	function cfg.preview_bounding_box(bool)
		BoxLine2.Enabled = bool
		box_outline.Visible = bool
		box_color.Enabled = bool
	end

	local bottom_holder = library:create("Frame", {
		Parent = line_holder,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -1, 1, 3),
		Size = UDim2.new(1, 2, 0, 0),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = bottom_holder,
		Name = "",
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local UIPadding = library:create("UIPadding", {
		Parent = bottom_holder,
		Name = "",
		PaddingTop = UDim.new(0, 1),
	})

	local bar_holder = library:create("Frame", {
		Parent = bottom_holder,
		Name = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 4),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local reload_bar = library:create("Frame", {
		Parent = bar_holder,
		Name = "",
		Size = UDim2.new(1, 0, 0, 4),
		ZIndex = 50,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	function cfg.preview_reload_bar(bool)
		bar_holder.Visible = bool
	end

	local reload_slider = library:create("Frame", {
		Parent = reload_bar,
		Name = "",
		Size = UDim2.new(0.5, -2, 0, 2),
		Position = UDim2.new(0, 1, 0, 1),
		ZIndex = 50,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(28, 145, 255),
	})

	local gradient = library:create("UIGradient", {
		Parent = reload_slider,
		Name = "",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 238)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 238)),
		}),
	})

	local UIStroke = library:create("UIStroke", {
		Parent = distance,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local weapon = library:create("TextLabel", {
		Parent = bottom_holder,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = "double barrel",
		TextStrokeTransparency = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.031031031161546707, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 50,
		TextSize = 12,
		Size = UDim2.new(1, 0, 0, 4),
	})

	function cfg.preview_weapon(bool)
		weapon.Visible = bool
	end

	local UIStroke = library:create("UIStroke", {
		Parent = weapon,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local UIStroke = library:create("UIStroke", {
		Parent = distance,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local image_holder = library:create("Frame", {
		Parent = bottom_holder,
		Name = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	function cfg.preview_icons(bool)
		image_holder.Visible = bool
	end

	local ImageLabel = library:create("ImageLabel", {
		Parent = image_holder,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Image = "rbxassetid://130516018594923",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(0, 64, 0, 27),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local armor = library:create("Frame", {
		Parent = line_holder,
		Name = "",
		Position = UDim2.new(0, -14, 0, -2),
		Size = UDim2.new(0, 4, 1, 4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	function cfg.preview_armor(bool)
		armor.Visible = bool
	end

	local armor_slider = library:create("Frame", {
		Parent = armor,
		Name = "",
		Position = UDim2.new(0, 1, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0.5, 0, 1, -2),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 13, 255),
	})

	local armor_gradient = library:create("UIGradient", {
		Parent = armor_slider,
		Name = "",
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 242, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 17, 255)),
		}),
		Enabled = false,
	})

	local armor_text = library:create("TextLabel", {
		Parent = armor_slider,
		Name = "",
		ZIndex = 99,
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(0, 13, 255),
		Text = "100",
		Position = UDim2.new(0, -2, 0.75, -2),
		TextStrokeTransparency = 0,
		AnchorPoint = Vector2.new(1, 0),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		Active = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(26, 255, 0),
	})

	library:create("UIStroke", {
		Parent = armor_text,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local health = library:create("Frame", {
		Parent = line_holder,
		Name = "",
		Position = UDim2.new(0, -8, 0, -2),
		Size = UDim2.new(0, 4, 1, 4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	function cfg.preview_health(bool)
		health.Visible = bool
	end

	local health_slider = library:create("Frame", {
		Parent = health,
		Name = "",
		Position = UDim2.new(0, 1, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0.5, 0, 1, -2),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 255, 42),
	})

	local health_text = library:create("TextLabel", {
		Parent = health_slider,
		Name = "",
		Visible = false,
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(0, 255, 0),
		Text = "100",
		ZIndex = 99,
		TextStrokeTransparency = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, -4, 0.5, -2),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		Active = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(26, 255, 0),
	})

	local UIStroke = library:create("UIStroke", {
		Parent = health_text,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local box_inline = library:create("Frame", {
		Parent = line_holder,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 1, 0, 1),
		ZIndex = 50,
		Size = UDim2.new(1, -2, 1, -2),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local BoxLine3 = library:create("UIStroke", {
		Parent = box_inline,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local gradient = library:create("UIGradient", {
		Parent = line_holder,
		Name = "",
		Rotation = -180,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 0.5),
		}),
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
		}),
	})

	function cfg.preview_filler(bool)
		line_holder.BackgroundTransparency = bool and 0 or 1
		gradient.Enabled = bool
	end

	local top_holder = library:create("Frame", {
		Parent = line_holder,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -2, 0, -4),
		Size = UDim2.new(1, 4, 0, 0),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	library:create("UIListLayout", {
		Parent = top_holder,
		Name = "",
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	library:create("UIPadding", {
		Parent = top_holder,
		Name = "",
		PaddingTop = UDim.new(0, 1),
	})

	local player_name = library:create("TextLabel", {
		Parent = top_holder,
		Name = "",
		RichText = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = "hello there",
		FontFace = library.font,
		AnchorPoint = Vector2.new(0, 1),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, -2),
		BorderSizePixel = 0,
		ZIndex = 50,
		TextSize = 12,
		Size = UDim2.new(1, 0, 0, 0),
	})

	function cfg.preview_names(bool)
		player_name.Visible = bool
	end

	local UIStroke = library:create("UIStroke", {
		Parent = player_name,
		Name = "",
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local accent_line = library:create("Frame", {
		Parent = esp_preview,
		Name = "",
		BorderColor3 = Color3.fromRGB(34, 34, 34),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = themes.preset.accent,
	})

	library:apply_theme(accent_line, "accent", "BackgroundColor3")

	local depth = library:create("Frame", {
		Parent = esp_preview,
		Name = "",
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 0, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	local glow = library:create("ImageLabel", {
		Parent = esp_preview,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, -20),
		Size = UDim2.new(1, 40, 0, 42),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	library:apply_theme(glow, "accent", "ImageColor3")

	local selected_button
	local selected_player
	local player_buttons = {}

	function library.get_priority(player)
		return player_buttons[player.Name].priority.Text
	end

	local playerlist = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		Active = true,
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, inline1.AbsolutePosition.X - 358 - 8, 0, inline1.AbsolutePosition.Y + 1),
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		Size = UDim2.new(0, 358, 0, 328),
		BackgroundColor3 = Color3.fromRGB(56, 56, 56),
		Visible = false,
	})
	library:make_draggable(playerlist)
	library:make_resizable(playerlist)

	table.insert(library.main_frame, playerlist)

	local name = library:create("TextLabel", {
		Parent = playerlist,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "playerlist",
		TextStrokeTransparency = 0.5,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, -1),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 2,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = name,
		Name = "",
	})

	local main = library:create("Frame", {
		Parent = playerlist,
		Name = "",
		Position = UDim2.new(0, 4, 0, 4),
		BorderColor3 = Color3.fromRGB(26, 26, 26),
		Size = UDim2.new(1, -8, 1, -8),
		BorderSizePixel = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	library:create("UIStroke", {
		Parent = main,
		Name = "",
		Color = Color3.fromRGB(57, 57, 57),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local tabs = library:create("Frame", {
		Parent = main,
		Name = "",
		Position = UDim2.new(0, 8, 0, 8),
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		Size = UDim2.new(1, -16, 1, -16),
		BorderSizePixel = 2,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	library:create("UIStroke", {
		Parent = tabs,
		Name = "",
		Color = Color3.fromRGB(57, 57, 57),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local list = library:create("Frame", {
		Parent = tabs,
		Name = "",
		Position = UDim2.new(0, 14, 0, 14),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -28, 0.75, -28),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local inline = library:create("Frame", {
		Parent = list,
		Name = "",
		Position = UDim2.new(0, 1, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -2, 1, -2),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(57, 57, 57),
	})

	local background = library:create("Frame", {
		Parent = inline,
		Name = "",
		Position = UDim2.new(0, 1, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -2, 1, -2),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local UIGradient = library:create("UIGradient", {
		Parent = background,
		Name = "",
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(167, 167, 167)),
		}),
	})

	local contrast = library:create("Frame", {
		Parent = background,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local __ScrollingFrame = library:create("ScrollingFrame", {
		Parent = contrast,
		Name = "",
		ScrollBarImageColor3 = themes.preset.accent,
		MidImage = "rbxassetid://18406573371",
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		TopImage = "rbxassetid://18406573371",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1.0099999904632568,
		BottomImage = "rbxassetid://18406573371",
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})

	library:apply_theme(__ScrollingFrame, "accent", "ScrollBarImageColor3")

	local UIPadding = library:create("UIPadding", {
		Parent = __ScrollingFrame,
		Name = "",
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = __ScrollingFrame,
		Name = "",
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local info = library:create("Frame", {
		Parent = tabs,
		Name = "",
		Position = UDim2.new(0, 14, 0.75, -5),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -28, 0.30000001192092896, -23),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local inline = library:create("Frame", {
		Parent = info,
		Name = "",
		Position = UDim2.new(0, 1, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -2, 1, -2),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(57, 57, 57),
	})

	local background = library:create("Frame", {
		Parent = inline,
		Name = "",
		Position = UDim2.new(0, 1, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -2, 1, -2),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local UIGradient = library:create("UIGradient", {
		Parent = background,
		Name = "",
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(167, 167, 167)),
		}),
	})

	local contrast = library:create("Frame", {
		Parent = background,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local ScrollingFrame = library:create("ScrollingFrame", {
		Parent = contrast,
		Name = "",
		ScrollBarImageColor3 = Color3.fromRGB(155, 125, 175),
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		BackgroundTransparency = 1.0099999904632568,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = ScrollingFrame,
		Name = "",
		PaddingTop = UDim.new(0, 7),
		PaddingBottom = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 10),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = ScrollingFrame,
		Name = "",
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local display_name_label = library:create("TextLabel", {
		Parent = ScrollingFrame,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(180, 180, 180),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "display name: ...",
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutomaticSize = Enum.AutomaticSize.XY,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	library:create("UIStroke", {
		Parent = display_name_label,
		Name = "",
	})

	local name_label = library:create("TextLabel", {
		Parent = ScrollingFrame,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(180, 180, 180),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "name: ...",
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutomaticSize = Enum.AutomaticSize.XY,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	library:create("UIStroke", {
		Parent = name_label,
		Name = "",
	})

	local priority_label = library:create("TextLabel", {
		Parent = ScrollingFrame,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(180, 180, 180),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "priority: friendly",
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutomaticSize = Enum.AutomaticSize.XY,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	library:create("UIStroke", {
		Parent = priority_label,
		Name = "",
	})

	local Frame = library:create("Frame", {
		Parent = contrast,
		Name = "",
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -10, 0, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -200, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local button_inline = library:create("Frame", {
		Parent = Frame,
		Name = "",
		Position = UDim2.new(0, -15, 0, 2),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -26, 0, 16),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local button = library:create("TextButton", {
		Parent = button_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "neutral",
		TextStrokeTransparency = 0.5,
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	button.MouseButton1Click:Connect(function()
		player_buttons[selected_player.Name].priority.Text = "neutral"
		player_buttons[selected_player.Name].priority.TextColor3 = rgb(180, 180, 180)
	end)

	local button_inline = library:create("Frame", {
		Parent = Frame,
		Name = "",
		Position = UDim2.new(0, -15, 0, 2),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -26, 0, 16),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local button = library:create("TextButton", {
		Parent = button_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "friendly",
		TextStrokeTransparency = 0.5,
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	button.MouseButton1Click:Connect(function()
		player_buttons[selected_player.Name].priority.Text = "friendly"
		player_buttons[selected_player.Name].priority.TextColor3 = rgb(15, 179, 255)
	end)

	local button_inline = library:create("Frame", {
		Parent = Frame,
		Name = "",
		Position = UDim2.new(0, -15, 0, 2),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -26, 0, 16),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local button = library:create("TextButton", {
		Parent = button_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "enemy",
		TextStrokeTransparency = 0.5,
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	button.MouseButton1Click:Connect(function()
		player_buttons[selected_player.Name].priority.Text = "enemy"
		player_buttons[selected_player.Name].priority.TextColor3 = rgb(255, 44, 44)
	end)

	local UIListLayout = library:create("UIListLayout", {
		Parent = Frame,
		Name = "",
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
		Padding = UDim.new(0, 4),
	})

	local accent_line = library:create("Frame", {
		Parent = playerlist,
		Name = "",
		BorderColor3 = Color3.fromRGB(34, 34, 34),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = themes.preset.accent,
	})

	library:apply_theme(accent_line, "accent", "BackgroundColor3")

	local depth = library:create("Frame", {
		Parent = playerlist,
		Name = "",
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 0, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	local glow = library:create("ImageLabel", {
		Parent = playerlist,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, -20),
		Size = UDim2.new(1, 40, 0, 42),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	library:apply_theme(glow, "accent", "ImageColor3")

	local function create_player(player)
		local TextButton = library:create("TextButton", {
			Parent = __ScrollingFrame,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(180, 180, 180),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		player_buttons[player.Name] = {}
		player_buttons[player.Name].instance = TextButton

		local TextLabel = library:create("TextLabel", {
			Parent = TextButton,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(180, 180, 180),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = player.Name,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			AutomaticSize = Enum.AutomaticSize.Y,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		library:create("UIStroke", {
			Parent = TextLabel,
			Name = "",
		})

		local TextLabel = library:create("TextLabel", {
			Parent = TextButton,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(180, 180, 180),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = player.Team and tostring(player.Team) or "none",
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		library:create("UIStroke", {
			Parent = TextLabel,
			Name = "",
		})

		local Frame = library:create("Frame", {
			Parent = TextLabel,
			Name = "",
			Position = UDim2.new(0, -10, 0, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 1, 0, 12),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(32, 32, 38),
		})

		local TextLabel = library:create("TextLabel", {
			Parent = TextButton,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(180, 180, 180),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = "neutral",
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		player_buttons[player.Name].priority = TextLabel

		library:create("UIStroke", {
			Parent = TextLabel,
			Name = "",
		})

		local Frame = library:create("Frame", {
			Parent = TextLabel,
			Name = "",
			Position = UDim2.new(0, -10, 0, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 1, 0, 12),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(32, 32, 38),
		})

		local UIListLayout = library:create("UIListLayout", {
			Parent = TextButton,
			Name = "",
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalFlex = Enum.UIFlexAlignment.Fill,
		})

		local UIPadding = library:create("UIPadding", {
			Parent = TextButton,
			Name = "",
			PaddingRight = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
		})

		local line = library:create("Frame", {
			Parent = tabs,
			Name = "",
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(1, 0, 0, 1),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(32, 32, 38),
		})

		TextButton.MouseButton1Click:Connect(function()
			if selected_button then
				selected_button.BackgroundTransparency = 1
			end

			selected_button = TextButton
			selected_player = player
			TextButton.BackgroundTransparency = 0.85

			priority_label.Text = "priority: " .. library.get_priority(player)
			name_label.Text = "name: " .. player.Name
			display_name_label.Text = "display: " .. player.DisplayName
		end)
	end

	for _, player in next, players:GetPlayers() do
		create_player(player)
	end

	library:connection(players.PlayerAdded, function(player)
		create_player(player)
	end)

	library:connection(players.PlayerRemoving, function(player)
		player_buttons[player.Name].instance:Destroy()
	end)

	local old_kblist = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0.5, 0),
		ZIndex = 2,
		Active = true,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})
	library:make_draggable(old_kblist)

	local glow = library:create("ImageLabel", {
		Parent = old_kblist,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, -20),
		Size = UDim2.new(1, 40, 0, 42),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	library:apply_theme(glow, "accent", "ImageColor3")

	local inline1 = library:create("Frame", {
		Parent = old_kblist,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})

	local accent_line = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BorderColor3 = Color3.fromRGB(34, 34, 34),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = themes.preset.accent,
	})

	library:apply_theme(accent_line, "accent", "BackgroundColor3")

	local name = library:create("TextLabel", {
		Parent = inline1,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "keybinds",
		TextStrokeTransparency = 0.5,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, -1),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 2,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local inline2 = library:create("Frame", {
		Parent = inline1,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -4, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local main = library:create("Frame", {
		Parent = inline2,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(57, 57, 57),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local tab_inline = library:create("Frame", {
		Parent = main,
		Name = "",
		Position = UDim2.new(0, 6, 0, 6),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -12, 1, -12),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(19, 19, 19),
	})

	local tabs = library:create("Frame", {
		Parent = tab_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = tabs,
		Name = "",
		PaddingBottom = UDim.new(0, 22),
		PaddingRight = UDim.new(0, 20),
		PaddingLeft = UDim.new(0, 20),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = tabs,
		Name = "",
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 3),
	})

	local UIStroke = library:create("UIStroke", {
		Parent = tabs,
		Name = "",
		Color = Color3.fromRGB(57, 57, 57),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local depth = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 0, 0, 1),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 2,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	library.keybind_path = tabs

	function cfg.toggle_list(bool)
		old_kblist.Visible = bool
	end

	function cfg.toggle_playerlist(bool)
		playerlist.Visible = bool
	end

	function cfg.toggle_watermark(bool)
		__holder.Visible = bool
	end

	function cfg.set_menu_visibility(bool, pl)
		WINDOW_PATH.Visible = bool
		
		if not bool then
			if library.current_element_open and library.current_element_open.set_visible then
				library.current_element_open.set_visible(false)
				if library.current_element_open.open ~= nil then
					library.current_element_open.open = false
				end
				library.current_element_open = nil
			end
			if library.current_settings_menu and library.current_settings_menu.set_settings_visible then
				library.current_settings_menu.set_settings_visible(false)
				library.current_settings_menu.settings_open = false
				library.current_settings_menu = nil
			end
			for _, menu in ipairs(library.open_menus) do
				if menu and menu.Visible ~= nil then
					menu.Visible = false
				end
			end
			library.open_menus = {}
			for _, menu in ipairs(library.open_keybind_menus) do
				if menu and menu.Visible ~= nil then
					menu.Visible = false
				end
			end
			library.open_keybind_menus = {}
		end
		
		playerlist.Visible = false
	end

	return setmetatable(cfg, library)
end

function library:new_keybind(properties)
	local cfg = {
		text = properties.name or properties.text or "aimbot",
		key = properties.key or nil,
		mode = properties.mode or "hold",
	}

	local keybind_text = library:create("TextLabel", {
		Parent = library.keybind_path,
		Name = "",
		FontFace = library.font,
		LineHeight = 1.2000000476837158,
		TextStrokeTransparency = 0.5,
		AnchorPoint = Vector2.new(0.5, 0),
		TextSize = 12,
		Size = UDim2.new(0, 0, 0, 11),
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 8),
		BorderSizePixel = 0,
		Visible = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = keybind_text,
		Name = "",
		PaddingTop = UDim.new(0, 6),
	})

	function cfg.set_visible(bool)
		keybind_text.Visible = bool
	end

	function cfg.change_text(text)
		keybind_text.Text = text
	end

	function keyName(key)
		local text = tostring(key) ~= "Enums" and (keys[key] or tostring(key):gsub("Enum.", "")) or nil
		local __text = text and (tostring(text):gsub("KeyCode.", ""):gsub("UserInputType.", ""))

		return __text or "..."
	end

	function cfg.update(n_properties)
		cfg.change_text(
			"["
				.. tostring(keyName(n_properties.key))
				.. "] "
				.. tostring(n_properties.text)
				.. " ("
				.. tostring(n_properties.mode)
				.. ")"
		)
	end

	cfg.change_text(
		"[" .. tostring(keyName(cfg.key)) .. "] " .. tostring(cfg.text) .. " (" .. tostring(cfg.mode) .. ")"
	)

	return cfg
end

function library:notification(properties)
	local cfg = {
		time = properties.time or 5,
		text = properties.text or properties.name or "ledger.live is pasted",
	}

	function cfg:refresh_notifications()
		for _, notif in next, library.notifications do
			tween_service
				:Create(
					notif,
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
					{ Position = dim2(0, 20, 0, 72 + (_ * 28)) }
				)
				:Play()
		end
	end

	local holder = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 72 + (#library.notifications * 28)),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		ZIndex = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		AnchorPoint = Vector2.new(1, 0),
	})

	local inline1 = library:create("Frame", {
		Parent = holder,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 0, 0, 24),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})

	local inline2 = library:create("Frame", {
		Parent = inline1,
		Name = "",
		Position = UDim2.new(0, 0, 0, 2),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -4, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local main = library:create("Frame", {
		Parent = inline2,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(57, 57, 57),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local tab_inline = library:create("Frame", {
		Parent = main,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -4, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(19, 19, 19),
	})

	local name = library:create("TextLabel", {
		Parent = tab_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = cfg.text,
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(0, 0, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = tab_inline,
		Name = "",
		PaddingRight = UDim.new(0, 14),
	})

	local depth = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 1, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		ZIndex = 2,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	local accent_line = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BorderColor3 = Color3.fromRGB(34, 34, 34),
		Size = UDim2.new(0, 2, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = themes.preset.accent,
	})

	library:apply_theme(accent_line, "accent", "BackgroundColor3")

	local glow = library:create("ImageLabel", {
		Parent = holder,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, 0),
		Size = UDim2.new(0, 42, 1, 40),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	library:apply_theme(glow, "accent", "ImageColor3")

	task.spawn(function()
		tween_service
			:Create(
				holder,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{ AnchorPoint = Vector2.new(0, 0) }
			)
			:Play()

		task.wait(cfg.time)

		tween_service
			:Create(
				holder,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{ AnchorPoint = Vector2.new(1, 0) }
			)
			:Play()
		for _, v in next, holder:GetDescendants() do
			if v:IsA("TextLabel") then
				tween_service
					:Create(
						v,
						TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{ TextTransparency = 1 }
					)
					:Play()
			elseif v:IsA("Frame") then
				tween_service
					:Create(
						v,
						TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{ BackgroundTransparency = 1 }
					)
					:Play()
			elseif v:IsA("ImageLabel") then
				tween_service
					:Create(
						v,
						TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{ ImageTransparency = 1 }
					)
					:Play()
			end
		end
	end)

	task.delay(cfg.time + 0.1, function()
		table.remove(library.notifications, table.find(library.notifications, holder))
		cfg:refresh_notifications()
		task.wait(0.5)
		holder:Destroy()
	end)

	table.insert(library.notifications, holder)
end

function library:tab(properties)
	local cfg = {
		name = properties.name or "tab",
		enabled = false,
	}

	local is_first_tab = not library.first_tab_set

	local TAB_BUTTON = library:create("TextButton", {
		Parent = self.tab_holder,
		Name = "",
		FontFace = library.font,
		TextColor3 = themes.preset.unselected_text,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = cfg.name,
		TextStrokeTransparency = 0.5,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.3330000042915344, -4, 0, 22),
		BorderSizePixel = 0,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local line = library:create("Frame", {
		Parent = TAB_BUTTON,
		Name = "",
		Position = UDim2.new(0, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = rgb(57, 57, 57),
	})

	library:apply_theme(line, "accent", "BackgroundColor3")

	local glow = library:create("ImageLabel", {
		Parent = line,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, -20),
		Size = UDim2.new(1, 40, 1, 40),
		ZIndex = 2,
		Visible = false,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	library:apply_theme(glow, "accent", "ImageColor3")

	local depth = library:create("Frame", {
		Parent = line,
		Name = "",
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 0, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	local TAB = library:create("Frame", {
		Parent = self.tab_instance_holder,
		Name = "",
		Visible = false,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local scrolling_columns = library:create("Frame", {
		Parent = TAB,
		Name = "",
		ClipsDescendants = true,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 6, 0, 6),
		Size = UDim2.new(1, -12, 1, -12),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	cfg["column_holder"] = scrolling_columns

	local UIListLayout = library:create("UIListLayout", {
		Parent = scrolling_columns,
		Name = "",
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local left = library:create("ScrollingFrame", {
		Parent = scrolling_columns,
		Name = "",
		ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		Size = UDim2.new(0.5, -64, 1, 0),
		ClipsDescendants = false,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 4, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})

	left:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if library.current_element_open then
			library.current_element_open.set_visible(false)
			library.current_element_open.open = false
			library.current_element_open = nil
		end
	end)

	cfg["left"] = left

	local UIListLayout = library:create("UIListLayout", {
		Parent = left,
		Name = "",
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local UIPadding = library:create("UIPadding", {
		Parent = left,
		Name = "",
		PaddingBottom = UDim.new(0, 15),
	})

	local right = library:create("ScrollingFrame", {
		Parent = scrolling_columns,
		Name = "",
		ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		Size = UDim2.new(0.5, -64, 1, 0),
		ClipsDescendants = false,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, -50, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})

	right:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if library.current_element_open then
			library.current_element_open.set_visible(false)
			library.current_element_open.open = false
			library.current_element_open = nil
		end
	end)

	cfg["right"] = right

	local UIListLayout = library:create("UIListLayout", {
		Parent = right,
		Name = "",
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local UIPadding = library:create("UIPadding", {
		Parent = right,
		Name = "",
		PaddingBottom = UDim.new(0, 15),
	})

	function cfg.open_tab()
		if library.current_tab and library.current_tab[1] ~= TAB_BUTTON then
			local button = library.current_tab[1]
			button.TextColor3 = themes.preset.unselected_text

			local parent = button:FindFirstChildOfClass("Frame")
			parent.BackgroundColor3 = rgb(57, 57, 57)
			parent:FindFirstChildOfClass("ImageLabel").Visible = false

			library.current_tab[2].Visible = false
		end

		library.current_tab = {
			TAB_BUTTON,
			TAB,
		}

		line.BackgroundColor3 = themes.preset.accent
		glow.Visible = true
		TAB_BUTTON.TextColor3 = themes.preset.text
		TAB.Visible = true

		if library.current_element_open and library.current_element_open ~= cfg then
			library.current_element_open.set_visible(false)
			library.current_element_open.open = false
			library.current_element_open = nil
		end
		if library.current_settings_menu and library.current_settings_menu.set_settings_visible then
			library.current_settings_menu.set_settings_visible(false)
			library.current_settings_menu.settings_open = false
			library.current_settings_menu = nil
		end
		for _, menu in ipairs(library.open_menus) do
			if menu and menu.Visible ~= nil then
				menu.Visible = false
			end
		end
		library.open_menus = {}
		for _, menu in ipairs(library.open_keybind_menus or {}) do
			if menu and menu.Visible ~= nil then
				menu.Visible = false
			end
		end
		library.open_keybind_menus = {}
	end

	TAB_BUTTON.MouseButton1Click:Connect(cfg.open_tab)

	if is_first_tab then
		library.first_tab_set = true
		task.spawn(function()
			task.wait()
			cfg.open_tab()
		end)
	end

	return setmetatable(cfg, library)
end

function library:section(properties)
	local cfg = {
		name = properties.name or properties.Name or "Section",
		side = properties.side or properties.Side or "left",
	}

	local section = library:create("Frame", {
		Parent = self[cfg.side],
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		ZIndex = 2,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local section_inline = library:create("Frame", {
		Parent = section,
		Name = "",
		Position = UDim2.new(0, 0, 0, 4),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, 0, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local name = library:create("TextLabel", {
		Parent = section_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = cfg.name,
		TextStrokeTransparency = 0.5,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 8, 0, 0),
		ZIndex = 2,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local section = library:create("Frame", {
		Parent = section_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local elements = library:create("Frame", {
		Parent = section,
		Name = "",
		Position = UDim2.new(0, 12, 0, 12),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -24, 0, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = elements,
		Name = "",
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 3),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = section,
		Name = "",
		PaddingBottom = UDim.new(0, 13),
	})

	cfg["holder"] = elements

	return setmetatable(cfg, library)
end

function library:hitpart_picker(properties)
	local cfg = {
		name = properties.name or properties.Name or "Hitpart",
		side = properties.side or properties.Side or "left",
		flag = properties.flag or "Hitpart",
		default = properties.default or { "Head" },
		type_char = properties.type or "R6",
		multi = properties.multi or false,
		callback = properties.callback or function() end,
		height = properties.height or 310,
		previous_holder = self,
		open = false,
	}

	flags[cfg.flag] = {}

	local bodyparts = {}
	local bools = {}

	local button_inline = library:create("Frame", {
		Parent = self.holder,
		Name = "",
		Position = UDim2.new(0, -15, 0, 2),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -26, 0, 16),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local button = library:create("TextButton", {
		Parent = button_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = cfg.name,
		TextStrokeTransparency = 0.5,
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		TextSize = 12,
		TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local icon = library:create("TextLabel", {
		Parent = button,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "+",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.new(1, -6, 0, -1),
		BorderSizePixel = 0,
		TextSize = 8,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local r15_hitpart_holder = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		Size = UDim2.new(0, 250, 0, cfg.height),
		BorderSizePixel = 0,
		ZIndex = 9999,
		Visible = false,
		Position = UDim2.new(0, button_inline.AbsolutePosition.X, 0, button_inline.AbsolutePosition.Y + button_inline.AbsoluteSize.Y + 2),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})
	
	local title_bar = library:create("Frame", {
		Parent = r15_hitpart_holder,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 20),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(19, 19, 19),
	})
	library:make_draggable(r15_hitpart_holder)
	
	local title_text = library:create("TextLabel", {
		Parent = title_bar,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = cfg.name,
		TextStrokeTransparency = 0.5,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -8, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	button_inline:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		if r15_hitpart_holder.Visible then
			r15_hitpart_holder.Position = UDim2.new(0, button_inline.AbsolutePosition.X, 0, button_inline.AbsolutePosition.Y + button_inline.AbsoluteSize.Y + 2)
		end
	end)

	local hitpart_inline = library:create("Frame", {
		Parent = r15_hitpart_holder,
		Name = "",
		Position = UDim2.new(0, 2, 0, 22),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -4, 1, -26),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local hitpart = library:create("Frame", {
		Parent = hitpart_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	if cfg.type_char == "R15" then
		bodyparts.Head = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -25, 0, 16),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 50, 0, 44),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.UpperTorso = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -42, 0, 64),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 84, 0, 76),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftUpperArm = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -86, 0, 64),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 34),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightUpperArm = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 46, 0, 64),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 34),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftUpperLeg = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -42, 0, 158),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 34),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftLowerLeg = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -42, 0, 196),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 42),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightFoot = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 2, 0, 242),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 6),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftFoot = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -42, 0, 242),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 6),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightLowerLeg = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 2, 0, 196),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 42),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightUpperLeg = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 2, 0, 158),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 34),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftHand = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -86, 0, 148),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 6),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightHand = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 46, 0, 148),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 6),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LowerTorso = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -42, 0, 144),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 84, 0, 10),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightLowerArm = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 46, 0, 102),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 42),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftLowerArm = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -86, 0, 102),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 42),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		local outline = library:create("TextButton", {
			Text = "",
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -10, 0, 96),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 20, 0, 20),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		})

		bodyparts.HumanoidRootPart = library:create("TextButton", {
			Text = "",
			Parent = outline,
			Name = "",
			Position = UDim2.new(0, 4, 0, 4),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(1, -8, 1, -8),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})
	else
		bodyparts.Head = library:create("TextButton", {
			Parent = hitpart,
			Name = "",
			Text = "",
			Position = UDim2.new(0.5, -25, 0, 16),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 50, 0, 44),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.Torso = library:create("TextButton", {
			Parent = hitpart,
			Name = "",
			Text = "",
			Position = UDim2.new(0.5, -42, 0, 64),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 84, 0, 90),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftArm = library:create("TextButton", {
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -86, 0, 64),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 90),
			BorderSizePixel = 0,
			Text = "",
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightArm = library:create("TextButton", {
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 46, 0, 64),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 90),
			Text = "",
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.RightLeg = library:create("TextButton", {
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, 2, 0, 158),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 90),
			BorderSizePixel = 0,
			Text = "",
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		bodyparts.LeftLeg = library:create("TextButton", {
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -42, 0, 158),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 40, 0, 90),
			BorderSizePixel = 0,
			Text = "",
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		local hrp_out = library:create("TextButton", {
			Parent = hitpart,
			Name = "",
			Position = UDim2.new(0.5, -10, 0, 99),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 20, 0, 20),
			BorderSizePixel = 0,
			Text = "",
			BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		})

		bodyparts.HumanoidRootPart = library:create("TextButton", {
			Parent = hrp_out,
			Name = "",
			Position = UDim2.new(0, 4, 0, 4),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(1, -8, 1, -8),
			BorderSizePixel = 0,
			Text = "",
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})
	end


	function cfg.set(parts)
		flags[cfg.flag] = {}
		for name, button in pairs(bodyparts) do
			bools[name] = false
			local glow = button:FindFirstChildOfClass("ImageLabel")
			if glow then
				glow.Visible = false
			end
			button.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
		end

		for _, part in pairs(parts) do
			if bodyparts[part] then
				bools[part] = true
				table.insert(flags[cfg.flag], part)
				local glow = bodyparts[part]:FindFirstChildOfClass("ImageLabel")
				if glow then
					glow.Visible = true
				end
				bodyparts[part].BackgroundColor3 = themes.preset.accent
			end
		end

	if type(cfg.callback) == "function" then
		pcall(cfg.callback, flags[cfg.flag])
	end
	end

	cfg.hitpart_holder = r15_hitpart_holder
	cfg.button_inline = button_inline

	function cfg.set_visible(bool)
		r15_hitpart_holder.Visible = bool
		icon.Text = bool and "-" or "+"
		icon.TextSize = bool and 12 or 8

		if bool then
			if library.current_element_open and library.current_element_open ~= cfg then
				library.current_element_open.set_visible(false)
				library.current_element_open.open = false
			end
			library.current_element_open = cfg
			r15_hitpart_holder.Position = UDim2.new(0, button_inline.AbsolutePosition.X, 0, button_inline.AbsolutePosition.Y + button_inline.AbsoluteSize.Y + 2)
		end
	end

	button.MouseButton1Click:Connect(function()
		cfg.open = not cfg.open
		cfg.set_visible(cfg.open)
	end)

	for name, button in next, bodyparts do
		bools[name] = false

		library:apply_theme(button, "accent", "BackgroundColor3")

		local glow = library:create("ImageLabel", {
			Parent = button,
			Name = "",
			Visible = false,
			ImageColor3 = themes.preset.accent,
			ScaleType = Enum.ScaleType.Slice,
			ImageTransparency = 0.8999999761581421,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Image = "http://www.roblox.com/asset/?id=18245826428",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, -20, 0, -20),
			Size = UDim2.new(1, 40, 1, 40),
			ZIndex = 2,
			BorderSizePixel = 0,
			SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
		})

		library:apply_theme(glow, "accent", "ImageColor3")

		library:connection(button.MouseButton1Click, function()
			if not cfg.multi then
				cfg.set({ name })
			else
				bools[name] = not bools[name]

				if bools[name] then
					table.insert(flags[cfg.flag], name)
				else
					local index = table.find(flags[cfg.flag], name)
					table.remove(flags[cfg.flag], index)
				end

				glow.Visible = bools[name]
				button.BackgroundColor3 = bools[name] and themes.preset.accent or Color3.fromRGB(38, 38, 38)

				if type(cfg.callback) == "function" then
					pcall(cfg.callback, flags[cfg.flag])
				end
			end
		end)
	end

	if #cfg.default > 1 and not cfg.multi then
		cfg.default = { cfg.default[1] }
	end

	cfg.set(cfg.default)
	config_flags[cfg.flag] = cfg.set
	return setmetatable(cfg, library)
end

function library:toggle(properties)
	local cfg = {
		enabled = properties.enabled or nil,
		name = properties.name or "Toggle",
		flag = properties.flag or tostring(math.random(1, 9999999)),
		callback = properties.callback or function() end,
		default = properties.default or false,
		previous_holder = self,
		settings = properties.settings or nil,
		settings_open = false,
		keybind = properties.keybind or nil,
		keybind_mode = properties.keybind_mode or "toggle",
		keybind_key = properties.keybind_key or nil,
		binding = nil,
		hitpart_picker = properties.hitpart_picker or nil,
	}

	local object = library:create("TextButton", {
		Parent = self.holder,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = cfg.name,
		TextStrokeTransparency = 0.5,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Size = UDim2.new(1, -26, 0, 12),
		ZIndex = 1,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local right_components = library:create("Frame", {
		Parent = object,
		Name = "",
		Position = UDim2.new(1, 10, 0, 1),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local settings_icon = nil
	local settings_menu = nil
	
	if cfg.settings then
		settings_icon = library:create("TextButton", {
			Parent = right_components,
			Name = "",
			LayoutOrder = 1,
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(19, 19, 19),
			Text = "+",
			TextStrokeTransparency = 0.5,
			Size = UDim2.new(0, 12, 0, 12),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.fromRGB(8, 8, 8),
			TextSize = 10,
		})
		
		settings_menu = library:create("Frame", {
			Parent = library.gui,
			Name = "",
			BorderColor3 = Color3.fromRGB(8, 8, 8),
			Size = UDim2.new(0, 200, 0, 100),
			BorderSizePixel = 0,
			ZIndex = 10000,
			Visible = false,
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		})
		library:make_draggable(settings_menu)
		
		local settings_title = library:create("Frame", {
			Parent = settings_menu,
			Name = "",
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(1, 0, 0, 20),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(19, 19, 19),
		})
		
		local title_text = library:create("TextLabel", {
			Parent = settings_title,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = "settings",
			TextStrokeTransparency = 0.5,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -8, 1, 0),
			Position = UDim2.new(0, 8, 0, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})
		
		local settings_content = library:create("Frame", {
			Parent = settings_menu,
			Name = "",
			Position = UDim2.new(0, 2, 0, 22),
			BorderColor3 = Color3.fromRGB(19, 19, 19),
			Size = UDim2.new(1, -4, 1, -26),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(22, 22, 22),
			ClipsDescendants = false,
		})
		
		local settings_list = library:create("UIListLayout", {
			Parent = settings_content,
			Name = "",
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		})
		
		local settings_padding = library:create("UIPadding", {
			Parent = settings_content,
			Name = "",
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
		})
		
		local settings_settings = {}
		for setting_name, setting_config in pairs(cfg.settings) do
			local setting_flag = setting_config.flag or (cfg.flag .. "_" .. setting_name)
			
			if setting_config.items then
				flags[setting_flag] = setting_config.default or setting_config.items[1]
				
				local setting_frame = library:create("TextButton", {
					Parent = settings_content,
					Name = "",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -4, 0, 16),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(22, 22, 22),
					Text = "",
					AutoButtonColor = false,
					ClipsDescendants = false,
					ZIndex = 1,
				})
				
				local setting_label = library:create("TextLabel", {
					Parent = setting_frame,
					Name = "",
					FontFace = library.font,
					TextColor3 = Color3.fromRGB(170, 170, 170),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = setting_config.name or setting_name,
					TextStrokeTransparency = 0.5,
					BorderSizePixel = 0,
					Size = UDim2.new(0.6, -8, 1, 0),
					Position = UDim2.new(0, 4, 0, 0),
					AnchorPoint = Vector2.new(0, 0),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextSize = 11,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				})
				
				local value_button = library:create("TextButton", {
					Parent = setting_frame,
					Name = "",
					FontFace = library.font,
					TextColor3 = Color3.fromRGB(170, 170, 170),
					BorderColor3 = Color3.fromRGB(56, 56, 56),
					Text = tostring(flags[setting_flag]),
					TextStrokeTransparency = 0.5,
					Size = UDim2.new(0.4, -6, 1, -6),
					Position = UDim2.new(0.6, 2, 0, 3),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(30, 30, 30),
					TextSize = 11,
					AutoButtonColor = false,
					ZIndex = 2,
				})
				
				local dropdown_menu = library:create("Frame", {
					Parent = library.gui,
					Name = "",
					BorderColor3 = Color3.fromRGB(19, 19, 19),
					Size = UDim2.new(0, 120, 0, 0),
					Position = UDim2.new(0, value_button.AbsolutePosition.X, 0, value_button.AbsolutePosition.Y + value_button.AbsoluteSize.Y + 2),
					BorderSizePixel = 0,
					ZIndex = 10001,
					Visible = false,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(18, 18, 18),
				})
				
				local function register_dropdown_menu()
					if not table.find(library.open_menus, dropdown_menu) then
						table.insert(library.open_menus, dropdown_menu)
					end
				end
				
				value_button:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
					if dropdown_menu.Visible then
						dropdown_menu.Position = UDim2.new(0, value_button.AbsolutePosition.X, 0, value_button.AbsolutePosition.Y + value_button.AbsoluteSize.Y + 2)
					end
				end)
				
				if library.main_frame[1] then
					library.main_frame[1]:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
						if dropdown_menu.Visible then
							dropdown_menu.Position = UDim2.new(0, value_button.AbsolutePosition.X, 0, value_button.AbsolutePosition.Y + value_button.AbsoluteSize.Y + 2)
						end
					end)
				end
				
				local dropdown_content = library:create("Frame", {
					Parent = dropdown_menu,
					Name = "",
					Position = UDim2.new(0, 2, 0, 2),
					BorderColor3 = Color3.fromRGB(56, 56, 56),
					Size = UDim2.new(1, -4, 1, -4),
					BackgroundColor3 = Color3.fromRGB(26, 26, 26),
				})
				
				library:create("UIPadding", {
					Parent = dropdown_content,
					Name = "",
					PaddingTop = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 4),
				})
				
				local options_list = library:create("UIListLayout", {
					Parent = dropdown_content,
					Name = "",
					Padding = UDim.new(0, 2),
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				})
				
				local function set_setting_dropdown(val, fire_callback)
					if not val then
						return
					end
					flags[setting_flag] = val
					value_button.Text = val
					if fire_callback and setting_config.callback then
						setting_config.callback(val)
					end
				end

				for _, item in ipairs(setting_config.items) do
					local opt = library:create("TextButton", {
						Parent = dropdown_content,
						Name = "",
						FontFace = library.font,
						TextColor3 = Color3.fromRGB(170, 170, 170),
						BorderColor3 = Color3.fromRGB(56, 56, 56),
						Text = item,
						TextStrokeTransparency = 0.5,
						Size = UDim2.new(1, -6, 0, 10),
						Position = UDim2.new(0, 3, 0, 2),
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(35, 35, 35),
						TextSize = 11,
						TextYAlignment = Enum.TextYAlignment.Center,
						AutoButtonColor = false,
					})
					opt.MouseButton1Click:Connect(function()
						set_setting_dropdown(item, true)
						dropdown_menu.Visible = false
					end)
				end
				
				settings_settings[setting_name] = {
					frame = setting_frame,
					dropdown = dropdown_menu,
					flag = setting_flag,
					set = function(v)
						set_setting_dropdown(v, false)
					end,
				}
				
				value_button.MouseButton1Click:Connect(function()
					local new_visible = not dropdown_menu.Visible
					dropdown_menu.Visible = new_visible
					if new_visible then
						register_dropdown_menu()
						dropdown_menu.Position = UDim2.new(0, value_button.AbsolutePosition.X, 0, value_button.AbsolutePosition.Y + value_button.AbsoluteSize.Y + 2)
					else
						dropdown_menu.Visible = false
					end
				end)
				-- allow configs to reapply this dropdown
				config_flags[setting_flag] = settings_settings[setting_name].set
				set_setting_dropdown(flags[setting_flag], false)

			else
				flags[setting_flag] = setting_config.default or false
				
				local setting_frame = library:create("TextButton", {
					Parent = settings_content,
					Name = "",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -4, 0, 16),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(22, 22, 22),
					Text = "",
					AutoButtonColor = false,
					ClipsDescendants = false,
					ZIndex = 1,
				})
				
				local setting_label = library:create("TextLabel", {
					Parent = setting_frame,
					Name = "",
					FontFace = library.font,
					TextColor3 = Color3.fromRGB(170, 170, 170),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = setting_config.name or setting_name,
					TextStrokeTransparency = 0.5,
					BorderSizePixel = 0,
					Size = UDim2.new(1, -18, 1, 0),
					Position = UDim2.new(0, 4, 0, 0),
					AnchorPoint = Vector2.new(0, 0),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextSize = 11,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				})
					
				local setting_toggle_frame = library:create("Frame", {
					Parent = setting_frame,
					Name = "",
					Position = UDim2.new(1, -2, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					BorderColor3 = Color3.fromRGB(19, 19, 19),
					Size = UDim2.new(0, 10, 0, 10),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(8, 8, 8),
					ZIndex = 1,
					ClipsDescendants = false,
				})
				
				local setting_toggle = library:create("Frame", {
					Parent = setting_toggle_frame,
					Name = "",
					Position = UDim2.new(0, 2, 0, 2),
					BorderColor3 = Color3.fromRGB(56, 56, 56),
					Size = UDim2.new(1, -4, 1, -4),
					BackgroundColor3 = Color3.fromRGB(22, 22, 22),
					ZIndex = 2,
				})
				
				local setting_toggle_indicator = library:create("Frame", {
					Parent = setting_toggle,
					Name = "",
					BorderColor3 = Color3.fromRGB(56, 56, 56),
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = themes.preset.accent,
					Visible = setting_config.default or false,
					ZIndex = 3,
				})
				library:apply_theme(setting_toggle_indicator, "accent", "BackgroundColor3")
				
				local setting_toggle_glow = library:create("ImageLabel", {
					Parent = setting_toggle_frame,
					Name = "",
					Visible = setting_config.default or false,
					ImageColor3 = themes.preset.accent,
					ScaleType = Enum.ScaleType.Slice,
					ImageTransparency = 0.75,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Image = "http://www.roblox.com/asset/?id=18245826428",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, -12, 0, -12),
					Size = UDim2.new(1, 24, 1, 24),
			ZIndex = 999,
					BorderSizePixel = 0,
					SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
				})
				library:apply_theme(setting_toggle_glow, "accent", "ImageColor3")
				
				local function set_setting_toggle(state, fire_callback)
					flags[setting_flag] = not not state
					setting_toggle_indicator.Visible = flags[setting_flag]
					setting_toggle_glow.Visible = flags[setting_flag]
					if fire_callback and setting_config.callback then
						setting_config.callback(flags[setting_flag])
					end
				end

				settings_settings[setting_name] = {
					frame = setting_frame,
					indicator = setting_toggle_indicator,
					glow = setting_toggle_glow,
					flag = setting_flag,
					set = function(v)
						set_setting_toggle(v, false)
					end,
				}
				
				setting_frame.MouseButton1Click:Connect(function()
					set_setting_toggle(not flags[setting_flag], true)
				end)

				-- allow configs to reapply this toggle
				config_flags[setting_flag] = settings_settings[setting_name].set
				set_setting_toggle(flags[setting_flag], false)
			end
		end
		
		local function update_settings_menu_size()
			local total_height = 4
			for _, setting in pairs(settings_settings) do
				total_height = total_height + 20
			end
			settings_menu.Size = UDim2.new(0, 200, 0, math.max(total_height + 26, 48))
		end
		
		update_settings_menu_size()
		
		function cfg.set_settings_visible(bool)
			settings_menu.Visible = bool
			cfg.settings_open = bool
			
			if bool then
				if library.current_settings_menu and library.current_settings_menu ~= cfg then
					library.current_settings_menu.set_settings_visible(false)
					library.current_settings_menu.settings_open = false
				end
				library.current_settings_menu = cfg
				settings_menu.Position = UDim2.new(0, settings_icon.AbsolutePosition.X + settings_icon.AbsoluteSize.X + 2, 0, settings_icon.AbsolutePosition.Y)
				table.insert(library.open_menus, settings_menu)
				for _, setting in pairs(settings_settings) do
					if setting.dropdown then
						setting.dropdown.Visible = false
					end
				end
			else
				for _, setting in pairs(settings_settings) do
					if setting.dropdown then
						setting.dropdown.Visible = false
					end
				end
			end
		end
		
		settings_icon.MouseButton1Click:Connect(function()
			cfg.set_settings_visible(not cfg.settings_open)
		end)
		
		object:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			if settings_menu.Visible then
				settings_menu.Position = UDim2.new(0, settings_icon.AbsolutePosition.X + settings_icon.AbsoluteSize.X + 2, 0, settings_icon.AbsolutePosition.Y)
			end
		end)
	end

	local hitpart_picker_icon = nil
	local hitpart_picker_menu = nil
	
	if cfg.hitpart_picker then
		hitpart_picker_icon = library:create("TextButton", {
			Parent = right_components,
			Name = "",
			LayoutOrder = settings_icon and 2 or 1,
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(19, 19, 19),
			Text = "+",
			TextStrokeTransparency = 0.5,
			Size = UDim2.new(0, 12, 0, 12),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.fromRGB(8, 8, 8),
			TextSize = 10,
		})
		
		local temp_section_holder = setmetatable({ holder = library.gui }, library)
		local hitpart_picker_cfg = temp_section_holder:hitpart_picker({
			name = cfg.hitpart_picker.name or "Hit Parts",
			flag = cfg.hitpart_picker.flag or (cfg.flag .. "_hitparts"),
			default = cfg.hitpart_picker.default or { "Head" },
			multi = cfg.hitpart_picker.multi ~= nil and cfg.hitpart_picker.multi or true,
			type = cfg.hitpart_picker.type or "R6",
			callback = cfg.hitpart_picker.callback or function() end,
		})
		
		if hitpart_picker_cfg.button_inline then
			hitpart_picker_cfg.button_inline:Destroy()
		end
		
		hitpart_picker_menu = hitpart_picker_cfg.hitpart_holder
		
		if hitpart_picker_menu then
			hitpart_picker_menu.Visible = false
			
			hitpart_picker_cfg.set_visible = function(bool)
				hitpart_picker_menu.Visible = bool
				
				if bool then
					if library.current_element_open and library.current_element_open ~= hitpart_picker_cfg then
						if library.current_element_open.set_visible then
							library.current_element_open.set_visible(false)
						end
						if library.current_element_open.open ~= nil then
							library.current_element_open.open = false
						end
					end
					library.current_element_open = hitpart_picker_cfg
					hitpart_picker_menu.Position = UDim2.new(0, hitpart_picker_icon.AbsolutePosition.X + hitpart_picker_icon.AbsoluteSize.X + 2, 0, hitpart_picker_icon.AbsolutePosition.Y)
					if not table.find(library.open_menus, hitpart_picker_menu) then
						table.insert(library.open_menus, hitpart_picker_menu)
					end
		else
			hitpart_picker_menu.Visible = false
				end
			end
			
			hitpart_picker_icon.MouseButton1Click:Connect(function()
				hitpart_picker_cfg.open = not hitpart_picker_cfg.open
				hitpart_picker_cfg.set_visible(hitpart_picker_cfg.open)
			end)
			
			hitpart_picker_icon:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				if hitpart_picker_menu.Visible then
					hitpart_picker_menu.Position = UDim2.new(0, hitpart_picker_icon.AbsolutePosition.X + hitpart_picker_icon.AbsoluteSize.X + 2, 0, hitpart_picker_icon.AbsolutePosition.Y)
				end
			end)
			
			if library.main_frame[1] then
				library.main_frame[1]:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
					if hitpart_picker_menu.Visible then
						hitpart_picker_menu.Position = UDim2.new(0, hitpart_picker_icon.AbsolutePosition.X + hitpart_picker_icon.AbsoluteSize.X + 2, 0, hitpart_picker_icon.AbsolutePosition.Y)
					end
				end)
			end
		end
	end

	local list = library:create("UIListLayout", {
		Parent = right_components,
		Name = "",
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local toggle_keybind = nil
	local toggle_keybind_flag = cfg.flag .. "_keybind"
	
	if cfg.keybind then
		flags[toggle_keybind_flag] = {}
		flags[toggle_keybind_flag].mode = cfg.keybind_mode or "toggle"
		flags[toggle_keybind_flag].key = cfg.keybind_key or nil
		flags[toggle_keybind_flag].active = false
		
		if flags[toggle_keybind_flag].mode == "always" then
			flags[toggle_keybind_flag].active = true
			cfg.set(true)
		end
		
		toggle_keybind = library:create("TextButton", {
			Parent = right_components,
			Name = "",
			LayoutOrder = 0,
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = "ERROR",
			TextStrokeTransparency = 0.5,
			Size = UDim2.new(0, 24, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})
		
		local function keyName(key)
			if not key then return "..." end
			local text = tostring(key) ~= "Enums" and (keys[key] or tostring(key):gsub("Enum.", "")) or nil
			local __text = text and (tostring(text):gsub("KeyCode.", ""):gsub("UserInputType.", ""))
			return __text or "..."
		end
		
		local function update_keybind_text()
			local key = flags[toggle_keybind_flag].key
			local mode = flags[toggle_keybind_flag].mode or "toggle"
			local key_text = keyName(key)
			toggle_keybind.Text = "[" .. string.lower(key_text) .. "]"
		end
		
		local toggle_keybind_content = library:create("Frame", {
			Parent = library.gui,
			Name = "",
			BorderColor3 = Color3.fromRGB(19, 19, 19),
			Size = UDim2.new(0, 57, 0, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BorderSizePixel = 0,
			ZIndex = 2,
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = false,
			BackgroundColor3 = Color3.fromRGB(8, 8, 8),
		})
		
		local function update_toggle_keybind_position()
			if toggle_keybind_content.Visible then
				toggle_keybind_content.Position = UDim2.new(0, toggle_keybind.AbsolutePosition.X, 0, toggle_keybind.AbsolutePosition.Y + 15)
			end
		end
		
		toggle_keybind:GetPropertyChangedSignal("AbsolutePosition"):Connect(update_toggle_keybind_position)
		
		toggle_keybind_content:GetPropertyChangedSignal("Visible"):Connect(function()
			if toggle_keybind_content.Visible then
				update_toggle_keybind_position()
			end
		end)
		
		local toggle_keybind_content_inner = library:create("Frame", {
			Parent = toggle_keybind_content,
			Name = "",
			Position = UDim2.new(0, 2, 0, 2),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			Size = UDim2.new(1, -4, 1, -4),
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})
		
		local toggle_keybind_options = library:create("Frame", {
			Parent = toggle_keybind_content_inner,
			Name = "",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 2, 0, 2),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(1, -4, 1, -4),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		})
		
		local toggle_keybind_uilist = library:create("UIListLayout", {
			Parent = toggle_keybind_options,
			Name = "",
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		
		local toggle_keybind_press = library:create("TextButton", {
			Parent = toggle_keybind_options,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			Text = "toggle",
			TextStrokeTransparency = 0.5,
			Size = UDim2.new(1, 0, 0, 12),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 2, 0, 2),
			BorderSizePixel = 0,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(65, 65, 65),
		})
		
		local toggle_keybind_hold = library:create("TextButton", {
			Parent = toggle_keybind_options,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			Text = "hold",
			TextStrokeTransparency = 0.5,
			Size = UDim2.new(1, 0, 0, 12),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 2, 0, 2),
			BorderSizePixel = 0,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(65, 65, 65),
		})
		
		local toggle_keybind_always = library:create("TextButton", {
			Parent = toggle_keybind_options,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			Text = "always",
			TextStrokeTransparency = 0.5,
			Size = UDim2.new(1, 0, 0, 12),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 2, 0, 2),
			BorderSizePixel = 0,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(65, 65, 65),
		})
		
		local toggle_keybind_padding = library:create("UIPadding", {
			Parent = toggle_keybind_press,
			Name = "",
			PaddingBottom = UDim.new(0, 1),
			PaddingLeft = UDim.new(0, 5),
		})
		
		local toggle_keybind_padding2 = library:create("UIPadding", {
			Parent = toggle_keybind_hold,
			Name = "",
			PaddingBottom = UDim.new(0, 1),
			PaddingLeft = UDim.new(0, 5),
		})
		
		local toggle_keybind_padding3 = library:create("UIPadding", {
			Parent = toggle_keybind_always,
			Name = "",
			PaddingBottom = UDim.new(0, 1),
			PaddingLeft = UDim.new(0, 5),
		})
		
		local toggle_keybind_padding4 = library:create("UIPadding", {
			Parent = toggle_keybind_options,
			Name = "",
			PaddingBottom = UDim.new(0, 4),
		})
		
		local toggle_keybind_selected = nil
		
		if flags[toggle_keybind_flag].mode == "toggle" then
			toggle_keybind_selected = toggle_keybind_press
			toggle_keybind_press.BackgroundTransparency = 0
		elseif flags[toggle_keybind_flag].mode == "hold" then
			toggle_keybind_selected = toggle_keybind_hold
			toggle_keybind_hold.BackgroundTransparency = 0
		elseif flags[toggle_keybind_flag].mode == "always" then
			toggle_keybind_selected = toggle_keybind_always
			toggle_keybind_always.BackgroundTransparency = 0
		end
		
		local function set_toggle_keybind_mode(mode)
			flags[toggle_keybind_flag].mode = mode
			if mode == "always" then
				flags[toggle_keybind_flag].active = true
				cfg.set(true)
			elseif mode == "hold" then
				flags[toggle_keybind_flag].active = false
				cfg.set(false)
			end
		end
		
		toggle_keybind_press.MouseButton1Click:Connect(function()
			if toggle_keybind_selected then
				toggle_keybind_selected.BackgroundTransparency = 1
			end
			toggle_keybind_selected = toggle_keybind_press
			toggle_keybind_press.BackgroundTransparency = 0
			set_toggle_keybind_mode("toggle")
			toggle_keybind_content.Visible = false
		end)
		
		toggle_keybind_hold.MouseButton1Click:Connect(function()
			if toggle_keybind_selected then
				toggle_keybind_selected.BackgroundTransparency = 1
			end
			toggle_keybind_selected = toggle_keybind_hold
			toggle_keybind_hold.BackgroundTransparency = 0
			set_toggle_keybind_mode("hold")
			toggle_keybind_content.Visible = false
		end)
		
		toggle_keybind_always.MouseButton1Click:Connect(function()
			if toggle_keybind_selected then
				toggle_keybind_selected.BackgroundTransparency = 1
			end
			toggle_keybind_selected = toggle_keybind_always
			toggle_keybind_always.BackgroundTransparency = 0
			set_toggle_keybind_mode("always")
			toggle_keybind_content.Visible = false
		end)
		
		local mouse2_connection = nil
		
		toggle_keybind.MouseButton1Click:Connect(function()
			if cfg.binding then
				return
			end
			
			toggle_keybind.Text = "..."
			cfg.binding = true
			
			local binding_connection
			binding_connection = uis.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Keyboard then
					if input.KeyCode == Enum.KeyCode.Escape then
						flags[toggle_keybind_flag].key = nil
						update_keybind_text()
						if binding_connection then
							binding_connection:Disconnect()
							binding_connection = nil
						end
						if mouse2_connection then
							mouse2_connection:Disconnect()
							mouse2_connection = nil
						end
						cfg.binding = nil
						return
					end
					flags[toggle_keybind_flag].key = input.KeyCode
					update_keybind_text()
					if binding_connection then
						binding_connection:Disconnect()
						binding_connection = nil
					end
					if mouse2_connection then
						mouse2_connection:Disconnect()
						mouse2_connection = nil
					end
					cfg.binding = nil
				elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
					flags[toggle_keybind_flag].key = input.UserInputType
					update_keybind_text()
					if binding_connection then
						binding_connection:Disconnect()
						binding_connection = nil
					end
					if mouse2_connection then
						mouse2_connection:Disconnect()
						mouse2_connection = nil
					end
					cfg.binding = nil
				elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
					flags[toggle_keybind_flag].key = input.UserInputType
					update_keybind_text()
					if binding_connection then
						binding_connection:Disconnect()
						binding_connection = nil
					end
					if mouse2_connection then
						mouse2_connection:Disconnect()
						mouse2_connection = nil
					end
					cfg.binding = nil
				elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
					flags[toggle_keybind_flag].key = input.UserInputType
					update_keybind_text()
					if binding_connection then
						binding_connection:Disconnect()
						binding_connection = nil
					end
					if mouse2_connection then
						mouse2_connection:Disconnect()
						mouse2_connection = nil
					end
					cfg.binding = nil
				end
			end)
			
			mouse2_connection = uis.InputBegan:Connect(function(input, game_event)
				if game_event then
					return
				end
				if input.UserInputType == Enum.UserInputType.MouseButton2 and cfg.binding then
					toggle_keybind_content.Visible = false
				end
			end)
			
			if not table.find(library.open_keybind_menus, toggle_keybind_content) then
				table.insert(library.open_keybind_menus, toggle_keybind_content)
			end
		end)
		
		if library.main_frame[1] then
			library.main_frame[1]:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				if toggle_keybind_content.Visible then
					toggle_keybind_content.Position = UDim2.new(0, toggle_keybind.AbsolutePosition.X, 0, toggle_keybind.AbsolutePosition.Y + 15)
				end
			end)
		end
		
		toggle_keybind.MouseButton2Click:Connect(function()
			if cfg.binding then
				return
			end
			toggle_keybind_content.Visible = not toggle_keybind_content.Visible
			if toggle_keybind_content.Visible and not table.find(library.open_keybind_menus, toggle_keybind_content) then
				table.insert(library.open_keybind_menus, toggle_keybind_content)
			end
		end)
		
		update_keybind_text()
		
		library:connection(uis.InputBegan, function(input, game_event)
			if not game_event and flags[toggle_keybind_flag].key then
				local key = flags[toggle_keybind_flag].key
				local mode = flags[toggle_keybind_flag].mode or "toggle"
				
				if input.UserInputType == Enum.UserInputType.Keyboard then
					if input.KeyCode == key then
						if mode == "toggle" then
							flags[toggle_keybind_flag].active = not flags[toggle_keybind_flag].active
							cfg.enabled = flags[toggle_keybind_flag].active
							cfg.set(cfg.enabled)
						elseif mode == "hold" then
							flags[toggle_keybind_flag].active = true
							cfg.set(true)
						end
					end
				else
					if input.UserInputType == key then
						if mode == "toggle" then
							flags[toggle_keybind_flag].active = not flags[toggle_keybind_flag].active
							cfg.enabled = flags[toggle_keybind_flag].active
							cfg.set(cfg.enabled)
						elseif mode == "hold" then
							flags[toggle_keybind_flag].active = true
							cfg.set(true)
						end
					end
				end
			end
		end)
		
		library:connection(uis.InputEnded, function(input, game_event)
			if game_event then
				return
			end
			
			if flags[toggle_keybind_flag].key then
				local key = flags[toggle_keybind_flag].key
				local mode = flags[toggle_keybind_flag].mode or "toggle"
				
				local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
				
				if selected_key == key and mode == "hold" then
					flags[toggle_keybind_flag].active = false
					cfg.set(false)
				end
			end
		end)
	end

	local icon_inline = library:create("TextButton", {
		Parent = object,
		Name = "",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -15, 0.5, 0),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(0, 10, 0, 10),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
		ClipsDescendants = false,
	})

	local icon = library:create("Frame", {
		Parent = icon_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local icon_2 = library:create("Frame", {
		Parent = icon,
		Name = "",
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = themes.preset.accent,
	})
	library:apply_theme(icon_2, "accent", "BackgroundColor3")

	local glow = library:create("ImageLabel", {
		Parent = icon_inline,
		Name = "",
		Visible = false,
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.75,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -12, 0, -12),
		Size = UDim2.new(1, 24, 1, 24),
		ZIndex = 999,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	library:apply_theme(glow, "accent", "ImageColor3")

	local bottom_components = library:create("Frame", {
		Parent = object,
		Name = "",
		Visible = true,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Position = UDim2.new(0, 0, 0, 13),
		Size = UDim2.new(1, 26, 0, 0),
		ZIndex = 2,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local list = library:create("UIListLayout", {
		Parent = bottom_components,
		Name = "",
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	function cfg.set(bool)
		icon_2.Visible = bool
		glow.Visible = bool

		flags[cfg.flag] = bool

		if type(cfg.callback) == "function" then
			pcall(cfg.callback, bool)
		end
	end

	library:connection(object.MouseButton1Click, function()
		cfg.enabled = not cfg.enabled

		cfg.set(cfg.enabled)
	end)

	library:connection(icon_inline.MouseButton1Click, function()
		cfg.enabled = not cfg.enabled

		cfg.set(cfg.enabled)
	end)

	cfg.set(cfg.default)

	self.previous_holder = left_components
	self.bottom_holder = bottom_components
	self.right_holder = right_components

	cfg.holder = left_components
	cfg.right_holder = right_components
	cfg.bottom_holder = bottom_components

	config_flags[cfg.flag] = cfg.set

	return setmetatable(cfg, library)
end

function library:slider(properties)
	local cfg = {
		name = properties.name or nil,
		suffix = properties.suffix or "",
		flag = properties.flag or tostring(2 ^ 789),
		callback = properties.callback or function() end,

		min = properties.min or properties.minimum or 0,
		max = properties.max or properties.maximum or 100,
		intervals = properties.interval or properties.decimal or 1,
		default = properties.default or 10,

		dragging = false,
		value = properties.default or 10,

		previous_holder = self,
	}

	local bottom_components
	if cfg.name then
		object = library:create("TextLabel", {
			Parent = self.holder,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = cfg.name,
			TextStrokeTransparency = 0.5,
			Size = UDim2.new(1, -26, 0, 12),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		bottom_components = library:create("Frame", {
			Parent = object,
			Name = "",
			Visible = true,
			Position = UDim2.new(0, 0, 0, 13),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(1, 26, 0, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		local list = library:create("UIListLayout", {
			Parent = bottom_components,
			Name = "",
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	else
		self.bottom_holder.Parent.AutomaticSize = Enum.AutomaticSize.Y
		self.bottom_holder.Parent.TextYAlignment = Enum.TextYAlignment.Top
	end

	local slider_holder = library:create("Frame", {
		Parent = cfg.name and bottom_components or self.bottom_holder,
		Name = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local slider_inline = library:create("TextButton", {
		Parent = slider_holder,
		Name = "",
		Position = UDim2.new(0, 0, 0, 1),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -26, 0, 8),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local fill_inline = library:create("Frame", {
		Parent = slider_inline,
		Name = "",
		Size = UDim2.new(0.5, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		ZIndex = 2,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(19, 19, 19),
	})

	local fill = library:create("Frame", {
		Parent = fill_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, 0, 1, -4),
		BackgroundColor3 = themes.preset.accent,
	})

	library:apply_theme(fill, "accent", "BackgroundColor3")
	library:apply_theme(fill, "accent", "BorderColor3")

	local VALUE_TEXT = library:create("TextLabel", {
		Parent = fill_inline,
		Name = "",
		RichText = true,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(0, 1, 0, 11),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		FontFace = library.font,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local glow = library:create("ImageLabel", {
		Parent = fill_inline,
		Name = "",
		ImageColor3 = themes.preset.accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -18, 0, -18),
		Size = UDim2.new(1, 36, 1, 36),
		ZIndex = 2,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	library:apply_theme(glow, "accent", "ImageColor3")

	local add = library:create("TextButton", {
		Parent = slider_inline,
		Name = "",
		TextWrapped = true,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "+",
		TextStrokeTransparency = 0.5,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, 5, 0, -1),
		Size = UDim2.new(0, 8, 0, 8),
		FontFace = library.font,
		TextSize = 8,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local sub = library:create("TextButton", {
		Parent = slider_inline,
		Name = "",
		TextWrapped = true,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "-",
		TextStrokeTransparency = 0.5,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -15, 0, -1),
		Size = UDim2.new(0, 8, 0, 8),
		FontFace = library.font,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local slider = library:create("Frame", {
		Parent = slider_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local pad = library:create("UIPadding", {
		Parent = slider_holder,
		Name = "",
		PaddingBottom = UDim.new(0, -17),
	})

	function cfg.set(value)
		if type(value) ~= "number" then
			return
		end

		cfg.value = math.clamp(library:round(value, cfg.intervals), cfg.min, cfg.max)

		fill_inline.Size = dim2((cfg.value - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
		VALUE_TEXT.Text = tostring(cfg.value) .. cfg.suffix
		flags[cfg.flag] = cfg.value

		if type(cfg.callback) == "function" then
			pcall(cfg.callback, flags[cfg.flag])
		end
	end

	library:connection(uis.InputChanged, function(input)
		if cfg.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local size_x = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
			local value = ((cfg.max - cfg.min) * size_x) + cfg.min
			cfg.set(value)
		end
	end)

	library:connection(uis.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			cfg.dragging = false
		end
	end)

	slider_inline.MouseButton1Down:Connect(function()
		cfg.dragging = true
	end)

	add.MouseButton1Down:Connect(function()
		cfg.value += cfg.intervals
		cfg.set(cfg.value)
	end)

	sub.MouseButton1Down:Connect(function()
		cfg.value -= cfg.intervals
		cfg.set(cfg.value)
	end)

	cfg.set(cfg.default)

	config_flags[cfg.flag] = cfg.set

	library.config_flags[cfg.flag] = cfg.set

	return setmetatable(cfg, library)
end

function library:dropdown(properties)
	local cfg = {
		name = properties.name or nil,
		flag = properties.flag or tostring(math.random(1, 9999999)),

		items = properties.items or { "1", "2", "3" },
		callback = properties.callback or function() end,
		multi = properties.multi or false,

		open = false,
		option_instances = {},
		multi_items = {},

		previous_holder = self,
	}
	cfg.default = properties.default or (cfg.multi and { cfg.items[1] }) or cfg.items[1] or nil

	local bottom_components
	local object
	if cfg.name then
		object = library:create("TextLabel", {
			Parent = self.holder,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = cfg.name,
			TextStrokeTransparency = 0.5,
			Size = UDim2.new(1, -26, 0, 12),
			BorderSizePixel = 0,
			ZIndex = 2,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		bottom_components = library:create("Frame", {
			Parent = object,
			Name = "",
			Visible = true,
			Position = UDim2.new(0, 0, 0, 13),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(1, 26, 0, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		local list = library:create("UIListLayout", {
			Parent = bottom_components,
			Name = "",
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	else
		self.bottom_holder.Parent.AutomaticSize = Enum.AutomaticSize.Y
		self.bottom_holder.Parent.TextYAlignment = Enum.TextYAlignment.Top
	end

	local dropdown_inline = library:create("Frame", {
		Parent = cfg.name and bottom_components or self.bottom_holder,
		Name = "",
		Position = UDim2.new(0, -15, 0, 2),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -26, 0, 16),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local dropdown = library:create("TextButton", {
		Parent = dropdown_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "option 1, option 3",
		TextStrokeTransparency = 0.5,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -4, 1, -4),
		Position = UDim2.new(0, 2, 0, 2),
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = dropdown,
		Name = "",
		PaddingLeft = UDim.new(0, 5),
	})

	local icon = library:create("TextLabel", {
		Parent = dropdown,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "+",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.new(1, -6, 0, -1),
		BorderSizePixel = 0,
		TextSize = 8,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local content_inline = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(0, dropdown_inline.AbsoluteSize.X, 0, 0),
		Position = UDim2.new(
			0,
			dropdown_inline.AbsolutePosition.X,
			0,
			dropdown_inline.AbsolutePosition.Y + dropdown_inline.AbsoluteSize.Y + 2
		),
		BorderSizePixel = 0,
		ZIndex = 2,
		Visible = false,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	dropdown_inline:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		content_inline.Position = UDim2.new(
			0,
			dropdown_inline.AbsolutePosition.X,
			0,
			dropdown_inline.AbsolutePosition.Y + dropdown_inline.AbsoluteSize.Y + 2
		)
	end)

	dropdown_inline:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		content_inline.Size = UDim2.new(0, dropdown_inline.AbsoluteSize.X, 0, 0)
	end)
	
	if library.main_frame[1] then
		library.main_frame[1]:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			if content_inline.Visible then
				content_inline.Position = UDim2.new(
					0,
					dropdown_inline.AbsolutePosition.X,
					0,
					dropdown_inline.AbsolutePosition.Y + dropdown_inline.AbsoluteSize.Y + 2
				)
			end
		end)
	end

	local content = library:create("Frame", {
		Parent = content_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local options = library:create("Frame", {
		Parent = content,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -4, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = options,
		Name = "",
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local UIPadding = library:create("UIPadding", {
		Parent = options,
		Name = "",
		PaddingBottom = UDim.new(0, 4),
	})

	function cfg.set_visible(bool)
		content_inline.Visible = bool

		icon.Text = bool and "-" or "+"
		icon.TextSize = bool and 12 or 8

		if cfg.name then
			object.ZIndex = bool and 9999 or 3
		end

		if bool then
			if library.current_element_open and library.current_element_open ~= cfg then
				library.current_element_open.set_visible(false)
				library.current_element_open.open = false
			end

			library.current_element_open = cfg
			if not table.find(library.open_menus, content_inline) then
				table.insert(library.open_menus, content_inline)
			end
		end
	end

	function cfg.set(value)
		local selected = {}

		local is_table = type(value) == "table"

		for _, v in next, cfg.option_instances do
			if v.Text == value or (is_table and table.find(value, v.Text)) then
				table.insert(selected, v.Text)
				cfg.multi_items = selected
				v.BackgroundTransparency = 0
			else
				v.BackgroundTransparency = 1
			end
		end

		dropdown.Text = is_table and table.concat(selected, ",  ") or selected[1] or ""
		flags[cfg.flag] = is_table and selected or selected[1]
		if type(cfg.callback) == "function" then
			pcall(cfg.callback, flags[cfg.flag])
		end
	end

	function cfg:refresh_options(refreshed_list)
		for _, v in next, cfg.option_instances do
			v:Destroy()
		end

		cfg.option_instances = {}

		for i, v in next, refreshed_list do
			local op3 = library:create("TextButton", {
				Parent = options,
				Name = "",
				FontFace = library.font,
				TextColor3 = Color3.fromRGB(170, 170, 170),
				BorderColor3 = Color3.fromRGB(56, 56, 56),
				Text = v,
				BackgroundTransparency = 1,
				TextStrokeTransparency = 0.5,
				Size = UDim2.new(1, 0, 0, 14),
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.new(0, 2, 0, 2),
				BorderSizePixel = 0,
				TextSize = 12,
				BackgroundColor3 = Color3.fromRGB(65, 65, 65),
			})

			local UIPadding = library:create("UIPadding", {
				Parent = op3,
				Name = "",
				PaddingLeft = UDim.new(0, 5),
			})

			table.insert(cfg.option_instances, op3)

			op3.MouseButton1Down:Connect(function()
				if cfg.multi then
					local selected_index = table.find(cfg.multi_items, op3.Text)

					if selected_index then
						table.remove(cfg.multi_items, selected_index)
					else
						table.insert(cfg.multi_items, op3.Text)
					end

					cfg.set(cfg.multi_items)
				else
					cfg.set_visible(false)
					cfg.open = false

					cfg.set(op3.Text)
				end
			end)
		end

		dropdown.Text = ""
	end

	dropdown.MouseButton1Click:Connect(function()
		cfg.open = not cfg.open

		cfg.set_visible(cfg.open)
	end)

	cfg:refresh_options(cfg.items)

	cfg.set(cfg.default)

	library.config_flags[cfg.flag] = cfg.set

	return setmetatable(cfg, library)
end

function library:colorpicker(properties)
	local cfg = {
		name = properties.name or nil,
		flag = properties.flag or tostring(2 ^ 789),
		color = properties.color or properties.default or Color3.new(1, 1, 1),
		alpha = properties.alpha or 1,
		callback = properties.callback or function() end,
		animation = "normal",
		saved_color,
		right_holder = self.right_holder or nil,
		holder = self.holder or nil,
	}

	flags[cfg.flag] = {}

	local dragging_sat = false
	local dragging_hue = false
	local dragging_alpha = false

		local h, s, v = cfg.color:ToHSV()
	local a = cfg.alpha

	local right_components
	if cfg.name then
		local object = library:create("TextLabel", {
			Parent = self.holder,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = cfg.name,
			TextStrokeTransparency = 0.5,
			Size = UDim2.new(1, -26, 0, 12),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		right_components = library:create("Frame", {
			Parent = object,
			Name = "",
			Position = UDim2.new(1, 15, 0, 1),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 0, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

	local list = library:create("UIListLayout", {
			Parent = right_components,
			Name = "",
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 3),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	end

	local icon_inline = library:create("TextButton", {
		Parent = cfg.name and right_components or self.right_holder,
		Name = "",
		Text = "",
		Size = UDim2.new(0, 16, 0, 10),
		Position = UDim2.new(0, -15, 0, 1),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		ZIndex = 3,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(9, 9, 44),
		ClipsDescendants = false,
	})

	local icon = library:create("Frame", {
		Parent = icon_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(22, 22, 108),
		ZIndex = 2,
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(41, 41, 204),
	})

	local glow = library:create("ImageLabel", {
		Parent = icon_inline,
		Name = "",
		ImageColor3 = Color3.fromRGB(41, 41, 204),
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.8999999761581421,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, -20),
		Size = UDim2.new(1, 40, 1, 40),
		ZIndex = 999,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})

	local picker_inline = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		Size = UDim2.new(0, 142, 0, 146),
		Position = dim2(0, icon_inline.AbsolutePosition.X + 1, 0, icon_inline.AbsolutePosition.Y + 17),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		ZIndex = 9999,
		BorderSizePixel = 0,
		Visible = false,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local picker = library:create("Frame", {
		Parent = picker_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local sat_inline = library:create("TextButton", {
		Parent = picker,
		Name = "",
		Text = "",
		Position = UDim2.new(0, 4, 0, 4),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -8, 1, -50),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local sat = library:create("Frame", {
		Parent = sat_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
	})

	local sat_white = library:create("Frame", {
		Parent = sat,
		Name = "",
		Size = UDim2.new(1, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		ZIndex = 2,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIGradient = library:create("UIGradient", {
		Parent = sat_white,
		Name = "",
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
	})

	local sat_black = library:create("Frame", {
		Parent = sat_white,
		Name = "",
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIGradient = library:create("UIGradient", {
		Parent = sat_black,
		Name = "",
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
		}),
	})

	local sat_black_cursor = library:create("Frame", {
		Parent = sat_black,
		Name = "",
		Position = UDim2.new(0.800000011920929, 0, 0.20000000298023224, 0),
		BorderColor3 = Color3.fromRGB(108, 22, 22),
		Size = UDim2.new(0, 1, 0, 1),
		BackgroundColor3 = Color3.fromRGB(204, 41, 41),
	})

	local preview_inline = library:create("Frame", {
		Parent = picker,
		Name = "",
		Position = UDim2.new(1, -20, 1, -20),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(0, 16, 0, 16),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
	})

	local preview = library:create("Frame", {
		Parent = preview_inline,
		Name = "",
		BackgroundTransparency = 0,
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 2,
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(204, 41, 41),
	})

	local preview_image = library:create("ImageLabel", {
		Parent = preview_inline,
		Name = "",
		ScaleType = Enum.ScaleType.Tile,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Image = "http://www.roblox.com/asset/?id=18274452449",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		TileSize = UDim2.new(0, 6, 0, 6),
		BorderSizePixel = 0,
		ZIndex = 3,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local hue_inline = library:create("TextButton", {
		Parent = picker,
		Text = "",
		Name = "",
		Position = UDim2.new(0, 4, 1, -44),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -8, 0, 10),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local hue_border = library:create("Frame", {
		Parent = hue_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local hue = library:create("Frame", {
		Parent = hue_border,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIGradient = library:create("UIGradient", {
		Parent = hue,
		Name = "",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.16699999570846558, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.3330000042915344, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.6669999957084656, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.8330000042915344, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
	})

	local hue_cursor = library:create("Frame", {
		Parent = hue,
		Name = "",
		BorderColor3 = Color3.fromRGB(108, 22, 22),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = Color3.fromRGB(204, 41, 41),
	})

	local input_inline = library:create("Frame", {
		Parent = picker,
		Name = "",
		Position = UDim2.new(0, 4, 1, -20),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -26, 0, 16),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local __input = library:create("TextBox", {
		Parent = input_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "204, 41, 41, 0.5",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(1, -4, 1, -4),
		PlaceholderColor3 = Color3.fromRGB(90, 90, 90),
		Position = UDim2.new(0, 2, 0, 2),
		PlaceholderText = "r, g, b, a",
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local alpha_inline = library:create("TextButton", {
		Parent = picker,
		Name = "",
		Text = "",
		Position = UDim2.new(0, 4, 1, -32),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -8, 0, 10),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local alpha = library:create("Frame", {
		Parent = alpha_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(204, 41, 41),
	})

	local alpha_image = library:create("ImageLabel", {
		Parent = alpha,
		Name = "",
		ScaleType = Enum.ScaleType.Tile,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Image = "http://www.roblox.com/asset/?id=18343135386",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		TileSize = UDim2.new(0, 6, 0, 6),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIGradient = library:create("UIGradient", {
		Parent = alpha_image,
		Name = "",
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
	})

	local alpha_cursor = library:create("Frame", {
		Parent = alpha_image,
		Name = "",
		Position = UDim2.new(0.5, 0, 0, 0),
		BorderColor3 = Color3.fromRGB(108, 22, 22),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = Color3.fromRGB(204, 41, 41),
	})

	local content_inline = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(0, 73, 0, 0),
		Position = dim2(0, icon_inline.AbsolutePosition.X + 20, 0, icon_inline.AbsolutePosition.Y),
		BorderSizePixel = 0,
		ZIndex = 2,
		Visible = false,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local content = library:create("Frame", {
		Parent = content_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local options = library:create("Frame", {
		Parent = content,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -4, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = options,
		Name = "",
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local normal = library:create("TextButton", {
		Parent = options,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "normal",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(1, 0, 0, 12),
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 2, 0, 2),
		BorderSizePixel = 0,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(65, 65, 65),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = normal,
		Name = "",
		PaddingBottom = UDim.new(0, 1),
		PaddingLeft = UDim.new(0, 5),
	})

	local rainbow = library:create("TextButton", {
		Parent = options,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "rainbow",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(1, 0, 0, 12),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 2, 0, 2),
		BorderSizePixel = 0,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(65, 65, 65),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = rainbow,
		Name = "",
		PaddingBottom = UDim.new(0, 1),
		PaddingLeft = UDim.new(0, 5),
	})

	local fade = library:create("TextButton", {
		Parent = options,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "fade",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(1, 0, 0, 12),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 2, 0, 2),
		BorderSizePixel = 0,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(65, 65, 65),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = fade,
		Name = "",
		PaddingBottom = UDim.new(0, 1),
		PaddingLeft = UDim.new(0, 5),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = options,
		Name = "",
		PaddingBottom = UDim.new(0, 4),
	})

	local fade_alpha = library:create("TextButton", {
		Parent = options,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "fade alpha",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(1, 0, 0, 12),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 2, 0, 2),
		BorderSizePixel = 0,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(65, 65, 65),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = fade_alpha,
		Name = "",
		PaddingBottom = UDim.new(0, 1),
		PaddingLeft = UDim.new(0, 5),
	})

	function cfg.set_visible(bool)
		picker_inline.Visible = bool
		content_inline.Visible = false

		if bool then
			if library.current_element_open and library.current_element_open ~= cfg then
				library.current_element_open.set_visible(false)
				library.current_element_open.open = false
			end

			library.current_element_open = cfg
			if not table.find(library.open_menus, picker_inline) then
				table.insert(library.open_menus, picker_inline)
			end
			if not table.find(library.open_menus, content_inline) then
				table.insert(library.open_menus, content_inline)
			end
		else
			picker_inline.Visible = false
			content_inline.Visible = false
		end

		picker_inline.Position = dim2(0, icon_inline.AbsolutePosition.X + 1, 0, icon_inline.AbsolutePosition.Y + 17)
		content_inline.Position = dim2(0, icon_inline.AbsolutePosition.X + 20, 0, icon_inline.AbsolutePosition.Y)
	end

	icon_inline.MouseButton1Click:Connect(function()
		cfg.open = not cfg.open

		cfg.set_visible(cfg.open)
	end)

	icon_inline.MouseButton2Click:Connect(function()
		if cfg.open then
			cfg.open = false
			cfg.set_visible(false)
		end

		content_inline.Visible = not content_inline.Visible

		picker_inline.Position = dim2(0, icon_inline.AbsolutePosition.X + 1, 0, icon_inline.AbsolutePosition.Y + 17)
		content_inline.Position = dim2(0, icon_inline.AbsolutePosition.X + 20, 0, icon_inline.AbsolutePosition.Y)
	end)
	
	icon_inline:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		if picker_inline.Visible or content_inline.Visible then
			picker_inline.Position = dim2(0, icon_inline.AbsolutePosition.X + 1, 0, icon_inline.AbsolutePosition.Y + 17)
			content_inline.Position = dim2(0, icon_inline.AbsolutePosition.X + 20, 0, icon_inline.AbsolutePosition.Y)
		end
	end)
	
	if library.main_frame[1] then
		library.main_frame[1]:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			if picker_inline.Visible or content_inline.Visible then
				picker_inline.Position = dim2(0, icon_inline.AbsolutePosition.X + 1, 0, icon_inline.AbsolutePosition.Y + 17)
				content_inline.Position = dim2(0, icon_inline.AbsolutePosition.X + 20, 0, icon_inline.AbsolutePosition.Y)
			end
		end)
	end

	function cfg.set(color, alpha)
		if color then
			h, s, v = color:ToHSV()
		else
			cfg.saved_color = hsv(s, s, v)
		end

		if alpha then
			a = alpha
		end

		local visual = alpha_inline:FindFirstChildOfClass("Frame")

		if not visual then
			return
		end

		local hsv_position = Color3.fromHSV(h, s, v)
		local Color = Color3.fromHSV(h, s, v)

		local value = h
		local offset = (value < 1) and 0 or -4
		hue_cursor.Position = dim2(value, offset, 0, 0)

		local offset = (a < 1) and 0 or -4
		alpha_cursor.Position = dim2(a, offset, 0, 0)

		visual.BackgroundColor3 = Color
		glow.ImageColor3 = Color

		local RGB_Format = visual.BackgroundColor3

		icon_inline.BackgroundColor3 = Color3.fromRGB(RGB_Format.R / 4, RGB_Format.G / 4, RGB_Format.B / 4)
		icon.BorderColor3 = Color3.fromRGB(
			math.floor((Color.R * 255) + 0.5) / 2,
			math.floor((Color.G * 255) + 0.5) / 2,
			math.floor((Color.B * 255) + 0.5) / 2
		)
		icon.BackgroundColor3 = Color

		__input.Text = math.floor(RGB_Format.R * 255)
			.. ", "
			.. math.floor(RGB_Format.G * 255)
			.. ", "
			.. math.floor(RGB_Format.B * 255)
			.. ", "
			.. library:round(a, 0.01)
		preview.BackgroundColor3 = Color
		preview_image.ImageTransparency = 1 - a

		sat.BackgroundColor3 = Color3.fromHSV(h, 1, 1)

		local s_offset = (s < 1) and 0 or -3
		local v_offset = (1 - v < 1) and 0 or -3
		sat_black_cursor.Position = dim2(s, s_offset, 1 - v, v_offset)

		cfg.color = Color
		cfg.alpha = a

		flags[cfg.flag] = {
			Color = Color,
			Transparency = a,
		}
		cfg.saved_color = hsv(s, s, v)

		if type(cfg.callback) == "function" then
			pcall(cfg.callback, Color, a)
		end
	end

	__input.FocusLost:Connect(function()
		local text = __input.Text
		local r, g, b, a = library:convert_string_rgb(text)

		if r and g and b and a then
			cfg.set(rgb(r, g, b), a)
		end
	end)

	function cfg.update_color()
		local mouse = uis:GetMouseLocation()

		if dragging_sat then
			s = math.clamp(
				(vec2(mouse.X, mouse.Y - gui_offset) - sat_white.AbsolutePosition).X / sat_white.AbsoluteSize.X,
				0,
				1
			)
			v = 1
				- math.clamp(
					(vec2(mouse.X, mouse.Y - gui_offset) - sat_black.AbsolutePosition).Y / sat_black.AbsoluteSize.Y,
					0,
					1
				)
		elseif dragging_hue then
			h = 1
				- math.clamp(
					1
						- (vec2(mouse.X, mouse.Y - gui_offset) - hue_inline.AbsolutePosition).X
							/ hue_inline.AbsoluteSize.X,
					0,
					1
				)
		elseif dragging_alpha then
			a = math.clamp(
				(vec2(mouse.X, mouse.Y - gui_offset) - alpha_inline.AbsolutePosition).X / alpha_inline.AbsoluteSize.X,
				0,
				1
			)
		end

		cfg.set(nil, nil)
	end

	alpha_inline.MouseButton1Down:Connect(function()
		dragging_alpha = true
	end)

	hue_inline.MouseButton1Down:Connect(function()
		dragging_hue = true
	end)

	sat_inline.MouseButton1Down:Connect(function()
		dragging_sat = true
	end)

	cfg.saved_color = hsv(h, s, v)
	local selected = normal
	flags[cfg.flag]["animation"] = "normal"

	rainbow.MouseButton1Down:Connect(function()
		selected.BackgroundTransparency = 1
		selected = "rainbow"
		rainbow.BackgroundTransparency = 0

		flags[cfg.flag]["animation"] = "rainbow"
		cfg.saved_color = hsv(s, s, v)
	end)

	fade_alpha.MouseButton1Down:Connect(function()
		selected.BackgroundTransparency = 1
		selected = "fade_alpha"
		fade_alpha.BackgroundTransparency = 0

		flags[cfg.flag]["animation"] = "fade_alpha"
		cfg.saved_color = hsv(s, s, v)
	end)

	fade.MouseButton1Down:Connect(function()
		selected.BackgroundTransparency = 1
		selected = "fade"
		fade.BackgroundTransparency = 0

		flags[cfg.flag]["animation"] = "fade"
		cfg.saved_color = hsv(s, s, v)
	end)

	normal.MouseButton1Down:Connect(function()
		selected.BackgroundTransparency = 1
		selected = "normal"
		normal.BackgroundTransparency = 0

		flags[cfg.flag]["animation"] = "normal"
		cfg.set(cfg.saved_color)
	end)

	uis.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging_sat = false
			dragging_hue = false
			dragging_alpha = false
		end
	end)

	uis.InputChanged:Connect(function(input)
		if
			(dragging_sat or dragging_hue or dragging_alpha)
			and input.UserInputType == Enum.UserInputType.MouseMovement
		then
			cfg.update_color()
		end
	end)

	cfg.set(cfg.color, cfg.alpha)

	self.previous_holder = parent

	library.config_flags[cfg.flag] = cfg.set

	task.spawn(function()
		while true do
			if (not library) or library.__unloaded then
				break
			end

			if selected ~= "normal" then
				cfg.set(
					hsv(
						selected == "rainbow" and library.sin or h,
						selected == "rainbow" and 1 or s,
						selected == "fade" and library.sin or v
					),
					selected == "fade_alpha" and library.sin
				)
			end
			task.wait()
		end
	end)

	return setmetatable(cfg, library)
end

function library:keybind(properties)
	local cfg = {
		flag = properties.flag or tostring(2 ^ math.random(1, 30) * 3),
		keybind_name = properties.keybind_name or nil,
		callback = properties.callback or function() end,
		open = false,
		binding = nil,
		name = properties.name or nil,
		key = properties.default or properties.key or nil,
		mode = properties.mode or "toggle",
		active = properties.default or false,
		display = properties.displayName or properties.display or properties.name or nil,
		hold_instances = {},
	}

	flags[cfg.flag] = {}

	local key = library:new_keybind({
		text = cfg.display,
		key = cfg.key,
		mode = cfg.mode,
	})

	local right_components
	if cfg.name then
		local object = library:create("TextLabel", {
			Parent = self.holder,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = cfg.name,
			TextStrokeTransparency = 0.5,
			Size = UDim2.new(1, -26, 0, 12),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		right_components = library:create("Frame", {
			Parent = object,
			Name = "",
			Position = UDim2.new(1, 15, 0, 1),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, 0, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})

		local list = library:create("UIListLayout", {
			Parent = right_components,
			Name = "",
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 3),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	end

	local keybind = library:create("TextButton", {
		Parent = cfg.name and right_components or self.right_holder,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = "ERROR",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(0, 16, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local content_inline = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(0, 57, 0, 0),
		Position = dim2(0, keybind.AbsolutePosition.X, 0, keybind.AbsolutePosition.Y - 5),
		BorderSizePixel = 0,
		ZIndex = 2,
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	keybind:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		content_inline.Position = UDim2.new(0, keybind.AbsolutePosition.X, 0, keybind.AbsolutePosition.Y + 15)
	end)

	local content = library:create("Frame", {
		Parent = content_inline,
		Name = "",
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	local options = library:create("Frame", {
		Parent = content,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 2, 0, 2),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, -4, 1, -4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = options,
		Name = "",
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local press = library:create("TextButton", {
		Parent = options,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "toggle",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(1, 0, 0, 12),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 2, 0, 2),
		BorderSizePixel = 0,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(65, 65, 65),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = press,
		Name = "",
		PaddingBottom = UDim.new(0, 1),
		PaddingLeft = UDim.new(0, 5),
	})

	local hold = library:create("TextButton", {
		Parent = options,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "hold",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(1, 0, 0, 12),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 2, 0, 2),
		BorderSizePixel = 0,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(65, 65, 65),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = hold,
		Name = "",
		PaddingBottom = UDim.new(0, 1),
		PaddingLeft = UDim.new(0, 5),
	})

	local always = library:create("TextButton", {
		Parent = options,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "always",
		TextStrokeTransparency = 0.5,
		Size = UDim2.new(1, 0, 0, 12),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 2, 0, 2),
		BorderSizePixel = 0,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(65, 65, 65),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = always,
		Name = "",
		PaddingBottom = UDim.new(0, 1),
		PaddingLeft = UDim.new(0, 5),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = options,
		Name = "",
		PaddingBottom = UDim.new(0, 4),
	})

	function cfg.set_visible(bool)
		content_inline.Visible = bool

		if bool then
			if library.current_element_open and library.current_element_open ~= cfg then
				library.current_element_open.set_visible(false)
				library.current_element_open.open = false
			end

			library.current_element_open = cfg
		end
	end

	function cfg.set_mode(mode)
		cfg.mode = mode

		if mode == "always" then
			cfg.set(true)
		elseif mode == "hold" then
			cfg.set(false)
		end

		flags[cfg.flag] = {
			mode = cfg.mode,
			key = cfg.key,
			active = cfg.active,
		}

		flags[cfg.flag]["mode"] = mode
	end

	function cfg.set(input)
		if type(input) == "boolean" then
			local __cached = input

			if cfg.mode == "always" then
				__cached = true
			end

			cfg.active = __cached
			flags[cfg.flag]["active"] = __cached
			if type(cfg.callback) == "function" then
				pcall(cfg.callback, __cached)
			end

			flags[cfg.flag] = {
				mode = cfg.mode,
				key = cfg.key,
				active = cfg.active,
			}
		elseif tostring(input):find("Enum") then
			input = input.Name == "Escape" and "..." or input

			cfg.key = input or "..."

			local _text = keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")
			local _text2 = (tostring(_text):gsub("KeyCode.", ""):gsub("UserInputType.", "")) or "..."
			cfg.key_name = _text2

			flags[cfg.flag]["mode"] = cfg.mode
			flags[cfg.flag]["key"] = cfg.key

			keybind.Text = "[" .. string.lower(_text2) .. "]"

			if type(cfg.callback) == "function" then
				pcall(cfg.callback, cfg.active or false)
			end

			flags[cfg.flag] = {
				mode = cfg.mode,
				key = cfg.key,
				active = cfg.active,
			}
		elseif table.find({ "toggle", "hold", "always" }, input) then
			cfg.set_mode(input)

			if input == "always" then
				cfg.active = true
			end

			if type(cfg.callback) == "function" then
				pcall(cfg.callback, cfg.active or false)
			end

			flags[cfg.flag] = {
				mode = cfg.mode,
				key = cfg.key,
				active = cfg.active,
			}
		elseif type(input) == "table" then
			input.key = type(input.key) == "string" and input.key ~= "..." and library:convert_enum(input.key)
				or input.key

			input.key = input.key == Enum.KeyCode.Escape and "..." or input.key
			cfg.key = input.key or "..."

			cfg.mode = input.mode or "toggle"

			if input.active then
				cfg.active = input.active
			end

			flags[cfg.flag] = {
				mode = cfg.mode,
				key = cfg.key,
				active = cfg.active,
			}

			local text = tostring(cfg.key) ~= "Enums" and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or nil
			local __text = text and (tostring(text):gsub("KeyCode.", ""):gsub("UserInputType.", ""))

			keybind.Text = "[" .. string.lower(__text) .. "]" or "..."
			cfg.key_name = __text
		end

		if cfg.keybind_name then
			key.change_text(keybind.Text .. " " .. cfg.keybind_name .. " (" .. flags[cfg.flag].mode .. ")")
			key.set_visible(cfg.active)
		end
	end

	local selected
	
	if cfg.mode == "toggle" then
		selected = press
		press.BackgroundTransparency = 0
	elseif cfg.mode == "hold" then
		selected = hold
		hold.BackgroundTransparency = 0
	elseif cfg.mode == "always" then
		selected = always
		always.BackgroundTransparency = 0
	end

	hold.MouseButton1Click:Connect(function()
		if selected then
			selected.BackgroundTransparency = 1
		end
		selected = hold
		hold.BackgroundTransparency = 0

		cfg.set_mode("hold")
		cfg.set_visible(false)
		cfg.open = false

		key.update({
			text = cfg.display,
			key = cfg.key,
			mode = cfg.mode,
		})
	end)

	press.MouseButton1Click:Connect(function()
		if selected then
			selected.BackgroundTransparency = 1
		end
		selected = press
		press.BackgroundTransparency = 0

		cfg.set_mode("toggle")
		cfg.set_visible(false)
		cfg.open = false

		key.update({
			text = cfg.display,
			key = cfg.key,
			mode = cfg.mode,
		})
	end)

	always.MouseButton1Click:Connect(function()
		if selected then
			selected.BackgroundTransparency = 1
		end
		selected = always

		always.BackgroundTransparency = 0
		cfg.set_mode("always")
		cfg.set_visible(false)
		cfg.open = false

		key.update({
			text = cfg.display,
			key = cfg.key,
			mode = cfg.mode,
		})
	end)

	keybind.MouseButton2Click:Connect(function()
		if cfg.binding then
			return
		end
		cfg.open = not cfg.open
		cfg.set_visible(cfg.open)
	end)

	keybind.MouseButton1Click:Connect(function()
		if cfg.binding then
			return
		end
		
		keybind.Text = "..."
		cfg.binding = true

		local binding_connection
		binding_connection = uis.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape then
					cfg.set(nil)
					key.update({
						text = cfg.display,
						key = cfg.key,
						mode = cfg.mode,
					})
					if binding_connection then
						binding_connection:Disconnect()
						binding_connection = nil
					end
					cfg.binding = nil
					return
				end
				cfg.set(input.KeyCode)
				key.update({
					text = cfg.display,
					key = cfg.key,
					mode = cfg.mode,
				})
				if binding_connection then
					binding_connection:Disconnect()
					binding_connection = nil
				end
				cfg.binding = nil
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				cfg.set(input.UserInputType)
				key.update({
					text = cfg.display,
					key = cfg.key,
					mode = cfg.mode,
				})
				if binding_connection then
					binding_connection:Disconnect()
					binding_connection = nil
				end
				cfg.binding = nil
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				cfg.set(input.UserInputType)
				key.update({
					text = cfg.display,
					key = cfg.key,
					mode = cfg.mode,
				})
				if binding_connection then
					binding_connection:Disconnect()
					binding_connection = nil
				end
				cfg.binding = nil
			elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
				cfg.set(input.UserInputType)
				key.update({
					text = cfg.display,
					key = cfg.key,
					mode = cfg.mode,
				})
				if binding_connection then
					binding_connection:Disconnect()
					binding_connection = nil
				end
				cfg.binding = nil
			end
		end)
		
		cfg.binding = binding_connection
	end)

	library:connection(uis.InputBegan, function(input, game_event)
		if not game_event then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == cfg.key then
					if cfg.mode == "toggle" then
						toggled = not toggled
						cfg.set(toggled)
					elseif cfg.mode == "hold" then
						cfg.set(true)
					end
				end
			else
				if input.UserInputType == cfg.key then
					if cfg.mode == "toggle" then
						toggled = not toggled
						cfg.set(toggled)
					elseif cfg.mode == "hold" then
						cfg.set(true)
					end
				end
			end
		end
	end)

	library:connection(uis.InputEnded, function(input, game_event)
		if game_event then
			return
		end

		local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType

		if selected_key == cfg.key then
			if cfg.mode == "hold" then
				cfg.set(false)
			end
		end
	end)

	cfg.set({ mode = cfg.mode, active = cfg.active, key = cfg.key })
	key.update({
		text = cfg.display,
		key = cfg.key,
		mode = cfg.mode,
	})

	library.config_flags[cfg.flag] = cfg.set

	return setmetatable(cfg, library)
end

function library:button(properties)
	local cfg = {
		callback = properties.callback or function() end,
		name = properties.text or properties.name or "Button",
	}

	local button_inline = library:create("Frame", {
		Parent = self.holder,
		Name = "",
		Position = UDim2.new(0, -15, 0, 2),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -26, 0, 16),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local button = library:create("TextButton", {
		Parent = button_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = cfg.name,
		TextStrokeTransparency = 0.5,
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	button.MouseButton1Click:Connect(function()
		if type(cfg.callback) == "function" then
			pcall(cfg.callback)
		end
	end)

	return setmetatable(cfg, library)
end

function library:textbox(properties)
	local cfg = {
		placeholder = properties.placeholder
			or properties.placeholdertext
			or properties.holder
			or properties.holdertext
			or "type here...",
		default = properties.default,
		clear_on_focus = properties.clearonfocus or false,
		flag = properties.flag or "...",
		callback = properties.callback or function() end,
	}

	local textbox_inline = library:create("Frame", {
		Parent = self.holder,
		Name = "",
		Position = UDim2.new(0, -15, 0, 2),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		Size = UDim2.new(1, -26, 0, 16),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
	})

	local textbox = library:create("TextBox", {
		Parent = textbox_inline,
		Name = "",
		FontFace = library.font,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		Text = "",
		TextStrokeTransparency = 0.5,
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		ClearTextOnFocus = cfg.clear_on_focus,
		PlaceholderColor3 = Color3.fromRGB(90, 90, 90),
		CursorPosition = -1,
		PlaceholderText = cfg.placeholder,
		TextSize = 12,
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
	})

	textbox:GetPropertyChangedSignal("Text"):Connect(function()
		flags[cfg.flag] = textbox.Text
		if type(cfg.callback) == "function" then
			pcall(cfg.callback, textbox.Text)
		end
	end)

	function cfg.set(text)
		flags[cfg.flag] = text
		textbox.Text = text
	if type(cfg.callback) == "function" then
		pcall(cfg.callback, text)
	end
	end

	if cfg.default then
		cfg.set(cfg.default)
	end

	library.config_flags[cfg.flag] = cfg.set

	return setmetatable(cfg, library)
end

function library:panel(properties)
	if library.__panel == true then
		return
	end

	library.__panel = true

	local cfg = {
		name = properties.name or "Are you sure?",
		options = properties.options or { "Confirm", "Discard" },
		callback = properties.callback or function() end,
	}

	local panel_main_frame = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		BackgroundTransparency = 1, -- remove dimmed overlay
		Size = UDim2.new(1, 0, 1, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 100000,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})

	local holder = library:create("Frame", {
		Parent = panel_main_frame,
		Name = "",
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = 100001,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})

	local inline1 = library:create("Frame", {
		Parent = holder,
		Name = "",
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		AutomaticSize = Enum.AutomaticSize.XY,
		ZIndex = 100002,
		BackgroundColor3 = Color3.fromRGB(56, 56, 56),
	})

	local main = library:create("Frame", {
		Parent = inline1,
		Name = "",
		Position = UDim2.new(0, 4, 0, 4),
		BorderColor3 = Color3.fromRGB(26, 26, 26),
		Size = UDim2.new(1, -8, 1, -8),
		BorderSizePixel = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})

	local UIStroke = library:create("UIStroke", {
		Parent = main,
		Name = "",
		Color = Color3.fromRGB(57, 57, 57),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local tabs = library:create("Frame", {
		Parent = main,
		Name = "",
		Position = UDim2.new(0, 8, 0, 8),
		BorderColor3 = Color3.fromRGB(8, 8, 8),
		Size = UDim2.new(1, -16, 1, -16),
		BorderSizePixel = 2,
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	})

	local UIStroke = library:create("UIStroke", {
		Parent = tabs,
		Name = "",
		Color = Color3.fromRGB(57, 57, 57),
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	local UIPadding = library:create("UIPadding", {
		Parent = tabs,
		Name = "",
		PaddingTop = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 22),
		PaddingRight = UDim.new(0, 20),
		PaddingLeft = UDim.new(0, 20),
	})

	local aimbot = library:create("TextLabel", {
		Parent = tabs,
		Name = "",
		FontFace = library.font,
		LineHeight = 1.2000000476837158,
		TextStrokeTransparency = 0.5,
		AnchorPoint = Vector2.new(0.5, 0),
		TextSize = 12,
		Size = UDim2.new(0, 0, 0, 11),
		TextColor3 = Color3.fromRGB(170, 170, 170),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = cfg.name,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 8),
		BorderSizePixel = 0,
		TextYAlignment = Enum.TextYAlignment.Top,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = aimbot,
		Name = "",
		PaddingTop = UDim.new(0, 6),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = tabs,
		Name = "",
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 4),
	})

	local Frame = library:create("Frame", {
		Parent = tabs,
		Name = "",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})

	local UIListLayout = library:create("UIListLayout", {
		Parent = Frame,
		Name = "",
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 3),
	})

	local UIPadding = library:create("UIPadding", {
		Parent = Frame,
		Name = "",
	})

	for _, v in next, cfg.options do
		local button_inline = library:create("Frame", {
			Parent = Frame,
			Name = "",
			Position = UDim2.new(0, 0, 0, 4),
			BorderColor3 = Color3.fromRGB(19, 19, 19),
			Size = UDim2.new(0, 130, 0, 16),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(8, 8, 8),
		})

		local button = library:create("TextButton", {
			Parent = button_inline,
			Name = "",
			FontFace = library.font,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			Text = v,
			TextStrokeTransparency = 0.5,
			Position = UDim2.new(0, 2, 0, 2),
			Size = UDim2.new(1, -4, 1, -4),
			TextSize = 12,
			BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		})

		button.MouseButton1Click:Connect(function()
			if type(cfg.callback) == "function" then
				pcall(cfg.callback, v)
			end
			panel_main_frame:Destroy()
			library.__panel = false
		end)
	end
end

return library
