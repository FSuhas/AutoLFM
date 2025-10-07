--------------------------------------------------
-- Dungeon List UI
--------------------------------------------------
if not AutoLFM_DungeonList then
  AutoLFM_DungeonList = {
    clickableFrames = {},
    checkButtons = {}
  }
end

--------------------------------------------------
-- Get Priority Color
--------------------------------------------------
local function GetPriorityColor(priority)
  for _, color in ipairs(PRIORITY_COLOR_SCHEME or {}) do
    if color.priority == priority then
      return color.r, color.g, color.b
    end
  end
  return 0.5, 0.5, 0.5
end

--------------------------------------------------
-- Update Backdrop
--------------------------------------------------
local function UpdateDungeonBackdrop(frame, checkbox)
  if checkbox:GetChecked() then
    frame:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
      insets = {left = 1, right = 1, top = 1, bottom = 1},
    })
    frame:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
  else
    frame:SetBackdrop(nil)
  end
end

--------------------------------------------------
-- Checkbox Click Handler
--------------------------------------------------
local function OnDungeonCheckboxClick(checkbox, dungeonTag)
  local isChecked = checkbox:GetChecked()
  
  if isChecked then
    if customMessageEditBox then customMessageEditBox:Show() end
    if broadcastIntervalFrame then broadcastIntervalFrame:Show() end
    if broadcastToggleButton then broadcastToggleButton:Show() end
    if dungeonMessageDisplayFrame then dungeonMessageDisplayFrame:Show() end
    
    local alreadySelected = false
    for _, val in ipairs(selectedDungeonTags) do
      if val == dungeonTag then
        alreadySelected = true
        break
      end
    end
    
    if not alreadySelected then
      if table.getn(selectedDungeonTags) >= 4 then
        local first = selectedDungeonTags[1]
        table.remove(selectedDungeonTags, 1)
        if AutoLFM_DungeonList.checkButtons[first] then
          AutoLFM_DungeonList.checkButtons[first]:SetChecked(false)
          AutoLFM_DungeonList.checkButtons[first]:GetParent():SetBackdrop(nil)
        end
      end
      table.insert(selectedDungeonTags, dungeonTag)
    end
  else
    for i, val in ipairs(selectedDungeonTags) do
      if val == dungeonTag then
        table.remove(selectedDungeonTags, i)
        break
      end
    end
  end
  
  UpdateDungeonBackdrop(checkbox:GetParent(), checkbox)
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end

--------------------------------------------------
-- Create Single Dungeon Row
--------------------------------------------------
local function CreateDungeonRow(parent, dungeon, priority, yOffset)
  if ShouldShowPriorityLevel and not ShouldShowPriorityLevel(priority) then
    return nil
  end
  
  local clickableFrame = CreateFrame("Button", "ClickableDungeonFrame" .. dungeon.tag, parent)
  clickableFrame:SetHeight(20)
  clickableFrame:SetWidth(300)
  clickableFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -yOffset)
  
  local checkbox = CreateFrame("CheckButton", "DungeonCheckbox" .. dungeon.tag, clickableFrame, "UICheckButtonTemplate")
  checkbox:SetWidth(20)
  checkbox:SetHeight(20)
  checkbox:SetPoint("LEFT", clickableFrame, "LEFT", 0, 0)
  AutoLFM_DungeonList.checkButtons[dungeon.tag] = checkbox
  
  local levelLabel = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  levelLabel:SetPoint("RIGHT", clickableFrame, "RIGHT", -10, 0)
  levelLabel:SetText("(" .. dungeon.levelMin .. " - " .. dungeon.levelMax .. ")")
  
  local label = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
  label:SetText(dungeon.name)
  
  local r, g, b = GetPriorityColor(priority)
  label:SetTextColor(r, g, b)
  levelLabel:SetTextColor(r, g, b)
  
  clickableFrame:SetScript("OnClick", function()
    checkbox:SetChecked(not checkbox:GetChecked())
    OnDungeonCheckboxClick(checkbox, dungeon.tag)
  end)
  
  clickableFrame:SetScript("OnEnter", function()
    clickableFrame:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
      insets = {left = 1, right = 1, top = 1, bottom = 1},
    })
    clickableFrame:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
    checkbox:LockHighlight()
  end)
  
  clickableFrame:SetScript("OnLeave", function()
    if not checkbox:GetChecked() then
      clickableFrame:SetBackdrop(nil)
    else
      UpdateDungeonBackdrop(clickableFrame, checkbox)
    end
    checkbox:UnlockHighlight()
  end)
  
  checkbox:SetScript("OnClick", function()
    OnDungeonCheckboxClick(checkbox, dungeon.tag)
  end)
  
  table.insert(AutoLFM_DungeonList.clickableFrames, clickableFrame)
  
  return clickableFrame
end

--------------------------------------------------
-- Display All Dungeons
--------------------------------------------------
function AutoLFM_DungeonList.Display(parent)
  if not parent then return end
  
  for _, child in ipairs({parent:GetChildren()}) do
    child:Hide()
  end
  
  local playerLevel = UnitLevel("player")
  if not playerLevel or playerLevel < 1 then
    playerLevel = 1
  end
  
  local yOffset = 0
  local sortedDungeons = {}
  
  for index, dungeon in ipairs(DUNGEON_DATABASE or {}) do
    if dungeon then
      local priority = CalculateDungeonPriority and CalculateDungeonPriority(playerLevel, dungeon) or 4
      table.insert(sortedDungeons, {
        dungeon = dungeon,
        priority = priority,
        originalIndex = index
      })
    end
  end
  
  table.sort(sortedDungeons, function(a, b)
    if a.priority == b.priority then
      return a.originalIndex < b.originalIndex
    else
      return a.priority < b.priority
    end
  end)
  
  AutoLFM_DungeonList.clickableFrames = {}
  
  for _, entry in ipairs(sortedDungeons) do
    if entry and entry.dungeon then
      local frame = CreateDungeonRow(parent, entry.dungeon, entry.priority, yOffset)
      if frame then
        yOffset = yOffset + 20
      end
    end
  end
end

--------------------------------------------------
-- Clear Selection
--------------------------------------------------
function AutoLFM_DungeonList.ClearSelection()
  for _, checkbox in pairs(AutoLFM_DungeonList.checkButtons) do
    checkbox:SetChecked(false)
  end
  if selectedDungeonTags then
    selectedDungeonTags = {}
  end
end

--------------------------------------------------
-- Clear Backdrops
--------------------------------------------------
function AutoLFM_DungeonList.ClearBackdrops()
  for _, frame in pairs(AutoLFM_DungeonList.clickableFrames) do
    if frame and frame.SetBackdrop then
      frame:SetBackdrop(nil)
    end
  end
end