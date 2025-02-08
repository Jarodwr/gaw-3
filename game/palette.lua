local Palette = require("lib.classic"):extend()
local config = require "game-config"

function Palette:new(hexColorList)
  self._colors = {}
  for _, str in ipairs(hexColorList) do
    local rb = tonumber(string.sub(str, 2, 3), 16)
    local gb = tonumber(string.sub(str, 4, 5), 16)
    local bb = tonumber(string.sub(str, 6, 7), 16)
    local r, g, b, a = love.math.colorFromBytes(rb, gb, bb, 1)
    table.insert(self._colors, {r = r, g = g, b = b, a = 1})
  end
end

function Palette:setColor(index)
  local color = self._colors[index]
  love.graphics.setColor(color.r, color.g, color.b)
end

function Palette:clear(index)
  local color = self._colors[index]
  love.graphics.clear(color.r, color.g, color.b)
end

return Palette(config.palette)
