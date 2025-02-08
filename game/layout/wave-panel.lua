return function(id, properties)
  properties = properties or {}
  local children
  if properties.viewOnly then
    children = {{
      id = "main-panel",
    }}
  else
    children = {{
      id = "main-panel",
      size = 75
    }, {
      id = "info-panel"
    }}
  end
  return {
    id = id,
    orientation = "vertical",
    children = children
  }
end
