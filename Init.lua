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
-- Initialization Stages
-----------------------------------------------------------------------------
local function InitCore()
  if not V2_Settings then V2_Settings = {} end
  
  if not AutoLFM.Core.Settings.InitCharacter() then
    AutoLFM.Core.Utils.PrintError("Failed to create character ID")
    return false
  end
  
  if not AutoLFM.Core.Settings.InitSavedVars() then
    AutoLFM.Core.Utils.PrintError("Failed to initialize SavedVariables")
    return false
  end
  
  if AutoLFM.UI.DungeonsPanel.InitFilters then
    AutoLFM.UI.DungeonsPanel.InitFilters()
  end
  
  AutoLFM.Logic.Selection.Init()
  AutoLFM.Misc.FPSDisplay.Init()
  AutoLFM.Misc.RestedXP.Init()
  AutoLFM.Misc.AutoInvite.Init()
  AutoLFM.Misc.GuildSpam.Init()
  AutoLFM.Misc.AutoMarker.Init()
  
  return true
end

local function InitMainWindow()
  AutoLFM_MainFrame = AutoLFM.UI.MainWindow.CreateFrame()
  if not AutoLFM_MainFrame then return false end
  
  AutoLFM_MainIconTexture = AutoLFM.UI.MainWindow.GetIconTexture()
  AutoLFM.UI.MainWindow.CreateRoleSelector()
  AutoLFM.UI.MainWindow.CreateMessagePreview()
  AutoLFM.UI.MainWindow.CreateStartButton()
  
  return true
end

local function InitPanels()
  AutoLFM.UI.TabNavigation.CreateTabs()
  
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
      panel.Create(AutoLFM_MainFrame)
    end
    if panel and panel.Register then
      panel.Register()
    end
  end
  
  AutoLFM.UI.TabNavigation.Init()
  AutoLFM.UI.TabNavigation.SwitchTo(1)
end

local function InitExtras()
  AutoLFM.UI.MinimapButton.Init()
  AutoLFM.UI.LinkIntegration.Init()
  AutoLFM.Core.Events.Setup()
  AutoLFM.Logic.Broadcaster.InitLoop()
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
    
    AutoLFM.Core.Utils.PrintSuccess("Loaded successfully! " .. AutoLFM.Core.Utils.ColorizeText("More info: ", "white") .. AutoLFM.Core.Utils.ColorizeText("/lfm help", "yellow"))
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
