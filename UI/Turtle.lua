local FRAME_CONFIG = {
  SIZE = {384, 512},
  ROLE_SIZE = {54, 54},
  BUTTON_SIZE = {104, 21},
  ENTRY_HEIGHT = 20,
  POSITION = {0, -104},
  TAB_POSITIONS = {
    {20, 45},
    {110, 45},
    {250, 45}
  }
}

local TEXTURES = {
  PORTRAIT = "Interface\\AddOns\\AutoLFM\\icon\\portrait",
  FRAME = "Interface\\FrameXML\\LFT\\images\\ui-lfg-frame",
  BACKGROUND = "Interface\\FrameXML\\LFT\\images\\ui-lfg-background-dungeonwall",
  TAB_ACTIVE = "Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab",
  TAB_INACTIVE = "Interface\\PaperDollInfoFrame\\UI-Character-InactiveTab",
  TAB_HIGHLIGHT = "Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight"
}

local COLORS = {
  TAB_ACTIVE = {0.8, 0.8, 0.8},
  TAB_INACTIVE = {1, 0.82, 0},
  ROLE_BG_ALPHA = 0.6
}

local SLIDER_CONFIG = {
  SIZE = {295, 30},
  EDITBOX_SIZE = {25, 20},
  SLIDER_SIZE = {120, 17},
  MIN_VALUE = 10,
  MAX_VALUE = 40,
  DEFAULT_VALUE = 25,
  BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
    tile = true, 
    tileSize = 32, 
    edgeSize = 8, 
    insets = {left = 4, right = 4, top = 4, bottom = 4}
  },
  SLIDER_BACKDROP = {
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background", 
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", 
    tile = true, 
    tileSize = 8, 
    edgeSize = 8, 
    insets = {left = 3, right = 3, top = 6, bottom = 6}
  }
}

local SCROLL_CONFIG = {
  POSITION = {25, -158},
  DUNGEON_SIZE = {295, 252},
  RAID_SIZE = {295, 220}
}

local ROLE_DATA = {
  {
    name = "Tank",
    coord = {0.2968, 0.5937, 0, 0.5937},
    texture = "Interface\\FrameXML\\LFT\\images\\tank2",
    backgroundTexture = "Interface\\FrameXML\\LFT\\images\\ui-lfg-role-background"
  },
  {
    name = "Heal",
    coord = {0, 0.2968, 0, 0.5937},
    texture = "Interface\\FrameXML\\LFT\\images\\healer2",
    backgroundTexture = "Interface\\FrameXML\\LFT\\images\\ui-lfg-role-background"
  },
  {
    name = "Dps",
    coord = {0.5937, 0.8906, 0, 0.5937},
    texture = "Interface\\FrameXML\\LFT\\images\\damage2",
    backgroundTexture = "Interface\\FrameXML\\LFT\\images\\ui-lfg-role-background"
  }
}

-- Utility functions
local function setSize(obj, w, h)
  obj:SetWidth(w)
  obj:SetHeight(h)
end

-- Main frame creation
local function createMainFrame()
  local frame = CreateFrame("Frame", "AutoLFMTurtleFrame", UIParent)
  setSize(frame, FRAME_CONFIG.SIZE[1], FRAME_CONFIG.SIZE[2])
  frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", FRAME_CONFIG.POSITION[1], FRAME_CONFIG.POSITION[2])
  frame:EnableMouse(true)
  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function() this:StartMoving() end)
  frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
  frame:Hide()
  return frame
end

local function createFrameElements(frame)
  local portrait = frame:CreateTexture(nil, "BACKGROUND")
  portrait:SetTexture(TEXTURES.PORTRAIT)
  setSize(portrait, 64, 64)
  portrait:SetPoint("TOPLEFT", 7, -6)

  local title = frame:CreateFontString("AutoLFMTurtleFrameTitle", "OVERLAY", "GameFontNormal")
  title:SetText("AutoLFM")
  title:SetPoint("TOP", 0, -18)

  local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -27, -8)
  closeBtn:SetScript("OnClick", function() frame:Hide() end)

  local frameTexture = frame:CreateTexture(nil, "ARTWORK")
  frameTexture:SetTexture(TEXTURES.FRAME)
  setSize(frameTexture, 512, 512)
  frameTexture:SetPoint("TOPLEFT", frame, "TOPLEFT")

  local bgWall = frame:CreateTexture(nil, "BACKGROUND")
  bgWall:SetTexture(TEXTURES.BACKGROUND)
  setSize(bgWall, 512, 256)
  bgWall:SetPoint("TOP", 85, -155)
end

local AutoLFMTurtleFrame = createMainFrame()
local frameElements = createFrameElements(AutoLFMTurtleFrame)

local function setupPlaceholder(editBox, text)
  local placeholder = editBox:CreateFontString(nil, "OVERLAY", "GameFontDisable")
  placeholder:SetText(text)
  placeholder:SetPoint("CENTER", editBox, "CENTER", 0, 0)
  local function updatePlaceholder()
    if editBox:GetText() == "" then placeholder:Show() else placeholder:Hide() end
  end
  editBox:SetScript("OnEditFocusGained", function() placeholder:Hide() end)
  editBox:SetScript("OnEditFocusLost", updatePlaceholder)
  editBox:SetScript("OnTextChanged", updatePlaceholder)
  updatePlaceholder()
end
local editBox = CreateFrame("EditBox", "AutoLFMTurtleFrameEditBox", AutoLFMTurtleFrame, "InputBoxTemplate")
  setSize(editBox, 250, 32)
  editBox:SetPoint("TOP", AutoLFMTurtleFrame, "TOP", -10, -125)
  editBox:SetAutoFocus(false)
  editBox:SetMaxLetters(50)
  setupPlaceholder(editBox, "Add broadcast details")

-- Raid size controls
local function createRaidSizeControls(parent)
  local sliderBg = CreateFrame("Frame", nil, parent)
  setSize(sliderBg, SLIDER_CONFIG.SIZE[1], SLIDER_CONFIG.SIZE[2])
  sliderBg:SetPoint("BOTTOM", parent, "BOTTOM", -20, 105)
  sliderBg:SetBackdrop(SLIDER_CONFIG.BACKDROP)
  sliderBg:Hide()
  local label = sliderBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetText("Group Size:")
  label:SetPoint("LEFT", sliderBg, "LEFT", 10, 0)
  local sizeEditBox = CreateFrame("EditBox", "AutoLFMTurtleFrameSizeEditBox", sliderBg, "InputBoxTemplate")
  setSize(sizeEditBox, SLIDER_CONFIG.EDITBOX_SIZE[1], SLIDER_CONFIG.EDITBOX_SIZE[2])
  sizeEditBox:SetPoint("LEFT", label, "RIGHT", 25, 0)
  sizeEditBox:SetAutoFocus(false)
  sizeEditBox:SetMaxLetters(2)
  sizeEditBox:SetText(tostring(SLIDER_CONFIG.DEFAULT_VALUE))
  local slider = CreateFrame("Slider", "AutoLFMTurtleFrameRaidSizeSlider", sliderBg)
  setSize(slider, SLIDER_CONFIG.SLIDER_SIZE[1], SLIDER_CONFIG.SLIDER_SIZE[2])
  slider:SetPoint("LEFT", sizeEditBox, "RIGHT", 20, 0)
  slider:SetMinMaxValues(SLIDER_CONFIG.MIN_VALUE, SLIDER_CONFIG.MAX_VALUE)
  slider:SetValue(SLIDER_CONFIG.DEFAULT_VALUE)
  slider:SetValueStep(1)
  slider:SetOrientation("HORIZONTAL")
  slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
  slider:SetBackdrop(SLIDER_CONFIG.SLIDER_BACKDROP)
  slider:SetScript("OnValueChanged", function()
    local value = slider:GetValue()
    sizeEditBox:SetText(tostring(value))
  end)
  sizeEditBox:SetScript("OnTextChanged", function()
    local value = tonumber(sizeEditBox:GetText())
    if value and value >= SLIDER_CONFIG.MIN_VALUE and value <= SLIDER_CONFIG.MAX_VALUE then
      slider:SetValue(value)
    end
  end)
  return {
    background = sliderBg,
    label = label,
    editBox = sizeEditBox,
    slider = slider
  }
end

local raidSizeControls = createRaidSizeControls(AutoLFMTurtleFrame)

-- Instance list management
local showingRaids = false
local currentScrollContent = nil
local selectedRaid = nil
local selectedDungeons = {}

local function getInstanceData()
  local dungeonData = {}
  local raidData = {}
  
  if type(donjons) == "table" and table.getn(donjons) > 0 then
    dungeonData = donjons
  end
  
  if type(raids) == "table" and table.getn(raids) > 0 then
    raidData = raids
  end
  
  return dungeonData, raidData
end

local donjons, raids = getInstanceData()

local function createScrollFrame(parent)
  local scrollFrame = CreateFrame("ScrollFrame", "AutoLFMTurtleFrameInstancesList", parent, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", SCROLL_CONFIG.POSITION[1], SCROLL_CONFIG.POSITION[2])
  scrollFrame:SetFrameLevel(parent:GetFrameLevel() + 1)
  return scrollFrame
end

local function updateScrollFrameSize(scrollFrame)
  if showingRaids then
    setSize(scrollFrame, SCROLL_CONFIG.RAID_SIZE[1], SCROLL_CONFIG.RAID_SIZE[2])
  else
    setSize(scrollFrame, SCROLL_CONFIG.DUNGEON_SIZE[1], SCROLL_CONFIG.DUNGEON_SIZE[2])
  end
end

local function createInstanceEntry(parent, instance, index, isRaid)
  local entry = CreateFrame("Frame", nil, parent)
  setSize(entry, 295, FRAME_CONFIG.ENTRY_HEIGHT)
  entry:SetPoint("TOPLEFT", 0, -(index-1)*FRAME_CONFIG.ENTRY_HEIGHT)
  local check = CreateFrame("CheckButton", nil, entry, "OptionsCheckButtonTemplate")
  setSize(check, 20, 20)
  check:SetPoint("TOPLEFT", entry, "TOPLEFT")
  
  check.instanceData = instance
  check.isRaid = isRaid
  
  check:SetScript("OnClick", function()
    -- Selection logic handled by API
  end)
  
  local name = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  name:SetText(instance.nom or instance.name or "Unknown")
  name:SetPoint("LEFT", entry, "LEFT", 20, 0)
  local info = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  if isRaid then
    local sizeMin = instance.size_min or 0
    local sizeMax = instance.size_max or 0
    if sizeMin == sizeMax then
      info:SetText(tostring(sizeMin))
    else
      info:SetText(sizeMin .. "-" .. sizeMax)
    end
  else
    local lvlMin = instance.lvl_min or 0
    local lvlMax = instance.lvl_max or 0
    info:SetText(lvlMin .. "-" .. lvlMax)
  end
  info:SetPoint("RIGHT", entry, "RIGHT", -10, 0)
  return entry, check
end

local function clearScrollContent()
  if currentScrollContent then
    local children = {currentScrollContent:GetChildren()}
    for _, child in ipairs(children) do
      child:Hide()
    end
    currentScrollContent:Hide()
  end
end

local function updateInstanceList()
  local scrollFrame = getglobal("AutoLFMTurtleFrameInstancesList")
  if not scrollFrame then return end
  
  local data = showingRaids and raids or donjons
  
  if raidSizeControls and raidSizeControls.background then
    if showingRaids then
      raidSizeControls.background:Show()
    else
      raidSizeControls.background:Hide()
    end
  end
  
  clearScrollContent()
  
  if data and table.getn(data) > 0 then
    if not currentScrollContent then
      currentScrollContent = CreateFrame("Frame", nil, scrollFrame)
    end
    setSize(currentScrollContent, 298, table.getn(data) * FRAME_CONFIG.ENTRY_HEIGHT)
    scrollFrame:SetScrollChild(currentScrollContent)
    currentScrollContent:Show()
    
    for i, instance in ipairs(data) do
      createInstanceEntry(currentScrollContent, instance, i, showingRaids)
    end
  end
  
  updateScrollFrameSize(scrollFrame)
end

local function setInstanceMode(isRaid)
  showingRaids = isRaid
  updateInstanceList()
end

-- More tab components (declared before updateTabVisibility)
local moreLabelFrame = CreateFrame("Frame", nil, AutoLFMTurtleFrame)
setSize(moreLabelFrame, 295,250)
moreLabelFrame:SetPoint("TOPLEFT", AutoLFMTurtleFrame, "TOPLEFT", 25, -170)
moreLabelFrame:SetBackdrop({
  tile = true,
  tileSize = 32,
  edgeSize = 8,
  insets = {left = 4, right = 4, top = 4, bottom = 4}
})
moreLabelFrame:Hide()

local moreLabel = moreLabelFrame:CreateFontString(nil, "OVERLAY", "DialogButtonHighlightText")
moreLabel:SetText("Broadcast Message")
moreLabel:SetPoint("TOP", moreLabelFrame, "TOP", 0, 0)

-- Slider option with icon
local sliderIcon = moreLabelFrame:CreateTexture(nil, "OVERLAY")
sliderIcon:SetTexture("Interface\\GossipFrame\\HealerGossipIcon")
setSize(sliderIcon, 16, 16)
sliderIcon:SetPoint("TOPLEFT", moreLabelFrame, "TOPLEFT", 5, -50)

local sliderLabel = moreLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sliderLabel:SetText("Interval:")
sliderLabel:SetPoint("LEFT", sliderIcon, "RIGHT", 5, 0)

local intervalSlider = CreateFrame("Slider", nil, moreLabelFrame)
setSize(intervalSlider, 140, 17)
intervalSlider:SetPoint("TOPLEFT", moreLabelFrame, "TOPLEFT", 85, -52)
intervalSlider:SetMinMaxValues(40, 120)
intervalSlider:SetValue(80)
intervalSlider:SetValueStep(10)
intervalSlider:SetOrientation("HORIZONTAL")
intervalSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
intervalSlider:SetBackdrop(SLIDER_CONFIG.SLIDER_BACKDROP)

local sliderValue = moreLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sliderValue:SetText("60 secs")
sliderValue:SetPoint("LEFT", intervalSlider, "RIGHT", 10, 0)

intervalSlider:SetScript("OnValueChanged", function()
  local value = intervalSlider:GetValue()
  if value then
    sliderValue:SetText(tostring(math.floor(value)) .. " secs")
  end
end)

-- Channels section with icon
local channelIcon = moreLabelFrame:CreateTexture(nil, "OVERLAY")
channelIcon:SetTexture("Interface\\GossipFrame\\GossipGossipIcon")
setSize(channelIcon, 16, 16)
channelIcon:SetPoint("TOPLEFT", moreLabelFrame, "TOPLEFT", 5, -90)

local channelsLabel = moreLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
channelsLabel:SetText("Channel:")
channelsLabel:SetPoint("LEFT", channelIcon, "RIGHT", 5, 0)

-- Channel arrow before text (clickable)
local channelArrow = CreateFrame("Button", nil, moreLabelFrame)
setSize(channelArrow, 32, 32)
channelArrow:SetPoint("LEFT", channelsLabel, "RIGHT", 10, 0)

local arrowTexture = channelArrow:CreateTexture(nil, "OVERLAY")
arrowTexture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-RotationRight-Big-Up")
arrowTexture:SetAllPoints()

-- Channel text after arrow
local channelText = moreLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
channelText:SetText("LookingForGroup")
channelText:SetPoint("LEFT", channelArrow, "RIGHT", 5, 1)
channelText:SetTextColor(1, 1, 0, 1)

-- Apply italic effect by using a different font
local font, size, flags = channelText:GetFont()
channelText:SetFont(font, size, "OUTLINE")

-- Invisible button on channel text
local channelTextButton = CreateFrame("Button", nil, moreLabelFrame)
setSize(channelTextButton, 100, 20)
channelTextButton:SetPoint("LEFT", channelArrow, "RIGHT", 5, 0)

local currentChannel = "LookingForGroup"
local channels = {"LookingForGroup", "World", "General - Zone"}
local channelIndex = 1

local function changeChannel()
  channelIndex = channelIndex + 1
  if channelIndex > table.getn(channels) then
    channelIndex = 1
  end
  currentChannel = channels[channelIndex]
  channelText:SetText(currentChannel)
end

channelArrow:SetScript("OnClick", changeChannel)
channelTextButton:SetScript("OnClick", changeChannel)

-- Time line
local timeIcon = moreLabelFrame:CreateTexture(nil, "OVERLAY")
timeIcon:SetTexture("Interface\\GossipFrame\\VendorGossipIcon")
setSize(timeIcon, 16, 16)
timeIcon:SetPoint("TOPLEFT", channelIcon, "BOTTOMLEFT", 0, -20)

local timeLabel = moreLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
timeLabel:SetText("Duration: 00:00")
timeLabel:SetPoint("LEFT", timeIcon, "RIGHT", 5, 0)

-- Sent line
local sentIcon = moreLabelFrame:CreateTexture(nil, "OVERLAY")
sentIcon:SetTexture("Interface\\GossipFrame\\TrainerGossipIcon")
setSize(sentIcon, 16, 16)
sentIcon:SetPoint("TOPLEFT", timeIcon, "BOTTOMLEFT", 0, -20)

local sentLabel = moreLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sentLabel:SetText("Sent: 0")
sentLabel:SetPoint("LEFT", sentIcon, "RIGHT", 5, 0)

-- Next line
local nextIcon = moreLabelFrame:CreateTexture(nil, "OVERLAY")
nextIcon:SetTexture("Interface\\GossipFrame\\TaxiGossipIcon")
setSize(nextIcon, 16, 16)
nextIcon:SetPoint("TOPLEFT", sentIcon, "BOTTOMLEFT", 0, -20)

local nextLabel = moreLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
nextLabel:SetText("Next: 60s")
nextLabel:SetPoint("LEFT", nextIcon, "RIGHT", 5, 0)

-- HC button positioned under slider value
local hcLabel = moreLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
hcLabel:SetText("[HC]")
hcLabel:SetPoint("TOPLEFT", sliderValue, "BOTTOMLEFT", 0, -27 )
hcLabel:SetTextColor(0.75, 0.75, 0.75, 1)

local hcButton = CreateFrame("CheckButton", nil, moreLabelFrame, "OptionsCheckButtonTemplate")
setSize(hcButton, 20, 20)
hcButton:SetPoint("LEFT", hcLabel, "RIGHT", 5, 0)
hcButton:SetChecked(false)
hcButton:SetTextColor(0.75, 0.75, 0.75, 1)

-- Apply silver color to checkbox
local checkTexture = hcButton:GetNormalTexture()
if checkTexture then
  checkTexture:SetVertexColor(0.75, 0.75, 0.75, 1)
end

hcButton:SetScript("OnClick", function()
  -- HC toggle logic here
end)


-- Tab system
local CurrentTab = 1
local tabs = {}

local function CreateTab(name, id, text, parent)
  local tab = CreateFrame("Button", name, parent)
  setSize(tab, 96, 32)
  tab:SetID(id)
  local tabText = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  tabText:SetPoint("CENTER", 0, 2)
  tabText:SetText(text)
  tab.text = tabText
  tab.isActive = false
  
  -- Create texture once
  local texture = tab:CreateTexture(nil, "BACKGROUND")
  texture:SetAllPoints()
  tab:SetNormalTexture(texture)
  
  return tab
end

local function setTabInactive(tab)
  tab.isActive = false
  tab:GetNormalTexture():SetTexture(TEXTURES.TAB_INACTIVE)
  tab.text:SetTextColor(unpack(COLORS.TAB_INACTIVE))
  tab:SetScript("OnEnter", function()
    tab:SetHighlightTexture(TEXTURES.TAB_HIGHLIGHT)
  end)
end

local function setTabActive(tab)
  tab.isActive = true
  tab:GetNormalTexture():SetTexture(TEXTURES.TAB_ACTIVE)
  tab.text:SetTextColor(unpack(COLORS.TAB_ACTIVE))
  tab:SetScript("OnEnter", function()
    tab:SetHighlightTexture(nil)
  end)
end

local function updateTabVisibility(tabId)
  local isMoreTab = (tabId == 3)
  
  -- Hide/show instance scroll frame
  local scrollFrame = getglobal("AutoLFMTurtleFrameInstancesList")
  if scrollFrame then
    if isMoreTab then
      clearScrollContent()
      scrollFrame:SetScrollChild(nil)
      currentScrollContent = nil
      scrollFrame:Hide()
    else
      scrollFrame:Show()
    end
  end
  
  -- Hide/show raid size controls
  if raidSizeControls and raidSizeControls.background then
    if isMoreTab then
      raidSizeControls.background:Hide()
    else
      if tabId == 2 then -- Raids tab
        raidSizeControls.background:Show()
      else
        raidSizeControls.background:Hide()
      end
    end
  end
  
  -- Hide/show More tab content
  if isMoreTab then
    moreLabelFrame:Show()
  else
    moreLabelFrame:Hide()
  end
end

local function SetTab(frame, id)
  CurrentTab = id
  for i, tab in ipairs(tabs) do
    tab:ClearAllPoints()
    tab:SetPoint("BOTTOMLEFT", AutoLFMTurtleFrame, "BOTTOMLEFT", FRAME_CONFIG.TAB_POSITIONS[i][1], FRAME_CONFIG.TAB_POSITIONS[i][2])
    if i == id then
      setTabActive(tab)
    else
      setTabInactive(tab)
    end
  end
  
  updateTabVisibility(id)
  
  if AutoLFM_API and AutoLFM_API.IsAvailable() then
    local groupType = "other"
    if id == 1 then groupType = "dungeon" end
    if id == 2 then groupType = "raid" end
    -- Tab change handled by API
  end
end

tabs[1] = CreateTab("AutoLFMTurtleFrameTab1", 1, "Dungeons", AutoLFMTurtleFrame)
tabs[2] = CreateTab("AutoLFMTurtleFrameTab2", 2, "Raids", AutoLFMTurtleFrame)
tabs[3] = CreateTab("AutoLFMTurtleFrameTab3", 3, "More", AutoLFMTurtleFrame)

tabs[1]:SetScript("OnClick", function() SetTab(AutoLFMTurtleFrame, 1); setInstanceMode(false) end)
tabs[2]:SetScript("OnClick", function() SetTab(AutoLFMTurtleFrame, 2); setInstanceMode(true) end)
tabs[3]:SetScript("OnClick", function() SetTab(AutoLFMTurtleFrame, 3) end)

-- Role buttons
local function createRoleButton(data, index, parent)
  local btn = CreateFrame("Button", "AutoLFMTurtleFrameRole"..data.name, parent)
  setSize(btn, FRAME_CONFIG.ROLE_SIZE[1], FRAME_CONFIG.ROLE_SIZE[2])
  btn:SetPoint("TOPLEFT", 74 + (index-1)*98, -52)
  
  local bg = btn:CreateTexture(nil, "BACKGROUND") 
  bg:SetTexture(data.backgroundTexture)
  bg:SetTexCoord(unpack(data.coord))
  setSize(bg, 84, 84)
  bg:SetPoint("TOPLEFT", -12, 14)
  bg:SetVertexColor(1, 1, 1, COLORS.ROLE_BG_ALPHA)
  
  local icon = btn:CreateTexture(nil, "BORDER")
  icon:SetAllPoints()
  icon:SetTexture(data.texture)
  
  -- Create completely independent checkbox frame
  local checkFrame = CreateFrame("Frame", nil, parent)
  setSize(checkFrame, 18, 18)
  checkFrame:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 3, -3)
  
  local check = CreateFrame("CheckButton", nil, checkFrame, "OptionsCheckButtonTemplate")
  setSize(check, 18, 18)
  check:SetPoint("CENTER", checkFrame, "CENTER", 0, 0)
  check:SetHitRectInsets(0, 0, 0, 0) -- Limit hit area exactly to checkbox size
  
  check.roleName = string.lower(data.name)
  check:SetScript("OnClick", function()
    -- Role selection handled by API
  end)

  btn:SetScript("OnClick", function() 
    check:Click() 
  end)

  return btn, check
end

local roleButtons = {}
local roleChecks = {}
for i, roleData in ipairs(ROLE_DATA) do
  local btn, check = createRoleButton(roleData, i, AutoLFMTurtleFrame)
  roleButtons[roleData.name] = btn
  roleChecks[roleData.name] = check
end

local instanceScrollFrame = createScrollFrame(AutoLFMTurtleFrame)
updateScrollFrameSize(instanceScrollFrame)

local function createMoreTabComponents(parent)
  return {
    label = moreLabel,
  }
end

local moreTabContent = createMoreTabComponents(AutoLFMTurtleFrame)

-- Search button
local function createSearchButton(parent)
  local searchBtn = CreateFrame("Button", "AutoLFMTurtleFrameSearchButton", parent, "UIPanelButtonTemplate")
  setSize(searchBtn, FRAME_CONFIG.BUTTON_SIZE[1], FRAME_CONFIG.BUTTON_SIZE[2])
  searchBtn:SetPoint("BOTTOM", parent, "BOTTOM", -10, 79)
  searchBtn:SetText("Search")
  searchBtn:SetScript("OnClick", function()
    if AutoLFM_API and AutoLFM_API.IsAvailable() then
      -- Start broadcast via API
    end
  end)
  return searchBtn
end

-- Initialize addon
local function initializeAddon()
  local searchButton = createSearchButton(AutoLFMTurtleFrame)
  SetTab(AutoLFMTurtleFrame, 1)
  updateInstanceList()
end

local AutoLFMAddon = initializeAddon()