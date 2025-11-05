--=============================================================================
-- AutoLFM:    Dark UI
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.DarkUI then AutoLFM.UI.DarkUI = {} end

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
local DARK_COLOR = {0.3,   0.3,   0.3,   0.9}
local SLIDER_TEXTURE_LIGHT = "sliderBackgroundLight"

local BLACKLIST = {
  "Eyes\\",   "preview",   "rolesTank",   "rolesHeal",   "rolesDPS",   
  "minimap",   "tooltipBackground",   "Button",   "Check",   "Radio",   "Icon"
}

local WHITELIST = {"mainFrame",   "minimapBorder",   "tabActive"}

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local enabled = false
local darkenedFrames = {}

local blacklistPatterns = {}
local whitelistPatterns = {}
local blacklistCount = 0
local whitelistCount = 0

for i,   pattern in ipairs(BLACKLIST) do 
  blacklistPatterns[i] = pattern 
  blacklistCount = blacklistCount + 1
end
for i,   pattern in ipairs(WHITELIST) do 
  whitelistPatterns[i] = pattern 
  whitelistCount = whitelistCount + 1
end

-----------------------------------------------------------------------------
-- Utility Functions
-----------------------------------------------------------------------------
local function GetTableSize(tbl)
  local count = 0
  for _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

-----------------------------------------------------------------------------
-- Texture Filtering
-----------------------------------------------------------------------------
local function IsWhitelisted(texturePath)
  if not texturePath then return false end
  for i = 1,   whitelistCount do
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
    for i = 1,   blacklistCount do
      if blacklistPatterns[i] and string.find(name, blacklistPatterns[i]) then 
        return true 
      end
    end
  end
  
  for i = 1,   blacklistCount do
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
local function ProcessFrame(frame)
  if not frame then return end
  
  if frame.SetBackdropColor and frame.GetBackdrop and frame:GetBackdrop() then
    local _,   _,   _,   a = frame:GetBackdropColor()
    if a and a > 0 then
      frame:SetBackdropColor(unpack(DARK_COLOR))
    end
  end
  
  if frame.SetBackdropBorderColor then
    frame:SetBackdropBorderColor(unpack(DARK_COLOR))
  end
  
  if frame.SetBackdrop and frame.GetBackdrop then
    local backdrop = frame:GetBackdrop()
    if IsSliderBackdrop(backdrop) and AutoLFM.Core and AutoLFM.Core.Constants then
      local texturePath = AutoLFM.Core.Constants.TEXTURE_PATH
      if texturePath then
        frame:SetBackdrop({
          bgFile = texturePath .. SLIDER_TEXTURE_LIGHT,  
          edgeFile = backdrop.edgeFile,  
          tile = true,  
          tileSize = 8,  
          edgeSize = 8,  
          insets = {left = 3,   right = 3,   top = 6,   bottom = 6}
        })
        frame:SetBackdropColor(unpack(DARK_COLOR))
      end
    end
  end
  
  if frame.GetRegions then
    local regions = {frame:GetRegions()}
    for _,   region in pairs(regions) do
      if region and region.SetVertexColor and region:GetObjectType() == "Texture" then
        local skipRegion = false
        
        if region.GetBlendMode and region:GetBlendMode() == "ADD" then
          skipRegion = true
        end
        
        if not skipRegion and IsBlacklisted(region) then
          skipRegion = true
        end
        
        if not skipRegion then
          region:SetVertexColor(unpack(DARK_COLOR))
        end
      end
    end
  end
end

-----------------------------------------------------------------------------
-- Core Darkening
-----------------------------------------------------------------------------
function AutoLFM.UI.DarkUI.DarkenFrame(frame)
  if not enabled or not frame then return end
  
  ProcessFrame(frame)
  
  if frame.GetChildren then
    local children = {frame:GetChildren()}
    for _,   child in pairs(children) do
      AutoLFM.UI.DarkUI.DarkenFrame(child)
    end
  end
end

-----------------------------------------------------------------------------
-- Theme Management
-----------------------------------------------------------------------------
local function ApplyDarkTheme()
  if not enabled then return end
  local frameCount = GetTableSize(darkenedFrames)
  for i = 1,   frameCount do
    if darkenedFrames[i] then
      AutoLFM.UI.DarkUI.DarkenFrame(darkenedFrames[i])
    end
  end
end

local function ShowReloadMessage()
  if AutoLFM and AutoLFM.Core and AutoLFM.Core.Utils and AutoLFM.Color then
    local msg = AutoLFM.Color("You must ",   "orange") .. 
                AutoLFM.Color("/reload",   "gold") .. 
                AutoLFM.Color(" to apply changes.",   "orange")
    AutoLFM.Core.Utils.PrintSuccess(msg)
  end
end

-----------------------------------------------------------------------------
-- Public API
-----------------------------------------------------------------------------
function AutoLFM.UI.DarkUI.RegisterFrame(frame)
  if frame then
    local currentCount = GetTableSize(darkenedFrames)
    darkenedFrames[currentCount + 1] = frame
    if enabled then
      AutoLFM.UI.DarkUI.DarkenFrame(frame)
    end
  end
end

function AutoLFM.UI.DarkUI.RefreshFrame(frame)
  if enabled and frame then
    AutoLFM.UI.DarkUI.DarkenFrame(frame)
  end
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
  if enabled then
    AutoLFM.UI.DarkUI.Disable()
  else
    AutoLFM.UI.DarkUI.Enable()
  end
end

function AutoLFM.UI.DarkUI.IsEnabled()
  return enabled
end

function AutoLFM.UI.DarkUI.Init()
  if AutoLFM and AutoLFM.Core and AutoLFM.Core.Settings then
    enabled = AutoLFM.Core.Settings.LoadDarkMode()
    if enabled then
      ApplyDarkTheme()
    end
  end
end
