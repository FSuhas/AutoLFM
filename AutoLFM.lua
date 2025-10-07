--------------------------------------------------
-- Initialization on Login
--------------------------------------------------
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

initFrame:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" then
    if LoadChannelSelection then
      LoadChannelSelection()
    end
    
    if LoadColorFilterSettings then
      LoadColorFilterSettings()
    end
    
    if InitializeMinimapButton then
      InitializeMinimapButton()
    end
    
    if AutoLFM_MainFrame then
      AutoLFM_MainFrame:Hide()
    end
    
    if AutoLFM_PrintSuccess then
      AutoLFM_PrintSuccess("Loaded successfully! " .. ColorizeText("More information: ", "gray") .. "/lfm help")
    end
    
    initFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
  end
end)