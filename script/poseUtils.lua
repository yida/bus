require 'torch-load'

function QCompare(q, res)
  if math.abs(q[1]) > res then return false end
  if math.abs(q[2]) > res then return false end
  if math.abs(q[3]) > res then return false end
  if math.abs(q[4]) > res then return false end
  return true
end

function QDiff(q1, q2, res)
--  print(q1, q2)
--  print(math.abs(q1[1] - q2[1]))
  if math.abs(q1[1] - q2[1]) > res then return false end
  if math.abs(q1[2] - q2[2]) > res then return false end
  if math.abs(q1[3] - q2[3]) > res then return false end
  if math.abs(q1[4] - q2[4]) > res then return false end
  return true
end

function Vector2Q(w, dt)
--  print(w)
  local dq = torch.DoubleTensor(4):fill(0)
  if w:norm() == 0 then
    dq[1] = 1
    return dq
  end
  if dt then
    dAngle = w:norm() * dt
  else
    dAngle = w:norm()
  end
  dAxis = w:div(w:norm()) 
  dq[1] = math.cos(dAngle / 2)
  dq[{{2, 4}}] = dAxis * math.sin(dAngle / 2)
  return dq
end

function Q2Vector(q)
  if q[1] > 1 then q[1] = 1 end
  local alphaW = math.acos(q[1])
  local v = torch.DoubleTensor(3):fill(0)
  if alphaW > 0.0001 then
    v[1] = q[2] / math.sin(alphaW) * alphaW
    v[2] = q[3] / math.sin(alphaW) * alphaW
    v[3] = q[4] / math.sin(alphaW) * alphaW
  end
  return v
end

function QInverse(Q)
  local q = torch.DoubleTensor(4):copy(Q)
  local norm = q:norm()
  return torch.DoubleTensor({q[1]/norm, -q[2]/norm,
                            -q[3]/norm, -q[4]/norm})
end

function Quaternion2R(qin)
  local R = torch.DoubleTensor(3,3):fill(0)
  local q = torch.DoubleTensor(4):copy(qin)

  R[1][1] = 1 - 2 * q[3] * q[3] - 2 * q[4] * q[4]
  R[1][2] = 2 * q[2] * q[3] - 2 * q[4] * q[1]
  R[1][3] = 2 * q[2] * q[4] + 2 * q[3] * q[1]
  R[2][1] = 2 * q[2] * q[3] + 2 * q[4] * q[1]
  R[2][2] = 1 - 2 * q[2] * q[2] - 2 * q[4] * q[4]
  R[2][3] = 2 * q[3] * q[4] - 2 * q[2] * q[1]
  R[3][1] = 2 * q[2] * q[4] - 2 * q[3] * q[1]
  R[3][2] = 2 * q[3] * q[4] + 2 * q[2] * q[1]
  R[3][3] = 1 - 2 * q[2] * q[2] - 2 * q[3] * q[3]

  return R
end
--function Quaternion2R(q)
--  local n = q:norm()
--  local nq = q:div(q:norm())
--  local w = nq[1]
--  local x = nq[2]
--  local y = nq[3]
--  local z = nq[4]
--  local w2 = w * w
--  local x2 = x * x
--  local y2 = y * y
--  local z2 = z * z
--  local xy = x * y
--  local xz = x * z
--  local yz = y * z
--  local wx = w * x
--  local wy = w * y
--  local wz = w * z
--  local R = torch.DoubleTensor(3,3):fill(0)
--  R[1][1] = w2 + x2 - y2 - z2
--  R[2][1] = 2 * (wz + xy)
--  R[3][1] = 2 * (xz - wy)
--  R[1][2] = 2 * (xy - wz) 
--  R[2][2] = w2 - x2 + y2 - z2 
--  R[3][2] = 2 * (wx + yz)
--  R[1][2] = 2 * (wy + xz)
--  R[2][2] = 2 * (yz - wx) 
--  R[3][2] = w2 - x2 - y2 + z2
----  print(R)
----  print(w2, x2, y2, z2)
--  return R
--end

function R2Quaternion(R)
  local q = torch.DoubleTensor(4)
  local tr = R[1][1] + R[2][2] + R[3][3]
  if tr > 0 then
    local S = math.sqrt(tr + 1.0) * 2
    q[1] = 0.25 * S
    q[2] = (R[3][2] - R[2][3]) / S
    q[3] = (R[1][3] - R[3][1]) / S
    q[4] = (R[2][1] - R[1][2]) / S
  elseif R[1][1] > R[2][2] and R[1][1] > R[3][3] then
    local S = math.sqrt(1.0 + R[1][1] - R[2][2] - R[3][3]) * 2
    q[1] = (R[3][2] - R[2][3]) / S
    q[2] = 0.25 * S
    q[3] = (R[1][2] + R[2][1]) / S 
    q[4] = (R[1][3] + R[3][1]) / S
  elseif R[2][2] > R[3][3] then
    local S = math.sqrt(1.0 + R[2][2] - R[1][1] - R[3][3]) * 2
    q[1] = (R[1][3] - R[3][1]) / S
    q[2] = (R[1][2] + R[2][1]) / S 
    q[3] = 0.25 * S
    q[4] = (R[2][3] + R[3][2]) / S
  else
    local S = math.sqrt(1.0 + R[3][3] - R[1][1] - R[2][2]) * 2
    q[1] = (R[2][1] - R[1][2]) / S
    q[2] = (R[1][3] + R[3][1]) / S 
    q[3] = (R[2][3] + R[3][2]) / S
    q[4] = 0.25 * S
  end
  return q
end

function QuaternionMul(Q1, Q2)  -- q = q1 x q2
  local q = torch.DoubleTensor(4)
  local q1 = torch.DoubleTensor(4):copy(Q1)
  local q2 = torch.DoubleTensor(4):copy(Q2)
  q[1] = q2[1]*q1[1]-q2[2]*q1[2]-q2[3]*q1[3]-q2[4]*q1[4]
  q[2] = q2[1]*q1[2]+q2[2]*q1[1]+q2[3]*q1[4]-q2[4]*q1[3]
  q[3] = q2[1]*q1[3]-q2[2]*q1[4]+q2[3]*q1[1]+q2[4]*q1[2]
  q[4] = q2[1]*q1[4]+q2[2]*q1[3]-q2[3]*q1[2]+q2[4]*q1[1]
  return q
end

function R2rpy(R)
  local n = R:narrow(2, 1, 1)
  local o = R:narrow(2, 2, 1)
  local a = R:narrow(2, 3, 1)
  local rpy = torch.DoubleTensor(3):fill(0)
  rpy[3] = torch.cdiv(n[2], n[1])
  rpy[2] = torch.cdiv(-n[3], n[1]*math.cos(rpy[3])+n[2]*math.sin(rpy[3]))
  rpy[1] = torch.cdiv(a[1]*math.sin(rpy[3])-a[2]*math.cos(rpy[3]), 
                      -o[1]*math.sin(rpy[3])+o[2]*math.cos(rpy[3]))
  rpy:atan()
  return rpy
end


function rotX(theta)
  return torch.DoubleTensor({{1,               0,                0}, 
                             {0, math.cos(theta), -math.sin(theta)}, 
                             {0, math.sin(theta),  math.cos(theta)}})
end

function rotY(theta)
  return torch.DoubleTensor({{math.cos(theta), 0, math.sin(theta)},
                             {0,               1,               0}, 
                             {-math.sin(theta),0, math.cos(theta)}})
end

function rotZ(theta)
  return torch.DoubleTensor({{math.cos(theta), -math.sin(theta), 0},
                             {math.sin(theta), math.cos(theta), 0},
                             {0,               0,                1}})
end

function rpy2R(rpy)
  local Rz = torch.DoubleTensor(3,3):fill(0)
  local Ry = torch.DoubleTensor(3,3):fill(0)
  local Rx = torch.DoubleTensor(3,3):fill(0)
  local r = rpy[{1}]
  local p = rpy[{2}]
  local y = rpy[{3}]
  Rz = rotZ(y)
  Ry = rotY(p)
  Rx = rotX(r)
--  print(Rz)
--  print(Ry)
--  print(Rx)
  local R = torch.mm(Rz, Ry, Rx)
  return R
end

--q = torch.DoubleTensor({1, 0, 0, 0})
--print(Q2Vector(q))
--rpy = torch.DoubleTensor({math.pi, 0, 0})
--R = rpy2R(rpy)
--print(R)
--q = R2Quaternion(R)
--print(R2Quaternion(R))
--print(Quaternion2R(q))
--R = torch.DoubleTensor({{0.5, 0.6, 0},{0.3, 0.7, 0},{0, 0, 1}})
--print(q)
--R1 = Quaternion2R(q)
--print(R1)
--print(q:norm())

--q1 = torch.DoubleTensor({-0.2852, -0.1770, -0.6088, 0.7188})
--q2 = torch.DoubleTensor({1, -0.0020, 0.0008, 0.0010})
--q3 = QuaternionMul(q1, q2)
--print(q3)

--print(rotX(math.pi/3))
--print(rotY(math.pi/3))
--print(rotZ(math.pi/3))
--x = torch.DoubleTensor({-0.0020, 0.0008, 0.0010})
--y = torch.cmul(x, torch.ones(3):mul(0.0002))
--print(y)
--a = torch.DoubleTensor({{1},{2}, {3}})
--print(a)
--print(a * a:t())

function cholesky(A)
  -- http://rosettacode.org/wiki/Cholesky_decomposition
  local e = torch.symeig(A)
  for i = 1, e:size(1) do
    if e[i] < 0 then
      error('Not positive definite matrix')
    end
  end
  local m = A:size(1)
  local L = torch.DoubleTensor(A:size(1), A:size(1)):fill(0)
  for i = 1, m do
    for k = 1, i do
      local sum = 0
      for j = 1, k do
        sum = sum + L[i][j] * L[k][j]
      end
      if i == k then
        L[i][k] = math.sqrt(A[i][i] - sum)
      else
        L[i][k] = 1 / L[k][k] * (A[i][k] - sum)
      end
    end
  end
  return L
end

--A = torch.DoubleTensor({{ 0.1029,-0.0000, 0.0000, 0.0000,-0.0001, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000,0.0000, 0.0000},
--{-0.0000, 0.1029,-0.0000,-0.0001, 0.0001,-0.0000,-0.0000,-0.0000,-0.0000,-0.0000,-0.0000,0.0000},
--{ 0.0000,-0.0000, 0.1029, 0.0000,-0.0000, 0.0000,-0.1234,-0.1130,-0.1360, 0.0000,0.0000 ,0.0000},
--{ 0.0000,-0.0001, 0.0000, 0.1077,-0.0063, 0.0002, 0.0003, 0.0007, 0.0008, 0.0000,0.0000 ,0.0000},
--{-0.0001, 0.0001,-0.0000,-0.0063, 0.1114,-0.0003,-0.0004,-0.0010,-0.0011, 0.0000,0.0000 ,0.0000},
--{ 0.0000,-0.0000, 0.0000, 0.0002,-0.0003, 0.1029,-0.1233,-0.1129,-0.1359,-0.0000,-0.0000,0.0000},
--{ 0.0000,-0.0000,-0.1234, 0.0003,-0.0004,-0.1233, 1.8827, 0.5218, 0.6341,-0.0000,-0.0000,0.0000},
--{ 0.0000,-0.0000,-0.1130, 0.0007,-0.0010,-0.1129, 0.5218, 1.6979, 0.5205, 0.0012,0.0012 ,0.0000},
--{ 0.0000,-0.0000,-0.1360, 0.0008,-0.0011,-0.1359, 0.6341, 0.5205, 1.9113, 0.0013,0.0014 ,0.0000},
--{ 0.0000,-0.0000, 0.0000, 0.0000, 0.0000,-0.0000,-0.0000, 0.0012, 0.0013, 0.0978,-0.0018,0.0000},
--{ 0.0000,-0.0000, 0.0000, 0.0000, 0.0000,-0.0000,-0.0000, 0.0012, 0.0014,-0.0018,0.0292 ,0.0000},
--{ 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000,0.0000 ,0.0100}})
--print(A)
--a = torch.DoubleTensor({{2, -1, 0}, {-1, 2, -1}, {0,-1,2}})
--
----print(a)
----print(cholesky(A))
--print(cholesky(A))
--P = torch.eye(12, 12)
--posCov = torch.eye(3, 3):mul(0.0001)
--P:narrow(1, 1, 3):narrow(2, 1, 3):copy(posCov)
--velCov = torch.eye(3, 3):mul(0.0004)
--P:narrow(1, 4, 3):narrow(2, 4, 3):copy(velCov)
--qCov   = torch.eye(3, 3):mul(0.04)
--P:narrow(1, 7, 3):narrow(2, 7, 3):copy(qCov)
--omegaCov = torch.eye(3, 3):mul(0.0002)
--P:narrow(1, 10, 3):narrow(2, 10, 3):copy(omegaCov)
--print(P)
