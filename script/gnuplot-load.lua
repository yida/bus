local pwd = os.getenv('PWD')

package.path = pwd..'/torch/lua/?/init.lua;'..package.path
package.path = pwd..'/torch/lua/?.lua;'..package.path
package.cpath = pwd..'/torch/?.so;'..package.cpath

function include(file, depth)
  local torchPackagePath = 'torch/lua/gnuplot/'
  dofile(torchPackagePath..file)
end

require 'gnuplot'