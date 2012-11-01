MEX_EXT = $(shell mexext)
include common.mk

TARGETS : kBotPacketAPI.$(MEX_EXT) SerialDeviceAPI.$(MEX_EXT) GetUnixTime.$(MEX_EXT) usleep.$(MEX_EXT)

kBotPacketAPI.$(MEX_EXT) : kBotPacketAPI.cc kBotPacket.o
	mex $^ -o $@ $(INCLUDES)

kBotPacket2API.$(MEX_EXT) : kBotPacket2API.cc kBotPacket2.o crc32.o 
	mex $^ -o $@ $(INCLUDES)

SerialDeviceAPI.$(MEX_EXT) : SerialDeviceAPI.cc SerialDevice.o
	mex -O SerialDeviceAPI.cc SerialDevice.o  $(INCLUDES)

clean:
	rm -rf *~ *.o *.$(MEX_EXT)

