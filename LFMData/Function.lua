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

function OnUpdateHandler(self, elapsed)
    now = GetTime()
    if now >= nextChange then
        eyeOpen = not eyeOpen
        eye:SetTexture(eyeOpen and openTexture or closedTexture)
        if eyeOpen then
            nextChange = now + math.random(1, 3)
        else
            nextChange = now + 0.15
        end
    end
end

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
  local diff_min = niveau_joueur - donjon.lvl_min  -- Différence par rapport au niveau minimum du donjon
  local diff_max = niveau_joueur - donjon.lvl_max  -- Différence par rapport au niveau maximum du donjon

  local priority

  if diff_min > 7 then
      priority = 4  -- Gris : trop élevé, le joueur a plus de 7 niveaux au-dessus du donjon
  elseif diff_min >= 3 then
      priority = 1  -- Vert : adapté, joueur est à +2 niveaux du niveau minimum du donjon
  elseif diff_min >= 1 then
      priority = 2  -- Orange : légèrement en dessous, joueur à 1 niveau en dessous du niveau minimum
  elseif diff_min < 0 and math.abs(diff_min) > 5 then
      priority = 3  -- Rouge : trop faible, joueur a plus de 5 niveaux en dessous du donjon
  else
      priority = 3  -- Rouge : situation où le joueur est trop faible mais moins de 5 niveaux en dessous
  end

  return priority
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
