--=============================================================================
-- AutoLFM: Welcome Popup
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if AutoLFM.UI.WelcomePopup then return end

AutoLFM.UI.WelcomePopup = {}
M = AutoLFM.UI.WelcomePopup

-------------------------------------------------------------------------------
-- Local State
-------------------------------------------------------------------------------
local popupFrame
local titleLabel
local labels = {}
local currentLine = 1
local typingElapsed = 0
local fadeElapsed = 0
local fadeTotal = 0
local fadeMode
local fadeFunc
local waitBeforeStart = 0
local waitBeforeFade = 0
local typingActive = false
local fadeActive = false
local waitingActive = false
local lastUpdate = nil

local padding = 20
local textPadding = 6
local titleLineHeight = 0
local textLineHeight = 0
local initialHeight = 0

-------------------------------------------------------------------------------
-- Title blocks
-------------------------------------------------------------------------------
local titleBlocks = {
    { text = "Welcome to ", r = 1, g = 1, b = 1 },
    { text = "Auto", r = 1, g = 1, b = 1 },
    { text = "L",    r = 0.2, g = 0.7, b = 1 },
    { text = "F",    r = 1,   g = 0,   b = 0 },
    { text = "M",    r = 1,   g = 1,   b = 1 },
}

local messages = {
    { text = " ", r = 1, g = 1, b = 1 },
    { text = " ", r = 1, g = 1, b = 1 },
    { text = "Automated LFM Broadcaster optimized for Turtle WoW", r = 0.2, g = 0.7, b = 1 },
    { text = " ", r = 1, g = 1, b = 1 },
    { text = "Select dungeons, raids, or quests", r = 0.2, g = 0.7, b = 1 },
    { text = "Pick the roles you need (Tank/Healer/DPS)", r = 0.8, g = 0.8, b = 1 },
    { text = "Broadcast automatically on chosen channels", r = 1, g = 0.6, b = 0 },
    { text = " ", r = 1, g = 1, b = 1 },
    { text = "Start now with /lfm", r = 0.2, g = 0.7, b = 1 },
    { text = " ", r = 1, g = 1, b = 1 },
    { text = " ", r = 1, g = 1, b = 1 },
    { text = "Enjoy smooth recruitment in Turtle WoW!", r = 0.4, g = 0.8, b = 0.4 },
}



-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------
M.FadeFrame = function(frame, mode, duration, onFinish)
    fadeMode = mode
    fadeElapsed = 0
    fadeTotal = duration
    fadeFunc = onFinish
    fadeActive = true

    if mode == "IN" then
        frame:SetAlpha(0)
        frame:Show()
    else
        frame:SetAlpha(1)
    end
end

M.GetPartialTitleText = function(blockIndex, letterIndex)
    local text = ""
    local i = 1
    while titleBlocks[i] do
        if i < blockIndex then
            local block = titleBlocks[i]
            local hex = string.format("%02X%02X%02X", block.r*255, block.g*255, block.b*255)
            text = text.."|cff"..hex..block.text
        elseif i == blockIndex then
            local block = titleBlocks[i]
            local hex = string.format("%02X%02X%02X", block.r*255, block.g*255, block.b*255)
            text = text.."|cff"..hex..string.sub(block.text,1,letterIndex)
        end
        i = i + 1
    end
    return text
end

-------------------------------------------------------------------------------
-- Create Popup
-------------------------------------------------------------------------------
M.CreatePopup = function()
    local frame = CreateFrame("Frame", "AutoLFM_WelcomePopup", UIParent)
    frame:SetWidth(50)
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile = true, tileSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0,0,0,0.75)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    frame:Hide()

    local tempTitle = frame:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
    tempTitle:SetText("M")
    titleLineHeight = tempTitle:GetHeight() or 20
    tempTitle:Hide()

    local tempText = frame:CreateFontString(nil,"ARTWORK","GameFontNormal")
    tempText:SetText("M")
    textLineHeight = tempText:GetHeight() or 14
    tempText:Hide()

    initialHeight = titleLineHeight + padding*2
    frame:SetHeight(initialHeight)

    titleLabel = frame:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
    titleLabel:SetFont("Fonts\\FRIZQT__.TTF", 22, "OUTLINE")
    titleLabel:SetText("")
    titleLabel:SetJustifyH("CENTER")
    titleLabel:SetPoint("TOP", frame, "TOP", 0, -padding)

    local i = 1
    while messages[i] do
        local lbl = frame:CreateFontString(nil,"ARTWORK","GameFontNormal")
        lbl:SetText("")
        lbl:SetJustifyH("CENTER")
        lbl:SetPoint("TOP", frame, "TOP", 0, -padding - titleLineHeight - (i-1)*(textLineHeight+textPadding))
        lbl:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        labels[i] = lbl
        i = i + 1
    end

    return frame
end

-------------------------------------------------------------------------------
-- OnUpdate
-------------------------------------------------------------------------------
local titleBlockIndex = 1
local titleLetterIndex = 0
local messageLetterIndex = 0

M.OnUpdate = function()
    local now = GetTime()
    local elapsed = lastUpdate and (now - lastUpdate) or 0
    lastUpdate = now

    if fadeActive then
        fadeElapsed = fadeElapsed + elapsed
        local progress = fadeElapsed / fadeTotal
        if progress >= 1 then
            popupFrame:SetAlpha((fadeMode=="IN") and 1 or 0)
            fadeActive = false
            if fadeFunc then fadeFunc() end
        else
            popupFrame:SetAlpha((fadeMode=="IN") and progress or 1-progress)
        end
        return
    end

    if waitingActive then
        waitBeforeStart = waitBeforeStart + elapsed
        if waitBeforeStart > 0.5 then
            waitingActive = false
            typingActive = true
            titleBlockIndex = 1
            titleLetterIndex = 0
            currentLine = 1
            messageLetterIndex = 0
        end
        return
    end

    if typingActive then
        typingElapsed = typingElapsed + elapsed
        if typingElapsed > 0.05 then
            typingElapsed = 0

            if titleBlocks[titleBlockIndex] then
                local block = titleBlocks[titleBlockIndex]
                if titleLetterIndex < string.len(block.text) then
                    titleLetterIndex = titleLetterIndex + 1
                    titleLabel:SetText(M.GetPartialTitleText(titleBlockIndex,titleLetterIndex))
                    local w = titleLabel:GetStringWidth() + padding*2
                    if w > popupFrame:GetWidth() then popupFrame:SetWidth(w) end
                else
                    titleBlockIndex = titleBlockIndex + 1
                    titleLetterIndex = 0
                end
                return
            end

            local msg = messages[currentLine]
            if msg then
                local lbl = labels[currentLine]
                if lbl then
                    local fullText = msg.text or ""
                    if messageLetterIndex < string.len(fullText) then
                        messageLetterIndex = messageLetterIndex + 1
                        local partial = string.sub(fullText, 1, messageLetterIndex)
                        lbl:SetText(partial)
                        lbl:SetTextColor(msg.r or 1,msg.g or 1,msg.b or 1)
                        local w = lbl:GetStringWidth() + padding*2
                        if w > popupFrame:GetWidth() then popupFrame:SetWidth(w) end
                    else
                        currentLine = currentLine + 1
                        messageLetterIndex = 0
                        popupFrame:SetHeight(initialHeight + titleLineHeight + currentLine*(textLineHeight+(textPadding-2)))
                        if not messages[currentLine] then
                            typingActive = false
                            waitBeforeFade = 0
                        end
                    end
                end
            end
        end
        return
    end

    if not typingActive and not fadeActive and not waitingActive then
        waitBeforeFade = waitBeforeFade + elapsed
        if waitBeforeFade > 2.0 then
            M.FadeFrame(popupFrame,"OUT",1.5,function()
                popupFrame:Hide()
                if AutoLFM.Core and AutoLFM.Core.Settings then
                  AutoLFM.Core.Settings.SaveWelcomeShown(true)
                end
                popupFrame:SetScript("OnUpdate",nil)
            end)
        end
    end
end

-------------------------------------------------------------------------------
-- API
-------------------------------------------------------------------------------
M.Init = function()
  if M.ShouldShow() then
    M.Show()
  end
end

M.ShouldShow = function()
  if not (AutoLFM.Core and AutoLFM.Core.Settings) then
    return false
  end
  return not AutoLFM.Core.Settings.LoadWelcomeShown()
end

M.Show = function()
    if not popupFrame then popupFrame = M.CreatePopup() end
    lastUpdate = nil

    titleBlockIndex = 1
    titleLetterIndex = 0
    currentLine = 1
    messageLetterIndex = 0
    typingElapsed = 0
    fadeElapsed = 0
    fadeActive = false
    waitingActive = false
    typingActive = false
    waitBeforeFade = 0
    waitBeforeStart = 0

    popupFrame:SetAlpha(0)
    popupFrame:SetHeight(initialHeight)
    popupFrame:SetWidth(50)
    popupFrame:Show()
    popupFrame:SetPoint("CENTER",UIParent,"CENTER",0,200)
    popupFrame:SetScript("OnUpdate",M.OnUpdate)

    M.FadeFrame(popupFrame,"IN",0.5)
    waitingActive = true
end
