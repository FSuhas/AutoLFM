---------------------------------------------------------------------------------
--                            Role Functions                                   --
---------------------------------------------------------------------------------
-- Function to toggle role selection
function toggleRole(role)
  if roleChecks[role]:GetChecked() then
    table.insert(selectedRoles, role)
  else
    for i, v in ipairs(selectedRoles) do
      if v == role then
        table.remove(selectedRoles, i)
        break
      end
    end
  end
  updateMsgFrameCombined()
end

-- Function to clear all selected roles
function clearSelectedRoles()
  selectedRoles = {}
  if roleChecks then
    for role, check in pairs(roleChecks) do
      check:SetChecked(false)
    end
  end
end

-- Function to get selected roles
function getSelectedRoles()
  return selectedRoles or {}
end

-- Function to check if a role is selected
function isRoleSelected(role)
  for _, selectedRole in ipairs(selectedRoles) do
    if selectedRole == role then
      return true
    end
  end
  return false
end