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
-- Helpers
-----------------------------------------------------------------------------
local function SafeCall0(module, method)
  if module and module[method] then
    return module[method]()
  end
  return nil
end

local function SafeCall1(module, method, arg1)
  if module and module[method] then
    return module[method](arg1)
  end
  return nil
end

local function SafeCall2(module, method, arg1, arg2)
  if module and module[method] then
    return module[method](arg1, arg2)
  end
  return nil
end

-----------------------------------------------------------------------------
-- Initialization Stages
-----------------------------------------------------------------------------
local function InitCore()
  if not V2_Settings then V2_Settings = {} end
  
  if not SafeCall0(AutoLFM.Core.Settings, "InitCharacter") then
    SafeCall1(AutoLFM.Core.Utils, "PrintError", "Failed to create character ID")
    return false
  end
  
  if not SafeCall0(AutoLFM.Core.Settings, "InitSavedVars") then
    SafeCall1(AutoLFM.Core.Utils, "PrintError", "Failed to initialize SavedVariables")
    return false
  end
  
  SafeCall0(AutoLFM.UI.DungeonsPanel, "InitFilters")
  SafeCall0(AutoLFM.Logic.Selection, "Init")
  SafeCall0(AutoLFM.Misc.FPSDisplay, "Init")
  SafeCall0(AutoLFM.Misc.RestedXP, "Init")
  
  return true
end

local function InitMainWindow()
  AutoLFM_MainFrame = SafeCall0(AutoLFM.UI.MainWindow, "CreateFrame")
  if not AutoLFM_MainFrame then return false end
  
  AutoLFM_MainIconTexture = SafeCall0(AutoLFM.UI.MainWindow, "GetIconTexture")
  SafeCall0(AutoLFM.UI.MainWindow, "CreateRoleSelector")
  SafeCall0(AutoLFM.UI.MainWindow, "CreateMessagePreview")
  SafeCall0(AutoLFM.UI.MainWindow, "CreateStartButton")
  
  return true
end

local function InitPanels()
  SafeCall0(AutoLFM.UI.TabNavigation, "CreateTabs")
  
  local panels = {
    AutoLFM.UI.DungeonsPanel,
    AutoLFM.UI.RaidsPanel,
    AutoLFM.UI.QuestsPanel,
    AutoLFM.UI.MorePanel
  }
  
  for i = 1, table.getn(panels) do
    local panel = panels[i]
    if panel then
      SafeCall1(panel, "Create", AutoLFM_MainFrame)
      SafeCall0(panel, "Register")
    end
  end
  
  SafeCall0(AutoLFM.UI.TabNavigation, "Init")
  SafeCall1(AutoLFM.UI.TabNavigation, "SwitchTo", 1)
end

local function InitExtras()
  SafeCall0(AutoLFM.UI.MinimapButton, "Init")
  SafeCall0(AutoLFM.UI.LinkIntegration, "Init")
  SafeCall0(AutoLFM.Core.Events, "Setup")
  SafeCall0(AutoLFM.Logic.Broadcaster, "InitLoop")
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
    
    if AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintSuccess and AutoLFM.Core.Utils.ColorizeText then
      AutoLFM.Core.Utils.PrintSuccess("Loaded successfully! " .. AutoLFM.Core.Utils.ColorizeText("More info: ", "white") .. AutoLFM.Core.Utils.ColorizeText("/lfm help", "yellow"))
    end
  end)
  
  if not success then
    SafeCall1(AutoLFM.Core.Utils, "PrintError", "Initialization failed: " .. tostring(err))
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
