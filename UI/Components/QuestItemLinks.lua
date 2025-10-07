--------------------------------------------------
-- Quest & Item Links Component
--------------------------------------------------
local editBoxHasFocus = false

--------------------------------------------------
-- Create Quest Hyperlink
--------------------------------------------------
local function CreateQuestHyperlink(questIndex)
  if not questIndex or questIndex < 1 then return nil end
  
  local title, level, _, _, _, _, _, questID = GetQuestLogTitle(questIndex)
  if not title or title == "" then return nil end
  
  questID = questID or 0
  level = level or 0
  
  local color = "|cffffff00"
  local link = string.format("%s|Hquest:%d:%d|h[%s]|h|r", color, questID, level, title)
  return link
end

--------------------------------------------------
-- Insert Link into EditBox
--------------------------------------------------
local function InsertLinkIntoEditBox(link)
  if not link then return end
  
  local editBox = GetCustomMessageEditBox()
  if not editBox then return end
  if not AutoLFM_MainFrame or not AutoLFM_MainFrame:IsVisible() then return end
  
  local currentText = editBox:GetText() or ""
  if currentText == "" then
    editBox:SetText(link)
  else
    editBox:SetText(currentText .. " " .. link)
  end
  
  editBox:SetFocus()
  editBox:HighlightText(0, 0)
end

--------------------------------------------------
-- Hook Container Item Buttons
--------------------------------------------------
local Original_ContainerFrameItemButton_OnClick = nil
local Original_ContainerFrameItemButton_OnModifiedClick = nil

local function HookBagClicks()
  -- Hook OnClick
  if ContainerFrameItemButton_OnClick then
    Original_ContainerFrameItemButton_OnClick = ContainerFrameItemButton_OnClick
    
    ContainerFrameItemButton_OnClick = function(button, ignoreModifiers)
      if IsShiftKeyDown() and AutoLFM_MainFrame and AutoLFM_MainFrame:IsVisible() and editBoxHasFocus then
        local bag = this:GetParent():GetID()
        local slot = this:GetID()
        local itemLink = GetContainerItemLink(bag, slot)
        
        if itemLink then
          InsertLinkIntoEditBox(itemLink)
          return
        end
      end
      
      if Original_ContainerFrameItemButton_OnClick then
        Original_ContainerFrameItemButton_OnClick(button, ignoreModifiers)
      end
    end
  end
  
  -- Hook OnModifiedClick
  if ContainerFrameItemButton_OnModifiedClick then
    Original_ContainerFrameItemButton_OnModifiedClick = ContainerFrameItemButton_OnModifiedClick
    
    ContainerFrameItemButton_OnModifiedClick = function(button, ignoreModifiers)
      if IsShiftKeyDown() and AutoLFM_MainFrame and AutoLFM_MainFrame:IsVisible() and editBoxHasFocus then
        local bag = this:GetParent():GetID()
        local slot = this:GetID()
        local itemLink = GetContainerItemLink(bag, slot)
        
        if itemLink then
          InsertLinkIntoEditBox(itemLink)
          return
        end
      end
      
      if Original_ContainerFrameItemButton_OnModifiedClick then
        Original_ContainerFrameItemButton_OnModifiedClick(button, ignoreModifiers)
      end
    end
  end
end

--------------------------------------------------
-- Hook Quest Log
--------------------------------------------------
local function HookQuestLog()
  local questFrame = CreateFrame("Frame")
  questFrame:RegisterEvent("QUEST_LOG_UPDATE")
  
  local lastClickedQuest = nil
  local lastClickTime = 0
  
  questFrame:SetScript("OnEvent", function()
    if not QuestLogFrame or not QuestLogFrame:IsVisible() then return end
    
    local currentTime = GetTime()
    if currentTime - lastClickTime < 0.1 then return end
    
    local selectedQuest = GetQuestLogSelection()
    if selectedQuest and selectedQuest > 0 and selectedQuest ~= lastClickedQuest then
      lastClickedQuest = selectedQuest
      lastClickTime = currentTime
      
      if IsShiftKeyDown() and editBoxHasFocus then
        if AutoLFM_MainFrame and AutoLFM_MainFrame:IsVisible() then
          local questLink = CreateQuestHyperlink(selectedQuest)
          if questLink then
            InsertLinkIntoEditBox(questLink)
          end
        end
      end
    end
  end)
end

--------------------------------------------------
-- Hook Chat Links
--------------------------------------------------
local function HookChatLinks()
  local Original_ChatFrame = ChatFrame_OnHyperlinkShow
  
  ChatFrame_OnHyperlinkShow = function(...)
    if Original_ChatFrame then
      Original_ChatFrame(unpack(arg))
    end
    
    if IsShiftKeyDown() and editBoxHasFocus then
      if AutoLFM_MainFrame and AutoLFM_MainFrame:IsVisible() then
        local link = arg[1]
        local text = arg[2]
        
        if link and text and (string.find(link, "^item:") or string.find(link, "^quest:")) then
          InsertLinkIntoEditBox(text)
        end
      end
    end
  end
end

--------------------------------------------------
-- Update EditBox Focus State
--------------------------------------------------
function UpdateEditBoxFocusState(hasFocus)
  editBoxHasFocus = hasFocus
end

--------------------------------------------------
-- Initialize Quest Item Links
--------------------------------------------------
function InitializeQuestItemLinks()
  HookBagClicks()
  HookQuestLog()
  HookChatLinks()
end