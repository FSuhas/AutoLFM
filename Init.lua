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
local function SafeInit(name, func)
  local ok, err = pcall(func)
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
  
  if AutoLFM.Logic and AutoLFM.Logic.Selection then
    SafeInit("Logic.Selection", function() AutoLFM.Logic.Selection.Init() end)
  end
  
  if AutoLFM.Misc then
    if AutoLFM.Misc.FPSDisplay and AutoLFM.Misc.FPSDisplay.Init then
      SafeInit("FPSDisplay", function() AutoLFM.Misc.FPSDisplay.Init() end)
    end
    if AutoLFM.Misc.RestedXP and AutoLFM.Misc.RestedXP.Init then
      SafeInit("RestedXP", function() AutoLFM.Misc.RestedXP.Init() end)
    end
    if AutoLFM.Misc.AutoInvite and AutoLFM.Misc.AutoInvite.Init then
      SafeInit("AutoInvite", function() AutoLFM.Misc.AutoInvite.Init() end)
    end
    if AutoLFM.Misc.GuildSpam and AutoLFM.Misc.GuildSpam.Init then
      SafeInit("GuildSpam", function() AutoLFM.Misc.GuildSpam.Init() end)
    end
    if AutoLFM.Misc.AutoMarker and AutoLFM.Misc.AutoMarker.Init then
      SafeInit("AutoMarker", function() AutoLFM.Misc.AutoMarker.Init() end)
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
      SafeInit("Panel Create", function() panel.Create(AutoLFM_MainFrame) end)
    end
    if panel and panel.Register then
      SafeInit("Panel Register", function() panel.Register() end)
    end
  end
  
  if AutoLFM.UI.TabNavigation then
    AutoLFM.UI.TabNavigation.Init()
    AutoLFM.UI.TabNavigation.SwitchTo(1)
  end
end

local function InitExtras()
  if AutoLFM.UI and AutoLFM.UI.MinimapButton and AutoLFM.UI.MinimapButton.Init then
    SafeInit("MinimapButton", function() AutoLFM.UI.MinimapButton.Init() end)
  end
  if AutoLFM.UI and AutoLFM.UI.LinkIntegration and AutoLFM.UI.LinkIntegration.Init then
    SafeInit("LinkIntegration", function() AutoLFM.UI.LinkIntegration.Init() end)
  end
  if AutoLFM.Core and AutoLFM.Core.Events and AutoLFM.Core.Events.Setup then
    SafeInit("Core.Events", function() AutoLFM.Core.Events.Setup() end)
  end
  if AutoLFM.Logic and AutoLFM.Logic.Broadcaster and AutoLFM.Logic.Broadcaster.InitLoop then
    SafeInit("Broadcaster", function() AutoLFM.Logic.Broadcaster.InitLoop() end)
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
