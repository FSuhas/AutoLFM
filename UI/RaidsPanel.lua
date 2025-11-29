--=============================================================================
-- AutoLFM: Raids Panel
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.RaidsPanel then AutoLFM.UI.RaidsPanel = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local mainFrame, scrollFrame, contentFrame
local clickableFrames, checkButtons = {}, {}
local raidSizeControlFrame, raidSizeSlider, raidSizeEditBox, raidSizeValueText, raidSizeLabelText

-----------------------------------------------------------------------------
-- Size Controls
-----------------------------------------------------------------------------
local function GetRaidSizeState(raidTag)
    if not raidTag or not AutoLFM.Logic.Content.GetRaidByTag then
        return {isFixed = true, minSize = 10, maxSize = 10, currentSize = 10}
    end

    local raid = AutoLFM.Logic.Content.GetRaidByTag(raidTag)
    if not raid then return {isFixed = true, minSize = 10, maxSize = 10, currentSize = 10} end

    local minSize, maxSize = AutoLFM.Logic.Content.GetRaidSizeRange(raidTag)
    local currentSize = AutoLFM.Logic.Content.InitRaidSize(raidTag)
    return {isFixed = (minSize == maxSize), minSize = minSize, maxSize = maxSize, currentSize = currentSize}
end

local function SetFixedSizeState()
    if not raidSizeSlider or not raidSizeEditBox or not raidSizeValueText then return end

    raidSizeSlider:Hide()
    raidSizeEditBox:Hide()
    raidSizeValueText:SetText("10")
    raidSizeValueText:Show()

    if AutoLFM.Core.Utils then
        AutoLFM.Core.Utils.SetFontColor(raidSizeValueText, "gray")
        if raidSizeLabelText then AutoLFM.Core.Utils.SetFontColor(raidSizeLabelText, "white") end
    end

    if AutoLFM.Logic.Content.SetRaidSize then
        AutoLFM.Logic.Content.SetRaidSize(10)
    end
end

local function SetVariableSizeState(sizeState)
    if not sizeState or not raidSizeSlider or not raidSizeEditBox or not raidSizeValueText then return end

    raidSizeValueText:Hide()

    raidSizeSlider:SetMinMaxValues(sizeState.minSize, sizeState.maxSize)
    raidSizeSlider:SetValue(sizeState.currentSize)
    raidSizeSlider:Show()

    raidSizeEditBox:SetText(tostring(sizeState.currentSize))
    raidSizeEditBox:Show()
    raidSizeEditBox:SetFocus()
    raidSizeEditBox:HighlightText()

    if AutoLFM.Core.Utils then
        AutoLFM.Core.Utils.SetFontColor(raidSizeEditBox, "yellow")
        if raidSizeLabelText then AutoLFM.Core.Utils.SetFontColor(raidSizeLabelText, "gold") end
    end
end

local function UpdateSizeControlsForRaid(raidTag)
    local sizeState = GetRaidSizeState(raidTag)
    if sizeState.isFixed then
        SetFixedSizeState()
    else
        SetVariableSizeState(sizeState)
    end
end

-----------------------------------------------------------------------------
-- Raid List
-----------------------------------------------------------------------------
local function OnRaidCheckboxClick(checkbox, raidTag)
    if not checkbox or not raidTag then return end

    local isChecked = checkbox:GetChecked()

    if isChecked then
        for tag, otherCheckbox in pairs(checkButtons) do
            if otherCheckbox ~= checkbox then
                otherCheckbox:SetChecked(false)
                local parent = otherCheckbox:GetParent()
                if parent then parent:SetBackdrop(nil) end
            end
        end

        if AutoLFM.Logic.Content.ToggleRaid then
            AutoLFM.Logic.Content.ToggleRaid(raidTag, true)
        end
        UpdateSizeControlsForRaid(raidTag)
    else
        if AutoLFM.Logic.Content.ToggleRaid then
            AutoLFM.Logic.Content.ToggleRaid(raidTag, false)
        end
        SetFixedSizeState()
    end

    local parent = checkbox:GetParent()
    if parent then parent:SetBackdrop(nil) end
end

local function CreateRaidRow(parent, raid, index, yOffset)
    if not parent or not raid then return end

    local checked = AutoLFM.Logic.Content.IsRaidSelected and AutoLFM.Logic.Content.IsRaidSelected(raid.tag)
    local sizeText = raid.sizeMin == raid.sizeMax and "("..raid.sizeMin..")" or "("..raid.sizeMin.." - "..raid.sizeMax..")"

    local frame = AutoLFM.UI.PanelBuilder.CreateSelectableRow{
        parent = parent,
        frameName = "RaidRow"..index,
        checkboxName = "RaidCheckbox"..index,
        yOffset = yOffset,
        mainText = raid.name,
        rightText = sizeText,
        color = {r=1, g=0.82, b=0},
        isChecked = checked,
        onCheckboxClick = function(cb) OnRaidCheckboxClick(cb, raid.tag) end
    }

    if frame then
        checkButtons[raid.tag] = frame.checkbox
        table.insert(clickableFrames, frame)
    end

    return frame
end

-----------------------------------------------------------------------------
-- Panel Display
-----------------------------------------------------------------------------
function AutoLFM.UI.RaidsPanel.Display(parent)
    if not parent then return end

    for _, child in ipairs({parent:GetChildren()}) do child:Hide() end
    clickableFrames, checkButtons = {}, {}

    local raids = AutoLFM.Core.Constants.RAIDS or {}
    local yOffset = 0

    for index, raid in ipairs(raids) do
        CreateRaidRow(parent, raid, index, yOffset)
        yOffset = yOffset + 20
    end
end

function AutoLFM.UI.RaidsPanel.ClearSelection()
    if AutoLFM.Logic.Content.ClearRaids then AutoLFM.Logic.Content.ClearRaids() end
    AutoLFM.UI.PanelBuilder.ClearCheckboxes(checkButtons)
    SetFixedSizeState()
end

function AutoLFM.UI.RaidsPanel.ClearBackdrops()
    AutoLFM.UI.PanelBuilder.ClearBackdrops(clickableFrames)
end

function AutoLFM.UI.RaidsPanel.UpdateCheckboxes()
    if AutoLFM.Logic.Content.IsRaidSelected then
        AutoLFM.UI.PanelBuilder.UpdateCheckboxes(checkButtons, AutoLFM.Logic.Content.IsRaidSelected)
    end
end

-----------------------------------------------------------------------------
-- Size Controls UI
-----------------------------------------------------------------------------
function AutoLFM.UI.RaidsPanel.ShowSizeControls()
    if raidSizeControlFrame then raidSizeControlFrame:Show() end

    if AutoLFM.Logic.Content.GetSelectedRaids then
        local selected = AutoLFM.Logic.Content.GetSelectedRaids()
        if selected and table.getn(selected) > 0 then
            UpdateSizeControlsForRaid(selected[1])
        else
            SetFixedSizeState()
        end
    end
end

function AutoLFM.UI.RaidsPanel.HideSizeControls()
    if raidSizeControlFrame then raidSizeControlFrame:Hide() end
end

function AutoLFM.UI.RaidsPanel.CreateSizeSlider(bottomZone)
    if not bottomZone or raidSizeControlFrame then return end

    raidSizeControlFrame = CreateFrame("Frame", nil, bottomZone)
    raidSizeControlFrame:SetAllPoints(bottomZone)
    raidSizeControlFrame:Hide()

    local raidSizeLabelFrame = CreateFrame("Button", nil, raidSizeControlFrame)
    raidSizeLabelFrame:SetWidth(65)
    raidSizeLabelFrame:SetHeight(20)
    raidSizeLabelFrame:SetPoint("LEFT", raidSizeControlFrame, "LEFT", 0, 0)

    raidSizeLabelText = raidSizeLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    raidSizeLabelText:SetPoint("LEFT", raidSizeLabelFrame, "LEFT", 0, 0)
    raidSizeLabelText:SetText("Raid size: ")
    if AutoLFM.Core.Utils then AutoLFM.Core.Utils.SetFontColor(raidSizeLabelText, "white") end

    raidSizeValueText = raidSizeControlFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    raidSizeValueText:SetPoint("LEFT", raidSizeLabelFrame, "RIGHT", -4, 0)
    raidSizeValueText:SetText("10")
    raidSizeValueText:Show()
    if AutoLFM.Core.Utils then AutoLFM.Core.Utils.SetFontColor(raidSizeValueText, "gray") end

    raidSizeEditBox = CreateFrame("EditBox", "AutoLFM_RaidSizeEditBox", raidSizeControlFrame)
    raidSizeEditBox:SetPoint("LEFT", raidSizeLabelFrame, "RIGHT", -4, 0)
    raidSizeEditBox:SetWidth(25)
    raidSizeEditBox:SetHeight(20)
    raidSizeEditBox:SetFont("Fonts\\FRIZQT__.TTF", 12)
    raidSizeEditBox:SetJustifyH("LEFT")
    raidSizeEditBox:SetAutoFocus(false)
    raidSizeEditBox:SetMaxLetters(2)
    raidSizeEditBox:SetText("10")
    raidSizeEditBox:Hide()
    if AutoLFM.Core.Utils then AutoLFM.Core.Utils.SetFontColor(raidSizeEditBox, "yellow") end

    raidSizeSlider = AutoLFM.UI.PanelBuilder.CreateSlider({
        parent = raidSizeControlFrame,
        width = 115,
        height = 17,
        minValue = 10,
        maxValue = 10,
        initialValue = 10,
        valueStep = 1,
        point = {
            point = "LEFT",
            relativeTo = raidSizeEditBox,
            relativePoint = "RIGHT",
            x = 0,
            y = 0
        },
        onValueChanged = function(value)
            if AutoLFM.Logic.Content.SetRaidSize then AutoLFM.Logic.Content.SetRaidSize(value) end
            if raidSizeEditBox then raidSizeEditBox:SetText(tostring(value)) end
        end
    })
    raidSizeSlider:EnableMouse(true)
    raidSizeSlider:Hide()

    raidSizeEditBox:SetScript("OnTextChanged", function()
        local value = tonumber(raidSizeEditBox:GetText())
        if value and raidSizeSlider and raidSizeSlider:IsShown() then
            local minVal, maxVal = raidSizeSlider:GetMinMaxValues()
            if value >= minVal and value <= maxVal then
                raidSizeSlider:SetValue(value)
            end
        end
    end)
    raidSizeEditBox:SetScript("OnEnterPressed", function() raidSizeEditBox:ClearFocus() end)
    raidSizeEditBox:SetScript("OnEscapePressed", function() raidSizeEditBox:ClearFocus() end)
    raidSizeEditBox:SetScript("OnEditFocusGained", function() raidSizeEditBox:HighlightText() end)

    SetFixedSizeState()
end

-----------------------------------------------------------------------------
-- Panel Management
-----------------------------------------------------------------------------
function AutoLFM.UI.RaidsPanel.Init()
    if mainFrame then return mainFrame end

    local parent = AutoLFM.UI.MainWindow.GetFrame()
    if not parent then return nil end

    local panelData = AutoLFM.UI.PanelBuilder.CreatePanel(parent, "AutoLFM_RaidsPanel")
    if not panelData then return end

    mainFrame = panelData.panel
    panelData = AutoLFM.UI.PanelBuilder.AddScrollFrame(panelData, "AutoLFM_ScrollFrame_Raids")
    scrollFrame, contentFrame = panelData.scrollFrame, panelData.contentFrame

    AutoLFM.UI.RaidsPanel.Display(contentFrame)
    AutoLFM.UI.RaidsPanel.CreateSizeSlider(panelData.bottomZone)

    if AutoLFM.UI.DarkUI then AutoLFM.UI.DarkUI.RegisterFrame(mainFrame) end
    AutoLFM.UI.RaidsPanel.Register()
end

function AutoLFM.UI.RaidsPanel.Show()
    AutoLFM.UI.PanelBuilder.ShowPanel(mainFrame, scrollFrame)
    AutoLFM.UI.RaidsPanel.ShowSizeControls()
    if AutoLFM.UI.DungeonsPanel and AutoLFM.UI.DungeonsPanel.ClearBackdrops then
        AutoLFM.UI.DungeonsPanel.ClearBackdrops()
    end
end

function AutoLFM.UI.RaidsPanel.Hide()
    AutoLFM.UI.PanelBuilder.HidePanel(mainFrame, scrollFrame)
end

function AutoLFM.UI.RaidsPanel.Register()
    AutoLFM.UI.TabNavigation.RegisterPanel("raids",
        AutoLFM.UI.RaidsPanel.Show,
        AutoLFM.UI.RaidsPanel.Hide,
        function()
            AutoLFM.UI.RaidsPanel.ShowSizeControls()
            if AutoLFM.UI.DungeonsPanel and AutoLFM.UI.DungeonsPanel.ClearBackdrops then
                AutoLFM.UI.DungeonsPanel.ClearBackdrops()
            end
        end
    )
end
