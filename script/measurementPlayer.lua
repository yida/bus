cwd = '../../UPennTHOR/'
Config = true
dofile('../../UPennTHOR/Run/include.lua')

require 'include2'
require 'common'
require 'poseUtils'
require 'torch'
require 'GPSUtils'

local util = require 'util'
local simple_ipc = require 'simple_ipc'
local msgpack = require 'cmsgpack'
local unix = require 'unix'

local test_channel = simple_ipc.setup_publisher('test')

local datasetpath = '../data/150213185940.20/'
--local datasetpath = '../data/010213180247/'
--local datasetpath = './'
local dataset = loadDataMP(datasetpath, 'measurementMP', _, 1)
--
for i = 1, #dataset do
  local mpstr = msgpack.pack(dataset[i])
  test_channel:send(mpstr)
  unix.usleep(1e6 * 0.05)
--  if dataset[i].type == 'label' then
--    if dataset[i].timestamp > 946686893.57 and dataset[i].timestamp < 946686897.74 then
--      print(dataset[i].timestamp, dataset[i].value)
--    else
--      newdataset[#newdataset+1] = dataset[i]
--    end 
--  end
--  i = i + 1
  io.stdout:flush()
end
