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

-----------------------------------------------------------------------------
-- Plugin Registration
-----------------------------------------------------------------------------
local function RegisterPlugin()
  local plugin = AceLibrary("AceAddon-2.0"):new("FuBarPlugin-2.0")
  
  plugin.name = PLUGIN_NAME
  plugin.title = "FuBar - AutoLFM"
  plugin.version = PLUGIN_VERSION
  plugin.hasIcon = "Interface\\AddOns\\AutoLFM\\AutoLFM"
  plugin.defaultPosition = "RIGHT"
  plugin.cannotDetachTooltip = true
  
  function plugin:OnInitialize()
  end
  
  function plugin:OnEnable()
    self:Update()
  end
  
  function plugin:OnTextUpdate()
    local isActive = AutoLFM.Logic.Broadcaster.IsActive()
    
    if isActive then
      self:SetText("|cff00ff00ON|r")
    else
      self:SetText("|cffff0000OFF|r")
    end
  end
  
  function plugin:OnTooltipUpdate()
    if not AutoLFM.Logic.Broadcaster then return end
    
    local tablet = AceLibrary("Tablet-2.0")
    if not tablet then return end
    
    tablet:SetTitle("AutoLFM")
    
    local cat = tablet:AddCategory("columns", 2)
    
    local isActive = AutoLFM.Logic.Broadcaster.IsActive()
    local status = isActive and "|cff00ff00Active|r" or "|cffff0000Inactive|r"
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
      end
    end
    
    tablet:SetHint("|cffeda55fLeft-click|r to toggle broadcast\n|cffeda55fRight-click|r for options")
  end
  
  function plugin:OnClick(button)
    if button == "LeftButton" then
      if AutoLFM.Logic.Broadcaster.IsActive() then
        AutoLFM.Logic.Broadcaster.Stop()
      else
        AutoLFM.Logic.Broadcaster.Start()
      end
      self:Update()
    end
  end
  
  function plugin:OnMenuRequest()
    local dewdrop = AceLibrary("Dewdrop-2.0")
    if not dewdrop then return end
    
    dewdrop:AddLine(
      "text", "Open AutoLFM Window",
      "func", function()
        if AutoLFM.UI.MainWindow.Toggle then
          AutoLFM.UI.MainWindow.Toggle()
        end
      end
    )
    
    dewdrop:AddLine()
    
    if AutoLFM.Logic.Broadcaster.IsActive() then
      dewdrop:AddLine(
        "text", "|cffff0000Stop Broadcast|r",
        "func", function()
          AutoLFM.Logic.Broadcaster.Stop()
          plugin:Update()
        end
      )
    else
      dewdrop:AddLine(
        "text", "|cff00ff00Start Broadcast|r",
        "func", function()
          AutoLFM.Logic.Broadcaster.Start()
          plugin:Update()
        end
      )
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
  AutoLFM.API.RegisterEventCallback("BROADCAST_START", "FuBar_AutoLFM", function()
    FuBarPlugin.Update()
  end)
  
  AutoLFM.API.RegisterEventCallback("BROADCAST_STOP", "FuBar_AutoLFM", function()
    FuBarPlugin.Update()
  end)
  
  AutoLFM.API.RegisterEventCallback("MESSAGE_SENT", "FuBar_AutoLFM", function()
    FuBarPlugin.Update()
  end)
end
