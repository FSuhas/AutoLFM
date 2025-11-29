--=============================================================================
-- AutoLFM: Quests Panel
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.QuestsPanel then AutoLFM.UI.QuestsPanel = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local mainFrame, scrollFrame, contentFrame
local questButtons = {}
local questInfoLabelFrame, questInfoLabelButton, questInfoLabelText

-----------------------------------------------------------------------------
-- Quest Link Utilities
-----------------------------------------------------------------------------
local function CreateQuestHyperlink(questIndex)
  if not questIndex or questIndex < 1 then return nil end

  local title, level, _, _, _, _, _, questID = GetQuestLogTitle(questIndex)
  if not title then return nil end

  questID, level = questID or 0, level or 0
  local cleanTitle = string.gsub(title, "^%[.-%]%s*", "")

  return AutoLFM.Logic.Content.CreateQuestLink(questID, level, cleanTitle)
end

local function GetEditBox()
  if not AutoLFM_MainFrame or not AutoLFM_MainFrame:IsVisible() then return nil end
  return AutoLFM.UI.MorePanel.GetCustomMessageEditBox and AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
end

local function UpdateCustomMessage(newText)
  if AutoLFM.Logic.Broadcaster.SetCustomMessage then
    AutoLFM.Logic.Broadcaster.SetCustomMessage(newText)
  end
  if AutoLFM.Logic.Broadcaster.UpdateMessage then
    AutoLFM.Logic.Broadcaster.UpdateMessage()
  end
  if AutoLFM.UI.MainWindow.UpdateMessagePreview then
    AutoLFM.UI.MainWindow.UpdateMessagePreview()
  end
end

local function IsQuestLinkInEditBox(link)
  local editBox = GetEditBox()
  if not link or not editBox then return false end

  local currentText = editBox:GetText() or ""
  local escapedLink = string.gsub(link, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
  return string.find(currentText, escapedLink) ~= nil
end

local function RemoveLinkFromEditBox(link)
  local editBox = GetEditBox()
  if not link or not editBox then return false end

  local pattern = string.gsub(link, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
  local currentText = editBox:GetText() or ""
  local newText = string.gsub(currentText, pattern, "")
  newText = AutoLFM.Logic.Content.CleanQuestText(newText)

  editBox:SetText(newText)
  UpdateCustomMessage(newText)
  return true
end

local function InsertLinkToEditBox(link)
  local editBox = GetEditBox()
  if not link or not editBox then return false end

  local currentText = editBox:GetText() or ""
  local newText = currentText == "" and link or (currentText .. " " .. link)

  editBox:SetText(newText)
  editBox:SetFocus()
  editBox:HighlightText(0, 0)
  UpdateCustomMessage(newText)
  return true
end

-----------------------------------------------------------------------------
-- Quest Selection Management
-----------------------------------------------------------------------------
local function HasSelectedQuest()
  for _, btn in ipairs(questButtons) do
    if btn.checkbox and btn.checkbox:GetChecked() then
      return true
    end
  end
  return false
end

local function UpdateInfoLabelState()
  if not questInfoLabelText then return end
  if HasSelectedQuest() then
    AutoLFM.Core.Utils.SetFontColor(questInfoLabelText, "gold")
  else
    AutoLFM.Core.Utils.SetFontColor(questInfoLabelText, "gray")
  end
end

function AutoLFM.UI.QuestsPanel.UncheckAllQuestCheckboxes()
  for _, btn in ipairs(questButtons) do
    if btn.checkbox and btn.checkbox:GetChecked() then
      btn.checkbox:SetChecked(false)
      local link = CreateQuestHyperlink(btn.questIndex)
      if link then RemoveLinkFromEditBox(link) end
    end
  end
  UpdateInfoLabelState()
end

local function OnQuestCheckboxClick(checkbox, questIndex)
  local link = CreateQuestHyperlink(questIndex)
  if not link then return end
  if checkbox:GetChecked() then
    InsertLinkToEditBox(link)
  else
    RemoveLinkFromEditBox(link)
  end
  UpdateInfoLabelState()
end

-----------------------------------------------------------------------------
-- Text Utilities
-----------------------------------------------------------------------------

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
    onCheckboxClick = function(checkbox)
      OnQuestCheckboxClick(checkbox, checkbox:GetParent().questIndex)
    end,
    customTooltip = function(frame)
      local questIndex = frame.questIndex
      if not questIndex or questIndex <= 0 then return end

      local title, level, _, _, isHeader = GetQuestLogTitle(questIndex)
      if not title or title == "" or isHeader then return end

      local questZone
      for i = questIndex - 1, 1, -1 do
        local headerTitle, headerLevel = GetQuestLogTitle(i)
        if headerTitle and (not headerLevel or headerLevel == 0) then
          questZone = headerTitle
          break
        end
      end

      if questZone then
        local scale = UIParent:GetEffectiveScale()
        local x, y = GetCursorPosition()
        x, y = x / scale, y / scale
        GameTooltip:SetOwner(frame, "ANCHOR_NONE")
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", x + 10, y - 10)
        GameTooltip:SetText(questZone, 1, 0.82, 0)
        GameTooltip:Show()
      end
    end
  })

  btn.text, btn.levelText = btn.label, btn.rightLabel
  return btn
end

-----------------------------------------------------------------------------
-- Quest List Update
-----------------------------------------------------------------------------
local function UpdateQuestList()
  if not contentFrame or not questButtons then return end

  for _, btn in ipairs(questButtons) do
    btn:Hide()
  end

  local numEntries, numQuests = GetNumQuestLogEntries()
  if numQuests == 0 then
    contentFrame:SetHeight(1)
    return
  end

  local buttonIndex = 1

  local questData = {}
  for questIndex = 1, numEntries do
    local title, level, questTag, _, isHeader = GetQuestLogTitle(questIndex)
    questData[questIndex] = {title = title, level = level, tag = questTag, isHeader = isHeader}
  end

  local playerLevel = UnitLevel("player")

  for questIndex = 1, numEntries do
    local q = questData[questIndex]
    if q.level and q.level > 0 and not q.isHeader then
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

      local displayTitle = q.title or "Unknown Quest"
      displayTitle = string.gsub(displayTitle, "^%[%d+%+?[dr]?%]%s*", "")
      displayTitle = "[" .. q.level .. "] " .. AutoLFM.Core.Utils.TruncateByLength(displayTitle, 25)

      local rightLabel = q.tag and "(" .. tostring(q.tag) .. ")" or ""

      local priority = AutoLFM.Logic.Content.CalculateQuestPriority(playerLevel, q.level)
      local r, g, b = AutoLFM.Logic.Content.GetColor(priority, true)

      btn.text:SetText(displayTitle)
      AutoLFM.Core.Utils.SetFontColor(btn.text, priority)
      btn.levelText:SetText(rightLabel)
      AutoLFM.Core.Utils.SetFontColor(btn.levelText, priority)

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
function AutoLFM.UI.QuestsPanel.Init()
  if mainFrame then return mainFrame end
  local parentFrame = AutoLFM.UI.MainWindow.GetFrame()
  if not parentFrame then return nil end

  local panelData = AutoLFM.UI.PanelBuilder.CreatePanel(parentFrame, "AutoLFM_QuestsPanel")
  mainFrame = panelData.panel

  panelData = AutoLFM.UI.PanelBuilder.AddScrollFrame(panelData, "AutoLFM_ScrollFrame_Quests")
  scrollFrame, contentFrame = panelData.scrollFrame, panelData.contentFrame

  UpdateQuestList()
  if scrollFrame.UpdateScrollChildRect then scrollFrame:UpdateScrollChildRect() end

  questInfoLabelButton, questInfoLabelText = AutoLFM.UI.PanelBuilder.CreateClickableLabel(
    panelData,
    "Uncheck all quests",
    function() if HasSelectedQuest() then AutoLFM.UI.QuestsPanel.UncheckAllQuestCheckboxes() end end,
    function(_, text) if HasSelectedQuest() then AutoLFM.Core.Utils.SetFontColor(text, "red") end end,
    function() UpdateInfoLabelState() end
  )

  questInfoLabelButton:SetWidth(questInfoLabelText:GetStringWidth() + 5)
  AutoLFM.Core.Utils.SetFontColor(questInfoLabelText, "gray")
  questInfoLabelFrame = panelData.bottomZone
  UpdateInfoLabelState()

  local questUpdateFrame = CreateFrame("Frame")
  questUpdateFrame:RegisterEvent("QUEST_LOG_UPDATE")
  questUpdateFrame:SetScript("OnEvent", function()
    UpdateQuestList()
    if scrollFrame.UpdateScrollChildRect then scrollFrame:UpdateScrollChildRect() end
    UpdateInfoLabelState()
  end)

  AutoLFM.UI.DarkUI.RegisterFrame(mainFrame)

  AutoLFM.UI.QuestsPanel.Register()
end

function AutoLFM.UI.QuestsPanel.Show()
  AutoLFM.UI.PanelBuilder.ShowPanel(mainFrame, scrollFrame)
  UpdateQuestList()

  if AutoLFM.UI.RaidsPanel.HideSizeControls then AutoLFM.UI.RaidsPanel.HideSizeControls() end
  if AutoLFM.UI.DungeonsPanel.ClearBackdrops then AutoLFM.UI.DungeonsPanel.ClearBackdrops() end
  if AutoLFM.UI.RaidsPanel.ClearBackdrops then AutoLFM.UI.RaidsPanel.ClearBackdrops() end

  UpdateInfoLabelState()
end

function AutoLFM.UI.QuestsPanel.Hide()
  AutoLFM.UI.PanelBuilder.HidePanel(mainFrame, scrollFrame)
end

function AutoLFM.UI.QuestsPanel.GetFrame() return mainFrame end
function AutoLFM.UI.QuestsPanel.GetContentFrame() return contentFrame end
function AutoLFM.UI.QuestsPanel.GetScrollFrame() return scrollFrame end

function AutoLFM.UI.QuestsPanel.Register()
  AutoLFM.UI.TabNavigation.RegisterPanel("quests",
    AutoLFM.UI.QuestsPanel.Show,
    AutoLFM.UI.QuestsPanel.Hide,
    function()
      if AutoLFM.UI.RaidsPanel.HideSizeControls then AutoLFM.UI.RaidsPanel.HideSizeControls() end
      if AutoLFM.UI.DungeonsPanel.ClearBackdrops then AutoLFM.UI.DungeonsPanel.ClearBackdrops() end
      if AutoLFM.UI.RaidsPanel.ClearBackdrops then AutoLFM.UI.RaidsPanel.ClearBackdrops() end
    end
  )
end
