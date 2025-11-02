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
local updateFrame = nil
local lastUpdate = 0

-----------------------------------------------------------------------------
-- Helper Functions
-----------------------------------------------------------------------------
local function FormatDuration(seconds)
  if not seconds or seconds < 0 then
    return "00:00"
  end
  local minutes = math.floor(seconds / 60)
  local secs = math.floor(math.mod(seconds, 60))
  return string.format("%02d:%02d", minutes, secs)
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
      if FuBarPlugin.instance and FuBarPlugin.instance.Update then
        pcall(function() FuBarPlugin.instance:Update() end)
      end
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
-- Plugin Registration
-----------------------------------------------------------------------------
local function RegisterPlugin()
  local plugin = AceLibrary("AceAddon-2.0"):new("FuBarPlugin-2.0", "AceDB-2.0")

  plugin:RegisterDB("AutoLFMFu_DB")
  plugin:RegisterDefaults("profile", { disabled = false })

  plugin.name = "AutoLFM"
  plugin.title = "AutoLFM"
  plugin.version = "0.1"
  plugin.author = "Gondoleon, NSO73"
  plugin.email = ""
  plugin.website = "https://github.com/FSuhas/AutoLFM"
  plugin.notes = "AutoLFM status display for FuBar"
  plugin.hasIcon = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\Eyes\\eye"
  plugin.defaultPosition = "CENTER"
  plugin.cannotDetachTooltip = true
  plugin.clickableTooltip = false
  plugin.hideWithoutStandby = false

  return plugin
end

-----------------------------------------------------------------------------
-- Menu Options
-----------------------------------------------------------------------------
local menuOptions = {
  type = "group",
  args = {
    open = {
      type = "execute",
      name = "Open AutoLFM Window",
      desc = "Open the main AutoLFM window",
      func = function()
        if AutoLFM_MainFrame then
          ShowUIPanel(AutoLFM_MainFrame)
        end
      end,
      order = 1
    }
  }
}

-----------------------------------------------------------------------------
-- Lifecycle
-----------------------------------------------------------------------------
local function OnInitialize()
end

local function OnEnable()
  if AutoLFMFu and AutoLFMFu.Update then
    AutoLFMFu:Update()
  end
end

-----------------------------------------------------------------------------
-- Text Display
-----------------------------------------------------------------------------
local function OnTextUpdate()
  if not AutoLFMFu then return end

  if not AutoLFM.API or not AutoLFM.API.IsAvailable() then
    AutoLFMFu:SetText("AutoLFM")
    return
  end

  local text = "AutoLFM"
  local isActive = AutoLFM.API.IsActive()

  if isActive then
    local playerCount = AutoLFM.API.GetPlayerCount()
    if playerCount and playerCount.currentInGroup and playerCount.desiredTotal then
      text = text .. " " .. playerCount.currentInGroup .. "/" .. playerCount.desiredTotal
    end

    local timing = AutoLFM.API.GetTiming()
    if timing and timing.timeUntilNext and timing.timeUntilNext > 0 then
      text = text .. " " .. "(" .. math.floor(timing.timeUntilNext) .. "s)"
    end
  end

  AutoLFMFu:SetText(text)
end

-----------------------------------------------------------------------------
-- Tooltip Display
-----------------------------------------------------------------------------
local function OnTooltipUpdate()
  if not AutoLFMFu then return end

  if not AutoLFM.API or not AutoLFM.API.IsAvailable() then
    return
  end

  local tablet = AceLibrary("Tablet-2.0")
  if not tablet then return end

  tablet:SetTitle("AutoLFM")

  local status = AutoLFM.API.GetFullStatus()
  if not status or not status.broadcastStats then return end

  local cat = tablet:AddCategory(
    "columns", 2,
    "child_textR", 1,
    "child_textG", 1,
    "child_textB", 0,
    "child_text2R", 1,
    "child_text2G", 1,
    "child_text2B", 1
  )

  local statusText = status.broadcastStats.isActive and AutoLFM.Color("Active", "green") or AutoLFM.Color("Inactive", "red")
  cat:AddLine("text", "Status:", "text2", statusText)

  if not status.broadcastStats.isActive then
    return
  end

  if status.groupType then
    local typeText = status.groupType == "raid" and "Raid" or status.groupType == "dungeon" and "Dungeon" or "Other"
    cat:AddLine("text", "Type:", "text2", AutoLFM.Color(typeText, "white"))
  end

  if status.selectedContent and status.selectedContent.list and table.getn(status.selectedContent.list) > 0 then
    local contentNames = {}
    for i = 1, table.getn(status.selectedContent.list) do
      local tag = status.selectedContent.list[i]
      local detail = status.selectedContent.details[tag]
      if detail and detail.name then
        table.insert(contentNames, detail.name)
      end
    end
    if table.getn(contentNames) > 0 then
      cat:AddLine("text", "Content:", "text2", table.concat(contentNames, ", "))
    end
  end

  if status.playerCount then
    local countText = status.playerCount.currentInGroup .. "/" .. status.playerCount.desiredTotal
    if status.playerCount.missing > 0 then
      countText = countText .. " " .. AutoLFM.Color("(-" .. status.playerCount.missing .. ")", "red")
    end
    cat:AddLine("text", "Players:", "text2", countText)
  end

  if status.rolesNeeded and table.getn(status.rolesNeeded) > 0 then
    cat:AddLine("text", "Roles:", "text2", table.concat(status.rolesNeeded, ", "))
  end

  if status.selectedChannels and table.getn(status.selectedChannels) > 0 then
    cat:AddLine("text", "Channels:", "text2", table.concat(status.selectedChannels, ", "))
  end

  if status.message and status.message.combined and status.message.combined ~= "" then
    cat:AddLine("text", "Message:", "text2", status.message.combined)
  end

  if status.broadcastStats.searchDuration and status.broadcastStats.searchDuration > 0 then
    cat:AddLine("text", "Duration:", "text2", FormatDuration(status.broadcastStats.searchDuration))
  end

  if status.timing and status.timing.intervalSeconds then
    cat:AddLine("text", "Interval:", "text2", status.timing.intervalSeconds .. "s")

    if status.timing.timeUntilNext and status.timing.timeUntilNext > 0 then
      cat:AddLine("text", "Next:", "text2", math.floor(status.timing.timeUntilNext) .. "s")
    end
  end

  if status.broadcastStats.messagesSent then
    cat:AddLine("text", "Messages:", "text2", tostring(status.broadcastStats.messagesSent))
  end
end

-----------------------------------------------------------------------------
-- Click Handler
-----------------------------------------------------------------------------
local function OnClick(frame, button)
  if button == "LeftButton" and AutoLFM_MainFrame then
    if AutoLFM_MainFrame:IsVisible() then
      HideUIPanel(AutoLFM_MainFrame)
    else
      ShowUIPanel(AutoLFM_MainFrame)
    end
  end
end

-----------------------------------------------------------------------------
-- Public API
-----------------------------------------------------------------------------
function FuBarPlugin.Update()
  if FuBarPlugin.instance and FuBarPlugin.instance.Update then
    pcall(function() FuBarPlugin.instance:Update() end)
  end
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function FuBarPlugin.Init()
  if not FuBar or not AceLibrary or not AceLibrary:HasInstance("FuBarPlugin-2.0") then
    return
  end

  local success = pcall(function()
    AutoLFMFu = RegisterPlugin()
  end)

  if not success or not AutoLFMFu then
    return
  end

  FuBarPlugin.instance = AutoLFMFu

  AutoLFMFu.OnMenuRequest = menuOptions
  AutoLFMFu.OnInitialize = OnInitialize
  AutoLFMFu.OnEnable = OnEnable
  AutoLFMFu.OnTextUpdate = OnTextUpdate
  AutoLFMFu.OnTooltipUpdate = OnTooltipUpdate
  AutoLFMFu.OnClick = OnClick

  if AutoLFM and AutoLFM.API and AutoLFM.API.RegisterEventCallback then
    local events = {
      "BROADCAST_START",
      "BROADCAST_STOP",
      "MESSAGE_SENT",
      "PLAYER_COUNT_CHANGED",
      "CONTENT_CHANGED",
      "ROLES_CHANGED",
      "CHANNELS_CHANGED",
      "INTERVAL_CHANGED"
    }

    for i = 1, table.getn(events) do
      AutoLFM.API.RegisterEventCallback(events[i], "AutoLFMFu", FuBarPlugin.Update)
    end

    AutoLFM.API.RegisterEventCallback("BROADCAST_START", "AutoLFMFu_Timer", StartUpdateTimer)
    AutoLFM.API.RegisterEventCallback("BROADCAST_STOP", "AutoLFMFu_Timer", function()
      StopUpdateTimer()
      FuBarPlugin.Update()
    end)
  end
end
