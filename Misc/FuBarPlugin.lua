--=============================================================================
-- AutoLFM: FuBar Plugin
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Misc then AutoLFM.Misc = {} end
if not AutoLFM.Misc.FuBar then AutoLFM.Misc.FuBar = {} end

local FuBarPlugin = AutoLFM.Misc.FuBar

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local updateFrame, lastUpdate = nil, 0

-----------------------------------------------------------------------------
-- Utility Functions
-----------------------------------------------------------------------------
local function IsAPIAvailable()
  return AutoLFM and AutoLFM.API and AutoLFM.API.IsAvailable and AutoLFM.API.IsAvailable()
end

local function IsOtherGroupType(groupType)
  return groupType ~= "raid" and groupType ~= "dungeon"
end

local function GetColorByPercentage(percentage)
  if not percentage then return "gray" end
  if percentage < 25 then return "red" end
  if percentage < 50 then return "orange" end
  if percentage < 75 then return "yellow" end
  return "green"
end

local function GetGroupTypeName(groupType)
  if groupType == "raid" then return "Raid" end
  if groupType == "dungeon" then return "Dungeon" end
  return "Other"
end

local function SafeUpdate()
  if FuBarPlugin.instance and FuBarPlugin.instance.Update then
    pcall(function() FuBarPlugin.instance:Update() end)
  end
end

local function CreateDelayedUpdate(delay, callback)
  local frame = CreateFrame("Frame")
  frame.elapsed = 0
  frame:SetScript("OnUpdate", function()
    frame.elapsed = frame.elapsed + arg1
    if frame.elapsed >= delay then
      frame:SetScript("OnUpdate", nil)
      callback()
    end
  end)
end

-----------------------------------------------------------------------------
-- Update Timer
-----------------------------------------------------------------------------
local function StartUpdateTimer()
  if updateFrame then return end
  updateFrame = CreateFrame("Frame")
  updateFrame:SetScript("OnUpdate", function()
    local now = GetTime()
    if now - lastUpdate >= 1 then
      lastUpdate = now
      SafeUpdate()
    end
  end)
end

local function StopUpdateTimer()
  if updateFrame then
    updateFrame:SetScript("OnUpdate", nil)
    updateFrame = nil
  end
end

-----------------------------------------------------------------------------
-- FuBar Text Display
-----------------------------------------------------------------------------
local function BuildFuBarText(status)
  local text = GetGroupTypeName(status.groupType)
  local playerCount = AutoLFM.API.GetPlayerCount()
  
  if playerCount and playerCount.currentInGroup then
    local countText = " (" .. playerCount.currentInGroup
    if not IsOtherGroupType(status.groupType) and playerCount.desiredTotal then
      countText = countText .. "/" .. playerCount.desiredTotal
      local percentage = (playerCount.currentInGroup / playerCount.desiredTotal) * 100
      text = AutoLFM.Color(text .. countText .. ")", GetColorByPercentage(percentage))
    else
      text = AutoLFM.Color(text .. countText .. ")", "gold")
    end
  end
  
  local timing = AutoLFM.API.GetTiming()
  if timing and timing.timeUntilNext and timing.timeUntilNext > 0 then
    text = text .. " " .. AutoLFM.Color("(" .. math.floor(timing.timeUntilNext) .. "s)", "gray")
  end
  
  return text
end

local function OnTextUpdate()
  if not AutoLFMFu then return end
  
  if not IsAPIAvailable() or not AutoLFM.API.IsActive() then
    AutoLFMFu:SetText(AutoLFM.Color("AutoLFM", "gold"))
    return
  end

  local status = AutoLFM.API.GetFullStatus()
  AutoLFMFu:SetText(status and BuildFuBarText(status) or AutoLFM.Color("AutoLFM", "gold"))
end

-----------------------------------------------------------------------------
-- Tooltip Builders
-----------------------------------------------------------------------------
local function BuildRoleIcons(roles)
  if not roles or table.getn(roles) == 0 then return "" end
  
  local roleData = {Tank = {"T", "4A90E2"}, Heal = {"H", "5FB878"}, DPS = {"D", "E85D75"}}
  local icons = ""
  
  for i = 1, table.getn(roles) do
    local data = roleData[roles[i]]
    if data then
      if i > 1 then icons = icons .. " " end
      icons = icons .. "|cff" .. data[2] .. "[" .. data[1] .. "]|r"
    end
  end
  
  return icons
end

local function GetDungeonColorHex(tag, playerLevel)
  if not AutoLFM.Logic.Content.GetDungeonByTag or not AutoLFM.Logic.Content.CalculateDungeonPriority then
    return "d100"
  end
  
  local dungeon = AutoLFM.Logic.Content.GetDungeonByTag(tag)
  if not dungeon then return "d100" end
  
  local priority = AutoLFM.Logic.Content.CalculateDungeonPriority(playerLevel, dungeon)
  local r, g, b = AutoLFM.Logic.Content.GetColor(priority, true)
  
  return r and g and b and string.format("%02x%02x%02x", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)) or "d100"
end

local function AddLabeledLine(cat, label, value, isFirstLine)
  local labelText = isFirstLine and AutoLFM.Color(label, "white") or ""
  cat:AddLine("text", labelText, "text2", value)
end

local function AddContentSection(tablet, status)
  if not status.selectedContent or not status.selectedContent.list or table.getn(status.selectedContent.list) == 0 then return end
  
  local cat = tablet:AddCategory("columns", 2)
  local playerLevel = UnitLevel("player") or 1
  
  for i = 1, table.getn(status.selectedContent.list) do
    local tag = status.selectedContent.list[i]
    local detail = status.selectedContent.details[tag]
    
    if detail and detail.name then
      local coloredName
      if status.groupType == "dungeon" then
        local colorHex = GetDungeonColorHex(tag, playerLevel)
        coloredName = "|cff" .. colorHex .. detail.name .. "|r"
      else
        coloredName = AutoLFM.Color(detail.name, "gold")
      end
      
      local label = i == 1 and AutoLFM.Color("Content:", "white") or ""
      cat:AddLine("text", label, "text2", coloredName)
    end
  end
end

local function AddGroupSection(tablet, status)
  if IsOtherGroupType(status.groupType) or not status.playerCount then return end
  
  local pc = status.playerCount
  if not pc.currentInGroup or not pc.desiredTotal then return end
  
  local cat = tablet:AddCategory("columns", 2)
  local percentage = (pc.currentInGroup / pc.desiredTotal) * 100
  local color = GetColorByPercentage(percentage)
  
  local groupText = AutoLFM.Color("Group:", "white") .. " " .. AutoLFM.Color(pc.currentInGroup .. "/" .. pc.desiredTotal, color)
  if pc.missing and pc.missing > 0 then
    groupText = groupText .. " " .. AutoLFM.Color("(-" .. tostring(pc.missing) .. ")", color)
  end
  
  local rolesText = ""
  if status.rolesNeeded and table.getn(status.rolesNeeded) > 0 then
    rolesText = AutoLFM.Color("Roles:", "white") .. " " .. BuildRoleIcons(status.rolesNeeded)
  end
  
  cat:AddLine("text", groupText, "text2", rolesText)
end

local function AddChannelsTimingStatsSection(tablet, status)
  local cat = tablet:AddCategory("columns", 2)
  
  if status.selectedChannels and table.getn(status.selectedChannels) > 0 then
    for i = 1, table.getn(status.selectedChannels) do
      AddLabeledLine(cat, "Channels:", AutoLFM.Color(status.selectedChannels[i], "gold"), i == 1)
    end
  end
  
  if status.timing then
    local timing = status.timing
    if timing.intervalSeconds or (timing.timeUntilNext and timing.timeUntilNext > 0) then
      local intervalText = timing.intervalSeconds and AutoLFM.Color("Interval:", "white") .. " " .. AutoLFM.Color(timing.intervalSeconds .. "s", "gold") or ""
      local nextText = timing.timeUntilNext and timing.timeUntilNext > 0 and AutoLFM.Color("Next:", "white") .. " " .. AutoLFM.Color(math.floor(timing.timeUntilNext) .. "s", "gold") or ""
      
      if intervalText ~= "" or nextText ~= "" then
        cat:AddLine("text", intervalText, "text2", nextText)
      end
    end
  end
  
  if status.broadcastStats then
    local stats = status.broadcastStats
    local durationText, sentText = "", ""
    
    if stats.searchDuration and stats.searchDuration > 0 then
      local minutes = math.floor(stats.searchDuration / 60)
      local secs = math.floor(math.mod(stats.searchDuration, 60))
      durationText = AutoLFM.Color("Duration:", "white") .. " " .. AutoLFM.Color(string.format("%02d:%02d", minutes, secs), "gold")
    end
    
    if stats.messagesSent then
      sentText = AutoLFM.Color("Sent:", "white") .. " " .. AutoLFM.Color(tostring(stats.messagesSent), "gold")
    end
    
    if durationText ~= "" or sentText ~= "" then
      cat:AddLine("text", durationText, "text2", sentText)
    end
  end
end

-----------------------------------------------------------------------------
-- Tooltip Display
-----------------------------------------------------------------------------
local function OnTooltipUpdate()
  if not AutoLFMFu or not IsAPIAvailable() then return end

  local tablet = AceLibrary("Tablet-2.0")
  if not tablet then return end

  local status = AutoLFM.API.GetFullStatus()
  if not status or not status.broadcastStats then return end

  local typeText = GetGroupTypeName(status.groupType)
  local typeColor = status.broadcastStats.isActive and "blue" or "red"
  if not status.broadcastStats.isActive then typeText = "Inactive" end
  
  tablet:SetTitle("AutoLFM")
  local headerCat = tablet:AddCategory("columns", 1, "justify", "CENTER", "child_justify", "CENTER")
  headerCat:AddLine("text", " ")
  headerCat:AddLine("text", AutoLFM.Color(typeText, typeColor), "size", 14)

  if not status.broadcastStats.isActive then return end

  if status.message and status.message.combined and status.message.combined ~= "" then
    headerCat:AddLine("text", AutoLFM.Color(status.message.combined, "gold"))
  end
  
  AddContentSection(tablet, status)
  AddGroupSection(tablet, status)
  AddChannelsTimingStatsSection(tablet, status)
end

-----------------------------------------------------------------------------
-- Public API
-----------------------------------------------------------------------------
function FuBarPlugin.Update()
  SafeUpdate()
  OnTextUpdate()
end

function FuBarPlugin.RegisterEvents()
  if not IsAPIAvailable() then
    CreateDelayedUpdate(1, FuBarPlugin.RegisterEvents)
    return
  end

  if not AutoLFM.API.RegisterEventCallback then return end
  
  local events = {"MESSAGE_SENT", "PLAYER_COUNT_CHANGED", "CONTENT_CHANGED", "ROLES_CHANGED", "CHANNELS_CHANGED", "INTERVAL_CHANGED"}
  for i = 1, table.getn(events) do
    AutoLFM.API.RegisterEventCallback(events[i], "AutoLFMFu", FuBarPlugin.Update)
  end

  AutoLFM.API.RegisterEventCallback("BROADCAST_START", "AutoLFMFu_Timer", function()
    StartUpdateTimer()
    CreateDelayedUpdate(0.5, FuBarPlugin.Update)
  end)
  
  AutoLFM.API.RegisterEventCallback("BROADCAST_STOP", "AutoLFMFu_Timer", function()
    StopUpdateTimer()
    FuBarPlugin.Update()
  end)
  
  FuBarPlugin.Update()
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function FuBarPlugin.Init()
  if not FuBar or not AceLibrary or not AceLibrary:HasInstance("FuBarPlugin-2.0") then return end

  local success, plugin = pcall(function()
    local p = AceLibrary("AceAddon-2.0"):new("FuBarPlugin-2.0", "AceDB-2.0")
    p:RegisterDB("AutoLFMFu_DB")
    p:RegisterDefaults("profile", {disabled = false})
    p.name = "AutoLFM"
    p.title = "AutoLFM"
    p.version = "1.0"
    p.author = "Gondoleon, NSO73"
    p.email = ""
    p.website = "https://github.com/FSuhas/AutoLFM"
    p.notes = "AutoLFM status display for FuBar"
    p.hasIcon = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\Eyes\\eye"
    p.defaultPosition = "CENTER"
    p.cannotDetachTooltip = true
    p.clickableTooltip = false
    p.hideWithoutStandby = false
    return p
  end)

  if not success or not plugin then return end

  AutoLFMFu = plugin
  FuBarPlugin.instance = plugin

  plugin.OnMenuRequest = {type = "group", args = {open = {type = "execute", name = "Open AutoLFM Window", desc = "Open the main AutoLFM window", func = function() if AutoLFM_MainFrame then if AutoLFM_MainFrame:IsVisible() then HideUIPanel(AutoLFM_MainFrame) else ShowUIPanel(AutoLFM_MainFrame) end end end, order = 1}}}
  plugin.OnInitialize = function() end
  plugin.OnEnable = function() if AutoLFMFu and AutoLFMFu.Update then AutoLFMFu:Update() end end
  plugin.OnTextUpdate = OnTextUpdate
  plugin.OnTooltipUpdate = OnTooltipUpdate
  plugin.OnClick = function(frame, button) if button == "LeftButton" and AutoLFM_MainFrame then if AutoLFM_MainFrame:IsVisible() then HideUIPanel(AutoLFM_MainFrame) else ShowUIPanel(AutoLFM_MainFrame) end end end

  FuBarPlugin.RegisterEvents()
end
