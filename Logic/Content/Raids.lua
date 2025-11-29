--=============================================================================
-- AutoLFM: Raids Logic
--   Raid data management and API
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.Content = AutoLFM.Logic.Content or {}
AutoLFM.Logic.Content.Raids = {}

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Returns the array of raid definitions from Constants.RAIDS
--- @return table - Array of raid objects with name, tag, raidSizeMin, raidSizeMax
function AutoLFM.Logic.Content.Raids.GetRaids()
  return AutoLFM.Core.Constants.RAIDS
end
