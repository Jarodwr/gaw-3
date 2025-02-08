local libinspect = require "lib.inspect"

inspect = function(...)
print(libinspect(...))
end

local lurker = require "lib.lurker"

local Game = require "game"
local conf = require "game-config"
local game

local music

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest", 1)
  game = Game(conf.screenDimensions, {
    controls = {
      left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
      right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
      up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
      down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},
      action = {'key:x', 'button:a'},
      draw = {'key:c'},
      clear = {'key:v'},
      cancel = {'key:z', 'button:b'},
    }
  })
end

function love.update(dt)
  lurker.update()
  game:update(dt)
end

function love.draw()
  game:draw()
end
