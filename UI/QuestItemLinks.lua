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
  if not questIndex or questIndex < 1 then return nil end
  if not AutoLFM_MainFrame or not AutoLFM_MainFrame:IsVisible() then return nil end
  
  local title, level, _, _, _, _, _, questID = GetQuestLogTitle(questIndex)
  if not title or title == "" then return nil end
  
  questID = questID or 0
  level = level or 0
  
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
  
  local originalOnClick = button:GetScript("OnClick")
  
  button:SetScript("OnClick", function()
    if originalOnClick then
      originalOnClick()
    end
    
    if not (arg1 == "LeftButton" and IsShiftKeyDown()) then return end
    if not customMessageEditBox then return end
    if not editBoxHasFocus then return end
    
    local questIndex = button:GetID()
    if not questIndex then return end
    
    local questLink = CreateQuestHyperlink(questIndex)
    if questLink then
      customMessageEditBox:SetText(questLink)
      customMessageEditBox:SetFocus()
    end
  end)
end

--------------------------------------------------
-- Hook Bag Button
--------------------------------------------------
local function HookBagButton(button, bagID, slotID)
  if not button then return end
  if not bagID or not slotID then return end
  
  local key = bagID .. "_" .. slotID
  if hookedBagButtons[key] then return end
  
  hookedBagButtons[key] = true
  
  local originalOnClick = button:GetScript("OnClick")
  
  button:SetScript("OnClick", function()
    if originalOnClick then
      originalOnClick()
    end
    
    if not (arg1 == "LeftButton" and IsShiftKeyDown()) then return end
    if not customMessageEditBox then return end
    if not editBoxHasFocus then return end
    
    local itemLink = GetContainerItemLink(bagID, slotID)
    if itemLink then
      customMessageEditBox:SetText(itemLink)
      customMessageEditBox:SetFocus()
    end
  end)
end

--------------------------------------------------
-- Quest Log Hook
--------------------------------------------------
local questHookFrame = CreateFrame("Frame")
questHookFrame:RegisterEvent("QUEST_LOG_UPDATE")

questHookFrame:SetScript("OnEvent", function()
  if event ~= "QUEST_LOG_UPDATE" then return end
  if not QuestLogFrame then return end
  if not QuestLogFrame:IsVisible() then return end
  
  local i = 1
  local maxButtons = 50
  
  while i <= maxButtons do
    local button = getglobal("QuestLogTitle" .. i)
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
  if not (event == "BAG_UPDATE" or event == "BAG_UPDATE_COOLDOWN") then return end
  
  for bagID = 0, 4 do
    local bagName = "ContainerFrame" .. (bagID + 1)
    local bagFrame = getglobal(bagName)
    
    if not bagFrame then break end
    if not bagFrame:IsVisible() then break end
    
    local numSlots = GetContainerNumSlots(bagID)
    if not numSlots or numSlots < 1 then break end
    
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
  
  if not (button == "LeftButton" and IsShiftKeyDown()) then return end
  if not customMessageEditBox then return end
  if not editBoxHasFocus then return end
  if not link then return end
  
  if string.find(link, "^item:") and text then
    customMessageEditBox:SetText(text)
    customMessageEditBox:SetFocus()
  end
end

--------------------------------------------------
-- Update EditBox Focus State
--------------------------------------------------
function UpdateEditBoxFocusState(hasFocus)
  editBoxHasFocus = hasFocus
end