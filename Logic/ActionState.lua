--=============================================================================
-- AutoLFM: Action State
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Logic then AutoLFM.Logic = {} end
if not AutoLFM.Logic.ActionState then AutoLFM.Logic.ActionState = {} end

-----------------------------------------------------------------------------
-- State Checks
-----------------------------------------------------------------------------
local function HasAnyContent()
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

  local hasCustomMessage = false
  local editBox = nil
  if AutoLFM.UI.MorePanel and AutoLFM.UI.MorePanel.GetCustomMessageEditBox then
    editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
  end
  if editBox then
    local text = editBox:GetText() or ""
    hasCustomMessage = text ~= ""
  end

  return hasDungeons or hasRaids or hasRoles or hasCustomMessage
end

function AutoLFM.Logic.ActionState.HasAnythingToClear()
  local hasQuests = false
  local editBox = nil
  if AutoLFM.UI.MorePanel and AutoLFM.UI.MorePanel.GetCustomMessageEditBox then
    editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
  end
  if editBox then
    local text = editBox:GetText() or ""
    hasQuests = string.find(text, "|Hquest:") ~= nil
  end

  return HasAnyContent() or hasQuests
end

function AutoLFM.Logic.ActionState.HasAnythingToSave()
  return HasAnyContent()
end

-----------------------------------------------------------------------------
-- Clear All Action
-----------------------------------------------------------------------------
function AutoLFM.Logic.ActionState.ClearAll()
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

  if AutoLFM.UI.Components.MainWindow and AutoLFM.UI.Components.MainWindow.ClearRoleCheckboxes then
    AutoLFM.UI.Components.MainWindow.ClearRoleCheckboxes()
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

  if AutoLFM.UI.Components.MainWindow.UpdateMessagePreview then
    AutoLFM.UI.Components.MainWindow.UpdateMessagePreview()
  end

  if AutoLFM.UI.Components.LineTabs and AutoLFM.UI.Components.LineTabs.UpdateActionIcons then
    AutoLFM.UI.Components.LineTabs.UpdateActionIcons()
  end
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function AutoLFM.Logic.ActionState.Init()
  return true
end

-----------------------------------------------------------------------------
-- Save Preset Action
-----------------------------------------------------------------------------
local function GeneratePresetName()
  return date("%Y%m%d_%H%M%S")
end

local function ShowPresetNameDialog(presetData)
  local savedPresetData = presetData

  StaticPopupDialogs["AUTOLFM_PRESET_NAME"] = {
    text = "Enter preset name:",
    button1 = "Save",
    button2 = "Cancel",
    hasEditBox = 1,
    maxLetters = 50,
    OnAccept = function()
      local editBox = getglobal(this:GetParent():GetName().."EditBox")
      local presetName = editBox:GetText()
      if presetName and presetName ~= "" then
        if AutoLFM.Core.Settings.SavePreset and savedPresetData then
          local success = AutoLFM.Core.Settings.SavePreset(presetName, savedPresetData)
          if success then
            AutoLFM.Core.Utils.PrintSuccess("Preset saved: " .. AutoLFM.Color(presetName, "yellow"))
            if AutoLFM.UI.PresetPanel and AutoLFM.UI.PresetPanel.Refresh then
              AutoLFM.UI.PresetPanel.Refresh()
            end
          else
            AutoLFM.Core.Utils.PrintError("Failed to save preset")
          end
        end
      end
    end,
    OnShow = function()
      local editBox = getglobal(this:GetName().."EditBox")
      editBox:SetText(GeneratePresetName())
      editBox:HighlightText()
    end,
    OnHide = function()
      if AutoLFM.UI.Components.LineTabs and AutoLFM.UI.Components.LineTabs.UpdateActionIcons then
        AutoLFM.UI.Components.LineTabs.UpdateActionIcons()
      end
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1
  }

  StaticPopup_Show("AUTOLFM_PRESET_NAME")
end

local function CaptureCurrentSelection()
  local preset = {}

  preset.name = GeneratePresetName()

  if AutoLFM.Logic.Content.GetSelectedDungeons then
    local dungeons = AutoLFM.Logic.Content.GetSelectedDungeons()
    preset.dungeons = {}
    for i = 1, table.getn(dungeons) do
      table.insert(preset.dungeons, dungeons[i])
    end
  end

  if AutoLFM.Logic.Content.GetSelectedRaids then
    local raids = AutoLFM.Logic.Content.GetSelectedRaids()
    preset.raids = {}
    for i = 1, table.getn(raids) do
      table.insert(preset.raids, raids[i])
    end
  end

  if AutoLFM.Logic.Content.GetRaidSize then
    preset.raidSize = AutoLFM.Logic.Content.GetRaidSize()
  end

  if AutoLFM.Logic.Selection.GetRoles then
    local roles = AutoLFM.Logic.Selection.GetRoles()
    preset.roles = {}
    for i = 1, table.getn(roles) do
      table.insert(preset.roles, roles[i])
    end
  end

  if AutoLFM.UI.MorePanel and AutoLFM.UI.MorePanel.GetCustomMessageEditBox then
    local editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
    if editBox then
      preset.customMessage = editBox:GetText() or ""
    end
  end

  if AutoLFM.Core.Settings.LoadInterval then
    preset.interval = AutoLFM.Core.Settings.LoadInterval()
  end

  if AutoLFM.Core.Settings.LoadChannels then
    local channels = AutoLFM.Core.Settings.LoadChannels()
    preset.channels = {}
    for k, v in pairs(channels) do
      preset.channels[k] = v
    end
  end

  return preset
end

local function HasAnySelection(preset)
  local hasDungeons = preset.dungeons and table.getn(preset.dungeons) > 0
  local hasRaids = preset.raids and table.getn(preset.raids) > 0
  local hasRoles = preset.roles and table.getn(preset.roles) > 0
  local hasMessage = preset.customMessage and preset.customMessage ~= ""

  return hasDungeons or hasRaids or hasRoles or hasMessage
end

function AutoLFM.Logic.ActionState.SavePreset()
  local preset = CaptureCurrentSelection()

  if not HasAnySelection(preset) then
    return
  end

  ShowPresetNameDialog(preset)
end