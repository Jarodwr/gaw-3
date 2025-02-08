local config = require "game-config"
local palette = require "game.palette"

local vector = require "lib.brinevector"
local tick = require "lib.tick"

local parseLayout = require "game.layout"
local screenLayout = require "game.layout.level"

local config = require "game-config"
local waveFunctionLookup = require "game.math.wave-functions"
local WaveReadonly = require "game.screen.level-screen.wave-readonly"

local WaveView = require "game.screen.level-screen.wave-view"

local LevelScreen = require("game.screen"):extend()

function LevelScreen:new()
  self._score = 0
  self._currentWaveFunction = nil
  self._waveSections = {}
  self._layout = parseLayout(screenLayout)
  for i = 1, 4 do
    local waveType = nil
    if i == 1 then
      waveType = "sin"
    elseif i == 2 then
      waveType = "none"
    elseif i == 3 then
      waveType = "none"
    elseif i == 4 then
      waveType = "none"
    end
    self._waveSections[i] = WaveView(self._layout:get("wave-" .. i), i, waveType)
  end
  self._waveOutput = WaveReadonly(self._waveSections, 9);
  self:regenerateGoalWaveSections()
  self._waveGoal = WaveReadonly(self._secretGoalWaveSections, 10)
  self._levelTime = config.levelTime
end

function LevelScreen:regenerateGoalWaveSections()
  -- clear the table
  self._secretGoalWaveSections = self._secretGoalWaveSections or {}
  for k in ipairs(self._secretGoalWaveSections) do
    self._secretGoalWaveSections[k] = nil
  end
  local count = 0
  local hasSubs = false
  if self._score < 4 then -- single
    hasSubs = true
    count = 1
  elseif self._score < 8 then
    count = 2
  elseif self._score < 16 then -- double
    hasSubs = true
    count = 2
  elseif self._score < 24 then -- triple
    hasSubs = false
    count = 3
  else -- quadruple
    count = 4
  end
  local availableWaveFunctions = {}
  for k, _ in pairs(waveFunctionLookup) do
    if k ~= "none" then
      table.insert(availableWaveFunctions, k)
    end
  end

  for i = 1, count do
    local key = availableWaveFunctions[math.random(1, #availableWaveFunctions)]
    local wv = WaveView(self._layout:get("wave-" .. i))
    local freqDiff = config.maxSectionFrequency - config.minSectionFrequency
    local amplDiff = config.maxSectionAmplitude - config.minSectionAmplitude
    math.randomseed(os.time())
    local freqVal = math.random(0, config.maxKnobValue) / config.maxKnobValue
    math.randomseed(os.time())
    local amplVal = math.random(0, config.maxKnobValue) / config.maxKnobValue
    wv:setFrequency((freqDiff * freqVal) + config.minSectionFrequency)
    wv:setAmplitude((amplDiff * amplVal) + config.minSectionAmplitude)
    wv:setMode((math.random(0, 1) > 0 and hasSubs) and "sub" or "add")
    wv:setShape(key)
    table.insert(self._secretGoalWaveSections, wv)
  end
end

function LevelScreen:update(dt, game)
  local controls = game._midiControls
  for i, section in ipairs(self._waveSections) do
    local amplitudeKnobValue = controls:knob(((i - 1) * 2) + 1)
    local frequencyKnobValue = controls:knob(((i - 1) * 2) + 2)
    local amplitude = ((config.maxSectionAmplitude - config.minSectionAmplitude) * amplitudeKnobValue) +
                        config.minSectionAmplitude
    local frequency = ((config.maxSectionFrequency - config.minSectionFrequency) * frequencyKnobValue) +
                        config.minSectionFrequency
    section:setFrequency(frequency)
    section:setAmplitude(amplitude)

    local changeShapePress = controls:pressed(((i - 1) * 2) + 1)
    local changeModePress = controls:pressed(((i - 1) * 2) + 2)
    if changeShapePress then
      section:changeToNextFunction()
    end
    if changeModePress then
      section:toggleMode()
    end
  end
  -- check if the level is complete
  if self:isCompatible() then
    self._score = self._score + 1
    self:regenerateGoalWaveSections()
    self._levelTime = config.levelTime * (#self._secretGoalWaveSections)

  end
  self._levelTime = self._levelTime - dt

  if self._levelTime <= 0 then
    game:setHighScoreIfValid(self._score)
    game:popScreen()
  end
end

function LevelScreen:isCompatible()
  return self:getMinimumCompatibilityRating() > self:getCompatibilityRating()
end

function LevelScreen:getMinimumCompatibilityRating()
  if self._secretGoalWaveSections == 1 then
    return 650
  elseif self._secretGoalWaveSections == 2 then
    return 700
  elseif self._secretGoalWaveSections == 3 then
    return 750
  elseif self._secretGoalWaveSections == 4 then
    return 800
  end
end

function LevelScreen:draw(game)
  palette:clear(20)

  local dimensions = game:getDimensions()
  self._layout:computeSizes(vector(0, 0), dimensions)

  for _, section in ipairs(self._waveSections) do
    section:draw()
  end
  self._waveGoal:draw(self._layout:get('wave-goal'), 9, 13)
  -- DRAW THE OUTPUT
  self._waveOutput:draw(self._layout:get('wave-output'), 10, 13)

  -- Draw them overlaid over each other for compatibility
  self._waveGoal:draw(self._layout:get('wave-overlay'), 11, 1)
  self._waveOutput:draw(self._layout:get('wave-overlay'), nil, 13)

  local ip, id = self._layout:get('info-box'):getRect()
  love.graphics.push()
  love.graphics.translate(ip.x, ip.y)
  love.graphics.translate(5, 5)
  love.graphics.setFont(config.levelFont)
  palette:setColor(13)
  love.graphics.print("SCORE: " .. (self._score), 5, 5)
  palette:setColor(3)
  love.graphics.print("SCORE: " .. (self._score))
  love.graphics.translate(0, config.levelFont:getHeight() * 1.5)
  love.graphics.setFont(config.levelFont)
  palette:setColor(13)
  love.graphics.print("TIMER: " .. math.ceil(self._levelTime), 5, 5)
  palette:setColor(3)
  love.graphics.print("TIMER: " .. math.ceil(self._levelTime))
  love.graphics.pop()
end

function LevelScreen:getCompatibilityRating()
  local goalPts = self._waveGoal:getPoints()
  local outputPts = self._waveOutput:getPoints()
  local totalDifference = 0
  for i = 1, (#goalPts) / 2 do
    local x1 = goalPts[((i - 1) * 2) + 1]
    local y1 = goalPts[((i - 1) * 2) + 2]
    local x2 = outputPts[((i - 1) * 2) + 1]
    local y2 = outputPts[((i - 1) * 2) + 2]
    totalDifference = totalDifference + math.abs(y1 - y2)
  end
  return totalDifference
end

return LevelScreen
