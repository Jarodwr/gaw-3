local baton = require "lib.baton"
local LevelScreen = require "game.screen.level-screen"
local MainMenuScreen = require "game.screen.main-menu-screen"
local vector = require "lib.brinevector"
local config = require "game-config"
local MidiControls = require "game.midi-controls"

local Game = require("lib.classic"):extend()

function Game:new(screenDimensions, controls, midiControls)
  self._baton = baton.new(controls)

  self.highScore = 0

  self._canvas = love.graphics.newCanvas(screenDimensions.x, screenDimensions.y)
  self._screens = {}
  self._midiControls = MidiControls(config.midiTextFile)
  self:pushScreen(MainMenuScreen())
  -- self:pushScreen(LevelScreen())
end

function Game:setHighScoreIfValid(value)
  if self.highScore < value then
    self.highScore = value
  end
end

function Game:getSceneAtTopOfStack()
  return self._screens[#self._screens]
end

function Game:update(dt)
  self._midiControls:update()
  self._baton:update()
  self:getSceneAtTopOfStack():update(dt, self)
end

function Game:pushScreen(nextScreen)
  local oldScene = self:getSceneAtTopOfStack()
  if oldScene ~= nil then
    self:getSceneAtTopOfStack():onExit(self)
  end
  table.insert(self._screens, nextScreen)
  self:getSceneAtTopOfStack():onEnter(self)
end

function Game:popScreen()
  table.remove(self._screens)
  self:getSceneAtTopOfStack():onEnter(self)
end

function Game:getDimensions()
  return vector(self._canvas:getDimensions())
end

function Game:draw()
  love.graphics.setCanvas(self._canvas)
  love.graphics.clear()
  love.graphics.setColor(1, 1, 1)
  love.graphics.push()

  self:getSceneAtTopOfStack():draw(self)

  love.graphics.pop()
  love.graphics.setCanvas()
  love.graphics.setColor(1, 1, 1)

  local windowWidth, windowHeight = love.graphics.getDimensions()
  local scale = math.min(windowWidth / self._canvas:getWidth(), windowHeight / self._canvas:getHeight())

  love.graphics.clear()
  love.graphics.draw(self._canvas, (windowWidth - self._canvas:getWidth() * scale) / 2,
    (windowHeight - self._canvas:getHeight() * scale) / 2, 0, scale, scale)
end

return Game
