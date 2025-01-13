-- Variables
local selectedDungeons = {}
local selectedRaids = {}
local selectedRoles = {}
local selectedChannels = {}
local combinedMessage = ""

local donjons = {
    { nom = "Ragefire Chasm", abrev = "RFC", size = 5 },
    { nom = "Wailing Caverns", abrev = "WC", size = 5 },
    { nom = "Deadmines", abrev = "DM", size = 5 },
    { nom = "Shadowfang Keep", abrev = "SFK", size = 5 },
    { nom = "Blackfathom Deeps", abrev = "BFD", size = 5 },
    { nom = "The Stockade", abrev = "Stockade", size = 5 },  
    { nom = "Gnomeregan", abrev = "Gnomeregan", size = 5 },  
    { nom = "Razorfen Kraul", abrev = "RFK", size = 5 },
    { nom = "Scarlet Monastery Graveyard", abrev = "SM Grav", size = 5 },
    { nom = "Scarlet Monastery Library", abrev = "SM Lib", size = 5 },
    { nom = "Scarlet Monastery Armory", abrev = "SM Armo", size = 5 },
    { nom = "Scarlet Monastery Cathedral", abrev = "SM Cath", size = 5 },
    { nom = "Razorfen Downs", abrev = "RFD", size = 5 },
    { nom = "Uldaman", abrev = "Ulda", size = 5 },
    { nom = "Gilneas City", abrev = "Gilneas", size = 5 },
    { nom = "Maraudon", abrev = "Maraudon", size = 5 },  
    { nom = "Zul'Farrak", abrev = "ZF", size = 5 },
    { nom = "The Sunken Temple", abrev = "ST", size = 5 },
    { nom = "Halteforge Quarry", abrev = "HQ", size = 5 },
    { nom = "Blackrock Depths", abrev = "BRD", size = 5 },
    { nom = "Dire Maul East", abrev = "DM E", size = 5 },
    { nom = "Dire Maul West", abrev = "DM W", size = 5 },
    { nom = "Dire Maul North", abrev = "DM N", size = 5 },
    { nom = "Scholomance 5", abrev = "Scholo 5", size = 5 },
    { nom = "Scholomance 10", abrev = "Scholo 10", size = 10 },
    { nom = "Stratholme UD 5", abrev = "Strat UD 5", size = 5 },
    { nom = "Stratholme UD 10", abrev = "Strat UD 10", size = 10 },
    { nom = "Stratholme Live 5", abrev = "Strat Live 5", size = 5 },
    { nom = "Stratholme Live 10", abrev = "Strat Live 10", size = 10  },
    { nom = "Lower Blackrock Spire", abrev = "LBRS", size = 5 },
    { nom = "Upper Blackrock Spire", abrev = "UBRS", size = 10  },
    { nom = "Caverns of Time. Black Morass", abrev = "BT", size = 5 },
    { nom = "Stormwind Vault", abrev = "SWV", size = 5 },
}


local raids = {
    { nom = "Zul'Gurub", abrev = "ZG", size = 20 },
    { nom = "Ruins of Ahn'Qiraj", abrev = "AQ20", size = 20 },
    { nom = "Molten Core", abrev = "MC", size = 40 },
    { nom = "Onyxia's Lair", abrev = "Ony", size = 40 },
    { nom = "Lower Karazhan Halls", abrev = "Kara10",  size = 10 },
    { nom = "Blackwing Lair", abrev = "BWL", size = 40 },
    { nom = "Emerald Sanctum", abrev = "ES", size = 40},
    { nom = "Temple of Ahn'Qiraj", abrev = "AQ40", size = 40 },
    { nom = "Naxxramas", abrev = "Naxx", size = 40 },
}

-- Liste des rôles possibles
local allRoles = {
    "Tank",
    "Healer",
    "DPS"
}

-- Initialiser les tables si elles ne le sont pas déjà
donjonCheckButtons = donjonCheckButtons or {}
raidCheckButtons = raidCheckButtons or {}


--------------------------- Fonction Divers ---------------------------


-- Fonction pour compter manuellement les éléments dans une table
local function countTableEntries(t)
    local count = 0
    for _, _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- Fonction pour vérifier si la table est vide
local function isTableEmpty(t)
    for _, _ in pairs(t) do
        return false
    end
    return true
end

-- Fonction pour compter les rôles sélectionnés
local function countSelectedRoles(selectedRoles)
    local count = 0
    for _, _ in pairs(selectedRoles) do
        count = count + 1
    end
    return count
end

local function countSelectedDungeons(selectedDungeons)
    local count = 0
    for _, _ in pairs(selectedDungeons) do
        count = count + 1
    end
    return count
end

-- Créer strsplit
function strsplit(delim, text)
    local result = {}
    local start = 1
    local i = 1

    while true do
        -- Recherche de l'emplacement du prochain délimiteur
        local s, e = string.find(text, delim, start)

        if not s then  -- Si aucun délimiteur n'est trouvé, on arrête
            result[i] = string.sub(text, start)
            break
        end

        -- Ajouter le segment trouvé dans le tableau
        result[i] = string.sub(text, start, s - 1)
        i = i + 1

        -- Mettre à jour le point de départ pour la prochaine recherche
        start = e + 1
    end

    return result
end


--------------------------- Interface ---------------------------

--------------------------- Cadre Principal AutoLFM ---------------------------

-- Création du cadre
local AutoLFM = CreateFrame("Frame", "AutoLFM", UIParent)
AutoLFM:SetWidth(600)
AutoLFM:SetHeight(400)
AutoLFM:SetPoint("CENTER", UIParent, "CENTER")
AutoLFM:SetMovable(true)
AutoLFM:EnableMouse(true)
AutoLFM:RegisterForDrag("LeftButton")

-- Ajouter le fond
AutoLFM:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 11, bottom = 12 },
})

-- Créer un titre du cadre
local title = CreateFrame("Frame", nil, AutoLFM)
title:SetPoint("BOTTOM", AutoLFM, "TOP", 0, 1)
title:SetWidth(200)
title:SetHeight(40)
title:SetMovable(true)
title:EnableMouse(true)
title:RegisterForDrag("LeftButton")

title:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 16,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
title:SetBackdropBorderColor(0, 0, 0, 1)


--------------------------- Titre segmenté LFM ---------------------------


local titleSegments = {}
local part1 = title:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
part1:SetText("|cffadd8e6L|r")
part1:SetFont("Fonts\\SKURRI.TTF", 24, "OUTLINE")
table.insert(titleSegments, part1)

local part2 = title:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
part2:SetText("F")
part2:SetFont("Fonts\\SKURRI.TTF", 24, "OUTLINE")
part2:SetTextColor(1, 1, 1)
part2:SetPoint("LEFT", part1, "RIGHT", 5, 0)
table.insert(titleSegments, part2)

local part3 = title:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
part3:SetText("|cffff7f7fM|r")
part3:SetFont("Fonts\\SKURRI.TTF", 24, "OUTLINE")
part3:SetPoint("LEFT", part2, "RIGHT", 5, 0)
table.insert(titleSegments, part3)

-- Calculer la largeur totale du texte
local totalWidth = 0
for _, segment in ipairs(titleSegments) do
    totalWidth = totalWidth + segment:GetStringWidth()
end

local currentX = -totalWidth / 2
for _, segment in ipairs(titleSegments) do
    segment:SetPoint("CENTER", title, "CENTER", currentX, 0)
    currentX = currentX + segment:GetStringWidth()
end

--------------------------- Bouton X ---------------------------

-- --- Création du bouton rond "X" en haut à droite de la frame principale ---
local closeButton = CreateFrame("Button", nil, AutoLFM)
closeButton:SetWidth(30)
closeButton:SetHeight(30)
closeButton:SetPoint("TOPRIGHT", AutoLFM, "TOPRIGHT", 10, 10)

-- Appliquer une forme ronde au bouton avec une bordure
closeButton:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
closeButton:SetBackdropColor(0, 0, 0, 1)
closeButton:SetBackdropBorderColor(0, 0, 0, 1)

-- Ajouter un texte (un "X") à l'intérieur du bouton
local closeIcon = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
closeIcon:SetText("X")
closeIcon:SetPoint("CENTER", closeButton, "CENTER", 0, 0) 
closeIcon:SetTextColor(1, 1, 1) 

-- Ajouter un script pour masquer la frame quand le bouton est cliqué
closeButton:SetScript("OnClick", function()
    AutoLFM:Hide()
end)

-- Option pour ajouter un effet de survol :
closeButton:SetScript("OnEnter", function(self)
    this:SetBackdropBorderColor(1, 0, 0, 1)
end)

closeButton:SetScript("OnLeave", function(self)
    this:SetBackdropBorderColor(0, 0, 0, 1) 
end)


--------------------------- Frames ---------------------------


-- Créer cadre djframe
local djframe = CreateFrame("Frame", nil, AutoLFM)
djframe:SetWidth(240)
djframe:SetHeight(380)
djframe:SetPoint("TOPLEFT", AutoLFM, "TOPLEFT", 10, -10)
djframe:SetBackdrop({
    edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", edgeSize = 16,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
djframe:Hide()

local djScrollFrame = CreateFrame("ScrollFrame", "AutoLFM_ScrollFrame_Dungeons", djframe, "UIPanelScrollFrameTemplate")
djScrollFrame:SetPoint("TOPLEFT", djframe, "TOPLEFT", 10, -40)
djScrollFrame:SetWidth(240)
djScrollFrame:SetHeight(330)
djScrollFrame:Hide()


-- Créer cadre raidFrame
local raidFrame = CreateFrame("Frame", nil, AutoLFM)
raidFrame:SetWidth(240)
raidFrame:SetHeight(380)
raidFrame:SetPoint("TOPLEFT", AutoLFM, "TOPLEFT", 10, -10)
raidFrame:SetBackdrop({
    edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", edgeSize = 16,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
raidFrame:Hide()

local raidScrollFrame = CreateFrame("ScrollFrame", "AutoLFM_ScrollFrame_Raids", raidFrame, "UIPanelScrollFrameTemplate")
raidScrollFrame:SetPoint("TOPLEFT", raidFrame, "TOPLEFT", 10, -40)
raidScrollFrame:SetWidth(240)
raidScrollFrame:SetHeight(330)
raidScrollFrame:Hide()


-- Créer cadre roleframe
local roleframe = CreateFrame("Frame", nil, AutoLFM)
roleframe:SetBackdrop({
    bgFile = nil,
    -- edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",  -- Bordure blanche dev position
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }, 
})
roleframe:SetBackdropColor(1, 1, 1, 0.3)
roleframe:SetBackdropBorderColor(1, 1, 1, 1)

-- Positionner le roleframe
roleframe:SetWidth(AutoLFM:GetWidth() * 0.4)
roleframe:SetHeight(AutoLFM:GetHeight() * 0.2)
roleframe:SetPoint("TOPRIGHT", AutoLFM, "TOPRIGHT", -50, -40)

-- Réduction de la taille des icônes de 20 % au total
local iconWidth = roleframe:GetWidth() / 3 * 0.6 
local iconHeight = roleframe:GetHeight() * 0.6

-- Espacement entre les icônes (en pixels) : augmenter l'espacement à 20 pixels
local iconSpacing = 20 

-- Ajouter un texte au-dessus des icônes
local selectRoleText = roleframe:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
selectRoleText:SetText("Choose the role(s) you need ")
selectRoleText:SetPoint("BOTTOM", roleframe, "TOP", 0, 5)
selectRoleText:SetJustifyH("CENTER")
selectRoleText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")

-- Calculer la largeur totale nécessaire pour les icônes et l'espacement
local totalIconsWidth = 3 * iconWidth + 2 * iconSpacing 
local offsetX = (roleframe:GetWidth() - totalIconsWidth) / 2  

-- Calculer la hauteur totale nécessaire pour les icônes et l'espacement
local totalIconsHeight = iconHeight
local offsetY = (roleframe:GetHeight() - totalIconsHeight) / 2


-- Créer cadre msgFrame
local msgFrame = CreateFrame("Frame", nil, AutoLFM)
msgFrame:SetBackdrop({
    bgFile = nil,
    -- edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",  -- Bordure blanche dev position
    edgeSize = 16,  -- Taille de la bordure
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
msgFrame:SetBackdropColor(1, 1, 1, 0.3)
msgFrame:SetBackdropBorderColor(1, 1, 1, 1) 

-- Positionner le nouveau cadre juste en dessous de roleframe
msgFrame:SetWidth(roleframe:GetWidth()) 
msgFrame:SetHeight(roleframe:GetHeight())
msgFrame:SetPoint("TOPRIGHT", roleframe, "BOTTOMRIGHT", 0, -10)

-- Réduire la hauteur de msgFrame (par exemple, 50 pixels) et garder la largeur égale à sliderframe
msgFrame:SetWidth(roleframe:GetWidth())
msgFrame:SetPoint("TOPRIGHT", roleframe, "BOTTOMRIGHT", 0, -10) 

-- Créer un FontString dans msgFrame pour afficher le message
local msgText = msgFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
msgText:SetPoint("CENTER", msgFrame, "CENTER")
msgText:SetTextColor(1, 1, 1) 
msgText:SetJustifyH("CENTER")
msgText:SetJustifyV("CENTER")

msgText:SetWidth(msgFrame:GetWidth())



-- Créer cadre sliderframe
local sliderframe = CreateFrame("Frame", nil, AutoLFM)
sliderframe:SetBackdrop({
    bgFile = nil,
    -- edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",  -- Bordure blanche dev position
    edgeSize = 16,  -- Taille de la bordure
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
sliderframe:SetBackdropColor(1, 1, 1, 0.3) 
sliderframe:SetBackdropBorderColor(1, 1, 1, 1)

-- Positionner le nouveau cadre juste en dessous de roleframe
sliderframe:SetWidth(roleframe:GetWidth()) 
sliderframe:SetHeight(roleframe:GetHeight() + 90)
sliderframe:SetPoint("TOPRIGHT", msgFrame, "BOTTOMRIGHT", 0, -10)

-- Créer la barre de glissement (Slider)
local slider = CreateFrame("Slider", nil, sliderframe, "OptionsSliderTemplate")
slider:SetWidth(200)
slider:SetHeight(20)
slider:SetPoint("CENTER", sliderframe, "CENTER", 0, 0) 
slider:SetMinMaxValues(30, 120)
slider:SetValue(70)
slider:SetValueStep(10)


--------------------------- Init ---------------------------

AutoLFM:RegisterEvent("PARTY_MEMBERS_CHANGED")

djframe:Show()
djScrollFrame:Show()
AutoLFM:Hide()


--------------------------- Msg Dynamique ---------------------------


-- Fonction pour obtenir la taille d'une table
local function getTableSize(tbl)
    local size = 0
    for _, _ in pairs(tbl) do
        size = size + 1
    end
    return size
end

combinedMessage  = ""

-- Fonction pour compter les membres du groupe
local function countGroupMembers()
    local groupSize

    groupSize = GetNumPartyMembers() + 1

    return groupSize
end


-- Fonction pour générer le message dynamique
local function updateMsgFrameCombined()
    local totalPlayersInGroup = countGroupMembers()
    local totalGroupSize = 0 

    -- Segment des rôles sélectionnés
    local selectedRoles = selectedRoles
    local selectedCountRoles = 0 

    -- Comptage des rôles sélectionnés
    for _, role in pairs(selectedRoles) do
        selectedCountRoles = selectedCountRoles + 1
    end

    -- Segment des rôles
    local rolesSegmentFix = "Need "
    local rolesSegment = ""
    if selectedCountRoles == 3 then 
        rolesSegment = "Need All"
    elseif selectedCountRoles > 0 then
        rolesSegment = rolesSegmentFix .. table.concat(selectedRoles, " & ")
    end

    -- Segment des donjons ou raids sélectionnés
    local contentMessage = ""
    local selectedContent = {}

    -- Si un raid est sélectionné, utiliser les raids
    local selectedRaids = GetSelectedRaids()
    if table.getn(selectedRaids) > 0 then
        for _, raidAbrev in pairs(selectedRaids) do
            -- Rechercher le raid correspondant dans la table 'raids'
            for _, raid in pairs(raids) do
                if raid.abrev == raidAbrev then
                    -- Mettre à jour la taille du groupe en fonction du raid sélectionné
                    totalGroupSize = raid.size 

                    -- Calcul du nombre de joueurs manquants pour chaque raid
                    local missingPlayers = totalGroupSize - totalPlayersInGroup
                    if missingPlayers < 0 then
                        missingPlayers = 0 
                        stopMessageBroadcast()
                    end

                    -- Générer le message pour ce raid sous le format "LF M for Raidselect"
                    local raidMessage = ""
                    if missingPlayers > 0 then
                        raidMessage = raid.abrev
                    end

                    -- Ajouter le message pour ce raid à la liste des contenus sélectionnés
                    table.insert(selectedContent, raidMessage)
                    break 
                end
            end
        end
    else

        -- Sinon, utiliser les donjons
        for _, donjonAbrev in pairs(selectedDungeons) do
            -- Rechercher le donjon correspondant dans la table 'donjons'
            for _, donjon in pairs(donjons) do
                if donjon.abrev == donjonAbrev then
                    -- Vérifier que 'donjon.size' n'est pas nil avant de l'utiliser
                    if donjon.size and totalPlayersInGroup then
                        totalGroupSize = donjon.size 

                        -- Calcul du nombre de joueurs manquants pour chaque donjon
                        local missingPlayers = totalGroupSize - totalPlayersInGroup
                        if missingPlayers < 0 then
                            missingPlayers = 0  
                            stopMessageBroadcast()
                        end

                        -- Générer le message pour ce donjon sous le format "LF M for Donjonselect"
                        local donjonMessage = ""
                        if missingPlayers > 0 then
                            donjonMessage = donjon.abrev
                        end

                        -- Ajouter le message pour ce donjon à la liste des contenus sélectionnés
                        table.insert(selectedContent, donjonMessage)
                    else
                        -- Si 'donjon.size' est nil ou 'totalPlayersInGroup' est nil, afficher un message d'erreur
                        DEFAULT_CHAT_FRAME:AddMessage("Erreur : Invalid dungeon size or number of players for " .. donjon.abrev " " .. donjon.size)
                    end
                    break  -- Stopper la recherche dès qu'on a trouvé le bon donjon
                end
            end
        end
    end

    -- Si aucun contenu n'est sélectionné, ne rien afficher
    if table.getn(selectedContent) == 0 and selectedCountRoles == 0 then
        combinedMessage = ""
        msgText:SetText("")
        return
    end

    -- Créer un message combiné pour chaque donjon
    if table.getn(selectedContent) > 0 then
        contentMessage = table.concat(selectedContent, ", ")
    end

    local mate = totalGroupSize - totalPlayersInGroup

    if mate == -totalPlayersInGroup then
        mate = ""
    end

    -- Combiner le message final
    combinedMessage = "LF" .. mate .. "M " .. contentMessage .. " " .. rolesSegment .. " "

    msgText:SetText(combinedMessage)

    -- Vérifier si combinedMessage est non vide
    if combinedMessage and combinedMessage ~= "" then
        -- Ajuster le texte du message
        msgText:SetText(combinedMessage)

        -- Gérer le retour à la ligne si le texte dépasse la largeur du cadre
        local frameWidth = msgText:GetWidth()  -- Largeur du cadre où le texte est affiché
        local textWidth = msgText:GetStringWidth()  -- Largeur du texte

        -- Si le texte dépasse la largeur du cadre, ajuster le retour à la ligne
        if textWidth > frameWidth then
            local wrappedText = ""
            local words = {strsplit(" ", combinedMessage)}  -- Séparer les mots

            -- Vérifier si 'words' est valide avant de procéder
            if words then
                local line = ""
                
                for _, word in ipairs(words) do
                    -- Si ajouter ce mot dépasse la largeur du cadre
                    if (strlen(line) + strlen(word) + 1) > frameWidth then
                        wrappedText = wrappedText .. line .. "\n"  -- Ajouter un retour à la ligne
                        line = word  -- Commencer une nouvelle ligne avec ce mot
                    else
                        if line == "" then
                            line = word
                        else
                            line = line .. " " .. word  -- Ajouter un espace entre les mots
                        end
                    end
                end
                -- Ajouter la dernière ligne
                wrappedText = wrappedText .. line

                -- Afficher le texte enveloppé
                msgText:SetText(wrappedText)
            else
                -- Si 'words' est nil, afficher le texte tel quel
                msgText:SetText(combinedMessage)
            end
        end
    else
        msgText:SetText("")
    end
end


-- Fonction pour récupérer les donjons sélectionnés
function GetSelectedDungeons()
    return selectedDungeons or {}
end

-- Fonction pour récupérer les raids sélectionnés
function GetSelectedRaids()
    return selectedRaids or {}
end

function GetCombinedMessage()
    return combinedMessage or {}
end


--------------------------- Donjon Fonction ---------------------------

local donjonCount = 0
local maxDonjons = 100

-- Nombre maximum de donjons à afficher
for _, donjon in pairs(donjons) do
    donjonCount = donjonCount + 1
    if donjonCount >= maxDonjons then
        break
    end
end

-- Créer une bordure autour du ScrollFrame des donjons
local djBorderFrame = CreateFrame("Frame", "AutoLFM_BorderFrame_Dungeons", djScrollFrame)
djBorderFrame:SetPoint("TOPLEFT", djScrollFrame, "TOPLEFT", -5, 5)
djBorderFrame:SetPoint("BOTTOMRIGHT", djScrollFrame, "BOTTOMRIGHT", 5, -5)
djBorderFrame:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
djBorderFrame:SetBackdropBorderColor(0, 0, 0, 1)

-- Créer le contenu du ScrollFrame pour les donjons
local contentFrame = CreateFrame("Frame", nil, djScrollFrame)
contentFrame:SetWidth(200)
contentFrame:SetHeight(donjonCount * 30)
djScrollFrame:SetScrollChild(contentFrame)

local donjonCheckButtons = {}
-- Fonction pour vérifier si un élément est présent dans la table
local function tableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Créer les cases à cocher pour chaque donjon
for index, donjon in pairs(donjons) do
    -- Créer la case à cocher
    local checkbox = CreateFrame("CheckButton", "DonjonCheckbox" .. index, contentFrame, "UICheckButtonTemplate")
    checkbox:SetWidth(20)
    checkbox:SetHeight(20)
    checkbox:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -(30 * (index - 1)))

    -- Créer le label à côté de la case à cocher
    local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)

    -- Afficher le nom du donjon (pas l'abréviation)
    label:SetText(donjon.nom)

    -- Capturer l'abréviation du donjon localement dans la closure de la case à cocher
    local donjonAbrev = donjon.abrev 

    -- Ajouter la case à cocher dans la table donjonCheckButtons
    donjonCheckButtons[donjonAbrev] = checkbox 

    -- Ajouter la gestion de la sélection des donjons
    checkbox:SetScript("OnClick", function()
        -- Ici on utilise la valeur de donjonAbrev déjà capturée dans la closure
        -- Si la case est cochée, ajouter l'abréviation à la liste
        if checkbox:GetChecked() then
            if not tableContains(selectedDungeons, donjonAbrev) then
                table.insert(selectedDungeons, donjonAbrev)
            end
        else
            -- Si la case est décochée, retirer l'abréviation du donjon de la liste
            for i, value in pairs(selectedDungeons) do
                if value == donjonAbrev then
                    table.remove(selectedDungeons, i)
                    break
                end
            end
        end

        -- Lorsque des donjons sont sélectionnés, effacer les raids sélectionnés
        clearSelectedRaids()

        -- Mettre à jour l'affichage après chaque changement
        updateMsgFrameCombined()
    end)
end

-- Fonction utilitaire pour vérifier si une table contient un élément
function table.contains(table, element)
    for _, value in ipairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Fonction pour effacer les raids sélectionnés
function clearSelectedRaids()
    -- Décoche toutes les cases des raids
    for _, raidCheckbox in pairs(raidCheckButtons) do
        raidCheckbox:SetChecked(false)
    end
    selectedRaids = {}
end

--------------------------- Raids Fonctions ---------------------------


local raidCount = 0
local maxRaids = 100

-- Nombre maximum de raids à afficher
for _, raid in pairs(raids) do
    raidCount = raidCount + 1
    if raidCount >= maxRaids then
        break
    end
end

-- Créer une bordure autour du ScrollFrame des raids
local raidBorderFrame = CreateFrame("Frame", "AutoLFM_BorderFrame_Raids", raidScrollFrame)
raidBorderFrame:SetPoint("TOPLEFT", raidScrollFrame, "TOPLEFT", -5, 5)
raidBorderFrame:SetPoint("BOTTOMRIGHT", raidScrollFrame, "BOTTOMRIGHT", 5, -5)
raidBorderFrame:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
raidBorderFrame:SetBackdropBorderColor(0, 0, 0, 1)

-- Créer le contenu du ScrollFrame pour les raids
local raidContentFrame = CreateFrame("Frame", nil, raidScrollFrame)
raidContentFrame:SetWidth(200)
raidContentFrame:SetHeight(raidCount * 30)
raidScrollFrame:SetScrollChild(raidContentFrame)

raidCheckButtons = {}

-- Créer des cases à cocher pour chaque raid (similaire aux donjons)
for index, raid in pairs(raids) do
    -- Créer la case à cocher pour chaque raid
    local checkbox = CreateFrame("CheckButton", "RaidCheckbox" .. index, raidContentFrame, "UICheckButtonTemplate")
    checkbox:SetWidth(20)
    checkbox:SetHeight(20)
    checkbox:SetPoint("TOPLEFT", raidContentFrame, "TOPLEFT", 0, -(30 * (index - 1)))

    -- Créer le label pour chaque raid
    local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    label:SetText(raid.nom) 

    -- Capturer l'abréviation du raid localement
    local raidAbrev = raid.abrev

    -- Ajouter la case à cocher dans la table raidCheckButtons
    raidCheckButtons[raidAbrev] = checkbox 

    -- Ajouter la gestion de la sélection des raids
    checkbox:SetScript("OnClick", function()
        -- Si la case est cochée, désélectionner toutes les autres cases
        if checkbox:GetChecked() then
            -- Désélectionner toutes les autres cases à cocher de raid
            for _, otherCheckbox in pairs(raidCheckButtons) do
                if otherCheckbox ~= checkbox then
                    otherCheckbox:SetChecked(false)
                end
            end

            -- Ajouter l'abréviation du raid à la liste des raids sélectionnés
            if not tableContains(selectedRaids, raidAbrev) then
                selectedRaids = {raidAbrev}
            end
        else
            -- Si la case est décochée, retirer l'abréviation du raid de la liste
            selectedRaids = {} 
        end

        -- Lorsque des raids sont sélectionnés, effacer les donjons sélectionnés
        clearSelectedDungeons()

        -- Mettre à jour l'affichage après chaque changement
        updateMsgFrameCombined()
    end)
end

-- Fonction pour effacer les donjons sélectionnés
function clearSelectedDungeons()
    -- Décoche toutes les cases des donjons
    for _, donjonCheckbox in pairs(donjonCheckButtons) do
        donjonCheckbox:SetChecked(false)
    end
    selectedDungeons = {}
end


--------------------------- Swap Bouton ---------------------------


local swapButton = CreateFrame("Button", nil, AutoLFM, "OptionsButtonTemplate")
swapButton:SetText("Raids List")
swapButton:SetWidth(200)
swapButton:SetHeight(25)
swapButton:SetPoint("BOTTOM", djScrollFrame, "TOP", 0, 10)

--- Action lorsque le bouton est cliqué ---
swapButton:SetScript("OnClick", function()
    -- Si les donjons et les raids sont vides, basculer entre les vues
    if djframe:IsShown() then
        -- Cacher les donjons et afficher les raids
        djframe:Hide()
        djScrollFrame:Hide()
        swapButton:SetText("Dungeons List")
        raidFrame:Show()
        raidScrollFrame:Show()
    else
        -- Cacher les raids et afficher les donjons
        raidFrame:Hide()
        raidScrollFrame:Hide()
        swapButton:SetText("Raids List")
        djframe:Show()
        djScrollFrame:Show()
    end
end)


--------------------------- Role Fonction ---------------------------


-- Créer l'icône Tank
local tankIcon = CreateFrame("Button", nil, roleframe)
tankIcon:SetWidth(iconWidth)
tankIcon:SetHeight(iconHeight) 
tankIcon:SetPoint("TOPLEFT", roleframe, "TOPLEFT", offsetX, -offsetY) 

tankIcon.texture = tankIcon:CreateTexture(nil, "BACKGROUND")
tankIcon.texture:SetAllPoints(tankIcon)
tankIcon.texture:SetTexture("Interface\\AddOns\\AutoLFM\\icon\\tank.png")

tankIcon.selected = false
tankIcon:SetScript("OnClick", function()
    -- Inverser l'état de sélection
    if tankIcon.selected then
        -- Désélectionner
        tankIcon.selected = false
        tankIcon:SetBackdrop(nil)
        -- Supprimer le rôle Tank de la table selectedRoles
        for i, role in ipairs(selectedRoles) do
            if role == "Tank" then
                table.remove(selectedRoles, i)
                break
            end
        end
    else
        -- Sélectionner
        tankIcon.selected = true
        tankIcon:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        tankIcon:SetBackdropBorderColor(1, 1, 0, 1) 
        -- Ajouter le rôle Tank à la table selectedRoles
        table.insert(selectedRoles, "Tank")
    end
    updateMsgFrameCombined()
end)

-- Créer l'icône DPS
local dpsIcon = CreateFrame("Button", nil, roleframe)
dpsIcon:SetWidth(iconWidth)  
dpsIcon:SetHeight(iconHeight) 
dpsIcon:SetPoint("TOPLEFT", tankIcon, "TOPRIGHT", iconSpacing, 0) 

dpsIcon.texture = dpsIcon:CreateTexture(nil, "BACKGROUND")
dpsIcon.texture:SetAllPoints(dpsIcon)
dpsIcon.texture:SetTexture("Interface\\AddOns\\AutoLFM\\icon\\dps.png")  

dpsIcon.selected = false
dpsIcon:SetScript("OnClick", function()
    -- Inverser l'état de sélection
    if dpsIcon.selected then
        -- Désélectionner
        dpsIcon.selected = false
        dpsIcon:SetBackdrop(nil)
        -- Supprimer le rôle DPS de la table selectedRoles
        for i, role in ipairs(selectedRoles) do
            if role == "DPS" then
                table.remove(selectedRoles, i)
                break
            end
        end
    else
        -- Sélectionner
        dpsIcon.selected = true
        dpsIcon:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        dpsIcon:SetBackdropBorderColor(1, 1, 0, 1)
        -- Ajouter le rôle DPS à la table selectedRoles
        table.insert(selectedRoles, "DPS")
    end
    updateMsgFrameCombined()  
end)

-- Créer l'icône Heal
local healIcon = CreateFrame("Button", nil, roleframe)
healIcon:SetWidth(iconWidth)  
healIcon:SetHeight(iconHeight)  
healIcon:SetPoint("TOPLEFT", dpsIcon, "TOPRIGHT", iconSpacing, 0)  

healIcon.texture = healIcon:CreateTexture(nil, "BACKGROUND")
healIcon.texture:SetAllPoints(healIcon)
healIcon.texture:SetTexture("Interface\\AddOns\\AutoLFM\\icon\\heal.png")  

healIcon.selected = false
healIcon:SetScript("OnClick", function()
    -- Inverser l'état de sélection
    if healIcon.selected then
        -- Désélectionner
        healIcon.selected = false
        healIcon:SetBackdrop(nil)
        -- Supprimer le rôle Heal de la table selectedRoles
        for i, role in ipairs(selectedRoles) do
            if role == "Heal" then
                table.remove(selectedRoles, i)
                break
            end
        end
    else
        -- Sélectionner
        healIcon.selected = true
        healIcon:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",  
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        healIcon:SetBackdropBorderColor(1, 1, 0, 1)  
        -- Ajouter le rôle Heal à la table selectedRoles
        table.insert(selectedRoles, "Heal")
    end
    updateMsgFrameCombined()  
end)


--------------------------- Slider Frame ---------------------------


-- Table des canaux à rechercher
local channelsToFind = {"WORLD", "LookingForGroup"}
-- Table pour stocker les canaux trouvés
local foundChannels = {}

-- Fonction pour envoyer un message dans les canaux trouvés
local function sendMessageToChannels(message)
    for _, channel in ipairs(channelsToFind) do
        -- Recherche l'ID du canal en utilisant "/join" pour s'assurer qu'il est ouvert
        local channelId = GetChannelName(channel)
        if channelId and channelId > 0 then
            SendChatMessage(message, "CHANNEL", nil, channelId)
        end
    end
end

-- Valeur de pas fixe pour arrondir
local step = 10

-- Fonction pour arrondir la valeur du slider à l'étape la plus proche
local function SnapToStep(value)
    if value then
        local roundedValue = math.floor(value / step + 0.5) * step 
        return roundedValue
    end
end

-- Variable pour stocker la valeur du slider
local sliderValue = 70  

-- Créer une police pour afficher la valeur actuelle du slider (placer la valeur au-dessus du slider)
local valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
valueText:SetPoint("BOTTOM", slider, "TOP", 0, 5) 
valueText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")


-- Variables pour gérer l'intervalle et la diffusion du message
local isBroadcasting = false 
local broadcastStartTime = 0 


-- Fonction pour arrêter la diffusion du message
local function stopMessageBroadcast()
    isBroadcasting = false
end

-- Fonction pour démarrer la diffusion du message
local function startMessageBroadcast()
    -- Vérifier si combinedMessage est vide avant de démarrer la diffusion
    if combinedMessage == "" or combinedMessage == " " then
        print("The LFM message is empty. The broadcast cannot begin.")
        return 
    end

    isBroadcasting = true
    broadcastStartTime = GetTime()
    print("Broadcast started.")

    -- Diffuser immédiatement le message dès le démarrage
    sendMessageToChannels(combinedMessage)
end

-- Créer un bouton Toggle en dessous de msgFrame, centré par rapport à AutoLFM
local toggleButton = CreateFrame("Button", "ToggleButton", msgFrame, "UIPanelButtonTemplate")
toggleButton:SetWidth(120)
toggleButton:SetHeight(30)


-- Positionner le bouton en bas centré, sous roleframe et msgFrame par rapport a autolfm
toggleButton:SetPoint("CENTER", msgFrame, "CENTER", 0, -10)  -- Placer 10 pixels sous msgFrame
toggleButton:SetPoint("BOTTOM", AutoLFM, 0, 20)

toggleButton:SetText("Start")

-- Fonction pour gérer le changement d'état du bouton et démarrer/arrêter la diffusion
toggleButton:SetScript("OnClick", function()
    -- Vérifier si le message combiné est vide ou ne contient que des espaces
    if combinedMessage == " " or combinedMessage == "" then
        -- Si le message est vide, ne pas démarrer la diffusion et vider la variable
        combinedMessage = ""
        stopMessageBroadcast()
        toggleButton:SetText("Start")
        print("The message is empty. The broadcast cannot start.")
        return
    end

    if isBroadcasting then
        stopMessageBroadcast()
        toggleButton:SetText("Start")
        print("Broadcast stopped")
    else
        startMessageBroadcast() 
        toggleButton:SetText("Stop")
    end
end)


-- Mettre à jour la valeur du slider à chaque déplacement en utilisant OnUpdate
sliderframe:SetScript("OnUpdate", function(self, elapsed)
    -- Récupérer la valeur actuelle du slider
    local currentValue = slider:GetValue()

    -- Arrondir la valeur à l'étape la plus proche
    local snappedValue = SnapToStep(currentValue)

    -- Appliquer la valeur arrondie au slider si nécessaire (au cas où la valeur serait flottante)
    if currentValue ~= snappedValue then
        slider:SetValue(snappedValue)
    end

    -- Mettre à jour dynamiquement le texte pour refléter la nouvelle valeur en temps réel
    valueText:SetText("Dispense every " .. slider:GetValue() .. " seconds")

    -- Mettre à jour la variable stockée
    sliderValue = snappedValue

    -- Si la diffusion est active, gérer le délai entre chaque diffusion du message
    if isBroadcasting then
        local timeElapsed = GetTime() - broadcastStartTime

        -- Si le temps écoulé est supérieur ou égal à la valeur du slider, diffuser un message
        if timeElapsed >= sliderValue then
            -- Diffuser le message à l'intervalle spécifié
            if combinedMessage ~= "" then
                sendMessageToChannels(combinedMessage)
            else
                print("The LFM message is empty.")
            end
            broadcastStartTime = GetTime()
        end
    end
end)


--------------------------- Event Fonction ---------------------------


AutoLFM:SetScript("OnEvent", function(self, event, ...)
    if "GROUP_ROSTER_UPDATE" then
        -- Si le groupe a changé, on arrête la diffusion du message
        stopMessageBroadcast()
        toggleButton:SetText("Start")
        countGroupMembers()
        updateMsgFrameCombined()
    end
end)


--------------------- Commandes Slash pour l'addon ---------------------


-- Définir les slash commandes
SLASH_LFM1 = "/lfm"
SLASH_LFM3 = "/lfm help"
SLASH_LFM5 = "/lfm minimap show"
SLASH_LFM6 = "/lfm minimap hide"

-- Fonction principale des commandes Slash
SlashCmdList["LFM"] = function(msg)
    -- Séparer le message en argument
    local args = strsplit(" ", msg)

    -- Afficher les commandes disponibles
    if args[1] == "help" then
        -- Afficher les commandes disponibles dans le chat avec des couleurs
        DEFAULT_CHAT_FRAME:AddMessage("Commandes disponibles :", 0.0, 1.0, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("- |cffadd8e6/lfm |cffFFFFFFOpens AutoLFM window.")
        DEFAULT_CHAT_FRAME:AddMessage("- |cffadd8e6/lfm help |cffFFFFFFDisplays all available orders.")  -- Bleu clair pour la commande et blanc pour l'explication
        DEFAULT_CHAT_FRAME:AddMessage("- |cffadd8e6/lfm minimap show |cffFFFFFFDisplays the minimap button.")
        DEFAULT_CHAT_FRAME:AddMessage("- |cffadd8e6/lfm minimap hide |cffFFFFFFHide minimap button.")
        return
    end

    -- Commande pour ouvrir la fenêtre AutoLFM
    if args[1] == "" or args[1] == "open" then
        if AutoLFM then
            if AutoLFM:IsVisible() then
                AutoLFM:Hide()  -- Si la fenêtre est visible, la cacher
            else
                AutoLFM:Show()  -- Si la fenêtre est cachée, l'afficher
            end
        end
        return
    end

    -- Commande pour afficher le bouton de la minimap
    if args[1] == "minimap" and args[2] == "show" then
        -- Vérifier si le bouton de la minimap existe et s'il est caché
        if AutoLFMMinimapButton and not AutoLFMMinimapButton:IsVisible() then
            AutoLFMMinimapButton:Show()  -- Afficher le bouton de la minimap
            DEFAULT_CHAT_FRAME:AddMessage("The minimap button has been redisplayed.", 0.0, 1.0, 0.0)  -- Texte vert
        else
            DEFAULT_CHAT_FRAME:AddMessage("The minimap button is already visible.", 1.0, 0.0, 0.0)  -- Texte rouge
        end
        return
    end

        -- Commande pour masquer le bouton de la minimap
    if args[1] == "minimap" and args[2] == "hide" then
        -- Vérifier si le bouton de la minimap existe et est visible
        if AutoLFMMinimapButton and AutoLFMMinimapButton:IsVisible() then
            AutoLFMMinimapButton:Hide()  -- Masquer le bouton
            DEFAULT_CHAT_FRAME:AddMessage("The minimap button has been hidden.", 0.0, 1.0, 0.0)  -- Texte vert
        else
            DEFAULT_CHAT_FRAME:AddMessage("The minimap button is already hidden.", 1.0, 0.0, 0.0)  -- Texte rouge
        end
        return
    end

    -- Si la commande est incorrecte
    DEFAULT_CHAT_FRAME:AddMessage("|cffff7f7f! Usage !  |cffadd8e6/lfm help |cffFFFFFFto list all commands.")  -- Rouge
end


--------------------- Minimap Buton ---------------------


-- Création du bouton de la mini-carte
local AutoLFMMinimapBtn = CreateFrame("Button", "AutoLFMMinimapButton", Minimap)
AutoLFMMinimapBtn:SetWidth(25)  -- Taille du bouton
AutoLFMMinimapBtn:SetHeight(25)  -- Taille du bouton
AutoLFMMinimapBtn:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -5, -5)  -- Positionner le bouton

-- Définir l'icône
AutoLFMMinimapBtn:SetNormalTexture("Interface\\Icons\\INV_Misc_Eye_01")
AutoLFMMinimapBtn:GetNormalTexture():SetTexCoord(0.10, 0.80, 0.10, 0.80)  -- Ajuster le cadrage pour rendre l'icône plus centrée et ronde

-- Créer une bordure ronde
local border = AutoLFMMinimapBtn:CreateTexture(nil, "BACKGROUND")
border:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")  -- Texture de bordure par défaut
border:SetAllPoints(AutoLFMMinimapBtn)
border:SetVertexColor(1, 0.5, 0.5)  -- Couleur rouge clair pour la bordure
border:SetBlendMode("ADD")  -- Pour que la bordure brille un peu, ajoutez l'effet "ADD" pour l'éclat

-- Appliquer des coins arrondis à la bordure
border:SetTexCoord(0, 1, 0, 1)  -- Ajuste la texture de la bordure

-- Ajouter un effet lors du survol de la souris
AutoLFMMinimapBtn:SetScript("OnEnter", function()
    -- Appliquer une brillance à l'icône
    AutoLFMMinimapBtn:GetNormalTexture():SetVertexColor(1, 0.5, 0.5)  -- Rouge clair

    -- Afficher le tooltip
    GameTooltip:SetOwner(AutoLFMMinimapBtn, "ANCHOR_RIGHT")
    GameTooltip:SetText("AutoLFM")
    GameTooltip:AddLine("Click to toggle AutoLFM interface.", 1, 1, 1)
    GameTooltip:AddLine("Ctrl + Click for move.", 1, 1, 1)
    GameTooltip:Show()
end)

-- Réinitialiser la couleur et l'effet lors de la sortie de la souris
AutoLFMMinimapBtn:SetScript("OnLeave", function()
    -- Réinitialiser la couleur de l'icône (retour à la couleur normale)
    AutoLFMMinimapBtn:GetNormalTexture():SetVertexColor(1, 1, 1)  -- Retour à la couleur d'origine (blanc)

    -- Cacher le tooltip
    GameTooltip:Hide()
end)

-- Clic gauche pour ouvrir/fermer l'interface
AutoLFMMinimapBtn:SetScript("OnClick", function()
    -- Vérifier si la touche Ctrl est enfoncée
    if IsControlKeyDown() then
        return 
    end

    -- Si Ctrl n'est pas enfoncé, gérer l'ouverture/fermeture de l'interface
    if AutoLFM:IsShown() then
        AutoLFM:Hide()
    else
        AutoLFM:Show() 
    end
end)

-- Rendre le bouton déplacable avec Ctrl + Clic gauche
AutoLFMMinimapBtn:SetMovable(true)
AutoLFMMinimapBtn:EnableMouse(true)
AutoLFMMinimapBtn:RegisterForDrag("LeftButton")

AutoLFMMinimapBtn:SetScript("OnMouseDown", function(self, button)
    -- Vérifier si Ctrl est maintenu lors du clic
    if IsControlKeyDown() then
        AutoLFMMinimapBtn:StartMoving()
    end
end)

AutoLFMMinimapBtn:SetScript("OnMouseUp", function(self, button)
    -- Arrêter le déplacement du bouton
    AutoLFMMinimapBtn:StopMovingOrSizing()
end)


----------------- Drag and Drop -----------------


-- Fonction pour démarrer le mouvement de la frame et du titre
local function StartMovingFrame(self)
    if AutoLFM:IsShown() then
        AutoLFM:StartMoving()
        title:StartMoving()
    end
end

-- Fonction pour arrêter le mouvement de la frame et du titre
local function StopMovingFrame(self)
    if AutoLFM:IsShown() then
        AutoLFM:StopMovingOrSizing()
        title:StopMovingOrSizing()
    end
end

-- Fonction pour arrêter le mouvement de la frame et du titre quand ils sont cachés
local function StopMovingOnHide(self)
    AutoLFM:StopMovingOrSizing()
    title:StopMovingOrSizing()
end

-- Détecter les événements de déplacement sur la frame principale
AutoLFM:SetScript("OnMouseDown", StartMovingFrame)
AutoLFM:SetScript("OnMouseUp", StopMovingFrame)
AutoLFM:SetScript("OnHide", StopMovingOnHide)

-- Détecter les événements de déplacement sur le titre
title:SetScript("OnMouseDown", StartMovingFrame)
title:SetScript("OnMouseUp", StopMovingFrame)
title:SetScript("OnHide", StopMovingOnHide)

--------------------------- Slash de Control Pour Dev ---------------------------

-- -- Créer la commande Slash pour afficher les rôles sélectionnés

-- local function ShowSelectedRoles()
--     if getTableSize(selectedRoles) == 0 then
--         print("Aucun rôle sélectionné.")
--     else
--         -- Concaténer les rôles sélectionnés en une chaîne séparée par des virgules
--         local rolesText = ""
--         for i, role in ipairs(selectedRoles) do
--             rolesText = rolesText .. role
--             if i < getTableSize(selectedRoles) then
--                 rolesText = rolesText .. ", "
--             end
--         end
--         print("Rôles sélectionnés : " .. rolesText)
--     end
-- end

-- SLASH_ShowRoles1 = "/roles"
-- SlashCmdList["ShowRoles"] = ShowSelectedRoles


-- -- Slash Command pour afficher les rôles sélectionnés
-- SLASH_SHOWROLES1 = "/roles"  -- Nom de la commande Slash
-- SlashCmdList["SHOWROLES"] = function()
--     local rolesText = "Rôles sélectionnés : "

--     -- Compter le nombre total de rôles dans allRoles
--     local totalRoles = countTableEntries(allRoles)

--     -- Vérifier combien de rôles sont sélectionnés
--     local selectedCount = countSelectedRoles(selectedRoles)

--     if selectedCount == totalRoles then
--         -- Si tous les rôles sont sélectionnés
--         rolesText = rolesText .. "All"
--     elseif isTableEmpty(selectedRoles) then
--         -- Si aucun rôle n'est sélectionné
--         rolesText = rolesText .. "Aucun rôle sélectionné."
--     else
--         -- Afficher les rôles sélectionnés
--         for role, _ in pairs(selectedRoles) do
--             rolesText = rolesText .. role .. " "
--         end
--     end

--     -- Afficher le message dans la fenêtre de chat
--     DEFAULT_CHAT_FRAME:AddMessage(rolesText)
-- end


-- -- Slash Command pour afficher les donjons sélectionnés
-- SLASH_GETDUNGEONS1 = "/dgs"  -- Enregistrer la commande /dgs

-- SlashCmdList["GETDUNGEONS"] = function()
--     -- Appeler la fonction pour récupérer les donjons sélectionnés avec leurs abréviations
--     local selected = GetSelectedDungeons()

--     local selectedCount = 0
--     for _, _ in pairs(selected) do
--         selectedCount = selectedCount + 1  -- Compter manuellement les raids sélectionnés
--     end

--     -- Vérifier si des donjons ont été sélectionnés
--     if selectedCount == 0 then
--         -- Message si aucun donjon n'est sélectionné
--         DEFAULT_CHAT_FRAME:AddMessage("Aucun donjon sélectionné.", 1.0, 0.0, 0.0)  -- Rouge
--     else
--         -- Affichage des donjons sélectionnés
--         DEFAULT_CHAT_FRAME:AddMessage("Donjons sélectionnés :", 0.0, 1.0, 0.0)  -- Vert

--         -- Afficher chaque donjon sélectionné (abréviation)
--         for _, donjon in ipairs(selected) do
--             -- Affichage avec un tiret et une couleur personnalisée (ici un bleu clair)
--             DEFAULT_CHAT_FRAME:AddMessage("- " .. donjon, 0.0, 0.6, 1.0)  -- Bleu clair (RGB: 0, 0.6, 1)
--         end
--     end
-- end


-- -- Slash Command pour afficher les raids sélectionnés
-- SLASH_GETRAIDS1 = "/raids"  -- Enregistrer la commande /raids

-- SlashCmdList["GETRAIDS"] = function()
--     -- Appeler la fonction pour récupérer les raids sélectionnés
--     local selected = GetSelectedRaids()

--     -- Vérifier si des raids ont été sélectionnés
--     local selectedCount = 0
--     for _, _ in pairs(selected) do
--         selectedCount = selectedCount + 1  -- Compter manuellement les raids sélectionnés
--     end

--     -- Afficher les raids sélectionnés dans le chat
--     if selectedCount == 0 then
--         DEFAULT_CHAT_FRAME:AddMessage("Aucun raid sélectionné.", 1.0, 0.0, 0.0)  -- Message rouge si aucun raid n'est sélectionné
--     else
--         DEFAULT_CHAT_FRAME:AddMessage("Raids sélectionnés :", 0.0, 1.0, 0.0)  -- Message vert indiquant les raids sélectionnés

--         -- Pour chaque raid sélectionné, afficher avec un tiret et couleur
--         for _, raid in ipairs(selected) do
--             -- Affichage avec un tiret et une couleur personnalisée (ici un bleu clair)
--             DEFAULT_CHAT_FRAME:AddMessage("- " .. raid, 0.0, 0.6, 1.0)  -- Bleu clair (RGB: 0, 0.6, 1)
--         end
--     end
-- end

-- -- Commande dev /inter pour afficher la valeur du slider

-- SLASH_INTER1 = "/inter"
-- SlashCmdList["INTER"] = function()
--     -- Afficher la valeur actuelle du slider dans le chat
--     print("La valeur actuelle du slider est : " .. sliderValue .. " second")
-- end

-- -- -- Enregistrer la commande Slash
-- SLASH_LFMMSG1 = "/lfmm"  -- Nom de la commande, par exemple "/lfmm"
-- -- Fonction qui sera appelée par la commande slash "/lfmm"
-- function showCombinedMessage(msg)
--     -- Générer le message combiné
--     GetCombinedMessage()

--     -- Vérifier si le message est vide
--     if combinedMessage and combinedMessage ~= "" then
--         -- Afficher le message dans la fenêtre de chat
--         DEFAULT_CHAT_FRAME:AddMessage(combinedMessage)
--     else
--         -- Message d'erreur si le message est vide
--         print("Le message combiné est vide ou n'a pas été généré correctement.")
--     end
-- end
-- SlashCmdList["LFMMSG"] = showCombinedMessage

-- -- Commande slash pour afficher le message combiné
-- SLASH_GETCOMBINEDMESSAGE1 = "/msg"
-- function SlashCmdList.GETCOMBINEDMESSAGE(msg)
--     -- Appel à la fonction pour générer le message combiné
--     GetCombinedMessage()

--     print("Combined Message: ", combinedMessage)

--     -- Affichage du message dans le chat
--     DEFAULT_CHAT_FRAME:AddMessage(combinedMessage)
-- end
