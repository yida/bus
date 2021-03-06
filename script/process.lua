require 'include'
require 'common'
local util = require 'util'

--local datasetpath = '../data/philadelphia/211212165622.00/'
local datasetpath = '../data/philadelphia/191212190259.60/'
local datasetpath = '../data/philadelphia/150213185940.20/'
local datasetpath = '../data/philadelphia/010213180304.00/'
local labelset = loadDataMP(datasetpath, 'labelMP')

print(#labelset)
local label_filter = {}
for i = 1, #labelset do
  if labelset[i].value ~= '00' or labelset[i].value ~= '0000' then
    label_filter[#label_filter + 1] = labelset[i]
  end
end
print(#label_filter)

saveDataMP(label_filter, 'labelPrunedMP', datasetpath)
