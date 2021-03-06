# Makefile Includes (http://owen.sj.ca.us/~rk/howto/slides/make/slides/makerecurs.html)
TOP := $(dir $(lastword $(MAKEFILE_LIST)))
TARGETS = all clean
.PHONY: $(TARGETS)

## Path Definition

NAODIR= Platform/Nao
NAOV4DIR = Platform/NaoV4
WEBOTSNAODIR= Platform/WebotsNao
WEBOTSOPDIR= Platform/WebotsOP
WEBOTSGENERICDIR= Platform/WebotsGeneric
WEBOTSHUBODIR= Platform/WebotsHubo
WEBOTSCHARLIDIR= Platform/WebotsCharli
WEBOTSSAFFIRDIR= Platform/WebotsSaffir
WEBOTSTHOROPDIR= Platform/WebotsTHOROP
VISIONTESTDIR = Platform/VisionTest
HPDIR= Platform/HP2
OPDIR= Platform/OP
XOSDIR= Platform/XOS
CHARLIDIR = Platform/Charli
MODULEDIR = Modules
NAOQIDIR= $(NAODIR)/NaoQi
WEBOTSDIR = $(MODULEDIR)/Webots
IMAGEDIR= $(MODULEDIR)/ImageProc
COMMDIR= $(MODULEDIR)/Comm
HOKUYODIR= $(MODULEDIR)/Hokuyo
OCCMAPDIR = $(MODULEDIR)/OccMap
UTILDIR= $(MODULEDIR)/Util
MATLABDIR= ../Tools/Matlab
COLORTABLEDIR= $(MATLABDIR)/Colortable
VELODIR= $(MODULEDIR)/Velocity
PRIMEDIR= $(MODULEDIR)/PrimeSense
HANDSDIR= $(MODULEDIR)/Hands
PLATFORMS = nao naov4 op xos webots_nao webots_op webots_generic webots_hubo visiontest
INSTDIR= ../Player/Lib
WEBOTSCONTDIR= ../WebotsController
PLAYERDIR= ../Player
NAODEPDIR= ../Install/dependencies
NAODEPLUA51DIR= $(NAODEPDIR)/usr/local/lib/lua/5.1


## Compiler Definition
MODE=$(shell getconf LONG_BIT)
CXX=g++
CC=gcc
#LD=ld
LD=g++
LDFLAGS=
STRIP=strip
CFLAGS=-O2 -fpic
CXXFLAGS= -O2 -fpic

MEXEXT=mexglx
SHLIBEXT= so
LIBOPTS= -shared -fpic
LIBRT= -lrt

# Library and Include Paths
ifeq ($(shell pkg-config --exists luajit && echo 0),0)
  LUAJIT_INC=`pkg-config luajit --cflags`
else 
# No LuaJIT found, falling back to regular Lua
ifeq ($(shell pkg-config --exists lua5.1 && echo 0),0)
  LUA_INC=`pkg-config lua5.1 --cflags`
else
  LUA_INC=`pkg-config lua --cflags`
endif
endif

INCLUDES= -I$(TOP)/Common -I/usr/local/include -I/usr/include $(LUAJIT_INC)
LIB_DIR= -L/usr/local/lib -L/usr/lib


ifndef OSTYPE
  OSTYPE = $(shell uname -s|awk '{print tolower($$0)}')
endif

ifndef ARCH
  ARCH= $(shell uname -m)
endif

ifndef USER
  USER=$(shell whoami)
endif

ifeq ($(OSTYPE),linux)
  SHLIBEXT= so
  LIBOPTS= -shared -fpic
  LIBRT= -lrt
ifeq ($(USER),darwin)
  CXXFLAGS= -O3 -fomit-frame-pointer -mtune=native -march=native -pipe -funroll-loops
endif
endif

ifeq ($(OSTYPE),darwin)
#  SHLIBEXT= dylib
  SHLIBEXT= so
  LIBOPTS= -bundle -undefined dynamic_lookup
  # -march=native is not supported, so tune as your system demand
  CXXFLAGS= -O2 -fomit-frame-pointer -mtune=native
  LIBRT=
# The -arch option is only available on Mac systems to create universal binaries
ifeq ($(MODE),64)
  CC=gcc -arch x86_64
  CXX=g++ -arch x86_64
  LD=g++ -arch x86_64
  MEXEXT=mexmaci64
else
  CC=gcc -arch i386
  CXX=g++ -arch i386
  LD=g++ -arch i386
  MEXEXT=mexmaci
endif
endif



# For Intel Atom Z530 on the Darwin-OP
# http://jim-dev.blogspot.com/2010/04/gentoo-linux-on-dell-mini-1012.html
#CFLAGS="-O2 -march=core2 -mtune=generic -mssse3 -mfpmath=sse -pipe -fomit-frame-pointer"
#CXXFLAGS="${CFLAGS}"
# From Gentoo wiki (http://en.gentoo-wiki.com/wiki/Intel_D945GCLF2)
#CHOST="i686-pc-linux-gnu"
#CFLAGS="-O2 -march=core2 -mtune=generic -fomit-frame-pointer -pipe -mssse3 -mfpmath=sse"
# Possible?
#CXXFLAGS= -O3 -funroll-loops -fpic
#-mtune=atom
# ANother guide: http://linuxreviews.org/howtos/compiling/#toc1
# -march=native could help...?
#  Look at the warning here: http://en.gentoo-wiki.com/wiki/Safe_Cflags/Intel
#  http://tombarta.wordpress.com/2008/05/25/gcc-flags/
#  Should be using arch...? http://www.implbits.com/About/Blog/tabid/78/post/building-with-gcc-4-6-on-osx/Default.aspx
# http://stackoverflow.com/questions/1754460/apples-gcc-whats-the-difference-between-arch-i386-and-m32
#  Really, should use native unless on the Nao
# OSX Specific: http://programmers.stackexchange.com/questions/51670/why-do-programmers-use-or-recommend-mac-os-x
