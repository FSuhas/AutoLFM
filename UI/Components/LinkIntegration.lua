--=============================================================================
-- AutoLFM: Link Integration
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
-- Bag Item Clicks
-----------------------------------------------------------------------------
local function HookBagClicks()
  if ContainerFrameItemButton_OnClick then
    Original_ContainerFrameItemButton_OnClick = ContainerFrameItemButton_OnClick
    
    ContainerFrameItemButton_OnClick = function(button, ignoreModifiers)
      local success, err = pcall(function()
        if IsShiftKeyDown() and AutoLFM_MainFrame and AutoLFM_MainFrame:IsVisible() and AutoLFM.UI.MorePanel.GetEditBoxFocus() then
          local bag = this:GetParent():GetID()
          local slot = this:GetID()
          local itemLink = GetContainerItemLink(bag, slot)
          
          if itemLink and AutoLFM.UI.MorePanel.GetCustomMessageEditBox then
            local editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
            if editBox then
              local currentText = editBox:GetText() or ""
              if currentText == "" then
                editBox:SetText(itemLink)
              else
                editBox:SetText(currentText .. " " .. itemLink)
              end
              editBox:SetFocus()
              editBox:HighlightText(0, 0)
              return
            end
          end
        end
        
        if Original_ContainerFrameItemButton_OnClick then
          Original_ContainerFrameItemButton_OnClick(button, ignoreModifiers)
        end
      end)
      
      if not success then
        if Original_ContainerFrameItemButton_OnClick then
          Original_ContainerFrameItemButton_OnClick(button, ignoreModifiers)
        end
      end
    end
  end
end

-----------------------------------------------------------------------------
-- Quest Log Selection
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
        
        if IsShiftKeyDown() and AutoLFM.UI.MorePanel.GetEditBoxFocus() then
          if AutoLFM_MainFrame and AutoLFM_MainFrame:IsVisible() and AutoLFM.UI.MorePanel.GetCustomMessageEditBox then
            local title, level, _, _, _, _, _, questID = GetQuestLogTitle(selectedQuest)
            if title and title ~= "" then
              questID = questID or 0
              level = level or 0
              local cleanTitle = string.gsub(title, "^%[.-%]%s*", "")
              local link = AutoLFM.Logic.Content.CreateQuestLink(questID, level, cleanTitle)
              
              local editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
              if editBox then
                local currentText = editBox:GetText() or ""
                if currentText == "" then
                  editBox:SetText(link)
                else
                  editBox:SetText(currentText .. " " .. link)
                end
                editBox:SetFocus()
                editBox:HighlightText(0, 0)
              end
            end
          end
        end
      end
    end)
  end)
end

-----------------------------------------------------------------------------
-- Chat Hyperlinks
-----------------------------------------------------------------------------
local function HookChatLinks()
  if ChatFrame_OnHyperlinkShow then
    Original_ChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow
  end
  
  ChatFrame_OnHyperlinkShow = function()
    local success, err = pcall(function()
      local link = arg1
      local text = arg2
      
      if Original_ChatFrame_OnHyperlinkShow then
        Original_ChatFrame_OnHyperlinkShow(link, text)
      end
      
      if IsShiftKeyDown() and AutoLFM.UI.MorePanel.GetEditBoxFocus() then
        if AutoLFM_MainFrame and AutoLFM_MainFrame:IsVisible() and AutoLFM.UI.MorePanel.GetCustomMessageEditBox then
          if link and text and (string.find(link, "^item:") or string.find(link, "^quest:")) then
            local editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
            if editBox then
              local currentText = editBox:GetText() or ""
              if currentText == "" then
                editBox:SetText(text)
              else
                editBox:SetText(currentText .. " " .. text)
              end
              editBox:SetFocus()
              editBox:HighlightText(0, 0)
            end
          end
        end
      end
    end)
    
    if not success then
      if Original_ChatFrame_OnHyperlinkShow then
        local link = arg1
        local text = arg2
        Original_ChatFrame_OnHyperlinkShow(link, text)
      end
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
    AutoLFM.Core.Utils.PrintError("Failed to initialize quest/item links: " .. tostring(err))
  end
end
