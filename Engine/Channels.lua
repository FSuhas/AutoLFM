--------------------------------------------------
-- Channel Management
--------------------------------------------------
local channelsToFind = {"WORLD", "LookingForGroup", "Hardcore", "testketa"}
local foundChannels = {}
local channelsFrame = nil

--------------------------------------------------
-- Save/Load Selected Channels
--------------------------------------------------
function SaveChannelSelection()
  if not AutoLFM_SavedVariables then return end
  if not characterUniqueID then return end
  if not AutoLFM_SavedVariables[characterUniqueID] then
    AutoLFM_SavedVariables[characterUniqueID] = {}
  end
  AutoLFM_SavedVariables[characterUniqueID].selectedChannels = selectedChannelsList or {}
end

function LoadChannelSelection()
  if not AutoLFM_SavedVariables then return end
  if not characterUniqueID then return end
  if not AutoLFM_SavedVariables[characterUniqueID] then
    AutoLFM_SavedVariables[characterUniqueID] = {}
  end
  
  if AutoLFM_SavedVariables[characterUniqueID].selectedChannels then
    selectedChannelsList = AutoLFM_SavedVariables[characterUniqueID].selectedChannels
  else
    selectedChannelsList = {}
    AutoLFM_SavedVariables[characterUniqueID].selectedChannels = selectedChannelsList
  end
end

function ToggleChannelSelection(channelName, isSelected)
  if not selectedChannelsList then selectedChannelsList = {} end
  if not channelName then return end
  
  if isSelected then
    selectedChannelsList[channelName] = true
  else
    selectedChannelsList[channelName] = nil
  end
  SaveChannelSelection()
end

--------------------------------------------------
-- Find Available Channels
--------------------------------------------------
function FindAvailableChannels()
  foundChannels = {}
  
  if not channelsToFind or table.getn(channelsToFind) == 0 then
    return false
  end
  
  for _, channel in ipairs(channelsToFind) do
    if channel then
      local channelId = GetChannelName(channel)
      if channelId and channelId > 0 then
        table.insert(foundChannels, {name = channel, id = channelId})
      end
    end
  end
  
  return table.getn(foundChannels) > 0
end

--------------------------------------------------
-- Create Channel Buttons
--------------------------------------------------
function CreateChannelCheckboxes()
  if not channelsFrame then return end
  if not next(foundChannels) then return end
  
  for _, button in ipairs(channelsFrame.buttons or {}) do
    button:Hide()
  end
  channelsFrame.buttons = {}
  
  local buttonFrame = channelsFrame.buttonFrame
  if not buttonFrame then return end
  
  local lastButton = nil
  
  for _, channel in ipairs(foundChannels) do
    if channel and channel.name then
      local button = CreateFrame("CheckButton", nil, channelsFrame, "UICheckButtonTemplate")
      button:SetWidth(14)
      button:SetHeight(14)
      
      if lastButton then
        button:SetPoint("TOP", lastButton, "BOTTOM", 0, -5)
      else
        button:SetPoint("TOPLEFT", buttonFrame, "TOPLEFT", 10, -5)
      end
      
      local channelText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      channelText:SetPoint("LEFT", button, "RIGHT", 5, 0)
      channelText:SetText(channel.name)
      channelText:SetFont("Fonts\\FRIZQT__.TTF", 9, "MONOCHROME")
      
      button:SetChecked(selectedChannelsList[channel.name])
      
      local currentChannel = channel
      button:SetScript("OnClick", function()
        if currentChannel and currentChannel.name then
          ToggleChannelSelection(currentChannel.name, button:GetChecked())
        end
      end)
      
      table.insert(channelsFrame.buttons, button)
      lastButton = button
    end
  end
end

--------------------------------------------------
-- Initialize Channel Frame
--------------------------------------------------
function InitializeChannelSelectionUI()
  if not moreTabContentFrame then return end
  if channelsFrame then return end
  
  channelsFrame = CreateFrame("Frame", nil, moreTabContentFrame)
  channelsFrame:SetPoint("TOP", broadcastIntervalFrame, "BOTTOM", 0, -20)
  channelsFrame:SetWidth(250)
  channelsFrame:SetHeight(90)
  
  local titleText = channelsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  titleText:SetPoint("TOP", channelsFrame, "TOP", 0, -10)
  titleText:SetText("Select Channel Broadcast")
  titleText:SetTextColor(1, 1, 0)
  titleText:SetJustifyH("CENTER")
  titleText:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
  
  local buttonFrame = CreateFrame("Frame", nil, channelsFrame)
  buttonFrame:SetPoint("TOP", titleText, "BOTTOM", 0, -10)
  buttonFrame:SetWidth(channelsFrame:GetWidth() - 20)
  buttonFrame:SetHeight(channelsFrame:GetHeight() - 50)
  channelsFrame.buttonFrame = buttonFrame
  
  channelsFrame.buttons = {}
  
  LoadChannelSelection()
  FindAvailableChannels()
  CreateChannelCheckboxes()
end

function EnsureChannelUIExists()
  if not channelsFrame then
    InitializeChannelSelectionUI()
  end
  return channelsFrame ~= nil
end