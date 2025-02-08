local vector = require "lib.brinevector"

local Layout = require "lib.classic":extend()

-- min size is in percentage of parent size
function Layout:new(params)
  assert(params.orientation == "vertical" or params.orientation == "horizontal", "invalid orientation supplied")
  self._id = params.id
  self._children = params.children
  self._size = params.size
  self._orientation = params.orientation
  self._lookup = {}
  self._isolatedLookup = params.isolatedLookup or false
  for _, child in ipairs(self._children) do
    if child._isolatedLookup == false then
      local lookup = child:getLookup()
      for k, v in pairs(lookup) do
        self._lookup[k] = v
      end
      if child._id then
        self._lookup[child._id] = child
      end
    end
  end
end

function Layout:getLookup()
  return self._lookup
end

function Layout:computeSizes(position, dimensions)
  self._computedPosition = position
  self._computedDimensions = dimensions
  local dividingLength = self._orientation == "vertical" and dimensions.y or dimensions.x
  local constantLength = self._orientation == "vertical" and dimensions.x or dimensions.y
  local remainingSpace = 100
  local evenlySpacedItemCount = 0
  for _, v in ipairs(self._children) do
    if (v._size ~= nil) then
      remainingSpace = remainingSpace - v._size
    else
      evenlySpacedItemCount = evenlySpacedItemCount + 1
    end
  end
  local evenlySpacedSize = remainingSpace / evenlySpacedItemCount
  local cursorPosition = position
  for _, v in ipairs(self._children) do
    local size = v._size ~= nil and v._size or evenlySpacedSize
    local actualLength = dividingLength * (size / 100)
    local computedSize = self._orientation == "vertical" and vector(constantLength, actualLength) or
                           vector(actualLength, constantLength)
    v:computeSizes(cursorPosition, computedSize)
    if self._orientation == "vertical" then
      cursorPosition = vector(cursorPosition.x, cursorPosition.y + computedSize.y)
    else
      cursorPosition = vector(cursorPosition.x + computedSize.x, cursorPosition.y)
    end
  end
end

function Layout:getChildren()
  return self._children
end

function Layout:getRect()
  return self._computedPosition, self._computedDimensions
end

function Layout:get(id)
  return self._lookup[id]
end

function parseLayout(layout)
  local children = {}
  if layout.children ~= nil then
    for _, child in ipairs(layout.children) do
      table.insert(children, parseLayout(child))
    end
  end
  local node = Layout({
    id = layout.id,
    orientation = layout.orientation or "horizontal",
    children = children,
    size = layout.size,
    isolatedLookup = layout.isolatedLookup
  })
  return node
end

return parseLayout
