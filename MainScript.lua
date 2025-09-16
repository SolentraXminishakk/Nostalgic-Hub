-- heres the script src (complicated so I wouldnt touch around this)
local Libary = loadstring(game:HttpGet("https://raw.githubusercontent.com/SolentraXminishakk/Nostalgic-Hub/refs/heads/main/library.lua"))()
local silentCheck = loadstring(game:HttpGet("https://raw.githubusercontent.com/SolentraXminishakk/Nostalgic-Hub/refs/heads/main/silentCheck.lua"))()
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local Player = Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait() -- safe load
local Humanoid = Char.Humanoid
local HRP = Char.HumanoidRootPart

-- Tabs

Check()
