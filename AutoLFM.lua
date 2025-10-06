--------------------------------------------------
-- AutoLFM
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
  end
  if LoadDungeonFilters then
    LoadDungeonFilters()
  end
  initSteps.step1 = true
  return true
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
  AutoLFM_PrintSuccess("Loaded successfully!")
  AutoLFM_PrintInfo("|cffffff00More information: |cff00FFFF/lfm help")
  
  TryInitStep1()
  TryInitStep2()
  TryInitStep3()
  
  msglog:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

msglog:SetScript("OnEvent", function()
  local currentEvent = event
  if currentEvent == "PLAYER_ENTERING_WORLD" then
    OnPlayerEnteringWorld()
  end
end)