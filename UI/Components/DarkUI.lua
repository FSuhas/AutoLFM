--=============================================================================
-- AutoLFM: Dark UI
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
  ["Eyes\\"] = true,
  ["preview"] = true,
  ["rolesTank"] = true,
  ["rolesHeal"] = true,
  ["rolesDPS"] = true,
  ["minimap"] = true,
  ["tooltipBackground"] = true,
  ["Button"] = true,
  ["Check"] = true,
  ["Radio"] = true,
  ["Icon"] = true,
}

local WHITELIST = {
  ["mainFrame"] = true,
  ["minimapBorder"] = true,
  ["tabActive"] = true
}

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local enabled = false
local darkenedFrames = {}

-----------------------------------------------------------------------------
-- Texture Filtering
-----------------------------------------------------------------------------
local function IsWhitelisted(texturePath)
  if not texturePath then return false end
  for pattern in pairs(WHITELIST) do
    if string.find(texturePath, pattern) then return true end
  end
  return false
end

local function IsBlacklisted(texture)
  if not texture then return true end
  
  local name = texture:GetName()
  local texturePath = texture:GetTexture()
  if not texturePath then return true end
  if IsWhitelisted(texturePath) then return false end
  
  if name then
    for pattern in pairs(BLACKLIST) do
      if string.find(name, pattern) then return true end
    end
  end
  
  for pattern in pairs(BLACKLIST) do
    if string.find(texturePath, pattern) then return true end
  end
  
  return false
end

local function IsSliderBackdrop(backdrop)
  if not backdrop then return false end
  return backdrop.edgeSize == 8 and backdrop.tileSize == 8
end

-----------------------------------------------------------------------------
-- Frame Processing
-----------------------------------------------------------------------------
local function ProcessBackdropColor(frame)
  if not frame or not frame.SetBackdropColor or not frame.GetBackdrop then return end
  
  local backdrop = frame:GetBackdrop()
  if not backdrop then return end
  
  local r, g, b, a = frame:GetBackdropColor()
  if not a or a <= 0 then return end
  
  frame:SetBackdropColor(DARK_COLOR.r, DARK_COLOR.g, DARK_COLOR.b, DARK_COLOR.a)
end

local function ProcessBackdropBorder(frame)
  if not frame or not frame.SetBackdropBorderColor then return end
  frame:SetBackdropBorderColor(DARK_COLOR.r, DARK_COLOR.g, DARK_COLOR.b, DARK_COLOR.a)
end

local function ProcessSliderBackdrop(frame)
  if not frame or not frame.SetBackdrop or not frame.GetBackdrop then return end
  if not AutoLFM.Core or not AutoLFM.Core.Constants then return end
  
  local backdrop = frame:GetBackdrop()
  if not backdrop or not IsSliderBackdrop(backdrop) then return end
  
  local texturePath = AutoLFM.Core.Constants.TEXTURE_PATH
  if not texturePath then return end
  
  local newBackdrop = {
    bgFile = texturePath .. SLIDER_TEXTURE_LIGHT,
    edgeFile = backdrop.edgeFile,
    tile = true,
    tileSize = 8,
    edgeSize = 8,
    insets = {left = 3, right = 3, top = 6, bottom = 6}
  }
  
  frame:SetBackdrop(newBackdrop)
  frame:SetBackdropColor(DARK_COLOR.r, DARK_COLOR.g, DARK_COLOR.b, DARK_COLOR.a)
end

local function ProcessRegions(frame)
  if not frame or not frame.GetRegions then return end
  
  for _, region in pairs({frame:GetRegions()}) do
    if region and region.SetVertexColor and region:GetObjectType() == "Texture" then
      local skipRegion = false
      
      if region.GetBlendMode and region:GetBlendMode() == "ADD" then
        skipRegion = true
      elseif IsBlacklisted(region) then
        skipRegion = true
      end
      
      if not skipRegion then
        region:SetVertexColor(DARK_COLOR.r, DARK_COLOR.g, DARK_COLOR.b, DARK_COLOR.a)
      end
    end
  end
end

local function ProcessRolesBackground(frame)
  if not frame then return end
end

local function ProcessChildren(frame, processFunc)
  if not frame or not frame.GetChildren then return end
  
  for _, child in pairs({frame:GetChildren()}) do
    if child then
      processFunc(child)
    end
  end
end

-----------------------------------------------------------------------------
-- Core Darkening
-----------------------------------------------------------------------------
function AutoLFM.UI.DarkUI.DarkenFrame(frame)
  if not enabled then return end
  if not frame then return end
  
  ProcessRolesBackground(frame)
  ProcessChildren(frame, AutoLFM.UI.DarkUI.DarkenFrame)
  
  if frame.GetRegions then
    ProcessBackdropBorder(frame)
    ProcessBackdropColor(frame)
    ProcessSliderBackdrop(frame)
    ProcessRegions(frame)
  end
end

-----------------------------------------------------------------------------
-- Theme Management
-----------------------------------------------------------------------------
local function ApplyDarkTheme()
  if not enabled then return end
  
  for _, frame in pairs(darkenedFrames) do
    if frame then
      AutoLFM.UI.DarkUI.DarkenFrame(frame)
    end
  end
end

local function ShowReloadMessage()
  if not AutoLFM or not AutoLFM.Core or not AutoLFM.Core.Utils then return end
  if not AutoLFM.Color then return end
  
  local msg = AutoLFM.Color("You must ", "orange") .. AutoLFM.Color("/reload", "gold") .. AutoLFM.Color(" to apply changes.", "orange")
  AutoLFM.Core.Utils.PrintSuccess(msg)
end

-----------------------------------------------------------------------------
-- Public API
-----------------------------------------------------------------------------
function AutoLFM.UI.DarkUI.RegisterFrame(frame)
  if not frame then return end
  table.insert(darkenedFrames, frame)
  
  if enabled then
    AutoLFM.UI.DarkUI.DarkenFrame(frame)
  end
end

function AutoLFM.UI.DarkUI.RefreshFrame(frame)
  if not enabled then return end
  if not frame then return end
  AutoLFM.UI.DarkUI.DarkenFrame(frame)
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

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function AutoLFM.UI.DarkUI.Init()
  if AutoLFM and AutoLFM.Core and AutoLFM.Core.Settings then
    enabled = AutoLFM.Core.Settings.LoadDarkMode()
    if enabled then
      ApplyDarkTheme()
    end
  end
end
