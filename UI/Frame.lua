--------------------------------------------------
-- Local Variables
--------------------------------------------------
local currentTab = 1
local tabs = {}
local step = 10

-- Inside frames (local to Frame.lua)
local insideDungeons = nil
local insideRaids = nil

-- Scroll frames (local to Frame.lua)
local djScrollFrame = nil
local raidScrollFrame = nil
local raidListContentFrame = nil

-- Dungeon filter frame (local to Frame.lua)
local dungeonFilterFrame = nil

--------------------------------------------------
-- Main Frame
--------------------------------------------------
AutoLFM_MainFrame = CreateFrame("Frame", "AutoLFM_MainFrame", UIParent)
UIPanelWindows["AutoLFM_MainFrame"] = { area = "left", pushable = 3 }
AutoLFM_MainFrame:SetWidth(384)
AutoLFM_MainFrame:SetHeight(512)
AutoLFM_MainFrame:Hide()

local mainTexture = AutoLFM_MainFrame:CreateTexture(nil, "BACKGROUND")
mainTexture:SetPoint("TOPLEFT", AutoLFM_MainFrame, "TOPLEFT", 0, 0)
mainTexture:SetWidth(512)
mainTexture:SetHeight(512)
mainTexture:SetTexture(TEXTURE_BASE_PATH .. "mainFrame")

local mainIcon = AutoLFM_MainFrame:CreateTexture(nil, "LOW")
mainIcon:SetPoint("TOPLEFT", AutoLFM_MainFrame, "TOPLEFT", 7, -4)
mainIcon:SetWidth(64)
mainIcon:SetHeight(64)
mainIcon:SetTexture(TEXTURE_BASE_PATH .. "Eyes\\eye01")
AutoLFM_MainIconTexture = mainIcon

local mainTitle = AutoLFM_MainFrame:CreateFontString(nil, "MEDIUM", "GameFontNormal")
mainTitle:SetPoint("TOP", AutoLFM_MainFrame, "TOP", 0, -18)
mainTitle:SetText("AutoLFM")

local close = CreateFrame("Button", nil, AutoLFM_MainFrame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", AutoLFM_MainFrame, "TOPRIGHT", -27, -8)
close:SetScript("OnClick", function() HideUIPanel(AutoLFM_MainFrame) end)

--------------------------------------------------
-- Roles
--------------------------------------------------
local function createRole(name, x, texCoordStart)
  local btn = CreateFrame("Button", nil, AutoLFM_MainFrame)
  btn:SetPoint("TOPLEFT", AutoLFM_MainFrame, "TOPLEFT", x, -52)
  btn:SetWidth(54)
  btn:SetHeight(54)
  btn:SetHighlightTexture(TEXTURE_BASE_PATH .. "rolesHighlight")
  
  local bg = btn:CreateTexture(nil, "BACKGROUND")
  bg:SetPoint("TOPLEFT", btn, "TOPLEFT", -12, 14)
  bg:SetWidth(84)
  bg:SetHeight(84)
  bg:SetTexture(TEXTURE_BASE_PATH .. "rolesBackground")
  bg:SetTexCoord(texCoordStart, texCoordStart + 0.2968, 0, 0.5937)
  bg:SetVertexColor(1, 1, 1, 0.6)
  
  local icon = btn:CreateTexture(nil, "BORDER")
  icon:SetAllPoints(btn)
  icon:SetTexture(TEXTURE_BASE_PATH .. "roles" .. name)
  
  local check = CreateFrame("CheckButton", nil, AutoLFM_MainFrame, "UICheckButtonTemplate")
  check:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 1, -5)
  check:SetWidth(24)
  check:SetHeight(24)
  check:SetScript("OnClick", function() 
    if ToggleRoleSelection then 
      ToggleRoleSelection(name) 
    end 
  end)
  
  roleCheckboxes[name] = check
  btn:SetScript("OnClick", function() check:Click() end)
  
  return btn, bg, icon, check
end

createRole("Tank", 74, 0.2968)
createRole("Heal", 172, 0)
createRole("DPS", 270, 0.5937)

--------------------------------------------------
-- Dynamic Message Frames
--------------------------------------------------
dungeonMessageDisplayFrame = CreateFrame("Frame", nil, AutoLFM_MainFrame)
dungeonMessageDisplayFrame:SetPoint("TOP", AutoLFM_MainFrame, "TOP", -10, -125)
dungeonMessageDisplayFrame:SetWidth(330)
dungeonMessageDisplayFrame:SetHeight(30)

dungeonMessageText = dungeonMessageDisplayFrame:CreateFontString(nil, "MEDIUM", "GameFontHighlight")
dungeonMessageText:SetPoint("CENTER", dungeonMessageDisplayFrame, "CENTER", 0, 0)

raidMessageDisplayFrame = CreateFrame("Frame", nil, AutoLFM_MainFrame)
raidMessageDisplayFrame:SetPoint("TOP", AutoLFM_MainFrame, "TOP", -10, -125)
raidMessageDisplayFrame:SetWidth(330)
raidMessageDisplayFrame:SetHeight(30)

raidMessageText = raidMessageDisplayFrame:CreateFontString(nil, "MEDIUM", "GameFontHighlight")
raidMessageText:SetPoint("CENTER", raidMessageDisplayFrame, "CENTER", 0, 0)
raidMessageText:SetTextColor(1, 1, 1)

--------------------------------------------------
-- Tab System
--------------------------------------------------
local function onTabClick(tabNum)
  currentTab = tabNum
  
  -- Hide all inside frames and scroll frames
  if insideDungeons then insideDungeons:Hide() end
  if insideRaids then insideRaids:Hide() end
  if moreTabContentFrame then moreTabContentFrame:Hide() end
  if djScrollFrame then djScrollFrame:Hide() end
  if raidScrollFrame then raidScrollFrame:Hide() end
  
  -- Show corresponding frame
  if tabNum == 1 then
    if insideDungeons then 
      insideDungeons:Show()
    end
    if djScrollFrame then 
      djScrollFrame:Show()
      djScrollFrame:SetVerticalScroll(0)
    end
  elseif tabNum == 2 then
    if insideRaids then 
      insideRaids:Show()
    end
    if raidScrollFrame then 
      raidScrollFrame:Show()
      raidScrollFrame:SetVerticalScroll(0)
    end
  elseif tabNum == 3 then
    if moreTabContentFrame then 
      moreTabContentFrame:Show()
    end
  end
  
  -- Update tab visuals
  for i = 1, 3 do
    local active = i == tabNum
    tabs[i].bg:SetTexture(TEXTURE_BASE_PATH .. (active and "tabActive" or "tabInactive"))
    tabs[i].text:SetTextColor(1, active and 1 or 0.82, active and 1 or 0)
    if active then 
      tabs[i].highlight:Hide() 
    end
  end
end

local function createTab(index, label, onClick, anchorTo)
  local tab = CreateFrame("Button", nil, AutoLFM_MainFrame)
  tab:SetPoint(anchorTo and "LEFT" or "BOTTOMLEFT", anchorTo or AutoLFM_MainFrame, anchorTo and "RIGHT" or "BOTTOMLEFT", anchorTo and -5 or 20, anchorTo and 0 or 46)
  tab:SetWidth(90)
  tab:SetHeight(32)
  
  local bg = tab:CreateTexture(nil, "BACKGROUND")
  bg:SetTexture(TEXTURE_BASE_PATH .. (index == 1 and "tabActive" or "tabInactive"))
  bg:SetAllPoints()
  
  local highlight = tab:CreateTexture(nil, "BORDER")
  highlight:SetPoint("CENTER", tab, "CENTER", 0, 0)
  highlight:SetWidth(70)
  highlight:SetHeight(24)
  highlight:SetTexture(TEXTURE_BASE_PATH .. "tabHighlight")
  highlight:Hide()
  
  local text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  text:SetPoint("CENTER", tab, "CENTER", 0, 0)
  text:SetText(label)
  text:SetTextColor(1, index == 1 and 1 or 0.82, index == 1 and 1 or 0)
  
  tabs[index] = {btn = tab, bg = bg, text = text, highlight = highlight}
  
  tab:SetScript("OnClick", function() 
    onTabClick(index) 
    if onClick then 
      onClick() 
    end 
  end)
  
  tab:SetScript("OnEnter", function() 
    if currentTab ~= index then 
      highlight:Show() 
      text:SetTextColor(1, 1, 1) 
    end 
  end)
  
  tab:SetScript("OnLeave", function() 
    highlight:Hide() 
    if currentTab ~= index then 
      text:SetTextColor(1, 0.82, 0) 
    end 
  end)
  
  return tab
end

--------------------------------------------------
-- Tab Actions
--------------------------------------------------
local function clearAllSelections()
  if ClearAllRoles then ClearAllRoles() end
  if ResetCustomMessage then ResetCustomMessage() end
  if UpdateDynamicMessage then UpdateDynamicMessage() end
  if EnsureChannelUIExists then EnsureChannelUIExists() end
end

local function onDungeonsTab()
  if dungeonMessageDisplayFrame then dungeonMessageDisplayFrame:Show() end
  if raidMessageDisplayFrame then raidMessageDisplayFrame:Hide() end
  if dungeonFilterFrame then dungeonFilterFrame:Show() end
  
  if ClearRaidSelection then ClearRaidSelection() end
  if HideRaidSizeControls then HideRaidSizeControls() end
  
  if AutoLFM_RaidList and AutoLFM_RaidList.ClearBackdrops then
    AutoLFM_RaidList.ClearBackdrops()
  end
  
  clearAllSelections()
end

local function onRaidsTab()
  if dungeonMessageDisplayFrame then dungeonMessageDisplayFrame:Hide() end
  if raidMessageDisplayFrame then raidMessageDisplayFrame:Show() end
  if dungeonFilterFrame then dungeonFilterFrame:Hide() end
  
  if ClearDungeonSelection then ClearDungeonSelection() end
  
  if AutoLFM_DungeonList and AutoLFM_DungeonList.ClearBackdrops then
    AutoLFM_DungeonList.ClearBackdrops()
  end
  
  clearAllSelections()
end

local function onMoreTab()
  if InitializeChannelSelectionUI then InitializeChannelSelectionUI() end
end

--------------------------------------------------
-- Create Tabs
--------------------------------------------------
local function createTabs()
  local prevTab
  local labels = {"Dungeons", "Raids", "More"}
  local actions = {onDungeonsTab, onRaidsTab, onMoreTab}
  
  for i = 1, 3 do
    prevTab = createTab(i, labels[i], actions[i], prevTab)
  end
end

--------------------------------------------------
-- Inside Frames
--------------------------------------------------
insideDungeons = CreateFrame("Frame", nil, AutoLFM_MainFrame)
insideDungeons:SetPoint("TOPLEFT", AutoLFM_MainFrame, "TOPLEFT", 25, -157)
insideDungeons:SetWidth(323)
insideDungeons:SetHeight(253)
insideDungeons:SetFrameStrata("HIGH")
insideDungeons:Show()

insideRaids = CreateFrame("Frame", nil, AutoLFM_MainFrame)
insideRaids:SetPoint("TOPLEFT", AutoLFM_MainFrame, "TOPLEFT", 25, -157)
insideRaids:SetWidth(323)
insideRaids:SetHeight(253)
insideRaids:SetFrameStrata("HIGH")
insideRaids:Hide()

moreTabContentFrame = CreateFrame("Frame", nil, AutoLFM_MainFrame)
moreTabContentFrame:SetPoint("TOPLEFT", AutoLFM_MainFrame, "TOPLEFT", 25, -157)
moreTabContentFrame:SetWidth(295)
moreTabContentFrame:SetHeight(253)
moreTabContentFrame:SetFrameStrata("HIGH")
moreTabContentFrame:Hide()

createTabs()

--------------------------------------------------
-- Scroll Frames
--------------------------------------------------
local function createScrollFrame(name, parent)
  local scrollFrame = CreateFrame("ScrollFrame", "AutoLFM_ScrollFrame_" .. name, parent, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
  scrollFrame:SetWidth(295)
  scrollFrame:SetHeight(253)
  scrollFrame:EnableMouse(true)
  scrollFrame:EnableMouseWheel(true)
  
  local contentFrame = CreateFrame("Frame", nil, scrollFrame)
  contentFrame:SetWidth(scrollFrame:GetWidth() - 20)
  contentFrame:SetHeight(1)
  scrollFrame:SetScrollChild(contentFrame)
  
  return scrollFrame, contentFrame
end

-- Dungeons scroll in insideDungeons frame
djScrollFrame, dungeonListContentFrame = createScrollFrame("Dungeons", insideDungeons)

-- Raids scroll in insideRaids frame  
raidScrollFrame, raidListContentFrame = createScrollFrame("Raids", insideRaids)

-- Force initial visibility for tab 1
djScrollFrame:Show()
raidScrollFrame:Hide()

--------------------------------------------------
-- Raid Size Slider
--------------------------------------------------
raidGroupSize = 0

local function createRaidSizeControls(parent)
  local raidSizeFrame = CreateFrame("Frame", nil, parent)
  raidSizeFrame:SetPoint("BOTTOM", parent, "BOTTOM", -16, 75)
  raidSizeFrame:SetWidth(300)
  raidSizeFrame:SetHeight(30)
  raidSizeFrame:Hide()
  
  local raidSizeIcon = raidSizeFrame:CreateTexture(nil, "ARTWORK")
  raidSizeIcon:SetPoint("LEFT", raidSizeFrame, "LEFT", 0, 0)
  raidSizeIcon:SetWidth(18)
  raidSizeIcon:SetHeight(18)
  raidSizeIcon:SetTexture(TEXTURE_BASE_PATH .. "Icons\\group")
  
  local raidSizeEditBox = CreateFrame("EditBox", "AutoLFM_RaidSizeEditBox", raidSizeFrame)
  raidSizeEditBox:SetPoint("LEFT", raidSizeIcon, "RIGHT", 10, 0)
  raidSizeEditBox:SetWidth(25)
  raidSizeEditBox:SetHeight(20)
  raidSizeEditBox:SetFont("Fonts\\FRIZQT__.TTF", 12)
  raidSizeEditBox:SetJustifyH("CENTER")
  raidSizeEditBox:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 8,
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
  })
  raidSizeEditBox:SetBackdropColor(0, 0, 0, 0.8)
  raidSizeEditBox:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
  raidSizeEditBox:SetAutoFocus(false)
  raidSizeEditBox:SetMaxLetters(2)
  raidSizeEditBox:SetText("18")
  raidSizeEditBox:SetTextInsets(2, 2, 0, 0)
  
  local iconButton = CreateFrame("Button", nil, raidSizeFrame)
  iconButton:SetAllPoints(raidSizeIcon)
  iconButton:SetScript("OnClick", function()
    raidSizeEditBox:SetFocus()
    raidSizeEditBox:HighlightText()
  end)
  
  local raidSizeSlider = CreateFrame("Slider", "AutoLFM_RaidSizeSlider", raidSizeFrame)
  raidSizeSlider:SetPoint("LEFT", raidSizeEditBox, "RIGHT", 10, 0)
  raidSizeSlider:SetWidth(135)
  raidSizeSlider:SetHeight(17)
  raidSizeSlider:SetMinMaxValues(10, 40)
  raidSizeSlider:SetValue(25)
  raidSizeSlider:SetValueStep(1)
  raidSizeSlider:SetOrientation("HORIZONTAL")
  raidSizeSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
  raidSizeSlider:SetBackdrop({
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
    tile = true,
    tileSize = 8,
    edgeSize = 8,
    insets = {left = 3, right = 3, top = 6, bottom = 6}
  })
  raidSizeSlider:EnableMouse(true)
  
  return raidSizeFrame, raidSizeEditBox, raidSizeSlider
end

raidSizeControlFrame, raidSizeValueEditBox, raidSizeSlider = createRaidSizeControls(AutoLFM_MainFrame)

if CreateColorFilterUI then
  dungeonFilterFrame = CreateColorFilterUI(AutoLFM_MainFrame)
  if dungeonFilterFrame then
    dungeonFilterFrame:Show()
  end
end

function UpdateRaidSizeDisplay(value)
  if value then
    raidSizeValueEditBox:SetText(tostring(value))
  else
    raidSizeValueEditBox:SetText("")
  end
end

raidSizeSlider:SetScript("OnValueChanged", function()
  local value = raidSizeSlider:GetValue()
  raidGroupSize = value
  UpdateRaidSizeDisplay(value)
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end)

raidSizeValueEditBox:SetScript("OnTextChanged", function()
  local value = tonumber(raidSizeValueEditBox:GetText())
  if value then
    local minVal, maxVal = raidSizeSlider:GetMinMaxValues()
    if value >= minVal and value <= maxVal then
      raidSizeSlider:SetValue(value)
    end
  end
end)

--------------------------------------------------
-- Inside More - Message Details EditBox
--------------------------------------------------
local function setupPlaceholder(editBox, placeholderText)
  local placeholder = editBox:CreateFontString(nil, "OVERLAY", "GameFontDisable")
  placeholder:SetText(placeholderText)
  placeholder:SetPoint("CENTER", editBox, "CENTER", 0, 0)
  
  local function updatePlaceholder()
    if editBox:GetText() == "" then
      placeholder:Show()
    else
      placeholder:Hide()
    end
  end
  
  editBox:SetScript("OnEditFocusGained", function()
    placeholder:Hide()
    if UpdateEditBoxFocusState then
      UpdateEditBoxFocusState(true)
    end
  end)
  
  editBox:SetScript("OnEditFocusLost", function()
    if UpdateEditBoxFocusState then
      UpdateEditBoxFocusState(false)
    end
    updatePlaceholder()
  end)
  
  editBox:SetScript("OnTextChanged", function()
    customUserMessage = editBox:GetText()
    if UpdateDynamicMessage then
      UpdateDynamicMessage()
    end
    updatePlaceholder()
  end)
  
  editBox:SetScript("OnEnterPressed", function()
    editBox:ClearFocus()
  end)
  
  editBox:SetScript("OnEscapePressed", function()
    editBox:ClearFocus()
  end)
  
  updatePlaceholder()
end

customMessageEditBox = CreateFrame("EditBox", "AutoLFM_EditBox", moreTabContentFrame)
customMessageEditBox:SetPoint("TOP", moreTabContentFrame, "TOP", 0, -10)
customMessageEditBox:SetWidth(270)
customMessageEditBox:SetHeight(30)
customMessageEditBox:SetAutoFocus(false)
customMessageEditBox:SetFont("Fonts\\FRIZQT__.TTF", 14)
customMessageEditBox:SetMaxLetters(150)
customMessageEditBox:SetText("")
customMessageEditBox:SetTextColor(1, 1, 1)
customMessageEditBox:SetBackdrop({
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true,
  tileSize = 8,
  edgeSize = 16,
  insets = { left = 8, right = 2, top = 2, bottom = 2 }
})
customMessageEditBox:SetBackdropColor(0, 0, 0, 0.8)
customMessageEditBox:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
customMessageEditBox:SetJustifyH("CENTER")
customMessageEditBox:SetTextInsets(10, 10, 5, 5)

setupPlaceholder(customMessageEditBox, "Add message details (optional)")

--------------------------------------------------
-- Inside More - Broadcast Interval Slider
--------------------------------------------------
local function SnapToStep(value)
  if not value then return step end
  local roundedValue = math.floor(value / step + 0.5) * step
  return roundedValue
end

broadcastIntervalFrame = CreateFrame("Frame", nil, moreTabContentFrame)
broadcastIntervalFrame:SetPoint("TOP", customMessageEditBox, "BOTTOM", 0, -30)
broadcastIntervalFrame:SetWidth(250)
broadcastIntervalFrame:SetHeight(50)
broadcastIntervalFrame:SetBackdrop({
  bgFile = nil,
  edgeSize = 16,
  insets = { left = 4, right = 2, top = 4, bottom = 4 },
})
broadcastIntervalFrame:SetBackdropColor(1, 1, 1, 0.3)
broadcastIntervalFrame:SetBackdropBorderColor(1, 1, 1, 1)

broadcastIntervalSlider = CreateFrame("Slider", nil, broadcastIntervalFrame, "OptionsSliderTemplate")
broadcastIntervalSlider:SetWidth(200)
broadcastIntervalSlider:SetHeight(20)
broadcastIntervalSlider:SetPoint("CENTER", broadcastIntervalFrame, "CENTER", 0, 0)
broadcastIntervalSlider:SetMinMaxValues(40, 120)
broadcastIntervalSlider:SetValue(80)
broadcastIntervalSlider:SetValueStep(10)

local valueText = broadcastIntervalSlider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
valueText:SetPoint("BOTTOM", broadcastIntervalSlider, "TOP", 0, 5)
valueText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
valueText:SetText("Dispense every 80 seconds")

broadcastIntervalSlider:SetScript("OnValueChanged", function()
  local value = broadcastIntervalSlider:GetValue()
  if value then
    valueText:SetText("Dispense every " .. value .. " seconds")
  end
end)

local lastSliderUpdate = 0
local SLIDER_UPDATE_THROTTLE = 0.1

broadcastIntervalFrame:SetScript("OnUpdate", function()
  local now = GetTime()
  if now - lastSliderUpdate < SLIDER_UPDATE_THROTTLE then return end
  lastSliderUpdate = now
  
  local currentValue = broadcastIntervalSlider:GetValue()
  if currentValue then
    local snappedValue = SnapToStep(currentValue)
    if currentValue ~= snappedValue then
      broadcastIntervalSlider:SetValue(snappedValue)
    end
  end
end)

--------------------------------------------------
-- Start/Stop Button
--------------------------------------------------
broadcastToggleButton = CreateFrame("Button", "ToggleButton", AutoLFM_MainFrame, "UIPanelButtonTemplate")
broadcastToggleButton:SetPoint("BOTTOM", AutoLFM_MainFrame, "BOTTOM", 97, 80)
broadcastToggleButton:SetWidth(110)
broadcastToggleButton:SetHeight(21)
broadcastToggleButton:SetText("Start")

broadcastToggleButton:SetScript("OnClick", function()
  if isBroadcastActive then
    if StopBroadcast then
      StopBroadcast()
    end
    broadcastToggleButton:SetText("Start")
    PlaySoundFile("Interface\\AddOns\\AutoLFM\\UI\\Sounds\\LFG_Denied.ogg")
    groupSearchStartTimestamp = 0
  else
    if EnsureChannelUIExists then
      EnsureChannelUIExists()
    end
    
    local success = StartBroadcast()
    
    if success then
      broadcastToggleButton:SetText("Stop")
      PlaySoundFile("Interface\\AddOns\\AutoLFM\\UI\\Sounds\\LFG_RoleCheck.ogg")
      groupSearchStartTimestamp = GetTime()
    end
  end
end)

--------------------------------------------------
-- Events
--------------------------------------------------
AutoLFM_MainFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
AutoLFM_MainFrame:RegisterEvent("RAID_ROSTER_UPDATE")

local function HandleGroupFull(contentType, maxSize)
  if StopBroadcast then StopBroadcast() end
  if contentType == "raid" then
    if ClearRaidSelection then ClearRaidSelection() end
  else
    if ClearDungeonSelection then ClearDungeonSelection() end
  end
  if ClearAllRoles then ClearAllRoles() end
  if ResetCustomMessage then ResetCustomMessage() end
  if UpdateDynamicMessage then UpdateDynamicMessage() end
  if broadcastToggleButton then broadcastToggleButton:SetText("Start") end
  PlaySoundFile("Interface\\AddOns\\AutoLFM\\UI\\Sounds\\LFG_Denied.ogg")
end

AutoLFM_MainFrame:SetScript("OnEvent", function()
  if event == "RAID_ROSTER_UPDATE" then
    if HandleRaidRosterUpdate then
      HandleRaidRosterUpdate()
    end
  elseif event == "PARTY_MEMBERS_CHANGED" then
    local hasRaid = selectedRaidTags and selectedRaidTags[1]
    local hasDungeon = selectedDungeonTags and selectedDungeonTags[1]
    
    if hasRaid then
      local totalPlayersInRaid = GetRaidMemberCount and GetRaidMemberCount() or 0
      if raidGroupSize == totalPlayersInRaid then
        HandleGroupFull("raid", raidGroupSize)
      else
        if HandlePartyUpdate then HandlePartyUpdate() end
      end
    elseif hasDungeon then
      local totalPlayersInGroup = GetPartyMemberCount and GetPartyMemberCount() or 0
      if totalPlayersInGroup >= 5 then
        HandleGroupFull("dungeon", 5)
      else
        if HandlePartyUpdate then HandlePartyUpdate() end
      end
    end
  end
end)

--------------------------------------------------
-- Display Lists After Frames Created
--------------------------------------------------
local displayFrame = CreateFrame("Frame")
displayFrame:RegisterEvent("PLAYER_LOGIN")

displayFrame:SetScript("OnEvent", function()
  if event == "PLAYER_LOGIN" then
    if AutoLFM_DungeonList and dungeonListContentFrame then
      AutoLFM_DungeonList.Display(dungeonListContentFrame)
    end
    
    if AutoLFM_RaidList and raidListContentFrame then
      AutoLFM_RaidList.Display(raidListContentFrame)
    end
    
    displayFrame:UnregisterEvent("PLAYER_LOGIN")
  end
end)

-- Backward compatibility alias
AutoLFM = AutoLFM_MainFrame