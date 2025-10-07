
-- -- Quest List Button To add in autoLFM
local questListBtn = CreateFrame("Button", nil, moreContent, "UIPanelButtonTemplate")
questListBtn:SetWidth(200)
questListBtn:SetHeight(30)
questListBtn:SetPoint("TOP", moreContent, "TOP", 0, -150) -- Ajuste la position selon tes autres boutons
questListBtn:SetText("Open Quest List")
questListBtn:SetScript("OnClick", function()
  ToggleQuestList()
end)



--------------------------------------------------
-- Quest List Panel
--------------------------------------------------

local questListFrame = nil
local questButtons = {}
local MAX_DISPLAYED_QUESTS = 20

--------------------------------------------------
-- Create Quest List Frame
--------------------------------------------------
local function CreateQuestListFrame()
  if questListFrame then return questListFrame end
  
  -- Main Frame
  questListFrame = CreateFrame("Frame", "AutoLFM_QuestListFrame", UIParent)
  questListFrame:SetWidth(400)
  questListFrame:SetHeight(500)
  questListFrame:SetPoint("CENTER", 0, 0)
  questListFrame:SetFrameStrata("DIALOG")
  questListFrame:EnableMouse(true)
  questListFrame:SetMovable(true)
  questListFrame:RegisterForDrag("LeftButton")
  questListFrame:SetScript("OnDragStart", function() this:StartMoving() end)
  questListFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
  questListFrame:Hide()
  
  -- Background
  local bg = questListFrame:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints(questListFrame)
  bg:SetTexture(0, 0, 0, 0.9)
  
  -- Border
  local border = questListFrame:CreateTexture(nil, "OVERLAY")
  border:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Border")
  border:SetAllPoints(questListFrame)
  
  -- Title
  local title = questListFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", questListFrame, "TOP", 0, -10)
  title:SetText("Quest List - Click to insert link")
  title:SetTextColor(1, 0.82, 0)
  
  -- Close Button
  local closeBtn = CreateFrame("Button", nil, questListFrame, "UIPanelCloseButton")
  closeBtn:SetPoint("TOPRIGHT", questListFrame, "TOPRIGHT", -5, -5)
  closeBtn:SetScript("OnClick", function()
    questListFrame:Hide()
  end)
  
  -- Scroll Frame
  local scrollFrame = CreateFrame("ScrollFrame", "AutoLFM_QuestListScrollFrame", questListFrame, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", questListFrame, "TOPLEFT", 10, -40)
  scrollFrame:SetPoint("BOTTOMRIGHT", questListFrame, "BOTTOMRIGHT", -30, 40)
  
  -- Content Frame
  local contentFrame = CreateFrame("Frame", nil, scrollFrame)
  contentFrame:SetWidth(scrollFrame:GetWidth())
  contentFrame:SetHeight(1)
  scrollFrame:SetScrollChild(contentFrame)
  questListFrame.contentFrame = contentFrame
  
  -- Refresh Button
  local refreshBtn = CreateFrame("Button", nil, questListFrame, "UIPanelButtonTemplate")
  refreshBtn:SetWidth(100)
  refreshBtn:SetHeight(25)
  refreshBtn:SetPoint("BOTTOM", questListFrame, "BOTTOM", 0, 10)
  refreshBtn:SetText("Refresh")
  refreshBtn:SetScript("OnClick", function()
    UpdateQuestList()
  end)
  
  return questListFrame
end

--------------------------------------------------
-- Create Quest Button
--------------------------------------------------
local function CreateQuestButton(parent, index)
  local btn = CreateFrame("Button", "AutoLFM_QuestButton" .. index, parent)
  btn:SetWidth(350)
  btn:SetHeight(20)
  
  -- Background
  local bg = btn:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints(btn)
  bg:SetTexture(0.2, 0.2, 0.2, 0.5)
  
  -- Highlight
  local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
  highlight:SetAllPoints(btn)
  highlight:SetTexture(0.4, 0.4, 0.4, 0.5)
  
  -- Quest Title
  local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  text:SetPoint("LEFT", btn, "LEFT", 5, 0)
  text:SetJustifyH("LEFT")
  text:SetWidth(280)
  btn.text = text
  
  -- Level
  local levelText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  levelText:SetPoint("RIGHT", btn, "RIGHT", -5, 0)
  levelText:SetJustifyH("RIGHT")
  levelText:SetWidth(50)
  btn.levelText = levelText
  
-- OnClick: Insert Quest Link
btn:SetScript("OnClick", function()
  local questIndex = this.questIndex
  if not questIndex then return end
  
  local title, level, _, _, _, _, _, questID = GetQuestLogTitle(questIndex)
  if not title or title == "" then return end
  
  questID = questID or 0
  level = level or 0
  
  -- Remove tags from title for the link
  local cleanTitle = string.gsub(title, "^%[.-%]%s*", "")
  
  local color = "|cffffff00"
  local link = string.format("%s|Hquest:%d:%d|h[%s]|h|r", color, questID, level, cleanTitle)
  
  -- Try AutoLFM EditBox first
  if AutoLFM_MainFrame and AutoLFM_MainFrame:IsVisible() then
    local editBox = GetCustomMessageEditBox()
    if editBox then
      local currentText = editBox:GetText() or ""
      if currentText == "" then
        editBox:SetText(link)
      else
        editBox:SetText(currentText .. " " .. link)
      end
      editBox:SetFocus()
      editBox:HighlightText(0, 0)
      DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Quest link inserted in AutoLFM!|r")
      return
    end
  end
  
  -- Fallback: Insert in chat
  local chatFrame = DEFAULT_CHAT_FRAME
  if chatFrame and chatFrame.editBox then
    if not chatFrame.editBox:IsVisible() then
      ChatFrameEditBox:Show()
    end
    ChatFrameEditBox:Insert(link)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Quest link inserted in chat!|r")
  end
end)
  
  -- Tooltip
  btn:SetScript("OnEnter", function()
    local questIndex = this.questIndex
    if questIndex then
      GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
      GameTooltip:SetQuestLogItem("quest", questIndex)
      GameTooltip:Show()
    end
  end)
  
  btn:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  
  return btn
end

--------------------------------------------------
-- Update Quest List
--------------------------------------------------
function UpdateQuestList()
  if not questListFrame or not questListFrame:IsVisible() then return end
  
  local contentFrame = questListFrame.contentFrame
  if not contentFrame then return end
  
  -- Clear existing buttons
  for i = 1, table.getn(questButtons) do
    questButtons[i]:Hide()
  end
  
  -- Get quest count
  local numEntries, numQuests = GetNumQuestLogEntries()
  
  if numQuests == 0 then
    -- No quests
    if not questButtons[1] then
      questButtons[1] = CreateQuestButton(contentFrame, 1)
      questButtons[1]:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 5, -5)
    end
    questButtons[1]:Show()
    questButtons[1].text:SetText("No active quests")
    questButtons[1].levelText:SetText("")
    questButtons[1].questIndex = nil
    questButtons[1]:SetScript("OnClick", nil)
    questButtons[1]:SetScript("OnEnter", nil)
    
    contentFrame:SetHeight(30)
    return
  end
  
  -- Populate quest list
  local buttonIndex = 1
  local yOffset = -5
  
  for questIndex = 1, numEntries do
    local title, level, questTag, suggestedGroup, isHeader, isCollapsed = GetQuestLogTitle(questIndex)
    
    -- Skip headers
    if not isHeader then
      -- Create button if needed
      if not questButtons[buttonIndex] then
        questButtons[buttonIndex] = CreateQuestButton(contentFrame, buttonIndex)
        if buttonIndex == 1 then
          questButtons[buttonIndex]:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 5, yOffset)
        else
          questButtons[buttonIndex]:SetPoint("TOPLEFT", questButtons[buttonIndex - 1], "BOTTOMLEFT", 0, -2)
        end
      end
      
      local btn = questButtons[buttonIndex]
      btn:Show()
      btn.questIndex = questIndex
      
      -- Set quest title
      local displayTitle = title or "Unknown Quest"
      if questTag then
        displayTitle = "[" .. questTag .. "] " .. displayTitle
      end
      
      -- Color based on level difficulty
      local levelDiff = level - UnitLevel("player")
      local color
      if levelDiff >= 5 then
        color = "|cffff0000" -- Red (hard)
      elseif levelDiff >= 3 then
        color = "|cffff8000" -- Orange
      elseif levelDiff >= -2 then
        color = "|cffffff00" -- Yellow
      elseif levelDiff >= -5 then
        color = "|cff40ff40" -- Green
      else
        color = "|cff808080" -- Gray (trivial)
      end
      
      btn.text:SetText(color .. displayTitle .. "|r")
      btn.levelText:SetText(color .. "[" .. level .. "]|r")
      
      buttonIndex = buttonIndex + 1
      yOffset = yOffset - 22
    end
  end
  
  -- Set content height
  contentFrame:SetHeight(math.max(1, (buttonIndex - 1) * 22 + 10))
end

--------------------------------------------------
-- Show Quest List
--------------------------------------------------
function ShowQuestList()
  local frame = CreateQuestListFrame()
  frame:Show()
  UpdateQuestList()
end

--------------------------------------------------
-- Toggle Quest List
--------------------------------------------------
function ToggleQuestList()
  local frame = CreateQuestListFrame()
  if frame:IsVisible() then
    frame:Hide()
  else
    ShowQuestList()
  end
end

--------------------------------------------------
-- Auto-update when quest log changes
--------------------------------------------------
local questUpdateFrame = CreateFrame("Frame")
questUpdateFrame:RegisterEvent("QUEST_LOG_UPDATE")
questUpdateFrame:SetScript("OnEvent", function()
  UpdateQuestList()
end)