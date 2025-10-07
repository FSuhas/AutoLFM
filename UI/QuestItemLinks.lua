--------------------------------------------------
-- Quest and Item Links Management
--------------------------------------------------
local editBoxHasFocus = false
local hookedQuestButtons = {}
local hookedBagButtons = {}

--------------------------------------------------
-- Quest Link Creation
--------------------------------------------------
function CreateQuestHyperlink(questIndex)
  if not questIndex then return nil end
  if questIndex < 1 then return nil end
  if not AutoLFM_MainFrame then return nil end
  if not AutoLFM_MainFrame:IsVisible() then return nil end
  
  local title, level, _, _, _, _, _, questID = GetQuestLogTitle(questIndex)
  if not title then return nil end
  if title == "" then return nil end
  
  if not questID then questID = 0 end
  if not level then level = 0 end
  
  local color = "|cffffff00"
  local link = string.format("%s|Hquest:%d:%d|h[%s]|h|r", color, questID, level, title)
  return link
end

--------------------------------------------------
-- Hook Quest Button
--------------------------------------------------
local function HookQuestButton(button)
  if not button then return end
  
  local buttonName = button:GetName()
  if not buttonName then return end
  if hookedQuestButtons[buttonName] then return end
  
  hookedQuestButtons[buttonName] = true
  
  local originalScript = button:GetScript("OnClick")
  
  button:SetScript("OnClick", function()
    local mouseButton = arg1
    local isShiftPressed = IsShiftKeyDown()
    
    if originalScript and type(originalScript) == "function" then
      originalScript()
    end
    
    -- Notre logique personnalisée
    if not mouseButton then return end
    if mouseButton ~= "LeftButton" then return end
    if not isShiftPressed then return end
    if not customMessageEditBox then return end
    if not editBoxHasFocus then return end
    
    local questIndex = button:GetID()
    if not questIndex then return end
    
    local questLink = CreateQuestHyperlink(questIndex)
    if not questLink then return end
    
    customMessageEditBox:SetText(questLink)
    customMessageEditBox:SetFocus()
  end)
end

--------------------------------------------------
-- Hook Bag Button
--------------------------------------------------
local function HookBagButton(button, bagID, slotID)
  if not button then return end
  if not bagID then return end
  if not slotID then return end
  
  local key = bagID .. "_" .. slotID
  if hookedBagButtons[key] then return end
  
  hookedBagButtons[key] = true
  
  local originalScript = button:GetScript("OnClick")
  
  button:SetScript("OnClick", function()
    local mouseButton = arg1
    local isShiftPressed = IsShiftKeyDown()
    
    if originalScript and type(originalScript) == "function" then
      originalScript()
    end
    
    if not mouseButton then return end
    if mouseButton ~= "LeftButton" then return end
    if not isShiftPressed then return end
    if not customMessageEditBox then return end
    if not editBoxHasFocus then return end
    
    local itemLink = GetContainerItemLink(bagID, slotID)
    if not itemLink then return end
    
    customMessageEditBox:SetText(itemLink)
    customMessageEditBox:SetFocus()
  end)
end

--------------------------------------------------
-- Quest Log Hook
--------------------------------------------------
local questHookFrame = CreateFrame("Frame")
questHookFrame:RegisterEvent("QUEST_LOG_UPDATE")

questHookFrame:SetScript("OnEvent", function()
  local eventType = event
  if not eventType then return end
  if eventType ~= "QUEST_LOG_UPDATE" then return end
  if not QuestLogFrame then return end
  if not QuestLogFrame:IsVisible() then return end
  
  local i = 1
  local maxButtons = 50
  
  while i <= maxButtons do
    local buttonName = "QuestLogTitle" .. i
    local button = getglobal(buttonName)
    if not button then break end
    
    HookQuestButton(button)
    i = i + 1
  end
end)

--------------------------------------------------
-- Bag Hook
--------------------------------------------------
local bagHookFrame = CreateFrame("Frame")
bagHookFrame:RegisterEvent("BAG_UPDATE")
bagHookFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")

bagHookFrame:SetScript("OnEvent", function()
  local eventType = event
  if not eventType then return end
  if eventType ~= "BAG_UPDATE" and eventType ~= "BAG_UPDATE_COOLDOWN" then return end
  
  for bagID = 0, 4 do
    local bagIndex = bagID + 1
    local bagName = "ContainerFrame" .. bagIndex
    local bagFrame = getglobal(bagName)
    
    if not bagFrame then break end
    if not bagFrame:IsVisible() then break end
    
    local numSlots = GetContainerNumSlots(bagID)
    if not numSlots then break end
    if numSlots < 1 then break end
    
    for slotID = 1, numSlots do
      local buttonName = bagName .. "Item" .. slotID
      local button = getglobal(buttonName)
      
      if button then
        HookBagButton(button, bagID, slotID)
      end
    end
  end
end)

--------------------------------------------------
-- SetItemRef Override
--------------------------------------------------
local Original_SetItemRef = SetItemRef

function SetItemRef(link, text, button)
  if Original_SetItemRef then
    Original_SetItemRef(link, text, button)
  end
  
  if not button then return end
  if button ~= "LeftButton" then return end
  if not IsShiftKeyDown() then return end
  if not customMessageEditBox then return end
  if not editBoxHasFocus then return end
  if not link then return end
  
  local isItemLink = string.find(link, "^item:")
  if isItemLink and text then
    customMessageEditBox:SetText(text)
    customMessageEditBox:SetFocus()
  end
end

--------------------------------------------------
-- Update EditBox Focus State
--------------------------------------------------
function UpdateEditBoxFocusState(hasFocus)
  if hasFocus == nil then
    editBoxHasFocus = false
  else
    editBoxHasFocus = hasFocus
  end
end