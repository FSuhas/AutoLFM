--------------------------------------------------
-- Message Preview Component
--------------------------------------------------

local messagePreviewFrame = nil
local messageText = nil

--------------------------------------------------
-- Create Message Preview Frame
--------------------------------------------------
function CreateMessagePreview(parentFrame)
  if not parentFrame then return nil end
  if messagePreviewFrame then return messagePreviewFrame end
  
  messagePreviewFrame = CreateFrame("Frame", nil, parentFrame)
  messagePreviewFrame:SetPoint("TOP", parentFrame, "TOP", -10, -125)
  messagePreviewFrame:SetWidth(330)
  messagePreviewFrame:SetHeight(30)
  
  messageText = messagePreviewFrame:CreateFontString(nil, "MEDIUM", "GameFontHighlight")
  messageText:SetPoint("CENTER", messagePreviewFrame, "CENTER", 0, 0)
  messageText:SetTextColor(1, 1, 1)
  
  -- Always visible, no need to show/hide
  messagePreviewFrame:Show()
  
  return messagePreviewFrame
end

--------------------------------------------------
-- Update Message Preview
--------------------------------------------------
function UpdateMessagePreview()
  if not messageText then return end
  
  local message = GetGeneratedLFMMessage()
  messageText:SetText(message or "")
end