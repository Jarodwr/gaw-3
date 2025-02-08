local vector = require "lib.brinevector"
local palette = require "game.palette"
local waveFunctionLookup = require "game.math.wave-functions"

local WaveView = require "lib.classic":extend()

local waveSampleCount = require("game-config").sampleRate

local nextWaveFunctionLookup = {}
local waveFunctionKeys = {"none", "sin", "sawtooth", "pulse", "triangular"}

for i = 1, #waveFunctionKeys do
  local next = (i + 1) % #waveFunctionKeys
  if next == 0 then
    next = #waveFunctionKeys
  end
  nextWaveFunctionLookup[waveFunctionKeys[i]] = waveFunctionKeys[next]
end

function WaveView:new(layout, color, shape)
  self._layout = layout
  self._shape = shape
  self._amplitude = 1
  self._frequency = 2
  self._styles = {
    color = color,
    maxYAxis = 10
  }

  self.mode = "add"
end

function WaveView:getFunction()
  local waveFunction = nil
  if type(self._shape) == "string" then
    waveFunction = waveFunctionLookup[self._shape]
  elseif type(self._shape) == "function" then
    waveFunction = self._shape
  end
  return waveFunction
end

function WaveView:changeToNextFunction()
  assert(type(self._shape) ~= "function", "cannot iterate if shape is function")
  self._shape = nextWaveFunctionLookup[self._shape]
end

function WaveView:getFrequency()
  return self._frequency
end

function WaveView:getAmplitude()
  return self._amplitude
end

function WaveView:setAmplitude(value)
  self._amplitude = value
end

function WaveView:setFrequency(value)
  self._frequency = value
end

function WaveView:setMode(value)
  self.mode = value
end

function WaveView:getMode()
  return self.mode
end

function WaveView:setShape(value)
  self._shape = value
end

function WaveView:getPoints()
  local mp, md = self._layout:get("main-panel"):getRect()

  -- DRAW THE WAVE
  local sampleRate = waveSampleCount / self._frequency -- Adjusted based on frequency
  local waveLength = md.x -- Length of one wave cycle
  local rx = md.x / waveLength
  local ry = md.y / self._styles.maxYAxis
  local points = {}

  local waveFunction = self:getFunction()
  for i = 1, waveSampleCount do
    local pt = (waveLength / (waveSampleCount - 1)) * (i - 1)
    table.insert(points, (pt * rx)) -- X coordinate
    local waveValue = waveFunction(i - 1, self._amplitude, self._frequency, sampleRate) -- Sample index is `i - 1`
    table.insert(points, (waveValue * ry)) -- Y coordinate
  end
  return points
end

function WaveView:draw()
  palette:setColor(self._styles.color)

  local mp, md = self._layout:get("main-panel"):getRect()
  palette:setColor(self._styles.color + 4)
  love.graphics.rectangle('fill', mp.x, mp.y, md.x, md.y)

  palette:setColor(13)
  love.graphics.push()
  love.graphics.setLineWidth(5)
  love.graphics.setLineJoin("bevel")
  love.graphics.setLineStyle("rough")
  love.graphics.translate(mp.x, mp.y + md.y / 2)
  love.graphics.line(self:getPoints())
  love.graphics.pop()

  local infoPanelLayout = self._layout:get("info-panel")
  if infoPanelLayout ~= nil then
    local ip, id = self._layout:get("info-panel"):getRect()
    palette:setColor(self._styles.color)
    love.graphics.rectangle('fill', ip.x, ip.y, id.x, id.y)
    palette:setColor(13)
    love.graphics.rectangle('line', ip.x, ip.y, id.x, id.y)
    local boxSize = 25

    for i = 1, 5 do
      local waveType = waveFunctionKeys[i]
      local primaryColor = self._shape == waveType and 13 or 1
      local secondaryColor = self._shape == waveType and 1 or 13
      love.graphics.push()
      love.graphics.translate((ip.x + 5) + ((i - 1) * (boxSize + 3)), ip.y + 7.5)
      palette:setColor(primaryColor)
      love.graphics.rectangle('fill', 0, 0, boxSize, boxSize)
      love.graphics.setLineWidth(2)
      love.graphics.setLineJoin('miter')
      palette:setColor(secondaryColor)
      love.graphics.rectangle('line', 0, 0, boxSize, boxSize)
      local fn = waveFunctionLookup[waveType]

      local pts = {}
      for i = 0, boxSize do
        local y = fn(i, 6, 2, (boxSize))
        table.insert(pts, i)
        table.insert(pts, y + boxSize / 2)
      end
      love.graphics.line(pts)
      love.graphics.pop()
    end

    do
      for i, value in ipairs({"add", "sub"}) do
        love.graphics.push()
        local offset = (i - 1) * (boxSize + 3)
        local primaryColor = self.mode == value and 13 or 1
        local secondaryColor = self.mode == value and 1 or 13
        love.graphics.translate(ip.x + 155 + offset, ip.y + 7.5)
        palette:setColor(primaryColor)
        love.graphics.rectangle('fill', 0, 0, boxSize, boxSize)
        palette:setColor(secondaryColor)
        love.graphics.rectangle('line', 0, 0, boxSize, boxSize)
        local p = 7.5
        if value == "add" then
          love.graphics.line(p, boxSize / 2, boxSize - p, boxSize / 2)
          love.graphics.line(boxSize / 2, p, boxSize / 2, boxSize - p)
        elseif value == "sub" then
          love.graphics.line(p, boxSize / 2, boxSize - p, boxSize / 2)
        end
        love.graphics.pop()
      end

    end
  end

  local tp, td = self._layout:getRect()
  palette:setColor(13)
  love.graphics.setLineWidth(5)
  love.graphics.setLineJoin("bevel")
  love.graphics.rectangle('line', tp.x, tp.y, td.x, td.y)
end

function WaveView:toggleMode()
  if self.mode == "add" then
    self.mode = "sub"
  else
    self.mode = "add"
  end
end

return WaveView
