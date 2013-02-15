require 'include'
require 'common'

require 'torch-load'

--local datasetpath = '../data/010213180247/'
--local imuset = loadData(datasetpath, 'imuPruned')

--imuPruned = pruneTUC(imuset)

--saveData(imuPruned, 'imuPruned')

function QuaterionMul(q1, q2)  --t = q1 x q2
  t = torch.DoubleTensor(4)
  t[{1}] = q2[{1}]*q1[{1}]-q2[{2}]*q1[{2}]-q2[{3}]*q1[{3}]-q2[{4}]*q1[{4}]
  t[{2}] = q2[{1}]*q1[{2}]+q2[{2}]*q1[{1}]-q2[{3}]*q1[{4}]+q2[{4}]*q1[{3}]
  t[{3}] = q2[{1}]*q1[{3}]+q2[{2}]*q1[{4}]+q2[{3}]*q1[{1}]-q2[{4}]*q1[{2}]
  t[{4}] = q2[{1}]*q1[{4}]-q2[{2}]*q1[{3}]+q2[{3}]*q1[{2}]+q2[{4}]*q1[{1}]
  return t
end

function R2rpy(R)
  local n = R:narrow(2, 1, 1)
  local o = R:narrow(2, 2, 1)
  local a = R:narrow(2, 3, 1)
  local y = torch.atan(n[2]:clone():cdiv(n[1]))
  print(type(n[2]))
  print(type(y))
  local p = torch.atan(-n[3] / (n[1] * y:clone():cos() + n[2] * y:clone():sin()))
  print(type((n[1] * y:clone():cos() + n[2] * y:clone():sin())))
  print(type(p))
  local r = torch.atan((a[1]*y:clone():sin()-a[2]*y:clone():cos()) / 
                        (-o[1]*y:clone():sin()+o[2]*y:clone():cos()))
  print(type(a[1]*y:clone():sin()-a[2]*y:clone():cos()))
  print(type(-o[1]*y:clone():sin()+o[2]*y:clone():cos()))

  print(type(r))
--  local r = torch.atan()
  local rpy = torch.DoubleTensor(3):fill(0)
  print(R)
  return rpy
end

function rpy2R(rpy)
  local Rz = torch.DoubleTensor(3,3):fill(0)
  local Ry = torch.DoubleTensor(3,3):fill(0)
  local Rx = torch.DoubleTensor(3,3):fill(0)
  local r = rpy[{1}]
  local p = rpy[{2}]
  local y = rpy[{3}]
  Rz[{1, 1}] = math.cos(y) 
  Rz[{2, 1}] = math.sin(y) 
  Rz[{1, 2}] = -math.sin(y) 
  Rz[{2, 2}] = math.cos(y) 
  Rz[{3, 3}] = 1
  Ry[{1, 1}] = math.cos(p)
  Ry[{3, 1}] = -math.sin(p)
  Ry[{1, 3}] = math.sin(p)
  Ry[{3, 3}] = math.cos(p)
  Ry[{2, 2}] = 1
  Rx[{2, 2}] = math.cos(r)
  Rx[{3, 2}] = math.sin(r)
  Rx[{2, 3}] = -math.sin(r)
  Rx[{3, 3}] = math.cos(r)
  Rx[{1, 1}] = 1
  local R = torch.mm(Rz, Ry)
  R:mm(R, Rx)
  return R
end

state = {}
state = torch.DoubleTensor(13):fill(0) -- x, y, z, q0, q1, q2, q3, vx, vy, vz, wx, wy, wz

--print(state)

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
--  end
--end

R = torch.DoubleTensor({{0.5, 0.6, 0},{0.3, 0.7, 0},{0, 0, 1}})
print(R)
R2rpy(R)

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
