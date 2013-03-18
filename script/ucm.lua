
require 'include'
require "shm"
local util = require "util"
require "vector"

local ucm = {}
ucm.shared = {}
ucm.shsize = {}
local shared = ucm.shared
local shsize = ucm.shsize

shared.ukf = {}
shared.ukf.timestamp = vector.zeros(1)
shared.ukf.counter = vector.zeros(1)
shared.ukf.rpy = vector.zeros(3)
shared.ukf.quat = vector.zeros(4)
shared.ukf.trpy = vector.zeros(3)
shared.ukf.pos = vector.zeros(3)
shared.ukf.magheading = vector.zeros(1)

shared.gps = {}
shared.gps.counter = vector.zeros(1)
shared.gps.pos = vector.zeros(3)

shared.label = {}
shared.label.counter = vector.zeros(1)
shared.label.value = vector.zeros(1)

util.init_shm_segment(ucm, 'ucm', shared, shsize, 1, 1);

return ucm
