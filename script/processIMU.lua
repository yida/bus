require 'include'
require 'common'

require 'torch-load'

local datasetpath = '../data/010213180247/'
local imuset = loadData(datasetpath, 'imuPruned')

--imuPruned = pruneTUC(imuset)

--saveData(imuPruned, 'imuPruned')

state = {}
state = torch.DoubleTensor(6) -- x, y, z, vx, vy, vz
print(state)

local lasetstep = imuset[1].timstamp
local gravity = 9.81
for i = 2, #imuset - 10000 do
--for i = 2, 3 do
  local dt = imuset[i].timstamp - lasetstep
  local ax = imuset[i].ax * gravity
  local ay = imuset[i].ay * gravity
  local az = (imuset[i].az + 1) * gravity
  lasetstep = imuset[i].timstamp
  print(dt, ax, ay, az)
  state[1] = state[1] + state[4] * dt + 0.5 * ax * dt * dt
  state[2] = state[2] + state[5] * dt + 0.5 * ay * dt * dt
  state[3] = state[3] + state[6] * dt + 0.5 * az * dt * dt
  state[4] = state[4] + ax * dt
  state[5] = state[5] + ay * dt
  state[6] = state[6] + az * dt
  print(state)
end
