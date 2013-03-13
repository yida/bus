require 'ukfBase'

require 'ucm'

require 'include'
require 'common'
local serialization = require('serialization');


--local datasetpath = '../data/010213180247/'
--local datasetpath = '../data/010213192135/'
--local datasetpath = '../data/191212190259/'
--local datasetpath = '../data/211212164337/'
--local datasetpath = '../data/211212165622/'
--local datasetpath = '../data/rawdata/'
--local datasetpath = '../simulation/'
local datasetpath = '../data/'
--local datasetpath = '../'
--local dataset = loadData(datasetpath, 'logall')
--local dataset = loadData(datasetpath, 'imugpsmag')
--local dataset = loadData(datasetpath, 'imuPruned')
--local dataset = loadData(datasetpath, 'log-946684824.42841')
--local dataset = loadData(datasetpath, 'log-946684824.46683')
--local dataset = loadData(datasetpath, 'log-946684824.66965')
local dataset = loadData(datasetpath, 'log-946684834.63068', _, 1)
--local dataset = loadData(datasetpath, 'log-946684836.76822')


--local Path = path or './'
--local dtype = 'state'
--local filecnt = 0
--local filetime = os.date('%m.%d.%Y.%H.%M.%S')
--local filename = string.format(dtype.."-%s-%d", filetime, filecnt)
--
--local file = io.open(Path..filename, "w")
 

local sdata = {}
local counter = 0
local kCount = 0
local t1 = utime()
for i = 1, #dataset do
  tstep = dataset[i].timstamp or dataset[i].timestamp
  if dataset[i].type == 'imu' then
    local ret = processUpdate(tstep, dataset[i])
    if ret == true then measurementGravityUpdate() end
  elseif dataset[i].type == 'gps' then
    measurementGPSUpdate(dataset[i])
  elseif dataset[i].type == 'mag' then
    measurementMagUpdate(dataset[i])
  end
--  magInit = true
  processInit = imuInit and magInit and gpsInit
--  processInit = imuInit and gpsInit
  if processInit then 
    if kCount ~= KGainCount then
--      print(1/(utime() - t1))
      t1 = utime()
      print(KGainCount)
      kCount = KGainCount
--      local Q = state:narrow(1, 7, 4)
--      local vec = Quat2Vector(Q)
--      st = {['x'] = state[1][1], ['y'] = state[2][1], ['z'] = state[3][1],
--            ['vx'] = state[4][1], ['vy'] = state[5][1], ['vz'] = state[6][1],
--            ['e1'] = vec[1], ['e2'] = vec[2], ['e3'] = vec[3], 
--            ['type'] = 'state', ['timestamp'] = tstep}
--      saveData = serialization.serialize(st)
--      print(saveData)
--      file:write(saveData)
--      file:write('\n')
  --    sdata[#sdata + 1] = st
   
  --    error('stop for debugging') 
      local Q = state:narrow(1, 7, 4)
      counter = counter + 1 
    
      q = vector.new({Q[1][1], Q[2][1], Q[3][1], Q[4][1]})
      --pos = vector.new({state[1][1], state[2][1], state[3][1]})
      if gpspos ~= nil then
        pos = vector.new({gpspos[1], gpspos[2], gpspos[3]})
        ucm.set_ukf_counter(counter)
        ucm.set_ukf_quat(q)
        ucm.set_ukf_pos(pos)
      end
    --  print(state:narrow(1, 1, 6))
    end
  end
end

--file:close()
--saveData(sdata, 'state', dataPath)

