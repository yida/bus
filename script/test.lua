require 'torch-load'
--require 'gnuplot-load'
--
--require 'torch'
local ffi = require 'ffi'

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

print(d[0])
print(type(tble))
x:string()
--torch.Tensor = torch.DoubleTensor
--y = torch.rand(5,4)
--z = torch.DoubleTensor(5,5):ones(5,5)
--print(y)
--print(z)
--
--gnuplot.figure(2)
