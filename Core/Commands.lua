--=============================================================================
-- AutoLFM: Slash Commands
--   Command-line interface for the addon
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Core = AutoLFM.Core or {}
AutoLFM.Core.Commands = {}

--=============================================================================
-- TEST MODE FUNCTIONS
--=============================================================================

--- Enables test mode and simulates group size changes
local function enableTestMode()
  AutoLFM.Core.Events.EnableTestMode()
  AutoLFM.Core.Utils.PrintSuccess("Test mode enabled! Use /lfm add and /lfm remove to simulate players")
  AutoLFM.Core.Utils.Print("Current simulated group size: " .. AutoLFM.Core.Events.GetGroupSize())
end

--- Disables test mode and restores original functions
local function disableTestMode()
  AutoLFM.Core.Events.DisableTestMode()
  AutoLFM.Core.Utils.PrintSuccess("Test mode disabled")
end

--- Adds a simulated player to the group
local function addSimulatedPlayer()
  if not AutoLFM.Core.Events.IsTestModeEnabled() then
    AutoLFM.Core.Utils.PrintError("Test mode not enabled. Use /lfm testmode first")
    return
  end

  local currentSize = AutoLFM.Core.Events.GetSimulatedGroupSize()
  if currentSize >= 40 then
    AutoLFM.Core.Utils.PrintError("Cannot add more players (max 40)")
    return
  end

  local newSize = currentSize + 1
  AutoLFM.Core.Events.SetSimulatedGroupSize(newSize)

  -- Update Maestro states
  local groupType = AutoLFM.Core.Utils.GetGroupTypeFromSize(newSize)

  AutoLFM.Core.Maestro.SetState("Group.Size", newSize)
  AutoLFM.Core.Maestro.SetState("Group.Type", groupType)

  -- Dispatch group size changed event
  AutoLFM.Core.Maestro.Dispatch("Group.SizeChanged", { size = newSize })

  AutoLFM.Core.Utils.Print("Added player. Group size: " .. newSize .. " (" .. groupType .. ")")
end

--- Removes a simulated player from the group
local function removeSimulatedPlayer()
  if not AutoLFM.Core.Events.IsTestModeEnabled() then
    AutoLFM.Core.Utils.PrintError("Test mode not enabled. Use /lfm testmode first")
    return
  end

  local currentSize = AutoLFM.Core.Events.GetSimulatedGroupSize()
  if currentSize <= 1 then
    AutoLFM.Core.Utils.PrintError("Cannot remove more players (min 1)")
    return
  end

  local newSize = currentSize - 1
  AutoLFM.Core.Events.SetSimulatedGroupSize(newSize)

  -- Update Maestro states
  local groupType = AutoLFM.Core.Utils.GetGroupTypeFromSize(newSize)

  AutoLFM.Core.Maestro.SetState("Group.Size", newSize)
  AutoLFM.Core.Maestro.SetState("Group.Type", groupType)

  -- Dispatch group size changed event
  AutoLFM.Core.Maestro.Dispatch("Group.SizeChanged", { size = newSize })

  AutoLFM.Core.Utils.Print("Removed player. Group size: " .. newSize .. " (" .. groupType .. ")")
end

--- Sets the simulated group size directly
--- @param size number - Target group size (1-40)
local function setSimulatedGroupSize(size)
  if not AutoLFM.Core.Events.IsTestModeEnabled() then
    AutoLFM.Core.Utils.PrintError("Test mode not enabled. Use /lfm testmode first")
    return
  end

  size = tonumber(size)
  if not size or size < 1 or size > 40 then
    AutoLFM.Core.Utils.PrintError("Invalid size. Must be between 1 and 40")
    return
  end

  AutoLFM.Core.Events.SetSimulatedGroupSize(size)

  -- Update Maestro states
  local groupType = AutoLFM.Core.Utils.GetGroupTypeFromSize(size)

  AutoLFM.Core.Maestro.SetState("Group.Size", size)
  AutoLFM.Core.Maestro.SetState("Group.Type", groupType)

  -- Dispatch group size changed event
  AutoLFM.Core.Maestro.Dispatch("Group.SizeChanged", { size = size })

  AutoLFM.Core.Utils.Print("Set group size: " .. size .. " (" .. groupType .. ")")
end

--=============================================================================
-- SLASH COMMAND HANDLER
--=============================================================================

--- Handles slash command input and routes to appropriate actions
--- @param msg string - Command arguments (empty for toggle, "debug" for debug window, "test" for API test)
local function handleSlashCommand(msg)
  -- Ensure msg is a string
  msg = msg or ""

  -- Parse command and arguments using string.find (Lua 5.0 compatible)
  local _, _, cmd, arg = string.find(msg, "^(%S*)%s*(.-)$")
  cmd = string.lower(cmd or "")

  if cmd == "" then
      -- Toggle main window
      AutoLFM.Core.Maestro.Dispatch("MainFrame.Toggle")

  elseif cmd == "debug" then
      -- Toggle debug window
      AutoLFM.Core.Maestro.Dispatch("Debug.Toggle")

  elseif cmd == "testmode" then
      -- Toggle test mode
      if AutoLFM.Core.Events.IsTestModeEnabled() then
        disableTestMode()
      else
        enableTestMode()
      end

  elseif cmd == "add" or cmd == "addplayer" then
      -- Add simulated player
      addSimulatedPlayer()

  elseif cmd == "remove" or cmd == "removeplayer" then
      -- Remove simulated player
      removeSimulatedPlayer()

  elseif cmd == "setsize" then
      -- Set group size directly
      if arg and arg ~= "" then
        setSimulatedGroupSize(arg)
      else
        AutoLFM.Core.Utils.PrintError("Usage: /lfm setsize <1-40>")
      end

  elseif cmd == "test" then
      -- Test WoW API functions
      DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00=== WoW API Test ===|r")

      -- Test GetAddOnInfo
      local numAddOns = GetNumAddOns()
      DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00Total addons installed: " .. numAddOns .. "|r")

      -- List first 5 addons
      DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00First 5 addons:|r")
      for i = 1, math.min(5, numAddOns) do
          local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
          local status = enabled and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"
          DEFAULT_CHAT_FRAME:AddMessage("  " .. i .. ". " .. name .. " - " .. status)
      end

      -- Test RandomRoll
      local roll = math.random(1, 100)
      DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00Random roll (1-100): |r" .. roll)

      DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00API test complete!|r")

  else
      -- Show help in chat
      AutoLFM.Core.Utils.PrintTitle("=== AutoLFM Commands ===")
      AutoLFM.Core.Utils.Print("  /lfm - Toggle main window")
      AutoLFM.Core.Utils.Print("  /lfm debug - Toggle debug window")
      AutoLFM.Core.Utils.Print("  /lfm test - Test WoW API functions")
      AutoLFM.Core.Utils.Print("")
      AutoLFM.Core.Utils.PrintTitle("=== Test Mode Commands ===")
      AutoLFM.Core.Utils.Print("  /lfm testmode - Enable/disable test mode")
      AutoLFM.Core.Utils.Print("  /lfm add - Add a simulated player")
      AutoLFM.Core.Utils.Print("  /lfm remove - Remove a simulated player")
      AutoLFM.Core.Utils.Print("  /lfm setsize <1-40> - Set group size directly")
  end
end

--=============================================================================
-- REGISTRATION
--=============================================================================

SLASH_AUTOLFM1 = "/lfm"
SlashCmdList["AUTOLFM"] = handleSlashCommand
