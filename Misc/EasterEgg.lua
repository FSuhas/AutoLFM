--------------------------------------------------
-- Easter Egg - Big Message Animation
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

--------------------------------------------------
-- Easter Egg Command Handler
--------------------------------------------------
function HandleEasterEggCommand()
  ShowBigMessage("Fuuumiiieeeerrrr !!!!!!", 3)
  PlaySoundFile("Interface\\AddOns\\AutoLFM\\UI\\Sounds\\fumier.ogg")
end