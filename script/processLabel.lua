require 'include'
require 'common'
require 'poseUtils'
require 'torch-load'

local util = require 'util'

function extractLabel(dataset, Debug)
  local debug = Debug or false
  local state = {}
  local lastlabel = ''
  local labelstamps = {}
  for i = 1, #dataset do
    if dataset[i].type == 'label' then
      local label = dataset[i].value
      local st = dataset[i]
      local time = string.format('%10f', st.timestamp)
      local init = ''
      if label == '1000' or label == '0010' then
        if label == lastlabel then
          init = ''
        else
          init = 'start '..label..' '
          local stamp = {['st'] = time, ['et'] = time}
          if label == '1000' then stamp.label = 1 end
          if label == '0010' then stamp.label = 2 end
          labelstamps[#labelstamps + 1] = stamp
        end
      end
      labelstamps[#labelstamps].et = time
      lastlabel = label
      if label == '1000' or label == '0100' then
        if debug then print(time, init..'left turn '..label) end
      elseif label == '0010' or label == '0001' then
        if debug then print(time, init..'right turn '..label) end
      end
    end
  end
  
  for i = 1, #labelstamps do
    if debug then print('turn '..string.format('%02d',i)..' start at '
                  ..labelstamps[i].st, 'end at '..labelstamps[i].et) end
  end
  
  return labelstamps
end

function applyLabel(state, lstamps)
  for i = 1, #state do
    local ts = state[i].timestamp
    local label = 3 -- go straight
    for lidx = 1, #lstamps do
      if tonumber(ts) >= tonumber(lstamps[lidx].st) and tonumber(ts) <= tonumber(lstamps[lidx].et) then
        label = lstamps[lidx].label
      end
    end
    state[i].label = label
  end
  return state
end

function splitObservation(obs)
  local obsSeq = {}
  local lastLabel = obs[1].label
  local lastLabelstart = 1
  obsSeq[#obsSeq+1] = {}
  obsSeq[#obsSeq].sidx = 1
  obsSeq[#obsSeq].label = obs[1].label
  obsSeq[#obsSeq].sts = obs[1].timestamp
  for i = 2, #obs do 
    if obs[i].label ~= lastLabel then
      obsSeq[#obsSeq].eidx = i - 1
      obsSeq[#obsSeq].ets = obs[i].timestamp
--      print(lastLabel, lastLabelstart, i-1)
      lastLabelstart = i
      obsSeq[#obsSeq+1] = {}
      obsSeq[#obsSeq].sidx = i
      obsSeq[#obsSeq].label = obs[i].label
      obsSeq[#obsSeq].sts = obs[i].timestamp
      lastLabel = obs[i].label
    end
  end
  obsSeq[#obsSeq].eidx = #obs
  obsSeq[#obsSeq].ets = obs[#obs].timestamp
  print(lastLabel, lastLabelstart, #obs)
  print('\n')
  for i = 1, #obsSeq do
    print('label '..obsSeq[i].label, obsSeq[i].sidx, 
            obsSeq[i].eidx, obsSeq[i].sts, obsSeq[i].ets)
  end
end

local datasetpath = '../data/150213185940/'
local label = loadData(datasetpath, 'label', _, 1)
local state = loadData(datasetpath, 'state150213185940', _, 1)

labelstamps = extractLabel(label)
obs = applyLabel(state, labelstamps)
splitObservation(obs)

--saveData(obs, 'obs', './')
