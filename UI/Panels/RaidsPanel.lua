--------------------------------------------------
-- Raids Panel
--------------------------------------------------

local raidsPanelFrame = nil
local raidScrollFrame = nil
local raidListContentFrame = nil

--------------------------------------------------
-- Create Raids Panel
--------------------------------------------------
function CreateRaidsPanel(parentFrame)
  if not parentFrame then return nil end
  if raidsPanelFrame then return raidsPanelFrame end
  
  -- Main panel frame
  raidsPanelFrame = CreateFrame("Frame", nil, parentFrame)
  raidsPanelFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 25, -157)
  raidsPanelFrame:SetWidth(323)
  raidsPanelFrame:SetHeight(253)
  raidsPanelFrame:SetFrameStrata("HIGH")
  raidsPanelFrame:Hide()
  
  -- Scroll frame
  raidScrollFrame = CreateFrame("ScrollFrame", "AutoLFM_ScrollFrame_Raids", raidsPanelFrame, "UIPanelScrollFrameTemplate")
  raidScrollFrame:SetPoint("TOPLEFT", raidsPanelFrame, "TOPLEFT", 0, 0)
  raidScrollFrame:SetWidth(295)
  raidScrollFrame:SetHeight(253)
  raidScrollFrame:EnableMouse(true)
  raidScrollFrame:EnableMouseWheel(true)
  
  -- Content frame
  raidListContentFrame = CreateFrame("Frame", nil, raidScrollFrame)
  raidListContentFrame:SetWidth(raidScrollFrame:GetWidth() - 20)
  raidListContentFrame:SetHeight(1)
  raidScrollFrame:SetScrollChild(raidListContentFrame)
  
  -- Display raid list
  if AutoLFM_RaidList and AutoLFM_RaidList.Display then
    AutoLFM_RaidList.Display(raidListContentFrame)
  end
  
  return raidsPanelFrame
end

--------------------------------------------------
-- Show Raids Panel
--------------------------------------------------
function ShowRaidsPanel()
  if raidsPanelFrame then
    raidsPanelFrame:Show()
  end
  
  if raidScrollFrame then
    raidScrollFrame:Show()
    raidScrollFrame:SetVerticalScroll(0)
  end
  
  -- Show raid size controls
  if AutoLFM_RaidList and AutoLFM_RaidList.ShowSizeControls then
    AutoLFM_RaidList.ShowSizeControls()
  end
  
  -- Hide dungeon backdrops (but don't clear selection)
  if AutoLFM_DungeonList and AutoLFM_DungeonList.ClearBackdrops then
    AutoLFM_DungeonList.ClearBackdrops()
  end
end

--------------------------------------------------
-- Hide Raids Panel
--------------------------------------------------
function HideRaidsPanel()
  if raidsPanelFrame then
    raidsPanelFrame:Hide()
  end
  
  if raidScrollFrame then
    raidScrollFrame:Hide()
  end
end

--------------------------------------------------
-- Get Raids Panel Frame
--------------------------------------------------
function GetRaidsPanelFrame()
  return raidsPanelFrame
end

--------------------------------------------------
-- Get Raid List Content Frame (for external access)
--------------------------------------------------
function GetRaidListContentFrame()
  return raidListContentFrame
end