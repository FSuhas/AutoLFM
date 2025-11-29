--=============================================================================
-- AutoLFM: Dark UI (Optimized & Readable)
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.DarkUI then AutoLFM.UI.DarkUI = {} end

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
local DARK_COLOR = {r = 0.3, g = 0.3, b = 0.3, a = 0.9}
local SLIDER_TEXTURE_LIGHT = "sliderBackgroundLight"

local BLACKLIST = {
    "Eyes\\", "preview", "rolesTank", "rolesHeal", "rolesDPS",
    "minimap", "tooltipBackground", "Button", "Check", "Radio", "Icon"
}

local WHITELIST = {"mainFrame", "minimapBorder", "tabActive"}

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local enabled = false
local darkenedFrames = {}

local blacklistPatterns = {}
local whitelistPatterns = {}
local blacklistCount, whitelistCount = 0, 0

for i, pattern in ipairs(BLACKLIST) do
    blacklistPatterns[i] = pattern
    blacklistCount = blacklistCount + 1
end
for i, pattern in ipairs(WHITELIST) do
    whitelistPatterns[i] = pattern
    whitelistCount = whitelistCount + 1
end

-----------------------------------------------------------------------------
-- Utility Functions
-----------------------------------------------------------------------------
local function IsWhitelisted(texturePath)
    if not texturePath then return false end
    for i = 1, whitelistCount do
        if whitelistPatterns[i] and string.find(texturePath, whitelistPatterns[i]) then
            return true
        end
    end
    return false
end

local function IsBlacklisted(texture)
    if not texture then return true end
    local texturePath = texture:GetTexture()
    if not texturePath then return true end
    if IsWhitelisted(texturePath) then return false end

    local name = texture:GetName()
    if name then
        for i = 1, blacklistCount do
            if blacklistPatterns[i] and string.find(name, blacklistPatterns[i]) then
                return true
            end
        end
    end
    for i = 1, blacklistCount do
        if blacklistPatterns[i] and string.find(texturePath, blacklistPatterns[i]) then
            return true
        end
    end
    return false
end

local function IsSliderBackdrop(backdrop)
    return backdrop and backdrop.edgeSize == 8 and backdrop.tileSize == 8
end

-----------------------------------------------------------------------------
-- Frame Processing
-----------------------------------------------------------------------------
local function ProcessBackdropColor(frame)
    if not frame or not frame.SetBackdropColor or not frame.GetBackdrop then return end
    local backdrop = frame:GetBackdrop()
    if not backdrop then return end
    local _, _, _, a = frame:GetBackdropColor()
    if not a or a <= 0 then return end
    frame:SetBackdropColor(DARK_COLOR.r, DARK_COLOR.g, DARK_COLOR.b, DARK_COLOR.a)
end

local function ProcessBackdropBorder(frame)
    if not frame or not frame.SetBackdropBorderColor then return end
    frame:SetBackdropBorderColor(DARK_COLOR.r, DARK_COLOR.g, DARK_COLOR.b, DARK_COLOR.a)
end

local function ProcessSliderBackdrop(frame)
    if not frame or not frame.SetBackdrop or not frame.GetBackdrop then return end
    local backdrop = frame:GetBackdrop()
    if not backdrop or not IsSliderBackdrop(backdrop) then return end
    if not AutoLFM.Core or not AutoLFM.Core.Constants then return end
    local texturePath = AutoLFM.Core.Constants.TEXTURE_PATH
    if not texturePath then return end
    frame:SetBackdrop({
        bgFile = texturePath .. SLIDER_TEXTURE_LIGHT,
        edgeFile = backdrop.edgeFile,
        tile = true, tileSize = 8, edgeSize = 8,
        insets = {left = 3, right = 3, top = 6, bottom = 6}
    })
    frame:SetBackdropColor(DARK_COLOR.r, DARK_COLOR.g, DARK_COLOR.b, DARK_COLOR.a)
end

local function ProcessRegions(frame)
    if not frame or not frame.GetRegions then return end
    for _, region in pairs({frame:GetRegions()}) do
        if region and region.SetVertexColor and region:GetObjectType() == "Texture" then
            local skip = false
            if region.GetBlendMode and region:GetBlendMode() == "ADD" then skip = true end
            if not skip and IsBlacklisted(region) then skip = true end
            if not skip then
                region:SetVertexColor(DARK_COLOR.r, DARK_COLOR.g, DARK_COLOR.b, DARK_COLOR.a)
            end
        end
    end
end

-----------------------------------------------------------------------------
-- Core Darkening
-----------------------------------------------------------------------------
function AutoLFM.UI.DarkUI.DarkenFrame(frame)
    if not enabled or not frame then return end
    ProcessBackdropColor(frame)
    ProcessBackdropBorder(frame)
    ProcessSliderBackdrop(frame)
    ProcessRegions(frame)

    if frame.GetChildren then
        for _, child in pairs({frame:GetChildren()}) do
            AutoLFM.UI.DarkUI.DarkenFrame(child)
        end
    end
end

-----------------------------------------------------------------------------
-- Theme Management
-----------------------------------------------------------------------------
local function ApplyDarkTheme()
    if not enabled then return end
    for i, frame in ipairs(darkenedFrames) do
        if frame then AutoLFM.UI.DarkUI.DarkenFrame(frame) end
    end
end

local function ShowReloadMessage()
    if AutoLFM and AutoLFM.Core and AutoLFM.Core.Utils and AutoLFM.Color then
        local msg = AutoLFM.Color("You must ", "orange") ..
                    AutoLFM.Color("/reload", "gold") ..
                    AutoLFM.Color(" to apply changes.", "orange")
        AutoLFM.Core.Utils.PrintSuccess(msg)
    end
end

-----------------------------------------------------------------------------
-- Public API
-----------------------------------------------------------------------------
function AutoLFM.UI.DarkUI.RegisterFrame(frame)
    if frame then
        table.insert(darkenedFrames, frame)
        if enabled then AutoLFM.UI.DarkUI.DarkenFrame(frame) end
    end
end

function AutoLFM.UI.DarkUI.RefreshFrame(frame)
    if enabled and frame then AutoLFM.UI.DarkUI.DarkenFrame(frame) end
end

function AutoLFM.UI.DarkUI.Enable()
    enabled = true
    ApplyDarkTheme()
    if AutoLFM and AutoLFM.Core and AutoLFM.Core.Settings then
        AutoLFM.Core.Settings.SaveDarkMode(true)
    end
    ShowReloadMessage()
end

function AutoLFM.UI.DarkUI.Disable()
    enabled = false
    if AutoLFM and AutoLFM.Core and AutoLFM.Core.Settings then
        AutoLFM.Core.Settings.SaveDarkMode(false)
    end
    ShowReloadMessage()
end

function AutoLFM.UI.DarkUI.Toggle()
    if enabled then AutoLFM.UI.DarkUI.Disable()
    else AutoLFM.UI.DarkUI.Enable() end
end

function AutoLFM.UI.DarkUI.IsEnabled()
    return enabled
end

function AutoLFM.UI.DarkUI.Init()
    if AutoLFM and AutoLFM.Core and AutoLFM.Core.Settings then
        enabled = AutoLFM.Core.Settings.LoadDarkMode()
        if enabled then ApplyDarkTheme() end
    end
end
