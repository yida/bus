require 'ukfBaseSimple'
require 'ucm'

local datasetpath = '../project3/figure8/'
local dataset = loadData(datasetpath, 'gesture5')

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



counter = 0
for i = 1, #dataset do
  if dataset[i].type == 'imu' then
    local ret = processUpdate(dataset[i].timestamp, dataset[i])
    if ret == true then measurementGravityUpdate() end
  end

  processInit = imuInit
  if processInit then 
    print(state)
--    error('stop for debugging') 
    local Q = state:narrow(1, 7, 4)
    counter = counter + 1 
  
    q = vector.new({Q[1][1], Q[2][1], Q[3][1], Q[4][1]})
    pos = vector.new({state[1][1], state[2][1], state[3][1]})
    ucm.set_ukf_counter(counter)
    ucm.set_ukf_quat(q)
    ucm.set_ukf_pos(pos)
  --  print(state:narrow(1, 1, 6))
  end

end
