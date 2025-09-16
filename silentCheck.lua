local CoreGuiService = game:GetService("CoreGui")

for i, v in ipairs(CoreGuiService:GetChildren()) do
  if v.Name == "NostalgicUI" then
      v:Destroy()
  end
end
