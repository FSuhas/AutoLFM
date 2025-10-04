---------------------------------------------------------------------------------
--                            Msg Dynamique                                    --
---------------------------------------------------------------------------------


-- Fonction pour générer le message dynamique
function updateMsgFrameCombined()
    local totalPlayersInGroup = countGroupMembers()
    local totalPlayersInRaid = countRaidMembers()
    local totalGroupSize = 0

    local selectedContent = {}
    local selectedCountRoles = 0

    -- Compter les rôles sélectionnés
    for _, role in pairs(selectedRoles) do
        selectedCountRoles = selectedCountRoles + 1
    end

    local rolesList = table.concat(selectedRoles, " & ")
    local finalRolesSegment = ""
    if selectedCountRoles == 3 then
        finalRolesSegment = "Need All"
    elseif selectedCountRoles > 0 then
        finalRolesSegment = "Need " .. rolesList
    end

    -- Gérer les raids
    local selectedRaids = GetSelectedRaids()
    local isRaidSelected = false
    local raidSize = 0

    if table.getn(selectedRaids) > 0 then
        for _, raidAbrev in pairs(selectedRaids) do
            for _, raid in pairs(raids) do
                if raid.abrev == raidAbrev then
                    table.insert(selectedContent, raid.abrev)
                    ShowSliderForRaid(raid)
                    if raid.size_min == raid.size_max then
                        sliderSizeFrame:Hide()
                    end
                    isRaidSelected = true
                    raidSize = sliderValue
                    break
                end
            end
        end
    end

    -- Donjons si aucun raid sélectionné
    if not isRaidSelected then
        for _, donjonAbrev in pairs(selectedDungeons) do
            for _, donjon in pairs(donjons) do
                if donjon.abrev == donjonAbrev then
                    if donjon.size and totalPlayersInGroup then
                        totalGroupSize = donjon.size
                        local missingPlayers = totalGroupSize - totalPlayersInGroup
                        if missingPlayers < 0 then
                            missingPlayers = 0
                            stopMessageBroadcast()
                        end
                        if missingPlayers > 0 then
                            table.insert(selectedContent, donjon.abrev)
                        end
                    else
                        DEFAULT_CHAT_FRAME:AddMessage("Erreur : Invalid dungeon size or number of players for " .. donjon.abrev)
                    end
                    break
                end
            end
        end
    end

    -- Aucun contenu, rôle, ou message
    local contentCount = table.getn(selectedContent)
    if contentCount == 0 and selectedCountRoles == 0 and userInputMessage == "" then
        combinedMessage = ""
        msgTextDj:SetText(combinedMessage)
        msgTextRaids:SetText(combinedMessage)
        return
    end

    -- Calcul du manque (mate)
    local mate = 0
    local raidPlayerCountText = ""
    local currentCount = 0

    if isRaidSelected then
        if totalPlayersInRaid > 0 then
            currentCount = totalPlayersInRaid
        else
            currentCount = totalPlayersInGroup
        end
        mate = raidSize - currentCount
        if mate < 0 then mate = 0 end
        raidPlayerCountText = " " .. currentCount .. "/" .. raidSize
    else
        mate = totalGroupSize - totalPlayersInGroup
        if mate < 0 then mate = 0 end
    end

    -- Construction du message
    local contentMessage = table.concat(selectedContent, " & ")

    if contentCount == 0 and selectedCountRoles == 0 then
        combinedMessage = userInputMessage

    elseif contentCount == 0 and selectedCountRoles > 0 then
        combinedMessage = finalRolesSegment
        if userInputMessage ~= "" then
            combinedMessage = combinedMessage .. " " .. userInputMessage
        end

    elseif contentCount > 0 and selectedCountRoles == 0 then
        if isRaidSelected then
            combinedMessage = contentMessage .. " LF" .. mate .. "M" .. raidPlayerCountText
        else
            combinedMessage = "LF" .. mate .. "M for " .. contentMessage
        end
        if userInputMessage ~= "" then
            combinedMessage = combinedMessage .. " " .. userInputMessage
        end

    elseif contentCount > 0 and selectedCountRoles > 0 then
        if isRaidSelected then
            combinedMessage = contentMessage .. " LF" .. mate .. "M " .. finalRolesSegment .. raidPlayerCountText
        else
            combinedMessage = "LF" .. mate .. "M for " .. contentMessage .. " " .. finalRolesSegment
        end
        if userInputMessage ~= "" then
            combinedMessage = combinedMessage .. " " .. userInputMessage
        end
    end

    msgTextDj:SetText(combinedMessage)
    msgTextRaids:SetText(combinedMessage)

    if AutoLFM_API and AutoLFM_API.NotifyDataChanged then
      AutoLFM_API.NotifyDataChanged()
    end
end


