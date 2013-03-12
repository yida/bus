require 'include'
require 'common'
require 'torch-load'


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

function GaussianPDF(x, mean, cov)
  local vectorSize = x:size(1)
  local Diff = torch.Tensor(vectorSize,1):copy(x - mean)
  local Cov = torch.Tensor(vectorSize, vectorSize):copy(cov)
  print(Diff:t() * torch.inverse(Cov) * Diff)
  print(torch.exp((Diff:t() * torch.inverse(Cov) * Diff):mul(-0.5)))
  local exp = torch.exp((Diff:t() * torch.inverse(Cov) * Diff):mul(-0.5))
  print(Cov)
  print(Cov:norm())
  local const = (2 * math.pi)^(-vectorSize/2) / torch.sqrt(Cov:norm())
  print(const)
  
end

local stateSet = {'circle', 'figure8', 'hammer', 'slash', 'toss', 'wave'}

local dataPath = '../project3/'
local trainSet = loadData(dataPath, 'observation')

hmm = trainHMM(trainSet, stateSet)

x = torch.Tensor({-1.1299, -0.8433, 1.0718})
GaussianPDF(x, hmm.pobsMean:narrow(2, 1, 1), hmm.pobsCov:narrow(1, 1, 1))
