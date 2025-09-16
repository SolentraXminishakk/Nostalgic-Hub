-- use this for wtv Idrk

-- NostalgicUILib.lua
-- Single ModuleScript UI library built from your Gui-to-Lua export.
-- Usage:
-- local lib = require(<this module>)
-- lib:start()
-- local tab = lib:CreateTab("Example")
-- tab:CreateButton({Name="Hi", Callback=function() print("clicked") end})
-- lib:AddThemes(<dropdownMenuOrMenuFrame>) -- populates menu with themes found in workspace.Themes

local NostalgicUILib = {}
NostalgicUILib.__index = NostalgicUILib

local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Config
local SCREENGUI_NAME = "NostalgicMM2_LibGUI"
local THEME_FOLDER_NAME = "NostalgicThemes" -- folder in workspace to search for themes

-- internal helpers
local function rgbFromString(s)
	-- Accepts "r,g,b" or Color3
	if typeof(s) == "Color3" then return s end
	if type(s) ~= "string" then return Color3.fromRGB(255,255,255) end
	local a,b,c = s:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
	if a and b and c then
		return Color3.fromRGB(tonumber(a), tonumber(b), tonumber(c))
	end
	-- fallback
	return Color3.fromRGB(255,255,255)
end

local function makeUICorner(parent, radius)
	local u = Instance.new("UICorner")
	u.CornerRadius = UDim.new(0, radius or 6)
	u.Parent = parent
	return u
end

local function createTextLabel(props)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	for k,v in pairs(props or {}) do
		if k ~= "Parent" then
			pcall(function() lbl[k] = v end)
		else
			lbl.Parent = v
		end
	end
	return lbl
end

-- Create the base ScreenGui and a single Tab container
function NostalgicUILib:start(parent)
	parent = parent or Players.LocalPlayer:WaitForChild("PlayerGui")
	-- if already created, return existing
	if self._gui and self._gui.Parent then return self._gui end

	local screen = Instance.new("ScreenGui")
	screen.Name = SCREENGUI_NAME
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.Parent = parent

	-- Topbar container (compact single-tab style)
	local topbar = Instance.new("Frame")
	topbar.Name = "TabNameTopbar"
	topbar.Parent = screen
	topbar.BackgroundColor3 = Color3.fromRGB(35,35,35)
	topbar.BorderSizePixel = 0
	topbar.Position = UDim2.new(0.015,0,0.0246,-2)
	topbar.Size = UDim2.new(0,236,0,50)
	makeUICorner(topbar, 12)

	local title = createTextLabel{
		Parent = topbar,
		Font = Enum.Font.Nunito,
		Text = "TABNAME HERE",
		TextColor3 = Color3.new(1,1,1),
		TextSize = 25,
		Size = UDim2.new(0,235,0,25),
		Position = UDim2.new(0.0042,0,0.24,0)
	}

	local uif = Instance.new("Frame")
	uif.Name = "UICornerFix"
	uif.Parent = topbar
	uif.BackgroundColor3 = Color3.fromRGB(35,35,35)
	uif.BorderSizePixel = 0
	uif.Position = UDim2.new(0,0,0.74,0)
	uif.Size = UDim2.new(0,236,0,14)

	local mainTab = Instance.new("Frame")
	mainTab.Name = "TabName"
	mainTab.Parent = topbar
	mainTab.BackgroundColor3 = Color3.fromRGB(25,25,25)
	mainTab.BorderSizePixel = 0
	mainTab.Position = UDim2.new(0,0,1,0)
	mainTab.Size = UDim2.new(0,236,0,372)
	makeUICorner(mainTab, 12)

	-- section container in tab
	local section = Instance.new("Frame")
	section.Name = "SectionName"
	section.Parent = mainTab
	section.BackgroundColor3 = Color3.fromRGB(15,15,15)
	section.BorderSizePixel = 0
	section.Position = UDim2.new(0.0425,0,0.0248,0)
	section.Size = UDim2.new(0,216,0,47)
	makeUICorner(section, 6)

	local sectionLabel = createTextLabel{
		Parent = section,
		Font = Enum.Font.Roboto,
		Text = "my section name",
		TextColor3 = Color3.new(1,1,1),
		TextSize = 20,
		Position = UDim2.new(0.069,0,0.2187,0),
		Size = UDim2.new(0,182,0,25)
	}

	local sectionBody = Instance.new("Frame")
	sectionBody.Name = "SectionNameBody"
	sectionBody.Parent = section
	sectionBody.BackgroundColor3 = Color3.fromRGB(25,25,25)
	sectionBody.BorderSizePixel = 0
	sectionBody.Position = UDim2.new(-0.0463,0,1.1276,0)
	sectionBody.Size = UDim2.new(0,234,0,302)

	local layout = Instance.new("UIListLayout")
	layout.Parent = sectionBody
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0,6)

	self._gui = screen
	self._root = {
		Screen = screen,
		Topbar = topbar,
		Title = title,
		MainTab = mainTab,
		Section = section,
		SectionBody = sectionBody,
		Layout = layout,
	}
	self._tabs = {}
	self._theme = nil

	return self
end

-- internal factory helpers for common controls
local function makeButton(name)
	local btn = Instance.new("TextButton")
	btn.Name = "Button"
	btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
	btn.BorderSizePixel = 0
	btn.Size = UDim2.new(0,183,0,39)
	btn.Font = Enum.Font.Roboto
	btn.Text = name or "Button"
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextSize = 20
	makeUICorner(btn,4)
	-- ripple effect
	btn.AutoButtonColor = false
	btn.MouseButton1Down:Connect(function(x,y)
		local absolutePosition = btn.AbsolutePosition
		local absoluteSize = btn.AbsoluteSize
		local relativeX = (x - absolutePosition.X) / absoluteSize.X
		local relativeY = (y - absolutePosition.Y) / absoluteSize.Y
		relativeX = math.clamp(relativeX,0,1)
		relativeY = math.clamp(relativeY,0,1)

		local ripple = Instance.new("Frame")
		ripple.BackgroundTransparency = 1
		ripple.Size = UDim2.new(1,0,1,0)
		ripple.ClipsDescendants = true
		ripple.ZIndex = btn.ZIndex + 1
		ripple.Parent = btn

		local rippleCircle = Instance.new("Frame")
		rippleCircle.AnchorPoint = Vector2.new(0.5,0.5)
		rippleCircle.Position = UDim2.new(relativeX,0,relativeY - 0.4,0)
		rippleCircle.Size = UDim2.new(0,0,0,0)
		rippleCircle.BackgroundColor3 = Color3.fromRGB(230,230,230)
		rippleCircle.BackgroundTransparency = 0.8
		rippleCircle.BorderSizePixel = 0
		makeUICorner(rippleCircle,999)
		rippleCircle.Parent = ripple

		local maxSize = math.sqrt(absoluteSize.X^2 + absoluteSize.Y^2)
		local targetSize = UDim2.new(0, maxSize, 0, maxSize)
		local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local scaleTween = TweenService:Create(rippleCircle, tweenInfo, {Size = targetSize})
		local fadeTween = TweenService:Create(rippleCircle, tweenInfo, {BackgroundTransparency = 1})
		scaleTween:Play()
		fadeTween:Play()
		fadeTween.Completed:Connect(function() ripple:Destroy() end)
	end)

	return btn
end

local function makeInput(name, placeholder)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0,237,0,39)
	frame.BackgroundTransparency = 1

	local txt = Instance.new("TextBox")
	txt.Name = "InputBox"
	txt.Parent = frame
	txt.BackgroundColor3 = Color3.fromRGB(30,30,30)
	txt.BorderSizePixel = 0
	txt.ClipsDescendants = true
	txt.Position = UDim2.new(0.6455,0,0.1025,0)
	txt.Size = UDim2.new(0,74,0,30)
	txt.ClearTextOnFocus = false
	txt.Font = Enum.Font.Roboto
	txt.PlaceholderColor3 = Color3.fromRGB(255,255,255)
	txt.PlaceholderText = placeholder or "..."
	txt.Text = ""
	txt.TextColor3 = Color3.new(1,1,1)
	txt.TextSize = 16

	local label = createTextLabel{
		Parent = frame,
		Font = Enum.Font.SourceSans,
		Text = name or "Input",
		TextSize = 18,
		Position = UDim2.new(0.0084,0,0.1794,0),
		Size = UDim2.new(0,139,0,23)
	}
	return frame, txt
end

local function makeKeybind(name)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0,237,0,39)
	frame.BackgroundTransparency = 1

	local box = Instance.new("TextBox")
	box.Name = "KeybindBox"
	box.Parent = frame
	box.BackgroundColor3 = Color3.fromRGB(30,30,30)
	box.BorderSizePixel = 0
	box.ClipsDescendants = true
	box.Position = UDim2.new(0.6455,0,0.1025,0)
	box.Size = UDim2.new(0,74,0,30)
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.Roboto
	box.Text = "None"
	box.TextColor3 = Color3.new(1,1,1)
	box.TextSize = 16

	local label = createTextLabel{
		Parent = frame,
		Font = Enum.Font.SourceSans,
		Text = name or "Keybind",
		TextSize = 18,
		Position = UDim2.new(0,0,0.2051,0),
		Size = UDim2.new(0,153,0,21)
	}

	return frame, box
end

local function makeSlider(name, minv, maxv, default)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0,237,0,39)
	frame.BackgroundTransparency = 1

	local label = createTextLabel{
		Parent = frame,
		Font = Enum.Font.SourceSans,
		Text = name or "Slider",
		TextSize = 18,
		Position = UDim2.new(0,0,-0.0769,0),
		Size = UDim2.new(0,153,0,22)
	}

	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Parent = frame
	background.Position = UDim2.new(0.0485,0,0.4871,0)
	background.Size = UDim2.new(0,215,0,15)
	background.BorderSizePixel = 0

	makeUICorner(background,5)

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Parent = background
	fill.BackgroundColor3 = Color3.fromRGB(0,0,0)
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new(0,0,0,15)
	makeUICorner(fill,5)

	local trigger = Instance.new("TextButton")
	trigger.Name = "Trigger"
	trigger.Parent = background
	trigger.Size = UDim2.new(0,215,0,15)
	trigger.BackgroundTransparency = 1
	trigger.Text = ""
	trigger.BorderSizePixel = 0

	local amount = Instance.new("TextLabel")
	amount.Name = "Amount"
	amount.Parent = background
	amount.Size = UDim2.new(0,215,0,15)
	amount.BackgroundTransparency = 1
	amount.Font = Enum.Font.SourceSans
	amount.Text = tostring(default or 0)
	amount.TextColor3 = Color3.fromRGB(143,0,2)
	amount.TextSize = 18

	-- slider state
	local MIN_VALUE = minv or 0
	local MAX_VALUE = maxv or 100
	local currentValue = default or MIN_VALUE
	local dragging = false

	local function getValueFromX(x)
		local bgAbsPos = background.AbsolutePosition.X
		local bgAbsSize = background.AbsoluteSize.X
		local rel = math.clamp((x - bgAbsPos) / bgAbsSize, 0, 1)
		return MIN_VALUE + rel * (MAX_VALUE - MIN_VALUE), rel
	end

	local function updateVisuals(val, rel)
		currentValue = val
		fill.Size = UDim2.new(rel, 0, 1, 0)
		local trigX = rel
		trigger.Position = UDim2.new(trigX, -trigger.AbsoluteSize.X/2, 0.5, -trigger.AbsoluteSize.Y/2)
		amount.Text = tostring(math.floor(val))
	end

	-- mouse handlers
	trigger.MouseButton1Down:Connect(function()
		dragging = true
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	RunService.RenderStepped:Connect(function()
		if dragging then
			local m = UIS:GetMouseLocation()
			local val, rel = getValueFromX(m.X)
			updateVisuals(val, rel)
		end
	end)

	-- initialise
	updateVisuals(default or MIN_VALUE, ((default or MIN_VALUE) - MIN_VALUE) / (MAX_VALUE - MIN_VALUE + 0.0001))

	return frame, function() return currentValue end, function(v) updateVisuals(v, ((v-MIN_VALUE)/(MAX_VALUE-MIN_VALUE)) ) end
end

local function makeToggle(name, default)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0,237,0,38)
	frame.BackgroundTransparency = 1

	local bg = Instance.new("Frame")
	bg.Name = "BackgroundToggle"
	bg.Parent = frame
	bg.BackgroundColor3 = Color3.fromRGB(45,45,45)
	bg.BorderSizePixel = 0
	bg.Position = UDim2.new(0.5614,0,0.0812,0)
	bg.Size = UDim2.new(0,93,0,30)
	makeUICorner(bg,5)

	local trigger = Instance.new("TextButton")
	trigger.Name = "trigger"
	trigger.Parent = bg
	trigger.Size = UDim2.new(0,110,0,30)
	trigger.BackgroundTransparency = 1
	trigger.Text = ""
	trigger.BorderSizePixel = 0

	local indicator = Instance.new("Frame")
	indicator.Name = "ToggleIndicator"
	indicator.Parent = bg
	indicator.BackgroundColor3 = Color3.fromRGB(144,0,0)
	indicator.Size = UDim2.new(0,40,0,22)
	indicator.Position = UDim2.new(0.0707,0,0.1052,0)
	makeUICorner(indicator,4)

	local label = createTextLabel{
		Parent = bg,
		Font = Enum.Font.SourceSans,
		Text = name or "Toggle",
		TextSize = 22,
		Position = UDim2.new(-1.3134,0,-0.0557,0),
		Size = UDim2.new(0,109,0,30)
	}

	local State = default and true or false

	local function updateScreen()
		if State then
			indicator:TweenPosition(UDim2.new(0.479,0,0.105,0), "Out", "Linear", 0.2, true)
			indicator.BackgroundColor3 = Color3.fromRGB(252,252,252)
		else
			indicator:TweenPosition(UDim2.new(0.071,0,0.105,0), "In", "Linear", 0.2, true)
			indicator.BackgroundColor3 = Color3.fromRGB(65,182,255)
		end
	end
	updateScreen()

	trigger.MouseButton1Down:Connect(function()
		State = not State
		updateScreen()
	end)

	return frame, function() return State end, function(v) State = v updateScreen() end
end

local function makeDropdown(name, options)
	local btn = Instance.new("TextButton")
	btn.Name = "MyDropdownMenu"
	btn.Size = UDim2.new(0,200,0,32)
	btn.Font = Enum.Font.SourceSans
	btn.Text = name or "Dropdown"
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextSize = 21
	btn.BackgroundColor3 = Color3.fromRGB(34,34,34)
	btn.BorderSizePixel = 0

	local menu = Instance.new("Frame")
	menu.Name = "MenuFrame"
	menu.Parent = btn
	menu.BackgroundColor3 = Color3.fromRGB(14,14,14)
	menu.BackgroundTransparency = 1
	menu.BorderSizePixel = 0
	menu.Position = UDim2.new(0,0,1,0)
	menu.Size = UDim2.new(0,200,0,5)
	menu.Visible = false

	local list = Instance.new("UIListLayout")
	list.Parent = menu
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder

	local open = false
	btn.AutoButtonColor = false
	btn.MouseButton1Click:Connect(function()
		if open then
			-- fade out
			for _,obj in pairs(menu:GetDescendants()) do
				if obj:IsA("TextLabel") or obj:IsA("TextButton") then
					pcall(function() TweenService:Create(obj, TweenInfo.new(0.2), {TextTransparency = 1}):Play() end)
				elseif obj:IsA("Frame") then
					pcall(function() TweenService:Create(obj, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end)
				end
			end
			task.delay(0.2, function() menu.Visible = false end)
		else
			menu.Visible = true
			for _,obj in pairs(menu:GetDescendants()) do
				if obj:IsA("TextLabel") or obj:IsA("TextButton") then
					pcall(function() obj.TextTransparency = 1 end)
					pcall(function() TweenService:Create(obj, TweenInfo.new(0.2), {TextTransparency = 0}):Play() end)
				elseif obj:IsA("Frame") then
					pcall(function() obj.BackgroundTransparency = 1 end)
					pcall(function() TweenService:Create(obj, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play() end)
				end
			end
		end
		open = not open
	end)

	return btn, menu
end

-- Create a top-level tab: returns Tab object (table) with builder methods
function NostalgicUILib:CreateTab(name)
	assert(self._root, "Call :start() first")
	local tab = {}
	tab.Name = name or "Tab"
	tab._parent = self._root.SectionBody

	-- create a small section label frame to clone visually
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(0,234,0,0) -- height will be auto
	container.Parent = tab._parent

	local layout = Instance.new("UIListLayout")
	layout.Parent = container
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0,6)

	-- builders
	function tab:CreateButton(opts)
		opts = opts or {}
		local btn = makeButton(opts.Name or "Button")
		btn.Parent = container
		if opts.Callback then
			btn.MouseButton1Click:Connect(function() pcall(opts.Callback) end)
		end
		return btn
	end

	function tab:CreateInput(opts)
		opts = opts or {}
		local frame, textbox = makeInput(opts.Name or "Input", opts.Default or "...")
		frame.Parent = container
		if opts.Callback then
			textbox.FocusLost:Connect(function(enterPressed)
				pcall(opts.Callback, textbox.Text)
			end)
		end
		return frame, textbox
	end

	function tab:CreateKeybind(opts)
		opts = opts or {}
		local frame, box = makeKeybind(opts.Name or "Keybind")
		frame.Parent = container
		local chosenKey = opts.Default or nil

		local captureConn
		box.Focused:Connect(function()
			box.Text = "..."
			if captureConn then captureConn:Disconnect(); captureConn = nil end
			captureConn = UIS.InputBegan:Connect(function(input, gpe)
				if gpe then return end
				if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
				box:ReleaseFocus()
				chosenKey = input.KeyCode
				box.Text = chosenKey.Name
				captureConn:Disconnect()
				captureConn = nil
			end)
		end)

		if opts.Callback then
			UIS.InputBegan:Connect(function(input, gpe)
				if gpe then return end
				if not chosenKey then return end
				if input.KeyCode == chosenKey then
					pcall(opts.Callback)
				end
			end)
		end

		return frame, box
	end

	function tab:CreateSlider(opts)
		opts = opts or {}
		local minv = opts.Min or 0
		local maxv = opts.Max or 100
		local def = opts.Default or minv
		local frame, getValue, setValue = makeSlider(opts.Name or "Slider", minv, maxv, def)
		frame.Parent = container
		if opts.Callback then
			-- poll value every RenderStepped while dragging to call callback when changed
			local prev = getValue()
			RunService.RenderStepped:Connect(function()
				local cur = getValue()
				if cur ~= prev then
					prev = cur
					pcall(opts.Callback, cur)
				end
			end)
		end
		return frame, getValue, setValue
	end

	function tab:CreateToggle(opts)
		opts = opts or {}
		local frame, getter, setter = makeToggle(opts.Name or "Toggle", opts.Default)
		frame.Parent = container
		if opts.Callback then
			-- watcher
			spawn(function()
				local last = getter()
				while frame.Parent do
					local cur = getter()
					if cur ~= last then
						pcall(opts.Callback, cur)
						last = cur
					end
					task.wait(0.12)
				end
			end)
		end
		return frame, getter, setter
	end

	function tab:CreateDropdown(opts)
		opts = opts or {}
		local btn, menu = makeDropdown(opts.Name or "Dropdown")
		btn.Parent = container
		-- If user passed Options table, add TextButtons for each option
		if opts.Options and type(opts.Options) == "table" then
			for i,opt in ipairs(opts.Options) do
				local childBtn = Instance.new("TextButton")
				childBtn.Size = UDim2.new(0,200,0,28)
				childBtn.Font = Enum.Font.SourceSans
				childBtn.Text = tostring(opt)
				childBtn.TextColor3 = Color3.new(1,1,1)
				childBtn.TextSize = 18
				childBtn.BackgroundColor3 = Color3.fromRGB(46,46,46)
				childBtn.BorderSizePixel = 0
				childBtn.Parent = menu
				childBtn.MouseButton1Click:Connect(function()
					if opts.Callback then pcall(opts.Callback, opt) end
				end)
			end
		end
		return btn, menu
	end

	setmetatable(tab, { __index = tab })
	table.insert(self._tabs, tab)
	return tab
end

-- Apply a theme table to the GUI. themeTable keys expected like "BackgroundTabColor" = "r,g,b" or Color3
function NostalgicUILib:ApplyTheme(themeTable)
	if not self._gui then return end
	if type(themeTable) ~= "table" then return end
	self._theme = themeTable

	-- Map keys to GUI elements we built
	local root = self._root
	-- safe pcall per assignment
	pcall(function()
		if themeTable.BackgroundTabColor then root.Topbar.BackgroundColor3 = rgbFromString(themeTable.BackgroundTabColor) end
		if themeTable.BackgroundTopbarColor then root.MainTab.BackgroundColor3 = rgbFromString(themeTable.BackgroundTopbarColor) end
		if themeTable.ButtonBackgroundColor then
			-- set all Buttons default
			for _,b in pairs(self._gui:GetDescendants()) do
				if b:IsA("TextButton") and b.Name ~= "Trigger" then
					b.BackgroundColor3 = rgbFromString(themeTable.ButtonBackgroundColor)
				end
			end
		end
		if themeTable.ButtonTextColor then
			for _,b in pairs(self._gui:GetDescendants()) do
				if b:IsA("TextButton") or b:IsA("TextLabel") then
					-- avoid overwriting section label etc: this is coarse, you can refine later
					b.TextColor3 = rgbFromString(themeTable.ButtonTextColor)
				end
			end
		end
		if themeTable.SliderFillColor then
			for _,f in pairs(self._gui:GetDescendants()) do
				if f.Name == "Fill" and f:IsA("Frame") then
					f.BackgroundColor3 = rgbFromString(themeTable.SliderFillColor)
				end
			end
		end
		if themeTable.SliderBackgroundColor then
			for _,f in pairs(self._gui:GetDescendants()) do
				if f.Name == "Background" and f:IsA("Frame") then
					f.BackgroundColor3 = rgbFromString(themeTable.SliderBackgroundColor)
				end
			end
		end
		if themeTable.SliderTextColor then
			for _,lbl in pairs(self._gui:GetDescendants()) do
				if lbl:IsA("TextLabel") and lbl.Name == "Amount" then
					lbl.TextColor3 = rgbFromString(themeTable.SliderTextColor)
				end
			end
		end
	end)
end

-- AddThemes: populate a dropdown/menu with toggles for each theme found in workspace.THEME_FOLDER_NAME
-- Accepts either:
--  - a dropdown button (created by CreateDropdown) whose MenuFrame is the parent MenuFrame,
--  - OR directly a MenuFrame (Frame) to populate
-- For each theme found, a toggle will be created and hooking it ON will apply the theme.
function NostalgicUILib:AddThemes(dropdownOrMenuFrame)
	assert(self._gui, "Call :start() first")
	-- detect menu frame
	local menuFrame
	if typeof(dropdownOrMenuFrame) == "Instance" and dropdownOrMenuFrame.ClassName == "Frame" then
		menuFrame = dropdownOrMenuFrame
	elseif typeof(dropdownOrMenuFrame) == "Instance" and dropdownOrMenuFrame:IsA("TextButton") then
		menuFrame = dropdownOrMenuFrame:FindFirstChild("MenuFrame")
	end
	if not menuFrame then
		error("AddThemes expects a MenuFrame or dropdown button from CreateDropdown")
		return
	end

	-- find or create theme folder in workspace
	local themeFolder = Workspace:FindFirstChild(THEME_FOLDER_NAME)
	if not themeFolder then
		themeFolder = Instance.new("Folder")
		themeFolder.Name = THEME_FOLDER_NAME
		themeFolder.Parent = Workspace
	end

	-- collect themes
	local themes = {} -- {name = table}
	for _,v in pairs(themeFolder:GetChildren()) do
		if v:IsA("ModuleScript") then
			-- require module safely
			local ok, t = pcall(function() return require(v) end)
			if ok and type(t) == "table" then
				themes[v.Name] = t
			end
		elseif v:IsA("StringValue") or v:IsA("ObjectValue") or v:IsA("Configuration") then
			-- if StringValue contains source or serialized table, attempt parse
			if v:IsA("StringValue") then
				local src = v.Value
				-- attempt loadstring
				local ok, fn = pcall(loadstring or function() return nil end, src)
				if ok and type(fn) == "function" then
					local success, out = pcall(fn)
					if success and type(out) == "table" then
						themes[v.Name] = out
					end
				end
			end
		end
	end

	if next(themes) == nil then
		local defaultTheme = {
			BackgroundTabColor = "25, 25, 25",
			BackgroundTopbarColor = "35, 35, 35",
			ButtonTextColor = "255,255,255",
			ButtonBackgroundColor = "45, 45, 45",
			SliderTextColor = "143, 0, 2",
			SliderFillColor = "0, 0, 0",
			SliderBackgroundColor = "255, 255, 255",
            SliderBackgroundTextColor = "255, 255, 255",
            DropdownToggleBackgroundColor = "34, 34, 34",
            ToggleIndicatorEnabled = "0, 144, 0",
            ToggleIndicatorDisabled = "144, 0, 0",
            KeybindBackgroundTextColor = "255, 255, 255",
            KeybindTextColor = "255, 255, 255,",
            KeybindBackgroundColor = "30, 30, 30",
            
		}
		local mod = Instance.new("ModuleScript")
		mod.Name = "Default"
		local s = "return " .. game:GetService("HttpService"):JSONEncode(defaultTheme)
		local bodyParts = {}
		table.insert(bodyParts, "local t = {}")
		for k,v in pairs(defaultTheme) do
			table.insert(bodyParts, ("t[%q] = %q"):format(k, v))
		end
		table.insert(bodyParts, "return t")
		mod.Source = table.concat(bodyParts, "\n")
		mod.Parent = themeFolder
		themes["Default"] = defaultTheme
	end

	-- clear any existing menu children
	for _,c in pairs(menuFrame:GetChildren()) do
		if not c:IsA("UIListLayout") then
			pcall(function() c:Destroy() end)
		end
	end

	-- create toggles for each theme (one active at a time)
	local activeThemeName
	local function createThemeToggle(name, tableData)
		local btn = Instance.new("Frame")
		btn.Size = UDim2.new(0,200,0,28)
		btn.BackgroundColor3 = Color3.fromRGB(46,46,46)
		btn.BorderSizePixel = 0
		btn.Parent = menuFrame
		local lbl = Instance.new("TextLabel")
		lbl.Parent = btn
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(0,150,0,28)
		lbl.Position = UDim2.new(0.01,0,0,0)
		lbl.Font = Enum.Font.SourceSans
		lbl.Text = name
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.TextSize = 18

		-- small toggle on right
		local toggleFrame = Instance.new("Frame")
		toggleFrame.Parent = btn
		toggleFrame.Size = UDim2.new(0,40,0,22)
		toggleFrame.Position = UDim2.new(0.72,0,0.12,0)
		toggleFrame.BackgroundColor3 = Color3.fromRGB(65,182,255)
		makeUICorner(toggleFrame,4)

		local toggled = false
		local function setState(v)
			toggled = v
			if v then
				toggleFrame.BackgroundColor3 = Color3.fromRGB(252,252,252)
			else
				toggleFrame.BackgroundColor3 = Color3.fromRGB(65,182,255)
			end
		end
		setState(false)

		btn.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				self:ApplyTheme(tableData)
				activeThemeName = name
				for _,s in pairs(menuFrame:GetChildren()) do
					if s ~= menuFrame:FindFirstChildOfClass("UIListLayout") and s:IsA("Frame") then
						local tf = s:FindFirstChildWhichIsA("Frame")
						if tf then
							pcall(function() tf.BackgroundColor3 = Color3.fromRGB(65,182,255) end)
						end
					end
				end
				pcall(function() toggleFrame.BackgroundColor3 = Color3.fromRGB(252,252,252) end)
			end
		end)
		return btn
	end

	for name, tdata in pairs(themes) do
		createThemeToggle(name, tdata)
	end

end

return NostalgicUILib
