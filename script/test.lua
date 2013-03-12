require 'torch-load'
--require 'gnuplot-load'
--
--require 'torch'
local ffi = require 'ffi'
require 'poseUtils'

state = torch.DoubleTensor(13, 1):fill(0)
--print(state)
P = torch.eye(12):mul(1000)
Q = torch.eye(12):mul(90)
--print(torch.sqrt((P + Q):mul(2*12)))
x = P:storage()
for i = 1, x:size() do
  x[i] = i
end
tble = x:totable()
local d = ffi.cast('double*', x:pointer())

x = torch.Tensor({{1,2,3},{2,3,4},{3,4,1}})
--x = torch.Tensor({{2.5056, 1.2905, 1.4870},
--{1.2905, 0.8665, 0.5052},
--{1.4870, 0.5052, 1.8278}})
lu = torch.lu(x)
print(lu)
local d = torch.det(x)
print(d)


A = torch.Tensor({{0.1622,   0.6020,   0.4505,   0.8258,   0.1067},
   {0.7943,   0.2630,   0.0838,   0.5383,   0.9619},
   {0.3112,   0.6541,   0.2290,   0.9961,   0.0046},
   {0.5285,   0.6892,   0.9133,   0.0782,   0.7749},
   {0.1656,   0.7482,   0.1524,   0.4427,   0.8173}})
print(torch.det(A))
--print(d[0])
--print(type(tble))
--x:string()
--torch.Tensor = torch.DoubleTensor
--y = torch.rand(5,4)
--z = torch.DoubleTensor(5,5):ones(5,5)
--print(y)
--print(z)
--
--gnuplot.figure(2)
