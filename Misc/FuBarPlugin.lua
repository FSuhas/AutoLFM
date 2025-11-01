--=============================================================================
-- AutoLFM: FuBar Plugin
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Misc then AutoLFM.Misc = {} end
if not AutoLFM.Misc.FuBar then AutoLFM.Misc.FuBar = {} end

local FuBarPlugin = AutoLFM.Misc.FuBar

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
local PLUGIN_NAME = "FuBar_AutoLFM"
local PLUGIN_VERSION = "1.0"
local ICON_PATH = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\Eyes\\eye07"

-----------------------------------------------------------------------------
-- Plugin Registration
-----------------------------------------------------------------------------
local function RegisterPlugin()
  local plugin = AceLibrary("AceAddon-2.0"):new("FuBarPlugin-2.0", "AceDB-2.0")
  
  plugin:RegisterDB("FuBar_AutoLFM_DB")
  plugin:RegisterDefaults("profile", {
    disabled = false
  })
  
  plugin.name = PLUGIN_NAME
  plugin.title = "FuBar - AutoLFM"
  plugin.version = PLUGIN_VERSION
  plugin.hasIcon = ICON_PATH
  plugin.defaultPosition = "CENTER"
  plugin.cannotDetachTooltip = true
  
  function plugin:IsActive()
    if self.db and self.db.profile then
      return not self.db.profile.disabled
    end
    return true
  end
  
  function plugin:ToggleActive()
    if self.db and self.db.profile then
      self.db.profile.disabled = not self.db.profile.disabled
      if self.db.profile.disabled then
        self:Hide()
      else
        self:Show()
      end
    end
  end
  
  function plugin:OnInitialize()
  end
  
  function plugin:OnEnable()
    self:Update()
    self:ScheduleRepeatingEvent("FuBar_AutoLFM_Update", self.Update, 1, self)
  end
  
  function plugin:OnTextUpdate()
    if not self:IsActive() then
      self:SetText(AutoLFM.Color("AutoLFM", "gray"))
      return
    end
    
    local text = "AutoLFM"
    
    if AutoLFM.Logic.Broadcaster.IsActive() then
      if AutoLFM.API and AutoLFM.API.GetPlayerCount then
        local playerCount = AutoLFM.API.GetPlayerCount()
        if playerCount then
          text = text .. " " .. AutoLFM.Color(playerCount.currentInGroup .. "/" .. playerCount.desiredTotal, "yellow")
        end
      end
    end
    
    self:SetText(text)
  end
  
  function plugin:OnTooltipUpdate()
    if not self:IsActive() then
      return
    end
    
    if not AutoLFM.Logic.Broadcaster then return end
    
    local tablet = AceLibrary("Tablet-2.0")
    if not tablet then return end
    
    tablet:SetTitle("AutoLFM")
    
    local cat = tablet:AddCategory("columns", 2)
    
    local isActive = AutoLFM.Logic.Broadcaster.IsActive()
    local status = isActive and AutoLFM.Color("Active", "green") or AutoLFM.Color("Inactive", "red")
    cat:AddLine("text", "Status:", "text2", status)
    
    local message = AutoLFM.Logic.Broadcaster.GetMessage()
    if message and message ~= "" then
      cat:AddLine("text", "Message:", "text2", message)
    end
    
    local channels = AutoLFM.Logic.Selection.GetChannels()
    if channels and next(channels) then
      local channelList = {}
      for name, _ in pairs(channels) do
        table.insert(channelList, name)
      end
      cat:AddLine("text", "Channels:", "text2", table.concat(channelList, ", "))
    end
    
    if isActive then
      local stats = AutoLFM.Logic.Broadcaster.GetStats()
      if stats then
        local duration = AutoLFM.Logic.Broadcaster.FormatDuration()
        cat:AddLine("text", "Duration:", "text2", duration)
        
        local interval = AutoLFM.Logic.Broadcaster.INTERVAL_DEFAULT
        if AutoLFM.UI.MorePanel.GetBroadcastIntervalSlider then
          local slider = AutoLFM.UI.MorePanel.GetBroadcastIntervalSlider()
          if slider and slider.GetValue then
            interval = slider:GetValue()
          end
        end
        cat:AddLine("text", "Interval:", "text2", interval .. "s")
        
        cat:AddLine("text", "Messages:", "text2", tostring(stats.messageCount or 0))
        
        if AutoLFM.API and AutoLFM.API.GetTiming then
          local timing = AutoLFM.API.GetTiming()
          if timing and timing.timeUntilNext then
            local seconds = math.floor(timing.timeUntilNext)
            cat:AddLine("text", "Next:", "text2", seconds .. "s")
          end
        end
      end
    end
    
    tablet:SetHint(AutoLFM.Color("Left-click", "orange") .. " to open window\n" .. AutoLFM.Color("Right-click", "orange") .. " for options")
  end
  
  function plugin:OnClick(button)
    if button == "LeftButton" then
      if AutoLFM_MainFrame then
        if AutoLFM_MainFrame:IsVisible() then
          HideUIPanel(AutoLFM_MainFrame)
        else
          ShowUIPanel(AutoLFM_MainFrame)
        end
      end
    end
  end

  function plugin:OnMenuRequest(level, value, inTooltip)
    local dewdrop = AceLibrary("Dewdrop-2.0")
    if not dewdrop then return end
    
    if not inTooltip then
      if level == 1 then
        dewdrop:AddLine(
          "text", "Open AutoLFM Window",
          "func", function()
            if AutoLFM_MainFrame then
              ShowUIPanel(AutoLFM_MainFrame)
            end
          end,
          "closeWhenClicked", true
        )
      end
    end
  end
  
  FuBarPlugin.instance = plugin
  
  return true
end

-----------------------------------------------------------------------------
-- Integration
-----------------------------------------------------------------------------
function FuBarPlugin.Init()
  if not AceLibrary then
    return false
  end
  
  if not AceLibrary:HasInstance("FuBarPlugin-2.0") then
    return false
  end
  
  local success, err = pcall(RegisterPlugin)
  
  if not success then
    if AutoLFM.Core and AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintError then
      AutoLFM.Core.Utils.PrintError("FuBar plugin error: " .. tostring(err))
    end
    return false
  end
  
  if AutoLFM.Core and AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintSuccess then
    AutoLFM.Core.Utils.PrintSuccess("FuBar plugin loaded")
  end
  
  return true
end

function FuBarPlugin.Update()
  if FuBarPlugin.instance and FuBarPlugin.instance.Update then
    FuBarPlugin.instance:Update()
  end
end

-----------------------------------------------------------------------------
-- API Integration
-----------------------------------------------------------------------------
if AutoLFM.API and AutoLFM.API.RegisterEventCallback then
  local events = {
    "BROADCAST_START",
    "BROADCAST_STOP",
    "MESSAGE_SENT"
  }
  
  for _, event in ipairs(events) do
    AutoLFM.API.RegisterEventCallback(event, "FuBar_AutoLFM", function()
      FuBarPlugin.Update()
    end)
  end
end
