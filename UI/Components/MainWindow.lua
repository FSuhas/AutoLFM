--=============================================================================
-- AutoLFM: Main Window
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.MainWindow then AutoLFM.UI.MainWindow = {} end

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
AutoLFM.UI.MainWindow.SOUND_START = "Interface\\AddOns\\AutoLFM\\UI\\Sounds\\LFG_RoleCheck.ogg"
AutoLFM.UI.MainWindow.SOUND_STOP = "Interface\\AddOns\\AutoLFM\\UI\\Sounds\\LFG_Denied.ogg"

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local mainFrame = nil
local mainIconTexture = nil
local messagePreviewFrame = nil
local messageText = nil
local roleButtons = {}
local roleCheckboxes = {}
local broadcastButton = nil

-----------------------------------------------------------------------------
-- Main Frame Creation
-----------------------------------------------------------------------------
function AutoLFM.UI.MainWindow.CreateFrame()
  if mainFrame then return mainFrame end
  
  mainFrame = CreateFrame("Frame", "AutoLFM_MainFrame", UIParent)
  UIPanelWindows["AutoLFM_MainFrame"] = { area = "left", pushable = 3 }
  mainFrame:SetWidth(384)
  mainFrame:SetHeight(512)
  mainFrame:Hide()
  
  local mainTexture = mainFrame:CreateTexture(nil, "BACKGROUND")
  mainTexture:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)
  mainTexture:SetWidth(512)
  mainTexture:SetHeight(512)
  mainTexture:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "mainFrame")
  
  local mainIcon = mainFrame:CreateTexture(nil, "LOW")
  mainIcon:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 7, -4)
  mainIcon:SetWidth(64)
  mainIcon:SetHeight(64)
  mainIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Eyes\\eye01")
  mainIconTexture = mainIcon
  
  local mainTitle = mainFrame:CreateFontString(nil, "MEDIUM", "GameFontNormal")
  mainTitle:SetPoint("TOP", mainFrame, "TOP", 0, -18)
  mainTitle:SetText("AutoLFM")
  
  local close = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -27, -8)
  close:SetScript("OnClick", function()
    HideUIPanel(mainFrame)
  end)
  
  return mainFrame
end

function AutoLFM.UI.MainWindow.GetFrame()
  return mainFrame
end

function AutoLFM.UI.MainWindow.GetIconTexture()
  return mainIconTexture
end

-----------------------------------------------------------------------------
-- Role Selector
-----------------------------------------------------------------------------
local function CreateRoleButton(roleName, xPos, texCoordStart)
  if not mainFrame or not roleName then return nil end
  
  local btn = CreateFrame("Button", nil, mainFrame)
  btn:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", xPos, -52)
  btn:SetWidth(54)
  btn:SetHeight(54)
  btn:SetHighlightTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "rolesHighlight")
  
  local bg = btn:CreateTexture(nil, "BACKGROUND")
  bg:SetPoint("TOPLEFT", btn, "TOPLEFT", -12, 14)
  bg:SetWidth(84)
  bg:SetHeight(84)
  bg:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "rolesBackground")
  bg:SetTexCoord(texCoordStart, texCoordStart + 0.2968, 0, 0.5937)
  bg:SetVertexColor(1, 1, 1, 0.6)
  
  local icon = btn:CreateTexture(nil, "BORDER")
  icon:SetAllPoints(btn)
  icon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "roles" .. roleName)
  
  local check = AutoLFM.UI.PanelBuilder.CreateCheckbox(mainFrame, nil, function()
    if AutoLFM.Logic.Selection.ToggleRole then
      AutoLFM.Logic.Selection.ToggleRole(roleName)
    end
  end)
  check:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 1, -5)
  check:SetWidth(24)
  check:SetHeight(24)
  
  btn:SetScript("OnClick", function()
    check:Click()
  end)
  
  roleButtons[roleName] = btn
  roleCheckboxes[roleName] = check
  
  return btn, check
end

function AutoLFM.UI.MainWindow.CreateRoleSelector()
  if not mainFrame then return end
  
  CreateRoleButton("Tank", 74, 0.2968)
  CreateRoleButton("Heal", 172, 0)
  CreateRoleButton("DPS", 270, 0.5937)
end

function AutoLFM.UI.MainWindow.UpdateRoleCheckboxes()
  if not roleCheckboxes or not AutoLFM.Logic.Selection.IsRoleSelected then return end
  AutoLFM.UI.PanelBuilder.BatchUpdateCheckboxes(roleCheckboxes, AutoLFM.Logic.Selection.IsRoleSelected)
end

function AutoLFM.UI.MainWindow.ClearRoleCheckboxes()
  AutoLFM.UI.PanelBuilder.ClearCheckboxes(roleCheckboxes)
end

function AutoLFM.UI.MainWindow.GetRoleCheckboxes()
  return roleCheckboxes
end

-----------------------------------------------------------------------------
-- Message Preview
-----------------------------------------------------------------------------
local function TruncateText(text, maxWidth, fontString)
  if not text or not fontString then return "", false end
  
  fontString:SetText(text)
  local textWidth = fontString:GetStringWidth()
  
  if textWidth <= maxWidth then
    return text, false
  end
  
  local ellipsis = " |cFFFFFFFF[...]|r"
  fontString:SetText(" [...]")
  local ellipsisWidth = fontString:GetStringWidth()
  local availableWidth = maxWidth - ellipsisWidth
  
  local len = string.len(text)
  local left = 1
  local right = len
  local result = text
  
  while left <= right do
    local mid = math.floor((left + right) / 2)
    local truncated = string.sub(text, 1, mid)
    fontString:SetText(truncated)
    local width = fontString:GetStringWidth()
    
    if width <= availableWidth then
      result = truncated
      left = mid + 1
    else
      right = mid - 1
    end
  end
  
  local lastSpace = 1
  for i = string.len(result), 1, -1 do
    local char = string.sub(result, i, i)
    if char == " " then
      lastSpace = i
      break
    end
  end
  
  if lastSpace > 1 and lastSpace > string.len(result) * 0.7 then
    result = string.sub(result, 1, lastSpace - 1)
  end
  
  return result .. ellipsis, true
end

function AutoLFM.UI.MainWindow.CreateMessagePreview()
  if not mainFrame then return nil end
  if messagePreviewFrame then return messagePreviewFrame end
  
  messagePreviewFrame = CreateFrame("Frame", nil, mainFrame)
  messagePreviewFrame:SetPoint("TOP", mainFrame, "TOP", -10, -125)
  messagePreviewFrame:SetWidth(330)
  messagePreviewFrame:SetHeight(30)
  
  messageText = messagePreviewFrame:CreateFontString(nil, "MEDIUM", "GameFontNormal")
  messageText:SetPoint("CENTER", messagePreviewFrame, "CENTER", -10, 0)
  messageText:SetWidth(290)
  messageText:SetJustifyH("CENTER")
  messageText:SetText("")
  
  local previewButton = CreateFrame("Button", nil, messagePreviewFrame)
  previewButton:SetPoint("RIGHT", messagePreviewFrame, "RIGHT", -4, 7)
  previewButton:SetWidth(20)
  previewButton:SetHeight(40)
  previewButton:Hide()
  
  local previewIcon = previewButton:CreateTexture(nil, "ARTWORK")
  previewIcon:SetAllPoints(previewButton)
  previewIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "preview")
  
  local previewIconHL = previewButton:CreateTexture(nil, "HIGHLIGHT")
  previewIconHL:SetAllPoints(previewButton)
  previewIconHL:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "preview")
  previewIconHL:SetBlendMode("ADD")
  
  previewButton:SetScript("OnClick", function()
    if not AutoLFM.Logic.Broadcaster.GetMessage then return end
    
    local message = AutoLFM.Logic.Broadcaster.GetMessage()
    if message and message ~= "" then
      AutoLFM.Core.Utils.Print("Preview: ")
      AutoLFM.Core.Utils.PrintInfo(message)
    end
  end)
  
  previewButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(previewButton, "ANCHOR_NONE")
    GameTooltip:SetPoint("BOTTOMRIGHT", previewButton, "TOPLEFT", 25, -10)
    GameTooltip:SetText("Preview full message in chat", 1, 1, 1)
    GameTooltip:Show()
  end)
  
  previewButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  
  messagePreviewFrame.previewButton = previewButton
  messagePreviewFrame:Show()
  
  return messagePreviewFrame
end

function AutoLFM.UI.MainWindow.UpdateMessagePreview()
  if not messageText or not AutoLFM.Logic.Broadcaster.GetMessage then return end
  
  local success, err = pcall(function()
    local message = AutoLFM.Logic.Broadcaster.GetMessage()
    if message and message ~= "" then
      local truncated, isTruncated = TruncateText(message, 290, messageText)
      messageText:SetText(truncated)
      
      if messagePreviewFrame and messagePreviewFrame.previewButton then
        if isTruncated then
          messagePreviewFrame.previewButton:Show()
        else
          messagePreviewFrame.previewButton:Hide()
        end
      end
    else
      messageText:SetText("")
      if messagePreviewFrame and messagePreviewFrame.previewButton then
        messagePreviewFrame.previewButton:Hide()
      end
    end
    
    if AutoLFM.UI.ClearTab and AutoLFM.UI.ClearTab.UpdateIcon then
      AutoLFM.UI.ClearTab.UpdateIcon()
    end
  end)
end

-----------------------------------------------------------------------------
-- Broadcast Button
-----------------------------------------------------------------------------
function AutoLFM.UI.MainWindow.CreateStartButton()
  if not mainFrame then return nil end
  if broadcastButton then return broadcastButton end
  
  broadcastButton = CreateFrame("Button", "AutoLFM_BroadcastToggle", mainFrame, "UIPanelButtonTemplate")
  broadcastButton:SetPoint("BOTTOM", mainFrame, "BOTTOM", 97, 80)
  broadcastButton:SetWidth(110)
  broadcastButton:SetHeight(21)
  broadcastButton:SetText("Start")
  
  broadcastButton:SetScript("OnClick", function()
    local success, err = pcall(function()
      if not AutoLFM.Logic.Broadcaster.IsActive then return end
      
      if AutoLFM.Logic.Broadcaster.IsActive() then
        if AutoLFM.Logic.Broadcaster.Stop then
          AutoLFM.Logic.Broadcaster.Stop()
        end
        broadcastButton:SetText("Start")
        pcall(PlaySoundFile, AutoLFM.UI.MainWindow.SOUND_STOP)
      else
        if AutoLFM.UI.MorePanel.EnsureChannelUIExists then
          AutoLFM.UI.MorePanel.EnsureChannelUIExists()
        end
        
        if AutoLFM.Logic.Broadcaster.Start then
          local startSuccess = AutoLFM.Logic.Broadcaster.Start()
          
          if startSuccess then
            broadcastButton:SetText("Stop")
            pcall(PlaySoundFile, AutoLFM.UI.MainWindow.SOUND_START)
          end
        end
      end
    end)
    
    if not success then
      AutoLFM.Core.Utils.PrintError("Broadcast button error: " .. tostring(err))
    end
  end)
  
  return broadcastButton
end

function AutoLFM.UI.MainWindow.GetStartButton()
  return broadcastButton
end

function AutoLFM.UI.MainWindow.GetBroadcastToggleButton()
  return broadcastButton
end

function AutoLFM.UI.MainWindow.SetBroadcastToggleButton(button)
  if button then
    broadcastButton = button
  end
end

-----------------------------------------------------------------------------
-- Globals (Required by WoW API)
-----------------------------------------------------------------------------
AutoLFM_MainFrame = nil
AutoLFM_MainIconTexture = nil
