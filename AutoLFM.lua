--------------------------------------------------
-- Initialization on Login
--------------------------------------------------
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

initFrame:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" then
    if LoadSelectedChannels then
      LoadSelectedChannels()
    end
    
    if LoadDungeonFilters then
      LoadDungeonFilters()
    end
    
    if InitMinimapButton then
      InitMinimapButton()
    end
    
    if AutoLFM then
      AutoLFM:Hide()
    end
    
    if AutoLFM_PrintSuccess then
      AutoLFM_PrintSuccess("Loaded successfully! " .. ColorText("More information: ", "gray") .. "/lfm help")
    end
    
    initFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
  end
end)