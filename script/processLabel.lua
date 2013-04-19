require 'include'
require 'common'
require 'poseUtils'
require 'torch'

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
    --[[ -- debug 
      if label == '1000' or label == '0100' then
        if debug then print(time, init..'left turn '..label) end
      elseif label == '0010' or label == '0001' then
        if debug then print(time, init..'right turn '..label) end
      end
    --]]
    end
  end
  
  for i = 1, #labelstamps do
    if debug then print('turn '..string.format('%02d',i)..' start at '
                  ..labelstamps[i].st, 'end at '..labelstamps[i].et) end
  end
  
  return labelstamps
end

function labelconversion(dataset, PairCheck)
  local labelstamps = {}
  local paircheck = PairCheck or false
  for i = 1, #dataset do
    local label = dataset[i].value
    local lstamp = {}
    lstamp.timestamp = dataset[i].timestamp or dataset[i].timstamp
    if label:find('1000') then lstamp.label = 1 
    elseif label:find('0100') then lstamp.label = 2
    elseif label:find('0010') then lstamp.label = 3
    elseif label:find('0001') then lstamp.label = 4
    end
    labelstamps[#labelstamps+1] = lstamp
  end
  -- pair check
  if paircheck then
    local lastLabel = 0
    local labelInit = false
    for i = 1, #labelstamps do
      if not labelInit then
        labelInit = true
        lastLabel = labelstamps[i].label
      else
        if lastLabel == 1 then
          if labelstamps[i].label == 3 or labelstamps[i].label == 4 then
            error('not match pair')
          end
        end
        if lastLabel == 3 then
          if labelstamps[i].label == 1 or labelstamps[i].label == 2 then
            error('not match pair')
          end
        end
  --      print(labelstamps[i].label, lastLabel)
        lastLabel = labelstamps[i].label
      end
    end
  end
  return labelstamps
end

function applyLabel(state, lstamps)
  local inturn = false
  local nturn = 0
  local turns = {}
  for i = 1, #lstamps do
    local turn = {}
    if not inturn and (lstamps[i].label == 1 or lstamps[i].label == 3) then

      if turns[#turns] then 
        turns[#turns].endtime = lstamps[i-1].timestamp
        print('close turn', nturn, lstamps[i-1].timestamp)
      end

      nturn = nturn + 1
      turn.begintime = lstamps[i].timestamp
      if lstamps[i].label == 1 then turn.label = 1;
      elseif lstamps[i].label == 3 then turn.label = 2; end

      turns[#turns+1] = turn
      print('open turn', nturn, i, lstamps[i].timestamp) 
      inturn = true
    end

    if inturn and (lstamps[i].label == 2 or lstamps[i].label == 4) then
      inturn = false
    end

  end
  turns[#turns].endtime = lstamps[#lstamps].timestamp
  print 'check turning starting and ending time'
  for i = 1, #turns do
    print(turns[i].begintime, turns[i].endtime)
  end

  for i = 1, #state do
    local ts = state[i].timestamp
    state[i].label = 3 -- in default use label 3 as straight
    for iturn = 1, #turns do
      if tonumber(ts) >= tonumber(turns[iturn].begintime) and tonumber(ts) <= tonumber(turns[iturn].endtime) then
        state[i].label = turns[iturn].label
      end
    end
    if state[i-1] then 
      state[i].prelabel = state[i-1].label
    else
      state[i].prelabel = -1
    end
  end
  return state
end

function splitObservation(obs, Debug)
  local debug = Debug or false
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
  if debug then 
    print(lastLabel, lastLabelstart, #obs)
    print('\n')
  end
  for i = 1, #obsSeq do
    if debug then print('label '..obsSeq[i].label, obsSeq[i].sidx, 
            obsSeq[i].eidx, obsSeq[i].sts, obsSeq[i].ets) end
    for j = obsSeq[i].sidx, obsSeq[i].eidx do
      local idx = j - obsSeq[i].sidx + 1
      obsSeq[i][idx] = obs[j]
    end
    assert((obsSeq[i].eidx - obsSeq[i].sidx + 1) == #obsSeq[i])
  end
end

function tstepApply(setFrom, setTo)
  print(#setFrom, #setTo)
--  for i = 1, #setFrom do
--    print(setFrom[i].timestamp)
--  end
  print(setFrom[1].timestamp, setTo[1].timestamp)
  print(setFrom[#setFrom].timestamp, setTo[#setTo].timestamp)
  for i = 1, #setTo do
    local tstep = setTo[i].timestamp
    for j = 1, #setFrom do
      if math.abs(setFrom[j].timestamp - tstep) < 0.5 then
        print('find match')
        setTo[i].label = setFrom[j].label
        break
      end
    end
    if setTo[i].label then
      print(tstep, setTo[i].label)
    else
      setTo[i].label = 0
    end
  end
  return setTo
end

local datasetpath = '../data/010213180304.00/'
local label = loadDataMP(datasetpath, 'labelMP', _, 1)
--local state = loadDataMP(datasetpath, 'stateMP', _, 1)
--local state = loadDataMP(datasetpath, 'gpsLocalMP', _, 1)
local state = loadDataMP(datasetpath, 'imuPrunedMP', _, 1)

--labelstamps = extractLabel(label)
labelstamps = labelconversion(label, false)
imuwlabel = tstepApply(labelstamps, state)
saveDataMP(imuwlabel, 'imuwlabelMP', datasetpath)
--statewlabel = applyLabel(state, labelstamps)
--[[
for i = 1, #statewlabel do
  if statewlabel[i].label ~= 3 and statewlabel[i].label ~= statewlabel[i].prelabel then
    print(statewlabel[i].label, statewlabel[i].prelabel)
  end
end
saveDataMP(statewlabel, 'imuwlabelMP', './')
--]]

--obs = applyLabel(state, labelstamps)
--obsSeq = splitObservation(obs)
--saveDataMP(obs, 'imuwlabelBinaryMP', datasetpath)
