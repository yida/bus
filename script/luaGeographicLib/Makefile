
include Makefile.inc

SOURCES= \
				 lua_Geocentric.cpp  \
				 lua_GeographicLib.cpp

OBJECTS=$(SOURCES:.c=.o)

all: $(SOURCES) GeographicLib 

%.o: %.cpp
	g++ -c -o $@ $^ $(CPP_FLAGS) $(INCLUDES)


GeographicLib: $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@.$(SHLIBEXT) $(LIBOPTS) $^ $(LIB_DIR) -lGeographic

clean:
	rm -f *.so *.o 
