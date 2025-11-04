--=============================================================================
-- AutoLFM: Welcome Popup
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if AutoLFM.UI.WelcomePopup then return end

AutoLFM.UI.WelcomePopup = {}
local M = AutoLFM.UI.WelcomePopup

-------------------------------------------------------------------------------
-- Local State
-------------------------------------------------------------------------------
local popupFrame, titleLabel
local labels = {}
local padding, textPadding = 18, 6
local titleLineHeight, textLineHeight, initialHeight = 0, 0, 0

local titleBlockIndex, titleLetterIndex = 1, 0
local messageLetterIndex, currentLine = 0, 1

local typingElapsed, fadeElapsed, fadeTotal = 0, 0, 0
local fadeMode, fadeFunc
local waitBeforeStart, waitBeforeFade = 0, 0
local typingActive, fadeActive, waitingActive = false, false, false
local lastUpdate = nil

-------------------------------------------------------------------------------
-- Data
-------------------------------------------------------------------------------
local titleBlocks = {
    { text = "Welcome to ", r = 1, g = 1, b = 1 },
    { text = "Auto",        r = 1, g = 1, b = 1 },
    { text = "L",           r = 0.2, g = 0.7, b = 1 },
    { text = "F",           r = 1,   g = 0,   b = 0 },
    { text = "M",           r = 1,   g = 1,   b = 1 },
}

local messages = {
    { text = " ", r = 1, g = 1, b = 1 },
    { text = "Automated LFM Broadcaster optimized for Turtle WoW", r = 0.2, g = 0.7, b = 1 },
    { text = " ", r = 1, g = 1, b = 1 },
    { text = " ", r = 1, g = 1, b = 1 },
    { text = "Select dungeons, raids, or quests",                  r = 0.2, g = 0.7, b = 1 },
    { text = "Pick the roles you need (Tank/Healer/DPS)",          r = 0.8, g = 0.8, b = 1 },
    { text = "Broadcast automatically on chosen channels",         r = 1,   g = 0.6, b = 0 },
    { text = " ", r = 1, g = 1, b = 1 },
    { text = "Start now with /lfm",                               r = 0.2, g = 0.7, b = 1 },
    { text = " ", r = 1, g = 1, b = 1 },
    { text = "Enjoy smooth recruitment in Turtle WoW!",            r = 0.4, g = 0.8, b = 0.4 },
}

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------
local function ToHex(r, g, b)
    return string.format("%02X%02X%02X", r * 255, g * 255, b * 255)
end

M.FadeFrame = function(frame, mode, duration, onFinish)
    fadeMode, fadeElapsed, fadeTotal = mode, 0, duration
    fadeFunc, fadeActive = onFinish, true
    frame:SetAlpha(mode == "IN" and 0 or 1)
    if mode == "IN" then frame:Show() end
end

M.GetPartialTitleText = function(blockIndex, letterIndex)
    local text = ""
    for i = 1, blockIndex do
        local block = titleBlocks[i]
        local color = "|cff" .. ToHex(block.r, block.g, block.b)
        if i < blockIndex then
            text = text .. color .. block.text
        else
            text = text .. color .. string.sub(block.text, 1, letterIndex)
        end
    end
    return text
end

-------------------------------------------------------------------------------
-- Create Popup
-------------------------------------------------------------------------------
M.CreatePopup = function()
    local frame = CreateFrame("Frame", "AutoLFM_WelcomePopup", UIParent)
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile = true, tileSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.75)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    frame:SetWidth(50)
    frame:Hide()

    local tmp = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    tmp:SetText("M")
    titleLineHeight = tmp:GetHeight() or 20
    tmp:SetFont("Fonts\\FRIZQT__.TTF", 14)
    textLineHeight = tmp:GetHeight() or 14
    tmp:Hide()

    initialHeight = titleLineHeight + padding * 2
    frame:SetHeight(initialHeight)

    titleLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    titleLabel:SetFont("Fonts\\FRIZQT__.TTF", 22, "OUTLINE")
    titleLabel:SetJustifyH("CENTER")
    titleLabel:SetPoint("TOP", frame, "TOP", 0, -padding)

    for i, _ in ipairs(messages) do
        local lbl = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        lbl:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        lbl:SetJustifyH("CENTER")
        lbl:SetText("")
        lbl:SetPoint("TOP", frame, "TOP", 0, -padding - titleLineHeight - (i - 1) * (textLineHeight + textPadding-2))
        labels[i] = lbl
    end
    return frame
end

-------------------------------------------------------------------------------
-- OnUpdate
-------------------------------------------------------------------------------
M.OnUpdate = function()
    local now = GetTime()
    local elapsed = lastUpdate and (now - lastUpdate) or 0
    lastUpdate = now

    if fadeActive then
        fadeElapsed = fadeElapsed + elapsed
        local progress = fadeElapsed / fadeTotal
        if progress >= 1 then
            popupFrame:SetAlpha((fadeMode == "IN") and 1 or 0)
            fadeActive = false
            if fadeFunc then fadeFunc() end
        else
            popupFrame:SetAlpha((fadeMode == "IN") and progress or (1 - progress))
        end
        return
    end

    if waitingActive then
        waitBeforeStart = waitBeforeStart + elapsed
        if waitBeforeStart > 0.5 then
            waitingActive = false
            typingActive = true
            titleBlockIndex, titleLetterIndex = 1, 0
            currentLine, messageLetterIndex = 1, 0
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
                    titleLabel:SetText(M.GetPartialTitleText(titleBlockIndex, titleLetterIndex))
                    local w = titleLabel:GetStringWidth() + padding * 2
                    if w > popupFrame:GetWidth() then
                        popupFrame:SetWidth(w)
                    end
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
                    local text = msg.text or ""
                    if messageLetterIndex < string.len(text) then
                        messageLetterIndex = messageLetterIndex + 1
                        lbl:SetText(string.sub(text, 1, messageLetterIndex))
                        lbl:SetTextColor(msg.r or 1, msg.g or 1, msg.b or 1)
                        local w = lbl:GetStringWidth() + padding * 2
                        if w > popupFrame:GetWidth() then
                            popupFrame:SetWidth(w)
                        end
                    else
                        currentLine = currentLine + 1
                        messageLetterIndex = 0
                        popupFrame:SetHeight(initialHeight + titleLineHeight + currentLine * (textLineHeight + textPadding))
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
        if waitBeforeFade > 2 then
            M.FadeFrame(popupFrame, "OUT", 1.5, function()
                popupFrame:Hide()
                if AutoLFM.Core and AutoLFM.Core.Settings then
                    AutoLFM.Core.Settings.SaveWelcomeShown(true)
                end
                popupFrame:SetScript("OnUpdate", nil)
            end)
        end
    end
end


-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
M.Init = function()
    if M.ShouldShow() then M.Show() end
end

M.ShouldShow = function()
    if not (AutoLFM.Core and AutoLFM.Core.Settings) then return false end
    return not AutoLFM.Core.Settings.LoadWelcomeShown()
end

M.Show = function()
    popupFrame = popupFrame or M.CreatePopup()
    lastUpdate = nil

    titleBlockIndex, titleLetterIndex = 1, 0
    currentLine, messageLetterIndex = 1, 0
    typingElapsed, fadeElapsed, waitBeforeFade, waitBeforeStart = 0, 0, 0, 0
    fadeActive, typingActive, waitingActive = false, false, true

    popupFrame:SetAlpha(0)
    popupFrame:SetHeight(initialHeight)
    popupFrame:SetWidth(50)
    popupFrame:Show()
    popupFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    popupFrame:SetScript("OnUpdate", M.OnUpdate)

    M.FadeFrame(popupFrame, "IN", 0.5)
end


SLASH_LFMWELCOME1 = "/lfmw"
SlashCmdList["LFMWELCOME"] = function(msg)
    M.Show()
end
