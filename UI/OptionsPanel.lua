--=============================================================================
-- AutoLFM: Options Panel
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.OptionsPanel then AutoLFM.UI.OptionsPanel = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local mainFrame, scrollFrame, contentFrame

-----------------------------------------------------------------------------
-- Panel Management
-----------------------------------------------------------------------------
function AutoLFM.UI.OptionsPanel.Init()
  if mainFrame then return mainFrame end

  local parent = AutoLFM.UI.Components.MainWindow.GetFrame()
  if not parent then return nil end

  local p = AutoLFM.UI.Components.PanelBuilder.CreatePanel(parent, "AutoLFM_OptionsPanel")
  if not p then return end

  mainFrame = p.panel
  mainFrame:Hide()

  p = AutoLFM.UI.Components.PanelBuilder.AddScrollFrame(p, "AutoLFM_ScrollFrame_Options")
  scrollFrame, contentFrame = p.scrollFrame, p.contentFrame

  local title = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", contentFrame, "TOP", 0, -20)
  title:SetText("Options")

  if scrollFrame and scrollFrame.UpdateScrollChildRect then
    scrollFrame:UpdateScrollChildRect()
  end

  if AutoLFM.UI.Components.DarkUI and AutoLFM.UI.Components.DarkUI.RegisterFrame then
    AutoLFM.UI.Components.DarkUI.RegisterFrame(mainFrame)
  end

  AutoLFM.UI.OptionsPanel.Register()
  return mainFrame
end

function AutoLFM.UI.OptionsPanel.Show()
  if AutoLFM.UI.Components.PanelBuilder and AutoLFM.UI.Components.PanelBuilder.ShowPanel then
    AutoLFM.UI.Components.PanelBuilder.ShowPanel(mainFrame, scrollFrame)
  end
end

function AutoLFM.UI.OptionsPanel.Hide()
  if AutoLFM.UI.Components.PanelBuilder and AutoLFM.UI.Components.PanelBuilder.HidePanel then
    AutoLFM.UI.Components.PanelBuilder.HidePanel(mainFrame, scrollFrame)
  end
end

function AutoLFM.UI.OptionsPanel.Register()
  if AutoLFM.UI.Components.TabNavigation and AutoLFM.UI.Components.TabNavigation.RegisterPanel then
    AutoLFM.UI.Components.TabNavigation.RegisterPanel("options",
      AutoLFM.UI.OptionsPanel.Show,
      AutoLFM.UI.OptionsPanel.Hide
    )
  end
end