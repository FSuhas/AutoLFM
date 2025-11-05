--=============================================================================
-- AutoLFM: Initialization
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Init then AutoLFM.Init = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local isInitialized = false
local initializedModules = {}

-----------------------------------------------------------------------------
-- Helper: Resolve and Execute
-----------------------------------------------------------------------------
local function ResolveAndExecute(fullPath, arg, safe)
  if not fullPath or fullPath == "" then
    if safe then AutoLFM.Core.Utils.PrintError("Invalid path (empty).") end
    return false
  end

  local lastDot = 0
  for i = string.len(fullPath), 1, -1 do
    if string.sub(fullPath, i, i) == "." then lastDot = i break end
  end
  if lastDot == 0 then
    local msg = "[AutoLFM] Invalid path (no dot): " .. fullPath
    if safe then AutoLFM.Core.Utils.PrintError(msg) else error(msg) end
    return false
  end

  local modulePath = string.sub(fullPath, 1, lastDot - 1)
  local funcName = string.sub(fullPath, lastDot + 1)
  local module, current = AutoLFM, 1

  while current < lastDot do
    local dotPos = string.find(modulePath, "%.", current)
    local key
    if dotPos then
      key = string.sub(modulePath, current, dotPos - 1)
      current = dotPos + 1
    else
      key = string.sub(modulePath, current)
      current = lastDot
    end
    module = module and module[key]
    if not module then
      local msg = "[AutoLFM] Missing module: " .. modulePath
      if safe then AutoLFM.Core.Utils.PrintError(msg) else error(msg) end
      return false
    end
  end

  local func = module[funcName]
  if not func then
    local msg = "[AutoLFM] Missing function: " .. fullPath
    if safe then AutoLFM.Core.Utils.PrintError(msg) else error(msg) end
    return false
  end

  local ok, result = pcall(func, arg)
  if not ok then
    local line = string.match(result, ":(%d+):") or "?"
    local msg = string.match(result, ":%d+:%s*(.*)") or result
    local err = "[AutoLFM] Lua error in " .. fullPath .. " (line " .. line .. "): " .. msg
    if safe then
      AutoLFM.Core.Utils.PrintError(err)
      return false
    else
      error(err)
    end
  end

  return result or true
end

-----------------------------------------------------------------------------
-- Public API
-----------------------------------------------------------------------------
function AutoLFM.Init.SafeCall(fullPath, arg)
  return ResolveAndExecute(fullPath, arg, true)
end

local function Call(fullPath, arg)
  return ResolveAndExecute(fullPath, arg, false)
end

-----------------------------------------------------------------------------
-- Initialization Sequence
-----------------------------------------------------------------------------
local initSequence = {
  { path = "Core.Settings.Init", strict = true },

  { path = "UI.DarkUI.Init", strict = false },
  { path = "UI.MainWindow.Init", strict = false },
  { path = "UI.DungeonsPanel.Init", strict = false },
  { path = "UI.RaidsPanel.Init", strict = false },
  { path = "UI.QuestsPanel.Init", strict = false },
  { path = "UI.MorePanel.Init", strict = false },
  { path = "UI.ClearTab.Init", strict = false },
  { path = "UI.TabNavigation.Init", strict = false },

  { path = "UI.WelcomePopup.Init", strict = false },
  { path = "UI.MinimapButton.Init", strict = false },
  { path = "UI.LinkIntegration.Init", strict = false },
  { path = "Logic.Selection.Init", strict = false },
  { path = "Logic.Broadcaster.Init", strict = false },
  { path = "API.Monitoring.Init", strict = false },
  { path = "Core.Events.Init", strict = false },
  { path = "Misc.AutoInvite.Init", strict = false },
  { path = "Misc.AutoMarker.Init", strict = false },
  { path = "Misc.FPSDisplay.Init", strict = false },
  { path = "Misc.FuBar.Init", strict = false },
  { path = "Misc.GuildSpam.Init", strict = false },
  { path = "Misc.RestedXP.Init", strict = false }
}

function AutoLFM.Init.Run()
  if isInitialized then return end
  for i = 1, table.getn(initSequence) do
    local entry = initSequence[i]
    local ok
    if entry.strict then
      ok = Call(entry.path)
    else
      ok = AutoLFM.Init.SafeCall(entry.path)
    end
    if ok then
      initializedModules[entry.path] = true
    else
      AutoLFM.Core.Utils.PrintWarning("Skipped: " .. entry.path)
    end
  end

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
