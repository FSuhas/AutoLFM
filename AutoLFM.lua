--------------------------------------------------
-- Log Message
--------------------------------------------------
local msglog = CreateFrame("Frame")
msglog:RegisterEvent("PLAYER_ENTERING_WORLD")

local initSteps = {
  step1 = false,
  step2 = false,
  step3 = false
}

local function TryInitStep1()
  if initSteps.step1 then return true end
  
  if LoadSelectedChannels then
    LoadSelectedChannels()
    initSteps.step1 = true
    return true
  end
  return false
end

local function TryInitStep2()
  if initSteps.step2 then return true end
  if not initSteps.step1 then return false end
  
  if InitMinimapButton then
    InitMinimapButton()
    initSteps.step2 = true
    return true
  end
  return false
end

local function TryInitStep3()
  if initSteps.step3 then return true end
  if not initSteps.step2 then return false end
  
  if AutoLFM then
    AutoLFM:Hide()
  end
  
  initSteps.step3 = true
  return true
end

local function OnPlayerEnteringWorld()
  local seg2 = "|cffffffff <"
  local seg3 = "|cffffff00 Auto "
  local seg4 = "|cff0070DDL"
  local seg5 = "|cffffffffF"
  local seg6 = "|cffff0000M "
  local seg7 = "|cffffffff>"
  local seg8 = " "
  local seg9 = "|cff00FF00 Loaded successfully !"
  local seg10 = "|cffffff00   More information with  : "
  local seg11 = "|cff00FFFF  /lfm help"
  
  DEFAULT_CHAT_FRAME:AddMessage(seg2 .. seg3 .. seg4 .. seg5 .. seg6 .. seg7 .. seg8 .. seg9)
  DEFAULT_CHAT_FRAME:AddMessage(seg10 .. seg11)
  
  TryInitStep1()
  TryInitStep2()
  TryInitStep3()
  
  msglog:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

msglog:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" then
    OnPlayerEnteringWorld()
  end
end)

--------------------------------------------------
-- Slash Commands
--------------------------------------------------
local bigMessageFrame, bigMessageText

local function ShowBigMessage(text, duration)
  if not bigMessageFrame then
    bigMessageFrame = CreateFrame("Frame", "BigMessageFrame", UIParent)
    bigMessageFrame:SetWidth(600)
    bigMessageFrame:SetHeight(100)
    bigMessageFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    
    bigMessageText = bigMessageFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bigMessageText:SetFont("Fonts\\FRIZQT__.TTF", 36, "OUTLINE")
    bigMessageText:SetPoint("CENTER", bigMessageFrame, "CENTER", 0, 0)
    bigMessageText:SetTextColor(1, 0, 0, 1)
  end
  
  bigMessageFrame:Show()
  
  local fullText = text
  local displayedText = ""
  local index = 0
  local timePerChar = 0.05
  local lastUpdate = GetTime()
  local totalTime = duration or 3
  
  bigMessageText:SetText("")
  
  bigMessageFrame:SetScript("OnUpdate", function()
    local now = GetTime()
    if now - lastUpdate >= timePerChar then
      lastUpdate = now
      index = index + 1
      displayedText = string.sub(fullText, 1, index)
      bigMessageText:SetText(displayedText)
    end
    
    if index >= string.len(fullText) then
      totalTime = totalTime - (now - lastUpdate)
      if totalTime <= 0 then
        bigMessageFrame:Hide()
        bigMessageFrame:SetScript("OnUpdate", nil)
      end
    end
  end)
end

SLASH_LFM1 = "/lfm"
SLASH_LFM3 = "/lfm help"
SLASH_LFM5 = "/lfm minimap show"
SLASH_LFM6 = "/lfm minimap hide"
SLASH_LFM = "/lfm minimap reset"

SlashCmdList["LFM"] = function(msg)
  local args = strsplit(" ", msg)
  
  if args[1] == "help" then
    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Available commands:")
    DEFAULT_CHAT_FRAME:AddMessage("|cff00FFFF /lfm  |cffFFFFFFOpens AutoLFM window.")
    DEFAULT_CHAT_FRAME:AddMessage("|cff00FFFF /lfm help   |cffFFFFFFDisplays all available orders.")
    DEFAULT_CHAT_FRAME:AddMessage("|cff00FFFF /lfm minimap show   |cffFFFFFFDisplays the minimap button.")
    DEFAULT_CHAT_FRAME:AddMessage("|cff00FFFF /lfm minimap hide   |cffFFFFFFHide minimap button.")
    DEFAULT_CHAT_FRAME:AddMessage("|cff00FFFF /lfm minimap reset   |cffFFFFFFReset minimap button position.")
    return
  end
  
  if args[1] == "" or args[1] == "open" then
    if AutoLFM then
      if AutoLFM:IsVisible() then
        HideUIPanel(AutoLFM)
      else
        ShowUIPanel(AutoLFM)
      end
    end
    return
  end
  
  if args[1] == "minimap" and args[2] == "show" then
    if AutoLFMMinimapBtn and not AutoLFMMinimapBtn:IsShown() then
      AutoLFMMinimapBtn:Show()
      AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnHidden = false
      DEFAULT_CHAT_FRAME:AddMessage("The minimap button has been redisplayed.", 0.0, 1.0, 0.0)
    else
      DEFAULT_CHAT_FRAME:AddMessage("The minimap button is already visible.", 1.0, 0.0, 0.0)
    end
    return
  end
  
  if args[1] == "minimap" and args[2] == "hide" then
    if AutoLFMMinimapBtn and AutoLFMMinimapBtn:IsShown() then
      AutoLFMMinimapBtn:Hide()
      AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnHidden = true
      DEFAULT_CHAT_FRAME:AddMessage("The minimap button has been hidden.", 0.0, 1.0, 0.0)
    else
      DEFAULT_CHAT_FRAME:AddMessage("The minimap button is already hidden.", 1.0, 0.0, 0.0)
    end
    return
  end
  
  if args[1] == "petfoireux" then
    ShowBigMessage("Fuuumiiieeeerrrr !!!!!!", 3)
    PlaySoundFile("Interface\\AddOns\\AutoLFM\\UI\\Sounds\\fumier.ogg")
    return
  end
  
  if args[1] == "minimap" and args[2] == "reset" then
    AutoLFM_SavedVariables.minimapBtnX = nil
    AutoLFM_SavedVariables.minimapBtnY = nil
    
    if AutoLFMMinimapBtn then
      AutoLFMMinimapBtn:ClearAllPoints()
      AutoLFMMinimapBtn:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -10, -10)
      AutoLFMMinimapBtn:Show()
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("Minimap button position reset to default.", 0, 1, 0)
    return
  end
  
  DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 ! Usage !   |cff00FFFF/lfm help |cffFFFFFFto list all commands.")
end