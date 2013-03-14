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

trainSet = obsSeq[1]

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
