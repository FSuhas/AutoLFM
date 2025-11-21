--=============================================================================
-- AutoLFM: Welcome Popup
--   Animated welcome message shown on first use
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Components = AutoLFM.Components or {}
AutoLFM.Components.WelcomePopup = {}

--=============================================================================
-- CONSTANTS
--=============================================================================
local TYPING_SPEED = 0.03
local FADE_DURATION = 0.5
local DISPLAY_DURATION = 4.0
local INITIAL_WAIT = 0.5

--=============================================================================
-- STATE
--=============================================================================
local popupFrame, titleLabel, labels = nil, nil, {}
local padding, textPadding = 24, 8
local titleLineHeight, textLineHeight = 0, 0

local titleBlockIndex, titleLetterIndex = 1, 0
local currentLine, coloredLetterIndex = 1, 0

local typingElapsed, fadeElapsed, fadeTotal = 0, 0, 0
local fadeMode, fadeFunc
local waitBeforeStart, waitBeforeFade = 0, 0
local typingActive, fadeActive, waitingActive = false, false, false
local lastUpdate = nil

--=============================================================================
-- DATA
--=============================================================================


local titleBlocks = {
  {text = "Thank you for using ", color = "WHITE"},
  {text = "Auto", color = "WHITE"},
  {text = "L", color = "BLUE"},
  {text = "F", color = "WHITE"},
  {text = "M", color = "RED"}
}

local messages = {
  {text = " "},
  {subblocks = {
    {text = "Automated ", color = "WHITE"},
    {text = "L", color = "BLUE"},
    {text = "F", color = "WHITE"},
    {text = "M", color = "RED"},
    {text = " Broadcaster optimized for ", color = "WHITE"},
    {text = "Turtle WoW", color = "GREEN"}
  }},
  {text = " "},
  {subblocks = {
    {text = "Select your ", color = "WHITE"},
    {text = "dungeons, raids, or quests", color = "BLUE"}
  }},
  {subblocks = {
    {text = "Pick the roles you need ", color = "WHITE"},
    {text = "(Tank/Healer/DPS)", color = "PURPLE"}
  }},
  {subblocks = {
    {text = "Broadcast automatically on chosen channels ", color = "WHITE"},
    {text = "(World, LFG or Hardcore)", color = "CYAN"}
  }},
  {text = " "},
  {subblocks = {
    {text = "Start now with ", color = "WHITE"},
    {text = "/lfm", color = "YELLOW"}
  }},
  {text = " "},
  {subblocks = {
    {text = "Enjoy smooth recruitment in ", color = "ORANGE"},
    {text = "Turtle WoW !", color = "GREEN"}
  }}
}

--=============================================================================
-- HELPERS
--=============================================================================

--- Generates partial title text with color codes for typing animation
--- @param blockIndex number - Current block being typed
--- @param letterIndex number - Current letter position in block
--- @return string - Colored text string
local function getPartialTitleText(blockIndex, letterIndex)
  local text = ""
  for i = 1, blockIndex do
    local block = titleBlocks[i]
    if block then
      local colorObj = AutoLFM.Core.Utils.GetColor(block.color)
      local color = "|cFF" .. colorObj.hex
      if i < blockIndex then
        text = text .. color .. block.text
      else
        text = text .. color .. string.sub(block.text, 1, letterIndex)
      end
    end
  end
  return text
end

--- Generates partial colored text for message lines with typing animation
--- @param msg table - Message data with subblocks
--- @param letterIndex number - Current letter position
--- @return string - Colored text string
local function getPartialColoredText(msg, letterIndex)
  local txt = ""
  local count = 0
  if not msg.subblocks then return "" end
  
  for _, block in ipairs(msg.subblocks) do
    local colorObj = AutoLFM.Core.Utils.GetColor(block.color)
    local color = "|cFF" .. colorObj.hex
    for i = 1, string.len(block.text) do
      count = count + 1
      if count <= letterIndex then
        txt = txt .. color .. string.sub(block.text, i, i)
      else
        return txt
      end
    end
  end
  return txt
end

--- Calculates total character count in a message
--- @param msg table - Message data with text or subblocks
--- @return number - Total character count
local function getTotalChars(msg)
  if not msg.subblocks then return string.len(msg.text or "") end
  local total = 0
  for _, block in ipairs(msg.subblocks) do
    total = total + string.len(block.text)
  end
  return total
end

--- Fades a frame in or out
--- @param frame frame - Frame to fade
--- @param mode string - "IN" or "OUT"
--- @param duration number - Fade duration in seconds
--- @param onFinish function - Callback when fade completes
local function fadeFrame(frame, mode, duration, onFinish)
  if not frame then return end
  fadeMode, fadeElapsed, fadeTotal = mode, 0, duration
  fadeFunc, fadeActive = onFinish, true
  frame:SetAlpha(mode == "IN" and 0 or 1)
  if mode == "IN" then frame:Show() end
end

--=============================================================================
-- CREATE POPUP
--=============================================================================

--- Creates the welcome popup frame with all UI elements
--- @return frame - Created popup frame
local function createPopup()
  local frame = CreateFrame("Frame", "AutoLFM_WelcomePopup", UIParent)
  frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    tile = true, tileSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
  })
  frame:SetBackdropColor(0, 0, 0, 0.75)
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 250)
  frame:SetWidth(50)
  frame:Hide()

  local tmp = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  tmp:SetText("M")
  titleLineHeight = tmp:GetHeight() or 20
  tmp:SetFont("Fonts\\FRIZQT__.TTF", 14)
  textLineHeight = tmp:GetHeight() or 14
  tmp:Hide()

  frame:SetHeight(titleLineHeight + padding * 2)

  titleLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  titleLabel:SetFont("Fonts\\FRIZQT__.TTF", 22, "OUTLINE")
  titleLabel:SetJustifyH("CENTER")
  titleLabel:SetPoint("TOP", frame, "TOP", 0, -padding)

  for i = 1, table.getn(messages) do
    local lbl = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    lbl:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    lbl:SetJustifyH("CENTER")
    lbl:SetText("")
    lbl:SetWidth(600)
    lbl:SetPoint("TOP", frame, "TOP", 0, -padding - titleLineHeight - (i - 1) * (textLineHeight + textPadding - 2))
    labels[i] = lbl
  end

  return frame
end

--=============================================================================
-- UPDATE
--=============================================================================

--- OnUpdate handler for typing animation and fade effects
local function onUpdate()
  local now = GetTime()
  local elapsed = lastUpdate and (now - lastUpdate) or 0
  lastUpdate = now

  if fadeActive then
    fadeElapsed = fadeElapsed + elapsed
    local progress = fadeElapsed / fadeTotal
    if progress >= 1 then
      popupFrame:SetAlpha(fadeMode == "IN" and 1 or 0)
      fadeActive = false
      if fadeFunc then fadeFunc() end
    else
      popupFrame:SetAlpha(fadeMode == "IN" and progress or (1 - progress))
    end
    return
  end

  if waitingActive then
    waitBeforeStart = waitBeforeStart + elapsed
    if waitBeforeStart > INITIAL_WAIT then
      waitingActive = false
      typingActive = true
      titleBlockIndex, titleLetterIndex = 1, 0
      currentLine, coloredLetterIndex = 1, 0
    end
    return
  end

  if typingActive then
    typingElapsed = typingElapsed + elapsed
    if typingElapsed > TYPING_SPEED then
      typingElapsed = 0

      if titleBlocks[titleBlockIndex] then
        local block = titleBlocks[titleBlockIndex]
        if titleLetterIndex < string.len(block.text) then
          titleLetterIndex = titleLetterIndex + 1
          titleLabel:SetText(getPartialTitleText(titleBlockIndex, titleLetterIndex))
        else
          titleBlockIndex = titleBlockIndex + 1
          titleLetterIndex = 0
        end
      else
        local msg = messages[currentLine]
        local lbl = labels[currentLine]
        if msg and lbl then
          coloredLetterIndex = coloredLetterIndex + 1
          lbl:SetText(getPartialColoredText(msg, coloredLetterIndex))
          
          if coloredLetterIndex >= getTotalChars(msg) then
            coloredLetterIndex = 0
            currentLine = currentLine + 1
          end
        end
      end

      local maxWidth = titleLabel:GetStringWidth()
      local totalHeight = titleLineHeight + padding * 2
      local lastIndex = 0
      
      for i, lbl in ipairs(labels) do
        if lbl:GetText() ~= "" then lastIndex = i end
      end
      
      for i, lbl in ipairs(labels) do
        local t = lbl:GetText() or ""
        if t ~= "" then
          local w = lbl:GetStringWidth()
          if w > maxWidth then maxWidth = w end
          totalHeight = totalHeight + textLineHeight + (i ~= lastIndex and (textPadding - 2) or 2)
        end
      end

      popupFrame:SetWidth(maxWidth + padding * 2)
      popupFrame:SetHeight(totalHeight)

      if not messages[currentLine] then
        typingActive = false
        waitBeforeFade = 0
      end
    end
    return
  end

  if not typingActive and not fadeActive and not waitingActive then
    waitBeforeFade = waitBeforeFade + elapsed
    if waitBeforeFade > DISPLAY_DURATION then
      fadeFrame(popupFrame, "OUT", FADE_DURATION, function()
        popupFrame:Hide()
        AutoLFM.Core.Persistent.SetWelcomeShown(true)
        popupFrame:SetScript("OnUpdate", nil)
      end)
    end
  end
end

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Shows the welcome popup with typing animation
function AutoLFM.Components.WelcomePopup.Show()
  popupFrame = popupFrame or createPopup()
  if not popupFrame then return end

  lastUpdate = nil
  titleBlockIndex, titleLetterIndex = 1, 0
  currentLine, coloredLetterIndex = 1, 0
  typingElapsed, fadeElapsed, waitBeforeFade, waitBeforeStart = 0, 0, 0, 0
  fadeActive, typingActive, waitingActive = false, false, true

  popupFrame:SetAlpha(0)
  popupFrame:SetHeight(titleLineHeight + padding * 2)
  popupFrame:SetWidth(50)
  popupFrame:Show()
  popupFrame:SetScript("OnUpdate", onUpdate)

  fadeFrame(popupFrame, "IN", FADE_DURATION)
end

--=============================================================================
-- INITIALIZATION
--=============================================================================

--- Initializes WelcomePopup and shows it on first launch
AutoLFM.Core.SafeRegisterInit("Components.WelcomePopup", function()
  if not AutoLFM.Core.Persistent.GetWelcomeShown() then
    AutoLFM.Components.WelcomePopup.Show()
  end
end, {
  id = "I09",
  dependencies = { "Core.Persistent" }
})
