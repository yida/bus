require 'include'
require 'common'
require 'torch-load'

require 'matrixUtils'

function trainHMM(trainSet, stateSet)
  local stateNum = #stateSet
  print 'Train initial probability'
  local pinit = torch.Tensor(stateNum, 1):fill(0)
  for i = 1, #trainSet do 
    local label = trainSet[i].label
    pinit[label][1] = pinit[label][1] + 1
  end
  pinit:div(#trainSet)
  
  
  print 'Train transition probability'
  local ptrans = torch.Tensor(stateNum, stateNum):fill(0)
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
  local obsDim = 3
  local pobsMean = torch.Tensor(obsDim, stateNum):fill(0)
  local pobsMeanCount = torch.Tensor(1, stateNum):fill(0)
  local pobsCov = torch.Tensor(stateNum, obsDim, obsDim):fill(0)
  local pobsCovCount = torch.Tensor(1, stateNum):fill(0)
  
  -- observation Mean
  for i = 1, #trainSet do 
    local obs = torch.Tensor({trainSet[i].e1, trainSet[i].e2, trainSet[i].e3})
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
    local obs = torch.Tensor({{trainSet[i].e1, trainSet[i].e2, trainSet[i].e3}})
    local label = trainSet[i].label
    local prevLabel = trainSet[i].prelabel 
    local obsCov = (obs - pobsMean:narrow(2, label, 1)):t() * (obs - pobsMean:narrow(2, label, 1))
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

function ForwardBackward(hmm, testSet, stateSet)
  local stateNum = #stateSet
  local alpha = torch.Tensor(stateNum, 1):fill(0)
  local pobs = torch.Tensor(stateNum, 1):fill(0)
  for i = 1, #testSet do
    local obs = torch.Tensor({testSet[i].e1, testSet[i].e2, testSet[i].e3})
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
    print(alpha)
  end
  local pObsGamma = 0
  for st = 1, stateNum do
    pObsGamma = pObsGamma + alpha[st][1]
  end
end

function viterbi(hmm, testSet, stateSet)
  local stateNum = #stateSet
  local delta = torch.Tensor(stateNum, 1):fill(0)
  local psi = torch.Tensor(stateNum, 1):fill(0)
  local pobs = torch.Tensor(stateNum, 1):fill(0)
  for i = 1, #testSet do
    local obs = torch.Tensor({testSet[i].e1, testSet[i].e2, testSet[i].e3})
    for st = 1, stateNum do
      pobs[st][1] = GaussianPDF(obs, hmm.pobsMean:narrow(2, st, 1), 
                                  hmm.pobsCov:narrow(1, st, 1))
      if i == 1 then
        delta[st][1] = hmm.pinit[st][1] * pobs[st][1]
      else
        local newDelta = torch.Tensor(stateNum, 1):fill(0)
        for preSt = 1, stateNum do
          newDelta[preSt][1] = delta[st][1] * hmm.ptrans[preSt][st]
        end
        maxDelta, i = torch.max(newDelta, 1)
        delta[st][1] = maxDelta * pobs[st][1]
        psi[st][1] = i
      end
    end
    delta:div(delta:norm())
  end
  local maxDelta, q = torch.max(delta, 1)
  return maxDelta, q[1][1]
--  local pObsGamma = 0
--  for st = 1, stateNum do
--    pObsGamma = pObsGamma + alpha[st][1]
--  end
end

local stateSet = {'leftTurn', 'rightTurn', 'Straight'}

local dataPath = './'
local trainSet = loadData(dataPath, 'obs')
hmm = trainHMM(trainSet, stateSet)
--ForwardBackward(hmm, testSet, stateSet)


--local dataPath = '../test/'
--for i = 1, 7 do
--  local testSet = loadData(dataPath, 'state'..string.format('%02d', i))
--  p, st = viterbi(hmm, testSet, stateSet)
--  print(stateSet[st], p)
--end
----x = torch.Tensor({-1.1299, -0.8433, 1.0718})
----print(GaussianPDF(x, hmm.pobsMean:narrow(2, 1, 1), hmm.pobsCov:narrow(1, 1, 1)))
--
