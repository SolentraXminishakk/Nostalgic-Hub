-- use this for wtv Idrk

-- NostalgicUILib.lua
local NostalgicUILib = {}
NostalgicUILib.Tabs = {}

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Helper
local function tween(obj, props)
    TweenService:Create(obj, TweenInfo.new(0.2), props):Play()
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NostalgicUI"
ScreenGui.Parent = game:GetService("CoreGui")

-- MainFrame (container for tabs)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Parent = ScreenGui

-- Tab Creation
function NostalgicUILib:CreateTab(info)
    local Tab = {}
    Tab.Name = info.Name or "Tab"

    local TabFrame = Instance.new("Frame")
    TabFrame.Name = Tab.Name
    TabFrame.Size = UDim2.new(1, -10, 1, -10)
    TabFrame.Position = UDim2.new(0, 5, 0, 5)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Parent = MainFrame

    -- Store for later
    NostalgicUILib.Tabs[Tab.Name] = TabFrame

    -- // Button
    function Tab:CreateButton(info)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 150, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = info.Name or "Button"
        btn.Parent = TabFrame

        btn.MouseButton1Click:Connect(function()
            if info.Callback then
                info.Callback()
            end
        end)
    end

    -- // Toggle
    function Tab:CreateToggle(info)
        local state = info.Default or false

        local frame = Instance.new("TextButton")
        frame.Size = UDim2.new(0, 150, 0, 30)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        frame.TextColor3 = Color3.fromRGB(255, 255, 255)
        frame.Text = info.Name or "Toggle"
        frame.Parent = TabFrame

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 20, 0, 20)
        indicator.Position = UDim2.new(1, -25, 0.5, -10)
        indicator.BackgroundColor3 = state and Color3.fromRGB(50,200,50) or Color3.fromRGB(200,50,50)
        indicator.Parent = frame

        frame.MouseButton1Click:Connect(function()
            state = not state
            tween(indicator, {BackgroundColor3 = state and Color3.fromRGB(50,200,50) or Color3.fromRGB(200,50,50)})
            if info.Callback then
                info.Callback(state)
            end
        end)
    end

    -- // Slider
    function Tab:CreateSlider(info)
        local min, max = info.Min or 0, info.Max or 100
        local value = info.Default or min

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 40)
        frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
        frame.Parent = TabFrame

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0.8, 0, 0, 6)
        bar.Position = UDim2.new(0.1,0,0.5,-3)
        bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
        bar.Parent = frame

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
        fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
        fill.Parent = bar

        local dragging = false
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local percent = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * percent)
                fill.Size = UDim2.new(percent,0,1,0)
                if info.Callback then info.Callback(value) end
            end
        end)
    end

    -- // Keybind
    function Tab:CreateKeybind(info)
        local key = info.Default or Enum.KeyCode.Unknown
        local frame = Instance.new("TextButton")
        frame.Size = UDim2.new(0, 150, 0, 30)
        frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
        frame.TextColor3 = Color3.fromRGB(255,255,255)
        frame.Text = (info.Name or "Keybind") .. " : " .. (key.Name or "None")
        frame.Parent = TabFrame

        local listening = false

        frame.MouseButton1Click:Connect(function()
            listening = true
            frame.Text = "Press a key..."
        end)

        UIS.InputBegan:Connect(function(input, gpe)
            if not gpe then
                if listening then
                    listening = false
                    if input.KeyCode ~= Enum.KeyCode.Unknown then
                        key = input.KeyCode
                        frame.Text = (info.Name or "Keybind") .. " : " .. key.Name
                    end
                elseif key ~= Enum.KeyCode.Unknown and input.KeyCode == key then
                    if info.Callback then info.Callback() end
                end
            end
        end)
    end

    return Tab
end

return NostalgicUILib
