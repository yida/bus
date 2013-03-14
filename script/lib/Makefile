CWD= $(shell pwd)

all:: GeographicLib LuaXml Serial

GeographicLib::
	cd GeographicLib && make && cd $(CWD)

LuaXml::
	cd LuaXml && make && cd $(CWD)

Serial::
	cd Serial && make && cd $(CWD)

clean:
	cd GeographicLib && make clean && cd $(CWD)
	cd LuaXml && make clean && cd $(CWD)
	cd Serial && make clean && cd $(CWD)


