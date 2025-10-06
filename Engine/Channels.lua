--------------------------------------------------
-- Channel Management
--------------------------------------------------
local channelsToFind = {"WORLD", "LookingForGroup", "Hardcore", "testketa"}
local foundChannels = {}
local channelsFrame = nil

--------------------------------------------------
-- Save/Load Selected Channels
--------------------------------------------------
function SaveSelectedChannels()
  if not AutoLFM_SavedVariables or not uniqueIdentifier then return end
  AutoLFM_SavedVariables[uniqueIdentifier].selectedChannels = selectedChannels or {}
end

function LoadSelectedChannels()
  if AutoLFM_SavedVariables[uniqueIdentifier] and AutoLFM_SavedVariables[uniqueIdentifier].selectedChannels then
    selectedChannels = AutoLFM_SavedVariables[uniqueIdentifier].selectedChannels
  else
    selectedChannels = {}
    if AutoLFM_SavedVariables[uniqueIdentifier] then
      AutoLFM_SavedVariables[uniqueIdentifier].selectedChannels = selectedChannels
    end
  end
end

function ToggleChannelSelection(channelName, isSelected)
  if not selectedChannels then selectedChannels = {} end
  if isSelected then
    selectedChannels[channelName] = true
  else
    selectedChannels[channelName] = nil
  end
  SaveSelectedChannels()
end

--------------------------------------------------
-- Find Available Channels
--------------------------------------------------
function findChannels()
  foundChannels = {}
  
  for _, channel in ipairs(channelsToFind) do
    if channel == "Hardcore" then
      -- Check if player has access to Hardcore channel
      local channelId = GetChannelName(channel)
      if channelId and channelId > 0 then
        table.insert(foundChannels, {name = channel, id = channelId})
      end
    else
      local channelId = GetChannelName(channel)
      if channelId and channelId > 0 then
        table.insert(foundChannels, {name = channel, id = channelId})
      end
    end
  end
end

--------------------------------------------------
-- Create Channel Buttons
--------------------------------------------------
function CreateChannelButtons()
  if not channelsFrame then return end
  if not next(foundChannels) then return end
  
  -- Hide existing buttons
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
      
      button:SetChecked(selectedChannels[channel.name])
      
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
function InitializeChannelFrame()
  if not insideMore then return end
  if channelsFrame then return end
  
  channelsFrame = CreateFrame("Frame", nil, insideMore)
  channelsFrame:SetPoint("TOP", sliderframe, "BOTTOM", 0, -20)
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
  
  LoadSelectedChannels()
  findChannels()
  CreateChannelButtons()
end

function EnsureChannelFrameExists()
  if not channelsFrame then
    InitializeChannelFrame()
  end
  return channelsFrame ~= nil
end