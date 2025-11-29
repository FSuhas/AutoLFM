--=============================================================================
-- AutoLFM: Clear Tab (Icon-only action tab)
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.ClearTab then AutoLFM.UI.ClearTab = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local clearTabIcon = nil
local clearTabButton = nil
local isHovering = false

-----------------------------------------------------------------------------
-- Check if there's anything to clear
-----------------------------------------------------------------------------
local function HasAnySelection()
  local hasDungeons = false
  if AutoLFM.Logic.Content.GetSelectedDungeons then
    local dungeons = AutoLFM.Logic.Content.GetSelectedDungeons()
    hasDungeons = dungeons and table.getn(dungeons) > 0
  end
  
  local hasRaids = false
  if AutoLFM.Logic.Content.GetSelectedRaids then
    local raids = AutoLFM.Logic.Content.GetSelectedRaids()
    hasRaids = raids and table.getn(raids) > 0
  end
  
  local hasRoles = false
  if AutoLFM.Logic.Selection.GetRoles then
    local roles = AutoLFM.Logic.Selection.GetRoles()
    hasRoles = roles and table.getn(roles) > 0
  end
  
  local hasQuests = false
  local editBox = nil
  if AutoLFM.UI.MorePanel and AutoLFM.UI.MorePanel.GetCustomMessageEditBox then
    editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
  end
  if editBox then
    local text = editBox:GetText() or ""
    hasQuests = string.find(text, "|Hquest:") ~= nil
  end
  
  local hasCustomMessage = false
  if editBox then
    local text = editBox:GetText() or ""
    hasCustomMessage = text ~= ""
  end
  
  return hasDungeons or hasRaids or hasRoles or hasQuests or hasCustomMessage
end

-----------------------------------------------------------------------------
-- Update icon based on selection state
-----------------------------------------------------------------------------
function AutoLFM.UI.ClearTab.UpdateIcon()
  if not clearTabIcon then return end
  
  if isHovering then
    clearTabIcon:SetVertexColor(1, 0, 0)
  elseif HasAnySelection() then
    clearTabIcon:SetVertexColor(1, 0.82, 0)
  else
    clearTabIcon:SetVertexColor(0.5, 0.5, 0.5)
  end
end

-----------------------------------------------------------------------------
-- Set icon reference and setup hover events
-----------------------------------------------------------------------------
function AutoLFM.UI.ClearTab.SetIcon(icon)
  clearTabIcon = icon
  AutoLFM.UI.ClearTab.UpdateIcon()
end

function AutoLFM.UI.ClearTab.SetButton(button)
  clearTabButton = button
  
  if clearTabButton then
    clearTabButton:SetScript("OnEnter", function()
      if HasAnySelection() then
        isHovering = true
        AutoLFM.UI.ClearTab.UpdateIcon()
        GameTooltip:SetOwner(clearTabButton, "ANCHOR_NONE")
        GameTooltip:SetPoint("BOTTOMRIGHT", clearTabButton, "TOPRIGHT", -1, -2)
        GameTooltip:SetText("Clear all", 1, 1, 1)
        GameTooltip:Show()
      end
    end)
    
    clearTabButton:SetScript("OnLeave", function()
      isHovering = false
      AutoLFM.UI.ClearTab.UpdateIcon()
      GameTooltip:Hide()
    end)
  end
end

-----------------------------------------------------------------------------
-- Tab Management (no panel, just action)
-----------------------------------------------------------------------------
function AutoLFM.UI.ClearTab.OnTabClick()
  if AutoLFM.Logic.Content.ClearDungeons then
    AutoLFM.Logic.Content.ClearDungeons()
  end
  
  if AutoLFM.UI.DungeonsPanel and AutoLFM.UI.DungeonsPanel.ClearSelection then
    AutoLFM.UI.DungeonsPanel.ClearSelection()
  end
  
  if AutoLFM.Logic.Content.ClearRaids then
    AutoLFM.Logic.Content.ClearRaids()
  end
  
  if AutoLFM.UI.RaidsPanel and AutoLFM.UI.RaidsPanel.ClearSelection then
    AutoLFM.UI.RaidsPanel.ClearSelection()
  end

  if AutoLFM.UI.QuestsPanel and AutoLFM.UI.QuestsPanel.UncheckAllQuestCheckboxes then
    AutoLFM.UI.QuestsPanel.UncheckAllQuestCheckboxes()
  end
  
  if AutoLFM.UI.MainWindow and AutoLFM.UI.MainWindow.ClearRoleCheckboxes then
    AutoLFM.UI.MainWindow.ClearRoleCheckboxes()
  end
  
  if AutoLFM.Logic.Selection.ClearRoles then
    AutoLFM.Logic.Selection.ClearRoles()
  end
  
  local editBox = nil
  if AutoLFM.UI.MorePanel and AutoLFM.UI.MorePanel.GetCustomMessageEditBox then
    editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
  end
  
  if editBox then
    editBox:SetText("")
    editBox:ClearFocus()
  end
  
  if AutoLFM.Logic.Broadcaster.SetCustomMessage then
    AutoLFM.Logic.Broadcaster.SetCustomMessage("")
  end
  
  if AutoLFM.Logic.Broadcaster.UpdateMessage then
    AutoLFM.Logic.Broadcaster.UpdateMessage()
  end
  
  if AutoLFM.UI.MainWindow.UpdateMessagePreview then
    AutoLFM.UI.MainWindow.UpdateMessagePreview()
  end
  
  AutoLFM.UI.ClearTab.UpdateIcon()
end

function AutoLFM.UI.ClearTab.Init()
  -- ClearTab has no panel to create, it's just an action button
  AutoLFM.UI.ClearTab.Register()
end

function AutoLFM.UI.ClearTab.Register()
end
