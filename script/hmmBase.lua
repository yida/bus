require 'include'
require 'common'
require 'torch'
local util = require 'util'
require 'matrixUtils'

function trainDiscreteHMM(trainSet, stateSet)
  local stateNum = #stateSet
  print 'Train initial probability'
  local pinit = torch.DoubleTensor(stateNum, 1):fill(0)
  for i = 1, #trainSet do 
    local label = trainSet[i].label
    pinit[label][1] = pinit[label][1] + 1
  end
  pinit:div(#trainSet)
  
  print 'Train transition probability'
  local ptrans = torch.DoubleTensor(stateNum, stateNum):fill(0)
  for i = 1, #trainSet do 
    local label = trainSet[i].label
    local preLabel = trainSet[i].prelabel
    if preLabel ~= -1 then
      ptrans:narrow(1, preLabel, 1):narrow(2, label, 1):add(1)
    end
  end
  for i = 1, stateNum do
    local row = ptrans:narrow(1, i, 1)
    local rowSum = row:sum()
    row:div(rowSum)
  end

  print'Train Observation Probability'
  local obsDim = 3 -- number of discrete observations
  local pobs = torch.DoubleTensor(obsDim, stateNum):fill(0)
  local pobsCount = torch.DoubleTensor(1, stateNum):fill(0)
  for i = 1, #trainSet do
    pobs[trainSet[i].bwy + obsDim - 1][trainSet[i].label] = 
               pobs[trainSet[i].bwy + obsDim - 1][trainSet[i].label] + 1
    pobsCount[1][trainSet[i].label] = pobsCount[1][trainSet[i].label] + 1
  end
  for i = 1, stateNum do
    pobs:narrow(2, i, 1):div(pobsCount[1][i])
  end
 
  hmm = {}
  hmm.pinit = pinit
  hmm.ptrans = ptrans
  hmm.pobs = pobs

  return hmm
end

function trainHMM(trainSet, stateSet)
  local stateNum = #stateSet
  print 'Train initial probability'
  local pinit = torch.DoubleTensor(stateNum, 1):fill(0)
  for i = 1, #trainSet do 
    local label = trainSet[i].label
    pinit[label][1] = pinit[label][1] + 1
  end
  pinit:div(#trainSet)
  
  print 'Train transition probability'
  local ptrans = torch.DoubleTensor(stateNum, stateNum):fill(0)
  for i = 1, #trainSet do 
    local label = trainSet[i].label
    local preLabel = trainSet[i].prelabel
    if preLabel ~= -1 then
      ptrans:narrow(1, preLabel, 1):narrow(2, label, 1):add(1)
    end
  end
  
  for i = 1, stateNum do
    local row = ptrans:narrow(1, i, 1)
    local rowSum = row:sum()
    row:div(rowSum)
  end
  
  print'Train Observation Probability'
  local obsDim = 1
--  local obsDim = 9
  local pobsMean = torch.DoubleTensor(obsDim, stateNum):fill(0)
  local pobsMeanCount = torch.DoubleTensor(1, stateNum):fill(0)
  local pobsCov = torch.DoubleTensor(stateNum, obsDim, obsDim):fill(0)
  local pobsCovCount = torch.DoubleTensor(1, stateNum):fill(0)
  
  -- observation Mean
  for i = 1, #trainSet do 
--    local obs = torch.DoubleTensor({trainSet[i].x, trainSet[i].y, trainSet[i].z,
--                              trainSet[i].vx, trainSet[i].vy, trainSet[i].vz,
--                              trainSet[i].e1, trainSet[i].e2, trainSet[i].e3})
    local obs = torch.DoubleTensor({trainSet[i].wy})

    local label = trainSet[i].label
    local prevLabel = trainSet[i].prelabel
    pobsMean:narrow(2, label, 1):add(obs)
    pobsMeanCount[1][label] = pobsMeanCount[1][label] + 1
  
  end
  
  for i = 1, stateNum do
    pobsMean:narrow(2, i, 1):div(pobsMeanCount[1][i])
  end
  
  -- observation Cov
  for i = 1, #trainSet do
    local obs = torch.DoubleTensor({trainSet[i].wy})
    obs:resize(obs:size(1), 1)
    local label = trainSet[i].label
    local prevLabel = trainSet[i].prelabel 
    local obsCov = (obs - pobsMean:narrow(2, label, 1)) * (obs - pobsMean:narrow(2, label, 1)):t()
    pobsCov:narrow(1, label, 1):add(obsCov)
    pobsCovCount[1][label] = pobsCovCount[1][label] + 1
  end
  
  for i = 1, stateNum do
    pobsCov:narrow(1, i, 1):div(pobsCovCount[1][i])
  end

  hmm = {}
  hmm.pinit = pinit
  hmm.ptrans = ptrans
  hmm.pobsMean = pobsMean
  hmm.pobsCov = pobsCov

  return hmm
end

function ForwardBackwardDiscrete(hmm, testSet, stateSet)
  local stateNum = #stateSet
  local alpha = torch.DoubleTensor(stateNum, 1):fill(0)
  local alphaSet = {}
  local obsDim = 3
  for i = 1, #testSet do
    local obs = testSet[i].bwy
    for st = 1, stateNum do
      if i == 1 then
        alpha[st][1] = hmm.pinit[st][1] * hmm.pobs[obs + obsDim - 1][st]
      else
        local transP = 0
        for preSt = 1, stateNum do
          transP = transP + alpha[preSt][1] * hmm.ptrans[preSt][st]
        end
        alpha[st][1] = transP * hmm.pobs[obs + obsDim - 1][st]
      end
    end
    alpha:div(alpha:norm())

    local alphaTbl = {}
    local pObsGamma = 0
    for st = 1, stateNum do
      alphaTbl[st] = alpha[st][1]
      pObsGamma = pObsGamma + alpha[st][1]
    end
    alphaSet[#alphaSet + 1] = alphaTbl
  end
  return alphaSet
end

function ForwardBackward(hmm, testSet, stateSet)
  local stateNum = #stateSet
  local alpha = torch.DoubleTensor(stateNum, 1):fill(0)
  local pobs = torch.DoubleTensor(stateNum, 1):fill(0)
  local alphaSet = {}
  for i = 1, #testSet do
    local obs = torch.DoubleTensor({testSet[i].wy})
    for st = 1, stateNum do
      pobs[st][1] = GaussianPDF(obs, hmm.pobsMean:narrow(2, st, 1), 
                                  hmm.pobsCov:narrow(1, st, 1))
      if i == 1 then
        alpha[st][1] = hmm.pinit[st][1] * pobs[st][1]
      else
        local transP = 0
        for preSt = 1, stateNum do
          transP = transP + alpha[preSt][1] * hmm.ptrans[preSt][st]
        end
        alpha[st][1] = transP * pobs[st][1]
      end
    end
    alpha:div(alpha:norm())

    local alphaTbl = {}
    local pObsGamma = 0
    for st = 1, stateNum do
      alphaTbl[st] = alpha[st][1]
      pObsGamma = pObsGamma + alpha[st][1]
    end
    alphaSet[#alphaSet + 1] = alphaTbl
  end
  return alphaSet
end

function viterbi(hmm, testSet, stateSet)
  local stateNum = #stateSet
  local delta = torch.DoubleTensor(stateNum, 1):fill(0)
  local psi = torch.DoubleTensor(stateNum, 1):fill(0)
  local pobs = torch.DoubleTensor(stateNum, 1):fill(0)
  for i = 1, #testSet do
    local obs = torch.DoubleTensor({testSet[i].e1, testSet[i].e2, testSet[i].e3})
--    local obs = torch.DoubleTensor({testSet[i].x, testSet[i].y, testSet[i].z,
--                              testSet[i].vx, testSet[i].vy, testSet[i].vz,
--                              testSet[i].e1, testSet[i].e2, testSet[i].e3})
--  print 'state'
    for st = 1, stateNum do
      pobs[st][1] = GaussianPDF(obs, hmm.pobsMean:narrow(2, st, 1), 
                                  hmm.pobsCov:narrow(1, st, 1))
      if i == 1 then
        delta[st][1] = hmm.pinit[st][1] * pobs[st][1]
      else
        local newDelta = torch.DoubleTensor(stateNum, 1):fill(0)
        for preSt = 1, stateNum do
          newDelta[preSt][1] = delta[st][1] * hmm.ptrans[preSt][st]
        end
--      print(newDelta)
        local maxDelta, idx = torch.max(newDelta, 1)
        delta[st][1] = maxDelta * pobs[st][1]
        psi[st][1] = idx
      end
--    print(st, delta[st][1], psi[st][1])
--      print(delta)
    end
--    print(delta)
    delta:div(delta:norm())
  end
  local maxD, q = torch.max(delta, 1)
  return maxD, q[1][1]
end

--local stateSet = {'circle', 'figure8', 'hammer', 'slash', 'toss', 'wave'}
--
--local dataPath = '../project3/'
--local trainSet = loadData(dataPath, 'observation')
--hmm = trainHMM(trainSet, stateSet)
----ForwardBackward(hmm, testSet, stateSet)
--
--
--local dataPath = '../test/'
--for i = 1, 7 do
--  local testSet = loadData(dataPath, 'state'..string.format('%02d', i))
--  p, st = viterbi(hmm, testSet, stateSet)
--  print(stateSet[st], p)
--end
----x = torch.DoubleTensor({-1.1299, -0.8433, 1.0718})
----print(GaussianPDF(x, hmm.pobsMean:narrow(2, 1, 1), hmm.pobsCov:narrow(1, 1, 1)))
--
