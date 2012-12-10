#ifndef QUADROTOR_UKF_H
#define QUADROTOR_UKF_H

#include <iostream>
#include <string.h>
#include <math.h>
#include <list>
#include <vector>
#include <algorithm>
//#include "ros/ros.h"
#include "armadillo"
#include "pose_utils.h"


class QuadrotorUKF
{
  private:

    // State History and Covariance
    list<colvec>    xHist;
    list<colvec>    uHist;
//    list<ros::Time> xTimeHist;
    list<double> xTimeHist;
    mat P;

    // Process Covariance Matrix
    mat Rv;

    // Instance sigma points
    mat Xa;
    mat Va;

    // Initial process update indicator
    bool initMeasure;
    bool initGravity;

    // Dimemsions
    int stateCnt;
    int procNoiseCnt;
    int measNoiseSLAMCnt;
    int measNoiseGPSCnt;
    int L;

    // Gravity
    double g;

    // UKF Parameters
    double alpha;
    double beta;
    double kappa;
    double lambda;
    double gamma;
    // UKF Weights
    rowvec wm;
    rowvec wc;

    // Private functions
    void GenerateWeights();
    void GenerateSigmaPoints();
    colvec ProcessModel(const colvec& x, const colvec& u, const colvec& v, double dt);
    mat MeasurementModelSLAM();
    mat MeasurementModelGPS();
    void PropagateAprioriCovariance(const double time, list<colvec>::iterator& kx, list<colvec>::iterator& ku, list<double>::iterator& kt);
    void PropagateAposterioriState(list<colvec>::iterator kx, list<colvec>::iterator ku, list<double>::iterator kt);
    
  public:

    QuadrotorUKF();
    ~QuadrotorUKF();

    bool      isInitialized();
    colvec    GetState();
    double GetStateTime();
    mat       GetStateCovariance();

    void SetGravity(double _g);
    void SetImuCovariance(const mat& _Rv);
    void SetUKFParameters(double _alpha, double _beta, double _kappa);
    void SetInitPose(colvec p, double time);

    bool ProcessUpdate(colvec u, double time);
    bool MeasurementUpdateSLAM(colvec z, mat RnSLAM, double time);
    bool MeasurementUpdateGPS(colvec z, mat RnGPS, double time);
};

#endif
