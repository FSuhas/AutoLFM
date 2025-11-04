--=============================================================================
-- AutoLFM: Initialization
--=============================================================================
-- Handles addon initialization sequence in proper dependency order.
-- Uses a local Call() helper to safely invoke namespaced Init functions.
-- 
-- Call() is safe because:
--   - Uses pcall to catch any runtime errors
--   - Validates module and function existence before invocation
--   - Provides clear error messages with full path context
--   - Only used internally during controlled init sequence
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Init then AutoLFM.Init = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local isInitialized = false

-----------------------------------------------------------------------------
-- Call function
-----------------------------------------------------------------------------
local function Call(fullPath, arg)
  local lastDot = 0
  for i = string.len(fullPath), 1, -1 do
    if string.sub(fullPath, i, i) == "." then lastDot = i break end
  end
  if lastDot == 0 then error("[AutoLFM] Invalid path: " .. fullPath) end
  
  local module, current = AutoLFM, 1
  while current < lastDot do
    local dotPos = string.find(fullPath, "%.", current)
    if dotPos and dotPos < lastDot then
      module = module and module[string.sub(fullPath, current, dotPos - 1)]
      current = dotPos + 1
    else
      module = module and module[string.sub(fullPath, current, lastDot - 1)]
      break
    end
  end
  if not module then error("[AutoLFM] Missing module: " .. string.sub(fullPath, 1, lastDot - 1)) end
  
  local func = module[string.sub(fullPath, lastDot + 1)]
  if not func then error("[AutoLFM] Missing function: " .. fullPath) end
  
  local ok, result = pcall(func, arg)
  if not ok then error("[AutoLFM] Error: " .. fullPath .. " - " .. tostring(result)) end
  
  return result or true
end

-----------------------------------------------------------------------------
-- Initialization Sequence
-----------------------------------------------------------------------------
function AutoLFM.Init.Run()
  if isInitialized then return end
  
  Call("Core.Settings.Init")

  Call("UI.DarkUI.Init")
  Call("UI.MainWindow.Init")

  Call("UI.DungeonsPanel.Init")
  Call("UI.RaidsPanel.Init")
  Call("UI.QuestsPanel.Init")
  Call("UI.MorePanel.Init")
  Call("UI.ClearTab.Init")
  Call("UI.TabNavigation.Init")

  Call("UI.WelcomePopup.Init")
  Call("UI.MinimapButton.Init")
  Call("UI.LinkIntegration.Init")

  Call("Logic.Selection.Init")
  Call("Logic.Broadcaster.Init")

  Call("API.Monitoring.Init")

  Call("Core.Events.Init")

  Call("Misc.AutoInvite.Init")
  Call("Misc.AutoMarker.Init")
  Call("Misc.FPSDisplay.Init")
  Call("Misc.FuBar.Init")
  Call("Misc.GuildSpam.Init")
  Call("Misc.RestedXP.Init")
  
  if AutoLFM.Core.Utils.PrintSuccess then
    AutoLFM.Core.Utils.PrintSuccess("Loaded successfully! " .. AutoLFM.Color("More info: ", "white") .. AutoLFM.Color("/lfm help", "yellow"))
  end
  
  isInitialized = true
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
