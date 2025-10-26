--=============================================================================
-- AutoLFM: Quests Panel
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.QuestsPanel then AutoLFM.UI.QuestsPanel = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local questsPanelFrame = nil
local questScrollFrame = nil
local questListContentFrame = nil
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
  if not title or title == "" then return nil end
  
  questID = questID or 0
  level = level or 0
  
  local cleanTitle = string.gsub(title, "^%[.-%]%s*", "")
  
  return AutoLFM.Logic.Content.CreateQuestLink(questID, level, cleanTitle)
end

local function IsQuestLinkInEditBox(link)
  if not link then return false end
  if not AutoLFM_MainFrame or not AutoLFM_MainFrame:IsVisible() then return false end
  
  local editBox = nil
  if AutoLFM.UI.MorePanel.GetCustomMessageEditBox then
    editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
  end
  
  if not editBox then return false end
  
  local currentText = editBox:GetText() or ""
  local escapedLink = string.gsub(link, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
  
  return string.find(currentText, escapedLink) ~= nil
end

local function RemoveLinkFromEditBox(link)
  if not link then return false end
  if not AutoLFM_MainFrame or not AutoLFM_MainFrame:IsVisible() then return false end
  
  local editBox = nil
  if AutoLFM.UI.MorePanel.GetCustomMessageEditBox then
    editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
  end
  
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
  
  local editBox = nil
  if AutoLFM.UI.MorePanel.GetCustomMessageEditBox then
    editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
  end
  
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
  local btn = CreateFrame("Button", "QuestListButton" .. index, parent)
  btn:SetWidth(300)
  btn:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ROW_HEIGHT)
  
  local checkbox = CreateFrame("CheckButton", "QuestCheckbox" .. index, btn, "UICheckButtonTemplate")
  checkbox:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.CHECKBOX_SIZE)
  checkbox:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.CHECKBOX_SIZE)
  checkbox:SetPoint("LEFT", btn, "LEFT", 0, 0)
  btn.checkbox = checkbox
  
  local levelLabel = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  levelLabel:SetPoint("RIGHT", btn, "RIGHT", -10, 0)
  levelLabel:SetText("")
  btn.levelText = levelLabel
  
  local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  text:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
  text:SetText("")
  btn.text = text
  
  AutoLFM.UI.PanelBuilder.SetupCheckboxClick(
    checkbox,
    function(isChecked)
      local questIndex = checkbox:GetParent().questIndex
      if questIndex then
        OnQuestCheckboxClick(checkbox, questIndex)
      end
    end
  )
  
  AutoLFM.UI.PanelBuilder.SetupClickToToggle(
    btn,
    checkbox,
    function(isChecked)
      OnQuestCheckboxClick(checkbox, btn.questIndex)
    end
  )
  
  btn:SetScript("OnEnter", function()
    local questIndex = this.questIndex
    if questIndex and questIndex > 0 then
      local numEntries = GetNumQuestLogEntries()
      if questIndex > numEntries then return end
      
      local title, level, questTag, suggestedGroup, isHeader = GetQuestLogTitle(questIndex)
      if not title or title == "" or isHeader then return end
      
      local r, g, b = btn.originalR or 1, btn.originalG or 0.82, btn.originalB or 0
      
      btn:SetBackdrop({
        bgFile = AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "white",
        insets = {left = 1, right = 1, top = 1, bottom = 1},
      })
      btn:SetBackdropColor(r, g, b, 0.3)
      btn.text:SetTextColor(1, 1, 1)
      btn.levelText:SetTextColor(1, 1, 1)
      btn.checkbox:LockHighlight()
      
      pcall(function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetQuestLogItem("quest", questIndex)
        GameTooltip:Show()
      end)
    end
  end)
  
  btn:SetScript("OnLeave", function()
    btn:SetBackdrop(nil)
    
    if btn.originalR and btn.originalG and btn.originalB then
      btn.text:SetTextColor(btn.originalR, btn.originalG, btn.originalB)
      btn.levelText:SetTextColor(btn.originalR, btn.originalG, btn.originalB)
    end
    
    btn.checkbox:UnlockHighlight()
    AutoLFM.UI.PanelBuilder.HideTooltip()
  end)
  
  return btn
end

-----------------------------------------------------------------------------
-- Quest List Update
-----------------------------------------------------------------------------
local function UpdateQuestList()
  if not questListContentFrame then return end
  if not questButtons then return end
  
  for i = 1, table.getn(questButtons) do
    questButtons[i]:Hide()
  end
  
  local numEntries, numQuests = GetNumQuestLogEntries()
  
  if numQuests == 0 then
    questListContentFrame:SetHeight(1)
    return
  end
  
  local buttonIndex = 1
  
  for questIndex = 1, numEntries do
    local title, level, questTag, suggestedGroup, isHeader, isCollapsed = GetQuestLogTitle(questIndex)
    
    if not isHeader and level and level > 0 then
      if not questButtons[buttonIndex] then
        questButtons[buttonIndex] = CreateQuestButton(questListContentFrame, buttonIndex)
        if buttonIndex == 1 then
          questButtons[buttonIndex]:SetPoint("TOPLEFT", questListContentFrame, "TOPLEFT", 0, 0)
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
      
      if isDungeon then
        displayTitle = string.gsub(displayTitle, "%[(%d+)d%]", "[%1]")
        rightLabel = "(Dungeon)"
      elseif isRaid then
        displayTitle = string.gsub(displayTitle, "%[(%d+)r%]", "[%1]")
        rightLabel = "(Raid)"
      end
      
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
  
  AutoLFM.UI.PanelBuilder.UpdateScrollHeight(questListContentFrame, buttonIndex - 1)
  
  UpdateInfoLabelState()
end

-----------------------------------------------------------------------------
-- Panel Management
-----------------------------------------------------------------------------
function AutoLFM.UI.QuestsPanel.Create(parentFrame)
  if not parentFrame then return nil end
  if questsPanelFrame then return questsPanelFrame end
  
  local panelData = AutoLFM.UI.PanelBuilder.CreatePanel(parentFrame, "AutoLFM_QuestsPanel")
  if not panelData then return nil end
  
  questsPanelFrame = panelData.panel
  
  panelData = AutoLFM.UI.PanelBuilder.AddScrollFrame(panelData, "AutoLFM_ScrollFrame_Quests")
  questScrollFrame = panelData.scrollFrame
  questListContentFrame = panelData.contentFrame
  
  UpdateQuestList()
  
  if questScrollFrame.UpdateScrollChildRect then
    questScrollFrame:UpdateScrollChildRect()
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
    if questScrollFrame and questScrollFrame.UpdateScrollChildRect then
      questScrollFrame:UpdateScrollChildRect()
    end
    UpdateInfoLabelState()
  end)
  
  return questsPanelFrame
end

function AutoLFM.UI.QuestsPanel.Show()
  AutoLFM.UI.PanelBuilder.ShowPanel(questsPanelFrame, questScrollFrame)
  
  UpdateQuestList()
  
  if AutoLFM_RaidList and AutoLFM_RaidList.HideSizeControls then
    AutoLFM_RaidList.HideSizeControls()
  end
  
  if AutoLFM_DungeonList and AutoLFM_DungeonList.ClearBackdrops then
    AutoLFM_DungeonList.ClearBackdrops()
  end
  
  if AutoLFM_RaidList and AutoLFM_RaidList.ClearBackdrops then
    AutoLFM_RaidList.ClearBackdrops()
  end
  
  UpdateInfoLabelState()
end

function AutoLFM.UI.QuestsPanel.Hide()
  AutoLFM.UI.PanelBuilder.HidePanel(questsPanelFrame, questScrollFrame)
end

function AutoLFM.UI.QuestsPanel.GetFrame()
  return questsPanelFrame
end

function AutoLFM.UI.QuestsPanel.GetContentFrame()
  return questListContentFrame
end

function AutoLFM.UI.QuestsPanel.GetScrollFrame()
  return questScrollFrame
end

function AutoLFM.UI.QuestsPanel.Register()
  AutoLFM.UI.TabNavigation.RegisterPanel("quests",
    AutoLFM.UI.QuestsPanel.Show,
    AutoLFM.UI.QuestsPanel.Hide,
    function()
      if AutoLFM_RaidList and AutoLFM_RaidList.HideSizeControls then
        AutoLFM_RaidList.HideSizeControls()
      end
      if AutoLFM_DungeonList and AutoLFM_DungeonList.ClearBackdrops then
        AutoLFM_DungeonList.ClearBackdrops()
      end
      if AutoLFM_RaidList and AutoLFM_RaidList.ClearBackdrops then
        AutoLFM_RaidList.ClearBackdrops()
      end
    end
  )
end
