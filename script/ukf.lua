require 'include'
require 'common'
require 'poseUtils'
require 'torch-load'

local datasetpath = '../data/010213180247/'
local imuset = loadData(datasetpath, 'imuPruned')

--imuPruned = pruneTUC(imuset)

--saveData(imuPruned, 'imuPruned')

state = {}
state = torch.DoubleTensor(13):fill(0) -- x, y, z, q0, q1, q2, q3, vx, vy, vz, wx, wy, wz
pos = state:narrow(1, 1, 3)
q = state:narrow(1, 4, 4)
q[1] = 1
linearVel = state:narrow(1, 8, 3)
angularVel = state:narrow(1, 11, 3)

--local q = torch.DoubleTensor(4):fill(0)
local dq = torch.DoubleTensor(4):fill(0)
local lasetstep = imuset[1].timstamp

for i = 2, #imuset - 1 do
  angularVel[1] = imuset[i].wr
  angularVel[2] = imuset[i].wp
  angularVel[3] = imuset[i].wy
  acc = torch.DoubleTensor({imuset[i].ax, imuset[i].ay, imuset[i].az})
  print(acc)
  local dt = imuset[i].timstamp - lasetstep
  lasetstep = imuset[i].timstamp
  if angularVel:norm() ~= 0 and dt ~= 0 then 
    -- update orientation
    dAngle = angularVel:norm() * dt
    dAxis = angularVel:div(angularVel:norm()) 
    dq[1] = math.cos(dAngle / 2)
    dq[{{2, 4}}] = dAxis * math.sin(dAngle / 2)
    q:copy(QuaternionMul(q, dq))
    
    pos[1] = pos[1] + linearVel[1] * dt + 0.5 * acc[1] * dt ^ 2
    pos[2] = pos[2] + linearVel[2] * dt + 0.5 * acc[2] * dt ^ 2
    pos[3] = pos[3] + linearVel[3] * dt + 0.5 * acc[3] * dt ^ 2
    linearVel[1] = linearVel[1] + dt * acc[1]
    linearVel[2] = linearVel[2] + dt * acc[2]
    linearVel[3] = linearVel[3] + dt * acc[3] 
--    print(state)
  end
end

--print(torch.diag(torch.ones(3)))

--rpy = torch.DoubleTensor({math.pi/5, math.pi/3, math.pi/6})
--R = rpy2R(rpy)
--q:copy(R2Quaternion(R))
--R = torch.DoubleTensor({{0.5, 0.6, 0},{0.3, 0.7, 0},{0, 0, 1}})
--print(q)
--R1 = Quaternion2R(q)
--print(R1)
--print(q:norm())

q1 = torch.DoubleTensor({-0.2852, -0.1770, -0.6088, 0.7188})
q2 = torch.DoubleTensor({1, -0.0020, 0.0008, 0.0010})
q3 = QuaternionMul(q1, q2)
--print(q3)

--local gravity = 9.81

