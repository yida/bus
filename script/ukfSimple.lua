require 'ukfBaseSimple'
require 'ucm'
require 'include'
require 'common'
local serialization = require('serialization');

function imuCorrent(imu, Bias)
  local ac = torch.Tensor(3, 1):copy(-Bias)
  ac[1] = ac[1] + imu.ax
  ac[2] = ac[2] + imu.ay
  ac[3] = ac[3] + imu.az
  local gyr = torch.Tensor(3, 1):fill(0)
  gyr[1] = imu.wx
  gyr[2] = imu.wy
  gyr[3] = imu.wz

  return ac, gyr
end

local dirSet = {'circle', 'figure8', 'hammer', 'slash', 'toss', 'wave'}

for dir = 1, #dirSet do
  local dataPath = '../project3/'..dirSet[dir]..'/'
  local gestureFileList = assert(io.popen('/bin/ls '..dataPath..'gesture*'))
  local gestureFileNum = 0
  for line in gestureFileList:lines() do
    gestureFileNum = gestureFileNum + 1
  end
  
  for nfile = 1, gestureFileNum do 
    local dataset = loadData(dataPath, 'gesture'..string.format('%02d', nfile))
    
    counter = 0
    sdata = {}
    local tstep = 0
    for i = 1, #dataset do
      if dataset[i].type == 'imu' then
        local ret = processUpdate(dataset[i].timestamp, dataset[i])
        tstep = dataset[i].timestamp
        if ret == true then measurementGravityUpdate() end
      end
    
      processInit = imuInit
      if processInit then 
    --    print(state)
        local Q = state:narrow(1, 7, 4)
        local vec = Quat2Vector(Q)
        st = {['x'] = state[1][1], ['y'] = state[2][1], ['z'] = state[3][1],
              ['vx'] = state[4][1], ['vy'] = state[5][1], ['vz'] = state[6][1],
              ['e1'] = vec[1], ['e2'] = vec[2], ['e3'] = vec[3]}
        st['type'] = 'state'
        st['timestamp'] = tstep
        sdata[#sdata + 1] = st
    --    error('stop for debugging') 
    --    local Q = state:narrow(1, 7, 4)
    --    counter = counter + 1 
    --  
    --    q = vector.new({Q[1][1], Q[2][1], Q[3][1], Q[4][1]})
    --    pos = vector.new({state[1][1], state[2][1], state[3][1]})
    --    ucm.set_ukf_counter(counter)
    --    ucm.set_ukf_quat(q)
    --    ucm.set_ukf_pos(pos)
      --  print(state:narrow(1, 1, 6))
      end
    
    end
    
    saveData(sdata, 'state'..string.format('%02d', nfile), dataPath)
  end
end
