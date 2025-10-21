--=============================================================================
-- AutoLFM Example Integration - Complete API Showcase
--=============================================================================
-- This addon demonstrates ALL AutoLFM API features with a comprehensive UI

local ADDON_NAME = "AutoLFM_Example"

--=============================================================================
-- Main Frame
--=============================================================================
local mainFrame = CreateFrame("Frame", "AutoLFMExampleFrame", UIParent)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainFrame:SetWidth(400)
mainFrame:SetHeight(500)
mainFrame:SetBackdrop({
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true,
  tileSize = 32,
  edgeSize = 32,
  insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function() this:StartMoving() end)
mainFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
mainFrame:Hide()

-- Title
local titleText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleText:SetPoint("TOP", mainFrame, "TOP", 0, -15)
titleText:SetText("AutoLFM API - Complete Example")

-- Close button
local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -5, -5)

--=============================================================================
-- Display Functions
--=============================================================================
local function CreateSection(parent, yOffset, title)
  local sectionFrame = CreateFrame("Frame", nil, parent)
  sectionFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
  sectionFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -20, yOffset)
  sectionFrame:SetHeight(1)
  
  local titleText = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  titleText:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", 0, 0)
  titleText:SetText(title)
  titleText:SetTextColor(1, 0.82, 0)
  
  local contentText = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  contentText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 10, -3)
  contentText:SetPoint("TOPRIGHT", sectionFrame, "TOPRIGHT", 0, -3)
  contentText:SetJustifyH("LEFT")
  contentText:SetText("")
  
  return contentText
end

-- Create all sections
local apiVersionText = CreateSection(mainFrame, -45, "API Version:")
local groupTypeText = CreateSection(mainFrame, -80, "Group Type:")
local playerCountText = CreateSection(mainFrame, -115, "Player Count:")
local contentText = CreateSection(mainFrame, -150, "Selected Content:")
local rolesText = CreateSection(mainFrame, -210, "Roles Needed:")
local channelsText = CreateSection(mainFrame, -245, "Channels:")
local messageText = CreateSection(mainFrame, -280, "Message:")
local broadcastStatusText = CreateSection(mainFrame, -340, "Broadcast Status:")
local statsText = CreateSection(mainFrame, -375, "Statistics:")
local timingText = CreateSection(mainFrame, -425, "Timing:")

--=============================================================================
-- Update UI with ALL API data
--=============================================================================
local function UpdateUI()
  if not AutoLFM or not AutoLFM.API or not AutoLFM.API.IsAvailable() then
    apiVersionText:SetText("|cffff0000API not available|r")
    groupTypeText:SetText("")
    playerCountText:SetText("")
    contentText:SetText("")
    rolesText:SetText("")
    channelsText:SetText("")
    messageText:SetText("")
    broadcastStatusText:SetText("")
    statsText:SetText("")
    timingText:SetText("")
    return
  end
  
  -- Get full status
  local status = AutoLFM.API.GetFullStatus()
  
  -- API Version
  apiVersionText:SetText("|cff00ff00" .. AutoLFM.API.GetVersion() .. "|r")
  
  -- Group Type
  local groupColor = "ffffff"
  if status.groupType == "raid" then groupColor = "ff8040"
  elseif status.groupType == "dungeon" then groupColor = "4080ff" end
  groupTypeText:SetText("|cff" .. groupColor .. status.groupType .. "|r")
  
  -- Player Count (utilise directement l'API, bug corrigé)
  local currentInGroup = status.playerCount.currentInGroup
  local desiredTotal = status.playerCount.desiredTotal
  local missing = status.playerCount.missing
  
  playerCountText:SetText(string.format("|cffffffff%d|r / |cff00ff00%d|r (missing: |cffff0000%d|r)", 
    currentInGroup, desiredTotal, missing))
  
  -- Selected Content
  if table.getn(status.selectedContent.list) > 0 then
    local contentStr = ""
    for i = 1, math.min(3, table.getn(status.selectedContent.list)) do
      local tag = status.selectedContent.list[i]
      if i > 1 then contentStr = contentStr .. ", " end
      contentStr = contentStr .. "|cff40bf40" .. tag .. "|r"
    end
    if table.getn(status.selectedContent.list) > 3 then
      contentStr = contentStr .. " +" .. (table.getn(status.selectedContent.list) - 3) .. " more"
    end
    contentText:SetText(contentStr)
  else
    contentText:SetText("|cff808080none|r")
  end
  
  -- Roles
  if table.getn(status.rolesNeeded) > 0 then
    rolesText:SetText("|cff40bf40" .. table.concat(status.rolesNeeded, "|r, |cff40bf40") .. "|r")
  else
    rolesText:SetText("|cff808080none|r")
  end
  
  -- Channels
  if table.getn(status.selectedChannels) > 0 then
    channelsText:SetText("|cff0070dd" .. table.concat(status.selectedChannels, "|r, |cff0070dd") .. "|r")
  else
    channelsText:SetText("|cff808080none|r")
  end
  
  -- Message
  if status.message.combined and status.message.combined ~= "" then
    local msg = status.message.combined
    if string.len(msg) > 60 then
      msg = string.sub(msg, 1, 57) .. "..."
    end
    messageText:SetText("|cffffffff" .. msg .. "|r")
  else
    messageText:SetText("|cff808080empty|r")
  end
  
  -- Broadcast Status
  if status.broadcastStats.isActive then
    broadcastStatusText:SetText("|cff00ff00ACTIVE|r")
  else
    broadcastStatusText:SetText("|cffff0000INACTIVE|r")
  end
  
  -- Statistics
  local statsStr = string.format("Messages: |cffffffff%d|r | Duration: |cffffffff%s|r",
    status.broadcastStats.messagesSent,
    string.format("%02d:%02d", 
      math.floor(status.broadcastStats.searchDuration / 60),
      math.floor(math.mod(status.broadcastStats.searchDuration, 60))
    )
  )
  statsText:SetText(statsStr)
  
  -- Timing
  local timingStr = string.format("Interval: |cffffffff%ds|r | Next in: |cffffffff%ds|r",
    status.timing.intervalSeconds,
    math.floor(status.timing.timeUntilNext)
  )
  timingText:SetText(timingStr)
end

--=============================================================================
-- Event Callbacks - ALL EVENTS
--=============================================================================
local function OnBroadcastStart(status)
  DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[Example]|r BROADCAST_START event fired")
  UpdateUI()
end

local function OnBroadcastStop(status)
  DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[Example]|r BROADCAST_STOP event fired")
  UpdateUI()
end

local function OnMessageSent(status)
  DEFAULT_CHAT_FRAME:AddMessage("|cff0070dd[Example]|r MESSAGE_SENT event fired: " .. status.message.combined)
  UpdateUI()
end

local function OnContentChanged(status)
  DEFAULT_CHAT_FRAME:AddMessage("|cffffff00[Example]|r CONTENT_CHANGED event fired")
  UpdateUI()
end

local function OnRolesChanged(status)
  DEFAULT_CHAT_FRAME:AddMessage("|cffffff00[Example]|r ROLES_CHANGED event fired")
  UpdateUI()
end

local function OnChannelsChanged(status)
  DEFAULT_CHAT_FRAME:AddMessage("|cffffff00[Example]|r CHANNELS_CHANGED event fired")
  UpdateUI()
end

local function OnIntervalChanged(status)
  DEFAULT_CHAT_FRAME:AddMessage("|cffffff00[Example]|r INTERVAL_CHANGED event fired")
  UpdateUI()
end

--=============================================================================
-- Initialization
--=============================================================================
local function Initialize()
  if not AutoLFM or not AutoLFM.API or not AutoLFM.API.IsAvailable() then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[Example]|r AutoLFM API not available")
    return
  end
  
  DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[Example]|r Loaded! API " .. AutoLFM.API.GetVersion())
  DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[Example]|r Demonstrating ALL API features")
  
  -- Register global callback
  AutoLFM.API.RegisterCallback(ADDON_NAME, function(status, eventType)
    UpdateUI()
  end)
  
  -- Register ALL event-specific callbacks
  AutoLFM.API.RegisterEventCallback(AutoLFM.API.EVENTS.BROADCAST_START, ADDON_NAME, OnBroadcastStart)
  AutoLFM.API.RegisterEventCallback(AutoLFM.API.EVENTS.BROADCAST_STOP, ADDON_NAME, OnBroadcastStop)
  AutoLFM.API.RegisterEventCallback(AutoLFM.API.EVENTS.MESSAGE_SENT, ADDON_NAME, OnMessageSent)
  AutoLFM.API.RegisterEventCallback(AutoLFM.API.EVENTS.CONTENT_CHANGED, ADDON_NAME, OnContentChanged)
  AutoLFM.API.RegisterEventCallback(AutoLFM.API.EVENTS.ROLES_CHANGED, ADDON_NAME, OnRolesChanged)
  AutoLFM.API.RegisterEventCallback(AutoLFM.API.EVENTS.CHANNELS_CHANGED, ADDON_NAME, OnChannelsChanged)
  AutoLFM.API.RegisterEventCallback(AutoLFM.API.EVENTS.INTERVAL_CHANGED, ADDON_NAME, OnIntervalChanged)
  
  DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[Example]|r All 7 event callbacks registered")
  DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[Example]|r Type |cffffff00/lfmexample|r to toggle UI")
  
  UpdateUI()
end

--=============================================================================
-- Slash Commands
--=============================================================================
SLASH_LFMEXAMPLE1 = "/lfmexample"
SLASH_LFMEXAMPLE2 = "/lfmex"
SlashCmdList["LFMEXAMPLE"] = function(msg)
  if msg == "debug" then
    -- Show debug info
    if AutoLFM.API and AutoLFM.API.DebugPrint then
      AutoLFM.API.DebugPrint()
    end
  elseif msg == "callbacks" then
    -- List callbacks
    if AutoLFM.API and AutoLFM.API.ListCallbacks then
      AutoLFM.API.ListCallbacks()
    end
  else
    -- Toggle frame
    if mainFrame:IsShown() then
      mainFrame:Hide()
    else
      mainFrame:Show()
      UpdateUI()
    end
  end
end

--=============================================================================
-- Event Registration
--=============================================================================
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
initFrame:RegisterEvent("RAID_ROSTER_UPDATE")

initFrame:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" then
    Initialize()
    initFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
  elseif event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
    -- Update UI when group changes
    if mainFrame:IsShown() then
      UpdateUI()
    end
  end
end)

-- Auto-update timer
local updateFrame = CreateFrame("Frame")
local timeSinceUpdate = 0
updateFrame:SetScript("OnUpdate", function()
  timeSinceUpdate = timeSinceUpdate + arg1
  
  if timeSinceUpdate >= 0.5 then
    if mainFrame:IsShown() then
      UpdateUI()
    end
    timeSinceUpdate = 0
  end
end)
