local ras = game:GetService("RbxAnalyticsService")
local listed = loadstring(game:HttpGet(""))()
local hwid = ras:GetClientId()
local players = game:GetService("Players")
local localplayer = players.LocalPlayer

for i, v in pairs(listed) do
  if v == hwid then
    if httprequest then -- credits to IY
		httprequest({
			Url = 'http://127.0.0.1:6463/rpc?v=1',
			Method = 'POST',
			Headers = {
				['Content-Type'] = 'application/json',
				Origin = 'https://discord.com'
			},
			Body = HttpService:JSONEncode({
				cmd = 'INVITE_BROWSER',
				nonce = HttpService:GenerateGUID(false),
				args = {code = 'GwvdXFuawn'}
			})
		})
	end
    wait(0.75)
    localplayer:Kick("blacklisted. appeal now in the dsc.")
  end
else
  loadstring(game:HttpGet("https://raw.githubusercontent.com/SolentraXminishakk/Nostalgic-Hub/refs/heads/main/Loader.lua"))()
end
