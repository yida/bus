require 'include'
require 'common'
require 'torch-load'

require 'matrixUtils'

local stateSet = {'leftTurn', 'rightTurn', 'Straight'}

--
--local dataPath = './'
--local trainSet = loadData(dataPath, 'obs')
--hmm = trainHMM(trainSet, stateSet)
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
