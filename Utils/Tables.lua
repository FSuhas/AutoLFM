--------------------------------------------------
-- Table Utilities
--------------------------------------------------

--------------------------------------------------
-- Check if Table Contains Value
--------------------------------------------------
function TableContains(tbl, value)
  if not tbl then return false end
  
  for _, v in pairs(tbl) do
    if v == value then
      return true
    end
  end
  
  return false
end

--------------------------------------------------
-- Count Table Elements
--------------------------------------------------
function TableCount(tbl)
  if not tbl then return 0 end
  
  local count = 0
  for _ in pairs(tbl) do
    count = count + 1
  end
  
  return count
end