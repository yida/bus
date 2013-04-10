require 'include'
require 'common'

require 'torch-load'

local datasetpath = '../data/010213180247/'
local datasetpath = './'
local imuset = loadDataMP(datasetpath, 'imuMP')

imuPruned = pruneTUC(imuset)

print(#imuPruned)
saveDataMP(imuPruned, 'imuPrunedMP', './')

--state = {}
--state = torch.DoubleTensor(6) -- x, y, z, vx, vy, vz
----print(state)
--
--local q = torch.DoubleTensor(4):fill(0)
--q[{1}] = 1
--local dq = torch.DoubleTensor(4):fill(0)
--local lasetstep = imuset[1].timstamp
--for i = 2, #imuset - 1 do
--  local angularVelocity = torch.DoubleTensor({{imuset[i].wr, imuset[i].wp, imuset[i].wy}})
--  local dt = imuset[i].timstamp - lasetstep
--  lasetstep = imuset[i].timstamp
--  if angularVelocity:norm() ~= 0 and dt ~= 0 then 
--    dAngle = angularVelocity:norm() * dt
--    dAxis = angularVelocity:div(angularVelocity:norm()) 
--    dq[{1}] = math.cos(dAngle / 2)
--    dq[{{2, 4}}] = dAxis * math.sin(dAngle / 2)
--    q = QuaterionMul(q, dq)
--    print(q:norm())
--  end
--end

--local gravity = 9.81
--for i = 2, #imuset - 10000 do
----for i = 2, 3 do
--  local ax = imuset[i].ax * gravity
--  local ay = imuset[i].ay * gravity
--  local az = (imuset[i].az + 1) * gravity
--  print(dt, ax, ay, az)
--  state[1] = state[1] + state[4] * dt + 0.5 * ax * dt * dt
--  state[2] = state[2] + state[5] * dt + 0.5 * ay * dt * dt
--  state[3] = state[3] + state[6] * dt + 0.5 * az * dt * dt
--  state[4] = state[4] + ax * dt
--  state[5] = state[5] + ay * dt
--  state[6] = state[6] + az * dt
--  print(state)
--end
