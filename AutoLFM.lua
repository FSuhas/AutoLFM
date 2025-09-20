---------------------------------------------------------------------------------
--                            Log Message                                      --
---------------------------------------------------------------------------------

local msglog = CreateFrame("Frame")
msglog:RegisterEvent("PLAYER_ENTERING_WORLD")

function ShowDungeonUI()
    raidFrame:Hide()
    raidScrollFrame:Hide()
    editBox:Hide()
    sliderframe:Hide()
    toggleButton:Hide()
    msgFrameDj:Hide()
    msgFrameRaids:Hide()
    dashText:Hide()
    if AutoLFM:IsVisible() then
        AutoLFM:Hide()
    end
end

local function OnPlayerEnteringWorld(self, event)
--   local seg1 = "|cffffffff ---- Refonte de l'addon ---- "
  local seg2 = "|cffffffff <"
  local seg3 = "|cffffff00 Auto "
  local seg4 = "|cff0070DDL"
  local seg5 = "|cffffffffF"
  local seg6 = "|cffff0000M "
  local seg7 = "|cffffffff>"
  local seg8 = " "
  local seg9 = "|cff00FF00 Loaded successfully !"
  local seg10 = "|cffffff00   More information with  : "
  local seg11 = "|cff00FFFF  /lfm help"


  -- Combine the segments and display the message
  -- DEFAULT_CHAT_FRAME:AddMessage(seg1)
  DEFAULT_CHAT_FRAME:AddMessage(seg2 .. seg3 .. seg4 .. seg5 .. seg6 .. seg7 .. seg8 .. seg9)
  DEFAULT_CHAT_FRAME:AddMessage(seg10 .. seg11)
  
  InitMinimapButton()
  DisplayDungeonsByColor()
  ShowDungeonUI()
  msglog:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

msglog:SetScript("OnEvent", OnPlayerEnteringWorld)


---------------------------------------------------------------------------------
--                           Init Donjons & Raids                              --
---------------------------------------------------------------------------------


-- Vérifier si des canaux sont sélectionnés
if next(selectedChannels) == nil then
    channelsFrame:Show()  -- Afficher le cadre des canaux
else
    LoadSelectedChannels()
    channelsFrame:Hide()  -- Masquer le cadre des canaux si aucun canal n'est sélectionné
end


---------------------------------------------------------------------------------
--                           Slash Commande                                    --
---------------------------------------------------------------------------------


local bigMessageFrame, bigMessageText

local function ShowBigMessage(text, duration)
    if not bigMessageFrame then
        bigMessageFrame = CreateFrame("Frame", "BigMessageFrame", UIParent)
        bigMessageFrame:SetWidth(600)
        bigMessageFrame:SetHeight(100)
        bigMessageFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

        bigMessageText = bigMessageFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        bigMessageText:SetFont("Fonts\\FRIZQT__.TTF", 36, "OUTLINE")
        bigMessageText:SetPoint("CENTER", bigMessageFrame, "CENTER", 0, 0)
        bigMessageText:SetTextColor(1, 0, 0, 1) -- Rouge vif
    end

    bigMessageFrame:Show()

    local fullText = text
    local displayedText = ""
    local index = 0
    local timePerChar = 0.05
    local lastUpdate = GetTime()
    local totalTime = duration or 3

    bigMessageText:SetText("")
    
    bigMessageFrame:SetScript("OnUpdate", function(self)
        local now = GetTime()
        if now - lastUpdate >= timePerChar then
            lastUpdate = now
            index = index + 1
            displayedText = string.sub(fullText, 1, index)
            bigMessageText:SetText(displayedText)
        end

        if index >= string.len(fullText) then
            totalTime = totalTime - (now - lastUpdate)
            if totalTime <= 0 then
                bigMessageFrame:Hide()
                bigMessageFrame:SetScript("OnUpdate", nil)
            end
        end
    end)
end


-- Définir les slash commandes
SLASH_LFM1 = "/lfm"
SLASH_LFM3 = "/lfm help"
SLASH_LFM2 = "/lfm broadcast"
SLASH_LFM5 = "/lfm minimap show"
SLASH_LFM6 = "/lfm minimap hide"
SLASH_LFM = "/lfm minimap reset"


-- Fonction principale des commandes Slash
SlashCmdList["LFM"] = function(msg)
    -- Séparer le message en argument
    local args = strsplit(" ", msg)

    -- Afficher les commandes disponibles
    if args[1] == "help" then
        -- Afficher les commandes disponibles dans le chat avec des couleurs
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Available commands :")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00FFFF /lfm  |cffFFFFFFOpens AutoLFM window.")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00FFFF /lfm help   |cffFFFFFFDisplays all available orders.")  -- Bleu clair pour la commande et blanc pour l'explication
        DEFAULT_CHAT_FRAME:AddMessage("|cff00FFFF /lfm broadcast   |cffFFFFFFOpen Broadcast settings.")  -- Bleu clair pour la commande et blanc pour l'explication
        DEFAULT_CHAT_FRAME:AddMessage("|cff00FFFF /lfm minimap show   |cffFFFFFFDisplays the minimap button.")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00FFFF /lfm minimap hide   |cffFFFFFFHide minimap button.")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00FFFF /lfm minimap reset   |cffFFFFFFReset minimap button position.")
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
        if AutoLFMMinimapBtn and not AutoLFMMinimapBtn:IsShown() then
            AutoLFMMinimapBtn:Show()
            AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnHidden = false
            DEFAULT_CHAT_FRAME:AddMessage("The minimap button has been redisplayed.", 0.0, 1.0, 0.0) -- Texte vert
        else
            DEFAULT_CHAT_FRAME:AddMessage("The minimap button is already visible.", 1.0, 0.0, 0.0) -- Texte rouge
        end
        return
    end

    -- Commande pour masquer le bouton de la minimap
    if args[1] == "minimap" and args[2] == "hide" then
        if AutoLFMMinimapBtn and AutoLFMMinimapBtn:IsShown() then
            AutoLFMMinimapBtn:Hide()
            AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnHidden = true
            DEFAULT_CHAT_FRAME:AddMessage("The minimap button has been hidden.", 0.0, 1.0, 0.0) -- Texte vert
        else
            DEFAULT_CHAT_FRAME:AddMessage("The minimap button is already hidden.", 1.0, 0.0, 0.0) -- Texte rouge
        end
        return
    end

    if args[1] == "broadcast" then
        if channelsFrame:IsVisible() then
            channelsFrame:Hide()  -- Cacher le cadre des canaux
            DEFAULT_CHAT_FRAME:AddMessage("Channels frame hidden.")  -- Message de confirmation
        else
            CreateChannelButtons()
            LoadSelectedChannels()
            channelsFrame:Show()  -- Afficher le cadre des canaux
            DEFAULT_CHAT_FRAME:AddMessage("Channels frame displayed.")  -- Message de confirmation
        end
        return
    end

    if args[1] == "petfoireux" then
        ShowBigMessage("Fuuumiiieeeerrrr !!!!!!", 3)
        PlaySoundFile("Interface\\AddOns\\AutoLFM\\sound\\fumier.ogg")
        return
    end

    -- if args[1] == "ui" and args[2] == "classic" then
    --     LoadUILayout("Classic")
    --     return
    -- elseif args[1] == "ui" and args[2] == "modern" then
    --     LoadUILayout("Modern")
    --     return
    -- end

    -- Ajout dans la fonction SlashCmdList["LFM"]
    if args[1] == "minimap" and args[2] == "reset" then
        -- Réinitialiser la position sauvegardée
        AutoLFM_SavedVariables.minimapBtnX = nil
        AutoLFM_SavedVariables.minimapBtnY = nil
        
        -- Repositionner immédiatement le bouton si il existe
        if AutoLFMMinimapBtn then
            AutoLFMMinimapBtn:ClearAllPoints()
            AutoLFMMinimapBtn:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -10, -10)
            AutoLFMMinimapBtn:Show()
        end
        
        DEFAULT_CHAT_FRAME:AddMessage("Minimap button position reset to default.", 0, 1, 0) -- Vert
        return
    end

    -- Si la commande est incorrecte
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 ! Usage !   |cff00FFFF/lfm help |cffFFFFFFto list all commands.")  -- Rouge
end


---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------


mgMessage = nil
mgInterval = 60 -- secondes
mgElapsed = 0
mgRunning = false

-- Frame pour OnUpdate
mgFrame = CreateFrame("Frame", "MGSpamFrame")

-- Slash command
SLASH_MG1 = "/mg"
SlashCmdList["MG"] = function(msg)
    if msg == "stop" then
        mgRunning = false
        mgFrame:SetScript("OnUpdate", nil)
        DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[MG]|r Spam arrêté.")
        return
    end

    if msg == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[MG]|r Usage : /mg <message> ou /mg stop")
        return
    end

    if not IsInGuild() then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[MG]|r Vous n'êtes pas dans une guilde.")
        return
    end

    mgMessage = msg
    mgElapsed = mgInterval
    mgRunning = true

    mgFrame:SetScript("OnUpdate", function()
        local now = GetTime()
        if not mgFrame.lastUpdate then
            mgFrame.lastUpdate = now
            return
        end

        local elapsed = now - mgFrame.lastUpdate
        mgFrame.lastUpdate = now

        if not mgRunning then
            mgFrame:SetScript("OnUpdate", nil)
            return
        end

        mgElapsed = mgElapsed + elapsed
        if mgElapsed >= mgInterval then
            mgElapsed = 0
            SendChatMessage("|cff00ffff" .. mgMessage .. "|r", "GUILD")

        end
    end)

    DEFAULT_CHAT_FRAME:AddMessage("|cff55ff55[MG]|r Spam lancé toutes les " .. mgInterval .. "s : " .. msg)
end


---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------


-- Création de la fenêtre FPS/MS
local MyFPSFrame = CreateFrame("Frame", "MyFPSFrame", UIParent)
MyFPSFrame:SetWidth(90)
MyFPSFrame:SetHeight(40)
MyFPSFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)

-- Fond / cadre
MyFPSFrame.bg = MyFPSFrame:CreateTexture(nil, "BACKGROUND")
MyFPSFrame.bg:SetAllPoints(MyFPSFrame)
MyFPSFrame.bg:SetTexture(0, 0, 0, 0.3)
MyFPSFrame.bg:Hide()  -- fond caché par défaut

-- Texte FPS
MyFPSFrame.fpsText = MyFPSFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
MyFPSFrame.fpsText:SetPoint("TOP", 0, -5)

-- Texte MS
MyFPSFrame.msText = MyFPSFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
MyFPSFrame.msText:SetPoint("BOTTOM", 0, 5)

-- Drag & drop avec ALT + clic gauche
MyFPSFrame:EnableMouse(true)
MyFPSFrame:SetMovable(true)
MyFPSFrame:SetScript("OnMouseDown", function()
    if IsAltKeyDown() then
        this:StartMoving()
    end
end)
MyFPSFrame:SetScript("OnMouseUp", function()
    this:StopMovingOrSizing()
end)

-- Initialisation du timer
MyFPSFrame.timeSinceUpdate = 0

-- Mise à jour continue FPS/MS
local lastUpdate = 0
MyFPSFrame:SetScript("OnUpdate", function()
    local now = GetTime()
    if now - lastUpdate >= 1 then
        local fps = floor(GetFramerate() + 0.5)
        local _, _, latencyHome = GetNetStats()
        MyFPSFrame.fpsText:SetText("FPS: "..fps)
        MyFPSFrame.msText:SetText("MS: "..latencyHome)
        lastUpdate = now
    end
end)

-- Affichage du fond au survol + tooltip mémoire
MyFPSFrame:SetScript("OnEnter", function()
    MyFPSFrame.bg:Show()
end)

MyFPSFrame:SetScript("OnLeave", function()
    MyFPSFrame.bg:Hide()
end)

-- Fonction pour toggle la fenêtre
local function ToggleMyFPSFrame()
    if MyFPSFrame:IsShown() then
        MyFPSFrame:Hide()
    else
        MyFPSFrame:Show()
        MyFPSFrame.timeSinceUpdate = 1 -- update immédiat
    end
end

-- Override ToggleFramerate pour Ctrl+R
local originalToggleFramerate = ToggleFramerate
function ToggleFramerate()
    ToggleMyFPSFrame()
end


MyFPSFrame:Hide()

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

-- Frame for events
local RestedXPFrame = CreateFrame("Frame")
local hasAnnouncedFull = false

-- Function to check rested XP
function CheckFullRested()
    local level = UnitLevel("player")
    if level >= 60 then return end  -- ignore if level 60

    local restXP = GetXPExhaustion()
    local maxXP = UnitXPMax("player")
    
    if restXP and restXP >= (maxXP * 1.5) then
        if not hasAnnouncedFull then
            -- Chat message
            DEFAULT_CHAT_FRAME:AddMessage("✨ Your rested XP is FULL!", 0, 1, 0)
            -- Play a sound
            PlaySound("LEVELUP")  -- Vanilla 1.12 has LEVELUP sound
            -- Optional: /say notification
            -- SendChatMessage("My rested XP is full!", "SAY")
            
            hasAnnouncedFull = true
        end
    else
        hasAnnouncedFull = false
    end
end

-- Event handler
RestedXPFrame:SetScript("OnEvent", function()
    CheckFullRested()
end)

RestedXPFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
RestedXPFrame:RegisterEvent("UPDATE_EXHAUSTION")

-- Slash command to check rested XP
SLASH_RESTEDXP1 = "/rested"
SlashCmdList["RESTEDXP"] = function()
    local level = UnitLevel("player")
    if level >= 60 then
        DEFAULT_CHAT_FRAME:AddMessage("You are level 60, rested XP does not apply.", 1, 0, 0)
        return
    end

    local restXP = GetXPExhaustion() or 0
    local maxXP = UnitXPMax("player")
    local percent = math.floor((restXP / (maxXP * 1.5)) * 100)
    
    DEFAULT_CHAT_FRAME:AddMessage(
        string.format("💤 Current rested XP: %d / %d (≈%d%%)", restXP, maxXP * 1.5, percent),
        0.5, 0.8, 1
    )
end

