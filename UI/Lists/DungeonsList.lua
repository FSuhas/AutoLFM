--------------------------------------------------
-- Dungeons List UI
--------------------------------------------------
if not AutoLFM_DungeonList then
  AutoLFM_DungeonList = {}
end
local clickableFrames = {}
local checkButtons = {}
local dungeonRows = {}

--------------------------------------------------
-- Get Priority Color
--------------------------------------------------
local function GetPriorityColor(priority)
  if not PRIORITY_COLOR_SCHEME then return 0.5, 0.5, 0.5 end
  for _, color in ipairs(PRIORITY_COLOR_SCHEME) do
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
  if not frame or not checkbox then return end
  
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
  if not checkbox or not dungeonTag then return end
  
  local isChecked = checkbox:GetChecked()
  ToggleDungeonSelection(dungeonTag, isChecked)
  
  UpdateDungeonBackdrop(checkbox:GetParent(), checkbox)
end

--------------------------------------------------
-- Create Single Dungeon Row
--------------------------------------------------
local function CreateDungeonRow(parent, dungeon, priority, yOffset)
  if not parent or not dungeon then return nil end
  
  local clickableFrame = CreateFrame("Button", "ClickableDungeonFrame" .. dungeon.tag, parent)
  clickableFrame:SetHeight(20)
  clickableFrame:SetWidth(300)
  clickableFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -yOffset)
  
  local checkbox = CreateFrame("CheckButton", "DungeonCheckbox" .. dungeon.tag, clickableFrame, "UICheckButtonTemplate")
  checkbox:SetWidth(20)
  checkbox:SetHeight(20)
  checkbox:SetPoint("LEFT", clickableFrame, "LEFT", 0, 0)
  
  checkbox:SetChecked(IsDungeonSelected(dungeon.tag))
  
  checkButtons[dungeon.tag] = checkbox
  
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
  
  clickableFrame.dungeonTag = dungeon.tag
  clickableFrame.priority = priority
  
  table.insert(clickableFrames, clickableFrame)
  dungeonRows[dungeon.tag] = clickableFrame
  
  return clickableFrame
end

--------------------------------------------------
-- Update Row Visibility Based on Filters
--------------------------------------------------
local function UpdateRowVisibility()
  if not dungeonRows then return end
  
  local yOffset = 0
  local visibleCount = 0
  
  for _, entry in ipairs(GetSortedDungeonsByPriority(UnitLevel("player"))) do
    if entry and entry.dungeon then
      local dungeonTag = entry.dungeon.tag
      local priority = entry.priority
      local frame = dungeonRows[dungeonTag]
      
      if frame then
        if ShouldShowPriorityLevel(priority) then
          frame:Show()
          frame:ClearAllPoints()
          frame:SetPoint("TOPLEFT", frame:GetParent(), "TOPLEFT", 0, -yOffset)
          yOffset = yOffset + 20
          visibleCount = visibleCount + 1
        else
          frame:Hide()
        end
      end
    end
  end
  
  local parent = nil
  for _, frame in pairs(dungeonRows) do
    if frame then
      parent = frame:GetParent()
      break
    end
  end
  
  if parent and parent.SetHeight then
    local contentHeight = visibleCount * 20
    parent:SetHeight(math.max(contentHeight, 1))
  end
end

--------------------------------------------------
-- Display All Dungeons
--------------------------------------------------
function AutoLFM_DungeonList.Display(parent)
  if not parent then return end
  
  for _, child in ipairs({parent:GetChildren()}) do
    child:Hide()
  end
  
  clickableFrames = {}
  checkButtons = {}
  dungeonRows = {}
  
  local playerLevel = UnitLevel("player")
  if not playerLevel or playerLevel < 1 then
    playerLevel = 1
  end
  
  local sortedDungeons = GetSortedDungeonsByPriority(playerLevel)
  local yOffset = 0
  local visibleCount = 0
  
  for _, entry in ipairs(sortedDungeons) do
    if entry and entry.dungeon then
      local frame = CreateDungeonRow(parent, entry.dungeon, entry.priority, yOffset)
      if frame then
        if ShouldShowPriorityLevel(entry.priority) then
          yOffset = yOffset + 20
          visibleCount = visibleCount + 1
        else
          frame:Hide()
        end
      end
    end
  end
  
  if parent and parent.SetHeight then
    local contentHeight = visibleCount * 20
    parent:SetHeight(math.max(contentHeight, 1))
  end
end

--------------------------------------------------
-- Refresh Display
--------------------------------------------------
function AutoLFM_DungeonList.Refresh()
  UpdateRowVisibility()
  
  local dungeonScrollFrame = GetDungeonScrollFrame()
  if dungeonScrollFrame and dungeonScrollFrame.UpdateScrollChildRect then
    dungeonScrollFrame:UpdateScrollChildRect()
  end
end

--------------------------------------------------
-- Clear Selection UI
--------------------------------------------------
function AutoLFM_DungeonList.ClearSelection()
  ClearDungeonSelection()
  
  for _, checkbox in pairs(checkButtons) do
    if checkbox and checkbox.SetChecked then
      checkbox:SetChecked(false)
    end
  end
end

--------------------------------------------------
-- Clear Backdrops
--------------------------------------------------
function AutoLFM_DungeonList.ClearBackdrops()
  for _, frame in pairs(clickableFrames) do
    if frame and frame.SetBackdrop then
      frame:SetBackdrop(nil)
    end
  end
end

--------------------------------------------------
-- Update Checkboxes from State
--------------------------------------------------
function AutoLFM_DungeonList.UpdateCheckboxes()
  for dungeonTag, checkbox in pairs(checkButtons) do
    if checkbox and checkbox.SetChecked then
      checkbox:SetChecked(IsDungeonSelected(dungeonTag))
    end
  end
end

--------------------------------------------------
-- Uncheck Specific Dungeon
--------------------------------------------------
function AutoLFM_DungeonList.UncheckDungeon(dungeonTag)
  if not dungeonTag then return end
  if not checkButtons then return end
  
  local checkbox = checkButtons[dungeonTag]
  if checkbox and checkbox.SetChecked then
    checkbox:SetChecked(false)
    
    local frame = checkbox:GetParent()
    if frame and frame.SetBackdrop then
      frame:SetBackdrop(nil)
    end
  end
end