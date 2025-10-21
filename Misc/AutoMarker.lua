--=============================================================================
-- AutoLFM: Auto Marker
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Misc then AutoLFM.Misc = {} end
if not AutoLFM.Misc.AutoMarker then AutoLFM.Misc.AutoMarker = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local trackedList = {}
local isEnabled = false
local eventFrame = nil
local updateFrame = nil

-----------------------------------------------------------------------------
-- Icon Names
-----------------------------------------------------------------------------
local ICON_NAMES = {
  "Star", "Circle", "Diamond", "Triangle", 
  "Moon", "Square", "Cross", "Skull"
}

local function GetIconName(index)
  return ICON_NAMES[index] or "Unknown"
end

-----------------------------------------------------------------------------
-- Marking Logic
-----------------------------------------------------------------------------
local function TryMarkUnit(unit)
  if not UnitExists(unit) or not isEnabled then return end
  
  local name = UnitName(unit)
  if not name or not trackedList[name] then return end
  
  local icon = trackedList[name]
  if GetRaidTargetIndex(unit) ~= icon then
    SetRaidTarget(unit, icon)
  end
end

local function ScanAll()
  if not isEnabled then return end
  
  for i = 1, GetNumPartyMembers() do
    TryMarkUnit("party" .. i)
  end
  
  for i = 1, GetNumRaidMembers() do
    TryMarkUnit("raid" .. i)
  end
  
  TryMarkUnit("target")
end

-----------------------------------------------------------------------------
-- Clear Marks
-----------------------------------------------------------------------------
local function ClearAllMarks()
  for i = 1, GetNumRaidMembers() do
    SetRaidTarget("raid" .. i, 0)
  end
  
  for i = 1, GetNumPartyMembers() do
    SetRaidTarget("party" .. i, 0)
  end
  
  SetRaidTarget("target", 0)
end

-----------------------------------------------------------------------------
-- Event/Update Setup
-----------------------------------------------------------------------------
local function Setup()
  if not eventFrame then
    eventFrame = CreateFrame("Frame", "AutoLFM_AutoMarkerEventFrame")
  end
  
  eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
  eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
  
  eventFrame:SetScript("OnEvent", function()
    if event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
      ScanAll()
    end
  end)
  
  if not updateFrame then
    updateFrame = CreateFrame("Frame", "AutoLFM_AutoMarkerUpdateFrame")
  end
  
  updateFrame.timer = 0
  updateFrame:SetScript("OnUpdate", function()
    if not updateFrame.timer then updateFrame.timer = 0 end
    updateFrame.timer = updateFrame.timer + arg1
    
    if updateFrame.timer > 1 then
      ScanAll()
      updateFrame.timer = 0
    end
  end)
  
  isEnabled = true
end

local function Teardown()
  if eventFrame then
    eventFrame:UnregisterEvent("RAID_ROSTER_UPDATE")
    eventFrame:UnregisterEvent("PARTY_MEMBERS_CHANGED")
    eventFrame:SetScript("OnEvent", nil)
  end
  
  if updateFrame then
    updateFrame:SetScript("OnUpdate", nil)
  end
  
  ClearAllMarks()
  isEnabled = false
end

-----------------------------------------------------------------------------
-- Public API
-----------------------------------------------------------------------------
function AutoLFM.Misc.AutoMarker.Enable()
  if not isEnabled then
    Setup()
  end
  
  AutoLFM.Core.Settings.SaveMiscModule("autoMarker", true)
  AutoLFM.Core.Utils.PrintSuccess("Auto Marker enabled")
end

function AutoLFM.Misc.AutoMarker.Disable()
  Teardown()
  
  AutoLFM.Core.Settings.SaveMiscModule("autoMarker", false)
  AutoLFM.Core.Utils.PrintWarning("Auto Marker disabled")
end

function AutoLFM.Misc.AutoMarker.IsEnabled()
  return isEnabled
end

function AutoLFM.Misc.AutoMarker.AddPlayer(name, iconIndex)
  if not name or name == "" then
    AutoLFM.Core.Utils.PrintError("Player name cannot be empty")
    return false
  end
  
  local icon = tonumber(iconIndex)
  if not icon or icon < 1 or icon > 8 then
    AutoLFM.Core.Utils.PrintError("Icon must be between 1 and 8")
    return false
  end
  
  trackedList[name] = icon
  AutoLFM.Core.Settings.SaveMiscModuleData("autoMarker", "trackedList", trackedList)
  
  AutoLFM.Core.Utils.PrintSuccess("Tracking " .. name .. " with " .. GetIconName(icon))
  ScanAll()
  return true
end

function AutoLFM.Misc.AutoMarker.RemovePlayer(name)
  if not name or name == "" then
    AutoLFM.Core.Utils.PrintError("Player name cannot be empty")
    return false
  end
  
  if not trackedList[name] then
    AutoLFM.Core.Utils.PrintWarning(name .. " was not tracked")
    return false
  end
  
  trackedList[name] = nil
  AutoLFM.Core.Settings.SaveMiscModuleData("autoMarker", "trackedList", trackedList)
  
  AutoLFM.Core.Utils.PrintSuccess("Removed " .. name .. " from tracking")
  return true
end

function AutoLFM.Misc.AutoMarker.GetTrackedList()
  return trackedList
end

function AutoLFM.Misc.AutoMarker.ClearAll()
  ClearAllMarks()
  AutoLFM.Core.Utils.PrintSuccess("All marks cleared")
end

function AutoLFM.Misc.AutoMarker.ShowStatus()
  local state = isEnabled and AutoLFM.Color("ON", "green") or AutoLFM.Color("OFF", "red")
  
  AutoLFM.Core.Utils.PrintInfo("Auto Marker Status: " .. state)
  
  local hasPlayers = false
  for name, icon in pairs(trackedList) do
    if not hasPlayers then
      AutoLFM.Core.Utils.PrintInfo("Tracked players:")
      hasPlayers = true
    end
    AutoLFM.Core.Utils.Print("  " .. AutoLFM.Color(name, "yellow") .. " -> " .. GetIconName(icon))
  end
  
  if not hasPlayers then
    AutoLFM.Core.Utils.PrintNote("No players tracked")
  end
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function AutoLFM.Misc.AutoMarker.Init()
  local enabled = AutoLFM.Core.Settings.LoadMiscModule("autoMarker")
  local savedList = AutoLFM.Core.Settings.LoadMiscModuleData("autoMarker", "trackedList")
  
  if savedList then
    trackedList = savedList
  end
  
  if enabled then
    Setup()
  end
end

-----------------------------------------------------------------------------
-- Legacy Slash Command (/am)
-----------------------------------------------------------------------------
SLASH_AUTOMARKER1 = "/am"
SlashCmdList["AUTOMARKER"] = function(msg)
  if msg == "" or msg == "help" then
    AutoLFM.Core.Utils.PrintInfo("Legacy command /am - Use /lfm misc marker instead")
    AutoLFM.Core.Utils.PrintNote("Commands:")
    AutoLFM.Core.Utils.Print("  /am <name> <icon>  - Track player (1=Star ... 8=Skull)")
    AutoLFM.Core.Utils.Print("  /am del <name>     - Remove player")
    AutoLFM.Core.Utils.Print("  /am list           - Show tracked players")
    AutoLFM.Core.Utils.Print("  /am on/off         - Enable/disable")
    AutoLFM.Core.Utils.Print("  /am clear          - Clear all marks")
    return
  end
  
  local cmd, arg = string.match(msg, "^(%S+)%s*(.*)$")
  
  if cmd == "off" then
    AutoLFM.Misc.AutoMarker.Disable()
    return
  elseif cmd == "on" then
    AutoLFM.Misc.AutoMarker.Enable()
    return
  elseif cmd == "list" then
    AutoLFM.Misc.AutoMarker.ShowStatus()
    return
  elseif cmd == "clear" then
    AutoLFM.Misc.AutoMarker.ClearAll()
    return
  elseif cmd == "del" and arg ~= "" then
    AutoLFM.Misc.AutoMarker.RemovePlayer(arg)
    return
  else
    local name, icon = string.match(msg, "^(%S+)%s+(%d+)$")
    if name and icon then
      AutoLFM.Misc.AutoMarker.AddPlayer(name, icon)
      return
    end
  end
  
  AutoLFM.Core.Utils.PrintError("Invalid command. Type /am help")
end
