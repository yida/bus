require 'torch-load'
--require 'gnuplot-load'
--
--require 'torch'

P = torch.eye(12):mul(1000)
Q = torch.eye(12):mul(90)
print(torch.sqrt((P + Q):mul(2*12)))
--torch.Tensor = torch.DoubleTensor
--y = torch.rand(5,4)
--z = torch.DoubleTensor(5,5):ones(5,5)
--print(y)
--print(z)
--
--gnuplot.figure(2)
