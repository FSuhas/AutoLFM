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

-- Retry logic for failed conversion attempts
local MAX_CONVERSION_ATTEMPTS = 3
local conversionAttempts = 0

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
--- Implements retry logic with exponential backoff for failed conversion attempts
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
  conversionAttempts = 0

  local function attemptConversion()
    conversionAttempts = conversionAttempts + 1
    local success, err = pcall(ConvertToRaid)

    if success then
      AutoLFM.Core.Utils.PrintSuccess("Converted party to raid")
      conversionPending = false
      return true
    end

    -- Retry with exponential backoff if attempts remain
    if conversionAttempts < MAX_CONVERSION_ATTEMPTS then
      AutoLFM.Core.Utils.LogWarning("Conversion attempt " .. conversionAttempts .. " failed, retrying...")
      -- Exponential backoff: 1 frame, 2 frames, 3 frames
      local backoffFrames = conversionAttempts
      local frameCounter = 0

      conversionFrame:SetScript("OnUpdate", function()
        frameCounter = frameCounter + 1
        if frameCounter >= backoffFrames then
          conversionFrame:SetScript("OnUpdate", nil)
          attemptConversion()
        end
      end)
      conversionFrame:Show()
      return false
    end

    -- Max attempts reached
    AutoLFM.Core.Utils.LogError("Failed to convert to raid after " .. MAX_CONVERSION_ATTEMPTS .. " attempts: " .. tostring(err))
    conversionPending = false
    return false
  end

  conversionFrame:SetScript("OnUpdate", function()
    conversionFrame:SetScript("OnUpdate", nil)
    conversionFrame:Hide()
    attemptConversion()
  end)
  conversionFrame:Show()
end

--=============================================================================
-- INITIALIZATION
--=============================================================================
AutoLFM.Core.SafeRegisterInit("Logic.Group", function() end, {
  id = "I07",
  dependencies = { "Core.Events" }
})
