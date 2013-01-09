#include <iostream>
#include <vector>
#include <map>
//#include "tf/tf.h"
//#include "ros/ros.h"
//#include "sensor_msgs/Imu.h"
//#include "nav_msgs/Odometry.h"
#include "quadrotor_ukf.h"
#include "pose_utils.h"

#include "mex.h"

// ROS
static vector<QuadrotorUKF> UKFHandles;
string frame_id;

void mex_imu(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int nukf = mxGetScalar(prhs[0]);
  // Assemble control input, and calibration
  static int calLimit = 100;
  static int calCnt   = 0;
  static colvec ag = zeros<colvec>(3);
  colvec u(6);

  double *imu = mxGetPr(prhs[1]);
  u(0) = imu[0]; // msg->linear_acceleration.x;
  u(1) = imu[1]; // msg->linear_acceleration.y;
  u(2) = imu[2]; // msg->linear_acceleration.z;
  u(3) = imu[3]; // msg->angular_velocity.x;
  u(4) = imu[4]; // msg->angular_velocity.y;
  u(5) = imu[5]; // msg->angular_velocity.z;

  double timestamp = *mxGetPr(prhs[2]);
  UKFHandles[nukf].SetGravity(9.80);

  plhs[0] = mxCreateDoubleScalar(0);
  plhs[1] = mxCreateDoubleMatrix(3, 1, mxREAL); // pose
  double pose[3] = {0};
  plhs[2] = mxCreateDoubleMatrix(3, 1, mxREAL); // orien
  double orien[3] = {0};
  plhs[3] = mxCreateDoubleMatrix(3, 1, mxREAL); // vel
  double vel[3] = {0};
  plhs[4] = mxCreateDoubleMatrix(3, 1, mxREAL); // omega
  double omega[3] = {0};
  plhs[5] = mxCreateDoubleMatrix(6,6, mxREAL);  // postCov
  double poseCov[36] = {0};
  plhs[6] = mxCreateDoubleMatrix(6,6, mxREAL);  // twistCov
  double twistCov[36] = {0};

  if (UKFHandles[nukf].ProcessUpdate(u, timestamp))  // Process Update
  {
    // Odometry Output
      plhs[0] = mxCreateDoubleScalar(UKFHandles[nukf].GetStateTime());

      colvec x = UKFHandles[nukf].GetState();
      pose[0] = x(0);
      pose[1] = x(1);
      pose[2] = x(2);
      cout << pose << endl;

      orien[0] = x(6);
      orien[1] = x(7);
      orien[2] = x(8);

      vel[0] = x(3);
      vel[1] = x(4);
      vel[2] = x(5);

      omega[0] = u(3);
      omega[1] = u(4);
      omega[2] = u(5);


      mat P = UKFHandles[nukf].GetStateCovariance();
      for (int j = 0; j < 6; j++)
        for (int i = 0; i < 6; i++)
          poseCov[i+j*6] = P((i<3)?i:i+3 , (j<3)?j:j+3);

      for (int j = 0; j < 3; j++)
        for (int i = 0; i < 3; i++)
          twistCov[i+j*6] = P(i+3 , j+3);
  }
  memcpy(mxGetPr(plhs[1]), &pose[0], 3 * sizeof(double));
  memcpy(mxGetPr(plhs[2]), &orien[0], 3 * sizeof(double));
  memcpy(mxGetPr(plhs[3]), &vel[0], 3 * sizeof(double));
  memcpy(mxGetPr(plhs[4]), &omega[0], 3 * sizeof(double));
  memcpy(mxGetPr(plhs[5]), &poseCov[0], 36 * sizeof(double));
  memcpy(mxGetPr(plhs[6]), &twistCov[0], 36 * sizeof(double));
}

//
void mex_vicon(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
//void slam_callback(const nav_msgs::Odometry::ConstPtr& msg)
{
//  // Get orientation
//  colvec q(4);
//  q(0) = msg->pose.pose.orientation.w;
//  q(1) = msg->pose.pose.orientation.x;
//  q(2) = msg->pose.pose.orientation.y;
//  q(3) = msg->pose.pose.orientation.z;
//  colvec ypr = R_to_ypr(quaternion_to_R(q));
  int nukf = mxGetScalar(prhs[0]);

  double *r = (double *) mxGetData(prhs[1]);
  int mx = mxGetM(prhs[1]);
  int nx = mxGetN(prhs[1]);
  mat R = zeros<mat>(3,3); 
  for (int i = 0; i < nx; i++)
    for (int j = 0; j < mx; j++)
      R(j, i) = r[i * 3 + j];
  colvec ypr = R_to_ypr(R);
  // Assemble measurement
  colvec z(6);
  z(0) = 0; // msg->pose.pose.position.x;
  z(1) = 0; // msg->pose.pose.position.y;
  z(2) = 0; // msg->pose.pose.position.z;
  z(3) = ypr(0);
  z(4) = ypr(1);
  z(5) = ypr(2);
  // Assemble measurement covariance
  double stdVicon = 0.005;
  mat RnVicon = eye<mat>(6,6);
  RnVicon(0,0) = stdVicon * stdVicon;
  RnVicon(1,1) = stdVicon * stdVicon;
  RnVicon(2,2) = stdVicon * stdVicon;
  RnVicon(3,3) = stdVicon * stdVicon;
  RnVicon(4,4) = stdVicon * stdVicon;
  RnVicon(5,5) = stdVicon * stdVicon;
  double timestamp = *mxGetPr(prhs[2]);
//  for (int j = 0; j < 3; j++)
//    for (int i = 0; i < 3; i++)
//      RnSLAM(i,j) = msg->pose.covariance[i+j*6];
//  RnSLAM(3,3) = msg->pose.covariance[3+3*6];
//  RnSLAM(4,4) = msg->pose.covariance[4+4*6];
//  RnSLAM(5,5) = msg->pose.covariance[5+5*6];
  // Measurement update
  if (UKFHandles[nukf].isInitialized())
  {
    UKFHandles[nukf].MeasurementUpdateSLAM(z, RnVicon, timestamp);
  }
  else
  {
    UKFHandles[nukf].SetInitPose(z, timestamp);
  }
}
//
//void gps_callback(const nav_msgs::Odometry::ConstPtr& msg)
//{
//  // Get orientation
//  colvec q(4);
//  q(0) = msg->pose.pose.orientation.w;
//  q(1) = msg->pose.pose.orientation.x;
//  q(2) = msg->pose.pose.orientation.y;
//  q(3) = msg->pose.pose.orientation.z;
//  colvec ypr = R_to_ypr(quaternion_to_R(q));
//  // Assemble measurement
//  colvec z(9);
//  z(0) = msg->pose.pose.position.x;
//  z(1) = msg->pose.pose.position.y;
//  z(2) = msg->pose.pose.position.z;
//  z(3) = msg->twist.twist.linear.x;
//  z(4) = msg->twist.twist.linear.y;
//  z(5) = msg->twist.twist.linear.z;
//  z(6) = ypr(0);
//  z(7) = ypr(1);
//  z(8) = ypr(2);
//  // Assemble measurement covariance
//  mat RnGPS = eye<mat>(9,9);
//  RnGPS(0,0) = msg->pose.covariance[0+0*6];
//  RnGPS(1,1) = msg->pose.covariance[1+1*6];
//  RnGPS(2,2) = msg->pose.covariance[2+2*6];
//  RnGPS(3,3) = msg->twist.covariance[0+0*6];
//  RnGPS(4,4) = msg->twist.covariance[1+1*6];
//  RnGPS(5,5) = msg->twist.covariance[2+2*6];
//  RnGPS(6,6) = msg->pose.covariance[3+3*6];
//  RnGPS(7,7) = msg->pose.covariance[4+4*6];
//  RnGPS(8,8) = msg->pose.covariance[5+5*6];
//  // Measurement update
//  if (quadrotorUKF.isInitialized())
//  {
//    quadrotorUKF.MeasurementUpdateGPS(z, RnGPS, msg->header.stamp);
//  }
//  else
//  {
//    colvec _z = join_cols(z.rows(0,2), z.rows(6,8));
//    quadrotorUKF.SetInitPose(_z, msg->header.stamp);
//  }
//}

void mex_create(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  // UKF Parameters and Noise
  double alpha = 0.1;
  double beta  = 2.0;
  double kappa = 0.0;
  double stdAcc[3]     = {0.1, 0.1, 0.1};
  double stdW[3]       = {0.1, 0.1, 0.1};
  double stdAccBias[3] = {0.0005, 0.0005, 0.0005};
  double stdAttBias[2] = {0.0005, 0.0005};

  alpha = *mxGetPr(prhs[0]);
  beta  = *mxGetPr(prhs[1]);
  kappa = *mxGetPr(prhs[2]);
 
  double *stdacc = mxGetPr(prhs[3]); 
  stdAcc[0] = stdacc[0];
  stdAcc[1] = stdacc[1];
  stdAcc[2] = stdacc[2];
//  n.param("noise_std/process/acc/x", stdAcc[0], 0.1);
//  n.param("noise_std/process/acc/y", stdAcc[1], 0.1);
//  n.param("noise_std/process/acc/z", stdAcc[2], 0.1);
  double *stdw = mxGetPr(prhs[4]); 
  stdW[0] = stdw[0];
  stdW[1] = stdw[1];
  stdW[2] = stdw[2];

//  n.param("noise_std/process/w/x", stdW[0], 0.1);
//  n.param("noise_std/process/w/y", stdW[1], 0.1);
//  n.param("noise_std/process/w/z", stdW[2], 0.1);
  double *stdaccbias = mxGetPr(prhs[5]); 
  stdAccBias[0] = stdaccbias[0];
  stdAccBias[1] = stdaccbias[1];
  stdAccBias[2] = stdaccbias[2];
//  n.param("noise_std/process/acc_bias/x", stdAccBias[0], 0.0005);
//  n.param("noise_std/process/acc_bias/y", stdAccBias[1], 0.0005);
//  n.param("noise_std/process/acc_bias/z", stdAccBias[2], 0.0005);
  stdAccBias[0] = *mxGetPr(prhs[6]);
  stdAccBias[1] = *mxGetPr(prhs[7]);
//  n.param("noise_std/process/att_bias/pitch", stdAttBias[0], 0.0005);
//  n.param("noise_std/process/att_bias/roll" , stdAttBias[1], 0.0005);

  // Fixed process noise
  mat Rv = eye<mat>(11,11);
  Rv(0,0)   = stdAcc[0] * stdAcc[0];
  Rv(1,1)   = stdAcc[1] * stdAcc[1];
  Rv(2,2)   = stdAcc[2] * stdAcc[2];
  Rv(3,3)   = stdW[0] * stdW[0];
  Rv(4,4)   = stdW[1] * stdW[1];
  Rv(5,5)   = stdW[2] * stdW[2];
  Rv(6,6)   = stdAccBias[0] * stdAccBias[0];
  Rv(7,7)   = stdAccBias[1] * stdAccBias[1];
  Rv(8,8)   = stdAccBias[2] * stdAccBias[2];
  Rv(9,9)   = stdAttBias[0] * stdAttBias[0];
  Rv(10,10) = stdAttBias[1] * stdAttBias[1];

  // Initialize UKF
  int nukf = UKFHandles.size();
  UKFHandles.push_back(QuadrotorUKF());
  UKFHandles[nukf].SetUKFParameters(alpha, beta, kappa);
  UKFHandles[nukf].SetImuCovariance(Rv);

  plhs[0] = mxCreateDoubleScalar(nukf);

 // ros::Subscriber subImu  = n.subscribe("imu" ,      10, imu_callback);
 // ros::Subscriber subSLAM = n.subscribe("odom_slam", 10, slam_callback);
 // ros::Subscriber subGPS  = n.subscribe("odom_gps",  10, gps_callback);
 // pubUKF = n.advertise<nav_msgs::Odometry>("/control_odom", 10);

 // ros::spin();

 // return 0;
}

void mex_get(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
}

void mex_mag(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
}

void mex_gps(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
}

void mexExit(void)
{
  printf("Exiting mexukf.\n");
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  static bool init = false;
  static std::map<std::string, void (*)(int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[])> funcMap;

  if (!init) {
    fprintf(stdout, "Starting mexukf...");

    UKFHandles.reserve(1);
    UKFHandles.clear();

    funcMap["init"] = mex_create;
    funcMap["get"] = mex_get;
    funcMap["imu"] = mex_imu;
    funcMap["gps"] = mex_gps;
    funcMap["mag"] = mex_mag;
    funcMap["vicon"] = mex_vicon;

    mexAtExit(mexExit);
    init = true;
  }

  if ((nrhs < 1) || (!mxIsChar(prhs[0])))
    mexErrMsgTxt("Need to input string argument");
  std::string fname(mxArrayToString(prhs[0]));

  std::map<std::string, void (*)(int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[])>::iterator iFuncMap = funcMap.find(fname);

  if (iFuncMap == funcMap.end())
    mexErrMsgTxt("Unknown function argument");

  (iFuncMap->second)(nlhs, plhs, nrhs-1, prhs+1);
}

