MEX_EXT = $(shell mexext)
include common.mk

TARGETS : kBotPacketMexAPI.$(MEX_EXT) kBotPacket2MexAPI.$(MEX_EXT) SerialDeviceMexAPI.$(MEX_EXT) GetUnixTime.$(MEX_EXT) usleep.$(MEX_EXT)

kBotPacketMexAPI.$(MEX_EXT) : kBotPacketMexAPI.cc kBotPacket.o
	mex $^ -o $@ $(INCLUDES)

kBotPacket2MexAPI.$(MEX_EXT) : kBotPacket2MexAPI.cc kBotPacket2.o crc32.o
	mex $^ -o $@ $(INCLUDES)

SerialDeviceMexAPI.$(MEX_EXT) : SerialDeviceMexAPI.cc SerialDevice.o
	mex -O SerialDeviceMexAPI.cc SerialDevice.o  $(INCLUDES)

clean:
	rm -rf *~ *.o *.$(MEX_EXT)

