---------------------------------------------------------------------------------
--                       Cadre Principal AutoLFM classic                       --
---------------------------------------------------------------------------------
searchStartTime = 0

AutoLFM = CreateFrame("Frame", "AutoLFM", UIParent)
AutoLFM:SetWidth(384)
AutoLFM:SetHeight(512)
AutoLFM:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
AutoLFM:EnableMouse(true)
AutoLFM:SetMovable(true)
AutoLFM:RegisterForDrag("LeftButton")
AutoLFM:SetScript("OnDragStart", function(self) this:StartMoving() end)
AutoLFM:SetScript("OnDragStop", function(self) this:StopMovingOrSizing() end)

-- Background Textures (gauche)
tl = AutoLFM:CreateTexture(nil, "ARTWORK")
tl:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-TopLeft")
tl:SetWidth(256)
tl:SetHeight(256)
tl:SetPoint("TOPLEFT", 0, 0)

tr = AutoLFM:CreateTexture(nil, "ARTWORK")
tr:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-TopRight")
tr:SetWidth(128)
tr:SetHeight(256)
tr:SetPoint("TOPRIGHT", 0, 0)

bl = AutoLFM:CreateTexture(nil, "ARTWORK")
bl:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-BotLeft")
bl:SetWidth(256)
bl:SetHeight(256)
bl:SetPoint("BOTTOMLEFT", 0, 0)

br = AutoLFM:CreateTexture(nil, "ARTWORK")
br:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-BotRight")
br:SetWidth(128)
br:SetHeight(256)
br:SetPoint("BOTTOMRIGHT", 0, 0)

-- Icon (Overlay)
ring = AutoLFM:CreateTexture("AutoLFMSpellbookRing", "OVERLAY")
ring:SetTexture("Interface\\AddOns\\AutoLFM\\icon\\ring.png")
ring:SetWidth(52)
ring:SetHeight(52)
ring:SetPoint("TOPLEFT", 13, -11)
ring:SetTexCoord(0.08, 0.92, 0.08, 0.92)

-- Right Panel
rightPanel = CreateFrame("Frame", "AutoLFM_RightPanel", AutoLFM)
rightPanel:SetWidth(384)
rightPanel:SetHeight(512)
rightPanel:SetPoint("TOPLEFT", AutoLFM, "TOPRIGHT", -46, 0)
rightPanel:Hide() -- Hide the right panel by default

rt_tl = rightPanel:CreateTexture(nil, "ARTWORK")
rt_tl:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-BotLeft")
rt_tl:SetWidth(256)
rt_tl:SetHeight(256)
rt_tl:SetPoint("TOPLEFT", rightPanel, "TOPLEFT")
rt_tl:SetTexCoord(0, 1, 1, 0)

rt_tr = rightPanel:CreateTexture(nil, "ARTWORK")
rt_tr:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-BotRight")
rt_tr:SetWidth(128)
rt_tr:SetHeight(256)
rt_tr:SetPoint("TOPRIGHT", rightPanel, "TOPRIGHT")
rt_tr:SetTexCoord(0, 1, 1, 0)

rt_bl = rightPanel:CreateTexture(nil, "ARTWORK")
rt_bl:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-BotLeft")
rt_bl:SetWidth(256)
rt_bl:SetHeight(256)
rt_bl:SetPoint("BOTTOMLEFT", rightPanel, "BOTTOMLEFT")

rt_br = rightPanel:CreateTexture(nil, "ARTWORK")
rt_br:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-BotRight")
rt_br:SetWidth(128)
rt_br:SetHeight(256)
rt_br:SetPoint("BOTTOMRIGHT", rightPanel, "BOTTOMRIGHT")


eyeOpen = true
eye = AutoLFM:CreateTexture(nil, "OVERLAY")
eye:SetWidth(52)
eye:SetHeight(52)
eye:SetPoint("TOPLEFT", 13, -11)
eye:SetTexture(openTexture)


-- Close Button
closeBtn = CreateFrame("Button", "AutoLFMCloseButton", AutoLFM, "UIPanelCloseButton")
closeBtn:SetWidth(32)
closeBtn:SetHeight(32)
closeBtn:SetPoint("TOPRIGHT", -28, -9)

showArrowBtn = nil
closeArrowTex = nil

-- Bouton flèche pour fermer rightPanel (flèche vers la gauche)
closeBtn = CreateFrame("Button", "AutoLFMCloseButton", rightPanel)
closeBtn:SetWidth(20)
closeBtn:SetHeight(60)
closeBtn:SetPoint("TOPRIGHT", rightPanel, "TOPRIGHT", -15, -225)

closeArrowTex = closeBtn:CreateTexture(nil, "OVERLAY")
closeArrowTex:SetAllPoints()
closeArrowTex:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up") -- flèche vers la gauche

-- Maintenant création du bouton flèche
showArrowBtn = CreateFrame("Button", nil, AutoLFM)
showArrowBtn:SetWidth(20)
showArrowBtn:SetHeight(60)
showArrowBtn:SetPoint("RIGHT", AutoLFM, "RIGHT", -15, 0)
showArrowBtn:Show()

arrowTex = showArrowBtn:CreateTexture(nil, "OVERLAY")
arrowTex:SetAllPoints()
arrowTex:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")

-- Créer cadre roleframe dans la frame de droite
roleframe = CreateFrame("Frame", nil, AutoLFM_RightPanel)
roleframe:SetBackdrop({
    bgFile = nil,
    -- edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",  -- Bordure visible (optionnelle)
    edgeSize = 16,
    insets = { left = 4, right = 2, top = 4, bottom = 4 },
})
roleframe:SetBackdropColor(1, 1, 1, 0.3)
roleframe:SetBackdropBorderColor(1, 1, 1, 1)

-- Positionner le roleframe
roleframe:SetWidth(AutoLFM_RightPanel:GetWidth()- 60)
roleframe:SetHeight(AutoLFM_RightPanel:GetHeight() / 6)
roleframe:SetPoint("TOPLEFT", AutoLFM_RightPanel, "TOPLEFT", 20, -100)

msgFrame = CreateFrame("Frame", nil, AutoLFM)

-- Positionner le cadre msgFrame juste en dessous de roleframe
msgFrame:SetWidth(roleframe:GetWidth())
msgFrame:SetHeight(roleframe:GetHeight() + 20)
msgFrame:SetPoint("TOPRIGHT", roleframe, "BOTTOMRIGHT", 0, -5)

-- Créer un bouton Toggle en dessous de msgFrame, centré par rapport à AutoLFM
toggleButton = CreateFrame("Button", "ToggleButton", msgFrame, "UIPanelButtonTemplate")
toggleButton:SetWidth(120)
toggleButton:SetHeight(30)

-- Positionner le bouton en bas centré, sous roleframe et msgFrame par rapport à AutoLFM
toggleButton:SetPoint("CENTER", msgFrame, "CENTER", 0, -10)  -- Placer 10 pixels sous msgFrame
toggleButton:SetPoint("BOTTOM", AutoLFM, -10, 40)

toggleButton:SetText("Start")


AutoLFM:SetScript("OnShow", function(self)
    nextChange = GetTime() + math.random(1, 3) -- init timer
    this:SetScript("OnUpdate", OnUpdateHandler)
end)

AutoLFM:SetScript("OnHide", function(self)
    this:SetScript("OnUpdate", nil) -- stop OnUpdate quand caché
end)

-- Titre : Conteneur invisible pour positionner les segments
title = CreateFrame("Frame", nil, AutoLFM)
title:SetWidth(384)
title:SetHeight(40)
title:SetPoint("TOP", AutoLFM, "TOP", 0, 20)  -- Décale légèrement au-dessus du cadre principal

-- Segments de texte
titleSegments = {}

part1 = title:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
part1:SetText("|cff0070DDL|r")
part1:SetFont("Fonts\\SKURRI.TTF", 24, "OUTLINE")
table.insert(titleSegments, part1)

part2 = title:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
part2:SetText("F")
part2:SetFont("Fonts\\SKURRI.TTF", 24, "OUTLINE")
part2:SetTextColor(1, 1, 1)
table.insert(titleSegments, part2)

part3 = title:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
part3:SetText("|cffff0000M|r")
part3:SetFont("Fonts\\SKURRI.TTF", 24, "OUTLINE")
table.insert(titleSegments, part3)

-- Positionnement centré horizontal
totalWidth = 0
for _, segment in ipairs(titleSegments) do
    segment:Show()
    totalWidth = totalWidth + segment:GetStringWidth() + 5
end

currentX = -totalWidth / 2
for _, segment in ipairs(titleSegments) do
    segment:ClearAllPoints()
    segment:SetPoint("CENTER", title, "CENTER", currentX, 0)
    currentX = currentX + segment:GetStringWidth() + 5
end


---------------------------------------------------------------------------------
--                                Donjons                                      --
---------------------------------------------------------------------------------


-- Créer cadre djframe
djframe = CreateFrame("Frame", nil, AutoLFM)
djframe:SetWidth(265)
djframe:SetHeight(380)
djframe:SetPoint("TOPLEFT", AutoLFM, "TOPLEFT", 10, -10)
djframe:SetBackdrop({
    edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", edgeSize = 16,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})

djScrollFrame = CreateFrame("ScrollFrame", "AutoLFM_ScrollFrame_Dungeons", djframe, "UIPanelScrollFrameTemplate")
djScrollFrame:SetPoint("TOPLEFT", djframe, "TOPLEFT", 20, -80)
djScrollFrame:SetWidth(280)
djScrollFrame:SetHeight(330)

-- Créer le contenu du ScrollFrame pour les donjons
contentFrame = CreateFrame("Frame", nil, djScrollFrame)
contentFrame:SetWidth(250)
contentFrame:SetHeight(donjonCount * 30)  -- Hauteur dynamique basée sur le nombre de donjons
djScrollFrame:SetScrollChild(contentFrame)


---------------------------------------------------------------------------------
--                                  Raids                                      --
---------------------------------------------------------------------------------


-- Créer cadre raidFrame
raidFrame = CreateFrame("Frame", nil, AutoLFM)
raidFrame:SetWidth(265)
raidFrame:SetHeight(380)
raidFrame:SetPoint("TOPLEFT", AutoLFM, "TOPLEFT", 10, -10)
raidFrame:SetBackdrop({
    edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", edgeSize = 16,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})

raidScrollFrame = CreateFrame("ScrollFrame", "AutoLFM_ScrollFrame_Raids", raidFrame, "UIPanelScrollFrameTemplate")
raidScrollFrame:SetPoint("TOPLEFT", raidFrame, "TOPLEFT", 20, -80)
raidScrollFrame:SetWidth(280)
raidScrollFrame:SetHeight(330)


---------------------------------------------------------------------------------
--                                 Roles                                       --
---------------------------------------------------------------------------------


-- Ajouter un texte au-dessus des icônes
selectRoleText = roleframe:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
selectRoleText:SetText("Choose the role(s) you need")
selectRoleText:SetPoint("BOTTOM", roleframe, "TOP", 0, 5)
selectRoleText:SetJustifyH("CENTER")
selectRoleText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")


---------------------------------------------------------------------------------
--                         Message Frame Donjons                               --
---------------------------------------------------------------------------------


msgFrameDj = CreateFrame("Frame", nil, AutoLFM)

-- Positionner le cadre msgFrameDj juste en dessous de roleframe
msgFrameDj:SetWidth(roleframe:GetWidth())
msgFrameDj:SetHeight(roleframe:GetHeight() + 20)
msgFrameDj:SetPoint("TOPRIGHT", roleframe, "BOTTOMRIGHT", 0, 0)


-- Créer un FontString dans msgFrameDj pour afficher le message
msgTextDj = msgFrameDj:CreateFontString(nil, "OVERLAY", "GameFontNormal")
msgTextDj:SetPoint("CENTER", msgFrameDj, "CENTER")
msgTextDj:SetTextColor(1, 1, 1)
msgTextDj:SetJustifyH("CENTER")
msgTextDj:SetJustifyV("CENTER")
msgTextDj:SetWidth(msgFrameDj:GetWidth())


---------------------------------------------------------------------------------
--                          Message Frame Raids                                --
---------------------------------------------------------------------------------


msgFrameRaids = CreateFrame("Frame", nil, AutoLFM)

-- Positionner le cadre msgFrameRaids juste en dessous de roleframe
msgFrameRaids:SetWidth(roleframe:GetWidth())
msgFrameRaids:SetHeight(roleframe:GetHeight() + 20)
msgFrameRaids:SetPoint("TOPRIGHT", roleframe, "BOTTOMRIGHT", 0, 0)

msgFrameRaids:Hide()

-- Créer un FontString dans msgFrame pour afficher le message
msgTextRaids = msgFrameRaids:CreateFontString(nil, "OVERLAY", "GameFontNormal")
msgTextRaids:SetPoint("CENTER", msgFrameRaids, "CENTER")
msgTextRaids:SetTextColor(1, 1, 1)
msgTextRaids:SetJustifyH("CENTER")
msgTextRaids:SetJustifyV("CENTER")
msgTextRaids:SetWidth(msgFrameRaids:GetWidth())


---------------------------------------------------------------------------------
--                                EditBox                                      --
---------------------------------------------------------------------------------


-- Créer une zone de saisie de texte en bas de msgFrame
editBox = CreateFrame("EditBox", "MonAddonEditBox", msgFrame)
editBox:SetPoint("BOTTOM", msgFrame, "BOTTOM", 0, -60)  -- Positionner en bas, avec un écart de 10 pixels du bas du cadre

-- Définir les propriétés de la zone de texte sans spécifier la taille
editBox:SetAutoFocus(false)  -- Empêcher le focus automatique
editBox:SetFont("Fonts\\FRIZQT__.TTF", 16)  -- Police de texte normale
editBox:SetMaxLetters(150)  -- Limiter le nombre de caractères
editBox:SetText("")  -- Texte initial (vide)
editBox:SetTextInsets(10, 10, 10, 10)  -- Marge interne de 10 pixels

-- Adapter la largeur de la zone de texte à la largeur de msgFrame moins une marge (pour éviter que le texte soit collé aux bords)
editBox:SetWidth(msgFrame:GetWidth() - 30)  -- Largeur légèrement réduite par rapport à msgFrame

-- Définir une hauteur fixe pour la zone de saisie (sans SetSize)
editBox:SetHeight(30)  -- Hauteur fixe de la zone de saisie

-- Fonction pour gérer l'appui sur "Entrée"
editBox:SetScript("OnEnterPressed", function(self)
this:ClearFocus()  -- Retirer le focus de la zone de texte
end)

editBox:SetScript("OnEscapePressed", function(self)
this:ClearFocus()  -- Retirer le focus de la zone de texte
end)

-- Créer un texte pour afficher un tiret centré au-dessus de la zone de saisie
dashText = msgFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
dashText:SetPoint("BOTTOM", editBox, "TOP", 0, 8)  -- Placer au-dessus de editBox avec un écart de 5 pixels
dashText:SetText("Add details (optional)")  -- Le texte du tiret

-- Personnaliser l'apparence du tiret (par exemple, couleur et taille de police)
dashText:SetFontObject(GameFontNormal)  -- Utiliser la police de texte normale
dashText:SetTextColor(1, 1, 1, 1)  -- Couleur blanche pour le tiret

-- Optionnel : ajouter un fond à la zone de saisie pour la rendre plus visible
editBox:SetBackdrop({
bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
edgeSize = 12,
insets = { left = 5, right = 5, top = 5, bottom = 5 },
})
editBox:SetTextColor(1, 1, 1)  -- Couleur du texte blanc

function CreateQuestLink(questIndex)
    if not AutoLFM or not AutoLFM:IsVisible() then
        return -- autoLFM fermé, ne fait rien
    end
    local title, level, _, _, _, _, _, questID = GetQuestLogTitle(questIndex)
    if not title or title == "" then return nil end
    if not questID then
        -- En 1.12, questID est souvent nil, mais on peut essayer d'extraire autrement (limité)
        questID = 0
    end
    -- Construire le lien (format 1.12)
    local color = "|cffffff00"  -- jaune, couleur des quêtes
    local link = string.format("%s|Hquest:%d:%d|h[%s]|h|r", color, questID, level or 0, title)
    return link
end

local editBoxHasFocus = false

editBox:SetScript("OnEditFocusGained", function(self)
    editBoxHasFocus = true
end)

editBox:SetScript("OnEditFocusLost", function(self)
    editBoxHasFocus = false
end)


-- Sauvegarder la fonction d'origine
Original_QuestLogTitleButton_OnClick = QuestLogTitleButton_OnClick

-- Surcharge de QuestLogTitleButton_OnClick
function QuestLogTitleButton_OnClick(self, button)

    Original_QuestLogTitleButton_OnClick(self, button)

    if "LeftButton" and IsShiftKeyDown() and editBox and editBoxHasFocus then
        local questIndex = this:GetID()
        if questIndex then
            local questLink = CreateQuestLink(questIndex)
            if questLink then
                editBox:SetText(questLink)
                editBox:SetFocus()
            end
        end
    end
end

-- On sauvegarde la fonction d'origine OnClick des boutons d'item du sac
Original_ContainerFrameItemButton_OnClick = ContainerFrameItemButton_OnClick

function ContainerFrameItemButton_OnClick(self, button)
    -- Appeler la fonction originale (ouvrir tooltip, etc.)
    Original_ContainerFrameItemButton_OnClick(self, button)

    if "LeftButton" and IsShiftKeyDown() and editBox and editBoxHasFocus then
        local bag = this:GetParent():GetID()
        local slot = this:GetID()
        local itemLink = GetContainerItemLink(bag, slot)
        if itemLink then
            if editBox then
                editBox:SetText(itemLink)
                editBox:SetFocus()
            end
        end
    end
end

-- Sauvegarder la fonction d'origine
Original_SetItemRef = SetItemRef

-- Nouvelle fonction pour intercepter les clics sur les liens
function SetItemRef(link, text, button, chatFrame)

    Original_SetItemRef(link, text, button, chatFrame)

    -- Vérifier clic gauche + Shift + lien d'item
    if "LeftButton" and IsShiftKeyDown() and editBox and editBoxHasFocus then
        -- En 1.12, les liens d'item commencent souvent par "item:"
        if link and string.find(link, "^item:") then
            if editBox then
                editBox:SetText(text)
                editBox:SetFocus()
            end
        end
    end
end


---------------------------------------------------------------------------------
--                                 Slider                                      --
---------------------------------------------------------------------------------


-- Créer cadre sliderframe
sliderframe = CreateFrame("Frame", nil, AutoLFM)
sliderframe:SetBackdrop({
    bgFile = nil,
    edgeSize = 16,  -- Taille de la bordure
    insets = { left = 4, right = 2, top = 4, bottom = 4 },
})
sliderframe:SetBackdropColor(1, 1, 1, 0.3)
sliderframe:SetBackdropBorderColor(1, 1, 1, 1)

-- Positionner le nouveau cadre juste en dessous de roleframe
sliderframe:SetWidth(roleframe:GetWidth())
sliderframe:SetHeight(roleframe:GetHeight() + 50)
sliderframe:SetPoint("TOPRIGHT", msgFrame, "BOTTOMRIGHT", 0, -40)

-- Créer la barre de glissement (Slider)
slider = CreateFrame("Slider", nil, sliderframe, "OptionsSliderTemplate")
slider:SetWidth(200)
slider:SetHeight(20)
slider:SetPoint("CENTER", sliderframe, "CENTER", 0, 0)
slider:SetMinMaxValues(40, 120)
slider:SetValue(80)
slider:SetValueStep(10)

--------------------------- SLIDER DE TAILLE ---------------------------

-- Créer un cadre pour le slider
sliderSizeFrame = CreateFrame("Frame", nil, msgFrame)
sliderSizeFrame:SetBackdropColor(1, 1, 1, 0.3)
sliderSizeFrame:SetBackdropBorderColor(1, 1, 1, 1)
sliderSizeFrame:SetWidth(220)  -- Largeur du slider
sliderSizeFrame:SetHeight(100)  -- Hauteur du cadre (augmentée pour laisser de la place au texte supplémentaire)
sliderSizeFrame:SetPoint("CENTER", msgFrame, "CENTER", 290, 120)  -- Positionner le cadre en bas au centre du panneau principal

sliderSizeFrame:SetBackdrop{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 12,
    insets = { left = 5, right = 5, top = 5, bottom = 5 },
}

sliderSizeFrame:Hide()  -- Masquer le cadre au départ

-- Créer le slider
sliderSize = CreateFrame("Slider", nil, sliderSizeFrame, "OptionsSliderTemplate")
sliderSize:SetWidth(200)
sliderSize:SetHeight(20)
sliderSize:SetPoint("CENTER", sliderSizeFrame, "CENTER", 0, 0)

-- Initialiser la valeur
sliderSize:SetValueStep(1)  -- Pas de valeur du slider

-- Variable globale pour stocker la valeur du slider
sliderValue = 0

-- Variable pour stocker la référence du slider
currentSliderFrame = nil
sliderValueText = nil  -- Texte pour afficher la plage
sliderCurrentValueText = nil  -- Texte pour afficher la valeur actuelle

-- Fonction pour mettre à jour le texte en fonction de la valeur du slider
function UpdateSliderText(value)
    if value then  -- Vérifier que value est défini et est un nombre
        local minValue, maxValue = sliderSize:GetMinMaxValues()

        -- Afficher la plage de valeurs du slider
        sliderValueText:SetText(value)

        -- Afficher la valeur actuelle du slider
        sliderCurrentValueText:SetText("Raid Size: " .. minValue .. " at " .. maxValue)
    else
        -- Afficher un message par défaut si la valeur est nil
        sliderValueText:SetText("Raid Size: N/A")
        sliderCurrentValueText:SetText("Valeur actuelle: N/A")
    end
end


-- Fonction pour afficher le slider pour un raid sélectionné
function ShowSliderForRaid(raid)

    if currentSliderFrame then
        currentSliderFrame:Hide()  -- Masquer le précédent slider
    end

    -- Vérifier si les valeurs de raid sont valides
    if not raid.size_min or not raid.size_max then
        print("Erreur: Les valeurs size_min ou size_max ne sont pas définies correctement.")
        return
    end

    -- Créer les textes si ils n'existent pas encore
    if not sliderValueText then
        sliderValueText = sliderSizeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        sliderValueText:SetPoint("CENTER", sliderSize, "TOP", 0, 10)
    end

    if not sliderCurrentValueText then
        sliderCurrentValueText = sliderSizeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        sliderCurrentValueText:SetPoint("CENTER", sliderSize, "BOTTOM", 0, -10)  -- Placer sous le slider
    end

    -- Définir les valeurs min et max pour le slider en fonction du raid sélectionné
    sliderSize:SetMinMaxValues(raid.size_min, raid.size_max)

    -- **Vérification de la valeur initiale** (on la force à la valeur précédemment sauvegardée ou à la valeur par défaut)
    local initialSliderValue = sliderValue ~= 0 and sliderValue or raid.size_min  -- Si une valeur est déjà enregistrée, on l'utilise
    sliderSize:SetValue(initialSliderValue)  -- Définir la valeur initiale

    -- Mettre à jour le texte avec la valeur actuelle
    UpdateSliderText(sliderSize:GetValue())

    -- Afficher le cadre du slider
    if AutoLFM and AutoLFM:IsShown() then
        sliderSizeFrame:Show()
    end

    -- Sauvegarder la référence du slider pour pouvoir le masquer plus tard
    currentSliderFrame = sliderSizeFrame
end

-- Mettre à jour le texte chaque fois que la valeur du slider change
sliderSize:SetScript("OnValueChanged", function(value)
    sliderValue = value  -- Sauvegarder la nouvelle valeur du slider
    UpdateSliderText(value)  -- Mettre à jour le texte avec la valeur actuelle
end)

-- Fonction pour gérer le changement de texte
editBox:SetScript("OnTextChanged", function(self)
-- print("Texte saisi : " .. this:GetText())  -- Afficher le texte dans la console
userInputMessage = this:GetText()
    -- Vérifier si un message saisi existe
if userInputMessage ~= "" then
    return updateMsgFrameCombined(userInputMessage)
end
updateMsgFrameCombined()
end)


-- Mettre à jour le texte chaque fois que la valeur du slider change
sliderSize:SetScript("OnValueChanged", function(value)
    value = sliderSize:GetValue()  -- Obtenir la valeur actuelle du slider
    sliderValue = value  -- Sauvegarder la nouvelle valeur du slider
    UpdateSliderText(sliderValue)  -- Mettre à jour le texte avec la valeur actuelle
    updateMsgFrameCombined()
end)

-- Créer le contenu du ScrollFrame pour les raids
raidContentFrame = CreateFrame("Frame", nil, raidScrollFrame)
raidContentFrame:SetWidth(raidFrame:GetWidth())
raidContentFrame:SetHeight(raidFrame:GetHeight())
raidScrollFrame:SetScrollChild(raidContentFrame)


---------------------------------------------------------------------------------
--                               Swap Bouton                                   --
---------------------------------------------------------------------------------


-- Swap View Button
swapBtn = CreateFrame("Button", "AutoLFMSwapButton", AutoLFM, "UIPanelButtonTemplate")
swapBtn:SetWidth(120)
swapBtn:SetHeight(30)
swapBtn:SetPoint("BOTTOM", -10, 40)
swapBtn:SetText("Raids List")

swapBtn:SetScript("OnClick", function()
    if djScrollFrame:IsShown() then
        -- Basculer en mode raids
        djScrollFrame:Hide()
        swapBtn:SetText("Dungeons List")
        raidFrame:Show()
        raidContentFrame:Show()
        raidScrollFrame:Show()
        msgFrameDj:Hide()
        msgFrameRaids:Show()
        clearSelectedDungeons()
        clearSelectedRoles()
        resetUserInputMessage()
        updateMsgFrameCombined()
        swapChannelFrame()
        ClearAllBackdrops(donjonClickableFrames)
    else
        -- Basculer en mode donjons
        swapBtn:SetText("Raids List")
        djScrollFrame:Show()
        raidFrame:Hide()
        raidContentFrame:Hide()
        raidScrollFrame:Hide()
        msgFrameDj:Show()
        msgFrameRaids:Hide()
        clearSelectedRaids()
        clearSelectedRoles()
        resetUserInputMessage()
        updateMsgFrameCombined()
        HideSliderForRaid()
        swapChannelFrame()
        ClearAllBackdrops(raidClickableFrames)
    end
end)


closeBtn:SetScript("OnClick", function()
    rightPanel:Hide()
    showArrowBtn:Show()
    editBox:Hide()
    sliderframe:Hide()
    toggleButton:Hide()
    msgFrameDj:Hide()
    msgFrameRaids:Hide()
    dashText:Hide()
    sliderSizeFrame:Hide()
    if selectedRaids[1] then
        -- Si un raid est sélectionné, masquer le sliderSizeFrame
        sliderSizeFrame:Hide()
    end
    UpdateChannelsFramePosition()
    swapChannelFrame()
end)

showArrowBtn:SetScript("OnClick", function()
    rightPanel:Show()
    showArrowBtn:Hide()
    editBox:Show()
    sliderframe:Show()
    toggleButton:Show()
    msgFrameDj:Show()
    msgFrameRaids:Show()
    dashText:Show()
    if selectedRaids[1] then
        -- Si un raid est sélectionné, afficher le sliderSizeFrame
        sliderSizeFrame:Show()
    else
        sliderSizeFrame:Hide()  -- Sinon, le cacher
    end
    UpdateChannelsFramePosition()
    swapChannelFrame()
end)


---------------------------------------------------------------------------------
--                               Slider Frame                                  --
---------------------------------------------------------------------------------


-- Valeur de pas fixe pour arrondir
step = 10

-- Fonction pour arrondir la valeur du slider à l'étape la plus proche
function SnapToStep(value)
    if value then
        local roundedValue = math.floor(value / step + 0.5) * step
        return roundedValue
    end
end

-- Variable pour stocker la valeur du slider
sliderValue = 80

-- Créer une police pour afficher la valeur actuelle du slider (placer la valeur au-dessus du slider)
valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
valueText:SetPoint("BOTTOM", slider, "TOP", 0, 5)
valueText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")

-- Mettre à jour la valeur du slider
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
end)


---------------------------------------------------------------------------------
--                              Toggle Bouton                                  --
---------------------------------------------------------------------------------


-- Fonction pour gérer le changement d'état du bouton et démarrer/arrêter la diffusion
toggleButton:SetScript("OnClick", function()
    -- Vérifier si le message combiné est vide ou ne contient que des espaces
    if combinedMessage == " " or combinedMessage == "" then
        -- Si le message est vide, ne pas démarrer la diffusion
        if not isBroadcasting then
            print("The message is empty. The broadcast cannot begin.")
            -- Ne pas changer le texte du bouton si la diffusion ne commence pas
            return
        end
    end

    -- Vérifier la validité des canaux avant de commencer la diffusion
    local allChannelsValid = true  -- Indicateur pour vérifier si tous les canaux sont valides
    for channelName, _ in pairs(selectedChannels) do
        -- Ignorer "Hardcore" lors de la vérification
        if channelName ~= "Hardcore" then
            local channelId = GetChannelName(channelName)
            if not (channelId and channelId > 0) then
                allChannelsValid = false
                break  -- Arrêter dès qu'un canal invalide est trouvé
            end
        end
    end

    -- Si tous les canaux sont valides (en ignorant "Hardcore"), démarrer la diffusion
    if allChannelsValid then
        if isBroadcasting then
            stopMessageBroadcast()
            toggleButton:SetText("Start")  -- Réinitialiser le texte à "Start" si on arrête
            PlaySoundFile("Interface\\AddOns\\AutoLFM\\sound\\LFG_Denied.ogg")
            searchStartTime = 0  -- AJOUT : Réinitialiser quand on arrête
        else
            swapChannelFrame()
            startMessageBroadcast()
            toggleButton:SetText("Stop")  -- Changer le texte à "Stop" lorsqu'on commence
            PlaySoundFile("Interface\\AddOns\\AutoLFM\\sound\\LFG_RoleCheck.ogg")
            searchStartTime = GetTime()  -- AJOUT : Enregistrer le début de la recherche
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("2112 : Broadcast has not started because one or more channels are invalid.")
    end
end)


AutoLFM:RegisterEvent("PARTY_MEMBERS_CHANGED")
AutoLFM:RegisterEvent("GROUP_ROSTER_UPDATE")
AutoLFM:RegisterEvent("RAID_ROSTER_UPDATE")


AutoLFM:SetScript("OnEvent", function(self, event, ...)
    if "RAID_ROSTER_UPDATE" then
        OnRaidRosterUpdate()
    end
end)

AutoLFM:SetScript("OnEvent", function(self, event, ...)
    if "GROUP_ROSTER_UPDATE" then
        local raid = selectedRaids[1]  -- Récupérer le raid sélectionné
        local donjon = selectedDungeons[1]  -- Récupérer le donjon sélectionné
        if raid ~= nil then
            raidSize = value
            local totalPlayersInRaid = countRaidMembers()  -- Récupérer le nombre total de membres du groupe
            if raidSize == totalPlayersInRaid then
                stopMessageBroadcast()  -- Si le groupe a atteint la taille du raid, arrêter la diffusion
                clearSelectedRaids() -- Effacer les donjons sélectionnés
                clearSelectedRoles()  -- Effacer les rôles sélectionnés
                resetUserInputMessage()  -- Réinitialiser le message d'entrée utilisateur
                updateMsgFrameCombined()  -- Mettre à jour le message combiné
                toggleButton:SetText("Start")  -- Réinitialiser le texte du bouton à "Start"
                PlaySoundFile("Interface\\AddOns\\AutoLFM\\sound\\LFG_Denied.ogg")  -- Jouer le son d'arrêt
            else
                OnGroupUpdate()  -- Mettre à jour le groupe
            end
        elseif donjon ~= nil then
            donjonSize = 5
            local totalPlayersInRaid = countGroupMembers()  -- Récupérer le nombre total de membres du groupe
            if donjonSize == totalPlayersInRaid then
                stopMessageBroadcast()  -- Si le groupe a atteint la taille du donjon, arrêter la diffusion
                clearSelectedDungeons()  -- Effacer les donjons sélectionnés
                clearSelectedRoles()  -- Effacer les rôles sélectionnés
                resetUserInputMessage()  -- Réinitialiser le message d'entrée utilisateur
                updateMsgFrameCombined()  -- Mettre à jour le message combiné
                toggleButton:SetText("Start")  -- Réinitialiser le texte du bouton à "Start"
                PlaySoundFile("Interface\\AddOns\\AutoLFM\\sound\\LFG_Denied.ogg")  -- Jouer le son d'arrêt
            else
                OnGroupUpdate()  -- Mettre à jour le groupe
            end
        end
    end
end)

