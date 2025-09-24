
-- Helpers
local FRAME_SIZE = {384, 512}
local ROLE_SIZE = {54, 54}
local BUTTON_SIZE = {104, 21}
local ENTRY_HEIGHT = 20
local function setSize(obj, w, h)
	obj:SetWidth(w)
	obj:SetHeight(h)
end


-- Main frame
local AutoLFMTurtleFrame = CreateFrame("Frame", "AutoLFMTurtleFrame", UIParent)
  setSize(AutoLFMTurtleFrame, FRAME_SIZE[1], FRAME_SIZE[2])
  AutoLFMTurtleFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, -104)
  AutoLFMTurtleFrame:EnableMouse(true)
  AutoLFMTurtleFrame:SetMovable(true)
  AutoLFMTurtleFrame:RegisterForDrag("LeftButton")
  AutoLFMTurtleFrame:SetScript("OnDragStart", function(self) this:StartMoving() end)
  AutoLFMTurtleFrame:SetScript("OnDragStop", function(self) this:StopMovingOrSizing() end)
  AutoLFMTurtleFrame:Hide()


-- Icon
local portrait = AutoLFMTurtleFrame:CreateTexture(nil, "BACKGROUND")
  portrait:SetTexture("Interface\\FrameXML\\LFT\\images\\ui-lfg-portrait")
  setSize(portrait, 64, 64)
  portrait:SetPoint("TOPLEFT", 7, -6)


-- Title
local title = AutoLFMTurtleFrame:CreateFontString("AutoLFMTurtleFrameTitle", "OVERLAY", "GameFontNormal")
  title:SetText("AutoLFM")
  title:SetPoint("TOP", 0, -18)


-- Close button
local closeBtn = CreateFrame("Button", nil, AutoLFMTurtleFrame, "UIPanelCloseButton")
  closeBtn:SetPoint("TOPRIGHT", AutoLFMTurtleFrame, "TOPRIGHT", -27, -8)
  closeBtn:SetScript("OnClick", function() AutoLFMTurtleFrame:Hide() end)


-- Windows texture
local frame = AutoLFMTurtleFrame:CreateTexture(nil, "ARTWORK")
  frame:SetTexture("Interface\\FrameXML\\LFT\\images\\ui-lfg-frame")
  setSize(frame, 512, 512)
  frame:SetPoint("TOPLEFT", AutoLFMTurtleFrame, "TOPLEFT")


-- Background image
local bgWall = AutoLFMTurtleFrame:CreateTexture(nil, "BACKGROUND")
  bgWall:SetTexture("Interface\\FrameXML\\LFT\\images\\ui-lfg-background-dungeonwall")
  setSize(bgWall, 512, 256)
  bgWall:SetPoint("TOP", 85, -155)


-- Role buttons
local roleData = {
  {name="Tank", coord={0.2968, 0.5937, 0, 0.5937}, tex="tank2"},
  {name="Healer", coord={0, 0.2968, 0, 0.5937}, tex="healer2"}, 
  {name="Damage", coord={0.5937, 0.8906, 0, 0.5937}, tex="damage2"}
}
for i, data in ipairs(roleData) do
  local btn = CreateFrame("Button", "AutoLFMTurtleFrameRole"..data.name, AutoLFMTurtleFrame)
    setSize(btn, ROLE_SIZE[1], ROLE_SIZE[2])
    btn:SetPoint("TOPLEFT", 74 + (i-1)*98, -52)
  local bg = btn:CreateTexture(nil, "BACKGROUND") 
    bg:SetTexture("Interface\\FrameXML\\LFT\\images\\ui-lfg-role-background")
    bg:SetTexCoord(unpack(data.coord))
    setSize(bg, 84, 84)
    bg:SetPoint("TOPLEFT", -12, 14)
    bg:SetVertexColor(1, 1, 1, 0.6)
  local icon = btn:CreateTexture(nil, "BORDER")
    icon:SetAllPoints()
    icon:SetTexture("Interface\\FrameXML\\LFT\\images\\"..data.tex)
  local check = CreateFrame("CheckButton", nil, btn, "OptionsCheckButtonTemplate")
    setSize(check, 24, 24) 
    check:SetPoint("BOTTOMLEFT", 2, -4)
    btn:SetScript("OnClick", function() check:Click() end)
end


-- InputUser broadcast
local function setupPlaceholder(editBox, text)
	local placeholder = editBox:CreateFontString(nil, "OVERLAY", "GameFontDisable")
	  placeholder:SetText(text)
	  placeholder:SetPoint("LEFT", editBox, "LEFT", 8, 0)
	local function updatePlaceholder()
		if editBox:GetText() == "" then placeholder:Show() else placeholder:Hide() end
	end
	  editBox:SetScript("OnEditFocusGained", function() placeholder:Hide() end)
	  editBox:SetScript("OnEditFocusLost", updatePlaceholder)
	  editBox:SetScript("OnTextChanged", updatePlaceholder)
	  updatePlaceholder()
end
local editBox = CreateFrame("EditBox", "AutoLFMTurtleFrameEditBox", AutoLFMTurtleFrame, "InputBoxTemplate")
  setSize(editBox, 200, 32)
  editBox:SetPoint("TOP", AutoLFMTurtleFrame, "TOP", -10, -125)
  editBox:SetAutoFocus(false)
  editBox:SetMaxLetters(50)
  setupPlaceholder(editBox, "Add details")


-- Raids/Dungeons
local function updateInstanceList()
	local data = showingRaids and raids or donjons
	local scrollFrame = getglobal("AutoLFMTurtleFrameInstancesList")
	if showingRaids then
		raidSliderBg:Show()
	else
		raidSliderBg:Hide()
	end


-- Scroll
if currentScrollContent then
	currentScrollContent:Hide()
	currentScrollContent = nil
end
currentScrollContent = CreateFrame("Frame", nil, scrollFrame)
	setSize(currentScrollContent, 298, table.getn(data) * ENTRY_HEIGHT)
	scrollFrame:SetScrollChild(currentScrollContent)
	for i, instance in ipairs(data) do
		local entry = CreateFrame("Frame", nil, currentScrollContent)
		  setSize(entry, 295, ENTRY_HEIGHT)
		  entry:SetPoint("TOPLEFT", 0, -(i-1)*ENTRY_HEIGHT)
		local check = CreateFrame("CheckButton", nil, entry, "OptionsCheckButtonTemplate")
		  setSize(check, 20, 20)
		  check:SetPoint("TOPLEFT", entry, "TOPLEFT")
		local name = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		  name:SetText(instance.nom)
		  name:SetPoint("LEFT", entry, "LEFT", 20, 0)
		local info = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		  if showingRaids then
			  if instance.size_min == instance.size_max then
				  info:SetText(instance.size_min)
			  else
				  info:SetText(instance.size_min .. "-" .. instance.size_max)
			  end
		  else
			  info:SetText(instance.lvl_min .. "-" .. instance.lvl_max)
		  end
		  info:SetPoint("RIGHT", entry, "RIGHT", -10, 0)
	  end
  end
scrollFrame = CreateFrame("ScrollFrame", "AutoLFMTurtleFrameInstancesList", AutoLFMTurtleFrame, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", AutoLFMTurtleFrame, "TOPLEFT", 25, -158)
local function updateScrollFrameSize()
	if showingRaids then
		setSize(scrollFrame, 295, 220)
	else
		setSize(scrollFrame, 295, 252)
	end
end
updateScrollFrameSize()


-- Raid size background
raidSliderBg = CreateFrame("Frame", nil, AutoLFMTurtleFrame)
  setSize(raidSliderBg, 295, 30)
  raidSliderBg:SetPoint("BOTTOM", AutoLFMTurtleFrame, "BOTTOM", -20, 105)
  raidSliderBg:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 8, insets = {left = 4, right = 4, top = 4, bottom = 4}})
  raidSliderBg:Hide()


-- Raid size label
local sliderLabel = raidSliderBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sliderLabel:SetText("Group Size:")
  sliderLabel:SetPoint("LEFT", raidSliderBg, "LEFT", 10, 0)


-- Input raid size
local sizeEditBox = CreateFrame("EditBox", "AutoLFMTurtleFrameSizeEditBox", raidSliderBg, "InputBoxTemplate")
  setSize(sizeEditBox, 25, 20)
  sizeEditBox:SetPoint("LEFT", sliderLabel, "RIGHT", 25, 0)
  sizeEditBox:SetAutoFocus(false)
  sizeEditBox:SetMaxLetters(2)
  sizeEditBox:SetText("25")


-- Raid size slider
local raidSizeSlider = CreateFrame("Slider", "AutoLFMTurtleFrameRaidSizeSlider", raidSliderBg)
  setSize(raidSizeSlider, 120, 17)
  raidSizeSlider:SetPoint("LEFT", sizeEditBox, "RIGHT", 20, 0)
  raidSizeSlider:SetMinMaxValues(10, 40)
  raidSizeSlider:SetValue(25)
  raidSizeSlider:SetValueStep(1)
  raidSizeSlider:SetOrientation("HORIZONTAL")
  raidSizeSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
  raidSizeSlider:SetBackdrop({bgFile = "Interface\\Buttons\\UI-SliderBar-Background", edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", tile = true, tileSize = 8, edgeSize = 8, insets = {left = 3, right = 3, top = 6, bottom = 6}})


-- Sync slider and input raid size
raidSizeSlider:SetScript("OnValueChanged", function()
	local value = raidSizeSlider:GetValue()
	  sizeEditBox:SetText(value)
end)
sizeEditBox:SetScript("OnTextChanged", function()
	local value = tonumber(sizeEditBox:GetText())
	  if value and value >= 10 and value <= 40 then
		  raidSizeSlider:SetValue(value)
	  end
end)


-- Instance list
updateInstanceList()


-- Raids button
local instanceTypeBtn = CreateFrame("Button", "AutoLFMTurtleFrameRaidsButton", AutoLFMTurtleFrame, "UIPanelButtonTemplate")
  setSize(instanceTypeBtn, BUTTON_SIZE[1], BUTTON_SIZE[2])
  instanceTypeBtn:SetPoint("BOTTOMLEFT", AutoLFMTurtleFrame, "BOTTOMLEFT", 25, 79)
  instanceTypeBtn:SetText("Raids")
  instanceTypeBtn:SetScript("OnClick", function()
  showingRaids = not showingRaids
	instanceTypeBtn:SetText(showingRaids and "Dungeons" or "Raids")
	updateInstanceList()
	updateScrollFrameSize()
end)


-- Search button
local searchBtn = CreateFrame("Button", "AutoLFMTurtleFrameSearchButton", AutoLFMTurtleFrame, "UIPanelButtonTemplate")
  setSize(searchBtn, BUTTON_SIZE[1], BUTTON_SIZE[2])
  searchBtn:SetPoint("BOTTOM", AutoLFMTurtleFrame, "BOTTOM", -10, 79)
  searchBtn:SetText("Search")


-- Options button
local optionsBtn = CreateFrame("Button", "AutoLFMTurtleFrameOptionsButton", AutoLFMTurtleFrame, "UIPanelButtonTemplate")
  setSize(optionsBtn, BUTTON_SIZE[1], BUTTON_SIZE[2])
  optionsBtn:SetPoint("BOTTOMRIGHT", AutoLFMTurtleFrame, "BOTTOMRIGHT", -45, 79)
  optionsBtn:SetText("Options")
  optionsBtn:SetText("Options")
  optionsBtn:GetNormalTexture():SetVertexColor(0.4, 0.6, 1.0)
  optionsBtn:GetHighlightTexture():SetVertexColor(0.6, 0.8, 1.0)