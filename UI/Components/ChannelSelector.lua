--------------------------------------------------
-- Channel Selector Component
--------------------------------------------------

local channelsFrame = nil
local channelButtons = {}

--------------------------------------------------
-- Check if player is in Hardcore mode
--------------------------------------------------
local function IsHardcoreMode()
  local channelId = GetChannelName("Hardcore")
  if channelId and channelId > 0 then
    return true
  end
  
  local i = 1
  while UnitBuff("player", i) do
    local buffName = UnitBuff("player", i)
    if buffName then
      local lowerName = string.lower(buffName)
      if lowerName == "hardcore" or string.find(lowerName, "^hardcore ") or string.find(lowerName, " hardcore$") then
        return true
      end
    end
    i = i + 1
  end
  
  return false
end

--------------------------------------------------
-- Create Channel Selector Frame
--------------------------------------------------
function CreateChannelSelector(parentFrame)
  if not parentFrame then return nil end
  if channelsFrame then
    channelsFrame:SetParent(parentFrame)
    channelsFrame:Show()
    return channelsFrame
  end
  
  channelsFrame = CreateFrame("Frame", "AutoLFM_ChannelSelector", parentFrame)
  channelsFrame:SetWidth(292)
  channelsFrame:SetHeight(100)
  channelsFrame:Show()
  
  local channelIcon = channelsFrame:CreateTexture(nil, "OVERLAY")
  channelIcon:SetTexture(TEXTURE_BASE_PATH .. "Icons\\channel")
  channelIcon:SetWidth(16)
  channelIcon:SetHeight(16)
  channelIcon:SetPoint("TOPLEFT", channelsFrame, "TOPLEFT", 0, 0)
  
  local titleText = channelsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  titleText:SetText("Channels:")
  titleText:SetPoint("LEFT", channelIcon, "RIGHT", 3, 0)
  
  
  return channelsFrame
end

--------------------------------------------------
-- Create Single Channel Checkbox
--------------------------------------------------
local function CreateChannelCheckbox(parentFrame, channel, lastButton)
  if not parentFrame or not channel then return nil end
  
  local button = CreateFrame("CheckButton", nil, parentFrame, "UICheckButtonTemplate")
  button:SetWidth(16)
  button:SetHeight(16)
  
  if lastButton then
    button:SetPoint("TOPLEFT", lastButton, "TOPLEFT", 0, -20)
  else
    button:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 19, -20)
  end
  
  -- Check if player has access to this channel
  local hasAccess = true
  if channel.name == "Hardcore" then
    hasAccess = IsHardcoreMode()
  end
  
  -- Disable checkbox if no access
  if not hasAccess then
    button:Disable()
    button:SetAlpha(0.5)
  else
    button:Enable()
    button:SetAlpha(1.0)
  end
  
  -- Channel label
  local channelText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  channelText:SetPoint("LEFT", button, "RIGHT", 5, 0)
  channelText:SetText(channel.name)
  
  -- Dim label if no access
  if not hasAccess then
    channelText:SetTextColor(0.5, 0.5, 0.5)
  else
    channelText:SetTextColor(1, 1, 1)
  end
  
  -- Set checked state from manager (false if no access)
  if hasAccess then
    button:SetChecked(IsChannelSelected(channel.name))
  else
    button:SetChecked(false)
  end
  
  -- Click handler
  button:SetScript("OnClick", function()
    if not hasAccess then
      button:SetChecked(false)
      return
    end
    ToggleChannelSelection(channel.name, button:GetChecked())
  end)
  
  channelButtons[channel.name] = button
  
  return button
end

--------------------------------------------------
-- Create Channel Checkboxes
--------------------------------------------------
local function CreateChannelCheckboxes()
  if not channelsFrame then return end
  
  -- Clear existing buttons
  for _, button in pairs(channelButtons) do
    if button then
      button:Hide()
    end
  end
  channelButtons = {}
  
  -- Find available channels
  local foundChannels = FindAvailableChannels()
  if not foundChannels or table.getn(foundChannels) == 0 then
    return
  end
  
  local lastButton = nil
  
  for _, channel in ipairs(foundChannels) do
    if channel and channel.name then
      lastButton = CreateChannelCheckbox(channelsFrame, channel, lastButton)
    end
  end
end

--------------------------------------------------
-- Refresh Channel Checkboxes
--------------------------------------------------
function RefreshChannelCheckboxes()
  CreateChannelCheckboxes()
end

--------------------------------------------------
-- Update Channel Checkboxes from State
--------------------------------------------------
function UpdateChannelCheckboxes()
  if not channelButtons then return end
  
  for channelName, button in pairs(channelButtons) do
    if button and button.SetChecked then
      button:SetChecked(IsChannelSelected(channelName))
    end
  end
end

--------------------------------------------------
-- Get Channel Selector Frame
--------------------------------------------------
function GetChannelSelectorFrame()
  return channelsFrame
end

--------------------------------------------------
-- Ensure Channel UI Exists
--------------------------------------------------
function EnsureChannelUIExists()
  return channelsFrame ~= nil
end