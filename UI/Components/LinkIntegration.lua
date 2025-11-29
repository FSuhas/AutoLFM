--=============================================================================
-- AutoLFM: Link Integration (WoW 1.12 safe)
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.LinkIntegration then AutoLFM.UI.LinkIntegration = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local Original_ContainerFrameItemButton_OnClick = nil
local Original_ChatFrame_OnHyperlinkShow = nil

-----------------------------------------------------------------------------
-- Bag Item Clicks (Shift+Click to custom editbox)
-----------------------------------------------------------------------------
local function HookBagClicks()
    if not ContainerFrameItemButton_OnClick then return end
    Original_ContainerFrameItemButton_OnClick = ContainerFrameItemButton_OnClick

    ContainerFrameItemButton_OnClick = function(button, ignoreModifiers)
        local success, err = pcall(function()
            if IsShiftKeyDown() 
               and AutoLFM_MainFrame and AutoLFM_MainFrame:IsVisible()
               and AutoLFM.UI.MorePanel.GetEditBoxFocus
               and AutoLFM.UI.MorePanel.GetCustomMessageEditBox then

                local bag = this:GetParent():GetID()
                local slot = this:GetID()
                local itemLink = GetContainerItemLink(bag, slot)
                local editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox()

                if itemLink and editBox then
                    local currentText = editBox:GetText() or ""
                    editBox:SetText((currentText == "" and itemLink) or (currentText .. " " .. itemLink))
                    editBox:SetFocus()
                    editBox:HighlightText(0, 0)
                    return
                end
            end

            if Original_ContainerFrameItemButton_OnClick then
                Original_ContainerFrameItemButton_OnClick(button, ignoreModifiers)
            end
        end)

        if not success and Original_ContainerFrameItemButton_OnClick then
            Original_ContainerFrameItemButton_OnClick(button, ignoreModifiers)
        end
    end
end

-----------------------------------------------------------------------------
-- Quest Log Selection (Shift+Click to custom editbox)
-----------------------------------------------------------------------------
local function HookQuestLog()
    local questFrame = CreateFrame("Frame")
    questFrame:RegisterEvent("QUEST_LOG_UPDATE")

    local lastClickedQuest = nil
    local lastClickTime = 0

    questFrame:SetScript("OnEvent", function()
      local success, err = pcall(function()
        if not QuestLogFrame or not QuestLogFrame:IsVisible() then return end

        local currentTime = GetTime()
        if currentTime - lastClickTime < 0.1 then return end

        local selectedQuest = GetQuestLogSelection()
        if selectedQuest and selectedQuest > 0 and selectedQuest ~= lastClickedQuest then
          lastClickedQuest = selectedQuest
          lastClickTime = currentTime

          if IsShiftKeyDown() and AutoLFM.UI.MorePanel.GetEditBoxFocus then
            local editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox and AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
            if editBox and AutoLFM_MainFrame and AutoLFM_MainFrame:IsVisible() then
              local title, level, _, _, _, _, _, questID = GetQuestLogTitle(selectedQuest)
              if title then
                level = level or 0
                questID = questID or 0
                local cleanTitle = string.gsub(title, "^%[.-%]%s*", "")
                local link = AutoLFM.Logic.Content.CreateQuestLink(questID, level, cleanTitle)

                local currentText = editBox:GetText() or ""
                editBox:SetText((currentText == "" and link) or (currentText .. " " .. link))
                editBox:SetFocus()
                editBox:HighlightText(0, 0)
              end
            end
          end
        end
      end)
      if not success then
        AutoLFM.Core.Utils.PrintError("QuestLog hook error: " .. tostring(err))
      end
    end)
end

-----------------------------------------------------------------------------
-- Chat Hyperlinks (RightClick for menu, Shift+Click for editbox)
-----------------------------------------------------------------------------
local function HookChatLinks()
    if not ChatFrame_OnHyperlinkShow then return end
    Original_ChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow

    ChatFrame_OnHyperlinkShow = function(link, text, button)
        local success, err = pcall(function()
            -- Right click on player → show menu
            local linkType, playerName = string.match(link or "", "^(%a+):([^:]+)")
            if linkType == "player" and playerName and button == "RightButton" then
                playerName = gsub(playerName, "-.*", "")
                HideDropDownMenu(1)
                ChatFrameDropDown_Show(nil, playerName)
                return
            end

            -- Shift+Click on item/quest → insert into editbox
            if IsShiftKeyDown() and AutoLFM.UI.MorePanel.GetEditBoxFocus then
                local editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox and AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
                if editBox and AutoLFM_MainFrame and AutoLFM_MainFrame:IsVisible() then
                    if link and text and (string.find(link, "^item:") or string.find(link, "^quest:")) then
                        local currentText = editBox:GetText() or ""
                        editBox:SetText((currentText == "" and text) or (currentText .. " " .. text))
                        editBox:SetFocus()
                        editBox:HighlightText(0, 0)
                    end
                end
            end

            -- Call original
            if Original_ChatFrame_OnHyperlinkShow then
                Original_ChatFrame_OnHyperlinkShow(link, text, button)
            end
        end)

        if not success and Original_ChatFrame_OnHyperlinkShow then
            Original_ChatFrame_OnHyperlinkShow(link, text, button)
        end
    end
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function AutoLFM.UI.LinkIntegration.Init()
    local success, err = pcall(function()
        HookBagClicks()
        HookQuestLog()
        HookChatLinks()
    end)

    if not success then
        AutoLFM.Core.Utils.PrintError("Failed to initialize links: " .. tostring(err))
    end
end
