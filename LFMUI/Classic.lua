--------------------------------------------------
-- Variables
--------------------------------------------------
searchStartTime = 0
roleChecks = {}
local texturePath = "Interface\\AddOns\\AutoLFM\\LFMUI\\Textures\\"

--------------------------------------------------
-- Main
--------------------------------------------------
AutoLFM = CreateFrame("Frame", "AutoLFM", UIParent)
  UIPanelWindows["AutoLFM"] = { area = "left", pushable = 3 }
  AutoLFM:SetWidth(384)
  AutoLFM:SetHeight(512)
  AutoLFM:Hide()

local mainTexture = AutoLFM:CreateTexture(nil, "LOW")
  mainTexture:SetPoint("TOPLEFT", AutoLFM, "TOPLEFT", 0, 0)
  mainTexture:SetWidth(512)
  mainTexture:SetHeight(512)
  mainTexture:SetTexture(texturePath .. "mainFrame")

local mainIcon = AutoLFM:CreateTexture(nil, "BACKGROUND")
  mainIcon:SetPoint("TOPLEFT", AutoLFM, "TOPLEFT", 7, -6)
  mainIcon:SetWidth(64)
  mainIcon:SetHeight(64)
  mainIcon:SetTexture(texturePath .. "mainIcon")

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
    check:SetScript("OnClick", function() toggleRole(name) end)
  
  roleChecks[name] = check
    btn:SetScript("OnClick", function() check:Click() end)
  
  return btn, bg, icon, check
end

createRole("Tank", 74, 0.2968)
createRole("Heal", 172, 0)
createRole("DPS", 270, 0.5937)

--------------------------------------------------
-- Dynamic Message
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
-- Tabs
--------------------------------------------------
tabs = {}
currentTab = 1
local function onTabClick(tabNum)
  currentTab = tabNum
  if insideList then
    if tabNum <= 2 then insideList:Show() else insideList:Hide() end
  end
  if insideMore then
    if tabNum == 3 then insideMore:Show() else insideMore:Hide() end
  end
  for i = 1, 3 do
    local active = i == tabNum
      tabs[i].bg:SetTexture(texturePath .. (active and "tabActive" or "tabInactive"))
      tabs[i].text:SetTextColor(1, active and 1 or 0.82, active and 1 or 0)
    if active then tabs[i].highlight:Hide() end
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
  
  tab:SetScript("OnClick", function() onTabClick(index) if onClick then onClick() end end)
  tab:SetScript("OnEnter", function() if currentTab ~= index then highlight:Show() text:SetTextColor(1, 1, 1) end end)
  tab:SetScript("OnLeave", function() highlight:Hide() if currentTab ~= index then text:SetTextColor(1, 0.82, 0) end end)
  
  return tab
end

local tabActions = {
  function() djScrollFrame:Show() raidFrame:Hide() raidContentFrame:Hide() raidScrollFrame:Hide() msgFrameDj:Show() msgFrameRaids:Hide() clearSelectedRaids() clearSelectedRoles() resetUserInputMessage() updateMsgFrameCombined() HideSliderForRaid() swapChannelFrame() ClearAllBackdrops(raidClickableFrames) end,
  function() djScrollFrame:Hide() raidFrame:Show() raidContentFrame:Show() raidScrollFrame:Show() msgFrameDj:Hide() msgFrameRaids:Show() clearSelectedDungeons() clearSelectedRoles() resetUserInputMessage() updateMsgFrameCombined() swapChannelFrame() ClearAllBackdrops(donjonClickableFrames) end,
  function() if djScrollFrame then djScrollFrame:Hide() end if raidFrame then raidFrame:Hide() end if raidContentFrame then raidContentFrame:Hide() end if raidScrollFrame then raidScrollFrame:Hide() end end
}

local function createTabs()
  local prevTab
    for i, label in ipairs({"Dungeons", "Raids", "More"}) do
      prevTab = createTab(i, label, tabActions[i], prevTab)
    end
end

--------------------------------------------------
-- Inside Frames
--------------------------------------------------
local function createInsideFrames()
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
end

createInsideFrames()
createTabs()

--------------------------------------------------
-- Dungeons & Raids ScrollFrames
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

---------------------------------------------------------------------------------
--                            Raid Size Slider                                --
---------------------------------------------------------------------------------
sliderValue = 0
currentSliderFrame = nil
sliderSizeFrame = nil
sliderSizeEditBox = nil
sliderSize = nil

local function createRaidSizeControls(AutoLFM)
  local raidSizeFrame = CreateFrame("Frame", nil, AutoLFM)
    raidSizeFrame:SetPoint("BOTTOM", AutoLFM, "BOTTOM", -16, 75)
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
  
  raidSizeSlider:SetScript("OnMouseDown", function()
    this.dragging = true
  end)
  
  raidSizeSlider:SetScript("OnMouseUp", function()
    this.dragging = false
  end)
  
  raidSizeSlider:SetScript("OnUpdate", function()
    if this.dragging then
      local x, y = GetCursorPosition()
      local scale = this:GetEffectiveScale()
      local left = this:GetLeft() * scale
      local width = this:GetWidth() * scale
      local relX = (x - left) / width
      relX = math.max(0, math.min(1, relX))
      local minVal, maxVal = this:GetMinMaxValues()
      local newVal = minVal + (maxVal - minVal) * relX
      this:SetValue(newVal)
      local top = this:GetTop() * scale
      local bottom = this:GetBottom() * scale
      local right = this:GetRight() * scale
      if not (x >= left and x <= right and y >= bottom and y <= top) then
        this.dragging = false
      end
    end
  end)
  
  return raidSizeFrame, raidSizeEditBox, raidSizeSlider
end

sliderSizeFrame, sliderSizeEditBox, sliderSize = createRaidSizeControls(AutoLFM)

function UpdateSliderText(value)
  if value then
    sliderSizeEditBox:SetText(tostring(value))
  else
    sliderSizeEditBox:SetText("")
  end
end

function ShowSliderForRaid(raid)
  if currentSliderFrame then
    currentSliderFrame:Hide()
  end
  if not raid or not raid.size_min or not raid.size_max then
    return
  end
  sliderSize:SetMinMaxValues(raid.size_min, raid.size_max)

  local initVal = sliderValue ~= 0 and sliderValue or raid.size_min
    sliderSize:SetValue(initVal)
  
  UpdateSliderText(sliderSize:GetValue())

  if AutoLFM and AutoLFM:IsShown() then
    sliderSizeFrame:Show()
  end

  currentSliderFrame = sliderSizeFrame
end

function HideSliderForRaid()
  if sliderSizeFrame then
    sliderSizeFrame:Hide()
  end
  sliderValue = 0
  currentSliderFrame = nil
end

sliderSize:SetScript("OnValueChanged", function()
  local value = sliderSize:GetValue()
  sliderValue = value
  raidSize = value
  UpdateSliderText(value)
  updateMsgFrameCombined()
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
-- Inside More
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
    editBoxHasFocus = true
  end)
  editBox:SetScript("OnEditFocusLost", function()
    editBoxHasFocus = false
    updatePlaceholder()
  end)
  editBox:SetScript("OnTextChanged", function()
    userInputMessage = this:GetText()
    if userInputMessage ~= "" then
      updateMsgFrameCombined(userInputMessage)
    else
      updateMsgFrameCombined()
    end
    updatePlaceholder()
  end)
  editBox:SetScript("OnEnterPressed", function()
    this:ClearFocus()
  end)
  editBox:SetScript("OnEscapePressed", function()
    this:ClearFocus()
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
-- Start/Stop Button
--------------------------------------------------
toggleButton = CreateFrame("Button", "ToggleButton", AutoLFM, "UIPanelButtonTemplate")
toggleButton:SetPoint("BOTTOM", AutoLFM, "BOTTOM", 97, 80)
toggleButton:SetWidth(110)
toggleButton:SetHeight(21)
toggleButton:SetText("Start")

toggleButton:SetScript("OnClick", function()
  if combinedMessage == " " or combinedMessage == "" then
    if not isBroadcasting then
      print("The message is empty. The broadcast cannot begin.")
      return
    end
  end
  local allChannelsValid = true
  for channelName, _ in pairs(selectedChannels) do
    if channelName ~= "Hardcore" then
      local channelId = GetChannelName(channelName)
      if not (channelId and channelId > 0) then
        allChannelsValid = false
        break
      end
    end
  end
  if allChannelsValid then
    if isBroadcasting then
      stopMessageBroadcast()
      toggleButton:SetText("Start")
      PlaySoundFile("Interface\\AddOns\\AutoLFM\\sound\\LFG_Denied.ogg")
      searchStartTime = 0
    else
      swapChannelFrame()
      startMessageBroadcast()
      toggleButton:SetText("Stop")
      PlaySoundFile("Interface\\AddOns\\AutoLFM\\sound\\LFG_RoleCheck.ogg")
      searchStartTime = GetTime()
    end
  else
    DEFAULT_CHAT_FRAME:AddMessage("2112 : Broadcast has not started because one or more channels are invalid.")
  end
end)




-- Right Panel
rightPanel = CreateFrame("Frame", "AutoLFM_RightPanel", AutoLFM)
rightPanel:SetWidth(384)
rightPanel:SetHeight(512)
rightPanel:SetPoint("TOPLEFT", AutoLFM, "TOPRIGHT", -46, 0)
rightPanel:Hide() -- Hide the right panel by default

rt_tl = rightPanel:CreateTexture(nil, "ARTWORK")
rt_tl:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-BotLeft")
rt_tl:SetWidth(256)
rt_tl:SetHeight(256)
rt_tl:SetPoint("TOPLEFT", rightPanel, "TOPLEFT")
rt_tl:SetTexCoord(0, 1, 1, 0)

rt_tr = rightPanel:CreateTexture(nil, "ARTWORK")
rt_tr:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-BotRight")
rt_tr:SetWidth(128)
rt_tr:SetHeight(256)
rt_tr:SetPoint("TOPRIGHT", rightPanel, "TOPRIGHT")
rt_tr:SetTexCoord(0, 1, 1, 0)

rt_bl = rightPanel:CreateTexture(nil, "ARTWORK")
rt_bl:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-BotLeft")
rt_bl:SetWidth(256)
rt_bl:SetHeight(256)
rt_bl:SetPoint("BOTTOMLEFT", rightPanel, "BOTTOMLEFT")

rt_br = rightPanel:CreateTexture(nil, "ARTWORK")
rt_br:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-BotRight")
rt_br:SetWidth(128)
rt_br:SetHeight(256)
rt_br:SetPoint("BOTTOMRIGHT", rightPanel, "BOTTOMRIGHT")

--eyeOpen = true
--eye = AutoLFM:CreateTexture(nil, "OVERLAY")
--eye:SetWidth(52)
--eye:SetHeight(52)
--eye:SetPoint("TOPLEFT", 13, -11)
--eye:SetTexture(openTexture)

showArrowBtn = nil
closeArrowTex = nil

-- Bouton flèche pour fermer rightPanel (flèche vers la gauche)
closeBtn = CreateFrame("Button", "AutoLFMCloseButton", rightPanel)
closeBtn:SetWidth(20)
closeBtn:SetHeight(60)
closeBtn:SetPoint("TOPRIGHT", rightPanel, "TOPRIGHT", -15, -225)

closeArrowTex = closeBtn:CreateTexture(nil, "OVERLAY")
closeArrowTex:SetAllPoints()
closeArrowTex:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up") -- flèche vers la gauche

-- Maintenant création du bouton flèche
showArrowBtn = CreateFrame("Button", nil, AutoLFM)
showArrowBtn:SetWidth(20)
showArrowBtn:SetHeight(60)
showArrowBtn:SetPoint("RIGHT", AutoLFM, "RIGHT", -15, 0)
showArrowBtn:Show()

arrowTex = showArrowBtn:CreateTexture(nil, "OVERLAY")
arrowTex:SetAllPoints()
arrowTex:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")

-- Créer cadre roleframe dans la frame de droite
roleframe = CreateFrame("Frame", nil, AutoLFM_RightPanel)
roleframe:SetWidth(AutoLFM_RightPanel:GetWidth()- 60)
roleframe:SetHeight(AutoLFM_RightPanel:GetHeight() / 6)
roleframe:SetPoint("TOPLEFT", AutoLFM_RightPanel, "TOPLEFT", 20, -100)






AutoLFM:SetScript("OnShow", function(self)
    nextChange = GetTime() + math.random(1, 3) -- init timer
    this:SetScript("OnUpdate", OnUpdateHandler)
end)

AutoLFM:SetScript("OnHide", function(self)
    this:SetScript("OnUpdate", nil) -- stop OnUpdate quand caché
end)

---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--                                EditBox                                      --
---------------------------------------------------------------------------------












function CreateQuestLink(questIndex)
    if not AutoLFM or not AutoLFM:IsVisible() then
        return -- autoLFM fermé, ne fait rien
    end
    local title, level, _, _, _, _, _, questID = GetQuestLogTitle(questIndex)
    if not title or title == "" then return nil end
    if not questID then
        -- En 1.12, questID est souvent nil, mais on peut essayer d'extraire autrement (limité)
        questID = 0
    end
    -- Construire le lien (format 1.12)
    local color = "|cffffff00"  -- jaune, couleur des quêtes
    local link = string.format("%s|Hquest:%d:%d|h[%s]|h|r", color, questID, level or 0, title)
    return link
end




-- Sauvegarder la fonction d'origine
Original_QuestLogTitleButton_OnClick = QuestLogTitleButton_OnClick

-- Surcharge de QuestLogTitleButton_OnClick
function QuestLogTitleButton_OnClick(self, button)

    Original_QuestLogTitleButton_OnClick(self, button)

    if "LeftButton" and IsShiftKeyDown() and editBox and editBoxHasFocus then
        local questIndex = this:GetID()
        if questIndex then
            local questLink = CreateQuestLink(questIndex)
            if questLink then
                editBox:SetText(questLink)
                editBox:SetFocus()
            end
        end
    end
end

-- On sauvegarde la fonction d'origine OnClick des boutons d'item du sac
Original_ContainerFrameItemButton_OnClick = ContainerFrameItemButton_OnClick

function ContainerFrameItemButton_OnClick(self, button)
    -- Appeler la fonction originale (ouvrir tooltip, etc.)
    Original_ContainerFrameItemButton_OnClick(self, button)

    if "LeftButton" and IsShiftKeyDown() and editBox and editBoxHasFocus then
        local bag = this:GetParent():GetID()
        local slot = this:GetID()
        local itemLink = GetContainerItemLink(bag, slot)
        if itemLink then
            if editBox then
                editBox:SetText(itemLink)
                editBox:SetFocus()
            end
        end
    end
end

-- Sauvegarder la fonction d'origine
Original_SetItemRef = SetItemRef

-- Nouvelle fonction pour intercepter les clics sur les liens
function SetItemRef(link, text, button, chatFrame)

    Original_SetItemRef(link, text, button, chatFrame)

    -- Vérifier clic gauche + Shift + lien d'item
    if "LeftButton" and IsShiftKeyDown() and editBox and editBoxHasFocus then
        -- En 1.12, les liens d'item commencent souvent par "item:"
        if link and string.find(link, "^item:") then
            if editBox then
                editBox:SetText(text)
                editBox:SetFocus()
            end
        end
    end
end


---------------------------------------------------------------------------------
--                                 Slider                                      --
---------------------------------------------------------------------------------


-- Créer cadre sliderframe
sliderframe = CreateFrame("Frame", nil, AutoLFM)
sliderframe:SetBackdrop({
    bgFile = nil,
    edgeSize = 16,  -- Taille de la bordure
    insets = { left = 4, right = 2, top = 4, bottom = 4 },
})
sliderframe:SetBackdropColor(1, 1, 1, 0.3)
sliderframe:SetBackdropBorderColor(1, 1, 1, 1)

-- Positionner le nouveau cadre juste en dessous de roleframe
sliderframe:SetWidth(roleframe:GetWidth())
sliderframe:SetHeight(roleframe:GetHeight() + 50)
sliderframe:SetPoint("TOPRIGHT", msgFrame, "BOTTOMRIGHT", 0, -40)

-- Créer la barre de glissement (Slider)
slider = CreateFrame("Slider", nil, sliderframe, "OptionsSliderTemplate")
slider:SetWidth(200)
slider:SetHeight(20)
slider:SetPoint("CENTER", sliderframe, "CENTER", 0, 0)
slider:SetMinMaxValues(40, 120)
slider:SetValue(80)
slider:SetValueStep(10)




---------------------------------------------------------------------------------
--                               Slider Frame                                  --
---------------------------------------------------------------------------------


-- Valeur de pas fixe pour arrondir
step = 10

-- Fonction pour arrondir la valeur du slider à l'étape la plus proche
function SnapToStep(value)
    if value then
        local roundedValue = math.floor(value / step + 0.5) * step
        return roundedValue
    end
end

-- Créer une police pour afficher la valeur actuelle du slider (placer la valeur au-dessus du slider)
valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
valueText:SetPoint("BOTTOM", slider, "TOP", 0, 5)
valueText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")

-- Mettre à jour la valeur du slider
sliderframe:SetScript("OnUpdate", function(self, elapsed)
-- Récupérer la valeur actuelle du slider
local currentValue = slider:GetValue()

-- Arrondir la valeur à l'étape la plus proche
local snappedValue = SnapToStep(currentValue)

-- Appliquer la valeur arrondie au slider si nécessaire (au cas où la valeur serait flottante)
if currentValue ~= snappedValue then
    slider:SetValue(snappedValue)
end

-- Mettre à jour dynamiquement le texte pour refléter la nouvelle valeur en temps réel
valueText:SetText("Dispense every " .. slider:GetValue() .. " seconds")
end)


AutoLFM:RegisterEvent("PARTY_MEMBERS_CHANGED")
AutoLFM:RegisterEvent("GROUP_ROSTER_UPDATE")
AutoLFM:RegisterEvent("RAID_ROSTER_UPDATE")


AutoLFM:SetScript("OnEvent", function(self, event, ...)
    if "RAID_ROSTER_UPDATE" then
        OnRaidRosterUpdate()
    end
end)

AutoLFM:SetScript("OnEvent", function(self, event, ...)
    if "GROUP_ROSTER_UPDATE" then
        local raid = selectedRaids[1]  -- Récupérer le raid sélectionné
        local donjon = selectedDungeons[1]  -- Récupérer le donjon sélectionné
        if raid ~= nil then
            local totalPlayersInRaid = countRaidMembers()  -- Récupérer le nombre total de membres du groupe
            if raidSize == totalPlayersInRaid then
                stopMessageBroadcast()  -- Si le groupe a atteint la taille du raid, arrêter la diffusion
                clearSelectedRaids() -- Effacer les donjons sélectionnés
                clearSelectedRoles()  -- Effacer les rôles sélectionnés
                resetUserInputMessage()  -- Réinitialiser le message d'entrée utilisateur
                updateMsgFrameCombined()  -- Mettre à jour le message combiné
                toggleButton:SetText("Start")  -- Réinitialiser le texte du bouton à "Start"
                PlaySoundFile("Interface\\AddOns\\AutoLFM\\sound\\LFG_Denied.ogg")  -- Jouer le son d'arrêt
            else
                OnGroupUpdate()  -- Mettre à jour le groupe
            end
        elseif donjon ~= nil then
            donjonSize = 5
            local totalPlayersInRaid = countGroupMembers()  -- Récupérer le nombre total de membres du groupe
            if donjonSize == totalPlayersInRaid then
                stopMessageBroadcast()  -- Si le groupe a atteint la taille du donjon, arrêter la diffusion
                clearSelectedDungeons()  -- Effacer les donjons sélectionnés
                clearSelectedRoles()  -- Effacer les rôles sélectionnés
                resetUserInputMessage()  -- Réinitialiser le message d'entrée utilisateur
                updateMsgFrameCombined()  -- Mettre à jour le message combiné
                toggleButton:SetText("Start")  -- Réinitialiser le texte du bouton à "Start"
                PlaySoundFile("Interface\\AddOns\\AutoLFM\\sound\\LFG_Denied.ogg")  -- Jouer le son d'arrêt
            else
                OnGroupUpdate()  -- Mettre à jour le groupe
            end
        end
    end
end)