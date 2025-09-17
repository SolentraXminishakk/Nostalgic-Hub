-- load the library (example as remote)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/.../library.lua"))()

-- MUST start (or CreateTab will auto-start)
Library:start()

-- create tabs (two valid styles)
local VisualTab = Library:CreateTab("Visuals")
local PlayerTab  = Library:CreateTab({ Name = "Player" })

-- populate the themes dropdown on VisualTab (uses exploit fs if available)
Library:AddThemes(VisualTab)

Check()
