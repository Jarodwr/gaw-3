local config = require "game-config"

local MidiControls = require "lib.classic":extend()

function MidiControls:new(path)
  self._controls = {}
  self._pads = {}
  self._path = path

  for i = 1, 8 do
    self._controls[i] = {
      value = 0
    }
    self._pads[i] = {
      value = 0,
      isJustPressed = false
    }
  end
end

function MidiControls:allKnobsAt0()
  for _, item in ipairs(self._controls) do
    if item.value ~= 0 then
      return false
    end
  end
  return true
end

function MidiControls:update()
  local value = love.filesystem.read(self._path)

  if not value then
    return
  end
  for line in string.gmatch(value, "[^\r\n]+") do
    local parts = {}
    for part in string.gmatch(line, "%S+") do
      table.insert(parts, part)
    end
    local numberParts = {}
    for part in string.gmatch(parts[2], "([^:]+)") do
      table.insert(numberParts, part)
    end
    local controlType = parts[1]
    local index = tonumber(numberParts[1])
    local value = tonumber(numberParts[2])

    if index ~= 0 then
      if controlType == "Control" then
        self._controls[index].value = value / config.maxKnobValue
      else
        index = ((index - 35) + 4) % 8
        if index == 0 then
          index = 8
        end
        local pad = self._pads[index]
        local oldValue = pad.value
        pad.value = value / config.maxKnobValue
        pad.isJustPressed = oldValue ~= value and oldValue == 0
      end
    end
  end
end

function MidiControls:knob(index)
  return self._controls[index].value
end

function MidiControls:pressed(index)
  return self._pads[index].isJustPressed
end

return MidiControls
