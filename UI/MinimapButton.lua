-- Déclaration globale pour le bouton minimap
AutoLFMMinimapBtn = nil

-- Fonction d'initialisation du bouton minimap
function InitMinimapButton()
    local isHidden = AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnHidden

    if AutoLFMMinimapBtn then
        if isHidden then
            HideUIPanel(AutoLFM)
        else
            ShowUIPanel(AutoLFM)
        end
        return
    end

    AutoLFMMinimapBtn = CreateFrame("Button", "AutoLFMMinimapBtn", Minimap)
    AutoLFMMinimapBtn:SetFrameStrata("LOW")
    AutoLFMMinimapBtn:SetHeight(24)
    AutoLFMMinimapBtn:SetWidth(24)

    local posX = AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnX or -10
    local posY = AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnY or -10
    AutoLFMMinimapBtn:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", posX, posY)

    -- Bordure
    local borderTexture = AutoLFMMinimapBtn:CreateTexture(nil, "BORDER")
    borderTexture:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    borderTexture:SetHeight(54)
    borderTexture:SetWidth(54)
    borderTexture:SetPoint("TOPLEFT", -4, 3)

    -- Icône
   AutoLFMMinimapBtn:SetNormalTexture(texturePath .. "Eyes\\eye01")
   AutoLFMMinimapBtn:GetNormalTexture():SetTexCoord(0.0, 1.0, 0.0, 1.0)

    -- Survol
    AutoLFMMinimapBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- Clic
    AutoLFMMinimapBtn:SetPushedTexture(texturePath .. "Eyes\\eye04")

    -- Tooltip sur survol
    AutoLFMMinimapBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(AutoLFMMinimapBtn, "ANCHOR_RIGHT")
        GameTooltip:SetText("Auto|cff0070DDL|r|cffffffffF|r|cffff0000M ")
        GameTooltip:AddLine("Click to toggle AutoLFM interface.", 1, 1, 1)
        GameTooltip:AddLine("Ctrl + Click for move.", 1, 1, 1)
        GameTooltip:Show()
    end)
    AutoLFMMinimapBtn:SetScript("OnLeave", function()
        AutoLFMMinimapBtn:GetNormalTexture():SetVertexColor(1, 1, 1)
        GameTooltip:Hide()
    end)

    -- Clic gauche toggle interface sauf si Ctrl enfoncé
    AutoLFMMinimapBtn:SetScript("OnClick", function()
      if IsControlKeyDown() then return end
      if AutoLFM:IsShown() then
        AutoLFM:Hide()
      else
        AutoLFM:Show()
      end
    end)

    -- Rendre déplaçable avec Ctrl + clic gauche
    AutoLFMMinimapBtn:SetMovable(true)
    AutoLFMMinimapBtn:EnableMouse(true)
    AutoLFMMinimapBtn:RegisterForDrag("LeftButton")

    AutoLFMMinimapBtn:SetScript("OnMouseDown", function(self, button)
        if IsControlKeyDown() then
            AutoLFMMinimapBtn:StartMoving()
        end
    end)

    AutoLFMMinimapBtn:SetScript("OnMouseUp", function(self, button)
        AutoLFMMinimapBtn:StopMovingOrSizing()
        local point, relativeTo, relativePoint, xOfs, yOfs = AutoLFMMinimapBtn:GetPoint()
        AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnX = xOfs
        AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnY = yOfs
    end)

    AutoLFMMinimapBtn:Show()
end

-- -- Frame pour gérer l'événement de chargement de l'addon
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == "AutoLFM" then
        InitMinimapButton()
    end
end)
