#include "SerialDevice.hh"
#include "mex.h"
#include <stdint.h>
#include <vector>

static SerialDevice * pDev = NULL;

std::vector<uint8_t> charBuf;

//this will be executed when the mex file is unloaded
void mexExit(void){
	printf("Exiting serialDeviceAPI\n"); fflush(stdout);
	if (pDev != NULL) delete pDev;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
	// Get input arguments
	if (nrhs == 0) {
		mexErrMsgTxt("serialDeviceAPI: Need input argument");
	}
	
	const int BUFLEN = 256;
	char command[BUFLEN];

	if (mxGetString(prhs[0], command, BUFLEN) != 0) {
		mexErrMsgTxt("serialDeviceAPI: Could not read string.");
	}

	//parse the commands
	if (strcasecmp(command, "connect") == 0) {
		if (pDev != NULL) {
			std::cout << "serialDeviceAPI: Port is already open" << std::endl;
			plhs[0] = mxCreateDoubleScalar(0);
			return;
		}

		if (nrhs != 3) mexErrMsgTxt("serialDeviceAPI: Please enter correct arguments: 'connect', <device>, <baud rate>\n");

		char deviceName[BUFLEN];
		if (mxGetString(prhs[1], deviceName, BUFLEN) != 0) {
			mexErrMsgTxt("serialDeviceAPI: Could not read string while reading the device name");
		}

		int baud=(int)mxGetPr(prhs[2])[0];
		pDev = new SerialDevice();

		//connect to the device and set IO mode (see SerialDevice.hh for modes)
		if (pDev->Connect(deviceName,baud) || pDev->Set_IO_BLOCK_W_TIMEOUT())
    {
			delete pDev;
			pDev=NULL;
			mexErrMsgTxt("Could not open device");
		}
		
		//set the atExit function
		mexAtExit(mexExit);

		std::cout << "serialDeviceAPI: Connected to device: "<<deviceName << std::endl;
		plhs[0] = mxCreateDoubleScalar(0);
		return;
	}

	else if (strcasecmp(command, "read") == 0) {
		//how many chars to read?		
		int len=(int)mxGetPr(prhs[1])[0];
		charBuf.resize(len); //make sure there is enough space for data

		//timeout in microseconds
		int timeout=(int)mxGetPr(prhs[2])[0];

		int numRead=pDev->ReadChars((char*)&(charBuf[0]),len,timeout);

		if (numRead >= 0){
			//std::cout << "serialDeviceAPI: Read "<<numRead<<" chars"<< std::endl;
			int ndim = 2;
      int dims[] = {1,numRead };
			plhs[0] = mxCreateNumericArray(ndim,dims,mxUINT8_CLASS,mxREAL);
      if (numRead > 0)
        memcpy(mxGetData(plhs[0]),&(charBuf[0]),numRead);
		}
		else{
			std::cout << "serialDeviceAPI: ERROR: could not read chars"<< std::endl;
			plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
		}
		return;
	}


	else if (strcasecmp(command, "write") == 0)
  {
    if (!pDev)
      mexErrMsgTxt("serialDeviceAPI: not connected to device");

    if (nrhs != 2)
      mexErrMsgTxt("serialDeviceAPI: need two argumets");

    uint8_t * data = (uint8_t *)mxGetData(prhs[1]);
    int len=mxGetNumberOfElements(prhs[1]);

    if (pDev->WriteChars((char*)data,len) == len){
      //std::cout << "serialDeviceAPI: Wrote "<<len<<" chars"<< std::endl;
      plhs[0] = mxCreateDoubleScalar(1);
    }
    else {
      std::cout << "serialDeviceAPI: ERROR: Could not write "<<len<<" chars"<< std::endl;
      plhs[0] = mxCreateDoubleScalar(0);
    }
    return;
  }
  else
    mexErrMsgTxt("command not recognized");

  return;
}








