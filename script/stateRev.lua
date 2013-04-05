require 'include'
require 'common'
local unix = require 'unix'
local msgpack = require 'cmsgpack'
local simple_ipc = require 'simple_ipc'
local state_channel = simple_ipc.new_subscriber('state');

while true do
  local str = state_channel:receive()
  print(#str, unix.time())
end
