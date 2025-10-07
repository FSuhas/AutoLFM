--------------------------------------------------
-- Role Selector Component
--------------------------------------------------

local roleButtons = {}
local roleCheckboxes = {}

--------------------------------------------------
-- Create Single Role Button
--------------------------------------------------
local function CreateRoleButton(parentFrame, roleName, xPos, texCoordStart)
  if not parentFrame then return nil end
  if not roleName then return nil end
  
  -- Main button
  local btn = CreateFrame("Button", nil, parentFrame)
  btn:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", xPos, -52)
  btn:SetWidth(54)
  btn:SetHeight(54)
  btn:SetHighlightTexture(TEXTURE_BASE_PATH .. "rolesHighlight")
  
  -- Background
  local bg = btn:CreateTexture(nil, "BACKGROUND")
  bg:SetPoint("TOPLEFT", btn, "TOPLEFT", -12, 14)
  bg:SetWidth(84)
  bg:SetHeight(84)
  bg:SetTexture(TEXTURE_BASE_PATH .. "rolesBackground")
  bg:SetTexCoord(texCoordStart, texCoordStart + 0.2968, 0, 0.5937)
  bg:SetVertexColor(1, 1, 1, 0.6)
  
  -- Icon
  local icon = btn:CreateTexture(nil, "BORDER")
  icon:SetAllPoints(btn)
  icon:SetTexture(TEXTURE_BASE_PATH .. "roles" .. roleName)
  
  -- Checkbox
  local check = CreateFrame("CheckButton", nil, parentFrame, "UICheckButtonTemplate")
  check:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 1, -5)
  check:SetWidth(24)
  check:SetHeight(24)
  
  check:SetScript("OnClick", function()
    ToggleRoleSelection(roleName)
  end)
  
  -- Button click toggles checkbox
  btn:SetScript("OnClick", function()
    check:Click()
  end)
  
  roleButtons[roleName] = btn
  roleCheckboxes[roleName] = check
  
  return btn, check
end

--------------------------------------------------
-- Initialize Role Selector
--------------------------------------------------
function InitializeRoleSelector(parentFrame)
  if not parentFrame then return end
  
  -- Create Tank (left)
  CreateRoleButton(parentFrame, ROLE_TANK, 74, 0.2968)
  
  -- Create Heal (center)
  CreateRoleButton(parentFrame, ROLE_HEAL, 172, 0)
  
  -- Create DPS (right)
  CreateRoleButton(parentFrame, ROLE_DPS, 270, 0.5937)
end

--------------------------------------------------
-- Update Role Checkboxes from State
--------------------------------------------------
function UpdateRoleCheckboxes()
  if not roleCheckboxes then return end
  
  for roleName, checkbox in pairs(roleCheckboxes) do
    if checkbox and checkbox.SetChecked then
      local isSelected = IsRoleSelected(roleName)
      checkbox:SetChecked(isSelected)
    end
  end
end

--------------------------------------------------
-- Clear Role Checkboxes UI
--------------------------------------------------
function ClearRoleCheckboxesUI()
  if not roleCheckboxes then return end
  
  for roleName, checkbox in pairs(roleCheckboxes) do
    if checkbox and checkbox.SetChecked then
      checkbox:SetChecked(false)
    end
  end
end

--------------------------------------------------
-- Get Role Checkboxes (for external access if needed)
--------------------------------------------------
function GetRoleCheckboxes()
  return roleCheckboxes
end