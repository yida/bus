module(..., package.seeall);

require 'include'
require "shm"
require "util"
require "vector"

shared = {}
shsize = {}

shared.ukf = {}
shared.ukf.timestamp = vector.zeros(1)
shared.ukf.counter = vector.zeros(1)
shared.ukf.rpy = vector.zeros(3)
shared.ukf.trpy = vector.zeros(3)

util.init_shm_segment(getfenv(), 'ucm', shared, shsize, 1, 1);
