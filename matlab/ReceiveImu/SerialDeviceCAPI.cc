#include "SerialDevice.hh"
#include <stdint.h>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <vector>

using namespace std;

static SerialDevice * pDev = NULL;

std::vector<uint8_t> charBuf;

void SerialDevice_exit(void){
  std::cout << "Exiting ReceivePackage" << std::endl;
  fflush(stdout);
	if (pDev != NULL) delete pDev;
}

int SerialDevice_connect(const char deviceName[], int baud) {
	if (pDev != NULL) {
		std::cout << "serialDeviceAPI: Port is already open" << std::endl;
		return 1;
	}

	pDev = new SerialDevice();

	//connect to the device and set IO mode (see SerialDevice.hh for modes)
	if (pDev->Connect(deviceName,baud) || pDev->Set_IO_BLOCK_W_TIMEOUT())
  {
		delete pDev;
		pDev=NULL;
		cout << "Could not open device" << endl;
	}
	
	//set the atExit function
	atexit(SerialDevice_exit);

	std::cout << "serialDeviceAPI: Connected to device: "<<deviceName << std::endl;
	return 0;

}

int SerialDevice_read(int len, int timeout, vector<uint8_t>& Buffer) {
	charBuf.resize(len); //make sure there is enough space for data
  Buffer.resize(len);

//  std::cout << charBuf.size() << std::endl;
  int	numRead=pDev->ReadChars((char*)&(charBuf[0]),len,timeout);

	if (numRead >= 0){
//		std::cout << "serialDeviceAPI: Read "<<numRead<<" chars"<< std::endl;
    if (numRead > 0)
      memcpy(&(Buffer[0]), &(charBuf[0]), numRead);
    return 1;
	}
	else{
		std::cout << "serialDeviceAPI: ERROR: could not read chars"<< std::endl;
    Buffer.resize(0); 
	  return 0;
	}
}

int SerialDevice_write(uint8_t *data, int len) {
  if (!pDev)
    cerr << "serialDeviceAPI: not connected to device" << endl;

  if (pDev->WriteChars((char*)data,len) == len){
    std::cout << "serialDeviceAPI: Wrote "<<len<<" chars"<< std::endl;
    return 1;
  }
  else {
    std::cout << "serialDeviceAPI: ERROR: Could not write "<<len<<" chars"<< std::endl;
    return 0;
  }
}
