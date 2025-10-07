--------------------------------------------------
-- Role Manager - Role Logic
--------------------------------------------------
local function IsValidRole(role)
  if not role or not AVAILABLE_ROLES then return false end
  
  for _, validRole in ipairs(AVAILABLE_ROLES) do
    if validRole == role then
      return true
    end
  end
  
  return false
end

--------------------------------------------------
-- Toggle Role Selection
--------------------------------------------------
function ToggleRoleSelection(role)
  if not role then return end
  if not IsValidRole(role) then
    if AutoLFM_PrintWarning then
      AutoLFM_PrintWarning("Invalid role: " .. tostring(role))
    end
    return
  end
  
  if not selectedRolesList then selectedRolesList = {} end
  
  -- Check if role is already selected
  local isSelected = false
  local indexToRemove = nil
  
  for i, selectedRole in ipairs(selectedRolesList) do
    if selectedRole == role then
      isSelected = true
      indexToRemove = i
      break
    end
  end
  
  if isSelected then
    -- Remove role from selection
    if indexToRemove then
      table.remove(selectedRolesList, indexToRemove)
    end
  else
    -- Add role to selection
    table.insert(selectedRolesList, role)
  end
  
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end

--------------------------------------------------
-- Clear All Role Selections
--------------------------------------------------
function ClearAllRoles()
  selectedRolesList = {}
  
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end

--------------------------------------------------
-- Get Selected Roles List
--------------------------------------------------
function GetSelectedRolesList()
  return selectedRolesList or {}
end

--------------------------------------------------
-- Check if Role is Selected
--------------------------------------------------
function IsRoleSelected(role)
  if not role then return false end
  if not selectedRolesList then return false end
  
  for _, selectedRole in ipairs(selectedRolesList) do
    if selectedRole == role then
      return true
    end
  end
  
  return false
end

--------------------------------------------------
-- Get Roles Count
--------------------------------------------------
function GetSelectedRolesCount()
  if not selectedRolesList then return 0 end
  return table.getn(selectedRolesList)
end

--------------------------------------------------
-- Check if All Roles Selected
--------------------------------------------------
function AreAllRolesSelected()
  if not selectedRolesList then return false end
  if not AVAILABLE_ROLES then return false end
  
  return table.getn(selectedRolesList) == table.getn(AVAILABLE_ROLES)
end

--------------------------------------------------
-- Get Roles String for Message
--------------------------------------------------
function GetRolesString()
  if not selectedRolesList then return "" end
  
  local rolesCount = table.getn(selectedRolesList)
  
  if rolesCount == 0 then
    return ""
  end
  
  -- If all 3 roles selected, return "Need All"
  if AreAllRolesSelected() then
    return "Need All"
  end
  
  -- Otherwise return "Need Tank & Heal" format
  return "Need " .. table.concat(selectedRolesList, " & ")
end