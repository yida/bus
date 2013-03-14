require 'include'
require 'common'
require 'torch-load'

require 'matrixUtils'
require 'labelUtils'
require 'hmmBase'

local stateSet = {'leftTurn', 'rightTurn', 'Straight'}

local datasetpath = '../data/150213185940/'
local label = loadData(datasetpath, 'label', _, 1)
local state = loadData(datasetpath, 'state150213185940', _, 1)

labelstamps = extractLabel(label)
obs = applyLabel(state, labelstamps)
obsSeq = splitObservation(obs)

--trainSet = obsSeq[1]
--for i = 1, #obsSeq[1] do
--  print(obsSeq[1][i].label, obsSeq[1][i].prelabel)
--end
ObsSetNum = #obsSeq
print('num of training sets '..#obsSeq)
ObsSetIdx = torch.randperm(ObsSetNum)
trainSetRatio = 0.7
trainSetNum = math.floor(trainSetRatio * ObsSetNum)
testSetNum = ObsSetNum - trainSetNum
print('train set '..trainSetNum, 'test set '..testSetNum)
-- Generate new train set
local trainSet = {}
local nTrain = 0
for i = 1, trainSetNum do
  print(ObsSetIdx[i], #obsSeq[ObsSetIdx[i]])
  nTrain = nTrain + #obsSeq[ObsSetIdx[i]]
  for j = 1, #obsSeq[ObsSetIdx[i]] do
    trainSet[#trainSet+1] = obsSeq[ObsSetIdx[i]][j]
  end
end
print(#trainSet, nTrain)

-- training
hmm = trainHMM(trainSet, stateSet)
--ForwardBackward(hmm, testSet, stateSet)

-- testing
for i = 1, testSetNum do
  print(ObsSetIdx[i+trainSetNum], #obsSeq[ObsSetIdx[i+trainSetNum]])
  testSet = obsSeq[ObsSetIdx[i+trainSetNum]]
  p, st = viterbi(hmm, testSet, stateSet)
end

--local dataPath = '../test/'
--for i = 1, 7 do
--  local testSet = loadData(dataPath, 'state'..string.format('%02d', i))
--  p, st = viterbi(hmm, testSet, stateSet)
--  print(stateSet[st], p)
--end
----x = torch.Tensor({-1.1299, -0.8433, 1.0718})
----print(GaussianPDF(x, hmm.pobsMean:narrow(2, 1, 1), hmm.pobsCov:narrow(1, 1, 1)))
--
