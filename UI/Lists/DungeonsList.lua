--------------------------------------------------
-- Dungeons List UI
--------------------------------------------------

if not AutoLFM_DungeonList then
  AutoLFM_DungeonList = {}
end

local clickableFrames = {}
local checkButtons = {}
local dungeonRows = {}  -- NOUVEAU : stocke toutes les lignes créées

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
  
  -- Checkbox
  local checkbox = CreateFrame("CheckButton", "DungeonCheckbox" .. dungeon.tag, clickableFrame, "UICheckButtonTemplate")
  checkbox:SetWidth(20)
  checkbox:SetHeight(20)
  checkbox:SetPoint("LEFT", clickableFrame, "LEFT", 0, 0)
  
  -- Set checked state from manager
  checkbox:SetChecked(IsDungeonSelected(dungeon.tag))
  
  checkButtons[dungeon.tag] = checkbox
  
  -- Level label
  local levelLabel = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  levelLabel:SetPoint("RIGHT", clickableFrame, "RIGHT", -10, 0)
  levelLabel:SetText("(" .. dungeon.levelMin .. " - " .. dungeon.levelMax .. ")")
  
  -- Name label
  local label = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
  label:SetText(dungeon.name)
  
  -- Apply priority color
  local r, g, b = GetPriorityColor(priority)
  label:SetTextColor(r, g, b)
  levelLabel:SetTextColor(r, g, b)
  
  -- Frame click handler
  clickableFrame:SetScript("OnClick", function()
    checkbox:SetChecked(not checkbox:GetChecked())
    OnDungeonCheckboxClick(checkbox, dungeon.tag)
  end)
  
  -- Hover handlers
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
  
  -- Checkbox click handler
  checkbox:SetScript("OnClick", function()
    OnDungeonCheckboxClick(checkbox, dungeon.tag)
  end)
  
  -- Store row data
  clickableFrame.dungeonTag = dungeon.tag
  clickableFrame.priority = priority
  
  table.insert(clickableFrames, clickableFrame)
  dungeonRows[dungeon.tag] = clickableFrame  -- NOUVEAU : indexer par tag
  
  return clickableFrame
end

--------------------------------------------------
-- Update Row Visibility Based on Filters
--------------------------------------------------
local function UpdateRowVisibility()
  if not dungeonRows then return end
  
  local yOffset = 0
  
  for _, entry in ipairs(GetSortedDungeonsByPriority(UnitLevel("player"))) do
    if entry and entry.dungeon then
      local dungeonTag = entry.dungeon.tag
      local priority = entry.priority
      local frame = dungeonRows[dungeonTag]
      
      if frame then
        -- Check if this priority should be shown
        if ShouldShowPriorityLevel(priority) then
          frame:Show()
          frame:SetPoint("TOPLEFT", frame:GetParent(), "TOPLEFT", 0, -yOffset)
          yOffset = yOffset + 20
        else
          frame:Hide()
        end
      end
    end
  end
end

--------------------------------------------------
-- Display All Dungeons
--------------------------------------------------
function AutoLFM_DungeonList.Display(parent)
  if not parent then return end
  
  -- Hide all existing children
  for _, child in ipairs({parent:GetChildren()}) do
    child:Hide()
  end
  
  clickableFrames = {}
  checkButtons = {}
  dungeonRows = {}  -- NOUVEAU : réinitialiser
  
  local playerLevel = UnitLevel("player")
  if not playerLevel or playerLevel < 1 then
    playerLevel = 1
  end
  
  -- Get sorted dungeons from manager
  local sortedDungeons = GetSortedDungeonsByPriority(playerLevel)
  
  local yOffset = 0
  
  -- Create ALL rows (even hidden ones)
  for _, entry in ipairs(sortedDungeons) do
    if entry and entry.dungeon then
      local frame = CreateDungeonRow(parent, entry.dungeon, entry.priority, yOffset)
      if frame then
        -- Check if should be visible initially
        if ShouldShowPriorityLevel(entry.priority) then
          yOffset = yOffset + 20
        else
          frame:Hide()
        end
      end
    end
  end
end

--------------------------------------------------
-- Refresh Display (for filters) - MODIFIÉ
--------------------------------------------------
function AutoLFM_DungeonList.Refresh()
  -- Instead of recreating everything, just update visibility
  UpdateRowVisibility()
end

--------------------------------------------------
-- Clear Selection UI
--------------------------------------------------
function AutoLFM_DungeonList.ClearSelection()
  ClearDungeonSelection()
  
  -- Update checkboxes
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
    
    -- Clear backdrop
    local frame = checkbox:GetParent()
    if frame and frame.SetBackdrop then
      frame:SetBackdrop(nil)
    end
  end
end