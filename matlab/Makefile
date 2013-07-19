MEX_EXT = $(shell mexext)

all:	getch.$(MEX_EXT) serialopen.$(MEX_EXT) msgpack.$(MEX_EXT)

getch.$(MEX_EXT) : getch.c
	mex $^ -o $@ $(INCLUDES)

serialopen.$(MEX_EXT) : serialopen.c
	mex $^ -o $@ $(INCLUDES)

msgpack.$(MEX_EXT): ../../msgpack-matlab/msgpack.cc
	mex $^ -o $@ -I/usr/local/include -L/usr/local/lib -lmsgpack

clean:
	rm -rf *~ *.o *.$(MEX_EXT)


