--------------------------------------------------
-- Dungeons Panel
--------------------------------------------------
local dungeonsPanelFrame = nil
local dungeonScrollFrame = nil
local dungeonListContentFrame = nil
local dungeonFilterFrame = nil

--------------------------------------------------
-- Create Dungeons Panel
--------------------------------------------------
function CreateDungeonsPanel(parentFrame)
  if not parentFrame then return nil end
  if dungeonsPanelFrame then return dungeonsPanelFrame end
  
  dungeonsPanelFrame = CreateFrame("Frame", nil, parentFrame)
  dungeonsPanelFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 25, -157)
  dungeonsPanelFrame:SetWidth(323)
  dungeonsPanelFrame:SetHeight(253)
  dungeonsPanelFrame:SetFrameStrata("HIGH")
  dungeonsPanelFrame:Show()
  
  dungeonScrollFrame = CreateFrame("ScrollFrame", "AutoLFM_ScrollFrame_Dungeons", dungeonsPanelFrame, "UIPanelScrollFrameTemplate")
  dungeonScrollFrame:SetPoint("TOPLEFT", dungeonsPanelFrame, "TOPLEFT", 0, 0)
  dungeonScrollFrame:SetWidth(295)
  dungeonScrollFrame:SetHeight(253)
  dungeonScrollFrame:EnableMouse(true)
  dungeonScrollFrame:EnableMouseWheel(true)
  
  dungeonListContentFrame = CreateFrame("Frame", nil, dungeonScrollFrame)
  dungeonListContentFrame:SetWidth(dungeonScrollFrame:GetWidth() - 20)
  dungeonListContentFrame:SetHeight(1)
  dungeonScrollFrame:SetScrollChild(dungeonListContentFrame)
  
  if AutoLFM_DungeonList and AutoLFM_DungeonList.Display then
    AutoLFM_DungeonList.Display(dungeonListContentFrame)
    
    if dungeonScrollFrame.UpdateScrollChildRect then
      dungeonScrollFrame:UpdateScrollChildRect()
    end
  end
  
  if CreateColorFilterUI then
    dungeonFilterFrame = CreateColorFilterUI(parentFrame)
    if dungeonFilterFrame then
      dungeonFilterFrame:Show()
    end
  end
  
  return dungeonsPanelFrame
end

--------------------------------------------------
-- Show Dungeons Panel
--------------------------------------------------
function ShowDungeonsPanel()
  if dungeonsPanelFrame then
    dungeonsPanelFrame:Show()
  end
  
  if dungeonScrollFrame then
    dungeonScrollFrame:Show()
    dungeonScrollFrame:SetVerticalScroll(0)
    
    if dungeonScrollFrame.UpdateScrollChildRect then
      dungeonScrollFrame:UpdateScrollChildRect()
    end
  end
  
  if dungeonFilterFrame then
    dungeonFilterFrame:Show()
  end
  
  if AutoLFM_RaidList and AutoLFM_RaidList.HideSizeControls then
    AutoLFM_RaidList.HideSizeControls()
  end
  
  if AutoLFM_RaidList and AutoLFM_RaidList.ClearBackdrops then
    AutoLFM_RaidList.ClearBackdrops()
  end
end

--------------------------------------------------
-- Hide Dungeons Panel
--------------------------------------------------
function HideDungeonsPanel()
  if dungeonsPanelFrame then
    dungeonsPanelFrame:Hide()
  end
  
  if dungeonScrollFrame then
    dungeonScrollFrame:Hide()
  end
  
  if dungeonFilterFrame then
    dungeonFilterFrame:Hide()
  end
end

--------------------------------------------------
-- Get Dungeons Panel Frame
--------------------------------------------------
function GetDungeonsPanelFrame()
  return dungeonsPanelFrame
end

--------------------------------------------------
-- Get Dungeon List Content Frame (for external access)
--------------------------------------------------
function GetDungeonListContentFrame()
  return dungeonListContentFrame
end

function GetDungeonScrollFrame()
  return dungeonScrollFrame
end