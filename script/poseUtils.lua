require 'torch-load'

function QCompare(q1, q2)
  local e1 = Q2Vector(q1)
  local e2 = Q2Vector(q2)
--  print(e1:norm())
--  print(e2:norm())
  return math.abs(e1:norm() - e2:norm())
end

function Vector2Q(w, dt)
--  print(w)
  local dq = torch.DoubleTensor(4):fill(0)
  if w:norm() < 1e-6 then
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
  local rt = q[1]^2 + q[2]^2 + q[3]^2 + q[4]^2
--  print(rt)
  return torch.DoubleTensor({q[1]/rt, -q[2]/rt,
                            -q[3]/rt, -q[4]/rt})
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

function QuaternionMul2(Q1, Q2)
  local q = torch.DoubleTensor(4)
  local q1 = torch.DoubleTensor(4):copy(Q1)
  local q2 = torch.DoubleTensor(4):copy(Q2)
  q[1] = q2[1]*q1[1]-q2[2]*q1[2]-q2[3]*q1[3]-q2[4]*q1[4]
  q[2] = q2[1]*q1[2]+q2[2]*q1[1]+q2[3]*q1[4]-q2[4]*q1[3]
  q[3] = q2[1]*q1[3]-q2[2]*q1[4]+q2[3]*q1[1]+q2[4]*q1[2]
  q[4] = q2[1]*q1[4]+q2[2]*q1[3]-q2[3]*q1[2]+q2[4]*q1[1]
  return q
end

function QuaternionMul(Q1, Q2)  -- q = q1 x q2
  local q = torch.DoubleTensor(4)
  local q1 = torch.DoubleTensor(4):copy(Q1)
  local q2 = torch.DoubleTensor(4):copy(Q2)
  local a1 = q1[1]
  local b1 = q1[2]
  local c1 = q1[3]
  local d1 = q1[4]
  local a2 = q2[1]
  local b2 = q2[2]
  local c2 = q2[3]
  local d2 = q2[4]
  q[1] = a1*a2 - b1*b2 - c1*c2 - d1*d2
  q[2] = a1*b2 + b1*a2 + c1*d2 - d1*c2
  q[3] = a1*c2 - b1*d2 + c1*a2 + d1*b2
  q[4] = a1*d2 + b1*c2 - c1*b2 + d1*a2
  return q
end

function R2rpy(R)
  -- http://planning.cs.uiuc.edu/node102.html
  local y = math.atan2(R[2][1], R[1][1])
  local p = math.atan2(-R[3][1], math.sqrt(R[3][2]^2+R[3][3]^2))
  local r = math.atan2(R[3][2], R[3][3])
  local rpy = torch.DoubleTensor({r, p, y})
  return rpy
end

function rpy2Quaternion(rpyin)
  return R2Quaternion(rpy2R(rpyin))
end

function Quaternion2rpy(Qin)
  local q = torch.DoubleTensor(4):copy(Qin)
  local rpy = torch.DoubleTensor(3):fill(0)
  rpy[1] = math.atan2(2*(q[1]*q[2]+q[3]*q[4]), 1-2*(q[2]*q[2]+q[3]*q[3]))
  rpy[2] = math.asin(2*(q[1]*q[3]-q[4]*q[2]))
  rpy[3] = math.atan2(2*(q[1]*q[4]+q[2]*q[3]), 1-2*(q[3]*q[3]+q[4]*q[4]))
  return rpy
end

function rotX(gamma)
  -- http://planning.cs.uiuc.edu/node102.html
  local R = torch.DoubleTensor(3,3):fill(0)
  R[2][2] = cos(gamma)
  R[3][2] = sin(gamma) 
  R[1][1] = 1
  R[2][3] = -sin(gamma)
  R[3][3] = cos(gamma)
  return R
end

function rotY(beta)
  -- http://planning.cs.uiuc.edu/node102.html
  local R = torch.DoubleTensor(3,3):fill(0)
  R[1][1] = cos(beta)
  R[1][3] = sin(beta) 
  R[2][2] = 1
  R[3][1] = -sin(beta)
  R[3][3] = cos(beta)
  return R
end

function rotZ(alpha)
  -- http://planning.cs.uiuc.edu/node102.html
  local R = torch.DoubleTensor(3,3):fill(0)
  R[1][1] = cos(alpha)
  R[2][1] = sin(alpha)
  R[1][2] = -sin(alpha)
  R[2][2] = cos(alpha)
  R[3][3] = 1
  return R
end

function rpy2R(rpy)
  -- http://planning.cs.uiuc.edu/node102.html
  local R = torch.DoubleTensor(3,3):fill(0)
  local alpha = rpy[3]
  local beta = rpy[2]
  local gamma = rpy[1]
  R[1][1] = math.cos(alpha) * math.cos(beta)
  R[2][1] = math.sin(alpha) * math.cos(beta)
  R[3][1] = -math.sin(beta)
  R[1][2] = math.cos(alpha) * math.sin(beta) * math.sin(gamma) - math.sin(alpha) * math.cos(gamma)
  R[2][2] = math.sin(alpha) * math.sin(beta) * math.sin(gamma) + math.cos(alpha) * math.cos(gamma)
  R[3][2] = math.cos(beta) * math.sin(gamma)
  R[1][3] = math.cos(alpha) * math.sin(beta) * math.cos(gamma) + math.sin(alpha) * math.sin(gamma)
  R[2][3] = math.sin(alpha) * math.sin(beta) * math.cos(gamma) - math.cos(alpha) * math.sin(gamma)
  R[3][3] = math.cos(beta) * math.cos(gamma)

--  local r = rpy[1]
--  local p = rpy[2]
--  local y = rpy[3]
--  Rz = rotZ(y)
--  Ry = rotY(p)
--  Rx = rotX(r)
--  local R = Rz * Ry * Rz
  return R
end

function pdcheck(A)
--  print(A)
  local e = torch.symeig(A)
  for i = 1, e:size(1) do
    if math.abs(e[i]) < 1e-6 then e[i] = 0; end
    if e[i] < 0 then
      error('Not positive definite matrix'.."("..i..","..e[i]..")")
    end
  end
end
function cholesky(A)
  -- http://rosettacode.org/wiki/Cholesky_decomposition
  pdcheck(A)
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


function QuaternionMean(QMax, qInit)
--  print(QMax, qInit)
  local qIter = torch.DoubleTensor(4):copy(qInit)
  local e = torch.DoubleTensor(3, QMax:size(2)):fill(0)
  local iter = 0
  local diff = 0
--  for i = 1, 10 do
  repeat
    iter = iter + 1
    for i = 1, QMax:size(2) do
      local ei = e:narrow(2, i, 1):fill(0)
      local qi = QMax:narrow(2, i, 1)
      local eQ = QuaternionMul(qi, QInverse(qIter))
      ei:copy(Q2Vector(eQ))
    end
    local eMean = torch.mean(e,2)
    local qIterNext = QuaternionMul(Vector2Q(eMean), qIter)
    diff = QCompare(qIterNext, qIter)
    qIter:copy(qIterNext)
  until diff < 0.0001
--  print(qIter)
--  end
  return qIter, e
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
--q = torch.DoubleTensor({1, 0, 0, 0})
--print(Q2Vector(q))
--rpy = torch.DoubleTensor({-math.pi, 0, -0.05})
--R = rpy2R(rpy)
--print(R)
----q = R2Quaternion(R)
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
--rpy1 = {17}
--q1 = torch.DoubleTensor({1,0,1,0})
--q2 = torch.DoubleTensor({1,0.5,0.5,0.75})
--print(QInverse(q1))
--print(QuaternionMul(q1, q2))
--print(QuaternionMul2(q1, q2))
rpy1 = torch.DoubleTensor({178*math.pi/180, 0,0})
q1 = R2Quaternion(rpy2R(rpy1))
rpy2 = torch.DoubleTensor({180*math.pi/180, 0,0})
q2 = R2Quaternion(rpy2R(rpy2))
print(q1)
print(q2)
print(QuaternionMul(q1, q2))
--rpy3 = torch.DoubleTensor({179.21*math.pi/180, 0,0})
--q3 = R2Quaternion(rpy2R(rpy3))
----print(q1, q2)
--Q = torch.DoubleTensor(4, 2)
--Q:narrow(2, 1, 1):copy(q1)
--Q:narrow(2, 2, 1):copy(q2)
--print(Q)
--print('mean')
--y, e = QuaternionMean(Q, q3)
--print(y)
--print(R2rpy(Quaternion2R(y)))

--rpyr = R2rpy(Quaternion2R(q1))
--rpyr = rpyr * 180 / math.pi
--print(rpyr)
--rpy4 = torch.DoubleTensor({math.pi, 0, math.pi/3})
--rpy4 = torch.DoubleTensor({-3.07, -0.06, -0.18})
--print(rpy4)
----print(R4)
--q4 = rpy2Quaternion(rpy4)
--print(q4)
--print(Quaternion2rpy(q4))
--print(q2)
--print(Quaternion2rpy(rpy2Quaternion(rpy4)))

