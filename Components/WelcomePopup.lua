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
local padding, textPadding = 24, 8
local extraMargin = 24

local state = {
  popupFrame = nil,
  titleLabel = nil,
  labels = {},
  titleLineHeight = 0,
  textLineHeight = 0,
  titleBlockIndex = 1,
  titleLetterIndex = 0,
  currentLine = 1,
  coloredLetterIndex = 0,
  typingElapsed = 0,
  fadeElapsed = 0,
  fadeTotal = 0,
  fadeMode = nil,
  fadeFunc = nil,
  waitBeforeStart = 0,
  waitBeforeFade = 0,
  typingActive = false,
  fadeActive = false,
  waitingActive = false,
  lastUpdate = nil
}

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
  state.fadeMode = mode
  state.fadeElapsed = 0
  state.fadeTotal = duration
  state.fadeFunc = onFinish
  state.fadeActive = true
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
  frame:SetWidth(padding * 2 + extraMargin)
  frame:Hide()

  local tmp = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  tmp:SetText("M")
  state.titleLineHeight = tmp:GetHeight() or 20
  tmp:SetFont("Fonts\\FRIZQT__.TTF", 14)
  state.textLineHeight = tmp:GetHeight() or 14
  tmp:Hide()

  frame:SetHeight(state.titleLineHeight + padding * 2)

  state.titleLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  state.titleLabel:SetFont("Fonts\\FRIZQT__.TTF", 22, "OUTLINE")
  state.titleLabel:SetJustifyH("CENTER")
  state.titleLabel:SetPoint("TOP", frame, "TOP", 0, -padding)

  for i = 1, table.getn(messages) do
    local lbl = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    lbl:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    lbl:SetJustifyH("CENTER")
    lbl:SetText("")
    lbl:SetWidth(600)
    if i == 1 then
      lbl:SetPoint("TOP", state.titleLabel, "BOTTOM", 0, -textPadding)
    else
      lbl:SetPoint("TOP", state.labels[i-1], "BOTTOM", 0, -textPadding)
    end
    state.labels[i] = lbl
  end

  return frame
end

--=============================================================================
-- UPDATE
--=============================================================================

--- OnUpdate handler for typing animation and fade effects
local function onUpdate()
  local now = GetTime()
  local elapsed = state.lastUpdate and (now - state.lastUpdate) or 0
  state.lastUpdate = now

  if state.fadeActive then
    state.fadeElapsed = state.fadeElapsed + elapsed
    local progress = state.fadeElapsed / state.fadeTotal
    if progress >= 1 then
      state.popupFrame:SetAlpha(state.fadeMode == "IN" and 1 or 0)
      state.fadeActive = false
      if state.fadeFunc then state.fadeFunc() end
    else
      state.popupFrame:SetAlpha(state.fadeMode == "IN" and progress or (1 - progress))
    end
    return
  end

  if state.waitingActive then
    state.waitBeforeStart = state.waitBeforeStart + elapsed
    if state.waitBeforeStart > INITIAL_WAIT then
      state.waitingActive = false
      state.typingActive = true
      state.titleBlockIndex, state.titleLetterIndex = 1, 0
      state.currentLine, state.coloredLetterIndex = 1, 0
    end
    return
  end

  if state.typingActive then
    state.typingElapsed = state.typingElapsed + elapsed
    if state.typingElapsed > TYPING_SPEED then
      state.typingElapsed = 0

      if titleBlocks[state.titleBlockIndex] then
        local block = titleBlocks[state.titleBlockIndex]
        if state.titleLetterIndex < string.len(block.text) then
          state.titleLetterIndex = state.titleLetterIndex + 1
          state.titleLabel:SetText(getPartialTitleText(state.titleBlockIndex, state.titleLetterIndex))
        else
          state.titleBlockIndex = state.titleBlockIndex + 1
          state.titleLetterIndex = 0
        end
      else
        local msg = messages[state.currentLine]
        local lbl = state.labels[state.currentLine]
        if msg and lbl then
          state.coloredLetterIndex = state.coloredLetterIndex + 1
          lbl:SetText(getPartialColoredText(msg, state.coloredLetterIndex))
          
          if state.coloredLetterIndex >= getTotalChars(msg) then
            state.coloredLetterIndex = 0
            state.currentLine = state.currentLine + 1
          end
        end
      end

      local maxWidth = state.titleLabel:GetStringWidth()
      local totalHeight = state.titleLineHeight + padding * 2
      local lastIndex = 0

      for i, lbl in ipairs(state.labels) do
        if lbl:GetText() ~= "" then lastIndex = i end
      end

      for i, lbl in ipairs(state.labels) do
        local t = lbl:GetText() or ""
        if t ~= "" then
          local w = lbl:GetStringWidth()
          if w > maxWidth then maxWidth = w end
          totalHeight = totalHeight + state.textLineHeight + (i ~= lastIndex and textPadding or 2)
        end
      end

      state.popupFrame:SetWidth(maxWidth + padding * 2 + extraMargin)
      state.popupFrame:SetHeight(totalHeight + padding * 2)

      if not messages[state.currentLine] then
        state.typingActive = false
        state.waitBeforeFade = 0
      end
    end
    return
  end

  if not state.typingActive and not state.fadeActive and not state.waitingActive then
    state.waitBeforeFade = state.waitBeforeFade + elapsed
    if state.waitBeforeFade > DISPLAY_DURATION then
      fadeFrame(state.popupFrame, "OUT", FADE_DURATION, function()
        state.popupFrame:Hide()
        AutoLFM.Core.Storage.SetWelcomeShown(true)
        state.popupFrame:SetScript("OnUpdate", nil)
      end)
    end
  end
end

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Shows the welcome popup with typing animation
function AutoLFM.Components.WelcomePopup.Show()
  state.popupFrame = state.popupFrame or createPopup()
  if not state.popupFrame then return end

  state.lastUpdate = nil
  state.titleBlockIndex, state.titleLetterIndex = 1, 0
  state.currentLine, state.coloredLetterIndex = 1, 0
  state.typingElapsed, state.fadeElapsed, state.waitBeforeFade, state.waitBeforeStart = 0, 0, 0, 0
  state.fadeActive, state.typingActive, state.waitingActive = false, false, true

  state.popupFrame:SetAlpha(0)
  state.popupFrame:SetHeight(state.titleLineHeight + padding * 2)
  state.popupFrame:SetWidth(padding * 2 + extraMargin)
  state.popupFrame:Show()
  state.popupFrame:SetScript("OnUpdate", onUpdate)

  fadeFrame(state.popupFrame, "IN", FADE_DURATION)
end

--=============================================================================
-- INITIALIZATION
--=============================================================================

--- Initializes WelcomePopup and shows it on first launch
AutoLFM.Core.SafeRegisterInit("Components.WelcomePopup", function()
  if not AutoLFM.Core.Storage.GetWelcomeShown() then
    AutoLFM.Components.WelcomePopup.Show()
  end
end, {
  id = "I09",
  dependencies = { "Core.Storage" }
})
