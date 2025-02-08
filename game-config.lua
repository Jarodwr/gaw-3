local vector = require "lib.brinevector"
love.graphics.setDefaultFilter("nearest", "nearest", 1)

return {
  title = "Approxiwave",
  screenDimensions = vector(640, 480),
  headerFont = love.graphics.newFont("asset/font/Kaph-Regular.ttf", 88),
  subheaderFont = love.graphics.newFont("asset/font/Kaph-Italic.ttf", 32),
  levelFont = love.graphics.newFont("asset/font/Kaph-Regular.ttf", 48),
  palette = {"#ffc888", "#ff8667", "#c11c3a", "#64172d", "#bb4310", "#f27e0d", "#ffc405", "#faffce", "#bef318",
             "#79c12d", "#2d7a29", "#123e3d", "#0d041a", "#6b3d66", "#c8667c", "#ffb4b8", "#ff6ca8", "#d036a9",
             "#6d1b81", "#240e55", "#253a91", "#1366bc", "#12a0b0", "#31f8aa"},
  sampleRate = 200,
  minSectionAmplitude = 0.5,
  maxSectionAmplitude = 1.25,
  minSectionFrequency = 1,
  maxSectionFrequency = math.pi,
  midiTextFile = "tools/midi-script/midi_values.txt",
  maxKnobValue = 127,
  levelTime = 30
}
