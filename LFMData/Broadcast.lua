---------------------------------------------------------------------------------
--                             Broadcast Fonction                              --
---------------------------------------------------------------------------------


-- Variables pour gérer l'intervalle et la diffusion du message
isBroadcasting = false
broadcastStartTime = 0
lastBroadcastTime = 0
broadcastedHalf = false
broadcastedOneSecBefore = false
messagesSentCount = 0

iconUpdateFrame = CreateFrame("Frame")  -- Frame pour gérer l'update des icônes

-- Fonction pour alterner les icônes
function toggleMinimapButtonIcon()
    local randomChoice = math.random(1, 2)
    if randomChoice == 1 then
        AutoLFMMinimapBtn:SetNormalTexture("Interface\\AddOns\\AutoLFM\\icon\\ring.png")
        AutoLFMMinimapBtn:SetPushedTexture("Interface\\AddOns\\AutoLFM\\icon\\fermer.png")
    else
        AutoLFMMinimapBtn:SetNormalTexture("Interface\\AddOns\\AutoLFM\\icon\\fermer.png")
        AutoLFMMinimapBtn:SetPushedTexture("Interface\\AddOns\\AutoLFM\\icon\\ring.png")
    end
end


-- Fonction pour arrêter la diffusion du message
function stopMessageBroadcast()
    isBroadcasting = false
    DEFAULT_CHAT_FRAME:AddMessage("Broadcast stopped")
    -- Réinitialiser l'icône du bouton lorsque la diffusion s'arrête
    AutoLFMMinimapBtn:SetNormalTexture("Interface\\AddOns\\AutoLFM\\icon\\ring.png")
    AutoLFMMinimapBtn:SetPushedTexture("Interface\\AddOns\\AutoLFM\\icon\\fermer.png")
    -- Désactiver la mise à jour de l'icône
    iconUpdateFrame:SetScript("OnUpdate", nil)
    messagesSentCount = 0
end

-- Fonction pour envoyer un message dans tous les canaux sélectionnés
function sendMessageToSelectedChannels(message)
    -- Vérifier si des canaux ont été sélectionnés
    if next(selectedChannels) then
        local allChannelsValid = true  -- Indicateur pour vérifier si tous les canaux sont valides

        -- Itérer sur tous les canaux sélectionnés
        for channelName, _ in pairs(selectedChannels) do
            -- Ignorer "Hardcore" lors de la vérification des autres canaux
            if channelName ~= "Hardcore" then
                -- Recherche l'ID du canal en utilisant GetChannelName pour s'assurer qu'il est ouvert
                local channelId = GetChannelName(channelName)

                -- Si le canal est invalide (ID non valide)
                if not (channelId and channelId > 0) then
                    DEFAULT_CHAT_FRAME:AddMessage("Error : The channel " .. channelName .. " is invalid or closed.")
                    allChannelsValid = false  -- Un canal invalide a été trouvé, donc on arrête l'envoi
                    break  -- Quitte la boucle dès qu'un canal invalide est trouvé
                end
            end
        end

        -- Si tous les canaux sont valides (en ignorant "Hardcore"), envoyer le message
        if allChannelsValid then
            -- Envoi du message dans tous les canaux sélectionnés
            for channelName, _ in pairs(selectedChannels) do
                -- Si le canal est "Hardcore", ajouter le préfixe "/h"
                if channelName == "Hardcore" then
                    -- Ajouter "/h" au message pour le canal Hardcore
                    local hardcoreMessage = message
                    -- Envoie le message comme une commande dans le canal "Hardcore"
                    SendChatMessage(hardcoreMessage, "Hardcore")  -- Utiliser "SAY" ou un autre canal pour simuler l'envoi
                    -- Affiche dans le chat du jeu le message envoyé (facultatif)
                    -- DEFAULT_CHAT_FRAME:AddMessage("Message envoyé au canal : " .. channelName .. " avec le préfixe /h : " .. hardcoreMessage)
                else
                    -- Pour les autres canaux, envoyer le message normalement
                    local channelId = GetChannelName(channelName)
                    SendChatMessage(message, "CHANNEL", nil, channelId)
                    -- Affiche dans le chat du jeu le message envoyé (dev mode)
                    -- DEFAULT_CHAT_FRAME:AddMessage("Message envoyé au canal : " .. channelName)
                end
            end
        else
            print("1977 : The message has not been sent, because one or more channels are invalid.")
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("Error: No channel selected.")
    end
    messagesSentCount = messagesSentCount + 1
end

-- Fonction pour démarrer la diffusion du message
function startMessageBroadcast()
    -- Vérifier si combinedMessage est vide avant de démarrer la diffusion
    if combinedMessage == "" or combinedMessage == " " then
        print("The LFM message is empty. The broadcast cannot begin.")
        return
    end

    isBroadcasting = true
    broadcastStartTime = GetTime()
    lastBroadcastTime = broadcastStartTime
    DEFAULT_CHAT_FRAME:AddMessage("Broadcast started.")

    -- Diffuser immédiatement le message dès le démarrage
    sendMessageToSelectedChannels(combinedMessage)

    -- Alterner les icônes toutes les 2 secondes pendant la diffusion
    iconUpdateFrame:SetScript("OnUpdate", function(self, elapsed)
        if isBroadcasting then
            -- Alterner les icônes toutes les 2 secondes
            if GetTime() - broadcastStartTime >= 0.3 then
                toggleMinimapButtonIcon()
                broadcastStartTime = GetTime()  -- Réinitialiser le temps à chaque changement
            end
        else
            -- Si la diffusion est arrêtée, arrêter de changer l'icône
            iconUpdateFrame:SetScript("OnUpdate", nil)

        end
    end)
end

-- Frame d'update pour gérer le délai entre chaque diffusion
broadcastFrame = CreateFrame("Frame")

broadcastFrame:SetScript("OnUpdate", function(self, elapsed)
  if isBroadcasting then
      -- Mettre à jour la valeur de l'intervalle du slider
      local sliderValue = slider:GetValue()

      -- Vérifier si le temps écoulé est supérieur ou égal à l'intervalle du slider
      local timeElapsed = GetTime() - lastBroadcastTime

      -- Calculer la moitié de la valeur du slider
      local halfSliderValue = sliderValue / 2
      local oneSecondBefore = sliderValue - 1

      -- Afficher un message une seule fois pour chaque niveau du décompte
      if not broadcastedHalf and timeElapsed >= halfSliderValue and timeElapsed < halfSliderValue + 1 then
          -- Message à la moitié du temps
          DEFAULT_CHAT_FRAME:AddMessage("Rediffusion in " .. math.floor(halfSliderValue) .. " seconds", 0, 1, 1)
          broadcastedHalf = true  -- Marquer comme diffusé une fois
      end

      if not broadcastedOneSecBefore and timeElapsed >= oneSecondBefore and timeElapsed < oneSecondBefore + 1 then
          -- Message 1 seconde avant la diffusion
          DEFAULT_CHAT_FRAME:AddMessage("Rediffusion of Message", 0, 1, 1)
          broadcastedOneSecBefore = true  -- Marquer comme diffusé une fois
      end

      -- Une fois le temps écoulé, envoyer le message
      if timeElapsed >= sliderValue then
          -- Diffuser le message
          if combinedMessage ~= "" then
              sendMessageToSelectedChannels(combinedMessage)
          end

          -- Réinitialiser le temps pour la prochaine diffusion
          lastBroadcastTime = GetTime()

          -- Réinitialiser les drapeaux
          broadcastedHalf = false
          broadcastedOneSecBefore = false
      end
  end
end)