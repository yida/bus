cwd = '../../UPennTHOR/'
Config = true
dofile('../../UPennTHOR/Run/include.lua')

require 'ukfBase'

require 'include2'
require 'common'
local msgpack = require 'cmsgpack'
local simple_ipc = require 'simple_ipc'

local test_channel = simple_ipc.setup_subscriber('test');

while true do
  local str = test_channel:receive()
  data = msgpack.unpack(str)
  print(data.type)
  tstep = data.timstamp or data.timestamp
  if data.type == 'imu' then
    local ret = processUpdate(tstep, data)
    if ret == true then measurementGravityUpdate() end
  elseif data.type == 'gps' then
    measurementGPSUpdate(data)
  elseif data.type == 'mag' then
    measurementMagUpdate(data)
  end
  processInit = imuInit and magInit and gpsInit

end
