
return {
  none = function()
    return 0
  end,
  sin = function(sampleIndex, amplitude, frequency, sampleRate)
    local x = sampleIndex / sampleRate
    return -math.sin(x * frequency * (math.pi * 2)) * amplitude
  end,
  pulse = function(sampleIndex, amplitude, frequency, sampleRate)
    local x = sampleIndex / sampleRate
    if (x % (1 / frequency)) > (0.5 / frequency) then
      return amplitude
    else
      return -amplitude
    end
  end,
  triangular = function(sampleIndex, amplitude, frequency, sampleRate)
    local x = sampleIndex / sampleRate
    local cycle_position = (x * frequency) % 1
    if cycle_position < 0.5 then
      return amplitude * (4 * cycle_position - 1) -- Linearly increase from -amplitude to amplitude
    else
      return amplitude * (3 - 4 * cycle_position) -- Linearly decrease from amplitude back to -amplitude
    end
  end,

  sawtooth = function(sampleIndex, amplitude, frequency, sampleRate)
    local x = sampleIndex / sampleRate
    local cycle_position = (x * frequency) % 1
    return amplitude * (2 * cycle_position - 1) -- Extend from -amplitude to +amplitude
  end
}