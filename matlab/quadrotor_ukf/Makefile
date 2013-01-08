TARGETS = all clean
.PHONY: $(TARGETS)

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

all: mexukf

mexukf: mexukf.cpp quadrotor_ukf.cpp pose_utils.cpp
	mex -O $^ $(LIBRT) -I/usr/local/include -L/usr/local/lib -larmadillo


clean:
	rm -f *.o *.$(SHLIBEXT) *.$(MEXEXT)

