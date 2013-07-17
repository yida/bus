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
  return state, turns
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

local datasetpath = '../data/150213185940.20/'
local label = loadDataMP(datasetpath, 'labelNewCleanMP', _, 1)
--local state = loadDataMP(datasetpath, 'stateMP', _, 1)
--local state = loadDataMP(datasetpath, 'gpsLocalMP', _, 1)
local state = loadDataMP(datasetpath, 'imuPrunedCleanMP', _, 1)

--labelstamps = extractLabel(label)
labelstamps = labelconversion(label, false)
--imuwlabel = tstepApply(labelstamps, state)
--saveDataMP(imuwlabel, 'imuwlabelMP', datasetpath)
statewlabel, turns = applyLabel(state, labelstamps)
--saveDataMP(statewlabel, 'imuwlabelCleanMP', datasetpath)
--print(#labelstamps, #turns)
--
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
--


local turn_time = {}
turn_time[1] = 0
turn_time[2] = 0
local turn_time_count = {}
turn_time_count[1] = 0
turn_time_count[2] = 0

for i = 1, #turns do
--  print(turns[i].begintime, turns[i].endtime)
--  util.ptable(turns[i])
--  print(turns[i].endtime - turns[i].begintime)
--  print(turns[i].label)
  local label = turns[i].label
  turn_time[label] = turn_time[label] + (turns[i].endtime - turns[i].begintime)
  turn_time_count[label] = turn_time_count[label] + 1
end
print('mean time')
turn_time[1] = turn_time[1] / turn_time_count[1]
turn_time[2] = turn_time[2] / turn_time_count[2]
print(turn_time[1], turn_time[2])
--print(turn_time_count[1], turn_time_count[2])

local turn_mean = {}
turn_mean[1] = 0
turn_mean[2] = 0
local turn_mean_count = {}
turn_mean_count[1] = 0
turn_mean_count[2] = 0

for i = 1, #state do
  local ts = tonumber(state[i].timestamp)
  for t = 1, #turns do
    if ts >= tonumber(turns[t].begintime) and ts <= tonumber(turns[t].endtime) then
      local label = turns[t].label
      local ts_mid = (turns[t].begintime + turns[t].endtime) / 2
--      print('in turn', turns[t].label, state[i].wy)
      turn_mean[label] = turn_mean[label] + ts_mid - ts
      turn_mean_count[label] = turn_mean_count[label] + 1
    end
  end
end

print('mean')
turn_mean[1] = turn_mean[1] / turn_mean_count[1]
turn_mean[2] = turn_mean[2] / turn_mean_count[2]
print(turn_mean[1], turn_mean[2])

local turn_variance = {}
turn_variance[1] = 0
turn_variance[2] = 0

for i = 1, #state do
  local ts = tonumber(state[i].timestamp)
  for t = 1, #turns do
    if ts >= tonumber(turns[t].begintime) and ts <= tonumber(turns[t].endtime) then
      local ts_mid = (turns[t].begintime + turns[t].endtime) / 2
      local label = turns[t].label
      if label == 1 then
        turn_variance[label] = turn_variance[label] - 
                    (ts - ts_mid - turn_mean[label])^2 * state[i].wy
      else
        turn_variance[label] = turn_variance[label] + 
                    (ts - ts_mid - turn_mean[label])^2 * state[i].wy
      end
    end
  end
end
local turn_variance_count = {}
turn_variance_count[1] = turn_mean_count[1]
turn_variance_count[2] = turn_mean_count[2]
turn_variance[1] = turn_variance[1] / turn_variance_count[1]
turn_variance[2] = turn_variance[2] / turn_variance_count[2]
print('variance')
print(turn_variance[1], turn_variance[2])


-- local datasetpath = '../data/010213180304.00/'
-- local label = loadDataMP(datasetpath, 'labelCleanMP', _, 1)
-- --local state = loadDataMP(datasetpath, 'stateMP', _, 1)
-- --local state = loadDataMP(datasetpath, 'gpsLocalMP', _, 1)
-- local state = loadDataMP(datasetpath, 'imuPrunedCleanMP', _, 1)
-- 
-- labelstamps = labelconversion(label, false)
-- --imuwlabel = tstepApply(labelstamps, state)
-- --saveDataMP(imuwlabel, 'imuwlabelMP', datasetpath)
-- state, turns = applyLabel(state, labelstamps)

-- windows sliding
local label = 2
local ts_window = turn_time[label]
local fidx = 1
local bidx = 1
local not_at_end = true
while (fidx < #state) and not_at_end do
  bidx = fidx
  while state[bidx].timestamp < (state[fidx].timestamp + ts_window) do
    bidx = bidx + 1
    if bidx == #state then 
      not_at_end = false 
      break 
    end
  end
  -- print(fidx, bidx, bidx - fidx )
  local y_mean = 0
  local x_mean = turn_mean[label]
  for i = fidx, bidx do
    y_mean = y_mean + state[i].wy
  end
  y_mean = y_mean / (bidx - fidx + 1)
--  print(y_mean, x_mean)
  local e_xx = 0
  local e_yy = 0
  local e_xy = 0
  for i = fidx, bidx do
    local ts_mid = (state[fidx].timestamp + state[bidx].timestamp) / 2 
    local ts_x = ts_mid - state[i].timestamp
    local y = state[i].wy
    local miu = turn_mean[label]
    local var = turn_variance[label]
    local x = math.exp(-(ts_x - miu)^2/(2 * var)) / math.sqrt(var * 2 * math.pi)
    e_xx = e_xx + (x - x_mean)^2
    e_yy = e_yy + (y - y_mean)^2
    e_xy = e_xy + (x - x_mean) * (y - y_mean)
  end
  local r_xy = e_xy / math.sqrt(e_xx * e_yy)
  state[fidx].r_xy = r_xy

  fidx = fidx + 1
end

for i = 1, #state do
  if state[i].r_xy == nil then
    state[i].r_xy = 0
  end
end

saveDataMP(state, 'gau2MP', datasetpath)

--[[
local new_label = {}
for i = 1, #label do
  if math.abs(label[i].timestamp - 946686894.12) < 10 then
    print(label[i].value)
  else
    new_label[#new_label + 1] = label[i]
  end
end
saveDataMP(new_label, 'labelNewCleanMP', datasetpath)

--]]

local sync = loadDataMP(datasetpath, 'syncCowGPS2MP', _, 1)
local r_xy = 0
local sync_gps = {}
for i = 1, #sync do
  print(sync[i].type)
  if sync[i].r_xy then r_xy = sync[i].r_xy end
  if sync[i].type == 'gps' then
    sync[i].r_xy = r_xy
    sync_gps[#sync_gps + 1] = sync[i]
  end
end
saveCSV(sync_gps, 'syn_gps2', './')

