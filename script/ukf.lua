require 'ukfBase'

require 'include'
require 'common'
local simple_ipc = require 'simple_ipc'
local mp = require 'MessagePack'

local state_channel = simple_ipc.setup_publisher('state');

--local datasetpath = '../data/010213180247/'
--local datasetpath = '../data/010213192135/'
--local datasetpath = '../data/191212190259/'
--local datasetpath = '../data/211212164337/'
--local datasetpath = '../data/211212165622/'
local datasetpath = '../data/150213185940.20/'
--local datasetpath = '../data/'
--local datasetpath = '../'
local dataset = loadDataMP(datasetpath, 'measurementMP')

local sendState = false
local saveState = true
if saveState then
  local Path = path or './'
  local dtype = 'stateMP'
  local filecnt = 0
  local filetime = os.date('%m.%d.%Y.%H.%M.%S')
  local filename = string.format(dtype.."-%s-%d", filetime, filecnt)
  
  file = io.open(Path..filename, "wb")
end 


local sdata = {}
local counter = 0
local kCount = 0
local t1 = utime()
for i = 1, #dataset do
  tstep = dataset[i].timstamp or dataset[i].timestamp
  if tstep > 946685120.97 then error() end
  if dataset[i].type == 'imu' then
    local ret = processUpdate(tstep, dataset[i])
    if ret == true then measurementGravityUpdate() end
  elseif dataset[i].type == 'gps' then
    measurementGPSUpdate(dataset[i])
  elseif dataset[i].type == 'mag' then
--    measurementMagUpdate(dataset[i])
  end
  magInit = true
--  processInit = imuInit and magInit and gpsInit
  processInit = imuInit and gpsInit
  if processInit then 
--    if kCount ~= KGainCount then
--      print(1/(utime() - t1))
--      t1 = utime()
--        print(KGainCount)
        kCount = KGainCount      
      if saveState then
        local Q = state:narrow(1, 7, 4)
        local vec = Quat2Vector(Q)
        st = {['x'] = state[1][1], ['y'] = state[2][1], ['z'] = state[3][1],
              ['vx'] = state[4][1], ['vy'] = state[5][1], ['vz'] = state[6][1],
              ['e1'] = vec[1], ['e2'] = vec[2], ['e3'] = vec[3], 
              ['type'] = 'state', ['timestamp'] = tstep}
        saveData = mp.pack(st)
        file:write(saveData)
  --    sdata[#sdata + 1] = st
      end
   
    if sendState then
      local st = {}
      local Q = state:narrow(1, 7, 4)
      local vec = Quat2Vector(Q)
      st = {['x'] = state[1][1], ['y'] = state[2][1], ['z'] = state[3][1],
            ['vx'] = state[4][1], ['vy'] = state[5][1], ['vz'] = state[6][1],
            ['e1'] = vec[1], ['e2'] = vec[2], ['e3'] = vec[3], 
            ['type'] = 'state', ['timestamp'] = tstep}
      st.counter = counter
      state_channel:send(mp.pack(st))
    end
  end
end

if saveState then
  file:close()
end

