--------------------------------------------------
-- AutoLFM - Initialization & Orchestration
--------------------------------------------------
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

--------------------------------------------------
-- Initialize Core Systems
--------------------------------------------------
local function InitializeCoreSystems()
  if InitializeCharacterInfo then
    InitializeCharacterInfo()
  end
  
  if InitializeCharacterSavedVariables then
    local success = InitializeCharacterSavedVariables()
    if not success then
      if AutoLFM_PrintError then
        AutoLFM_PrintError("Failed to initialize SavedVariables")
      end
      return false
    end
  end
  
  return true
end

--------------------------------------------------
-- Load Saved Settings
--------------------------------------------------
local function LoadSavedSettings()
  if LoadChannelSelection then
    LoadChannelSelection()
  end
  
  if LoadColorFilterSettings then
    LoadColorFilterSettings()
  end
end

--------------------------------------------------
-- Initialize UI Components
--------------------------------------------------
local function InitializeUI()
  if InitializeMainFrame then
    InitializeMainFrame()
  end
  
  if InitializeMinimapButton then
    InitializeMinimapButton()
  end
  
  if InitializeQuestItemLinks then
    InitializeQuestItemLinks()
  end
  
  if AutoLFM_MainFrame then
    AutoLFM_MainFrame:Hide()
  end
end

--------------------------------------------------
-- Setup Broadcast Loop
--------------------------------------------------
local function SetupBroadcastLoop()
  local broadcastFrame = CreateFrame("Frame")
  local lastUpdateCheck = 0
  
  broadcastFrame:SetScript("OnUpdate", function()
    if not IsBroadcastActive() then return end
    
    local currentTime = GetTime()
    
    if currentTime - lastUpdateCheck < UPDATE_THROTTLE_BROADCAST then
      return
    end
    lastUpdateCheck = currentTime
    
    local stats = GetBroadcastStats()
    if not stats or not stats.lastTimestamp then
      return
    end
    
    local sliderValue = DEFAULT_BROADCAST_INTERVAL
    local broadcastSlider = GetBroadcastIntervalSlider()
    if broadcastSlider and broadcastSlider.GetValue then
      sliderValue = broadcastSlider:GetValue() or DEFAULT_BROADCAST_INTERVAL
    end
    
    if not sliderValue or sliderValue < 1 then
      sliderValue = DEFAULT_BROADCAST_INTERVAL
    end
    
    local timeElapsed = currentTime - stats.lastTimestamp
    
    if timeElapsed >= sliderValue then
      local message = GetGeneratedLFMMessage()
      if message and message ~= "" and message ~= " " then
        local success = SendMessageToChannels(message)
        if not success then
          StopBroadcast()
          local broadcastButton = GetBroadcastToggleButton()
          if broadcastButton then
            broadcastButton:SetText("Start")
          end
        end
      end
    end
  end)
end

--------------------------------------------------
-- Print Welcome Message
--------------------------------------------------
local function PrintWelcomeMessage()
  if AutoLFM_PrintSuccess then
    AutoLFM_PrintSuccess("Loaded successfully! " .. ColorizeText("More information: ", "gray") .. "/lfm help")
  end
end

--------------------------------------------------
-- Main Initialization
--------------------------------------------------
initFrame:SetScript("OnEvent", function()
  local eventName = event
  
  if eventName == "PLAYER_ENTERING_WORLD" then
    local coreSuccess = InitializeCoreSystems()
    if not coreSuccess then
      return
    end
    
    LoadSavedSettings()
    
    InitializeUI()
    
    SetupBroadcastLoop()
    
    PrintWelcomeMessage()
    
    initFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
  end
end)