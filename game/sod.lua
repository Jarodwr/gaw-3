local vector = require "lib.brinevector"

local SodFloat = require("lib.classic"):extend()

function SodFloat:new(f, r, z, value)
  self._f = f
  self._r = r
  self._z = z
  self._state = value
  self._targetState = value
  self._targetStateDelta = 0
  self._velocity = 0
end

function SodFloat:update(dt)
  local F = self._f
  local Z = self._z
  local R = self._r
  local T = dt

  local W = 2 * math.pi * F
  local D = W * math.sqrt(math.abs(Z * Z - 1))

  local K1 = Z / (math.pi * F)
  local K2 = 1 / (W * W)
  local K3 = R * Z / W

  local K1_Stable, K2_Stable
  if ((W * T) < Z) then
    K1_Stable = K1;
    K2_Stable = math.max(K2, math.max(T * T / 2 + T * K1 / 2, T * K1));
  else
    local T1 = math.exp(-Z * W * T);
    local Alpha
    if Z <= 1 then
      Alpha = 2 * T1 * math.cos(T * D)
    else
      Alpha = 2 * T1 * math.cosh(T * D)
    end
    local Beta = T1 * T1;
    local T2 = T / (1 + Beta - Alpha);
    K1_Stable = (1 - Beta) * T2;
    K2_Stable = T * T2;
  end

  -- Update Location
  self._state = (self._state + self._velocity * (T));
  self._velocity = (self._velocity +
              ((self._targetState + (self._targetStateDelta * (K3)) - self._state -
                (self._velocity * (K1_Stable))) * (T) / (K2_Stable)));
  -- Reset Velocity
  self._targetStateDelta = 0;
end

function SodFloat:setTarget(value)
  self._targetState = value
end

function SodFloat:getTarget(value)
  return self._targetState
end

function SodFloat:setState(value)
  self._state = value
end

function SodFloat:getState(value)
  return self._state
end

function SodFloat:applyImpulse(value)
  self._velocity = self._velocity + value
end

local SodVector = require("lib.classic"):extend()

function SodVector:new(f, z, r, value)
  self._xSod = SodFloat(f, z, r, value and value.x or 0)
  self._ySod = SodFloat(f, z, r, value and value.y or 0)
end

function SodVector:update(dt)
  self._xSod:update(dt)
  self._ySod:update(dt)
end

function SodVector:setTarget(value)
  self._xSod:setTarget(value.x)
  self._ySod:setTarget(value.y)
end

function SodVector:setState(value)
  self._xSod:setState(value.x)
  self._ySod:setState(value.y)
end

function SodVector:applyImpulse(value)
  self._xSod:applyImpulse(value.x)
  self._ySod:applyImpulse(value.y)
end

function SodVector:getState()
  return vector(self._xSod:getState(), self._ySod:getState())
end

function SodVector:getTarget()
  return vector(self._xSod:getTarget(), self._ySod:getTarget())
end

return {
  float = SodFloat,
  vector = SodVector
}
