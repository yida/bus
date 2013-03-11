require 'include'
require 'common'
require 'syncData'

local serialization = require('serialization');

local dirSet = {'circle', 'figure8', 'hammer', 'slash', 'toss', 'wave'}

function mergeAll()
  local set1 = {}
  for dir = 1, #dirSet do
  --for dir = 1, 1 do
    local dataPath = '../project3/'..dirSet[dir]..'/'
    local gestureFileList = assert(io.popen('/bin/ls '..dataPath..'state*'))
    local gestureFileNum = 0
    for line in gestureFileList:lines() do
      gestureFileNum = gestureFileNum + 1
    end
  
    for nfile = 1, gestureFileNum do 
      set2 = loadData(dataPath, 'state'..string.format('%02d', nfile))
      -- add label
      for i = 1, #set2 do
        set2[i].label = dir
        set2[i].labelTag = dirSet[dir]
      end
      data = syncData(_, set1, set2)
      set1 = data
    end
  end
  
  saveData(data, 'observationAll', './')
end

mergeAll()

dataset = loadData('./', 'observationAll')
dataset[1].prelabel = -1
for i = 2, #dataset do
  dataset[i].prelabel = dataset[i-1].label
end

saveData(dataset, 'observation', './')

