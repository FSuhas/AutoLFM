--------------------------------------------------
-- Dungeon List UI
--------------------------------------------------
AutoLFM_DungeonList = {}
local DL = AutoLFM_DungeonList

DL.clickableFrames = {}
DL.checkButtons = {}

--------------------------------------------------
-- Priority Color
--------------------------------------------------
local function GetPriorityColor(priority)
  if priority == 4 then
    return 0.5, 0.5, 0.5
  elseif priority == 1 then
    return 0, 1, 0
  elseif priority == 2 then
    return 1, 0.5, 0
  else
    return 1, 0, 0
  end
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
    if editBox then editBox:Show() end
    if sliderframe then sliderframe:Show() end
    if toggleButton then toggleButton:Show() end
    if msgFrameDj then msgFrameDj:Show() end
    
    local alreadySelected = false
    for _, val in ipairs(selectedDungeons) do
      if val == dungeonTag then
        alreadySelected = true
        break
      end
    end
    
    if not alreadySelected then
      if table.getn(selectedDungeons) >= 4 then
        local first = selectedDungeons[1]
        table.remove(selectedDungeons, 1)
        if DL.checkButtons[first] then
          DL.checkButtons[first]:SetChecked(false)
          DL.checkButtons[first]:GetParent():SetBackdrop(nil)
        end
      end
      table.insert(selectedDungeons, dungeonTag)
    end
  else
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
  local clickableFrame = CreateFrame("Button", "ClickableDungeonFrame" .. dungeon.tag, parent)
  clickableFrame:SetHeight(20)
  clickableFrame:SetWidth(300)
  clickableFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -yOffset)
  
  local checkbox = CreateFrame("CheckButton", "DungeonCheckbox" .. dungeon.tag, clickableFrame, "UICheckButtonTemplate")
  checkbox:SetWidth(20)
  checkbox:SetHeight(20)
  checkbox:SetPoint("LEFT", clickableFrame, "LEFT", 0, 0)
  DL.checkButtons[dungeon.tag] = checkbox
  
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
  
  table.insert(DL.clickableFrames, clickableFrame)
  
  return clickableFrame
end

--------------------------------------------------
-- Display All Dungeons
--------------------------------------------------
function DL.Display(parent)
  for _, child in ipairs({parent:GetChildren()}) do
    child:Hide()
  end
  
  local playerLevel = UnitLevel("player")
  local yOffset = 0
  local sortedDungeons = {}
  
  for _, dungeon in pairs(dungeons or {}) do
    if table.getn(sortedDungeons) >= (maxDungeons or 100) then break end
    local priority = CalculatePriority and CalculatePriority(playerLevel, dungeon) or 4
    table.insert(sortedDungeons, {
      dungeon = dungeon,
      priority = priority,
      originalIndex = dungeon.originalIndex or 1
    })
  end
  
  table.sort(sortedDungeons, function(a, b)
    if a.priority == b.priority then
      return a.originalIndex < b.originalIndex
    else
      return a.priority < b.priority
    end
  end)
  
  DL.clickableFrames = {}
  
  for _, entry in ipairs(sortedDungeons) do
    CreateDungeonRow(parent, entry.dungeon, entry.priority, yOffset)
    yOffset = yOffset + 20
  end
end

--------------------------------------------------
-- Clear Selection
--------------------------------------------------
function DL.ClearSelection()
  for _, checkbox in pairs(DL.checkButtons) do
    checkbox:SetChecked(false)
  end
  if selectedDungeons then
    selectedDungeons = {}
  end
end

--------------------------------------------------
-- Clear Backdrops
--------------------------------------------------
function DL.ClearBackdrops()
  for _, frame in pairs(DL.clickableFrames) do
    if frame and frame.SetBackdrop then
      frame:SetBackdrop(nil)
    end
  end
end

--------------------------------------------------
-- Expose globally
--------------------------------------------------
dungeonCheckButtons = DL.checkButtons
dungeonClickableFrames = DL.clickableFrames