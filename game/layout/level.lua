local wavePanelLayout = require "game.layout.wave-panel"

return {
  orientation = "vertical",
  children = {{
    orientation = "vertical",
    children = {{
      orientation = "horizontal",
      children = {wavePanelLayout("wave-1"), wavePanelLayout("wave-2"), wavePanelLayout("wave-output", {
        viewOnly = true
      })}
    }, {
      orientation = "horizontal",
      children = {wavePanelLayout("wave-3"), wavePanelLayout("wave-4"), wavePanelLayout("wave-goal", {
        viewOnly = true
      })}
    }}
  }, {
    orientation = "horizontal",
    children = {{
      id = "info-box",
      orientation = "vertical"
    }, {
      id = "compatibility",
      orientation = "vertical"

    }, {
      id = "wave-overlay",
      orientation = "vertical",
    }},
    size = 33
  }}
}
