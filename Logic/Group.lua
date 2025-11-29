--=============================================================================
-- AutoLFM: Group Management
--   Centralized group size, type, and leadership tracking
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.Group = {}

--=============================================================================
-- PRIVATE STATE
--=============================================================================
local conversionPending = false
local conversionFrame = CreateFrame("Frame")
conversionFrame:Hide()

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Gets current group size (1 for solo, 2-5 for party, 6-40 for raid)
--- @return number - Current group size
function AutoLFM.Logic.Group.GetSize()
  return AutoLFM.Core.Maestro.GetState("Group.Size") or 1
end

--- Gets current group type
--- @return string - "solo", "party", or "raid"
function AutoLFM.Logic.Group.GetType()
  return AutoLFM.Core.Maestro.GetState("Group.Type") or "solo"
end

--- Checks if player is party/raid leader or solo
--- @return boolean - True if player can invite
function AutoLFM.Logic.Group.IsLeader()
  return AutoLFM.Core.Maestro.GetState("Group.IsLeader") or false
end

--- Checks if player can invite (leader or solo)
--- @return boolean - True if player can invite
function AutoLFM.Logic.Group.CanInvite()
  local groupType = AutoLFM.Logic.Group.GetType()
  if groupType == "solo" then return true end
  return AutoLFM.Logic.Group.IsLeader()
end

--- Gets the target group size based on current selection mode
--- @return number - Target group size (5 for dungeons, variable for raids/custom)
function AutoLFM.Logic.Group.GetTargetSize()
  local selectionMode = AutoLFM.Core.Maestro.GetState("Selection.Mode")

  if selectionMode == "raid" then
    return AutoLFM.Core.Maestro.GetState("Selection.RaidSize") or 40
  elseif selectionMode == "custom" then
    return AutoLFM.Core.Maestro.GetState("Selection.CustomGroupSize") or 5
  end
  return 5
end

--- Attempts to convert party to raid if conditions are met
--- Uses deferred execution to avoid API call issues in event callbacks
--- Conditions: 2+ players, target size > 5, player is leader, in party (not raid)
function AutoLFM.Logic.Group.ConvertToRaidIfNeeded()
  local groupSize = AutoLFM.Logic.Group.GetSize()
  local targetSize = AutoLFM.Logic.Group.GetTargetSize()

  -- Need at least 2 players and target > 5
  if groupSize < 2 or targetSize <= 5 then
    return
  end

  -- Must be in party (not already raid)
  local groupType = AutoLFM.Logic.Group.GetType()
  if groupType ~= "party" then
    return
  end

  -- Must be leader
  if not AutoLFM.Logic.Group.IsLeader() then
    return
  end

  -- Defer conversion to next frame to avoid API issues
  if conversionPending then
    return
  end

  conversionPending = true
  conversionFrame:SetScript("OnUpdate", function()
    conversionFrame:Hide()
    conversionFrame:SetScript("OnUpdate", nil)

    local success, err = pcall(ConvertToRaid)
    if success then
      AutoLFM.Core.Utils.LogAction("Converted party to raid (target: " .. targetSize .. ")")
    else
      AutoLFM.Core.Utils.LogError("Failed to convert to raid: " .. tostring(err))
    end

    conversionPending = false
  end)
  conversionFrame:Show()
end

--=============================================================================
-- INITIALIZATION
--=============================================================================
AutoLFM.Core.SafeRegisterInit("Logic.Group", function() end, {
  id = "I20",
  dependencies = { "Core.Events" }
})
