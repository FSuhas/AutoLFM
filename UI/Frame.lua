--------------------------------------------------
-- Local Variables
--------------------------------------------------
local currentTab = 1
local tabs = {}
local editBoxHasFocus = false
local currentSliderFrame = nil
local step = 10

--------------------------------------------------
-- Main Frame
--------------------------------------------------
AutoLFM = CreateFrame("Frame", "AutoLFM", UIParent)
UIPanelWindows["AutoLFM"] = { area = "left", pushable = 3 }
AutoLFM:SetWidth(384)
AutoLFM:SetHeight(512)
AutoLFM:Hide()

local mainTexture = AutoLFM:CreateTexture(nil, "BACKGROUND")
mainTexture:SetPoint("TOPLEFT", AutoLFM, "TOPLEFT", 0, 0)
mainTexture:SetWidth(512)
mainTexture:SetHeight(512)
mainTexture:SetTexture(texturePath .. "mainFrame")

local mainIcon = AutoLFM:CreateTexture(nil, "LOW")
mainIcon:SetPoint("TOPLEFT", AutoLFM, "TOPLEFT", 7, -4)
mainIcon:SetWidth(64)
mainIcon:SetHeight(64)
mainIcon:SetTexture(texturePath .. "Eyes\\eye01")
AutoLFMMainIcon = mainIcon

local mainTitle = AutoLFM:CreateFontString(nil, "MEDIUM", "GameFontNormal")
mainTitle:SetPoint("TOP", AutoLFM, "TOP", 0, -18)
mainTitle:SetText("AutoLFM")

local close = CreateFrame("Button", nil, AutoLFM, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", AutoLFM, "TOPRIGHT", -27, -8)
close:SetScript("OnClick", function() HideUIPanel(AutoLFM) end)

--------------------------------------------------
-- Roles
--------------------------------------------------
local function createRole(name, x, texCoordStart)
  local btn = CreateFrame("Button", nil, AutoLFM)
  btn:SetPoint("TOPLEFT", AutoLFM, "TOPLEFT", x, -52)
  btn:SetWidth(54)
  btn:SetHeight(54)
  btn:SetHighlightTexture(texturePath .. "rolesHighlight")
  
  local bg = btn:CreateTexture(nil, "BACKGROUND")
  bg:SetPoint("TOPLEFT", btn, "TOPLEFT", -12, 14)
  bg:SetWidth(84)
  bg:SetHeight(84)
  bg:SetTexture(texturePath .. "rolesBackground")
  bg:SetTexCoord(texCoordStart, texCoordStart + 0.2968, 0, 0.5937)
  bg:SetVertexColor(1, 1, 1, 0.6)
  
  local icon = btn:CreateTexture(nil, "BORDER")
  icon:SetAllPoints(btn)
  icon:SetTexture(texturePath .. "roles" .. name)
  
  local check = CreateFrame("CheckButton", nil, AutoLFM, "UICheckButtonTemplate")
  check:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 1, -5)
  check:SetWidth(24)
  check:SetHeight(24)
  check:SetScript("OnClick", function() 
    if toggleRole then 
      toggleRole(name) 
    end 
  end)
  
  roleChecks[name] = check
  btn:SetScript("OnClick", function() check:Click() end)
  
  return btn, bg, icon, check
end

createRole("Tank", 74, 0.2968)
createRole("Heal", 172, 0)
createRole("DPS", 270, 0.5937)

--------------------------------------------------
-- Dynamic Message Frames
--------------------------------------------------
msgFrameDj = CreateFrame("Frame", nil, AutoLFM)
msgFrameDj:SetPoint("TOP", AutoLFM, "TOP", -10, -125)
msgFrameDj:SetWidth(330)
msgFrameDj:SetHeight(30)

msgTextDj = msgFrameDj:CreateFontString(nil, "MEDIUM", "GameFontHighlight")
msgTextDj:SetPoint("CENTER", msgFrameDj, "CENTER", 0, 0)

msgFrameRaids = CreateFrame("Frame", nil, AutoLFM)
msgFrameRaids:SetPoint("TOP", AutoLFM, "TOP", -10, -125)
msgFrameRaids:SetWidth(330)
msgFrameRaids:SetHeight(30)

msgTextRaids = msgFrameRaids:CreateFontString(nil, "MEDIUM", "GameFontHighlight")
msgTextRaids:SetPoint("CENTER", msgFrameRaids, "CENTER", 0, 0)
msgTextRaids:SetTextColor(1, 1, 1)

--------------------------------------------------
-- Tab System
--------------------------------------------------
local function onTabClick(tabNum)
  currentTab = tabNum
  
  if insideList then
    if tabNum <= 2 then 
      insideList:Show() 
    else 
      insideList:Hide() 
    end
  end
  
  if insideMore then
    if tabNum == 3 then 
      insideMore:Show() 
    else 
      insideMore:Hide() 
    end
  end
  
  for i = 1, 3 do
    local active = i == tabNum
    tabs[i].bg:SetTexture(texturePath .. (active and "tabActive" or "tabInactive"))
    tabs[i].text:SetTextColor(1, active and 1 or 0.82, active and 1 or 0)
    if active then 
      tabs[i].highlight:Hide() 
    end
  end
end

local function createTab(index, label, onClick, anchorTo)
  local tab = CreateFrame("Button", nil, AutoLFM)
  tab:SetPoint(anchorTo and "LEFT" or "BOTTOMLEFT", anchorTo or AutoLFM, anchorTo and "RIGHT" or "BOTTOMLEFT", anchorTo and -5 or 20, anchorTo and 0 or 46)
  tab:SetWidth(90)
  tab:SetHeight(32)
  
  local bg = tab:CreateTexture(nil, "BACKGROUND")
  bg:SetTexture(texturePath .. (index == 1 and "tabActive" or "tabInactive"))
  bg:SetAllPoints()
  
  local highlight = tab:CreateTexture(nil, "BORDER")
  highlight:SetPoint("CENTER", tab, "CENTER", 0, 0)
  highlight:SetWidth(70)
  highlight:SetHeight(24)
  highlight:SetTexture(texturePath .. "tabHighlight")
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
local function onDungeonsTab()
  if djScrollFrame then djScrollFrame:Show() end
  if raidFrame then raidFrame:Hide() end
  if raidContentFrame then raidContentFrame:Hide() end
  if raidScrollFrame then raidScrollFrame:Hide() end
  if msgFrameDj then msgFrameDj:Show() end
  if msgFrameRaids then msgFrameRaids:Hide() end
  if dungeonFilterFrame then dungeonFilterFrame:Show() end
  if clearSelectedRaids then clearSelectedRaids() end
  if clearSelectedRoles then clearSelectedRoles() end
  if resetUserInputMessage then resetUserInputMessage() end
  if updateMsgFrameCombined then updateMsgFrameCombined() end
  if HideSliderForRaid then HideSliderForRaid() end
  if EnsureChannelFrameExists then EnsureChannelFrameExists() end
  
  if AutoLFM_RaidList and AutoLFM_RaidList.ClearBackdrops then
    AutoLFM_RaidList.ClearBackdrops()
  end
end

local function onRaidsTab()
  if djScrollFrame then djScrollFrame:Hide() end
  if raidFrame then raidFrame:Show() end
  if raidContentFrame then raidContentFrame:Show() end
  if raidScrollFrame then raidScrollFrame:Show() end
  if msgFrameDj then msgFrameDj:Hide() end
  if msgFrameRaids then msgFrameRaids:Show() end
  if dungeonFilterFrame then dungeonFilterFrame:Hide() end
  if clearSelectedDungeons then clearSelectedDungeons() end
  if clearSelectedRoles then clearSelectedRoles() end
  if resetUserInputMessage then resetUserInputMessage() end
  if updateMsgFrameCombined then updateMsgFrameCombined() end
  if EnsureChannelFrameExists then EnsureChannelFrameExists() end
  
  if AutoLFM_DungeonList and AutoLFM_DungeonList.ClearBackdrops then
    AutoLFM_DungeonList.ClearBackdrops()
  end
end

local function onMoreTab()
  if djScrollFrame then djScrollFrame:Hide() end
  if raidFrame then raidFrame:Hide() end
  if raidContentFrame then raidContentFrame:Hide() end
  if raidScrollFrame then raidScrollFrame:Hide() end
  
  if InitializeChannelFrame then InitializeChannelFrame() end
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
insideList = CreateFrame("Frame", nil, AutoLFM)
insideList:SetPoint("TOPLEFT", AutoLFM, "TOPLEFT", 25, -157)
insideList:SetWidth(323)
insideList:SetHeight(253)
insideList:SetFrameStrata("HIGH")
insideList:Show()

insideMore = CreateFrame("Frame", nil, AutoLFM)
insideMore:SetPoint("TOPLEFT", AutoLFM, "TOPLEFT", 25, -157)
insideMore:SetWidth(295)
insideMore:SetHeight(253)
insideMore:SetFrameStrata("HIGH")
insideMore:Hide()

createTabs()

--------------------------------------------------
-- Scroll Frames
--------------------------------------------------
local function createScrollFrame(name, parent)
  local frame = CreateFrame("Frame", nil, parent)
  frame:SetAllPoints(parent)
  if name == "raids" then frame:Hide() end
  
  local scrollFrame = CreateFrame("ScrollFrame", "AutoLFM_ScrollFrame_" .. name, parent, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", -1, 0)
  scrollFrame:SetWidth(295)
  scrollFrame:SetHeight(253)
  scrollFrame:EnableMouse(true)
  scrollFrame:EnableMouseWheel(true)
  if name == "raids" then scrollFrame:Hide() end
  
  local contentFrame = CreateFrame("Frame", nil, scrollFrame)
  contentFrame:SetWidth(scrollFrame:GetWidth() - 20)
  contentFrame:SetHeight(1)
  scrollFrame:SetScrollChild(contentFrame)
  
  return frame, scrollFrame, contentFrame
end

djframe, djScrollFrame, contentFrame = createScrollFrame("Dungeons", insideList)
raidFrame, raidScrollFrame, raidContentFrame = createScrollFrame("raids", insideList)

--------------------------------------------------
-- Raid Size Slider
--------------------------------------------------
sliderValue = 0

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
  raidSizeIcon:SetTexture(texturePath .. "Icons\\group")
  
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

sliderSizeFrame, sliderSizeEditBox, sliderSize = createRaidSizeControls(AutoLFM)

if CreateDungeonFilterCheckboxes then
  dungeonFilterFrame = CreateDungeonFilterCheckboxes(AutoLFM)
  if dungeonFilterFrame then
    dungeonFilterFrame:Show()
  end
end

function UpdateSliderText(value)
  if value then
    sliderSizeEditBox:SetText(tostring(value))
  else
    sliderSizeEditBox:SetText("")
  end
end

function HideSliderForRaid()
  if sliderSizeFrame then
    sliderSizeFrame:Hide()
  end
  if currentSliderFrame then
    currentSliderFrame:Hide()
    currentSliderFrame = nil
  end
  sliderValue = 0
end

sliderSize:SetScript("OnValueChanged", function()
  local value = sliderSize:GetValue()
  sliderValue = value
  raidSize = value
  UpdateSliderText(value)
  if updateMsgFrameCombined then
    updateMsgFrameCombined()
  end
end)

sliderSizeEditBox:SetScript("OnTextChanged", function()
  local value = tonumber(sliderSizeEditBox:GetText())
  if value then
    local minVal, maxVal = sliderSize:GetMinMaxValues()
    if value >= minVal and value <= maxVal then
      sliderSize:SetValue(value)
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
    userInputMessage = editBox:GetText()
    if updateMsgFrameCombined then
      updateMsgFrameCombined()
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

editBox = CreateFrame("EditBox", "AutoLFM_EditBox", insideMore)
editBox:SetPoint("TOP", insideMore, "TOP", 0, -10)
editBox:SetWidth(270)
editBox:SetHeight(30)
editBox:SetAutoFocus(false)
editBox:SetFont("Fonts\\FRIZQT__.TTF", 14)
editBox:SetMaxLetters(150)
editBox:SetText("")
editBox:SetTextColor(1, 1, 1)
editBox:SetBackdrop({
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true,
  tileSize = 8,
  edgeSize = 16,
  insets = { left = 8, right = 2, top = 2, bottom = 2 }
})
editBox:SetBackdropColor(0, 0, 0, 0.8)
editBox:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
editBox:SetJustifyH("CENTER")
editBox:SetTextInsets(10, 10, 5, 5)

setupPlaceholder(editBox, "Add message details (optional)")

--------------------------------------------------
-- Inside More - Broadcast Interval Slider
--------------------------------------------------
local function SnapToStep(value)
  if not value then return step end
  local roundedValue = math.floor(value / step + 0.5) * step
  return roundedValue
end

sliderframe = CreateFrame("Frame", nil, insideMore)
sliderframe:SetPoint("TOP", editBox, "BOTTOM", 0, -30)
sliderframe:SetWidth(250)
sliderframe:SetHeight(50)
sliderframe:SetBackdrop({
  bgFile = nil,
  edgeSize = 16,
  insets = { left = 4, right = 2, top = 4, bottom = 4 },
})
sliderframe:SetBackdropColor(1, 1, 1, 0.3)
sliderframe:SetBackdropBorderColor(1, 1, 1, 1)

slider = CreateFrame("Slider", nil, sliderframe, "OptionsSliderTemplate")
slider:SetWidth(200)
slider:SetHeight(20)
slider:SetPoint("CENTER", sliderframe, "CENTER", 0, 0)
slider:SetMinMaxValues(40, 120)
slider:SetValue(80)
slider:SetValueStep(10)

local valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
valueText:SetPoint("BOTTOM", slider, "TOP", 0, 5)
valueText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
valueText:SetText("Dispense every 80 seconds")

slider:SetScript("OnValueChanged", function()
  local value = slider:GetValue()
  if value then
    valueText:SetText("Dispense every " .. value .. " seconds")
  end
end)

local lastSliderUpdate = 0
local SLIDER_UPDATE_THROTTLE = 0.1

sliderframe:SetScript("OnUpdate", function()
  local now = GetTime()
  if now - lastSliderUpdate < SLIDER_UPDATE_THROTTLE then return end
  lastSliderUpdate = now
  
  local currentValue = slider:GetValue()
  if currentValue then
    local snappedValue = SnapToStep(currentValue)
    if currentValue ~= snappedValue then
      slider:SetValue(snappedValue)
    end
  end
end)

--------------------------------------------------
-- Start/Stop Button
--------------------------------------------------
toggleButton = CreateFrame("Button", "ToggleButton", AutoLFM, "UIPanelButtonTemplate")
toggleButton:SetPoint("BOTTOM", AutoLFM, "BOTTOM", 97, 80)
toggleButton:SetWidth(110)
toggleButton:SetHeight(21)
toggleButton:SetText("Start")

toggleButton:SetScript("OnClick", function()
  if isBroadcasting then
    -- Stop broadcast
    if stopMessageBroadcast then
      stopMessageBroadcast()
    end
    toggleButton:SetText("Start")
    PlaySoundFile("Interface\\AddOns\\AutoLFM\\UI\\Sounds\\LFG_Denied.ogg")
    searchStartTime = 0
  else
    -- Ensure channel frame exists
    if EnsureChannelFrameExists then
      EnsureChannelFrameExists()
    end
    
    -- Start broadcast (validation is done inside)
    local success = startMessageBroadcast()
    
    if success then
      toggleButton:SetText("Stop")
      PlaySoundFile("Interface\\AddOns\\AutoLFM\\UI\\Sounds\\LFG_RoleCheck.ogg")
      searchStartTime = GetTime()
    end
    -- If failed, startMessageBroadcast already printed errors
  end
end)

--------------------------------------------------
-- Events
--------------------------------------------------
AutoLFM:RegisterEvent("PARTY_MEMBERS_CHANGED")
AutoLFM:RegisterEvent("RAID_ROSTER_UPDATE")

local function HandleGroupFull(contentType, maxSize)
  if stopMessageBroadcast then stopMessageBroadcast() end
  if contentType == "raid" then
    if clearSelectedRaids then clearSelectedRaids() end
  else
    if clearSelectedDungeons then clearSelectedDungeons() end
  end
  if clearSelectedRoles then clearSelectedRoles() end
  if resetUserInputMessage then resetUserInputMessage() end
  if updateMsgFrameCombined then updateMsgFrameCombined() end
  if toggleButton then toggleButton:SetText("Start") end
  PlaySoundFile("Interface\\AddOns\\AutoLFM\\UI\\Sounds\\LFG_Denied.ogg")
end

AutoLFM:SetScript("OnEvent", function()
  if event == "RAID_ROSTER_UPDATE" then
    if OnRaidRosterUpdate then
      OnRaidRosterUpdate()
    end
  elseif event == "PARTY_MEMBERS_CHANGED" then
    local hasRaid = selectedRaids and selectedRaids[1]
    local hasDungeon = selectedDungeons and selectedDungeons[1]
    
    if hasRaid then
      local totalPlayersInRaid = countRaidMembers and countRaidMembers() or 0
      if raidSize == totalPlayersInRaid then
        HandleGroupFull("raid", raidSize)
      else
        if OnGroupUpdate then OnGroupUpdate() end
      end
    elseif hasDungeon then
      local totalPlayersInGroup = countGroupMembers and countGroupMembers() or 0
      if totalPlayersInGroup >= 5 then
        HandleGroupFull("dungeon", 5)
      else
        if OnGroupUpdate then OnGroupUpdate() end
      end
    end
  end
end)

--------------------------------------------------
-- Display Lists After Frames Created
--------------------------------------------------
if AutoLFM_DungeonList and contentFrame then
  AutoLFM_DungeonList.Display(contentFrame)
end

if AutoLFM_RaidList and raidContentFrame then
  AutoLFM_RaidList.Display(raidContentFrame)
end