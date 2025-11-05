--=============================================================================
-- AutoLFM: Main Window
--=============================================================================

AutoLFM = AutoLFM or {}
AutoLFM.UI = AutoLFM.UI or {}
AutoLFM.UI.MainWindow = AutoLFM.UI.MainWindow or {
  RoleSelector = {},
  MessagePreview = {},
  StartButton = {}
}

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local mainFrame, messagePreviewFrame, messageText, broadcastButton
local roleButtons, roleCheckboxes = {}, {}

-----------------------------------------------------------------------------
-- Main Frame Creation
-----------------------------------------------------------------------------
function AutoLFM.UI.MainWindow.Init()
  if mainFrame then return mainFrame end

  mainFrame = CreateFrame("Frame", "AutoLFM_MainFrame", UIParent)
  mainFrame:SetToplevel(1)
  UIPanelWindows["AutoLFM_MainFrame"] = { area = "left", pushable = 3 }
  mainFrame:SetWidth(384)
  mainFrame:SetHeight(512)
  mainFrame:Hide()

  local mainTexture = mainFrame:CreateTexture(nil, "BACKGROUND")
  mainTexture:SetPoint("TOPLEFT", 0, 0)
  mainTexture:SetWidth(512)
  mainTexture:SetHeight(512)
  mainTexture:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "mainFrame")

  local mainIcon = mainFrame:CreateTexture(nil, "LOW")
  mainIcon:SetPoint("TOPLEFT", 7, -4)
  mainIcon:SetWidth(64)
  mainIcon:SetHeight(64)
  mainIcon:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "Eyes\\eye01")
  AutoLFM_MainIconTexture = mainIcon

  local mainTitle = mainFrame:CreateFontString(nil, "MEDIUM", "GameFontNormal")
  mainTitle:SetPoint("TOP", 0, -18)
  mainTitle:SetText("AutoLFM")

  local close = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -27, -8)
  close:SetScript("OnClick", function() HideUIPanel(mainFrame) end)

  AutoLFM_MainFrame = mainFrame

  AutoLFM.UI.MainWindow.RoleSelector.Init()
  AutoLFM.UI.MainWindow.MessagePreview.Init()
  AutoLFM.UI.MainWindow.StartButton.Init()

  AutoLFM.UI.DarkUI.RegisterFrame(mainFrame)

  return mainFrame
end

function AutoLFM.UI.MainWindow.GetFrame()
  return mainFrame
end

-----------------------------------------------------------------------------
-- Role Selector
-----------------------------------------------------------------------------
local function CreateRoleButton(roleName, xPos, texCoordStart)
  if not mainFrame or not roleName then return end

  local btn = CreateFrame("Button", nil, mainFrame)
  btn:SetPoint("TOPLEFT", xPos, -52)
  btn:SetWidth(54)
  btn:SetHeight(54)
  btn:SetHighlightTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "rolesHighlight")

  local bg = btn:CreateTexture(nil, "BACKGROUND")
  bg:SetPoint("TOPLEFT", -12, 14)
  bg:SetWidth(84)
  bg:SetHeight(84)
  bg:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "rolesBackground")
  bg:SetTexCoord(texCoordStart, texCoordStart + 0.2968, 0, 0.5937)
  bg:SetVertexColor(1, 1, 1, 0.6)

  local icon = btn:CreateTexture(nil, "BORDER")
  icon:SetAllPoints(btn)
  icon:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "roles" .. roleName)

  local check = AutoLFM.UI.PanelBuilder.CreateCheckbox(mainFrame, nil, function()
    if AutoLFM.Logic.Selection.ToggleRole then
      AutoLFM.Logic.Selection.ToggleRole(roleName)
    end
  end)
  check:SetPoint("BOTTOMLEFT", btn, 1, -5)
  check:SetWidth(24)
  check:SetHeight(24)

  btn:SetScript("OnClick", function() check:Click() end)

  roleButtons[roleName] = btn
  roleCheckboxes[roleName] = check
  btn.rolesBackground = bg
end

function AutoLFM.UI.MainWindow.RoleSelector.Init()
  if not mainFrame then return end

  CreateRoleButton("Tank", 74, 0.2968)
  CreateRoleButton("Heal", 172, 0)
  CreateRoleButton("DPS", 270, 0.5937)
end

function AutoLFM.UI.MainWindow.UpdateRoleCheckboxes()
  if roleCheckboxes and AutoLFM.Logic.Selection.IsRoleSelected then
    AutoLFM.UI.PanelBuilder.BatchUpdateCheckboxes(roleCheckboxes, AutoLFM.Logic.Selection.IsRoleSelected)
  end
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
function AutoLFM.UI.MainWindow.MessagePreview.Init()
  if not mainFrame then return nil end
  if messagePreviewFrame then return messagePreviewFrame end

  messagePreviewFrame = CreateFrame("Frame", nil, mainFrame)
  messagePreviewFrame:SetPoint("TOP", -10, -125)
  messagePreviewFrame:SetWidth(330)
  messagePreviewFrame:SetHeight(30)

  messageText = messagePreviewFrame:CreateFontString(nil, "MEDIUM", "GameFontNormal")
  messageText:SetPoint("CENTER", -10, 0)
  messageText:SetWidth(290)
  messageText:SetJustifyH("CENTER")
  messageText:SetText("")

  local previewButton = CreateFrame("Button", nil, messagePreviewFrame)
  previewButton:SetPoint("RIGHT", -4, 7)
  previewButton:SetWidth(20)
  previewButton:SetHeight(40)
  previewButton:Hide()

  local previewIcon = previewButton:CreateTexture(nil, "ARTWORK")
  previewIcon:SetAllPoints(previewButton)
  previewIcon:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "preview")

  local previewIconHL = previewButton:CreateTexture(nil, "HIGHLIGHT")
  previewIconHL:SetAllPoints(previewButton)
  previewIconHL:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "preview")
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
  return messagePreviewFrame
end

function AutoLFM.UI.MainWindow.UpdateMessagePreview()
  if not messageText then return end

  local message = AutoLFM.Logic.Broadcaster.GetMessage and AutoLFM.Logic.Broadcaster.GetMessage() or ""
  if message ~= "" then
    local truncated, isTruncated = AutoLFM.Core.Utils.TruncateByWidth(message, 290, messageText, " |cFFFFFFFF[...]|r")
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
end

-----------------------------------------------------------------------------
-- Broadcast Button
-----------------------------------------------------------------------------
function AutoLFM.UI.MainWindow.StartButton.Init()
  if not mainFrame then return nil end
  if broadcastButton then return broadcastButton end

  broadcastButton = CreateFrame("Button", "AutoLFM_BroadcastToggle", mainFrame, "UIPanelButtonTemplate")
  broadcastButton:SetPoint("BOTTOM", 97, 80)
  broadcastButton:SetWidth(110)
  broadcastButton:SetHeight(21)
  broadcastButton:SetText("Start")

  broadcastButton:SetScript("OnClick", function()
    if not AutoLFM.Logic.Broadcaster.IsActive then return end

    if AutoLFM.Logic.Broadcaster.IsActive() then
      if AutoLFM.Logic.Broadcaster.Stop then
        AutoLFM.Logic.Broadcaster.Stop()
      end
      broadcastButton:SetText("Start")
      pcall(PlaySoundFile, AutoLFM.Core.Constants.SOUND_PATH .. AutoLFM.Core.Constants.SOUNDS.STOP)
    else
      if AutoLFM.UI.MorePanel.EnsureChannelUIExists then
        AutoLFM.UI.MorePanel.EnsureChannelUIExists()
      end

      if AutoLFM.Logic.Broadcaster.Start then
        local startSuccess = AutoLFM.Logic.Broadcaster.Start()
        if startSuccess then
          broadcastButton:SetText("Stop")
          pcall(PlaySoundFile, AutoLFM.Core.Constants.SOUND_PATH .. AutoLFM.Core.Constants.SOUNDS.START)
        end
      end
    end
  end)

  return broadcastButton
end

function AutoLFM.UI.MainWindow.GetBroadcastToggleButton()
  return broadcastButton
end
