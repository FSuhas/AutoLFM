--=============================================================================
-- AutoLFM: Quests Panel
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.QuestsPanel then AutoLFM.UI.QuestsPanel = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local mainFrame = nil
local scrollFrame = nil
local contentFrame = nil
local questButtons = {}
local questInfoLabelFrame = nil
local questInfoLabelButton = nil
local questInfoLabelText = nil

-----------------------------------------------------------------------------
-- Quest Link Utilities
-----------------------------------------------------------------------------
local function CreateQuestHyperlink(questIndex)
  if not questIndex or questIndex < 1 then return nil end
  
  local title, level, _, _, _, _, _, questID = GetQuestLogTitle(questIndex)
  if not title then return nil end
  
  questID = questID or 0
  level = level or 0
  
  local cleanTitle = string.gsub(title, "^%[.-%]%s*", "")
  
  return AutoLFM.Logic.Content.CreateQuestLink(questID, level, cleanTitle)
end

local function IsQuestLinkInEditBox(link)
  if not link then return false end
  if not AutoLFM_MainFrame or not AutoLFM_MainFrame:IsVisible() then return false end
  
  local editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox and AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
  if not editBox then return false end
  
  local currentText = editBox:GetText() or ""
  local escapedLink = string.gsub(link, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
  
  return string.find(currentText, escapedLink) ~= nil
end

local function RemoveLinkFromEditBox(link)
  if not link then return false end
  if not AutoLFM_MainFrame or not AutoLFM_MainFrame:IsVisible() then return false end
  
  local editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox and AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
  if not editBox then return false end
  
  local currentText = editBox:GetText() or ""
  
  local pattern = string.gsub(link, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
  local newText = string.gsub(currentText, pattern, "")
  newText = AutoLFM.Logic.Content.CleanQuestText(newText)
  
  editBox:SetText(newText)
  
  if AutoLFM.Logic.Broadcaster.SetCustomMessage then
    AutoLFM.Logic.Broadcaster.SetCustomMessage(newText)
  end
  if AutoLFM.Logic.Broadcaster.UpdateMessage then
    AutoLFM.Logic.Broadcaster.UpdateMessage()
  end
  if AutoLFM.UI.MainWindow.UpdateMessagePreview then
    AutoLFM.UI.MainWindow.UpdateMessagePreview()
  end
  
  return true
end

local function InsertLinkToEditBox(link)
  if not link then return false end
  if not AutoLFM_MainFrame or not AutoLFM_MainFrame:IsVisible() then return false end
  
  local editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox and AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
  if not editBox then return false end
  
  local currentText = editBox:GetText() or ""
  local newText = ""
  
  if currentText == "" then
    newText = link
  else
    newText = currentText .. " " .. link
  end
  
  editBox:SetText(newText)
  editBox:SetFocus()
  editBox:HighlightText(0, 0)
  
  if AutoLFM.Logic.Broadcaster.SetCustomMessage then
    AutoLFM.Logic.Broadcaster.SetCustomMessage(newText)
  end
  if AutoLFM.Logic.Broadcaster.UpdateMessage then
    AutoLFM.Logic.Broadcaster.UpdateMessage()
  end
  if AutoLFM.UI.MainWindow.UpdateMessagePreview then
    AutoLFM.UI.MainWindow.UpdateMessagePreview()
  end
  
  return true
end

-----------------------------------------------------------------------------
-- Quest Selection Management
-----------------------------------------------------------------------------
local function HasSelectedQuest()
  if not questButtons then return false end
  
  for i = 1, table.getn(questButtons) do
    local btn = questButtons[i]
    if btn and btn.checkbox and btn:IsShown() then
      if btn.checkbox:GetChecked() then
        return true
      end
    end
  end
  
  return false
end

local function UpdateInfoLabelState()
  if not questInfoLabelText then return end
  
  local hasSelected = HasSelectedQuest()
  
  if hasSelected then
    questInfoLabelText:SetTextColor(1, 0.82, 0)
  else
    questInfoLabelText:SetTextColor(0.5, 0.5, 0.5)
  end
end

local function UncheckAllQuestCheckboxes()
  if not questButtons then return end
  
  for i = 1, table.getn(questButtons) do
    local btn = questButtons[i]
    if btn and btn.checkbox then
      if btn.checkbox:GetChecked() then
        btn.checkbox:SetChecked(false)
        
        local questIndex = btn.questIndex
        if questIndex then
          local link = CreateQuestHyperlink(questIndex)
          if link then
            RemoveLinkFromEditBox(link)
          end
        end
      end
    end
  end
  
  UpdateInfoLabelState()
end

local function OnQuestCheckboxClick(checkbox, questIndex)
  if not checkbox or not questIndex then return end
  
  local link = CreateQuestHyperlink(questIndex)
  if not link then return end
  
  local isChecked = checkbox:GetChecked()
  
  if isChecked then
    InsertLinkToEditBox(link)
  else
    RemoveLinkFromEditBox(link)
  end
  
  UpdateInfoLabelState()
end

-----------------------------------------------------------------------------
-- Quest Button Creation
-----------------------------------------------------------------------------
local function CreateQuestButton(parent, index)
  local btn = AutoLFM.UI.PanelBuilder.CreateSelectableRow({
    parent = parent,
    frameName = "QuestListButton" .. index,
    checkboxName = "QuestCheckbox" .. index,
    yOffset = 0,
    mainText = "",
    rightText = "",
    color = {r = 1, g = 1, b = 1},
    isChecked = false,
    onCheckboxClick = function(checkbox, isChecked)
      local questIndex = checkbox:GetParent().questIndex
      if questIndex then
        OnQuestCheckboxClick(checkbox, questIndex)
      end
    end,
    customTooltip = function(frame)
      local questIndex = frame.questIndex
      if questIndex and questIndex > 0 then
        local numEntries = GetNumQuestLogEntries()
        if questIndex > numEntries then return end
        
        local title, level, questTag, suggestedGroup, isHeader = GetQuestLogTitle(questIndex)
        if not title or title == "" or isHeader then return end
        
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        GameTooltip:SetQuestLogItem("quest", questIndex)
        GameTooltip:Show()
      end
    end
  })
  
  if btn then
    btn.text = btn.label
    btn.levelText = btn.rightLabel
  end
  
  return btn
end

-----------------------------------------------------------------------------
-- Quest List Update
-----------------------------------------------------------------------------
local function UpdateQuestList()
  if not contentFrame then return end
  if not questButtons then return end
  
  for i = 1, table.getn(questButtons) do
    questButtons[i]:Hide()
  end
  
  local numEntries, numQuests = GetNumQuestLogEntries()
  
  if numQuests == 0 then
    contentFrame:SetHeight(1)
    return
  end
  
  local buttonIndex = 1
  
  for questIndex = 1, numEntries do
    local title, level, questTag, suggestedGroup, isHeader = GetQuestLogTitle(questIndex)
    local isDungeon = title and string.find(title, "%[%d+d%]")
    local isRaid = title and string.find(title, "%[%d+r%]")
    

    if level and level > 0 then
      if not questButtons[buttonIndex] then
        questButtons[buttonIndex] = CreateQuestButton(contentFrame, buttonIndex)
        if buttonIndex == 1 then
          questButtons[buttonIndex]:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, 0)
        else
          questButtons[buttonIndex]:SetPoint("TOPLEFT", questButtons[buttonIndex - 1], "BOTTOMLEFT", 0, 0)
        end
      end
      
      local btn = questButtons[buttonIndex]
      btn:Show()
      btn.questIndex = questIndex
      
      local displayTitle = title or "Unknown Quest"
      local rightLabel = ""
      
      local isDungeon = string.find(displayTitle, "%[%d+d%]")
      local isRaid = string.find(displayTitle, "%[%d+r%]")
      
      displayTitle = string.gsub(displayTitle, "^%[%d+%+?[dr]?%]%s*", "")

      if questTag == nil then
        rightLabel = ""
      else
        rightLabel = "(" .. tostring(questTag) .. ")"
      end

      local function TruncateText(text, maxLength)
        if not text then return "" end
        if string.len(text) <= maxLength then
          return text
        end

        -- Coupe à la limite
        local truncated = string.sub(text, 1, maxLength)

        -- Recule jusqu’au dernier espace pour ne pas couper le mot
        local lastSpace = string.find(truncated, " [^ ]*$")
        if lastSpace then
          truncated = string.sub(truncated, 1, lastSpace - 1)
        end

        return truncated .. "..."
      end

      displayTitle = "[" .. level .. "] " .. displayTitle
      displayTitle = TruncateText(displayTitle, 30)
      
      local playerLevel = UnitLevel("player")
      local priority = AutoLFM.Logic.Content.CalculateQuestPriority(playerLevel, level)
      
      local r, g, b = AutoLFM.Logic.Content.GetColor(priority, true)
      
      btn.text:SetText(displayTitle)
      btn.text:SetTextColor(r, g, b)
      
      btn.levelText:SetText(rightLabel)
      btn.levelText:SetTextColor(r, g, b)
      
      btn.originalR = r
      btn.originalG = g
      btn.originalB = b
      
      local link = CreateQuestHyperlink(questIndex)
      if link then
        btn.checkbox:SetChecked(IsQuestLinkInEditBox(link))
      end
      
      buttonIndex = buttonIndex + 1
    end
  end
  
  AutoLFM.UI.PanelBuilder.UpdateScrollHeight(contentFrame, buttonIndex - 1)
  
  UpdateInfoLabelState()
end

-----------------------------------------------------------------------------
-- Panel Management
-----------------------------------------------------------------------------
function AutoLFM.UI.QuestsPanel.Create(parentFrame)
  if not parentFrame then return nil end
  if mainFrame then return mainFrame end
  
  local panelData = AutoLFM.UI.PanelBuilder.CreatePanel(parentFrame, "AutoLFM_QuestsPanel")
  if not panelData then return nil end
  
  mainFrame = panelData.panel
  
  panelData = AutoLFM.UI.PanelBuilder.AddScrollFrame(panelData, "AutoLFM_ScrollFrame_Quests")
  scrollFrame = panelData.scrollFrame
  contentFrame = panelData.contentFrame
  
  UpdateQuestList()
  
  if scrollFrame.UpdateScrollChildRect then
    scrollFrame:UpdateScrollChildRect()
  end
  
  questInfoLabelButton, questInfoLabelText = AutoLFM.UI.PanelBuilder.CreateClickableLabel(
    panelData,
    "Uncheck all quests",
    function(btn, text)
      if HasSelectedQuest() then
        UncheckAllQuestCheckboxes()
      end
    end,
    function(btn, text)
      if HasSelectedQuest() then
        text:SetTextColor(1, 0, 0)
      end
    end,
    function(btn, text)
      UpdateInfoLabelState()
    end
  )
  
  questInfoLabelButton:SetWidth(questInfoLabelText:GetStringWidth() + 5)
  questInfoLabelText:SetTextColor(0.5, 0.5, 0.5)
  questInfoLabelFrame = panelData.bottomZone
  
  UpdateInfoLabelState()
  
  local questUpdateFrame = CreateFrame("Frame")
  questUpdateFrame:RegisterEvent("QUEST_LOG_UPDATE")
  questUpdateFrame:SetScript("OnEvent", function()
    UpdateQuestList()
    if scrollFrame and scrollFrame.UpdateScrollChildRect then
      scrollFrame:UpdateScrollChildRect()
    end
    UpdateInfoLabelState()
  end)
  
  return mainFrame
end

function AutoLFM.UI.QuestsPanel.Show()
  AutoLFM.UI.PanelBuilder.ShowPanel(mainFrame, scrollFrame)
  
  UpdateQuestList()
  
  if AutoLFM.UI.RaidsPanel.HideSizeControls then
    AutoLFM.UI.RaidsPanel.HideSizeControls()
  end
  
  if AutoLFM.UI.DungeonsPanel.ClearBackdrops then
    AutoLFM.UI.DungeonsPanel.ClearBackdrops()
  end
  
  if AutoLFM.UI.RaidsPanel.ClearBackdrops then
    AutoLFM.UI.RaidsPanel.ClearBackdrops()
  end
  
  UpdateInfoLabelState()
end

function AutoLFM.UI.QuestsPanel.Hide()
  AutoLFM.UI.PanelBuilder.HidePanel(mainFrame, scrollFrame)
end

function AutoLFM.UI.QuestsPanel.GetFrame()
  return mainFrame
end

function AutoLFM.UI.QuestsPanel.GetContentFrame()
  return contentFrame
end

function AutoLFM.UI.QuestsPanel.GetScrollFrame()
  return scrollFrame
end

function AutoLFM.UI.QuestsPanel.Register()
  AutoLFM.UI.TabNavigation.RegisterPanel("quests",
    AutoLFM.UI.QuestsPanel.Show,
    AutoLFM.UI.QuestsPanel.Hide,
    function()
      if AutoLFM.UI.RaidsPanel.HideSizeControls then
      AutoLFM.UI.RaidsPanel.HideSizeControls()
      end
      if AutoLFM.UI.DungeonsPanel.ClearBackdrops then
      AutoLFM.UI.DungeonsPanel.ClearBackdrops()
      end
      if AutoLFM.UI.RaidsPanel.ClearBackdrops then
      AutoLFM.UI.RaidsPanel.ClearBackdrops()
      end
    end
  )
end
