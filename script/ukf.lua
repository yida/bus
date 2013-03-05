require 'ukfBase'

require 'ucm'

local datasetpath = '../data/010213180247/'
--local datasetpath = '../data/010213192135/'
--local datasetpath = '../data/rawdata/'
--local datasetpath = '../simulation/'
--local datasetpath = '../data/'
--local datasetpath = '../'
--local dataset = loadData(datasetpath, 'logall')
--local dataset = loadData(datasetpath, 'log')
--local dataset = loadData(datasetpath, 'imuPruned')
--local dataset = loadData(datasetpath, 'imuPruned', 10000)
--local dataset = loadData(datasetpath, 'imugpsmag', 20000)
local dataset = loadData(datasetpath, 'imugpsmag')
--local dataset = loadData(datasetpath, 'imuPruned')
--local dataset = loadData(datasetpath, 'log-946684824.42841')
--local dataset = loadData(datasetpath, 'log-946684824.46683')
--local dataset = loadData(datasetpath, 'log-946684824.66965')
--local dataset = loadData(datasetpath, 'log-946684834.63068')
--local dataset = loadData(datasetpath, 'log-946684836.76822')

counter = 0
for i = 1, #dataset do
  if dataset[i].type == 'imu' then
    local ret = processUpdate(dataset[i].timstamp, dataset[i])
    if ret == true then measurementGravityUpdate() end
  elseif dataset[i].type == 'gps' then
    measurementGPSUpdate(dataset[i])
  elseif dataset[i].type == 'mag' then
    measurementMagUpdate(dataset[i])
  end

  processInit = imuInit and magInit and gpsInit
  if processInit then 
--    print(state)
--    error('stop for debugging') 
    local Q = state:narrow(1, 7, 4)
    counter = counter + 1 
  
    q = vector.new({Q[1][1], Q[2][1], Q[3][1], Q[4][1]})
    pos = vector.new({state[1][1], state[2][1], state[3][1]})
--    v1 = vector.new({trpy[1][1], trpy[2][1], trpy[3][1]})
    ucm.set_ukf_counter(counter)
    ucm.set_ukf_quat(q)
    ucm.set_ukf_pos(pos)
  --  print(state:narrow(1, 1, 6))
  end

end
