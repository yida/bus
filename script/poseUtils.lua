
function Quaternion2R(q)
  local n = q:norm()
  local nq = q:div(q:norm())
  local w = nq[1]
  local x = nq[2]
  local y = nq[3]
  local z = nq[4]
  local w2 = w * w
  local x2 = x * x
  local y2 = y * y
  local z2 = z * z
  local xy = x * y
  local xz = x * z
  local yz = y * z
  local wx = w * x
  local wy = w * y
  local wz = w * z
  local R = torch.DoubleTensor(3,3):fill(0)
  R[1][1] = w2 + x2 - y2 - z2
  R[2][1] = 2 * (wz + xy)
  R[3][1] = 2 * (xz - wy)
  R[1][2] = 2 * (xy - wz) 
  R[2][2] = w2 - x2 + y2 - z2 
  R[3][2] = 2 * (wx + yz)
  R[1][2] = 2 * (wy + xz)
  R[2][2] = 2 * (yz - wx) 
  R[3][2] = w2 - x2 - y2 + z2
--  print(R)
--  print(w2, x2, y2, z2)
  return R
end

function R2Quaternion(R)
  local q = torch.DoubleTensor(4)
  q[1] = math.sqrt(1 + R[1][1] + R[2][2] + R[3][3]) / 2 
  q[2] = (R[3][2] - R[2][3]) / (4 * q[1]) 
  q[3] = (R[1][3] - R[3][1]) / (4 * q[1]) 
  q[4] = (R[2][1] - R[1][2]) / (4 * q[1]) 
  return q
end

function QuaternionMul(q1, q2)  -- q = q1 x q2
  local q = torch.DoubleTensor(4)
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
  local R = torch.mm(Rz, Ry, Rx)
  return R
end


