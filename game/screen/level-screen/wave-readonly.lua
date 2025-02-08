local palette = require "game.palette"
local vector = require "lib.brinevector"
local WaveReadonly = require "lib.classic":extend()

function WaveReadonly:new(waveSections)
  self._waveSections = waveSections
  self._points = {}
end

function WaveReadonly:draw(layout, color, lineColor)
  love.graphics.push()
  local mp, md = layout:getRect()
  love.graphics.translate(mp.x, mp.y)
  if (color) then
    palette:setColor(color)
    love.graphics.rectangle("fill", 0, 0, md.x, md.y)
  end
  love.graphics.translate(0, (md.y / 2))
  local pointCollections = {}
  local basePointCounts = 0
  for _, section in ipairs(self._waveSections) do
    basePointCounts = #(section:getPoints())
    local pts = section:getPoints()
    local nextPoints = {}
    if section:getMode() == "sub" then
      for i, val in ipairs(pts) do
        if (i - 1) % 2 == 0 then
          table.insert(nextPoints, val)
        else
          table.insert(nextPoints, -val)
        end
      end
    else
      nextPoints = pts
    end
    table.insert(pointCollections, nextPoints)
  end
  local xLookup = {}
  for i = 1, (basePointCounts / 2) do
    for _, pts in ipairs(pointCollections) do
      local x = pts[((i - 1) * 2) + 1]
      xLookup[x] = xLookup[x] or {}
      table.insert(xLookup[x], pts[((i - 1) * 2) + 2])
    end
  end
  local points = {}
  for x, ys in pairs(xLookup) do
    local totalY = 0
    for _, y in ipairs(ys) do
      totalY = totalY + y
    end
    table.insert(points, vector(x, totalY))
  end
  table.sort(points, function(a, b)
    return a.x < b.x
  end)
  local actualPoints = {}
  for _, pt in ipairs(points) do
    table.insert(actualPoints, pt.x)
    table.insert(actualPoints, pt.y)
  end
  palette:setColor(lineColor)

  love.graphics.setLineWidth(5)
  love.graphics.setLineJoin("bevel")
  love.graphics.setLineStyle("rough")
  love.graphics.line(actualPoints)
  love.graphics.pop()
  local tp, td = layout:getRect()
  palette:setColor(lineColor)
  love.graphics.rectangle('line', tp.x, tp.y, td.x, td.y)

  -- We store this to do the compatibility check
  self._points = actualPoints
end

function WaveReadonly:getPoints()
  return self._points
end

return WaveReadonly
