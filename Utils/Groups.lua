--------------------------------------------------
-- Group Utilities
--------------------------------------------------

--------------------------------------------------
-- Get Party Member Count (including player)
--------------------------------------------------
function GetPartyMemberCount()
  return GetNumPartyMembers() + 1
end

--------------------------------------------------
-- Get Raid Member Count
--------------------------------------------------
function GetRaidMemberCount()
  return GetNumRaidMembers()
end

--------------------------------------------------
-- Check if Player is in Raid
--------------------------------------------------
function IsPlayerInRaid()
  return UnitInRaid("player")
end

--------------------------------------------------
-- Handle Raid Roster Update Event
--------------------------------------------------
function HandleRaidRosterUpdate()
  GetRaidMemberCount()
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end

--------------------------------------------------
-- Handle Party Members Changed Event
--------------------------------------------------
function HandlePartyUpdate()
  GetPartyMemberCount()
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end