--=============================================================================
-- AutoLFM: AutoInvite UI
--   Visual handlers for the AutoInvite panel
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.UI = AutoLFM.UI or {}
AutoLFM.UI.Content = AutoLFM.UI.Content or {}
AutoLFM.UI.Content.AutoInvite = {}

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local panel = nil
local isRestoringState = false  -- Flag to prevent OnClick during restoration
local MAX_KEYWORDS = 4  -- Maximum keyword slots in UI

-----------------------------------------------------------------------------
-- Helper: Apply Colors to Leader Status Radio Buttons
-----------------------------------------------------------------------------
--- Colors the "Group leader" radio button green and "No leadership" radio button red
local function ApplyLeaderColors()
  if not panel then return end
  
  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if not scrollChild then return end
  
  -- Color "Group leader" radio button green
  local leaderRadio = getglobal(scrollChild:GetName().."_LeaderYesRadio")
  if leaderRadio then
    leaderRadio:SetCheckedTexture("Interface\\Buttons\\UI-RadioButton-Highlight")
    local texture = leaderRadio:GetCheckedTexture()
    if texture then
      texture:SetVertexColor(0, 1, 0)  -- Green
    end
    leaderRadio:SetHighlightTexture("Interface\\Buttons\\UI-RadioButton-Highlight")
    local highlight = leaderRadio:GetHighlightTexture()
    if highlight then
      highlight:SetVertexColor(0, 1, 0)  -- Green
    end
  end
  
  -- Color "No leadership" radio button red
  local noLeaderRadio = getglobal(scrollChild:GetName().."_LeaderNoRadio")
  if noLeaderRadio then
    noLeaderRadio:SetCheckedTexture("Interface\\Buttons\\UI-RadioButton-Highlight")
    local texture = noLeaderRadio:GetCheckedTexture()
    if texture then
      texture:SetVertexColor(1, 0, 0)  -- Red
    end
    noLeaderRadio:SetHighlightTexture("Interface\\Buttons\\UI-RadioButton-Highlight")
    local highlight = noLeaderRadio:GetHighlightTexture()
    if highlight then
      highlight:SetVertexColor(1, 0, 0)  -- Red
    end
  end
end

-----------------------------------------------------------------------------
-- OnLoad: Initialize the panel
-----------------------------------------------------------------------------
--- XML OnLoad callback - initializes the AutoInvite panel UI
--- @param frame frame - The AutoInvite panel frame
function AutoLFM.UI.Content.AutoInvite.OnLoad(frame)
  panel = frame
  -- Apply colors to leader status labels
  ApplyLeaderColors()
  -- Setup keyword EditBox handlers
  AutoLFM.UI.Content.AutoInvite.SetupKeywordEditBoxes()
end

-----------------------------------------------------------------------------
-- OnShow: Refresh the panel when shown
-----------------------------------------------------------------------------
--- XML OnShow callback - restores saved option states when panel is shown
--- @param frame frame - The AutoInvite panel frame
function AutoLFM.UI.Content.AutoInvite.OnShow(frame)
  AutoLFM.UI.Content.AutoInvite.RefreshPanel()
end

-----------------------------------------------------------------------------
-- EditBox Handlers
-----------------------------------------------------------------------------
--- Called when keyword text changes
function AutoLFM.UI.Content.AutoInvite.OnKeywordTextChanged(keywordIndex, text)
  -- This is called by the EditBox onTextChanged
  -- Add any real-time validation or filtering here if needed
end

--- Called when keyword EditBox loses focus or Escape is pressed
function AutoLFM.UI.Content.AutoInvite.OnKeywordEscapePressed()
  -- This is called when user presses Escape or loses focus
  -- Add any save/validation logic here
end

--- Setup EditBox handlers in Lua to connect XML-free EditBoxes to functions
function AutoLFM.UI.Content.AutoInvite.SetupKeywordEditBoxes()
  if not panel then return end
  
  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if not scrollChild then return end
  
  for i = 1, 3 do
    local kw = getglobal(scrollChild:GetName().."_Keyword"..i.."_Input")
    if kw then
      local index = i
      
      -- Apply gold border and dark background
      if kw.SetBackdropBorderColor then
        kw:SetBackdropBorderColor(1, 0.82, 0, 1)
      end
      if kw.SetBackdropColor then
        kw:SetBackdropColor(0, 0, 0, 0.8)
      end
      
      kw:SetScript("OnTextChanged", function()
        AutoLFM.UI.Content.AutoInvite.OnKeywordTextChanged(index, kw:GetText())
      end)
      
      kw:SetScript("OnEscapePressed", function()
        kw:ClearFocus()
        AutoLFM.UI.Content.AutoInvite.OnKeywordEscapePressed()
      end)
      
      kw:SetScript("OnEditFocusGained", function()
        kw:HighlightText()
      end)
      
      kw:SetScript("OnMouseDown", function()
        kw:SetFocus()
        kw:HighlightText()
      end)
      
      kw:SetScript("OnEnterPressed", function()
        kw:ClearFocus()
      end)
    end
  end
end

-----------------------------------------------------------------------------
-- Helper: Update Leader Status Display
-----------------------------------------------------------------------------
--- Updates the leader status radio buttons based on current group status
local function UpdateLeaderStatus()
  if not panel then return end
  
  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if not scrollChild then return end
  
  local isLeader = UnitIsPartyLeader("player")
  if not UnitInParty("player") then
    isLeader = true  -- Solo player acts like leader
  end
  
  local yesRadio = getglobal(scrollChild:GetName().."_LeaderYesRadio")
  local noRadio = getglobal(scrollChild:GetName().."_LeaderNoRadio")
  
  if yesRadio and noRadio then
    if isLeader then
      yesRadio:SetChecked(1)
      noRadio:SetChecked(nil)
    else
      yesRadio:SetChecked(nil)
      noRadio:SetChecked(1)
    end
  end
end

-----------------------------------------------------------------------------
-- Event Handlers - Enable Radio Buttons
-----------------------------------------------------------------------------
--- Handles AutoInvite enable/disable radio button clicks (On/Off)
--- @param isEnabled boolean - True to enable AutoInvite, false to disable
function AutoLFM.UI.Content.AutoInvite.OnEnableRadioClick(isEnabled)
  if isRestoringState then return end

  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if not scrollChild then return end

  local onRadio = getglobal(scrollChild:GetName().."_StatusContainer_OnRadio")
  local offRadio = getglobal(scrollChild:GetName().."_StatusContainer_OffRadio")

  if onRadio and offRadio then
    if isEnabled then
      onRadio:SetChecked(1)
      offRadio:SetChecked(nil)
    else
      onRadio:SetChecked(nil)
      offRadio:SetChecked(1)
    end
  end

  -- Save to persistent storage
  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.SetAutoInviteEnabled then
    AutoLFM.Core.Storage.SetAutoInviteEnabled(isEnabled)
    AutoLFM.Core.Utils.LogInfo("AutoInvite " .. (isEnabled and "enabled" or "disabled"))
  end
end

--- Handles confirmation message radio button clicks (On/Off)
--- @param isEnabled boolean - True to enable confirmation messages, false to disable
function AutoLFM.UI.Content.AutoInvite.OnConfirmRadioClick(isEnabled)
  if isRestoringState then return end

  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if not scrollChild then return end

  local onRadio = getglobal(scrollChild:GetName().."_ConfirmContainer_OnRadio")
  local offRadio = getglobal(scrollChild:GetName().."_ConfirmContainer_OffRadio")

  if onRadio and offRadio then
    if isEnabled then
      onRadio:SetChecked(1)
      offRadio:SetChecked(nil)
    else
      onRadio:SetChecked(nil)
      offRadio:SetChecked(1)
    end
  end

  -- Save to persistent storage
  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.SetAutoInviteConfirm then
    AutoLFM.Core.Storage.SetAutoInviteConfirm(isEnabled)
    AutoLFM.Core.Utils.LogInfo("Confirmation messages " .. (isEnabled and "enabled" or "disabled"))
  end
end

--- Handles random messages radio button clicks (On/Off)
--- Toggles use of random invite messages vs simple confirmation
--- @param isEnabled boolean - True to use random messages, false for simple "Invitation sent"
function AutoLFM.UI.Content.AutoInvite.OnRandomMessagesRadioClick(isEnabled)
  if isRestoringState then return end

  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if not scrollChild then return end

  local onRadio = getglobal(scrollChild:GetName().."_RandomMessagesContainer_OnRadio")
  local offRadio = getglobal(scrollChild:GetName().."_RandomMessagesContainer_OffRadio")

  if onRadio and offRadio then
    if isEnabled then
      onRadio:SetChecked(1)
      offRadio:SetChecked(nil)
    else
      onRadio:SetChecked(nil)
      offRadio:SetChecked(1)
    end
  end

  -- Save to persistent storage
  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.SetAutoInviteRandomMessages then
    AutoLFM.Core.Storage.SetAutoInviteRandomMessages(isEnabled)
    AutoLFM.Core.Utils.LogInfo("Random messages " .. (isEnabled and "enabled" or "disabled"))
  end
end

--- Handles respond when not leader radio button clicks (On/Off)
--- Toggles whether to respond to whispers when player is not group leader
--- @param isEnabled boolean - True to respond when not leader, false to stay silent
function AutoLFM.UI.Content.AutoInvite.OnRespondNotLeaderRadioClick(isEnabled)
  if isRestoringState then return end

  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if not scrollChild then return end

  local onRadio = getglobal(scrollChild:GetName().."_RespondNotLeaderContainer_OnRadio")
  local offRadio = getglobal(scrollChild:GetName().."_RespondNotLeaderContainer_OffRadio")

  if onRadio and offRadio then
    if isEnabled then
      onRadio:SetChecked(1)
      offRadio:SetChecked(nil)
    else
      onRadio:SetChecked(nil)
      offRadio:SetChecked(1)
    end
  end

  -- Save to persistent storage
  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.SetAutoInviteRespondWhenNotLeader then
    AutoLFM.Core.Storage.SetAutoInviteRespondWhenNotLeader(isEnabled)
    AutoLFM.Core.Utils.LogInfo("Respond when not leader " .. (isEnabled and "enabled" or "disabled"))
  end
end

-----------------------------------------------------------------------------
-- Event Handlers - Keyword Management
-----------------------------------------------------------------------------
--- Handles keyword editbox escape key
--- Properly clears focus from the editbox
function AutoLFM.UI.Content.AutoInvite.OnKeywordEscapePressed()
  -- Simply do nothing - WoW will handle the focus blur naturally
end

--- Handles keyword text input changes
--- Updates keyword at specified index in persistent storage
--- @param index number - Keyword index (1-4)
--- @param text string - New keyword text
function AutoLFM.UI.Content.AutoInvite.OnKeywordTextChanged(index, text)
  if isRestoringState then return end

  -- Get current keywords from persistent storage
  local keywords = AutoLFM.Core.Storage.GetAutoInviteKeywords() or {}
  
  -- Ensure table is large enough
  while table.getn(keywords) < index do
    table.insert(keywords, "")
  end
  
  -- Update the keyword at this index
  keywords[index] = text
  
  -- Remove trailing empty keywords
  while table.getn(keywords) > 0 and keywords[table.getn(keywords)] == "" do
    table.remove(keywords)
  end
  
  -- Save updated keywords
  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.SetAutoInviteKeywords then
    AutoLFM.Core.Storage.SetAutoInviteKeywords(keywords)
  end
end

--- Handles remove keyword button click
--- Removes keyword at specified index and refreshes UI
--- @param index number - Keyword index to remove (1-4)
function AutoLFM.UI.Content.AutoInvite.OnRemoveKeywordClick(index)
  if isRestoringState then return end

  -- Get current keywords from persistent storage
  local keywords = AutoLFM.Core.Storage.GetAutoInviteKeywords() or {}
  
  -- Remove keyword at index
  if index <= table.getn(keywords) then
    table.remove(keywords, index)
  end
  
  -- Save updated keywords
  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.SetAutoInviteKeywords then
    AutoLFM.Core.Storage.SetAutoInviteKeywords(keywords)
  end
  
  -- Refresh UI to reflect changes
  AutoLFM.UI.Content.AutoInvite.RefreshPanel()
end

--- Handles add keyword button click
--- Adds empty keyword entry and refreshes UI
function AutoLFM.UI.Content.AutoInvite.OnAddKeywordClick()
  if isRestoringState then return end

  -- Get current keywords from persistent storage
  local keywords = AutoLFM.Core.Storage.GetAutoInviteKeywords() or {}
  
  -- Don't add if we've reached max keywords
  if table.getn(keywords) >= MAX_KEYWORDS then
    AutoLFM.Core.Utils.LogWarn("Maximum keywords (" .. MAX_KEYWORDS .. ") reached")
    return
  end
  
  -- Add empty keyword
  table.insert(keywords, "")
  
  -- Save updated keywords
  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.SetAutoInviteKeywords then
    AutoLFM.Core.Storage.SetAutoInviteKeywords(keywords)
  end
  
  -- Refresh UI to show new field
  AutoLFM.UI.Content.AutoInvite.RefreshPanel()
end

--- Handles clear keyword button click (✕ on first line)
--- Clears the first keyword entry
function AutoLFM.UI.Content.AutoInvite.OnClearKeywordClick(index)
  if isRestoringState then return end

  -- Get current keywords from persistent storage
  local keywords = AutoLFM.Core.Storage.GetAutoInviteKeywords() or {}
  
  -- Clear the keyword at this index
  if index <= table.getn(keywords) then
    keywords[index] = ""
  end
  
  -- Remove trailing empty keywords
  while table.getn(keywords) > 0 and keywords[table.getn(keywords)] == "" do
    table.remove(keywords)
  end
  
  -- Save updated keywords
  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.SetAutoInviteKeywords then
    AutoLFM.Core.Storage.SetAutoInviteKeywords(keywords)
  end
  
  -- Refresh UI
  AutoLFM.UI.Content.AutoInvite.RefreshPanel()
end

--- Handles add keyword line button click (+ button)
--- Shows the next keyword input line and hides the current add button
function AutoLFM.UI.Content.AutoInvite.OnAddKeywordLineClick()
  if isRestoringState then return end

  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if not scrollChild then return end

  -- Get current keywords from persistent storage
  local keywords = AutoLFM.Core.Storage.GetAutoInviteKeywords() or {}
  local numKeywords = table.getn(keywords)
  
  -- Add an empty keyword to make room for the next line
  if numKeywords < 3 then
    table.insert(keywords, "")
    
    -- Save updated keywords
    if AutoLFM.Core.Storage and AutoLFM.Core.Storage.SetAutoInviteKeywords then
      AutoLFM.Core.Storage.SetAutoInviteKeywords(keywords)
    end
    
    -- Refresh UI to show next line
    AutoLFM.UI.Content.AutoInvite.RefreshPanel()
  end
end

--- Handles delete keyword line button click (✕ on additional lines)
--- Hides the keyword input line and shows the appropriate add button
--- If a middle line is deleted, lines below move up
function AutoLFM.UI.Content.AutoInvite.OnDeleteKeywordLineClick(index)
  if isRestoringState then return end

  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if not scrollChild then return end

  -- Get current keywords from persistent storage
  local keywords = AutoLFM.Core.Storage.GetAutoInviteKeywords() or {}
  
  -- Remove keyword at index
  if index <= table.getn(keywords) then
    table.remove(keywords, index)
  end
  
  -- Save updated keywords
  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.SetAutoInviteKeywords then
    AutoLFM.Core.Storage.SetAutoInviteKeywords(keywords)
  end
  
  -- Refresh UI to reflect changes (keywords will move up)
  AutoLFM.UI.Content.AutoInvite.RefreshPanel()
end

-----------------------------------------------------------------------------
-- Public API - Refresh Panel
-----------------------------------------------------------------------------
--- Refreshes all UI elements from persistent storage
--- Called when panel is shown or after keyword changes
function AutoLFM.UI.Content.AutoInvite.RefreshPanel()
  if not panel then return end

  isRestoringState = true

  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if scrollChild then
    -- Get current state from persistent storage
    local isEnabled = AutoLFM.Core.Storage.GetAutoInviteEnabled()
    local isConfirmEnabled = AutoLFM.Core.Storage.GetAutoInviteConfirm()
    local useRandomMessages = AutoLFM.Core.Storage.GetAutoInviteRandomMessages()
    local respondWhenNotLeader = AutoLFM.Core.Storage.GetAutoInviteRespondWhenNotLeader()
    local keywords = AutoLFM.Core.Storage.GetAutoInviteKeywords() or {}

    -- Update enable radio buttons
    local enableOnRadio = getglobal(scrollChild:GetName().."_StatusContainer_OnRadio")
    local enableOffRadio = getglobal(scrollChild:GetName().."_StatusContainer_OffRadio")
    if enableOnRadio and enableOffRadio then
      if isEnabled then
        enableOnRadio:SetChecked(1)
        enableOffRadio:SetChecked(nil)
      else
        enableOnRadio:SetChecked(nil)
        enableOffRadio:SetChecked(1)
      end
    end

    -- Update leader status (read-only)
    UpdateLeaderStatus()

    -- Update confirmation radio buttons
    local confirmOnRadio = getglobal(scrollChild:GetName().."_ConfirmContainer_OnRadio")
    local confirmOffRadio = getglobal(scrollChild:GetName().."_ConfirmContainer_OffRadio")
    if confirmOnRadio and confirmOffRadio then
      if isConfirmEnabled then
        confirmOnRadio:SetChecked(1)
        confirmOffRadio:SetChecked(nil)
      else
        confirmOnRadio:SetChecked(nil)
        confirmOffRadio:SetChecked(1)
      end
    end

    -- Update random messages radio buttons
    local randomOnRadio = getglobal(scrollChild:GetName().."_RandomMessagesContainer_OnRadio")
    local randomOffRadio = getglobal(scrollChild:GetName().."_RandomMessagesContainer_OffRadio")
    if randomOnRadio and randomOffRadio then
      if useRandomMessages then
        randomOnRadio:SetChecked(1)
        randomOffRadio:SetChecked(nil)
      else
        randomOnRadio:SetChecked(nil)
        randomOffRadio:SetChecked(1)
      end
    end

    -- Update respond when not leader radio buttons
    local respondOnRadio = getglobal(scrollChild:GetName().."_RespondNotLeaderContainer_OnRadio")
    local respondOffRadio = getglobal(scrollChild:GetName().."_RespondNotLeaderContainer_OffRadio")
    if respondOnRadio and respondOffRadio then
      if respondWhenNotLeader then
        respondOnRadio:SetChecked(1)
        respondOffRadio:SetChecked(nil)
      else
        respondOnRadio:SetChecked(nil)
        respondOffRadio:SetChecked(1)
      end
    end

    -- Update keyword inputs, delete buttons, and add buttons
    -- Based on number of keywords stored, show/hide the appropriate lines
    local numKeywords = table.getn(keywords)
    
    -- Keyword 1 - ALWAYS visible
    local kw1Input = getglobal(scrollChild:GetName().."_Keyword1_Input")
    local kw1Clear = getglobal(scrollChild:GetName().."_Keyword1_Clear")
    local addBtn = getglobal(scrollChild:GetName().."_AddKeywordButton")
    
    if kw1Input then
      if numKeywords >= 1 then
        kw1Input:SetText(keywords[1])
      else
        kw1Input:SetText("")
      end
      kw1Input:Show()
      if kw1Clear then kw1Clear:Show() end
    end
    
    -- Keyword 2 - shown if we have 2 or more keywords
    local kw2Input = getglobal(scrollChild:GetName().."_Keyword2_Input")
    local kw2Delete = getglobal(scrollChild:GetName().."_Keyword2_Delete")
    local addBtn2 = getglobal(scrollChild:GetName().."_AddKeywordButton2")
    
    if kw2Input then
      if numKeywords >= 2 then
        kw2Input:SetText(keywords[2])
        kw2Input:Show()
        if kw2Delete then kw2Delete:Show() end
        if addBtn2 then addBtn2:Show() end
      else
        kw2Input:SetText("")
        kw2Input:Hide()
        if kw2Delete then kw2Delete:Hide() end
        if addBtn2 then addBtn2:Hide() end
      end
    end
    
    -- Keyword 3 - shown if we have 3 or more keywords
    local kw3Input = getglobal(scrollChild:GetName().."_Keyword3_Input")
    local kw3Delete = getglobal(scrollChild:GetName().."_Keyword3_Delete")
    
    if kw3Input then
      if numKeywords >= 3 then
        kw3Input:SetText(keywords[3])
        kw3Input:Show()
        if kw3Delete then kw3Delete:Show() end
        if addBtn2 then addBtn2:Hide() end
      else
        kw3Input:SetText("")
        kw3Input:Hide()
        if kw3Delete then kw3Delete:Hide() end
      end
    end
    
    -- Add button visibility:
    -- - Shows on Keyword1 line if numKeywords == 0 or numKeywords == 1
    -- - Shows on Keyword2 line if numKeywords == 2
    if addBtn then
      if numKeywords == 0 or numKeywords == 1 then
        addBtn:Show()
      else
        addBtn:Hide()
      end
    end
    
    if addBtn2 then
      if numKeywords == 2 then
        addBtn2:Show()
      else
        addBtn2:Hide()
      end
    end
  end

  isRestoringState = false
end
