-- ============================================================
-- AutoMarker.lua (WoW 1.12)
-- ============================================================

local AutoMarkerFrame = CreateFrame("Frame", "AutoMarkerFrame")
AutoMarkerFrame:RegisterEvent("RAID_ROSTER_UPDATE")
AutoMarkerFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")

local trackedList = {}   -- ex : { ["Gondoleon"]=8, ["Tartempion"]=1 }
local autoMarkEnabled = true

-- ------------------------------------------------------------
-- Outils
-- ------------------------------------------------------------
local function GetRaidIconName(index)
    local icons = {"Star", "Circle", "Diamond", "Triangle", "Moon", "Square", "Cross", "Skull"}
    return icons[index] or "Unknown"
end

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[AutoMarker]|r " .. msg)
end

-- ------------------------------------------------------------
-- Fonction de marquage
-- ------------------------------------------------------------
local function TryMarkUnit(unit)
    if not UnitExists(unit) or not autoMarkEnabled then return end
    local name = UnitName(unit)
    if name and trackedList[name] then
        local icon = trackedList[name]
        if GetRaidTargetIndex(unit) ~= icon then
            SetRaidTarget(unit, icon)
            Print("Marqué " .. name .. " avec " .. GetRaidIconName(icon))
        end
    end
end

-- ------------------------------------------------------------
-- Scan complet du groupe/raid
-- ------------------------------------------------------------
local function ScanAll()
    if not autoMarkEnabled then return end

    for i = 1, GetNumPartyMembers() do
        TryMarkUnit("party" .. i)
    end

    for i = 1, GetNumRaidMembers() do
        TryMarkUnit("raid" .. i)
    end

    TryMarkUnit("target")
end

-- ------------------------------------------------------------
-- Nettoyer tous les icônes
-- ------------------------------------------------------------
local function ClearAllMarks()
    for i = 1, GetNumRaidMembers() do
        SetRaidTarget("raid" .. i, 0)
    end
    for i = 1, GetNumPartyMembers() do
        SetRaidTarget("party" .. i, 0)
    end
    SetRaidTarget("target", 0)
    Print("Tous les marquages ont été effacés.")
end

-- ------------------------------------------------------------
-- Mise à jour régulière
-- ------------------------------------------------------------
AutoMarkerFrame:SetScript("OnUpdate", function()
    if not this.timer then this.timer = 0 end
    this.timer = this.timer + arg1
    if this.timer > 1 then
        ScanAll()
        this.timer = 0
    end
end)

-- ------------------------------------------------------------
-- Sur événement
-- ------------------------------------------------------------
AutoMarkerFrame:SetScript("OnEvent", function()
    if event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
        ScanAll()
    end
end)

-- ------------------------------------------------------------
-- Commandes Slash
-- ------------------------------------------------------------
SLASH_AUTOMARKER1 = "/am"
SlashCmdList["AUTOMARKER"] = function(msg)
    if msg == "" or msg == "help" then
        Print("Commandes :")
        Print("/am <nom> <icone>  -> ajoute ou modifie un marquage (1=Étoile ... 8=Crâne)")
        Print("/am del <nom>      -> retire le suivi d’un joueur")
        Print("/am list           -> affiche la liste des suivis")
        Print("/am off            -> désactive temporairement l’automark")
        Print("/am on             -> réactive l’automark")
        return
    end

    local cmd, arg = string.match(msg, "^(%S+)%s*(.*)$")

    if cmd == "off" then
        autoMarkEnabled = false
        ClearAllMarks()
        Print("Auto marquage désactivé.")
        return
    elseif cmd == "on" then
        autoMarkEnabled = true
        Print("Auto marquage activé.")
        return
    elseif cmd == "list" then
        if next(trackedList) == nil then
            Print("Aucun joueur surveillé.")
        else
            Print("Liste des joueurs surveillés :")
            for name, icon in trackedList do
                Print("- " .. name .. " : " .. GetRaidIconName(icon))
            end
        end
        return
    elseif cmd == "del" and arg ~= "" then
        if trackedList[arg] then
            trackedList[arg] = nil
            Print("Retiré de la liste : " .. arg)
        else
            Print(arg .. " n’était pas surveillé.")
        end
        return
    else
        -- Tente le format <nom> <icone>
        local name, icon = string.match(msg, "^(%S+)%s+(%d+)$")
        if name and icon then
            local nicon = tonumber(icon)
            if nicon < 1 or nicon > 8 then
                Print("Icône invalide. Utilise un nombre de 1 à 8.")
                return
            end
            trackedList[name] = nicon
            Print("Surveillance ajoutée : " .. name .. " → " .. GetRaidIconName(nicon))
            ScanAll()
            return
        end
    end

    Print("Commande invalide. Tape /am help pour l’aide.")
end