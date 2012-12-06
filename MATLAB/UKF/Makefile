TARGETS = all clean
.PHONY: $(TARGETS)

BOOST_INCLUDE_DIRS=
INCLUDES=

ifndef OSTYPE
  OSTYPE = $(shell uname -s|awk '{print tolower($$0)}')
endif

ifeq ($(OSTYPE),linux)
  SHLIBEXT=so
  LIBRT=-lrt
endif
ifeq ($(OSTYPE),darwin)
  SHLIBEXT=dylib
  INCLUDES=-I/usr/include -I/usr/local/include
endif

MEXEXT=$(shell mexext)

all: BusUKF

BusUKF: BusUKF.cc
	mex -O $^ $(BOOST_INCLUDE_DIRS) $(INCLUDES) $(LIBRT)


clean:
	rm -f *.o *.$(SHLIBEXT) *.$(MEXEXT)

