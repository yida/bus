require 'ukfBase'
require 'include'
require 'common'
local msgpack = require 'cmsgpack'
local simple_ipc = require 'simple_ipc'
local test_channel = simple_ipc.new_subscriber('test');
local state_channel = simple_ipc.new_publisher('state');

while true do
  local str = test_channel:receive()
  data = msgpack.unpack(str)
  tstep = data.timstamp or data.timestamp
  if data.type == 'imu' then
    local ret = processUpdateRot(tstep, data)
    if ret == true then measurementGravityUpdate() end
  elseif data.type == 'gps' then
    if data.nspeed ~= nil then
      processUpdatePos(tstep, data)
    end
    measurementGPSUpdate(data)
  elseif data.type == 'mag' then
    measurementMagUpdate(data)
  end
  gpsInit = true
  processInit = imuInit and magInit and gpsInit
  if processInit then
    print(KGainCount)
    local st = {}
    local Q = state:narrow(1, 7, 4)
    local vec = Quat2Vector(Q)
    st = {['x'] = state[1][1], ['y'] = state[2][1], ['z'] = state[3][1],
          ['vx'] = state[4][1], ['vy'] = state[5][1], ['vz'] = state[6][1],
          ['q0'] = state[7][1], ['q1'] = state[8][1], ['q2'] = state[9][1], ['q3'] = state[10][1],
          ['e1'] = vec[1], ['e2'] = vec[2], ['e3'] = vec[3],
          ['type'] = 'state', ['timestamp'] = tstep}
    st.counter = KGainCount
    state_channel:send(msgpack.pack(st))
  end
end
