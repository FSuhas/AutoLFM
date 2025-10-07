--------------------------------------------------
-- Quest & Item Links Component
--------------------------------------------------

local editBoxHasFocus = false
local hookedQuestButtons = {}
local hookedBagButtons = {}

--------------------------------------------------
-- Create Quest Hyperlink
--------------------------------------------------
local function CreateQuestHyperlink(questIndex)
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
-- Insert Link into EditBox
--------------------------------------------------
local function InsertLinkIntoEditBox(link)
  if not link then return end
  
  local editBox = GetCustomMessageEditBox()
  if not editBox then return end
  if not editBoxHasFocus then return end
  
  editBox:SetText(link)
  editBox:SetFocus()
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
    
    -- Execute original script first
    if originalScript and type(originalScript) == "function" then
      originalScript()
    end
    
    -- Our custom logic
    if not mouseButton then return end
    if mouseButton ~= "LeftButton" then return end
    if not isShiftPressed then return end
    
    local questIndex = button:GetID()
    if not questIndex then return end
    
    local questLink = CreateQuestHyperlink(questIndex)
    if questLink then
      InsertLinkIntoEditBox(questLink)
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
  
  local originalScript = button:GetScript("OnClick")
  
  button:SetScript("OnClick", function()
    local mouseButton = arg1
    local isShiftPressed = IsShiftKeyDown()
    
    -- Execute original script first
    if originalScript and type(originalScript) == "function" then
      originalScript()
    end
    
    -- Our custom logic
    if not mouseButton then return end
    if mouseButton ~= "LeftButton" then return end
    if not isShiftPressed then return end
    
    local itemLink = GetContainerItemLink(bagID, slotID)
    if itemLink then
      InsertLinkIntoEditBox(itemLink)
    end
  end)
end

--------------------------------------------------
-- Hook Quest Log Buttons
--------------------------------------------------
local function HookQuestLogButtons()
  if not QuestLogFrame then return end
  if not QuestLogFrame:IsVisible() then return end
  
  local maxButtons = 50
  
  for i = 1, maxButtons do
    local buttonName = "QuestLogTitle" .. i
    local button = getglobal(buttonName)
    if not button then break end
    
    HookQuestButton(button)
  end
end

--------------------------------------------------
-- Hook Bag Buttons
--------------------------------------------------
local function HookBagButtons()
  for bagID = 0, 4 do
    local bagIndex = bagID + 1
    local bagName = "ContainerFrame" .. bagIndex
    local bagFrame = getglobal(bagName)
    
    if bagFrame and bagFrame:IsVisible() then
      local numSlots = GetContainerNumSlots(bagID)
      if numSlots and numSlots > 0 then
        for slotID = 1, numSlots do
          local buttonName = bagName .. "Item" .. slotID
          local button = getglobal(buttonName)
          
          if button then
            HookBagButton(button, bagID, slotID)
          end
        end
      end
    end
  end
end

--------------------------------------------------
-- Setup Event Handlers
--------------------------------------------------
local function SetupEventHandlers()
  -- Quest log hook
  local questHookFrame = CreateFrame("Frame")
  questHookFrame:RegisterEvent("QUEST_LOG_UPDATE")
  
  questHookFrame:SetScript("OnEvent", function()
    local currentEvent = event
    if not currentEvent then return end
    if currentEvent ~= "QUEST_LOG_UPDATE" then return end
    
    HookQuestLogButtons()
  end)
  
  -- Bag hook
  local bagHookFrame = CreateFrame("Frame")
  bagHookFrame:RegisterEvent("BAG_UPDATE")
  bagHookFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
  
  bagHookFrame:SetScript("OnEvent", function()
    local currentEvent = event
    if not currentEvent then return end
    if currentEvent ~= "BAG_UPDATE" and currentEvent ~= "BAG_UPDATE_COOLDOWN" then return end
    
    HookBagButtons()
  end)
end

--------------------------------------------------
-- Override SetItemRef
--------------------------------------------------
local Original_SetItemRef = SetItemRef

function SetItemRef(link, text, button)
  -- Call original function
  if Original_SetItemRef then
    Original_SetItemRef(link, text, button)
  end
  
  -- Our custom logic
  if not button then return end
  if button ~= "LeftButton" then return end
  if not IsShiftKeyDown() then return end
  if not editBoxHasFocus then return end
  if not link then return end
  
  -- Check if it's an item link
  local isItemLink = string.find(link, "^item:")
  if isItemLink and text then
    InsertLinkIntoEditBox(text)
  end
end

--------------------------------------------------
-- Update EditBox Focus State
--------------------------------------------------
function UpdateEditBoxFocusState(hasFocus)
  editBoxHasFocus = hasFocus or false
end

--------------------------------------------------
-- Initialize Quest Item Links
--------------------------------------------------
function InitializeQuestItemLinks()
  SetupEventHandlers()
end