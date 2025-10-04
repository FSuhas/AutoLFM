---------------------------------------------------------------------------------
--                               Fonctions                                     --
---------------------------------------------------------------------------------

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

-- Fonction pour vérifier si un élément est présent dans la table
function tableContains(table, element)
    return table[element] ~= nil  -- Vérification optimisée
end

function tableContains(table, value)
  for _, v in pairs(table) do
      if v == value then
          return true
      end
  end
  return false
end

function CheckRaidStatus()
    if UnitInRaid("player") then
        return true
    else
        return false
    end
end

-- Utilisation avec un frame événement
frame = CreateFrame("Frame")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:SetScript("OnEvent", function()
    CheckRaidStatus()
end)

function tableCount(t)
    count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

--function OnUpdateHandler(self, elapsed)
--    now = GetTime()
--    if now >= nextChange then
--        eyeOpen = not eyeOpen
--        eye:SetTexture(eyeOpen and openTexture or closedTexture)
--        if eyeOpen then
--            nextChange = now + math.random(1, 3)
--        else
--            nextChange = now + 0.15
--        end
--    end
--end

for _, donjon in pairs(donjons) do
  if donjonCount >= maxDonjons then
      break
  end
  donjonCount = donjonCount + 1
end

-- Fonction pour cacher le slider lorsqu'un raid est décoché
function HideSliderForRaid()
    if currentSliderFrame then
        currentSliderFrame:Hide()  -- Masquer le cadre du slider
        currentSliderFrame = nil   -- Réinitialiser la référence
    end
end

-- Fonction pour compter les membres du groupe
function countGroupMembers()
    local groupSize
    groupSize = GetNumPartyMembers() + 1
    return groupSize
end

-- Fonction pour compter les membres du raid
function countRaidMembers()
  local raidSize = GetNumRaidMembers()-- Nombre de membres dans le raid
  return raidSize
end

-- Fonction pour surveiller les changements dans le raid
function OnRaidRosterUpdate()
  countRaidMembers()
  updateMsgFrameCombined()
end

function OnGroupUpdate()
    countGroupMembers()
    updateMsgFrameCombined()
end


-- Fonction pour réinitialiser le message saisi
function resetUserInputMessage()
  userInputMessage = ""  -- Réinitialiser le message saisi
  editBox:SetText(userInputMessage)  -- Mettre à jour l'EditBox
  updateMsgFrameCombined()
end

function GetCombinedMessage()
  return combinedMessage or {}
end

function GetSelectedRoles()
  return selectedRoles or {}
end

function GetSelectedDungeons()
  return selectedDungeons or {}
end

function GetSelectedRaids()
  return selectedRaids or {}
end

function getSelectedRoles()
  return selectedRoles or {}
end

function clearSelectedDungeons()
  -- Décoche toutes les cases des donjons
  for _, donjonCheckbox in pairs(donjonCheckButtons) do
      donjonCheckbox:SetChecked(false)
  end
  selectedDungeons = {}
end

for index, donjon in ipairs(donjons) do
  donjon.originalIndex = index
end


function clearSelectedRaids()
    -- Décoche toutes les cases des raids
    for _, raidCheckbox in pairs(raidCheckButtons) do
        raidCheckbox:SetChecked(false)
    end
    selectedRaids = {}
    -- sliderSizeFrame:Hide()  -- Masquer le slider
end

function ClearAllBackdrops(framesTable)
  for _, frame in pairs(framesTable) do
    if frame.SetBackdrop then
      frame:SetBackdrop(nil)
    end
  end
end

function calculer_priorite(niveau_joueur, donjon)
  -- Priorités :
  -- 1 = vert   (adapté, zone de confort)
  -- 2 = orange (début du range, faisable mais encore un peu bas)
  -- 3 = rouge  (trop faible, quasi infaisable)
  -- 4 = gris   (trop haut, trivial)

  local min = donjon.lvl_min
  local max = donjon.lvl_max

  --------------------------------------------------
  -- Règle 1 : Rouge
  -- Si le joueur est plus d’1 niveau en dessous du niveau minimum
  -- => trop faible pour entrer
  -- Exemple : Donjon 24–32, joueur 22 → Rouge
  --------------------------------------------------
  if niveau_joueur < min then
    return 3
  end

  --------------------------------------------------
  -- Règle 2 : Orange
  -- Si le joueur est entre [min+1] et [min+5]
  -- => il peut y aller, mais reste en début de fourchette (challenge élevé)
  -- Exemple : Donjon 22–30, joueur 25 → Orange
  --------------------------------------------------
  if niveau_joueur <= min + 5 then
    return 2
  end

  --------------------------------------------------
  -- Règle 3 : Vert
  -- Si le joueur est entre [min+6] et [max]
  -- => zone idéale pour ce donjon
  -- Exemple : Donjon 17–24, joueur 25 → Vert
  --------------------------------------------------
  if niveau_joueur <= max - 1 then
    return 1
  end

  --------------------------------------------------
  -- Règle 4 : Gris
  -- Si le joueur est au-dessus du niveau max
  -- => donjon trivial, plus intéressant
  -- Exemple : Donjon 18–23, joueur 25 → Gris
  --------------------------------------------------
  return 4
end


function clearSelectedRoles()
    -- Vider la table selectedRoles
    selectedRoles = getSelectedRoles()

    if tankIcon.selected then
    -- Désélectionner l'icône Tank
      tankIcon.selected = false
      tankIcon:SetBackdrop(nil)  -- Retirer les bordures
      tankIcon.texture:SetAlpha(0.5)  -- Appliquer un effet de fade (transparence)
      tankIcon:SetBackdrop({
          edgeFile = "Interface\\AddOns\\AutoLFM\\icon\\shadow-border.tga",  -- Texture pour l'ombre
          edgeSize = 16,
      })
        -- Supprimer le rôle Tank de la table selectedRoles
      for i, role in ipairs(selectedRoles) do
        if role == "Tank" then
            table.remove(selectedRoles, i)
            break
        end
      end
    end

    if dpsIcon.selected then
    -- Désélectionner l'icône DPS
      dpsIcon.selected = false
      dpsIcon:SetBackdrop(nil)  -- Retirer les bordures
      dpsIcon.texture:SetAlpha(0.5)  -- Appliquer un effet de fade (transparence)
      dpsIcon:SetBackdrop({
          edgeFile = "Interface\\AddOns\\AutoLFM\\icon\\shadow-border.tga",  -- Texture pour l'ombre
          edgeSize = 16,
      })
      -- Supprimer le rôle DPS de la table selectedRoles
      for i, role in ipairs(selectedRoles) do
        if role == "DPS" then
            table.remove(selectedRoles, i)
            break
        end
      end
    end

    if healIcon.selected then
    -- Désélectionner l'icône Heal
      healIcon.selected = false
      healIcon:SetBackdrop(nil)  -- Retirer les bordures
      healIcon.texture:SetAlpha(0.5)  -- Appliquer un effet de fade (transparence)
      healIcon:SetBackdrop({
          edgeFile = "Interface\\AddOns\\AutoLFM\\icon\\shadow-border.tga",  -- Texture pour l'ombre
          edgeSize = 16,
      })
      -- Supprimer le rôle Heal de la table selectedRoles
      for i, role in ipairs(selectedRoles) do
        if role == "Heal" then
            table.remove(selectedRoles, i)
            break
        end
      end
    end
    -- Mettre à jour l'affichage après avoir désélectionné tous les rôles
end

---------------------------------------------------------------------------------
--                           Gestion des Thèmes                               --
---------------------------------------------------------------------------------

function GetCurrentTheme()
    return selectedTheme or "Classic"
end

function LoadTheme(themeName)
    if not themeName or themeName == "" then
        if AutoLFM_SavedVariables and AutoLFM_SavedVariables[uniqueIdentifier] then
            themeName = AutoLFM_SavedVariables[uniqueIdentifier].selectedTheme
        end
        if not themeName or themeName == "" then
            themeName = "Classic"
        end
    end
    
    themeName = string.upper(string.sub(themeName, 1, 1)) .. string.lower(string.sub(themeName, 2))
    
    local themeExists = false
    for _, theme in ipairs(availableThemes) do
        if theme == themeName then
            themeExists = true
            break
        end
    end
    
    if not themeExists then
        DEFAULT_CHAT_FRAME:AddMessage("Theme '" .. themeName .. "' not found. Loading Classic theme.")
        themeName = "Classic"
    end
    
    if AutoLFM_SavedVariables and AutoLFM_SavedVariables[uniqueIdentifier] then
        AutoLFM_SavedVariables[uniqueIdentifier].selectedTheme = themeName
    end
    selectedTheme = themeName
    
    local themeFile = "Interface\\AddOns\\AutoLFM\\LFMUI\\" .. themeName .. ".lua"
    
end
