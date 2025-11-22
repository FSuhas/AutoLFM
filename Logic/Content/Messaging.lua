--=============================================================================
-- AutoLFM: Messaging Logic
--   Message configuration and link integration
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.Content = AutoLFM.Logic.Content or {}
AutoLFM.Logic.Content.Messaging = {}

--=============================================================================
-- PRIVATE STATE
--=============================================================================
local Original_ContainerFrameItemButton_OnClick = nil
local Original_ChatFrame_OnHyperlinkShow = nil

--=============================================================================
-- LINK INTEGRATION
--=============================================================================
-----------------------------------------------------------------------------
-- Get the custom message editbox
-----------------------------------------------------------------------------

--- Retrieves the custom message editbox from the Messaging UI
--- @return frame|nil - The editbox frame, or nil if UI not initialized
local function getCustomMessageEditBox()
  if AutoLFM.UI and AutoLFM.UI.Content and AutoLFM.UI.Content.Messaging then
    return AutoLFM.UI.Content.Messaging.GetCustomMessageEditBox and
           AutoLFM.UI.Content.Messaging.GetCustomMessageEditBox()
  end
  return nil
end

-----------------------------------------------------------------------------
-- Check if AutoLFM is visible and ready for links
-----------------------------------------------------------------------------

--- Checks if AutoLFM main window is visible and ready to receive links
--- @return boolean - True if main window is visible
local function isAutoLFMReady()
  return AutoLFM_MainFrame and AutoLFM_MainFrame:IsVisible()
end

-----------------------------------------------------------------------------
-- Insert link into editbox
-----------------------------------------------------------------------------

--- Inserts an item/quest link into the custom message editbox
--- @param link string - The hyperlink text to insert (e.g., item link, quest link)
--- @return boolean - True if link was successfully inserted, false otherwise
local function insertLinkIntoEditBox(link)
  if not link then
    if AutoLFM.Core and AutoLFM.Core.Utils then
      AutoLFM.Core.Utils.LogWarning("InsertLink: no link provided")
    end
    return false
  end

  local editBox = getCustomMessageEditBox()
  if not editBox then
    if AutoLFM.Core and AutoLFM.Core.Utils then
      AutoLFM.Core.Utils.LogWarning("InsertLink: editbox not found")
    end
    return false
  end

  local currentText = editBox:GetText() or ""
  local newText = (currentText == "" and link) or (currentText .. " " .. link)

  editBox:SetText(newText)
  editBox:SetFocus()
  editBox:HighlightText(0, 0)

  if AutoLFM.Core and AutoLFM.Core.Utils then
    AutoLFM.Core.Utils.LogAction("Link inserted: " .. link)
  end

  return true
end

-----------------------------------------------------------------------------
-- Bag Item Clicks
-----------------------------------------------------------------------------

--- Hooks bag item button clicks to enable Shift+Click link insertion
--- Overrides ContainerFrameItemButton_OnClick to intercept Shift+Click
local function hookBagClicks()
  if not ContainerFrameItemButton_OnClick then return end
  Original_ContainerFrameItemButton_OnClick = ContainerFrameItemButton_OnClick

  ContainerFrameItemButton_OnClick = function(button, ignoreModifiers)
    local success, err = pcall(function()
      if IsShiftKeyDown() and isAutoLFMReady() then
        local bag = this:GetParent():GetID()
        local slot = this:GetID()
        local itemLink = GetContainerItemLink(bag, slot)

        if itemLink and insertLinkIntoEditBox(itemLink) then
          return
        end
      end

      if Original_ContainerFrameItemButton_OnClick then
        Original_ContainerFrameItemButton_OnClick(button, ignoreModifiers)
      end
    end)

    if not success and Original_ContainerFrameItemButton_OnClick then
      Original_ContainerFrameItemButton_OnClick(button, ignoreModifiers)
    end
  end
end

-----------------------------------------------------------------------------
-- Create Quest Link (WoW 1.12 format)
-----------------------------------------------------------------------------

--- Creates a manually formatted quest link (WoW 1.12 does not have native quest links)
--- @param questID number - Quest ID (not used in display, for future compatibility)
--- @param level number - Quest level
--- @param title string - Quest name
--- @return string|nil - Formatted quest link, or nil if title missing
local function createQuestLink(questID, level, title)
  if not questID or not title then return nil end
  level = level or 0
  questID = questID or 0
  return string.format("|cff808080[Quest]|r |cffffd000[%d %s]|r", level, title)
end

-----------------------------------------------------------------------------
-- Chat Hyperlinks
-----------------------------------------------------------------------------

--- Hooks chat hyperlink clicks to enable Shift+Click link insertion and right-click player menus
--- Overrides ChatFrame_OnHyperlinkShow to intercept Shift+Click and right-click events
local function hookChatLinks()
  if not ChatFrame_OnHyperlinkShow then return end
  Original_ChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow

  ChatFrame_OnHyperlinkShow = function(link, text, button)
    -- Try our custom handling first
    local handled = false

    -- Right click on player → show menu
    local _, _, linkType, playerName = string.find(link or "", "^(%a+):([^:]+)")
    if linkType == "player" and playerName and button == "RightButton" then
      playerName = gsub(playerName, "-.*", "")
      if HideDropDownMenu then HideDropDownMenu(1) end
      if ChatFrameDropDown_Show then
        ChatFrameDropDown_Show(nil, playerName)
        return -- Handled, don't call original
      end
    end

    -- Shift+Click on item/quest → insert into editbox
    if IsShiftKeyDown() and isAutoLFMReady() then
      -- Check if it's an item or quest link
      local isItemOrQuest = link and (string.find(link, "^item:") or string.find(link, "^quest:"))

      if isItemOrQuest and text then
        if AutoLFM.Core and AutoLFM.Core.Utils then
          AutoLFM.Core.Utils.LogInfo("Attempting to insert link: " .. tostring(text))
        end

        if insertLinkIntoEditBox(text) then
          -- Successfully inserted, don't call original
          return
        end
      end
    end

    -- Call original for all other cases
    if Original_ChatFrame_OnHyperlinkShow then
      Original_ChatFrame_OnHyperlinkShow(link, text, button)
    end
  end
end

--=============================================================================
-- CHANNEL MANAGEMENT
--=============================================================================
-----------------------------------------------------------------------------
-- Join Channel if not already joined
-----------------------------------------------------------------------------
--- Joins a chat channel if the player is not already in it
--- @param channelName string - The name of the channel to join (e.g., "LookingForGroup")
--- @return boolean - True if in channel (already or newly joined), false if invalid channel name
function AutoLFM.Logic.Content.Messaging.JoinChannel(channelName)
  if not channelName or channelName == "" then
    if AutoLFM.Core and AutoLFM.Core.Utils then
      AutoLFM.Core.Utils.LogWarning("JoinChannel: no channel name provided")
    end
    return false
  end

  -- GetChannelName returns channelID (> 0) if in channel, 0 if not
  local channelID = GetChannelName(channelName)

  if channelID > 0 then
    if AutoLFM.Core and AutoLFM.Core.Utils then
      AutoLFM.Core.Utils.LogInfo("Already in channel: " .. channelName .. " (ID: " .. channelID .. ")")
    end
    return true
  end

  -- Join the channel and show it in the selected chat frame
  local chatFrame = SELECTED_CHAT_FRAME or ChatFrame1
  local frameId = chatFrame:GetID()
  JoinChannelByName(channelName, nil, frameId)

  if AutoLFM.Core and AutoLFM.Core.Utils then
    AutoLFM.Core.Utils.LogAction("Joined channel: " .. channelName)
    AutoLFM.Core.Utils.Print("Joined channel: " .. channelName)
  end

  return true
end

--=============================================================================
-- CHANNEL SELECTION MANAGEMENT
--=============================================================================

-----------------------------------------------------------------------------
-- Toggle Channel Selection
-----------------------------------------------------------------------------
--- Toggles a channel in the selection and joins it if selected
--- @param channelName string - The name of the channel to toggle
function AutoLFM.Logic.Content.Messaging.ToggleChannel(channelName)
  if not channelName or channelName == "" then
    if AutoLFM.Core and AutoLFM.Core.Utils then
      AutoLFM.Core.Utils.LogWarning("ToggleChannel: no channel name provided")
    end
    return
  end

  -- Get current channels from Maestro State
  local channelsList = AutoLFM.Core.Maestro.GetState("Channels.ActiveChannels") or {}
  
  -- Check if channel is already selected
  local isSelected = false
  local newChannelsList = {}
  
  for i = 1, table.getn(channelsList) do
    if channelsList[i] == channelName then
      isSelected = true
      -- Don't add to new list (remove it)
      if AutoLFM.Core and AutoLFM.Core.Utils then
        AutoLFM.Core.Utils.LogAction("Channel deselected: " .. channelName)
      end
    else
      table.insert(newChannelsList, channelsList[i])
    end
  end
  
  -- If not selected, add it
  if not isSelected then
    table.insert(newChannelsList, channelName)
    -- Join the channel
    AutoLFM.Logic.Content.Messaging.JoinChannel(channelName)
  end

  -- Update state
  AutoLFM.Core.Maestro.SetState("Channels.ActiveChannels", newChannelsList)

  -- Save to persistent storage
  if AutoLFM.Core and AutoLFM.Core.Persistent then
    AutoLFM.Core.Persistent.SetSelectedChannels(channelsList)
  end

  -- Dispatch event
  AutoLFM.Core.Maestro.Dispatch("Channels.Changed")
end

-----------------------------------------------------------------------------
-- PUBLIC API - REMOVED
-----------------------------------------------------------------------------
-- All public getters removed - use Maestro States directly:
--   GetState("Channels.ActiveChannels") → S11
-- To check if channel selected: iterate State and check presence

--=============================================================================
-- PUBLIC API
--=============================================================================
-----------------------------------------------------------------------------
-- Initialize Link Integration
-----------------------------------------------------------------------------
--- Initializes link integration for item and quest links
--- Hooks bag item clicks and chat hyperlinks to enable Shift+Click link insertion
--- into the custom message editbox in the Messaging UI
function AutoLFM.Logic.Content.Messaging.InitLinkIntegration()
  local success, err = pcall(function()
    hookBagClicks()
    hookChatLinks()
  end)
  if not success and AutoLFM.Core and AutoLFM.Core.Utils then
    AutoLFM.Core.Utils.PrintError("Failed to initialize link integration: " .. tostring(err))
  end
end

--=============================================================================
-- MAESTRO DECLARATIONS
--=============================================================================
--- Command: Toggle channel selection
AutoLFM.Core.Maestro.RegisterCommand("Channels.ToggleChannel", function(channelName)
  AutoLFM.Logic.Content.Messaging.ToggleChannel(channelName)
end, { id = "C23" })

--- Event: Channels selection changed
AutoLFM.Core.Maestro.RegisterEvent("Channels.Changed", { id = "E05" })

--- State: Active channels list
AutoLFM.Core.SafeRegisterState("Channels.ActiveChannels", {}, { id = "S15" })

-----------------------------------------------------------------------------
-- Load Saved Channels
-----------------------------------------------------------------------------
--- Loads selected channels from persistent storage and restores selection state
local function loadSavedChannels()
  if not AutoLFM.Core or not AutoLFM.Core.Persistent then return end

  local savedChannels = AutoLFM.Core.Persistent.GetSelectedChannels()
  if not savedChannels or type(savedChannels) ~= "table" then return end

  -- Join all saved channels
  for i = 1, table.getn(savedChannels) do
    local channelName = savedChannels[i]
    if channelName and channelName ~= "" then
      -- Join the channel
      AutoLFM.Logic.Content.Messaging.JoinChannel(channelName)
    end
  end

  -- Update Maestro state with saved channels
  AutoLFM.Core.Maestro.SetState("Channels.ActiveChannels", savedChannels)
end

-----------------------------------------------------------------------------
-- Auto-register initialization
-----------------------------------------------------------------------------
AutoLFM.Core.SafeRegisterInit("Logic.Content.Messaging", function()
  AutoLFM.Logic.Content.Messaging.InitLinkIntegration()
  loadSavedChannels()
end, { id = "I16", dependencies = { "Core.Persistent" } })
