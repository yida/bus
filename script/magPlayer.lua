require 'include'
require 'common'
require 'poseUtils'
require 'magUtils'
require 'imuUtils'
require 'torch'
local util = require 'util'

local datasetpath = '../data/150213185940.20/'
--local datasetpath = '../data/010213180247/'
--local dataset = loadDataMP(datasetpath, 'imuPrunedMP', _, 1)
local dataset = loadDataMP(datasetpath, 'measurementMP', _, 1)

accBias = torch.DoubleTensor({0, 0, 0})
rawacc = torch.DoubleTensor(3, 1):fill(0)
gyro = torch.DoubleTensor(3, 1):fill(0)


local mags = {}
local j = 0
for i = 1, #dataset do
  if dataset[i].type == 'mag' then
--    util.ptable(dataset[i])
    j = j + 1
--    if j > 25 then error() end
    local rawmag = magCorrect(dataset[i])
    -- calibrated & tilt compensated heading 
    local heading, Bf = magTiltCompensate(rawmag, rawacc)
    local mag = {}
    mag.timestamp = dataset[i].timestamp
    mag.heading = heading
    mags[#mags+1] = mag
--    print(j, dataset[i].timestamp, heading)
    local rpy = torch.DoubleTensor({0, 0, -heading})
    local Q = rpy2Quat(rpy)
--    util.ptorch(Q)
--    error()
  elseif dataset[i].type == 'imu' then
    rawacc, gyro = imuCorrent(dataset[i], accBias)
  end
end

print(#mags)
saveDataMP(mags, 'headingMP', './')
