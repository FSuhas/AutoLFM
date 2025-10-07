--------------------------------------------------
-- Main Frame - UI Assembly & Event Handling
--------------------------------------------------

AutoLFM_MainFrame = nil
AutoLFM_MainIconTexture = nil

local messagePreviewFrame = nil
local dungeonsPanelFrame = nil
local raidsPanelFrame = nil
local settingsPanelFrame = nil

--------------------------------------------------
-- Create Base Frame
--------------------------------------------------
local function CreateBaseFrame()
  AutoLFM_MainFrame = CreateFrame("Frame", "AutoLFM_MainFrame", UIParent)
  UIPanelWindows["AutoLFM_MainFrame"] = { area = "left", pushable = 3 }
  AutoLFM_MainFrame:SetWidth(384)
  AutoLFM_MainFrame:SetHeight(512)
  AutoLFM_MainFrame:Hide()
  
  -- Background texture
  local mainTexture = AutoLFM_MainFrame:CreateTexture(nil, "BACKGROUND")
  mainTexture:SetPoint("TOPLEFT", AutoLFM_MainFrame, "TOPLEFT", 0, 0)
  mainTexture:SetWidth(512)
  mainTexture:SetHeight(512)
  mainTexture:SetTexture(TEXTURE_BASE_PATH .. "mainFrame")
  
  -- Icon
  local mainIcon = AutoLFM_MainFrame:CreateTexture(nil, "LOW")
  mainIcon:SetPoint("TOPLEFT", AutoLFM_MainFrame, "TOPLEFT", 7, -4)
  mainIcon:SetWidth(64)
  mainIcon:SetHeight(64)
  mainIcon:SetTexture(TEXTURE_BASE_PATH .. "Eyes\\eye07")
  AutoLFM_MainIconTexture = mainIcon
  
  -- Title
  local mainTitle = AutoLFM_MainFrame:CreateFontString(nil, "MEDIUM", "GameFontNormal")
  mainTitle:SetPoint("TOP", AutoLFM_MainFrame, "TOP", 0, -18)
  mainTitle:SetText("AutoLFM")
  
  -- Close button
  local close = CreateFrame("Button", nil, AutoLFM_MainFrame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", AutoLFM_MainFrame, "TOPRIGHT", -27, -8)
  close:SetScript("OnClick", function()
    HideUIPanel(AutoLFM_MainFrame)
  end)
end

--------------------------------------------------
-- Initialize All Components
--------------------------------------------------
local function InitializeComponents()
  if not AutoLFM_MainFrame then return end
  
  -- Role Selector
  if InitializeRoleSelector then
    InitializeRoleSelector(AutoLFM_MainFrame)
  end
  
  -- Message Preview
  if CreateMessagePreview then
    messagePreviewFrame = CreateMessagePreview(AutoLFM_MainFrame)
  end
  
  -- Tab System
  if InitializeTabSystem then
    InitializeTabSystem(AutoLFM_MainFrame)
  end
  
  -- Panels
  if CreateDungeonsPanel then
    dungeonsPanelFrame = CreateDungeonsPanel(AutoLFM_MainFrame)
  end
  
  if CreateRaidsPanel then
    raidsPanelFrame = CreateRaidsPanel(AutoLFM_MainFrame)
  end
  
  if CreateSettingsPanel then
    settingsPanelFrame = CreateSettingsPanel(AutoLFM_MainFrame)
  end
  
  -- Broadcast Toggle Button (created in SettingsPanel but accessible globally)
  -- Create it attached to MainFrame for visibility on all tabs
  local broadcastButton = GetBroadcastToggleButton()
  if not broadcastButton then
    broadcastButton = CreateFrame("Button", "ToggleButton", AutoLFM_MainFrame, "UIPanelButtonTemplate")
    broadcastButton:SetPoint("BOTTOM", AutoLFM_MainFrame, "BOTTOM", 97, 80)
    broadcastButton:SetWidth(110)
    broadcastButton:SetHeight(21)
    broadcastButton:SetText("Start")
    
    broadcastButton:SetScript("OnClick", function()
      if IsBroadcastActive() then
        StopBroadcast()
        broadcastButton:SetText("Start")
        PlaySoundFile(SOUND_BASE_PATH .. SOUND_BROADCAST_STOP)
      else
        if EnsureChannelUIExists then
          EnsureChannelUIExists()
        end
        
        local success = StartBroadcast()
        
        if success then
          broadcastButton:SetText("Stop")
          PlaySoundFile(SOUND_BASE_PATH .. SOUND_BROADCAST_START)
        end
      end
    end)
  end
  
  -- Raid size slider (created in RaidsList but attached to MainFrame)
  if AutoLFM_RaidList and AutoLFM_RaidList.CreateSizeSlider then
    AutoLFM_RaidList.CreateSizeSlider(AutoLFM_MainFrame)
  end
end

--------------------------------------------------
-- Tab Change Handler
--------------------------------------------------
local function OnTabChange(tabIndex)
  if not tabIndex then return end
  
  -- Hide all panels
  if HideDungeonsPanel then HideDungeonsPanel() end
  if HideRaidsPanel then HideRaidsPanel() end
  if HideSettingsPanel then HideSettingsPanel() end
  
  -- Show selected panel
  if tabIndex == 1 then
    if ShowDungeonsPanel then ShowDungeonsPanel() end
  elseif tabIndex == 2 then
    if ShowRaidsPanel then ShowRaidsPanel() end
  elseif tabIndex == 3 then
    if ShowSettingsPanel then ShowSettingsPanel() end
  end

end

--------------------------------------------------
-- Handle Group Full Event
--------------------------------------------------
local function HandleGroupFull(contentType, maxSize)
  if IsBroadcastActive() then
    if StopBroadcast then StopBroadcast() end
  end
  
  if contentType == "raid" then
    if ClearRaidSelection then ClearRaidSelection() end
  else
    if ClearDungeonSelection then ClearDungeonSelection() end
  end
  
  if ClearAllRoles then ClearAllRoles() end
  if ResetCustomMessage then ResetCustomMessage() end
  if UpdateDynamicMessage then UpdateDynamicMessage() end
  
  local broadcastButton = GetBroadcastToggleButton()
  if broadcastButton then
    broadcastButton:SetText("Start")
  end
  
  PlaySoundFile(SOUND_BASE_PATH .. SOUND_BROADCAST_STOP)
end

--------------------------------------------------
-- Setup Event Handlers
--------------------------------------------------
local function SetupEventHandlers()
  if not AutoLFM_MainFrame then return end
  
  AutoLFM_MainFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
  AutoLFM_MainFrame:RegisterEvent("RAID_ROSTER_UPDATE")
  
  AutoLFM_MainFrame:SetScript("OnEvent", function()
    local currentEvent = event
    
    if currentEvent == "RAID_ROSTER_UPDATE" then
      if HandleRaidRosterUpdate then
        HandleRaidRosterUpdate()
      end
      
    elseif currentEvent == "PARTY_MEMBERS_CHANGED" then
      local selectedRaids = GetSelectedRaidsList()
      local selectedDungeons = GetSelectedDungeonsList()
      
      if selectedRaids and table.getn(selectedRaids) > 0 then
        -- Check raid size
        local totalPlayersInRaid = GetRaidMemberCount()
        local raidSize = GetRaidGroupSize()
        
        if raidSize == totalPlayersInRaid then
          HandleGroupFull("raid", raidSize)
        else
          if HandlePartyUpdate then HandlePartyUpdate() end
        end
        
      elseif selectedDungeons and table.getn(selectedDungeons) > 0 then
        -- Check dungeon size
        local totalPlayersInGroup = GetPartyMemberCount()
        
        if totalPlayersInGroup >= DEFAULT_DUNGEON_SIZE then
          HandleGroupFull("dungeon", DEFAULT_DUNGEON_SIZE)
        else
          if HandlePartyUpdate then HandlePartyUpdate() end
        end
      end
    end
  end)
end

--------------------------------------------------
-- Initialize Main Frame
--------------------------------------------------
function InitializeMainFrame()
  if AutoLFM_MainFrame then return end
  
  CreateBaseFrame()
  InitializeComponents()
  
  -- Register tab change callback
  if RegisterTabChangeCallback then
    RegisterTabChangeCallback(OnTabChange)
  end
  
  SetupEventHandlers()
  
  -- Set initial tab (Dungeons)
  if SwitchToTab then
    SwitchToTab(1)
  end
end

--------------------------------------------------
-- Post-Login Initialization
--------------------------------------------------
local displayFrame = CreateFrame("Frame")
displayFrame:RegisterEvent("PLAYER_LOGIN")

displayFrame:SetScript("OnEvent", function()
  local currentEvent = event
  
  if currentEvent == "PLAYER_LOGIN" then
    -- Display dungeon list
    local dungeonContentFrame = GetDungeonListContentFrame()
    if AutoLFM_DungeonList and AutoLFM_DungeonList.Display and dungeonContentFrame then
      AutoLFM_DungeonList.Display(dungeonContentFrame)
    end
    
    -- Display raid list
    local raidContentFrame = GetRaidListContentFrame()
    if AutoLFM_RaidList and AutoLFM_RaidList.Display and raidContentFrame then
      AutoLFM_RaidList.Display(raidContentFrame)
    end
    
    -- Update filter UI
    if UpdateFilterUI then
      UpdateFilterUI()
    end

    displayFrame:UnregisterEvent("PLAYER_LOGIN")
  end
end)

--------------------------------------------------
-- Legacy Global Reference
--------------------------------------------------
AutoLFM = AutoLFM_MainFrame