--=============================================================================
-- AutoLFM: MainFrame Logic
--   Main window state management, tab logic and content switching
--=============================================================================

AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.MainFrame = {}

--=============================================================================
-- PRIVATE STATE
--=============================================================================

local currentBottomTab = 1  -- 1=Dungeons, 2=Raids, 3=Quests, 4=Messaging
local currentSideTab = nil  -- nil or 2=Presets, 4=AutoInvite, 5=Settings

local BOTTOM_TABS = {
  "Dungeons",
  "Raids",
  "Quests",
  "Messaging"
}

local SIDE_TABS = {
  [2] = "Presets",
  [4] = "AutoInvite",
  [5] = "Settings"
}

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Toggles the main frame visibility (show/hide)
--- Uses WoW UI panel system for proper strata management
function AutoLFM.Logic.MainFrame.Toggle()
  local frame = getglobal("AutoLFM_MainFrame")
  if not frame then
    return
  end

  if frame:IsVisible() then
    AutoLFM.Core.Utils.LogAction("Hide MainFrame")
    HideUIPanel(frame)
  else
    AutoLFM.Core.Utils.LogAction("Show MainFrame")
    ShowUIPanel(frame)
  end
end

--=============================================================================
-- TAB MANAGEMENT
--   Bottom tabs: 1=Dungeons, 2=Raids, 3=Quests, 4=Messaging
--   Side tabs: 2=Presets, 4=AutoInvite, 5=Settings
--=============================================================================

--- Selects a bottom tab and switches to its content
--- @param tabIndex number - Tab index (1-4: Dungeons, Raids, Quests, Messaging)
--- @param tabName string - Optional display name for logging
function AutoLFM.Logic.MainFrame.SelectBottomTab(tabIndex, tabName)
  if tabIndex < 1 or tabIndex > 4 then
    return
  end

  currentBottomTab = tabIndex
  currentSideTab = nil

  local displayName = tabName or BOTTOM_TABS[tabIndex]
  AutoLFM.Core.Utils.LogInfo("Show " .. displayName .. " content")

  AutoLFM.Logic.MainFrame.UpdateTabVisuals()
  AutoLFM.Logic.MainFrame.UpdateContent()
end

--- Selects a side tab and switches to its content
--- @param tabIndex number - Tab index (2=Presets, 4=AutoInvite, 5=Settings)
--- @param tabName string - Optional display name for logging
function AutoLFM.Logic.MainFrame.SelectSideTab(tabIndex, tabName)
  if not SIDE_TABS[tabIndex] then
    return
  end

  currentSideTab = tabIndex

  local displayName = tabName or SIDE_TABS[tabIndex]
  AutoLFM.Core.Utils.LogInfo("Show " .. displayName .. " content")

  AutoLFM.Logic.MainFrame.UpdateTabVisuals()
  AutoLFM.Logic.MainFrame.UpdateContent()
end

--- Determines if a bottom tab should show hover highlight
--- Bottom tabs show highlight when not selected OR when a side tab is active
--- @param tabIndex number - The bottom tab index to check
--- @return boolean - True if highlight should be shown
function AutoLFM.Logic.MainFrame.ShouldShowTabHighlight(tabIndex)
  return tabIndex ~= currentBottomTab or currentSideTab
end

--- Returns the currently selected bottom tab index
--- @return number - Current bottom tab (1-4)
function AutoLFM.Logic.MainFrame.GetCurrentBottomTab()
  return currentBottomTab
end

--- Returns the currently selected side tab index or nil
--- @return number|nil - Current side tab (2, 4, 5) or nil if no side tab active
function AutoLFM.Logic.MainFrame.GetCurrentSideTab()
  return currentSideTab
end

--- Updates tab visual states (delegates to UI layer)
--- Refreshes tab colors and highlights based on current selection
function AutoLFM.Logic.MainFrame.UpdateTabVisuals()
  -- Delegate to UI layer
  if AutoLFM.UI and AutoLFM.UI.MainFrame and AutoLFM.UI.MainFrame.UpdateTabVisuals then
    AutoLFM.UI.MainFrame.UpdateTabVisuals(currentBottomTab, currentSideTab)
  end
end

--- Shows/hides content frames based on currently active tab
--- Hides all content frames, then shows the active one
function AutoLFM.Logic.MainFrame.UpdateContent()
  local activeContent
  if currentSideTab and SIDE_TABS[currentSideTab] then
    activeContent = SIDE_TABS[currentSideTab]
  else
    activeContent = BOTTOM_TABS[currentBottomTab]
  end

  for _, contentName in ipairs(BOTTOM_TABS) do
    local frame = getglobal("AutoLFM_Content_" .. contentName)
    if frame then
      frame:Hide()
    end
  end

  for _, contentName in pairs(SIDE_TABS) do
    local frame = getglobal("AutoLFM_Content_" .. contentName)
    if frame then
      frame:Hide()
    end
  end

  local activeFrame = getglobal("AutoLFM_Content_" .. activeContent)
  if activeFrame then
    activeFrame:Show()
  else
    AutoLFM.Core.Utils.LogWarning("Content frame not found: " .. activeContent)
  end
end

--=============================================================================
-- CONTENT FRAME MANAGEMENT
--   Content frames are defined in XML, logic manages their visibility
--=============================================================================

--- Initializes content frames and applies default panel from settings
--- Content frames are defined in XML, this just sets up the initial state
function AutoLFM.Logic.MainFrame.InitializeContentFrames()
  -- All content frames are now defined directly in XML with parent="AutoLFM_MainFrame_ContentContainer"
  -- No need to create them dynamically anymore

  -- Apply default panel from settings
  AutoLFM.Logic.MainFrame.ApplyDefaultPanel()

  -- Rows will be created by OnShow handlers when each content frame is first shown
end

--- Applies the default panel setting from persistent storage
--- Opens the configured panel (dungeons, raids, quests, messaging, or presets)
function AutoLFM.Logic.MainFrame.ApplyDefaultPanel()
  local defaultPanel = AutoLFM.Core.Persistent.GetDefaultPanel()
  if not defaultPanel then
    defaultPanel = "dungeons"
  end

  -- Map panel names to tab indices/types
  local panelMap = {
    dungeons = {type = "bottom", index = 1},
    raids = {type = "bottom", index = 2},
    quests = {type = "bottom", index = 3},
    messaging = {type = "bottom", index = 4},
    presets = {type = "side", index = 2}
  }

  local panel = panelMap[defaultPanel]
  if panel then
    if panel.type == "bottom" then
      AutoLFM.Logic.MainFrame.SelectBottomTab(panel.index, defaultPanel)
    elseif panel.type == "side" then
      AutoLFM.Logic.MainFrame.SelectSideTab(panel.index, defaultPanel)
    end
  else
    -- Fallback to dungeons
    AutoLFM.Logic.MainFrame.SelectBottomTab(1, "dungeons")
  end
end

--=============================================================================
-- INITIALIZATION
--=============================================================================

AutoLFM.Core.SafeRegisterInit("MainFrame", function()
  AutoLFM.Core.Maestro.RegisterCommand("MainFrame.Toggle", AutoLFM.Logic.MainFrame.Toggle, { id = "C01" })

  -- Subscribe to message state changes to update the preview
  AutoLFM.Core.Maestro.SubscribeState("Message.ToBroadcast", function(newMessage, oldMessage)
    if AutoLFM.UI.MainFrame and AutoLFM.UI.MainFrame.UpdateMessagePreview then
      AutoLFM.UI.MainFrame.UpdateMessagePreview(newMessage)
    end
  end)
end, { id = "I11" })
