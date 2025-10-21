-- ============================================================
-- AutoInvite.lua (WoW 1.12 / Lua 5.0)
-- Invite automatiquement les joueurs qui envoient un whisper avec un mot-clé.
-- ============================================================

local AutoInviteEnabled = true
local AutoInviteKeyword = "+1"
local AutoInviteConfirm = true

local frame = CreateFrame("Frame", "AutoInviteFrame")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("ADDON_LOADED")

-- Vérifie si le joueur peut inviter
local function IsPlayerPartyLeaderOrNotInParty()
    if not UnitInParty("player") then
        return true
    end
    return UnitIsPartyLeader("player")
end

-- Retire les espaces avant/après
local function Trim(s)
    if not s then return s end
    return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

-- Gestion des événements
frame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" then
        if arg1 == "AutoInvite" then
            DEFAULT_CHAT_FRAME:AddMessage("AutoInvite chargé. /ainv pour les commandes. Mot-clé: " .. AutoInviteKeyword)
        end

    elseif event == "CHAT_MSG_WHISPER" then
        if not AutoInviteEnabled then return end

        local msg = arg1
        local author = arg2
        local trimmed = Trim(msg)

        if string.lower(trimmed) == string.lower(AutoInviteKeyword) then
            if IsPlayerPartyLeaderOrNotInParty() then
                local playerName = UnitName("player")
                if author and author ~= playerName then
                    InviteByName(author)
                    if AutoInviteConfirm then
                        SendChatMessage("Invited you — come join!", "WHISPER", nil, author)
                    end
                end
            else
                if AutoInviteConfirm then
                    SendChatMessage("Je ne peux pas inviter : je ne suis pas leader de groupe.", "WHISPER", nil, author)
                end
            end
        end
    end
end)

-- ============================================================
-- Commandes slash
-- ============================================================

SLASH_AUTOINV1 = "/ainv"
SlashCmdList["AUTOINV"] = function(msg)
    local cmd, rest = string.match(msg or "", "^(%S*)%s*(.-)$")
    cmd = cmd and string.lower(cmd) or ""

    if cmd == "on" then
        AutoInviteEnabled = true
        DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: activé (mot-clé: " .. AutoInviteKeyword .. ")")

    elseif cmd == "off" then
        AutoInviteEnabled = false
        DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: désactivé")

    elseif cmd == "toggle" then
        AutoInviteEnabled = not AutoInviteEnabled
        DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: " .. (AutoInviteEnabled and "activé" or "désactivé"))

    elseif cmd == "status" or cmd == "" then
        DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: " .. (AutoInviteEnabled and "activé" or "désactivé") .. ", mot-clé: " .. AutoInviteKeyword)

    elseif cmd == "setkey" then
        local newkey = Trim(rest)
        if newkey == "" then
            DEFAULT_CHAT_FRAME:AddMessage("Usage: /ainv setkey <mot>")
        else
            AutoInviteKeyword = newkey
            DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: mot-clé changé en '" .. newkey .. "'")
        end

    elseif cmd == "confirm" then
        AutoInviteConfirm = not AutoInviteConfirm
        DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: confirmation whisper " .. (AutoInviteConfirm and "activée" or "désactivée"))

    else
        DEFAULT_CHAT_FRAME:AddMessage("AutoInvite commandes: on | off | toggle | status | setkey <mot> | confirm")
    end
end
