#include <iostream>
#include "tf/tf.h"
#include "ros/ros.h"
#include "sensor_msgs/Imu.h"
#include "nav_msgs/Odometry.h"
#include "quadrotor_ukf.h"

// ROS
ros::Publisher pubUKF;
QuadrotorUKF quadrotorUKF;
string frame_id;

void imu_callback(const sensor_msgs::Imu::ConstPtr& msg)
{
  // Assemble control input, and calibration
  static int calLimit = 100;
  static int calCnt   = 0;
  static colvec ag = zeros<colvec>(3);
  colvec u(6);
  u(0) = msg->linear_acceleration.x;
  u(1) = msg->linear_acceleration.y;
  u(2) = msg->linear_acceleration.z;
  u(3) = msg->angular_velocity.x;
  u(4) = msg->angular_velocity.y;
  u(5) = msg->angular_velocity.z;
  if (calCnt < calLimit)       // Calibration
  {
    calCnt++;
    ag += u.rows(0,2);
  }
  else if (calCnt == calLimit) // Save gravity vector
  {
    calCnt++;
    ag /= calLimit;
    double g = norm(ag,2);
    quadrotorUKF.SetGravity(g);
  }
  else if (quadrotorUKF.ProcessUpdate(u, msg->header.stamp))  // Process Update
  {
    nav_msgs::Odometry odomUKF;
    odomUKF.header.stamp = quadrotorUKF.GetStateTime();
    odomUKF.header.frame_id = frame_id;
    colvec x = quadrotorUKF.GetState();
    odomUKF.pose.pose.position.x = x(0);
    odomUKF.pose.pose.position.y = x(1);
    odomUKF.pose.pose.position.z = x(2);
    colvec q = R_to_quaternion(ypr_to_R(x.rows(6,8)));
    odomUKF.pose.pose.orientation.w = q(0);
    odomUKF.pose.pose.orientation.x = q(1);
    odomUKF.pose.pose.orientation.y = q(2);
    odomUKF.pose.pose.orientation.z = q(3);
    odomUKF.twist.twist.linear.x = x(3);
    odomUKF.twist.twist.linear.y = x(4);
    odomUKF.twist.twist.linear.z = x(5);
    odomUKF.twist.twist.angular.x = u(3);
    odomUKF.twist.twist.angular.y = u(4);
    odomUKF.twist.twist.angular.z = u(5);
    mat P = quadrotorUKF.GetStateCovariance();
    for (int j = 0; j < 6; j++)
      for (int i = 0; i < 6; i++)
        odomUKF.pose.covariance[i+j*6] = P((i<3)?i:i+3 , (j<3)?j:j+3);
    for (int j = 0; j < 3; j++)
      for (int i = 0; i < 3; i++)
        odomUKF.twist.covariance[i+j*6] = P(i+3 , j+3);
    pubUKF.publish(odomUKF); 
  }
}

void slam_callback(const nav_msgs::Odometry::ConstPtr& msg)
{
  // Get orientation
  colvec q(4);
  q(0) = msg->pose.pose.orientation.w;
  q(1) = msg->pose.pose.orientation.x;
  q(2) = msg->pose.pose.orientation.y;
  q(3) = msg->pose.pose.orientation.z;
  colvec ypr = R_to_ypr(quaternion_to_R(q));
  // Assemble measurement
  colvec z(6);
  z(0) = msg->pose.pose.position.x;
  z(1) = msg->pose.pose.position.y;
  z(2) = msg->pose.pose.position.z;
  z(3) = ypr(0);
  z(4) = ypr(1);
  z(5) = ypr(2);
  // Assemble measurement covariance
  mat RnSLAM = zeros<mat>(6,6);
  for (int j = 0; j < 3; j++)
    for (int i = 0; i < 3; i++)
      RnSLAM(i,j) = msg->pose.covariance[i+j*6];
  RnSLAM(3,3) = msg->pose.covariance[3+3*6];
  RnSLAM(4,4) = msg->pose.covariance[4+4*6];
  RnSLAM(5,5) = msg->pose.covariance[5+5*6];
  // Measurement update
  if (quadrotorUKF.isInitialized())
  {
    quadrotorUKF.MeasurementUpdateSLAM(z, RnSLAM, msg->header.stamp);
  }
  else
  {
    quadrotorUKF.SetInitPose(z, msg->header.stamp);
  }
}

void gps_callback(const nav_msgs::Odometry::ConstPtr& msg)
{
  // Get orientation
  colvec q(4);
  q(0) = msg->pose.pose.orientation.w;
  q(1) = msg->pose.pose.orientation.x;
  q(2) = msg->pose.pose.orientation.y;
  q(3) = msg->pose.pose.orientation.z;
  colvec ypr = R_to_ypr(quaternion_to_R(q));
  // Assemble measurement
  colvec z(9);
  z(0) = msg->pose.pose.position.x;
  z(1) = msg->pose.pose.position.y;
  z(2) = msg->pose.pose.position.z;
  z(3) = msg->twist.twist.linear.x;
  z(4) = msg->twist.twist.linear.y;
  z(5) = msg->twist.twist.linear.z;
  z(6) = ypr(0);
  z(7) = ypr(1);
  z(8) = ypr(2);
  // Assemble measurement covariance
  mat RnGPS = eye<mat>(9,9);
  RnGPS(0,0) = msg->pose.covariance[0+0*6];
  RnGPS(1,1) = msg->pose.covariance[1+1*6];
  RnGPS(2,2) = msg->pose.covariance[2+2*6];
  RnGPS(3,3) = msg->twist.covariance[0+0*6];
  RnGPS(4,4) = msg->twist.covariance[1+1*6];
  RnGPS(5,5) = msg->twist.covariance[2+2*6];
  RnGPS(6,6) = msg->pose.covariance[3+3*6];
  RnGPS(7,7) = msg->pose.covariance[4+4*6];
  RnGPS(8,8) = msg->pose.covariance[5+5*6];
  // Measurement update
  if (quadrotorUKF.isInitialized())
  {
    quadrotorUKF.MeasurementUpdateGPS(z, RnGPS, msg->header.stamp);
  }
  else
  {
    colvec _z = join_cols(z.rows(0,2), z.rows(6,8));
    quadrotorUKF.SetInitPose(_z, msg->header.stamp);
  }
}

int main(int argc, char** argv)
{
  ros::init(argc, argv, "quadrotor_ukf");
  ros::NodeHandle n("~");

  // UKF Parameters and Noise
  double alpha = 0.0;
  double beta  = 0.0;
  double kappa = 0.0;
  double stdAcc[3]     = {0,0,0};
  double stdW[3]       = {0,0,0};
  double stdAccBias[3] = {0,0,0};
  double stdAttBias[2] = {0,0};
  n.param("frame_id", frame_id, string("/map"));
  n.param("alpha", alpha, 0.1);
  n.param("beta" , beta , 2.0);
  n.param("kappa", kappa, 0.0);
  n.param("noise_std/process/acc/x", stdAcc[0], 0.1);
  n.param("noise_std/process/acc/y", stdAcc[1], 0.1);
  n.param("noise_std/process/acc/z", stdAcc[2], 0.1);
  n.param("noise_std/process/w/x", stdW[0], 0.1);
  n.param("noise_std/process/w/y", stdW[1], 0.1);
  n.param("noise_std/process/w/z", stdW[2], 0.1);
  n.param("noise_std/process/acc_bias/x", stdAccBias[0], 0.0005);
  n.param("noise_std/process/acc_bias/y", stdAccBias[1], 0.0005);
  n.param("noise_std/process/acc_bias/z", stdAccBias[2], 0.0005);
  n.param("noise_std/process/att_bias/pitch", stdAttBias[0], 0.0005);
  n.param("noise_std/process/att_bias/roll" , stdAttBias[1], 0.0005);

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
  quadrotorUKF.SetUKFParameters(alpha, beta, kappa);
  quadrotorUKF.SetImuCovariance(Rv);

  ros::Subscriber subImu  = n.subscribe("imu" ,      10, imu_callback);
  ros::Subscriber subSLAM = n.subscribe("odom_slam", 10, slam_callback);
  ros::Subscriber subGPS  = n.subscribe("odom_gps",  10, gps_callback);
  pubUKF = n.advertise<nav_msgs::Odometry>("/control_odom", 10);

  ros::spin();

  return 0;
}
