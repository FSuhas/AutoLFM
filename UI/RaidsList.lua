--------------------------------------------------
-- Raid List UI
--------------------------------------------------
AutoLFM_RaidList = {}
AutoLFM_RaidList.clickableFrames = {}
AutoLFM_RaidList.checkButtons = {}

--------------------------------------------------
-- Update Backdrop
--------------------------------------------------
local function UpdateRaidBackdrop(frame, checkbox)
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
local function OnRaidCheckboxClick(checkbox, raidTag)
  if checkbox:GetChecked() then
    -- Uncheck all other raid checkboxes (only one raid at a time)
    for _, otherCheckbox in pairs(AutoLFM_RaidList.checkButtons) do
      if otherCheckbox ~= checkbox then
        otherCheckbox:SetChecked(false)
        otherCheckbox:GetParent():SetBackdrop(nil)
      end
    end
    if selectedRaids then
      selectedRaids = {raidTag}
    end
  else
    if selectedRaids then
      selectedRaids = {}
    end
  end
  
  UpdateRaidBackdrop(checkbox:GetParent(), checkbox)
  
  if updateMsgFrameCombined then
    updateMsgFrameCombined()
  end
end

--------------------------------------------------
-- Create Single Raid Row
--------------------------------------------------
local function CreateRaidRow(parent, raid, index, yOffset)
  local clickableFrame = CreateFrame("Button", "ClickableRaidFrame" .. index, parent)
  clickableFrame:SetHeight(20)
  clickableFrame:SetWidth(300)
  clickableFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -yOffset)
  
  table.insert(AutoLFM_RaidList.clickableFrames, clickableFrame)
  
  local raidTag = raid.tag
  local raidName = raid.name
  
  local checkbox = CreateFrame("CheckButton", "RaidCheckbox" .. index, clickableFrame, "UICheckButtonTemplate")
  checkbox:SetWidth(20)
  checkbox:SetHeight(20)
  checkbox:SetPoint("LEFT", clickableFrame, "LEFT", 0, 0)
  
  local sizeLabel = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sizeLabel:SetPoint("RIGHT", clickableFrame, "RIGHT", -10, 0)
  local sizeText = raid.sizeMin == raid.sizeMax and "(" .. raid.sizeMin .. ")" or "(" .. raid.sizeMin .. " - " .. raid.sizeMax .. ")"
  sizeLabel:SetText(sizeText)
  
  local label = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
  label:SetText(raidName)
  
  AutoLFM_RaidList.checkButtons[raidTag] = checkbox
  
  checkbox:SetScript("OnClick", function()
    OnRaidCheckboxClick(checkbox, raidTag)
  end)
  
  clickableFrame:SetScript("OnClick", function()
    checkbox:SetChecked(not checkbox:GetChecked())
    checkbox:GetScript("OnClick")()
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
      UpdateRaidBackdrop(clickableFrame, checkbox)
    end
    checkbox:UnlockHighlight()
  end)
  
  return clickableFrame
end

--------------------------------------------------
-- Display All Raids
--------------------------------------------------
function AutoLFM_RaidList.Display(parent)
  -- Hide all existing children
  for _, child in ipairs({parent:GetChildren()}) do
    child:Hide()
  end
  
  local yOffset = 0
  
  for index, raid in ipairs(raids or {}) do
    CreateRaidRow(parent, raid, index, yOffset)
    yOffset = yOffset + 20
  end
end

--------------------------------------------------
-- Clear Selection
--------------------------------------------------
function AutoLFM_RaidList.ClearSelection()
  for _, checkbox in pairs(AutoLFM_RaidList.checkButtons) do
    checkbox:SetChecked(false)
  end
  if selectedRaids then
    selectedRaids = {}
  end
end

--------------------------------------------------
-- Clear Backdrops
--------------------------------------------------
function AutoLFM_RaidList.ClearBackdrops()
  for _, frame in pairs(AutoLFM_RaidList.clickableFrames) do
    if frame and frame.SetBackdrop then
      frame:SetBackdrop(nil)
    end
  end
end