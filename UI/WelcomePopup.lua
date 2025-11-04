--=============================================================================
-- AutoLFM: Welcome Popup Optimized with Colored Typing
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
local coloredLetterIndex = 0

local typingElapsed, fadeElapsed, fadeTotal = 0, 0, 0
local fadeMode, fadeFunc
local waitBeforeStart, waitBeforeFade = 0, 0
local typingActive, fadeActive, waitingActive = false, false, false
local lastUpdate = nil

-------------------------------------------------------------------------------
-- Data
-------------------------------------------------------------------------------
local titleBlocks = {
    { text = "Thank you for using ", r = 0.9, g = 0.9, b = 0.9 },
    { text = "Auto", r = 0.9, g = 0.9, b = 0.9 },
    { text = "L",    r = 0.2, g = 0.7, b = 1 },
    { text = "F",    r = 1, g = 1, b = 1 },
    { text = "M",    r = 1, g = 0, b = 0 },
}

local messages = {
    { text = " ", r=1,g=1,b=1 },
    { subblocks = {
        { text = "Automated ", r = 0.9, g = 0.9, b = 0.9 },
        { text = "L", r=0.2,g=0.7,b=1 },
        { text = "F", r=1,g=1,b=1 },
        { text = "M", r=1,g=0,b=0 },
        { text = " Broadcaster optimized for ", r = 0.9, g = 0.9, b = 0.9 },
        { text = "Turtle WoW", r=0.4,g=0.8,b=0.4, fontSize=16 },
    }, lineIndex=2 },
    { text = " ", r=1,g=1,b=1 },
    { subblocks = {
        { text = "Select your ", r = 0.9, g = 0.9, b = 0.9 },
        { text = "dungeons, raids, or quests", r=0.4,g=0.7,b=1 },
    }, lineIndex=4 },
    { subblocks = {
        { text = "Pick the roles you need ", r = 0.9, g = 0.9, b = 0.9 },
        { text = "(Tank/Healer/DPS)", r=0.7,g=0.6,b=1 },
    }, lineIndex=5 },
    { subblocks = {
        { text = "Broadcast automatically on chosen channels ", r = 0.9, g = 0.9, b = 0.9 },
        { text = "(World, LFG or Hardcore)", r=0.5,g=0.5,b=1 },
    }, lineIndex=6 },
    { text = " ", r=1,g=1,b=1 },
    { subblocks = {
        { text = "Start now with ", r = 0.9, g = 0.9, b = 0.9, fontSize=14 },
        { text = "/lfm", r=1,g=1,b=0, fontSize=16, outline=true },
    }, lineIndex=9 },
    { text = " ", r=1,g=1,b=1 },
    { subblocks = {
        { text = "Enjoy smooth recruitment in ", r=1,g=0.6,b=0.2, fontSize=14 },
        { text = "Turtle WoW !", r=0.4,g=0.8,b=0.4, fontSize=16, outline=true },
    }, lineIndex=11 },
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
    for i=1,blockIndex do
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

local function GetPartialColoredLine()
    local txt = ""
    local count = 0
    local line = messages[2]
    for _, block in ipairs(line.subblocks) do
        local color = "|cff" .. ToHex(block.r, block.g, block.b)
        for i=1,string.len(block.text) do
            count = count + 1
            if count <= coloredLetterIndex then
                txt = txt .. color .. string.sub(block.text,i,i)
            else
                return txt
            end
        end
    end
    return txt
end

-------------------------------------------------------------------------------
-- Create Popup
-------------------------------------------------------------------------------
M.CreatePopup = function()
    local frame = CreateFrame("Frame", "AutoLFM_WelcomePopup", UIParent)
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile = true, tileSize = 16,
        insets = { left=4, right=4, top=4, bottom=4 },
    })
    frame:SetBackdropColor(0,0,0,0.75)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 250)
    frame:SetWidth(50)
    frame:Hide()

    local tmp = frame:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
    tmp:SetText("M")
    titleLineHeight = tmp:GetHeight() or 20
    tmp:SetFont("Fonts\\FRIZQT__.TTF",14)
    textLineHeight = tmp:GetHeight() or 14
    tmp:Hide()

    initialHeight = titleLineHeight + padding*2
    frame:SetHeight(initialHeight)

    titleLabel = frame:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
    titleLabel:SetFont("Fonts\\FRIZQT__.TTF",22,"OUTLINE")
    titleLabel:SetJustifyH("CENTER")
    titleLabel:SetPoint("TOP",frame,"TOP",0,-padding)

    local i = 1
    while messages[i] do
        local lbl = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        lbl:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        lbl:SetJustifyH("CENTER")
        lbl:SetText("")
        lbl:SetPoint("TOP", frame, "TOP", 0, -padding - titleLineHeight - (i - 1) * (textLineHeight + textPadding - 2))
        labels[i] = lbl
        i = i + 1
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
            popupFrame:SetAlpha(fadeMode=="IN" and 1 or 0)
            fadeActive = false
            if fadeFunc then fadeFunc() end
        else
            popupFrame:SetAlpha(fadeMode=="IN" and progress or (1-progress))
        end
        return
    end

    if waitingActive then
        waitBeforeStart = waitBeforeStart + elapsed
        if waitBeforeStart > 0.5 then
            waitingActive = false
            typingActive = true
            titleBlockIndex, titleLetterIndex = 1,0
            currentLine,messageLetterIndex,coloredLetterIndex = 1,0,0
        end
        return
    end

    if typingActive then
        typingElapsed = typingElapsed + elapsed
        if typingElapsed > 0.03 then
            typingElapsed = 0

            if titleBlocks[titleBlockIndex] then
                local block = titleBlocks[titleBlockIndex]
                if titleLetterIndex < string.len(block.text) then
                    titleLetterIndex = titleLetterIndex + 1
                    titleLabel:SetText(M.GetPartialTitleText(titleBlockIndex,titleLetterIndex))
                else
                    titleBlockIndex = titleBlockIndex + 1
                    titleLetterIndex = 0
                end

            elseif currentLine == 2 and messages[2].subblocks then
                coloredLetterIndex = coloredLetterIndex + 1
                labels[2]:SetText(GetPartialColoredLine())
                local totalChars = 0
                for _, block in ipairs(messages[2].subblocks) do
                    totalChars = totalChars + string.len(block.text)
                end
                if coloredLetterIndex >= totalChars then
                    coloredLetterIndex = 0
                    currentLine = currentLine + 1
                end

            else
                local msg = messages[currentLine]
                local lbl = labels[currentLine]
                if msg and lbl then
                    if msg.subblocks then
                        coloredLetterIndex = coloredLetterIndex + 1
                        local txt = ""
                        local count = 0
                        for _, block in ipairs(msg.subblocks) do
                            local color = "|cff" .. ToHex(block.r or 1, block.g or 1, block.b or 1)
                            for i = 1, string.len(block.text) do
                                count = count + 1
                                if count <= coloredLetterIndex then
                                    txt = txt .. color .. string.sub(block.text,i,i)
                                else
                                    break
                                end
                            end
                        end
                        lbl:SetText(txt)

                        local totalChars = 0
                        for _, block in ipairs(msg.subblocks) do
                            totalChars = totalChars + string.len(block.text)
                        end
                        if coloredLetterIndex >= totalChars then
                            coloredLetterIndex = 0
                            currentLine = currentLine + 1
                        end
                    else
                        local text = msg.text or ""
                        if messageLetterIndex < string.len(text) then
                            messageLetterIndex = messageLetterIndex + 1
                            lbl:SetText(string.sub(text,1,messageLetterIndex))
                            lbl:SetTextColor(msg.r or 1,msg.g or 1,msg.b or 1)
                        else
                            messageLetterIndex = 0
                            currentLine = currentLine + 1
                        end
                    end
                end
            end

            local maxWidth = titleLabel:GetStringWidth()
            local totalHeight = titleLineHeight + padding*2

            local lastIndex = 0
            for i, lbl in ipairs(labels) do
                if lbl:GetText() ~= "" then
                    lastIndex = i
                end
            end

            for i, lbl in ipairs(labels) do
                local t = lbl:GetText() or ""
                if t ~= "" then
                    local w = lbl:GetStringWidth()
                    if w > maxWidth then maxWidth = w end
                    if i ~= lastIndex then
                        totalHeight = totalHeight + textLineHeight + textPadding - 2
                    else
                        totalHeight = totalHeight + textLineHeight + 2
                    end
                end
            end

            popupFrame:SetWidth(maxWidth + padding*2)
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
        if waitBeforeFade > 4 then
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

    titleBlockIndex,titleLetterIndex = 1,0
    currentLine,messageLetterIndex,coloredLetterIndex = 1,0,0
    typingElapsed,fadeElapsed,waitBeforeFade,waitBeforeStart = 0,0,0,0
    fadeActive,typingActive,waitingActive = false,false,true

    popupFrame:SetAlpha(0)
    popupFrame:SetHeight(initialHeight)
    popupFrame:SetWidth(50)
    popupFrame:Show()
    popupFrame:SetPoint("CENTER",UIParent,"CENTER",0,250)
    popupFrame:SetScript("OnUpdate",M.OnUpdate)

    M.FadeFrame(popupFrame,"IN",0.5)
end

-- SLASH_LFMWELCOME1 = "/lfmw"
-- SlashCmdList["LFMWELCOME"] = function(msg)
--     M.Show()
-- end
