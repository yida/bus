MEX_EXT = $(shell mexext)
include ReceiveIMU/common.mk

TARGETS :	getch.$(MEX_EXT) serialopen.$(MEX_EXT)

getch.$(MEX_EXT) : getch.c
	mex $^ -o $@ $(INCLUDES)

serialopen.$(MEX_EXT) : serialopen.c
	mex $^ -o $@ $(INCLUDES)

clean:
	rm -rf *~ *.o *.$(MEX_EXT) ReceivePackets


