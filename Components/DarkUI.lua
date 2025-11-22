--=============================================================================
-- AutoLFM: Dark UI Theme
--   Provides dark theme functionality for AutoLFM UI elements
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Components = AutoLFM.Components or {}
AutoLFM.Components.DarkUI = {}

-----------------------------------------------------------------------------
-- Private Constants
-----------------------------------------------------------------------------
local DARK_COLOR = {r = 0.3, g = 0.3, b = 0.3, a = 0.9}

local DARKUI_BLACKLIST = {
  ["Eye\\"] = true,
  ["Preview"] = true,
  ["RolesTank"] = true,
  ["RolesHeal"] = true,
  ["RolesDps"] = true,
  ["ClearAll"] = true,
  ["Presets"] = true,
  ["AddPreset"] = true,
  ["AutoInvite"] = true,
  ["Settings"] = true,
  ["Minimap"] = true,
  ["TooltipBackground"] = true,
  ["Button"] = true,
  ["Check"] = true,
  ["Radio"] = true,
  ["Icon"] = true,
  ["Slider"] = true
}

local DARKUI_WHITELIST = {
  ["MainFrame"] = true,
  ["MinimapBorder"] = true,
  ["BottomTabActive"] = true
}

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local enabled = false
local darkenedFrames = {}

-----------------------------------------------------------------------------
-- Texture Filtering
-----------------------------------------------------------------------------

--- Checks if a texture path is whitelisted for dark theme application
--- @param texturePath string - Path to the texture file
--- @return boolean - True if texture matches whitelist patterns
local function isWhitelisted(texturePath)
  if not texturePath then return false end

  for pattern in pairs(DARKUI_WHITELIST) do
      if string.find(texturePath, pattern) then return true end
  end
  return false
end

--- Checks if a frame is blacklisted from dark theme application
--- @param frame frame - The frame to check
--- @return boolean - True if frame name matches blacklist patterns
local function isFrameBlacklisted(frame)
  if not frame then return true end

  local name = frame:GetName()
  if not name then return false end

  for pattern in pairs(DARKUI_BLACKLIST) do
      if string.find(name, pattern) then return true end
  end

  return false
end

--- Checks if a texture is blacklisted from dark theme application
--- @param texture texture - The texture object to check
--- @return boolean - True if texture name or path matches blacklist patterns
local function isBlacklisted(texture)
  if not texture then return true end

  local name = texture:GetName()
  local texturePath = texture:GetTexture()
  if not texturePath then return true end
  if isWhitelisted(texturePath) then return false end

  if name then
      for pattern in pairs(DARKUI_BLACKLIST) do
          if string.find(name, pattern) then return true end
      end
  end

  for pattern in pairs(DARKUI_BLACKLIST) do
      if string.find(texturePath, pattern) then return true end
  end

  return false
end

-----------------------------------------------------------------------------
-- Frame Processing
-----------------------------------------------------------------------------

--- Applies dark color to frame backdrop if conditions are met
--- @param frame frame - The frame to process
local function processBackdropColor(frame)
  if not frame then return end
  if isFrameBlacklisted(frame) then return end
  if not frame.SetBackdropColor then return end
  if not frame.GetBackdrop then return end

  local backdrop = frame:GetBackdrop()
  if not backdrop then return end

  local r, g, b, a = frame:GetBackdropColor()
  if not a or a <= 0 then return end

  frame:SetBackdropColor(DARK_COLOR.r, DARK_COLOR.g, DARK_COLOR.b, DARK_COLOR.a)
end

--- Applies dark color to frame backdrop border if conditions are met
--- @param frame frame - The frame to process
local function processBackdropBorder(frame)
  if not frame then return end
  if isFrameBlacklisted(frame) then return end
  if not frame.SetBackdropBorderColor then return end

  frame:SetBackdropBorderColor(DARK_COLOR.r, DARK_COLOR.g, DARK_COLOR.b, DARK_COLOR.a)
end

--- Applies dark color to all texture regions in a frame
--- @param frame frame - The frame whose regions to process
local function processRegions(frame)
  if not frame then return end
  if not frame.GetRegions then return end

  for _, region in pairs({frame:GetRegions()}) do
      if region and region.SetVertexColor and region:GetObjectType() == "Texture" then
          local skipRegion = false

          if region.GetBlendMode and region:GetBlendMode() == "ADD" then
              skipRegion = true
          elseif isBlacklisted(region) then
              skipRegion = true
          end

          if not skipRegion then
              region:SetVertexColor(DARK_COLOR.r, DARK_COLOR.g, DARK_COLOR.b, DARK_COLOR.a)
          end
      end
  end
end

--- Recursively processes all child frames using the provided function
--- @param frame frame - The parent frame
--- @param processFunc function - Function to call on each child frame
local function processChildren(frame, processFunc)
  if not frame then return end
  if not frame.GetChildren then return end

  for _, child in pairs({frame:GetChildren()}) do
      if child then
          processFunc(child)
      end
  end
end

-----------------------------------------------------------------------------
-- Core Darkening
--   Recursively applies dark theme to frame and children
-----------------------------------------------------------------------------

--- Recursively darkens a frame and all its children
--- Applies dark theme to backdrop, borders, and text regions
--- @param frame frame - The frame to darken
function AutoLFM.Components.DarkUI.DarkenFrame(frame)
  if not enabled then return end
  if not frame then return end

  processChildren(frame, AutoLFM.Components.DarkUI.DarkenFrame)

  if frame.GetRegions then
      processBackdropBorder(frame)
      processBackdropColor(frame)
      processRegions(frame)
  end
end

-----------------------------------------------------------------------------
-- Theme Management
-----------------------------------------------------------------------------

--- Applies dark theme to all registered frames
local function applyDarkTheme()
  if not enabled then return end

  for _, frame in pairs(darkenedFrames) do
      if frame then
          AutoLFM.Components.DarkUI.DarkenFrame(frame)
      end
  end
end

-----------------------------------------------------------------------------
-- Public API
--   Functions for managing dark theme state
-----------------------------------------------------------------------------

--- Registers a frame for dark theme application
--- Frame will be darkened immediately if dark mode is enabled
--- @param frame frame - The frame to register for dark theme
function AutoLFM.Components.DarkUI.RegisterFrame(frame)
  if not frame then return end

  table.insert(darkenedFrames, frame)

  if enabled then
      AutoLFM.Components.DarkUI.DarkenFrame(frame)
  end
end

--- Returns whether dark mode is currently enabled
--- @return boolean - True if dark mode is active
function AutoLFM.Components.DarkUI.IsEnabled()
  return enabled
end

-----------------------------------------------------------------------------
-- Initialization
--   Loads dark mode setting and applies theme to registered frames
-----------------------------------------------------------------------------

--- Initializes dark mode from persistent settings
--- Applies dark theme to all registered frames if enabled
function AutoLFM.Components.DarkUI.Init()
  if not AutoLFM.Core.Persistent then return end

  enabled = AutoLFM.Core.Persistent.GetDarkMode()
  if enabled then
      applyDarkTheme()
  end
end

-----------------------------------------------------------------------------
-- Auto-register initialization
-----------------------------------------------------------------------------
AutoLFM.Core.SafeRegisterInit("Components.DarkUI", function()
  AutoLFM.Components.DarkUI.Init()
end, {
  id = "I08",
  dependencies = {"Core.Persistent"}
})
