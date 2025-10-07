--------------------------------------------------
-- Channel Selector Component
--------------------------------------------------

local channelsFrame = nil
local channelButtons = {}

--------------------------------------------------
-- Check if player is in Hardcore mode
--------------------------------------------------
local function IsHardcoreMode()
  -- Method 1: Check for Hardcore buff/debuff
  local i = 1
  while UnitBuff("player", i) do
    local name = UnitBuff("player", i)
    if name and string.find(string.lower(name), "hardcore") then
      return true
    end
    i = i + 1
  end
  
  -- Method 2: Check if Hardcore channel exists
  local channelId = GetChannelName("Hardcore")
  if channelId and channelId > 0 then
    return true
  end
  
  return false
end

--------------------------------------------------
-- Create Single Channel Checkbox
--------------------------------------------------
local function CreateChannelCheckbox(parentFrame, channel, lastButton)
  if not parentFrame or not channel then return nil end
  
  local button = CreateFrame("CheckButton", nil, parentFrame, "UICheckButtonTemplate")
  button:SetWidth(14)
  button:SetHeight(14)
  
  if lastButton then
    button:SetPoint("TOP", lastButton, "BOTTOM", 0, -5)
  else
    button:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, -5)
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
  channelText:SetFont("Fonts\\FRIZQT__.TTF", 9, "MONOCHROME")
  
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
-- Create Channel Selector Frame
--------------------------------------------------
function CreateChannelSelector(parentFrame)
  if not parentFrame then return nil end
  if channelsFrame then return channelsFrame end
  
  channelsFrame = CreateFrame("Frame", nil, parentFrame)
  channelsFrame:SetPoint("TOP", parentFrame, "TOP", 0, -100)
  channelsFrame:SetWidth(250)
  channelsFrame:SetHeight(120)
  
  -- Title
  local titleText = channelsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  titleText:SetPoint("TOP", channelsFrame, "TOP", 0, -10)
  titleText:SetText("Select Channel Broadcast")
  titleText:SetTextColor(1, 1, 0)
  titleText:SetJustifyH("CENTER")
  titleText:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
  
  CreateChannelCheckboxes()
  
  return channelsFrame
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
-- Ensure Channel UI Exists (legacy compatibility)
--------------------------------------------------
function EnsureChannelUIExists()
  return channelsFrame ~= nil
end

function InitializeChannelSelectionUI()
  -- Legacy function - does nothing now
  -- Channels are created in SettingsPanel
end