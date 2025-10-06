--------------------------------------------------
-- Dungeon List UI
--------------------------------------------------
AutoLFM_DungeonList = {}
AutoLFM_DungeonList.clickableFrames = {}
AutoLFM_DungeonList.checkButtons = {}

--------------------------------------------------
-- Get Priority Color
--------------------------------------------------
local function GetPriorityColor(priority)
  for _, color in ipairs(priorityColors or {}) do
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
    -- Show UI elements
    if editBox then editBox:Show() end
    if sliderframe then sliderframe:Show() end
    if toggleButton then toggleButton:Show() end
    if msgFrameDj then msgFrameDj:Show() end
    
    -- Check if already selected
    local alreadySelected = false
    for _, val in ipairs(selectedDungeons) do
      if val == dungeonTag then
        alreadySelected = true
        break
      end
    end
    
    if not alreadySelected then
      -- Limit to 4 dungeons max
      if table.getn(selectedDungeons) >= 4 then
        local first = selectedDungeons[1]
        table.remove(selectedDungeons, 1)
        if AutoLFM_DungeonList.checkButtons[first] then
          AutoLFM_DungeonList.checkButtons[first]:SetChecked(false)
          AutoLFM_DungeonList.checkButtons[first]:GetParent():SetBackdrop(nil)
        end
      end
      table.insert(selectedDungeons, dungeonTag)
    end
  else
    -- Remove from selection
    for i, val in ipairs(selectedDungeons) do
      if val == dungeonTag then
        table.remove(selectedDungeons, i)
        break
      end
    end
  end
  
  UpdateDungeonBackdrop(checkbox:GetParent(), checkbox)
  if updateMsgFrameCombined then
    updateMsgFrameCombined()
  end
end

--------------------------------------------------
-- Create Single Dungeon Row
--------------------------------------------------
local function CreateDungeonRow(parent, dungeon, priority, yOffset)
  if ShouldDisplayPriority and not ShouldDisplayPriority(priority) then
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
  -- Hide all existing children
  for _, child in ipairs({parent:GetChildren()}) do
    child:Hide()
  end
  
  local playerLevel = UnitLevel("player")
  local yOffset = 0
  local sortedDungeons = {}
  
  -- Build sorted list with priorities
  for index, dungeon in ipairs(dungeons or {}) do
    local priority = CalculatePriority and CalculatePriority(playerLevel, dungeon) or 4
    table.insert(sortedDungeons, {
      dungeon = dungeon,
      priority = priority,
      originalIndex = index
    })
  end
  
  -- Sort by priority then original index
  table.sort(sortedDungeons, function(a, b)
    if a.priority == b.priority then
      return a.originalIndex < b.originalIndex
    else
      return a.priority < b.priority
    end
  end)
  
  AutoLFM_DungeonList.clickableFrames = {}
  
  -- Create rows
  for _, entry in ipairs(sortedDungeons) do
    local frame = CreateDungeonRow(parent, entry.dungeon, entry.priority, yOffset)
    if frame then
      yOffset = yOffset + 20
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
  if selectedDungeons then
    selectedDungeons = {}
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