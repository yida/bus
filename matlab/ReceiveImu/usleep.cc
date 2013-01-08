#include <mex.h>
#include <unistd.h>
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  if (nrhs != 1)
    mexErrMsgTxt("please provide time to sleep (microseconds)");

  double t = (mxGetPr(prhs[0]))[0];
  
  if (t < 0)
    mexErrMsgTxt("sleep time must be non-negative");
  usleep((int)t);
  plhs[0] = mxCreateDoubleScalar(1);
}

