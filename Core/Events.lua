--=============================================================================
-- AutoLFM: Event Handlers
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Core then AutoLFM.Core = {} end
if not AutoLFM.Core.Events then AutoLFM.Core.Events = {} end

-----------------------------------------------------------------------------
-- Group Roster Change
-----------------------------------------------------------------------------
local function OnGroupRosterChange()
  local mode = AutoLFM.Logic.Selection.GetMode()
  local currentCount = AutoLFM.Logic.Selection.GetGroupCount()
  
  if mode == "raid" then
    local raidSize = AutoLFM.Logic.Content.GetRaidSize()
    
    if currentCount >= raidSize then
      local result = AutoLFM.Logic.Broadcaster.HandleGroupFull("raid")
      
      if result and result.needsUIUpdate then
        local button = AutoLFM.UI.MainWindow.GetBroadcastToggleButton()
        if button then
          button:SetText("Start")
        end
      end
      
      if result and result.playStopSound then
        pcall(PlaySoundFile, AutoLFM.UI.MainWindow.SOUND_STOP)
      end
    else
      AutoLFM.Logic.Broadcaster.UpdateMessage()
    end
  elseif mode == "dungeon" then
    if currentCount >= AutoLFM.Core.Utils.CONSTANTS.GROUP_SIZE_DUNGEON then
      local result = AutoLFM.Logic.Broadcaster.HandleGroupFull("dungeon")
      
      if result and result.needsUIUpdate then
        local button = AutoLFM.UI.MainWindow.GetBroadcastToggleButton()
        if button then
          button:SetText("Start")
        end
      end
      
      if result and result.playStopSound then
        pcall(PlaySoundFile, AutoLFM.UI.MainWindow.SOUND_STOP)
      end
    else
      AutoLFM.Logic.Broadcaster.UpdateMessage()
    end
  else
    AutoLFM.Logic.Broadcaster.UpdateMessage()
  end
end

-----------------------------------------------------------------------------
-- Player Login
-----------------------------------------------------------------------------
local function OnPlayerLogin()
  local dungeonContent = AutoLFM.UI.DungeonsPanel.GetContentFrame()
  if AutoLFM.UI.DungeonsPanel.Display and dungeonContent then
    AutoLFM.UI.DungeonsPanel.Display(dungeonContent)
    
    local dungeonScroll = AutoLFM.UI.DungeonsPanel.GetScrollFrame()
    if dungeonScroll and dungeonScroll.UpdateScrollChildRect then
      dungeonScroll:UpdateScrollChildRect()
    end
  end
  
  local raidContent = AutoLFM.UI.RaidsPanel.GetContentFrame()
  if AutoLFM.UI.RaidsPanel.Display and raidContent then
    AutoLFM.UI.RaidsPanel.Display(raidContent)
    
    local raidScroll = AutoLFM.UI.RaidsPanel.GetScrollFrame()
    if raidScroll and raidScroll.UpdateScrollChildRect then
      raidScroll:UpdateScrollChildRect()
    end
  end
  
  AutoLFM.UI.DungeonsPanel.UpdateFilterUI()
end

-----------------------------------------------------------------------------
-- Setup Event Handlers
-----------------------------------------------------------------------------
function AutoLFM.Core.Events.Setup()
  if not AutoLFM_MainFrame then return end
  
  AutoLFM_MainFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
  AutoLFM_MainFrame:RegisterEvent("RAID_ROSTER_UPDATE")
  AutoLFM_MainFrame:RegisterEvent("PLAYER_LOGIN")
  
  AutoLFM_MainFrame:SetScript("OnEvent", function()
    local success, err = pcall(function()
      if event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
        OnGroupRosterChange()
      elseif event == "PLAYER_LOGIN" then
        OnPlayerLogin()
      end
    end)
    
    if not success then
      AutoLFM.Core.Utils.PrintError("Event handler error: " .. tostring(err))
    end
  end)
end
