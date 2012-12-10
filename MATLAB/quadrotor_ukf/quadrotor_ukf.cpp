#include "quadrotor_ukf.h"

QuadrotorUKF::QuadrotorUKF()  
{
  // Init Dimensions
  stateCnt         = 14;
  procNoiseCnt     = 11;
  measNoiseSLAMCnt = 6; 
  measNoiseGPSCnt  = 9; 
  L = stateCnt + procNoiseCnt;
  // Init State
  xHist.clear();
  uHist.clear();
  xTimeHist.clear();
  Xa = zeros<mat>(stateCnt, 2*L+1);
  Va = zeros<mat>(procNoiseCnt, 2*L+1);
  P = zeros<mat>(stateCnt,stateCnt);
  P(0,0) = 0.5*0.5;
  P(1,1) = 0.5*0.5;
  P(2,2) = 0.1*0.1;
  P(3,3) = 0.1*0.1;
  P(4,4) = 0.1*0.1;
  P(5,5) = 0.1*0.1;
  P(6,6) = 10*PI/180*10*PI/180;
  P(7,7) = 10*PI/180*10*PI/180;
  P(8,8) = 10*PI/180*10*PI/180;
  P(9,9)   =  0.01*0.01;
  P(10,10) =  0.01*0.01;
  P(11,11) =  0.01*0.01;
  P(12,12) =  0.001*0.001;
  P(13,13) =  0.001*0.001;
  Rv = eye<mat>(procNoiseCnt,procNoiseCnt);
  // Init Sigma Points
  alpha = 0.1;
  beta  = 2;
  kappa = 0;
  GenerateWeights();
  // Other Inits
  g = 9.81;
  initMeasure = false;
  initGravity = false;
}

          QuadrotorUKF::~QuadrotorUKF() { }
bool      QuadrotorUKF::isInitialized() { return (initMeasure && initGravity); }
colvec    QuadrotorUKF::GetState()           { return xHist.front();     }
double QuadrotorUKF::GetStateTime()       { return xTimeHist.front(); }
mat       QuadrotorUKF::GetStateCovariance() { return P;                 }
void      QuadrotorUKF::SetGravity(double _g) { g = _g; initGravity = true; }
void      QuadrotorUKF::SetImuCovariance(const mat& _Rv) { Rv = _Rv; }

void QuadrotorUKF::SetUKFParameters(double _alpha, double _beta, double _kappa)
{
  alpha = _alpha;
  beta  = _beta;
  kappa = _kappa;
  GenerateWeights();
}

void QuadrotorUKF::SetInitPose(colvec p, double time)
{
  colvec x = zeros<colvec>(stateCnt);
  x.rows(0,2)  = p.rows(0,2);
  x.rows(6,8)  = p.rows(3,5);
  xHist.push_front(x);
  uHist.push_front(zeros<colvec>(6));
  xTimeHist.push_front(time);
  initMeasure = true;
}

bool QuadrotorUKF::ProcessUpdate(colvec u, double time)
{
  if (!initMeasure || !initGravity)
    return false;
  // Just update state, defer covariance update
  double dt = time-xTimeHist.front();
  colvec x = ProcessModel(xHist.front(), u, zeros<colvec>(procNoiseCnt), dt);
  xHist.push_front(x);
  uHist.push_front(u);
  xTimeHist.push_front(time);

  return true;
}

bool QuadrotorUKF::MeasurementUpdateSLAM(colvec z, mat RnSLAM, double time)
{
  // Init
  if (!initMeasure || !initGravity)
    return false;
  // A priori covariance
  list<colvec>::iterator    kx;
  list<colvec>::iterator    ku; 
  list<double>::iterator kt;
  PropagateAprioriCovariance(time, kx, ku, kt);
  colvec x = *kx;
  // Get Measurement
  mat H = MeasurementModelSLAM();
  colvec za = H * x;
  // Compute Kalman Gain
  mat S = H * P * trans(H) + RnSLAM;
  mat K = P * trans(H) * inv(S);
  // Innovation
  colvec inno = z - za;
  // Handle angle jumps
  inno(3) = asin(sin(inno(3)));
  // Posteriori Mean
  x += K * inno;
  *kx = x;
  // Posteriori Covariance
  P = P - K * H * P;
  // Propagate Aposteriori State
  PropagateAposterioriState(kx, ku, kt);

  return true;
}

bool QuadrotorUKF::MeasurementUpdateGPS(colvec z, mat RnGPS, double time)
{
  // Init
  if (!initMeasure || !initGravity)
    return false;
  // A priori covariance
  list<colvec>::iterator    kx;
  list<colvec>::iterator    ku; 
  list<double>::iterator kt;
  PropagateAprioriCovariance(time, kx, ku, kt);
  colvec x = *kx;
  // Get Measurement
  mat H = MeasurementModelGPS();
  colvec za = H * x;
  // Compute Kalman Gain
  mat S = H * P * trans(H) + RnGPS;
  mat K = P * trans(H) * inv(S);
  // Innovation
  colvec inno = z - za;
  // Handle angle jumps
  inno(6) = asin(sin(inno(6)));
  // Posteriori Mean
  x += K * inno;
  *kx = x;
  // Posteriori Covariance
  P = P - K * H * P;
  // Propagate Aposteriori State
  PropagateAposterioriState(kx, ku, kt);

  return true;
}

void QuadrotorUKF::GenerateWeights()
{
  // State + Process noise
  lambda = alpha*alpha*(L+kappa)-L;
  wm = zeros<rowvec>(2*L+1);
  wc = zeros<rowvec>(2*L+1);
  wm(0) = lambda / (L+lambda);
  wc(0) = lambda / (L+lambda) + (1-alpha*alpha+beta);
  for (int k = 1; k <= 2*L; k++)
  {
    wm(k) = 1 / (2 * (L+lambda));
    wc(k) = 1 / (2 * (L+lambda));
  }
  gamma = sqrt(L + lambda);
}

void QuadrotorUKF::GenerateSigmaPoints()
{
  // Expand state
  colvec x   = xHist.back();
  colvec xaa = zeros<colvec>(L);
  xaa.rows(0,stateCnt-1) = x;
  mat Xaa = zeros<mat>(L, 2*L+1);
  mat Paa = zeros<mat>(L,L);
  Paa.submat(0, 0, stateCnt-1, stateCnt-1) = P;
  Paa.submat(stateCnt, stateCnt, L-1, L-1) = Rv;
  // Matrix square root
  mat sqrtPaa = trans(chol(Paa));
  // Mean
  Xaa.col(0) = xaa;
  mat xaaMat = repmat(xaa,1,L);
  Xaa.cols(  1,  L) = xaaMat + gamma * sqrtPaa;
  Xaa.cols(L+1,L+L) = xaaMat - gamma * sqrtPaa;
  // Push back to original state
  Xa = Xaa.rows(0, stateCnt-1);
  Va = Xaa.rows(stateCnt, L-1);
}

colvec QuadrotorUKF::ProcessModel(const colvec& x, const colvec& u, const colvec& v, double dt)
{
  mat R = ypr_to_R(x.rows(6,8));
  colvec ag(3);
  ag(0) = 0;
  ag(1) = 0;
  ag(2) = g;
  // Acceleration
  colvec a = u.rows(0,2) + v.rows(0,2);
  colvec ddx = R * (a - x.rows(9,11)) - ag;
  // Rotation
  colvec w = u.rows(3,5) + v.rows(3,5);
  mat dR = eye<mat>(3,3);
  dR(0,1) = -w(2) * dt;
  dR(0,2) =  w(1) * dt;
  dR(1,0) =  w(2) * dt;
  dR(1,2) = -w(0) * dt;
  dR(2,0) = -w(1) * dt;
  dR(2,1) =  w(0) * dt;
  mat Rt = R * dR;
  // State
  colvec xt = x;
  xt.rows(0,2)   = x.rows(0,2) + x.rows(3,5)*dt + ddx*dt*dt/2;
  xt.rows(3,5)   =               x.rows(3,5)    + ddx*dt     ;
  xt.rows(6,8)  = R_to_ypr(Rt);
  xt.rows(9,11)  = x.rows(9,11)  + v.rows(6,8) *dt;
  xt.rows(12,13) = x.rows(12,13) + v.rows(9,10)*dt;
  return xt;
}

mat QuadrotorUKF::MeasurementModelSLAM()
{
  mat H = zeros<mat>(measNoiseSLAMCnt, stateCnt);
  H(0,0) = 1;
  H(1,1) = 1;
  H(2,2) = 1;
  H(3,6) = 1;
  H(4,7) = 1;
  H(5,8) = 1;
  H(4,12) = 1;
  H(5,13) = 1;
  return H;
}

mat QuadrotorUKF::MeasurementModelGPS()
{
  mat H = zeros<mat>(measNoiseGPSCnt, stateCnt);
  H(0,0) = 1;
  H(1,1) = 1;
  H(2,2) = 1;
  H(3,3) = 1;
  H(4,4) = 1;
  H(5,5) = 1;
  H(6,6) = 1;
  H(7,7) = 1;
  H(8,8) = 1;
  H(7,12) = 1;
  H(8,13) = 1;
  return H;
}

void QuadrotorUKF::PropagateAprioriCovariance(const double time, 
                                              list<colvec>::iterator& kx, list<colvec>::iterator& ku, list<double>::iterator& kt)
{
  // Find aligned state, Time
  double mdt = NUM_INF;
  list<colvec>::iterator    k1 = xHist.begin();
  list<colvec>::iterator    k2 = uHist.begin();
  list<double>::iterator k3 = xTimeHist.begin();
  int                       k4 = 0;
  for (; k1 != xHist.end(); k1++, k2++, k3++, k4++)
  {
    double dt = fabs(*k3 - time);
    if (dt < mdt)
    {
      mdt = dt; 
      kx  = k1;
      ku  = k2;
      kt  = k3;
    }
    else
    {
      break;
    }
  }
  colvec    cx = *kx;
  double ct = *kt;
  colvec    px = xHist.back();
  double pt = xTimeHist.back();
  double dt = ct - pt;
  if (fabs(dt) < 0.001)
  {
    kx = xHist.begin();
    ku = uHist.begin();
    kt = xTimeHist.begin();
    return;
  }
  // Delete redundant states
  xHist.erase(k1, xHist.end());
  uHist.erase(k2, uHist.end());
  xTimeHist.erase(k3, xTimeHist.end());
  // rot, gravity
  mat pR = ypr_to_R(px.rows(6,8));
  colvec ag(3);
  ag(0) = 0;
  ag(1) = 0;
  ag(2) = g;
  // Linear Acceleration
  mat dv = cx.rows(3,5) - px.rows(3,5);
  colvec a = trans(pR) * (dv / dt + ag) + px.rows(9,11);
  // Angular Velocity
  mat dR = trans(pR) * ypr_to_R(cx.rows(6,8));
  colvec w = zeros<colvec>(3);
  w(0) = dR(2,1) / dt;
  w(1) = dR(0,2) / dt;
  w(2) = dR(1,0) / dt;
  // Assemble state and control
  colvec u = join_cols(a,w);
  // Generate sigma points
  GenerateSigmaPoints();
  // Mean
  for (int k = 0; k < 2*L+1; k++)
    Xa.col(k) = ProcessModel(Xa.col(k), u, Va.col(k), dt);
  // Handle jump between +pi and -pi !
  double minYaw = as_scalar(min(Xa.row(6), 1));
  double maxYaw = as_scalar(max(Xa.row(6), 1));
  if (fabs(minYaw - maxYaw) > PI)
  {
    for (int k = 0; k < 2*L+1; k++)
      if (Xa(6,k) < 0)
        Xa(6,k) += 2*PI;
  }
  // Now we can get the mean...
  colvec xa = sum( repmat(wm,stateCnt,1) % Xa, 1 );
  // Covariance
  P.zeros();
  for (int k = 0; k < 2*L+1; k++)
  {
    colvec d = Xa.col(k) - xa;
    P += as_scalar(wc(k)) * d * trans(d);
  }
  return;
}

void QuadrotorUKF::PropagateAposterioriState(list<colvec>::iterator kx, list<colvec>::iterator ku, list<double>::iterator kt)
{
  for (; kx != xHist.begin(); kx--, ku--, kt--)
  {
    list<colvec>::iterator _kx = kx;
    _kx--;
    list<colvec>::iterator _ku = ku;
    _ku--;
    list<double>::iterator _kt = kt;
    _kt--;
    *_kx = ProcessModel(*kx, *_ku, zeros<colvec>(procNoiseCnt), *_kt - *kt);
  }
}

