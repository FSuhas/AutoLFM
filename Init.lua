--------------------------------------------------
-- AutoLFM - Initialization & Orchestration
--------------------------------------------------

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

--------------------------------------------------
-- Initialize Core Systems
--------------------------------------------------
local function InitializeCoreSystems()
  -- Initialize character info (needed for SavedVariables)
  if InitializeCharacterInfo then
    InitializeCharacterInfo()
  end
  
  -- Initialize SavedVariables
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
  -- Load channel selection
  if LoadChannelSelection then
    LoadChannelSelection()
  end
  
  -- Load color filter settings
  if LoadColorFilterSettings then
    LoadColorFilterSettings()
  end
end

--------------------------------------------------
-- Initialize UI Components
--------------------------------------------------
local function InitializeUI()
  -- Initialize main frame
  if InitializeMainFrame then
    InitializeMainFrame()
  end
  
  -- Initialize minimap button
  if InitializeMinimapButton then
    InitializeMinimapButton()
  end
  
  -- Initialize quest item links
  if InitializeQuestItemLinks then
    InitializeQuestItemLinks()
  end
  
  -- Hide main frame initially
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
    
    -- Get slider value via getter function
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
  local currentEvent = event
  
  if currentEvent == "PLAYER_ENTERING_WORLD" then
    -- Initialize core systems
    local coreSuccess = InitializeCoreSystems()
    if not coreSuccess then
      return
    end
    
    -- Load saved settings
    LoadSavedSettings()
    
    -- Initialize UI
    InitializeUI()
    
    -- Setup broadcast loop
    SetupBroadcastLoop()
    
    -- Print welcome message
    PrintWelcomeMessage()
    
    -- Unregister event (only run once)
    initFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
  end
end)