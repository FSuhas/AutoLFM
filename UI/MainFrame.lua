--=============================================================================
-- AutoLFM: MainFrame UI
--   UI handlers and event callbacks
--=============================================================================

AutoLFM = AutoLFM or {}
AutoLFM.UI = AutoLFM.UI or {}
AutoLFM.UI.MainFrame = {}

--=============================================================================
-- UI HANDLERS (for XML callbacks)
--=============================================================================

--- XML OnLoad callback - initializes main frame as UIPanel and registers for dark theme
--- @param frame frame - The main frame being loaded
function AutoLFM.UI.MainFrame.OnLoad(frame)
  -- Register as UIPanel (WoW handles positioning automatically)
  UIPanelWindows[frame:GetName()] = { area = "left", pushable = 3 }
  tinsert(UISpecialFrames, frame:GetName())

  -- Register frame for DarkUI theme
  if AutoLFM.Components.DarkUI and AutoLFM.Components.DarkUI.RegisterFrame then
    AutoLFM.Components.DarkUI.RegisterFrame(frame)
  end
end

--- XML OnShow callback - initializes content frames on first show and applies dark theme
--- @param frame frame - The main frame being shown
function AutoLFM.UI.MainFrame.OnShow(frame)
  -- Initialize content frames on first show (child frames are guaranteed to exist)
  if not frame.initialized then
    AutoLFM.Logic.MainFrame.InitializeContentFrames()
    frame.initialized = true
  else
    -- Apply default panel every time the window opens
    if AutoLFM.Logic.MainFrame.ApplyDefaultPanel then
      AutoLFM.Logic.MainFrame.ApplyDefaultPanel()
    end
  end

  -- Apply dark theme if enabled
  if AutoLFM.Components.DarkUI and AutoLFM.Components.DarkUI.IsEnabled() then
    AutoLFM.Components.DarkUI.DarkenFrame(frame)
  end
  
  -- Force update message preview with current state
  local currentMessage = AutoLFM.Core.Maestro.GetState("Message.ToBroadcast")
  if AutoLFM.UI.MainFrame.UpdateMessagePreview and currentMessage then
    AutoLFM.UI.MainFrame.UpdateMessagePreview(currentMessage)
  end

  PlaySound("GAMEDIALOGOPEN")
end

--- XML OnHide callback - plays close sound when frame is hidden
--- @param frame frame - The main frame being hidden
function AutoLFM.UI.MainFrame.OnHide(frame)
  PlaySound("GAMEDIALOGCLOSE")
end

--- XML OnEnter callback for bottom tabs - shows highlight if tab should be highlighted
--- @param tabIndex number - The index of the tab being hovered (1-4)
function AutoLFM.UI.MainFrame.OnBottomTabEnter(tabIndex)
  if AutoLFM.Logic.MainFrame.ShouldShowTabHighlight(tabIndex) then
  local tab = getglobal("AutoLFM_MainFrame_Tab" .. tabIndex)
  if tab then
    local highlight = getglobal(tab:GetName() .. "_Highlight")
    if highlight then
      highlight:Show()
    end
  end
  end
end

--- XML OnLeave callback for bottom tabs - hides highlight when mouse leaves tab
--- @param tabIndex number - The index of the tab no longer being hovered (1-4)
function AutoLFM.UI.MainFrame.OnBottomTabLeave(tabIndex)
  local tab = getglobal("AutoLFM_MainFrame_Tab" .. tabIndex)
  if tab then
  local highlight = getglobal(tab:GetName() .. "_Highlight")
  if highlight then
    highlight:Hide()
  end
  end
end

--=============================================================================
-- UTILITY HANDLERS (for repeated XML behaviors)
--=============================================================================

--- Shows a tooltip for a button with custom positioning
--- @param button frame - The button to attach the tooltip to
--- @param text string - The text to display in the tooltip
function AutoLFM.UI.MainFrame.ShowTooltip(button, text)
  if not button or not text then return end

  GameTooltip:SetOwner(button, "ANCHOR_NONE")
  GameTooltip:ClearAllPoints()
  GameTooltip:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", 6, 0)
  GameTooltip:SetText(text, 1, 1, 1)
  GameTooltip:Show()
end

--- Hides the currently displayed game tooltip
function AutoLFM.UI.MainFrame.HideTooltip()
  GameTooltip:Hide()
end

--- Shows the visual click effect on a button (if enabled)
--- @param button frame - The button to show the click effect on
function AutoLFM.UI.MainFrame.ShowClickEffect(button)
  if button:IsEnabled() then
  button._click = button._click or getglobal(button:GetName() .. "_Click")
  if button._click then
    button._click:Show()
  end
  end
end

--- Hides the visual click effect on a button
--- @param button frame - The button to hide the click effect on
function AutoLFM.UI.MainFrame.HideClickEffect(button)
  button._click = button._click or getglobal(button:GetName() .. "_Click")
  if button._click then
  button._click:Hide()
  end
end

--- XML OnLoad callback for role buttons - initializes background color
--- @param button frame - The role button being initialized
function AutoLFM.UI.MainFrame.InitRoleButton(button)
  button._background = button._background or getglobal(button:GetName() .. "_Background")
  AutoLFM.Core.Utils.SetVertexColorByName(button._background, "WHITE", 0.6)
end

--- XML OnClick callback for role buttons - toggles the associated checkbox
--- @param button frame - The role button that was clicked
function AutoLFM.UI.MainFrame.OnRoleButtonClick(button)
  button._checkbox = button._checkbox or getglobal(button:GetName() .. "Checkbox")
  if button._checkbox then
  button._checkbox:Click()
  end
end

--- XML OnClick callback for role checkboxes - dispatches role toggle via Maestro
--- @param checkbox frame - The checkbox that was clicked
--- @param role string - The role being toggled ("TANK", "HEAL", or "DPS")
function AutoLFM.UI.MainFrame.OnRoleCheckboxClick(checkbox, role)
  -- Dispatch to Maestro (will update state, which will then update UI via subscriber)
  AutoLFM.Core.Maestro.Dispatch("Selection.ToggleRole", role)
end

--- Synchronizes role checkboxes with Selection.Roles state
--- Called when Selection.Roles state changes to update UI
function AutoLFM.UI.MainFrame.UpdateRoleCheckboxes()
  local roles = AutoLFM.Core.Maestro.GetState("Selection.Roles") or {}

  -- Debug: Log the current roles state
  AutoLFM.Core.Utils.LogInfo("UpdateRoleCheckboxes called, roles count: " .. table.getn(roles))

  -- Build a lookup table for O(1) checks
  local roleSet = {}
  for i = 1, table.getn(roles) do
    roleSet[roles[i]] = true
  end

  -- Update each checkbox
  local tankCheckbox = getglobal("AutoLFM_MainFrame_RoleTankCheckbox")
  local healCheckbox = getglobal("AutoLFM_MainFrame_RoleHealCheckbox")
  local dpsCheckbox = getglobal("AutoLFM_MainFrame_RoleDPSCheckbox")

  -- Debug: Verify checkboxes were found
  if not tankCheckbox then
    AutoLFM.Core.Utils.LogWarning("Tank checkbox not found!")
  end
  if not healCheckbox then
    AutoLFM.Core.Utils.LogWarning("Heal checkbox not found!")
  end
  if not dpsCheckbox then
    AutoLFM.Core.Utils.LogWarning("DPS checkbox not found!")
  end

  if tankCheckbox then
    local shouldCheck = roleSet["TANK"] and 1 or nil
    AutoLFM.Core.Utils.LogInfo("Setting TANK checkbox to: " .. tostring(shouldCheck))
    tankCheckbox:SetChecked(shouldCheck)
  end
  if healCheckbox then
    local shouldCheck = roleSet["HEAL"] and 1 or nil
    AutoLFM.Core.Utils.LogInfo("Setting HEAL checkbox to: " .. tostring(shouldCheck))
    healCheckbox:SetChecked(shouldCheck)
  end
  if dpsCheckbox then
    local shouldCheck = roleSet["DPS"] and 1 or nil
    AutoLFM.Core.Utils.LogInfo("Setting DPS checkbox to: " .. tostring(shouldCheck))
    dpsCheckbox:SetChecked(shouldCheck)
  end
end

--- XML OnClick callback for close button - dispatches MainFrame.Toggle command
function AutoLFM.UI.MainFrame.OnCloseButtonClick()
  AutoLFM.Core.Maestro.Dispatch("MainFrame.Toggle")
end

--- XML OnLoad callback for main action button - initializes button state
--- @param button frame - The main button being loaded
function AutoLFM.UI.MainFrame.OnMainButtonLoad(button)
  AutoLFM.UI.MainFrame.UpdateMainButton()
end

--- XML OnClick callback for main action button - toggles broadcaster
function AutoLFM.UI.MainFrame.OnMainButtonClick()
  if AutoLFM.Logic.Broadcaster then
    AutoLFM.Logic.Broadcaster.Toggle()
  end
end

--- Updates the main button text and enabled state based on broadcaster status
function AutoLFM.UI.MainFrame.UpdateMainButton()
  local button = getglobal("AutoLFM_MainFrame_MainButton")
  if not button then return end

  local isRunning = AutoLFM.Core.Maestro.GetState("Broadcaster.IsRunning") or false
  local message = AutoLFM.Core.Maestro.GetState("Message.ToBroadcast") or ""
  local channels = AutoLFM.Core.Maestro.GetState("Channels.ActiveChannels") or {}

  -- Update button text
  if isRunning then
    button:SetText("Stop")
    button:Enable()
  else
    button:SetText("Start")
    -- Enable if we have a message and (at least one channel OR dry run mode)
    local isDryRun = AutoLFM.Core.Maestro.GetState("Settings.DryRun") or false
    if message ~= "" and (table.getn(channels) > 0 or isDryRun) then
      button:Enable()
    else
      button:Disable()
    end
  end
end

--- XML OnEnter callback for preview button - shows tooltip with custom positioning
--- @param button frame - The preview button being hovered
function AutoLFM.UI.MainFrame.OnPreviewButtonEnter(button)
  GameTooltip:SetOwner(button, "ANCHOR_NONE")
  GameTooltip:SetPoint("BOTTOMRIGHT", button, "TOPLEFT", 25, -10)
  GameTooltip:SetText("Preview full message in chat", 1, 1, 1)
  GameTooltip:Show()
end

--- XML OnLoad callback for minimap button - registers for clicks, drag, and dark theme
--- @param button frame - The minimap button being loaded
function AutoLFM.UI.MainFrame.OnMinimapButtonLoad(button)
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  button:RegisterForDrag("LeftButton")
  button:SetClampedToScreen(true)

  -- Register for DarkUI theme
  if AutoLFM.Components.DarkUI and AutoLFM.Components.DarkUI.RegisterFrame then
  AutoLFM.Components.DarkUI.RegisterFrame(button)
  end
end

--- XML OnDragStart callback for minimap button - starts moving if Ctrl is held
--- @param button frame - The minimap button being dragged
function AutoLFM.UI.MainFrame.OnMinimapDragStart(button)
  if IsControlKeyDown() then
  button:LockHighlight()
  button:StartMoving()
  end
end

--- XML OnDragStop callback for minimap button - stops moving and saves new position
--- @param button frame - The minimap button that was dragged
function AutoLFM.UI.MainFrame.OnMinimapDragStop(button)
  button:UnlockHighlight()
  button:StopMovingOrSizing()
  AutoLFM.Components.MinimapButton.OnDragStop(button)
end

--=============================================================================
-- MESSAGE PREVIEW UPDATE
--=============================================================================

--- Updates the message preview text in the main frame
--- Truncates the message if it's too long and shows a preview button
--- @param message string - The message to display in the preview
function AutoLFM.UI.MainFrame.UpdateMessagePreview(message)
  local messageFrame = getglobal("AutoLFM_MainFrame_MessagePreview")
  if not messageFrame then return end

  local messageText = getglobal("AutoLFM_MainFrame_MessagePreview_Text")
  if not messageText then return end

  local previewButton = getglobal("AutoLFM_MainFrame_MessagePreview_Button")

  if message and message ~= "" then
    -- Get number of lines from settings (default 2)
    local maxLines = 2
    if AutoLFM.Core.Persistent and AutoLFM.Core.Persistent.GetPreviewMessageLines then
      maxLines = AutoLFM.Core.Persistent.GetPreviewMessageLines()
    end

    -- Truncate message if needed
    local truncated, isTruncated = AutoLFM.Core.Utils.TruncateByWidth(
      message,
      AutoLFM.Core.Constants.MESSAGE_PREVIEW_TEXT_WIDTH,
      messageText,
      " |cFFFFFFFF[...]|r",
      maxLines
    )

    messageText:SetText("|cFFFFD100" .. truncated .. "|r")

    -- Show/hide preview button based on truncation
    if previewButton then
      if isTruncated then
        previewButton:Show()
      else
        previewButton:Hide()
      end
    end
  else
    messageText:SetText("")
    if previewButton then
      previewButton:Hide()
    end
  end
end

--- Shows the full message preview in the chat window
function AutoLFM.UI.MainFrame.ShowFullPreview()
  local message = AutoLFM.Core.Maestro.GetState("Message.ToBroadcast")
  if message and message ~= "" then
    AutoLFM.Core.Utils.Print("Preview: " .. message)
  end
end

--- Updates a side button state (enabled/disabled) based on selections
--- @param buttonName string - The global button name (e.g., "AutoLFM_MainFrame_SideTab1")
local function updateSideButtonState(buttonName)
  local button = getglobal(buttonName)
  if not button then return end

  local hasSelections = false
  if AutoLFM.Logic.Selection and AutoLFM.Logic.Selection.HasSelections then
    hasSelections = AutoLFM.Logic.Selection.HasSelections()
  end

  local icon = getglobal(button:GetName() .. "_Icon")

  if hasSelections then
    button:Enable()
    -- Reset icon to normal color
    if icon then
      icon:SetVertexColor(1, 1, 1, 1)
    end
  else
    button:Disable()
    -- Gray out the icon
    if icon then
      icon:SetVertexColor(0.5, 0.5, 0.5, 0.5)
    end
  end
end

--- Updates the Clear All button state (enabled/disabled) based on selections
function AutoLFM.UI.MainFrame.UpdateClearAllButton()
  updateSideButtonState("AutoLFM_MainFrame_SideTab1")
end

--- Updates the Add Preset button state (enabled/disabled) based on selections
function AutoLFM.UI.MainFrame.UpdateAddPresetButton()
  updateSideButtonState("AutoLFM_MainFrame_SideTab3")
end

--- Updates both Clear All and Add Preset buttons based on selections
local function updateSelectionButtons()
  AutoLFM.UI.MainFrame.UpdateClearAllButton()
  AutoLFM.UI.MainFrame.UpdateAddPresetButton()
end

--=============================================================================
-- TAB VISUAL UPDATES
--=============================================================================

--- Updates the visual appearance of a single bottom tab
--- @param tabIndex number - The tab index to update (1-4)
--- @param isActive boolean - True if this tab is currently active
local function updateBottomTab(tabIndex, isActive)
  local tab = getglobal("AutoLFM_MainFrame_Tab" .. tabIndex)
  if not tab then return end

  local bg = tab:GetRegions()
  local highlight = getglobal(tab:GetName() .. "_Highlight")
  local text = getglobal(tab:GetName() .. "_Text")

  if isActive then
  if bg then
    bg:SetTexture("Interface\\AddOns\\AutoLFM\\UI\\Textures\\Tabs\\BottomTabActive")
  end
  AutoLFM.Core.Utils.SetTextColorByName(text, "WHITE")
  else
  if bg then
    bg:SetTexture("Interface\\AddOns\\AutoLFM\\UI\\Textures\\Tabs\\BottomTabInactive")
  end
  AutoLFM.Core.Utils.SetTextColorByName(text, "GOLD")
  end

  if highlight then
  highlight:Hide()
  end
end

--- Updates visual appearance of all tabs based on current selection
--- @param currentBottomTab number - The currently active bottom tab index (1-4)
--- @param currentSideTab number|nil - The currently active side tab index (2, 4, or 5), or nil if none
function AutoLFM.UI.MainFrame.UpdateTabVisuals(currentBottomTab, currentSideTab)
  -- Update bottom tabs
  for i = 1, 4 do
  updateBottomTab(i, i == currentBottomTab and not currentSideTab)
  end

  -- Update side tabs
  for _, tabIndex in ipairs({2, 4, 5}) do
  local tab = getglobal("AutoLFM_MainFrame_SideTab" .. tabIndex)
  if tab and tab.SetChecked then
    tab:SetChecked(currentSideTab == tabIndex and 1 or nil)
  end
  end
end

--=============================================================================
-- INITIALIZATION
--=============================================================================

AutoLFM.Core.SafeRegisterInit("UI.MainFrame", function()
  -- Subscribe to state changes that affect the main button
  AutoLFM.Core.Maestro.SubscribeState("Broadcaster.IsRunning", function(newValue, oldValue)
    AutoLFM.UI.MainFrame.UpdateMainButton()
  end)

  AutoLFM.Core.Maestro.SubscribeState("Message.ToBroadcast", function(newValue, oldValue)
    AutoLFM.UI.MainFrame.UpdateMainButton()
    AutoLFM.UI.MainFrame.UpdateMessagePreview(newValue)
  end)

  AutoLFM.Core.Maestro.SubscribeState("Channels.ActiveChannels", function(newValue, oldValue)
    AutoLFM.UI.MainFrame.UpdateMainButton()
  end)

  AutoLFM.Core.Maestro.SubscribeState("Settings.DryRun", function(newValue, oldValue)
    AutoLFM.UI.MainFrame.UpdateMainButton()
  end)

  -- Subscribe to state changes that affect the Clear All and Add Preset buttons
  AutoLFM.Core.Maestro.SubscribeState("Selection.DungeonNames", updateSelectionButtons)
  AutoLFM.Core.Maestro.SubscribeState("Selection.RaidName", updateSelectionButtons)
  AutoLFM.Core.Maestro.SubscribeState("Selection.Roles", function(newValue, oldValue)
    updateSelectionButtons()
    AutoLFM.UI.MainFrame.UpdateRoleCheckboxes()
  end)
  AutoLFM.Core.Maestro.SubscribeState("Selection.CustomMessage", updateSelectionButtons)
  AutoLFM.Core.Maestro.SubscribeState("Selection.DetailsText", updateSelectionButtons)
  AutoLFM.Core.Maestro.SubscribeState("Selection.CustomGroupSize", updateSelectionButtons)
end, {
  id = "I21",
  dependencies = { "Logic.Broadcaster", "Logic.Message", "Logic.Selection" }
})
