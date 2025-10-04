--------------------------------------------------
-- Role Functions
--------------------------------------------------

function toggleRole(role)
  if not roleChecks or not roleChecks[role] then return end
  
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
  
  if updateMsgFrameCombined then
    updateMsgFrameCombined()
  end
end

function clearSelectedRoles()
  selectedRoles = {}
  if roleChecks then
    for role, check in pairs(roleChecks) do
      check:SetChecked(false)
    end
  end
end

function getSelectedRoles()
  return selectedRoles or {}
end

function isRoleSelected(role)
  for _, selectedRole in ipairs(selectedRoles or {}) do
    if selectedRole == role then
      return true
    end
  end
  return false
end