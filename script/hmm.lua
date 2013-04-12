require 'include'
require 'common'
require 'torch-load'

require 'matrixUtils'
require 'labelUtils'
require 'hmmBase'

local stateSet = {'leftTurn', 'rightTurn', 'Straight'}

local datasetpath = '../data/150213185940.20/'
local trainSet = loadDataMP(datasetpath, 'imuwlabelMP', _, 1)

--print(#trainSet)
hmm = trainDiscreteHMM(trainSet, stateSet)
alpha = ForwardBackwardDiscrete(hmm, trainSet, stateSet)

print('sync testing data')
for i = 1, #trainSet do
  trainSet[i].alpha = alpha[i]
end
saveDataMP(trainSet, 'yawtestMP', './')


--local datasetpath = '../data/150213185940/'
--local label = loadData(datasetpath, 'label', _, 1)
--local state = loadData(datasetpath, 'state150213185940', _, 1)
--
--labelstamps = extractLabel(label)
--obs = applyLabel(state, labelstamps)
--obsSeq = splitObservation(obs)
--
--ObsSetNum = #obsSeq
--print('num of training sets '..#obsSeq)
--ObsSetIdx = torch.randperm(ObsSetNum)
----ObsSetIdx = torch.Tensor({9, 10, 30, 19, 36, 34,  4, 28, 15, 12, 26, 1, 33, 27, 32, 29, 17, 23, 18, 22, 20, 7, 5, 35, 24, 25, 13, 14, 3, 2, 31,  6, 21, 37, 16, 11,  8})
--trainSetRatio = 0.7
--trainSetNum = math.floor(trainSetRatio * ObsSetNum)
--testSetNum = ObsSetNum - trainSetNum
--print('train set '..trainSetNum, 'test set '..testSetNum)
---- Generate new train set
--local trainSet = {}
--local nTrain = 0
--for i = 1, trainSetNum do
--  print(i, ObsSetIdx[i], #obsSeq[ObsSetIdx[i]], obsSeq[ObsSetIdx[i]].label)
--  nTrain = nTrain + #obsSeq[ObsSetIdx[i]]
--  for j = 1, #obsSeq[ObsSetIdx[i]] do
--    trainSet[#trainSet+1] = obsSeq[ObsSetIdx[i]][j]
--  end
--end
--print(#trainSet, nTrain)
----
------ training
--hmm = trainHMM(trainSet, stateSet)
----print(hmm)
--print(hmm.ptrans)
--------ForwardBackward(hmm, testSet, stateSet)
------
------ testing
--for i = 1, testSetNum do
----for i = 1, 1 do
--  print('test set id:'..i + trainSetNum, 'Samples: '..#obsSeq[ObsSetIdx[i+trainSetNum]], 
--         'label state: '..obsSeq[ObsSetIdx[i+trainSetNum]].label)
--  testSet = obsSeq[ObsSetIdx[i+trainSetNum]]
--  p, st = viterbi(hmm, testSet, stateSet)
--  print('detected state: '..st)
----  print(obsSeq[ObsSetIdx[i+trainSetNum]].label)
--end

--local dataPath = '../test/'
--for i = 1, 7 do
--  local testSet = loadData(dataPath, 'state'..string.format('%02d', i))
--  p, st = viterbi(hmm, testSet, stateSet)
--  print(stateSet[st], p)
--end
----x = torch.Tensor({-1.1299, -0.8433, 1.0718})
----print(GaussianPDF(x, hmm.pobsMean:narrow(2, 1, 1), hmm.pobsCov:narrow(1, 1, 1)))
--
