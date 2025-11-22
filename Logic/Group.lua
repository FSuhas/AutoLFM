--=============================================================================
-- AutoLFM: Group Management
--   Centralized group size, type, and leadership tracking
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.Group = {}

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Gets current group size (1 for solo, 2-5 for party, 6-40 for raid)
--- Reads from Maestro State instead of recalculating
--- @return number - Current group size
function AutoLFM.Logic.Group.GetSize()
  return AutoLFM.Core.Maestro.GetState("Group.Size") or 1
end

--- Gets current group type
--- Reads from Maestro State instead of recalculating
--- @return string - "solo", "party", or "raid"
function AutoLFM.Logic.Group.GetType()
  return AutoLFM.Core.Maestro.GetState("Group.Type") or "solo"
end

--- Checks if player is party/raid leader or solo
--- @return boolean - True if player can invite
function AutoLFM.Logic.Group.CanInvite()
  if not UnitInParty("player") then return true end
  return UnitIsPartyLeader("player")
end

--- Converts party to raid if conditions are met
--- @param targetSize number - Target group size
--- @return boolean - True if conversion successful or already in raid
function AutoLFM.Logic.Group.ConvertToRaidIfNeeded(targetSize)
  local groupType = AutoLFM.Logic.Group.GetType()
  local groupSize = AutoLFM.Logic.Group.GetSize()

  -- Already in raid
  if groupType == "raid" then
    return true
  end

  -- Solo, can't convert
  if groupType == "solo" then
    return false
  end

  -- Convert if target > 5 and currently in party
  if targetSize > 5 and groupType == "party" then
    if not AutoLFM.Logic.Group.CanInvite() then
      AutoLFM.Core.Utils.LogWarning("Cannot convert to raid: not party leader")
      return false
    end

    local success, err = pcall(ConvertToRaid)
    if not success then
      AutoLFM.Core.Utils.LogError("Failed to convert to raid: " .. tostring(err))
      return false
    end

    AutoLFM.Core.Utils.LogAction("Converted party to raid (target size: " .. targetSize .. ")")
    AutoLFM.Core.Utils.Print("Converted party to raid")
    return true
  end

  return false
end

--- Gets the target group size based on current selection mode
--- @return number - Target group size (5 for dungeons, variable for raids/custom)
function AutoLFM.Logic.Group.GetTargetSize()
  local selectionMode = AutoLFM.Core.Maestro.GetState("Selection.Mode")

  if selectionMode == "raid" then
    return AutoLFM.Core.Maestro.GetState("Selection.RaidSize") or 40
  elseif selectionMode == "custom" then
    return AutoLFM.Core.Maestro.GetState("Selection.CustomGroupSize") or 5
  else
    -- Dungeons or none
    return 5
  end
end

--=============================================================================
-- INITIALIZATION
--=============================================================================

AutoLFM.Core.SafeRegisterInit("Logic.Group", function()
  -- Group logic initialized
end, {
  id = "I20",
  dependencies = { "Core.Events" }
})
