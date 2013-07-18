require 'include'
require 'common'
local util = require 'util'

--local datasetpath = '../data/philadelphia/211212165622.00/'
local datasetpath = '../data/philadelphia/191212190259.60/'
local datasetpath = './'
local labelset = loadDataMP(datasetpath, 'labelMP')

for i = 1, #labelset do
  util.ptable(labelset[i])
end

--print(#labelset)
--local label_filter = {}
--for i = 1, #labelset do
--  if labelset[i].value ~= '00' then
--    label_filter[#label_filter + 1] = labelset[i]
--  end
--end
--print(#label_filter)
--
--saveDataMP(label_filter, 'labelPrunedMP', datasetpath)
