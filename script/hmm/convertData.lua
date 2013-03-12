require 'include'
require 'common'
local serialization = require('serialization');

function convertImuTime(dataPath)
  local imuFileList = assert(io.popen('/bin/ls '..dataPath..'imu*'))
  local timeFileList = assert(io.popen('/bin/ls '..dataPath..'time*'))
  local imuFileNum = 0
  local timeFileNum = 0
  for line in imuFileList:lines() do
    imuFileNum = imuFileNum + 1
  end
  for line in timeFileList:lines() do
    timeFileNum = timeFileNum + 1
  end
  -- imu and time should have same number of files
  assert(imuFileNum == timeFileNum)
  
  AccSen = 330
  GyrSen = 3.44
  
  local fileNum = (imuFileNum + timeFileNum) / 2
  for nfile = 1, fileNum do
    print('Gesture Set: '..nfile)
    imuFile = assert(io.open(dataPath..'imu_'..string.format('%02d', nfile), 'r'))
    timeFile = assert(io.open(dataPath..'time_'..string.format('%02d', nfile), 'r'))
    -- read imu file
    local imu = {}
    local imucounter = 0
    for line in imuFile:lines() do
      vals=string.gmatch(line, "%d+")
      imucounter = imucounter + 1
      imu[imucounter] = {}
      imu[imucounter]['ax'] = tonumber(vals())
      imu[imucounter]['ay'] = tonumber(vals())
      imu[imucounter]['az'] = tonumber(vals())
      imu[imucounter]['wx'] = tonumber(vals())
      imu[imucounter]['wy'] = tonumber(vals())
      imu[imucounter]['wz'] = tonumber(vals())
      io.write('\r'..line)
    end
    io.write('\n')
    -- read time file
    local imucounter = 0
    for line in timeFile:lines() do
      imucounter = imucounter + 1
      imu[imucounter]['timestamp'] = tonumber(line)
      io.write('\r'..line)
    end
    io.write('\n')
    local imuMean = {0, 0, 0, 0, 0, 0}
    for i = 1, #imu do
      imuMean[1] = imuMean[1] + imu[i].ax / #imu
      imuMean[2] = imuMean[2] + imu[i].ay / #imu
      imuMean[3] = imuMean[3] + imu[i].az / #imu
      imuMean[4] = imuMean[4] + imu[i].wx / #imu
      imuMean[5] = imuMean[5] + imu[i].wy / #imu
      imuMean[6] = imuMean[6] + imu[i].wz / #imu
    end
    for i = 1, #imu do
      -- Substract bias and multiply gain
      imu[i].ax = (imu[i].ax - imuMean[1]) * 3300 / 1023 / AccSen
      imu[i].ay = (imu[i].ay - imuMean[2]) * 3300 / 1023 / AccSen
      imu[i].az = (imu[i].az - imuMean[3]) * 3300 / 1023 / AccSen
      imu[i].wx = (imu[i].wx - imuMean[4]) * 3300 / 1023 / GyrSen * math.pi / 180
      imu[i].wy = (imu[i].wy - imuMean[5]) * 3300 / 1023 / GyrSen * math.pi / 180
      imu[i].wz = (imu[i].wz - imuMean[6]) * 3300 / 1023 / GyrSen * math.pi / 180
      imu[i]['type'] = 'imu'
    end
  
    saveData(imu, 'gesture'..string.format('%02d', nfile), dataPath)
  end


end

--local dirSet = {'circle', 'figure8', 'hammer', 'slash', 'toss', 'wave'}
--for dir = 1, #dirSet do
--  local dataPath = '../project3/'..dirSet[dir]..'/'
--  convertImuTime(dataPath)
--end
--
local dataPath = '../test/'
convertImuTime(dataPath)

