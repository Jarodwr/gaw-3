local config = require "game-config"
local palette = require "game.palette"
local LevelScreen = require "game.screen.level-screen"

local MainMenuScreen = require "game.screen":extend()

function MainMenuScreen:new()

end

function MainMenuScreen:update(dt, game)
  if game._midiControls:allKnobsAt0() and game._midiControls:pressed(1) then
    game:pushScreen(LevelScreen())
  end
end

function drawHeaderText(font, text, shadowOffset)
  love.graphics.setFont(font)
  palette:setColor(13)
  love.graphics.print(text, shadowOffset, shadowOffset)
  palette:setColor(2)
  love.graphics.print(text)
end

function MainMenuScreen:draw(game)
  palette:clear(20)
  love.graphics.push()
  love.graphics.push()
  love.graphics.translate(500, 30)
  drawHeaderText(config.subheaderFont, "HIGH", 5)
  love.graphics.translate(0, config.subheaderFont:getHeight())
  palette:setColor(13)
  love.graphics.printf(game.highScore, 5, 5, config.subheaderFont:getWidth("HIGH"), "center")
  palette:setColor(2)
  love.graphics.printf(game.highScore, 0, 0, config.subheaderFont:getWidth("HIGH"), "center")
  love.graphics.pop()
  love.graphics.translate(30, 30)
  drawHeaderText(config.headerFont, "FUNC", 5)
  love.graphics.translate(0, config.headerFont:getHeight())
  drawHeaderText(config.headerFont, "MATCH", 5)
  love.graphics.translate(0, config.headerFont:getHeight() * 2)
  drawHeaderText(config.subheaderFont, "To Start:", 5)
  love.graphics.translate(0, config.subheaderFont:getHeight())
  drawHeaderText(config.subheaderFont, "Reset dials to min", 5)
  love.graphics.translate(0, config.subheaderFont:getHeight())
  drawHeaderText(config.subheaderFont, "And press pad 5", 5)
  love.graphics.pop()

end

return MainMenuScreen
