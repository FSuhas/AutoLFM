--=============================================================================
-- AutoLFM: ContentPanel Factory
--   Reusable factory for creating and managing content panel UI handlers
--   Reduces code duplication across Dungeons, Raids, Quests panels
--=============================================================================

AutoLFM = AutoLFM or {}
AutoLFM.UI = AutoLFM.UI or {}

--=============================================================================
-- ContentPanel Factory
--   Creates a content panel with standard lifecycle hooks and event listeners
--=============================================================================

--- Creates a new content panel with automatic lifecycle and event management
--- Provides: OnLoad, OnShow, Refresh, and Maestro event listener registration
---
--- @param config table - Configuration object
---   - name: string - Panel identifier (e.g., "Dungeons", "Raids")
---   - rowTemplatePrefix: string - XML template prefix (e.g., "AutoLFM_DungeonRow")
---   - createRowsFunc: function - Function to create/update rows (signature: function(scrollChild))
---   - clearCacheFunc: function|nil - Optional function to clear cache on show
---   - listeningEvent: string - Maestro event to listen to (e.g., "Selection.Changed")
---   - listenerInitHandler: string - Init handler ID (e.g., "I22")
---   - listenerDependencies: table - Init handler dependencies (e.g., { "Logic.Selection" })
---   - listenerId: string - Listener ID (e.g., "L06")
---
--- @return table - The panel module with standard API
---
--- Example usage:
---   AutoLFM.UI.Content.Dungeons = AutoLFM.UI.CreateContentPanel({
---     name = "Dungeons",
---     rowTemplatePrefix = "AutoLFM_DungeonRow",
---     createRowsFunc = function(scrollChild) ... end,
---     clearCacheFunc = AutoLFM.Logic.Content.Dungeons.ClearCache,
---     listeningEvent = "Selection.Changed",
---     listenerInitHandler = "I22",
---     listenerDependencies = { "Logic.Selection" },
---     listenerId = "L06"
---   })
---
function AutoLFM.UI.CreateContentPanel(config)
  if not config or not config.name or not config.rowTemplatePrefix or not config.createRowsFunc then
    AutoLFM.Core.Utils.LogError("CreateContentPanel: Missing required config (name, rowTemplatePrefix, createRowsFunc)")
    return nil
  end

  local panel = {}
  local frameRef = nil

  --- Stores reference to the content frame
  --- @param frame frame - The content frame
  function panel.OnLoad(frame)
    frameRef = frame
  end

  --- Handles frame show event - clears cache and rebuilds rows
  --- @param frame frame - The content frame
  function panel.OnShow(frame)
    AutoLFM.UI.RowList.OnShowHandler(
      frame,
      config.createRowsFunc,
      config.clearCacheFunc,
      config.rowTemplatePrefix
    )
  end

  --- Refreshes the panel display by rebuilding rows
  function panel.Refresh()
    if frameRef then
      panel.OnShow(frameRef)
    end
  end

  --- Registers event listener with Maestro (called during initialization)
  function panel.RegisterListener()
    if not config.listeningEvent or not config.listenerId then
      return
    end

    local listenerName = "UI." .. config.name .. ".On" .. string.gsub(config.listeningEvent, "%..*", "")
    AutoLFM.Core.Maestro.Listen(
      listenerName,
      config.listeningEvent,
      function()
        panel.Refresh()
      end,
      { id = config.listenerId }
    )
  end

  --- Registers the panel's initialization handler with Maestro
  --- Called automatically during addon startup
  if config.listenerInitHandler and config.listeningEvent then
    AutoLFM.Core.SafeRegisterInit("UI." .. config.name, function()
      panel.RegisterListener()
    end, {
      id = config.listenerInitHandler,
      dependencies = config.listenerDependencies or {}
    })
  end

  return panel
end

AutoLFM.UI.ContentPanel = AutoLFM.UI.CreateContentPanel
