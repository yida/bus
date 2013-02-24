require 'include'
require 'common'

require 'torch-load'

local datasetpath = '../data/010213180247/'
--local datasetpath = '../data/'
--local datasetpath = '../data/dataset9/'
local magset = loadData(datasetpath, 'magPruned')

--magPruned = pruneTUC(magset)

--saveData(magPruned, 'magPruned')

--print(#magset)

function calibrateMagnetometer(magset)
  local sampleNum = 10000
  local divider = math.ceil(#magset / sampleNum)
  local Y = torch.DoubleTensor(sampleNum, 1):fill(0)
  local X = torch.DoubleTensor(sampleNum, 4):fill(1)
  
  local sampleCnt = 1
  for i = 1, #magset, divider do
    local mag = torch.DoubleTensor({magset[i].x, magset[i].y, magset[i].z})
    local magNorm = mag[1]^2 + mag[2]^2 + mag[3]^2
    Y[sampleCnt][1] = magNorm
    X:narrow(1, sampleCnt, 1):narrow(2, 1, 3):copy(mag)
    sampleCnt = sampleCnt + 1
  end
  
  local Beta = torch.inverse(X:t() * X) * X:t() * Y
  local V = torch.DoubleTensor(3):copy(Beta:narrow(1,1,3) / 2)
  local B = torch.sqrt(Beta[4] * Beta[4] + V[1] * V[1] + V[2] * V[2] + V[3] * V[3])
  local P = (Y - X * Beta):t() * (Y - X * Beta)
  local M = sampleNum
  local epsi = torch.sqrt(P / M)
  epsi:div(2 * B * B)
  print('Calibration fit')
  print(epsi)
  
  print('V - hard iron offset')
  print(V)
  print('Geomagnetic field strength')
  print(B)
  return V, B
end


