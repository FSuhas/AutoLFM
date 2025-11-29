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
-- Helper: Resolve and Execute
-----------------------------------------------------------------------------
local function ResolveAndExecute(fullPath, arg, safe)
    if not fullPath or fullPath == "" then
        if safe and AutoLFM.Core and AutoLFM.Core.Utils then
            AutoLFM.Core.Utils.PrintError("[SafeCall] Invalid path (empty).")
        end
        return false
    end

    local lastDot = 0
    for i = string.len(fullPath), 1, -1 do
        if string.sub(fullPath, i, i) == "." then
            lastDot = i
            break
        end
    end
    if lastDot == 0 then
        local msg = "[AutoLFM] Invalid path (no dot): " .. fullPath
        if safe then
            if AutoLFM.Core and AutoLFM.Core.Utils then
                AutoLFM.Core.Utils.PrintError(msg)
            end
            return false
        else
            error(msg)
        end
    end

    local modulePath = string.sub(fullPath, 1, lastDot - 1)
    local funcName   = string.sub(fullPath, lastDot + 1)
    local module     = AutoLFM
    local current    = 1

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
            if safe and AutoLFM.Core and AutoLFM.Core.Utils then
                AutoLFM.Core.Utils.PrintError(msg)
                return false
            else
                error(msg)
            end
        end
    end

    local func = module[funcName]
    if not func then
        local msg = "[AutoLFM] Missing function: " .. fullPath
        if safe and AutoLFM.Core and AutoLFM.Core.Utils then
            AutoLFM.Core.Utils.PrintError(msg)
            return false
        else
            error(msg)
        end
    end

    local ok, result = pcall(func, arg)
    if not ok then
        local line = string.match(result, ":(%d+):") or "?"
        local msg  = string.match(result, ":%d+:%s*(.*)") or result
        local err  = "[AutoLFM] Lua error in " .. fullPath .. " (line " .. line .. "): " .. msg
        if safe and AutoLFM.Core and AutoLFM.Core.Utils then
            AutoLFM.Core.Utils.PrintError(err)
            return false
        else
            error(err)
        end
    end

    return result or true
end

-----------------------------------------------------------------------------
-- Public API: Call / SafeCall
-----------------------------------------------------------------------------
function AutoLFM.Init.SafeCall(fullPath, arg)
    return ResolveAndExecute(fullPath, arg, true)
end

local function Call(fullPath, arg)
    return ResolveAndExecute(fullPath, arg, false)
end

-----------------------------------------------------------------------------
-- Module Table for Initialization Sequence
-----------------------------------------------------------------------------
local MODULES = {
    {path="Core.Settings.Init", critical=true},
    {path="UI.DarkUI.Init", critical=true},
    {path="UI.MainWindow.Init", critical=true},
    {path="UI.DungeonsPanel.Init", critical=false},
    {path="UI.RaidsPanel.Init", critical=false},
    {path="UI.QuestsPanel.Init", critical=false},
    {path="UI.MorePanel.Init", critical=false},
    {path="UI.ClearTab.Init", critical=false},
    {path="UI.TabNavigation.Init", critical=false},
    {path="UI.WelcomePopup.Init", critical=false},
    {path="UI.MinimapButton.Init", critical=false},
    {path="UI.LinkIntegration.Init", critical=false},
    {path="Logic.Selection.Init", critical=false},
    {path="Logic.Broadcaster.Init", critical=false},
    {path="API.Monitoring.Init", critical=false},
    {path="Core.Events.Init", critical=false},
    {path="Misc.AutoInvite.Init", critical=false},
    {path="Misc.AutoMarker.Init", critical=false},
    {path="Misc.FPSDisplay.Init", critical=false},
    {path="Misc.FuBar.Init", critical=false},
    {path="Misc.GuildSpam.Init", critical=false},
    {path="Misc.RestedXP.Init", critical=false},
}

-----------------------------------------------------------------------------
-- Run Initialization Sequence
-----------------------------------------------------------------------------
function AutoLFM.Init.Run()
    if isInitialized then return end

    for i=1, table.getn(MODULES) do
        local m = MODULES[i]
        if m.critical then
            Call(m.path)
        else
            AutoLFM.Init.SafeCall(m.path)
        end
    end

    if AutoLFM.Core and AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintSuccess then
        AutoLFM.Core.Utils.PrintSuccess(
            "Loaded successfully! " ..
            AutoLFM.Color("More info: ", "white") ..
            AutoLFM.Color("/lfm help", "yellow")
        )
        AutoLFM.Core.Utils.PrintTitle(
            "AutoLFM v3 available for beta testing! " ..
            AutoLFM.Color("More info on github repo", "white")
        )
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
