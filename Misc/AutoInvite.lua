--=============================================================================
-- AutoLFM: Auto Invite
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Misc then AutoLFM.Misc = {} end
if not AutoLFM.Misc.AutoInvite then AutoLFM.Misc.AutoInvite = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local isEnabled = false
local keyword = "+1"
local sendConfirmation = true
local eventFrame = nil

-----------------------------------------------------------------------------
-- Fun Paladin-style invitation messages
-----------------------------------------------------------------------------
local inviteMessages = {
  "⚔️ %s, the Light demands your presence! Don’t make an old paladin wait!",
  "🛡️ %s, by the Light! Get over here before my beard turns greyer!",
  "✨ %s, the Light calls—and so does your raid leader. Move it!",
  "⚔️ %s, the crusade awaits! Don’t make me smite you for being late!",
  "🔥 %s, blessed hammer in hand, it’s time to join the fight!"
}

local function GetRandomInviteMessage(target)
  local index = math.random(1, table.getn(inviteMessages))
  return string.format(inviteMessages[index], target)
end

-----------------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------------
local function IsPlayerLeaderOrSolo()
  if not UnitInParty("player") then
    return true
  end
  return UnitIsPartyLeader("player")
end

local function Trim(text)
  if not text then return "" end
  return string.gsub(text, "^%s*(.-)%s*$", "%1")
end

-----------------------------------------------------------------------------
-- Invite Logic
-----------------------------------------------------------------------------
local function HandleWhisper(message, sender)
  if not isEnabled then return end
  if not message or not sender then return end
  
  local trimmed = Trim(message)
  local lowerMsg = string.lower(trimmed)
  local lowerKey = string.lower(keyword)
  
  -- Vérifie si le mot-clé apparaît n'importe où dans le message
  if not string.find(lowerMsg, lowerKey, 1, true) then
    return
  end
  
  local playerName = UnitName("player")
  if sender == playerName then return end
  
  if IsPlayerLeaderOrSolo() then
    InviteByName(sender)
    
    if sendConfirmation then
      SendChatMessage(GetRandomInviteMessage(sender), "WHISPER", nil, sender)
    end
  else
    if sendConfirmation then
      SendChatMessage("Cannot invite: I'm not the group leader.", "WHISPER", nil, sender)
    end
  end
end

-----------------------------------------------------------------------------
-- Event Setup
-----------------------------------------------------------------------------
local function Setup()
  if not eventFrame then
    eventFrame = CreateFrame("Frame", "AutoLFM_AutoInviteFrame")
  end
  
  eventFrame:RegisterEvent("CHAT_MSG_WHISPER")
  
  eventFrame:SetScript("OnEvent", function()
    if event == "CHAT_MSG_WHISPER" then
      HandleWhisper(arg1, arg2)
    end
  end)
  
  isEnabled = true
end

local function Teardown()
  if eventFrame then
    eventFrame:UnregisterEvent("CHAT_MSG_WHISPER")
    eventFrame:SetScript("OnEvent", nil)
  end
  
  isEnabled = false
end

-----------------------------------------------------------------------------
-- Public API
-----------------------------------------------------------------------------
function AutoLFM.Misc.AutoInvite.Enable()
  if not isEnabled then
    Setup()
  end
  
  AutoLFM.Core.Settings.SaveMiscModule("autoInvite", true)
  AutoLFM.Core.Utils.PrintSuccess("Auto Invite enabled (keyword: " .. keyword .. ")")
end

function AutoLFM.Misc.AutoInvite.Disable()
  Teardown()
  
  AutoLFM.Core.Settings.SaveMiscModule("autoInvite", false)
  AutoLFM.Core.Utils.PrintWarning("Auto Invite disabled")
end

function AutoLFM.Misc.AutoInvite.IsEnabled()
  return isEnabled
end

function AutoLFM.Misc.AutoInvite.SetKeyword(newKeyword)
  if not newKeyword or newKeyword == "" then
    AutoLFM.Core.Utils.PrintError("Keyword cannot be empty")
    return false
  end
  
  keyword = Trim(newKeyword)
  AutoLFM.Core.Settings.SaveMiscModuleData("autoInvite", "keyword", keyword)
  AutoLFM.Core.Utils.PrintSuccess("Keyword changed to: " .. keyword)
  return true
end

function AutoLFM.Misc.AutoInvite.GetKeyword()
  return keyword
end

function AutoLFM.Misc.AutoInvite.ToggleConfirm()
  sendConfirmation = not sendConfirmation
  AutoLFM.Core.Settings.SaveMiscModuleData("autoInvite", "confirmation", sendConfirmation)
  
  local status = sendConfirmation and AutoLFM.Color("enabled", "green") or AutoLFM.Color("disabled", "red")
  AutoLFM.Core.Utils.PrintInfo("Confirmation whisper " .. status)
  
  return sendConfirmation
end

function AutoLFM.Misc.AutoInvite.GetConfirmation()
  return sendConfirmation
end

function AutoLFM.Misc.AutoInvite.ShowStatus()
  local state = isEnabled and AutoLFM.Color("ON", "green") or AutoLFM.Color("OFF", "red")
  local confirmState = sendConfirmation and AutoLFM.Color("enabled", "green") or AutoLFM.Color("disabled", "red")
  
  AutoLFM.Core.Utils.PrintInfo("Auto Invite Status:")
  AutoLFM.Core.Utils.Print("  State: " .. state)
  AutoLFM.Core.Utils.Print("  Keyword: " .. AutoLFM.Color(keyword, "yellow"))
  AutoLFM.Core.Utils.Print("  Confirmation: " .. confirmState)
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function AutoLFM.Misc.AutoInvite.Init()
  local enabled = AutoLFM.Core.Settings.LoadMiscModule("autoInvite")
  local savedKeyword = AutoLFM.Core.Settings.LoadMiscModuleData("autoInvite", "keyword")
  local savedConfirm = AutoLFM.Core.Settings.LoadMiscModuleData("autoInvite", "confirmation")
  
  if savedKeyword then
    keyword = savedKeyword
  end
  
  if savedConfirm ~= nil then
    sendConfirmation = savedConfirm
  end
  
  if enabled then
    Setup()
  end
end

-----------------------------------------------------------------------------
-- Legacy Slash Command (/ainv)
-----------------------------------------------------------------------------
SLASH_AUTOINV1 = "/ainv"
SlashCmdList["AUTOINV"] = function(msg)
  local cmd, rest = string.match(msg or "", "^(%S*)%s*(.-)$")
  cmd = cmd and string.lower(cmd) or ""
  
  if cmd == "on" then
    AutoLFM.Misc.AutoInvite.Enable()
  elseif cmd == "off" then
    AutoLFM.Misc.AutoInvite.Disable()
  elseif cmd == "toggle" then
    if AutoLFM.Misc.AutoInvite.IsEnabled() then
      AutoLFM.Misc.AutoInvite.Disable()
    else
      AutoLFM.Misc.AutoInvite.Enable()
    end
  elseif cmd == "status" or cmd == "" then
    AutoLFM.Core.Utils.PrintInfo("Legacy command /ainv - Use /lfm misc invite instead")
    AutoLFM.Misc.AutoInvite.ShowStatus()
  elseif cmd == "setkey" then
    local newkey = Trim(rest)
    if newkey == "" then
      AutoLFM.Core.Utils.PrintError("Usage: /ainv setkey <word>")
    else
      AutoLFM.Misc.AutoInvite.SetKeyword(newkey)
    end
  elseif cmd == "confirm" then
    AutoLFM.Misc.AutoInvite.ToggleConfirm()
  else
    AutoLFM.Core.Utils.PrintInfo("Legacy command /ainv - Use /lfm misc invite instead")
    AutoLFM.Core.Utils.PrintNote("Commands: on | off | toggle | status | setkey <word> | confirm")
  end
end
