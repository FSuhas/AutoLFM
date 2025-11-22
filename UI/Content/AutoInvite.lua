--=============================================================================
-- AutoLFM: AutoInvite UI
--   UI handlers for auto-invite configuration
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.UI = AutoLFM.UI or {}
AutoLFM.UI.Content = AutoLFM.UI.Content or {}
AutoLFM.UI.Content.AutoInvite = {}

--=============================================================================
-- PRIVATE STATE
--=============================================================================
local contentFrame = nil

--=============================================================================
-- FRAME LIFECYCLE
--=============================================================================

--- Initializes the AutoInvite content frame
--- @param frame frame - The content frame
function AutoLFM.UI.Content.AutoInvite.OnLoad(frame)
  contentFrame = frame
end

--- Called when AutoInvite panel is shown
--- @param frame frame - The content frame
function AutoLFM.UI.Content.AutoInvite.OnShow(frame)
  AutoLFM.UI.Content.AutoInvite.Refresh()
end

--=============================================================================
-- UI HANDLERS
--=============================================================================

--- Handles enable/disable button click
function AutoLFM.UI.Content.AutoInvite.OnEnableClick()
  local enabled = AutoLFM.Core.Persistent.GetAutoInviteEnabled()
  if enabled then
    AutoLFM.Core.Maestro.Dispatch("AutoInvite.Disable")
  else
    AutoLFM.Core.Maestro.Dispatch("AutoInvite.Enable")
  end
end

--- Handles keyword input change
function AutoLFM.UI.Content.AutoInvite.OnKeywordChange()
  local input = getglobal("AutoLFM_AutoInvite_KeywordInput")
  if not input then return end
  local keyword = input:GetText()
  if keyword and keyword ~= "" then
    AutoLFM.Core.Maestro.Dispatch("AutoInvite.SetKeyword", keyword)
  end
end

--- Handles confirmation checkbox click
function AutoLFM.UI.Content.AutoInvite.OnConfirmClick()
  AutoLFM.Core.Maestro.Dispatch("AutoInvite.ToggleConfirm")
end

--=============================================================================
-- REFRESH
--=============================================================================

--- Refreshes the AutoInvite UI with current settings
function AutoLFM.UI.Content.AutoInvite.Refresh()
  local scrollChild = getglobal("AutoLFM_Content_AutoInvite_ScrollFrame_ScrollChild")
  if not scrollChild then return end
  
  local title = getglobal(scrollChild:GetName() .. "_Title")
  local statusLabel = getglobal(scrollChild:GetName() .. "_StatusLabel")
  local keywordLabel = getglobal(scrollChild:GetName() .. "_KeywordLabel")
  local enableBtn = getglobal("AutoLFM_AutoInvite_EnableButton")
  local keywordInput = getglobal("AutoLFM_AutoInvite_KeywordInput")
  local confirmCheck = getglobal("AutoLFM_AutoInvite_ConfirmCheck")
  
  if title then
    title:SetText("Auto Invite")
  end
  
  if statusLabel then
    statusLabel:SetText("Status:")
  end
  
  if keywordLabel then
    keywordLabel:SetText("Keyword:")
  end
  
  if enableBtn then
    local enabled = AutoLFM.Core.Persistent.GetAutoInviteEnabled()
    enableBtn:SetText(enabled and "Disable" or "Enable")
  end
  
  if keywordInput then
    local keyword = AutoLFM.Core.Persistent.GetAutoInviteKeyword()
    keywordInput:SetText(keyword)
  end
  
  if confirmCheck then
    local confirm = AutoLFM.Core.Persistent.GetAutoInviteConfirm()
    confirmCheck:SetChecked(confirm)
    local checkText = getglobal(confirmCheck:GetName() .. "Text")
    if checkText then
      checkText:SetText("Send confirmation message")
    end
  end
end

--=============================================================================
-- INITIALIZATION
--=============================================================================

--- Initializes AutoInvite UI and registers event listeners
AutoLFM.Core.SafeRegisterInit("UI.Content.AutoInvite", function()
  AutoLFM.Core.Maestro.Listen(
    "UI.AutoInvite.OnChanged",
    "AutoInvite.Changed",
    function()
      if contentFrame and contentFrame:IsVisible() then
        AutoLFM.UI.Content.AutoInvite.Refresh()
      end
    end,
    { id = "L12" }
  )
end, {
  id = "I27",
  dependencies = { "Logic.AutoInvite" }
})
