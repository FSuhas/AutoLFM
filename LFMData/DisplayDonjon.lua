---------------------------------------------------------------------------------
--                               Donjon Fonction                               --
---------------------------------------------------------------------------------
function DisplayDungeonsByColor()
  -- Cacher les anciens donjons affichés
  for _, child in ipairs({contentFrame:GetChildren()}) do
    child:Hide()
  end

  local playerLevel = UnitLevel("player")
  local yOffset = 0
  local sortedDungeons = {}

  -- Préparer la liste triée avec priorité et index original
  for _, donjon in pairs(donjons) do
    if table.getn(sortedDungeons) >= maxDonjons then break end
    local priority = calculer_priorite(playerLevel, donjon)
    table.insert(sortedDungeons, {donjon = donjon, priority = priority, originalIndex = donjon.originalIndex})
  end

  table.sort(sortedDungeons, function(a, b)
    if a.priority == b.priority then
      return a.originalIndex < b.originalIndex
    else
      return a.priority < b.priority
    end
  end)

  -- Réinitialiser la table des frames pour pouvoir les gérer ailleurs
  donjonClickableFrames = {}

  -- Création des entrées UI pour chaque donjon trié
  for _, entry in ipairs(sortedDungeons) do
    local donjon = entry.donjon
    local priority = entry.priority

    local clickableFrame = CreateFrame("Button", "ClickableDonjonFrame" .. donjon.abrev, contentFrame)
    clickableFrame:SetHeight(20)
    clickableFrame:SetWidth(300)
    clickableFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -yOffset)

    -- Créer la checkbox
    local checkbox = CreateFrame("CheckButton", "DonjonCheckbox" .. donjon.abrev, clickableFrame, "UICheckButtonTemplate")
    checkbox:SetWidth(20)
    checkbox:SetHeight(20)
    checkbox:SetPoint("LEFT", clickableFrame, "LEFT", 0, 0)
    donjonCheckButtons[donjon.abrev] = checkbox

    -- Labels : niveau et nom
    local levelLabel = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    levelLabel:SetPoint("RIGHT", clickableFrame, "RIGHT", -10, 0)
    levelLabel:SetText("(" .. donjon.lvl_min .. " - " .. donjon.lvl_max .. ")")

    local label = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
    label:SetText(donjon.nom)

    -- Couleur selon priorité
    if priority == 4 then
      label:SetTextColor(0.5, 0.5, 0.5)
      levelLabel:SetTextColor(0.5, 0.5, 0.5)
    elseif priority == 1 then
      label:SetTextColor(0, 1, 0)
      levelLabel:SetTextColor(0, 1, 0)
    elseif priority == 2 then
      label:SetTextColor(1, 0.5, 0)
      levelLabel:SetTextColor(1, 0.5, 0)
    else
      label:SetTextColor(1, 0, 0)
      levelLabel:SetTextColor(1, 0, 0)
    end

    -- Mise à jour du fond selon état de la checkbox
    local function UpdateBackdrop()
      if checkbox:GetChecked() then
        clickableFrame:SetBackdrop({
          bgFile = "Interface\\Buttons\\WHITE8X8",
          insets = {left = 1, right = 1, top = 1, bottom = 1},
        })
        clickableFrame:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
      else
        clickableFrame:SetBackdrop(nil)
      end
    end

    -- Click sur la ligne : toggle checkbox et update
    clickableFrame:SetScript("OnClick", function()
        checkbox:SetChecked(not checkbox:GetChecked())
        checkbox:GetScript("OnClick")() -- appel du OnClick de la checkbox
        
        UpdateBackdrop()
    end)

    -- Hover : affiche le fond
    clickableFrame:SetScript("OnEnter", function()
      clickableFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        insets = {left = 1, right = 1, top = 1, bottom = 1},
      })
      clickableFrame:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
      checkbox:LockHighlight()
    end)

    -- Quitte le hover : remet le fond selon checkbox
    clickableFrame:SetScript("OnLeave", function()
      if not checkbox:GetChecked() then
        clickableFrame:SetBackdrop(nil)
      else
        UpdateBackdrop()
      end
      checkbox:UnlockHighlight()
    end)

    -- Script checkbox : gérer sélection max 4 et mise à jour liste
    checkbox:SetScript("OnClick", function()
      local isChecked = checkbox:GetChecked()

      if isChecked then
        rightPanel:Show()
        editBox:Show()
        sliderframe:Show()
        toggleButton:Show()
        msgFrameDj:Show()
        -- Ne pas dupliquer dans la liste selectedDungeons
        local alreadySelected = false
        for _, val in ipairs(selectedDungeons) do
          if val == donjon.abrev then
            alreadySelected = true
            break
          end
        end

        if not alreadySelected then
          -- Limite à 4 sélectionnés
          if table.getn(selectedDungeons) >= 4 then
            local first = selectedDungeons[1]
            table.remove(selectedDungeons, 1)
            if donjonCheckButtons[first] then
              donjonCheckButtons[first]:SetChecked(false)
              donjonCheckButtons[first]:GetParent():SetBackdrop(nil)
            end
          end
          table.insert(selectedDungeons, donjon.abrev)
        end

      else
        -- Retirer si décoché
        for i, val in ipairs(selectedDungeons) do
          if val == donjon.abrev then
            table.remove(selectedDungeons, i)
            break
          end
        end
      end

      UpdateBackdrop()
      updateMsgFrameCombined()
    end)

    -- Stocker le frame pour gestion externe
    table.insert(donjonClickableFrames, clickableFrame)

    -- Décalage pour la prochaine ligne
    yOffset = yOffset + 20
  end
end
