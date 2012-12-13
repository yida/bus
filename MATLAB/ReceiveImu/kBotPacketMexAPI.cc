#include "kBotPacket.h"
#include <mex.h>
#include <map>
#include <string.h>
#include <stdint.h>

using namespace std;

std::map<int,kBotPacket> packets;
static int packetCntr = 0;


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	// Get input arguments
	if (nrhs == 0)
		mexErrMsgTxt("Need input argument");
	
	const int BUFLEN = 256;
	char command[BUFLEN];

	if (mxGetString(prhs[0], command, BUFLEN) != 0)
		mexErrMsgTxt("serialDeviceAPI: Could not read string.");

  //parse the commands
	if (strcasecmp(command, "create") == 0)
  {
    packets[packetCntr] = kBotPacket();
    kBotPacketInit(&(packets[packetCntr]));
    plhs[0] = mxCreateDoubleScalar(packetCntr);
    packetCntr++;
    return;
  }
  if (strcasecmp(command, "processBuffer") == 0)
  {
    if (nrhs != 3)
      mexErrMsgTxt("need two input arguments");

    int nPacket = mxGetPr(prhs[1])[0];
    if (nPacket >= packetCntr)
      mexErrMsgTxt("invalid packet counter");

    if (mxGetClassID(prhs[2]) != mxUINT8_CLASS)
      mexErrMsgTxt("data buffer must be uint8");

    uint8_t * buf = (uint8_t*)mxGetData(prhs[2]);
    int size = mxGetNumberOfElements(prhs[2]);

    kBotPacket * dpacket = &(packets[nPacket]);
    int ndims    = 2;
    int dims[2]  = {1,0};

    while (size > 0)
    {
      int ret = kBotPacketProcessChar(*buf++,dpacket);
      size--;
      if (ret > 0)
      {
        dims[1] = dpacket->lenExpected;
        plhs[0] = mxCreateNumericArray(ndims,dims,mxUINT8_CLASS,mxREAL);
        memcpy(mxGetPr(plhs[0]),dpacket->buffer,dpacket->lenExpected);
        
        dims[1] = size;
        plhs[1] = mxCreateNumericArray(ndims,dims,mxUINT8_CLASS,mxREAL);
        memcpy(mxGetPr(plhs[1]),buf,size);
        return;
      }
    }
    
    dims[0] = 0;
    dims[1] = 0;
    plhs[0] = mxCreateNumericArray(ndims,dims,mxUINT8_CLASS,mxREAL);
    plhs[1] = mxCreateNumericArray(ndims,dims,mxUINT8_CLASS,mxREAL);
    return;
  }
 
  else
    mexErrMsgTxt("unknown commands");
  
  return;
}

