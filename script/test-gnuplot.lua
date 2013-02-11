local pwd = os.getenv('PWD')

package.path = pwd..'/lua/?/init.lua;'..package.path

require 'gnuplot'
