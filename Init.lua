--=============================================================================
-- AutoLFM: Initialization
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Init then AutoLFM.Init = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local isInitialized = false

-----------------------------------------------------------------------------
-- Helper: SafeInit
-----------------------------------------------------------------------------
local function SafeInit(name, func, arg1)
  if not func then return end
  
  local ok, err = pcall(func, arg1)
  if not ok then
    if AutoLFM.Core and AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintError then
      AutoLFM.Core.Utils.PrintError("Error initializing " .. name .. ": " .. tostring(err))
    else
      DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[AutoLFM] Error initializing " .. name .. ": " .. tostring(err) .. "|r")
    end
  end
end

-----------------------------------------------------------------------------
-- Initialization Stages
-----------------------------------------------------------------------------
local function InitCore()
  if not V2_Settings then V2_Settings = {} end
  
  if not (AutoLFM.Core and AutoLFM.Core.Settings) then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[AutoLFM]|r Core.Settings missing.")
    return false
  end

  if not AutoLFM.Core.Settings.InitCharacter() then
    AutoLFM.Core.Utils.PrintError("Failed to create character ID")
    return false
  end
  
  if not AutoLFM.Core.Settings.InitSavedVars() then
    AutoLFM.Core.Utils.PrintError("Failed to initialize SavedVariables")
    return false
  end
  
  if AutoLFM.UI and AutoLFM.UI.DungeonsPanel and AutoLFM.UI.DungeonsPanel.InitFilters then
    AutoLFM.UI.DungeonsPanel.InitFilters()
  end
  
  if AutoLFM.Logic and AutoLFM.Logic.Selection and AutoLFM.Logic.Selection.Init then
    SafeInit("Logic.Selection", AutoLFM.Logic.Selection.Init)
  end
  
  if AutoLFM.Misc then
    if AutoLFM.Misc.FPSDisplay and AutoLFM.Misc.FPSDisplay.Init then
      SafeInit("FPSDisplay", AutoLFM.Misc.FPSDisplay.Init)
    end
    if AutoLFM.Misc.RestedXP and AutoLFM.Misc.RestedXP.Init then
      SafeInit("RestedXP", AutoLFM.Misc.RestedXP.Init)
    end
    if AutoLFM.Misc.AutoInvite and AutoLFM.Misc.AutoInvite.Init then
      SafeInit("AutoInvite", AutoLFM.Misc.AutoInvite.Init)
    end
    if AutoLFM.Misc.GuildSpam and AutoLFM.Misc.GuildSpam.Init then
      SafeInit("GuildSpam", AutoLFM.Misc.GuildSpam.Init)
    end
    if AutoLFM.Misc.AutoMarker and AutoLFM.Misc.AutoMarker.Init then
      SafeInit("AutoMarker", AutoLFM.Misc.AutoMarker.Init)
    end
    if AutoLFM.Misc.FuBar and AutoLFM.Misc.FuBar.Init then
      SafeInit("FuBar", AutoLFM.Misc.FuBar.Init)
    end
  end
  
  return true
end

local function InitMainWindow()
  if not (AutoLFM.UI and AutoLFM.UI.MainWindow) then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[AutoLFM]|r Missing UI.MainWindow.")
    return false
  end

  AutoLFM_MainFrame = AutoLFM.UI.MainWindow.CreateFrame()
  if not AutoLFM_MainFrame then return false end
  
  AutoLFM_MainIconTexture = AutoLFM.UI.MainWindow.GetIconTexture()
  AutoLFM.UI.MainWindow.CreateRoleSelector()
  AutoLFM.UI.MainWindow.CreateMessagePreview()
  AutoLFM.UI.MainWindow.CreateStartButton()
  
  return true
end

local function InitPanels()
  if not AutoLFM.UI then return end
  if AutoLFM.UI.TabNavigation then
    AutoLFM.UI.TabNavigation.CreateTabs()
  end
  
  local panels = {
    AutoLFM.UI.DungeonsPanel,
    AutoLFM.UI.RaidsPanel,
    AutoLFM.UI.QuestsPanel,
    AutoLFM.UI.MorePanel,
    AutoLFM.UI.ClearTab
  }
  
  for i = 1, table.getn(panels) do
    local panel = panels[i]
    if panel and panel.Create then
      SafeInit("Panel Create", panel.Create, AutoLFM_MainFrame)
    end
    if panel and panel.Register then
      SafeInit("Panel Register", panel.Register)
    end
  end
  
  if AutoLFM.UI.TabNavigation then
    AutoLFM.UI.TabNavigation.Init()
    AutoLFM.UI.TabNavigation.SwitchTo(1)
  end
end

local function InitExtras()
  if AutoLFM.UI and AutoLFM.UI.MinimapButton and AutoLFM.UI.MinimapButton.Init then
    SafeInit("MinimapButton", AutoLFM.UI.MinimapButton.Init)
  end
  if AutoLFM.UI and AutoLFM.UI.LinkIntegration and AutoLFM.UI.LinkIntegration.Init then
    SafeInit("LinkIntegration", AutoLFM.UI.LinkIntegration.Init)
  end
  if AutoLFM.Core and AutoLFM.Core.Events and AutoLFM.Core.Events.Setup then
    SafeInit("Core.Events", AutoLFM.Core.Events.Setup)
  end
  if AutoLFM.Logic and AutoLFM.Logic.Broadcaster and AutoLFM.Logic.Broadcaster.InitLoop then
    SafeInit("Broadcaster", AutoLFM.Logic.Broadcaster.InitLoop)
  end
  if AutoLFM.API and AutoLFM.API.InitMonitoring then
    SafeInit("API.Monitoring", AutoLFM.API.InitMonitoring)
  end
end

-----------------------------------------------------------------------------
-- Main Entry Point
-----------------------------------------------------------------------------
function AutoLFM.Init.Run()
  if isInitialized then return end
  
  local success, err = pcall(function()
    if not InitCore() then return end
    if not InitMainWindow() then return end
    
    InitPanels()
    InitExtras()
    
    if AutoLFM_MainFrame then
      AutoLFM_MainFrame:Hide()
    end
    
    isInitialized = true
    
    if AutoLFM.Core and AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintSuccess then
      AutoLFM.Core.Utils.PrintSuccess("Loaded successfully! " ..
        AutoLFM.Core.Utils.ColorizeText("More info: ", "white") ..
        AutoLFM.Core.Utils.ColorizeText("/lfm help", "yellow"))
    else
      DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoLFM]|r Loaded successfully! Type /lfm help")
    end
  end)
  
  if not success then
    if AutoLFM.Core and AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintError then
      AutoLFM.Core.Utils.PrintError("Initialization failed: " .. tostring(err))
    else
      DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[AutoLFM] Initialization failed: " .. tostring(err) .. "|r")
    end
  end
end

-----------------------------------------------------------------------------
-- Event Registration
-----------------------------------------------------------------------------
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

initFrame:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" then
    AutoLFM.Init.Run()
    initFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
  end
end)
