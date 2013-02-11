require 'torch-load'
--require 'gnuplot-load'
--
--require 'torch'

torch.Tensor = torch.DoubleTensor
y = torch.rand(5,4)
z = torch.DoubleTensor(5,5):ones(5,5)
print(y)
print(z)

gnuplot.figure(2)
