function readImuLine(str, len, labeloffset)
  local cutil = require 'cutil'
  local carray = require 'carray'
  local imu = {}
  if labeloffset > 0 then
    label = {}
    label.type = 'label'
    label.timestamp = tonumber(str:sub(1, 16))
    label.value = str:sub(17,18)
  end
  imu.type = 'imu'
  imu.timestamp = tonumber(string.sub(str, 1, 16))
  ls = 16 + labeloffset

  imu.tuc = cutil.bit_or(str:byte(ls + 1), 
                        cutil.bit_lshift(str:byte(ls + 2), 8), 
                        cutil.bit_lshift(str:byte(ls + 3), 16), 
                        cutil.bit_lshift(str:byte(ls + 4), 24));
  imu.id = str:byte(ls + 5)
  imu.cntr = str:byte(ls + 6)
--  print(imu.tuc, imu.id, imu.cntr);
  rpyGain = 5000
  r = carray.short({cutil.bit_or(cutil.bit_lshift(str:byte(ls +  8), 8), 
                    str:byte(ls +  7))})
--    print(r[1])
  imu.r =  carray.short({cutil.bit_or(cutil.bit_lshift(str:byte(ls +  8), 8), str:byte(ls +  7))})[1] / rpyGain
  imu.p =  carray.short({cutil.bit_or(cutil.bit_lshift(str:byte(ls + 10), 8), str:byte(ls +  9))})[1] / rpyGain
  imu.y =  carray.short({cutil.bit_or(cutil.bit_lshift(str:byte(ls + 12), 8), str:byte(ls + 11))})[1] / rpyGain
--  print(imu.r, imu.p, imu.y)
  wrpyGain = 500
  imu.wr =  carray.short({cutil.bit_or(cutil.bit_lshift(str:byte(ls + 14), 8), str:byte(ls + 13))})[1] / wrpyGain
  imu.wp =  carray.short({cutil.bit_or(cutil.bit_lshift(str:byte(ls + 16), 8), str:byte(ls + 15))})[1] / wrpyGain
  imu.wy =  carray.short({cutil.bit_or(cutil.bit_lshift(str:byte(ls + 18), 8), str:byte(ls + 17))})[1] / wrpyGain
--  print(imu.wr, imu.wp, imu.wy)
  accGain = 5000
  imu.ax =  carray.short({cutil.bit_or(cutil.bit_lshift(str:byte(ls + 20), 8), str:byte(ls + 19))})[1] / accGain
  imu.ay =  carray.short({cutil.bit_or(cutil.bit_lshift(str:byte(ls + 22), 8), str:byte(ls + 21))})[1] / accGain
  imu.az =  carray.short({cutil.bit_or(cutil.bit_lshift(str:byte(ls + 24), 8), str:byte(ls + 23))})[1] / accGain
--  print(imu.ax, imu.ay, imu.az)
--  error()
  return imu, label
end

function checkData(imu)
  -- check time stamp, not readable or not reasonable
  -- unix time between 01012000, 00:00:00 to 01012000, 23:00:00
  if imu.timstamp == nil then return false end
  if imu.timstamp < 946684800 or imu.timstamp > 946767600 then return false end
  return true
end

local pattern = '%d%d%d%d%d%d%d%d%d%.%d%d%d%d%d%d'
function iterateIMU(data, xmlroot, labeloffset)
  local imuset = {}
  local labelset = {}
  local labeloffset = labeloffset or 0
  local imucounter = 0
--  for i = 0, 0 do -- data.FileNum - 1 do
  for i = 0, data.FileNum - 1 do
    local fileName = data.Path..data.Type..data.Stamp..i
    print(fileName)
    local file = assert(io.open(fileName, 'r+'))
    local line = file:read("*a");
    local lastlfpos = string.find(line, pattern, 1)
    if lastlfpos == nil then break; end
    local lfpos = string.find(line, pattern, lastlfpos + 1)
    while lfpos ~= nil do
      local len = lfpos - lastlfpos - 1
      local substr = string.sub(line, lastlfpos, lfpos-1)
--      print(len, labeloffset)
      if len == (40 + labeloffset) then
--        print(#substr, substr)
        imu, label = readImuLine(substr, len, labeloffset)
        local datacheck = checkData(imu)
        local tdata = os.date('*t', imu.timestamp)
--        print(substr:byte(1, #substr))
--        print(imucounter, string.format('%16f',imu.timestamp), imu.tuc, imu.r, imu.p, imu.y, imu.wr, imu.wp, imu.wy, imu.ax, imu.ay, imu.az)
--        print(imu.timstamp, tdata.year, tdata.month, tdata.day, tdata.hour, tdata.min, tdata.sec)
        imucounter = imucounter + 1
        imuset[imucounter] = imu
        if label then
          labelset[#labelset + 1] = label
        end
      end 
      lastlfpos = lfpos
      lfpos = string.find(line, pattern, lastlfpos + 1)
    end
    file:close();
  end
  return imuset, labelset
end

function parseIMU(labeloffset)
  local data = loadRawData(dataPath, dataStamp, 'imu')
  imuset, labelset = iterateIMU(data, _, labeloffset)

  return imuset, labelset
end

