alpha = 0.4;
beta = 2.0;
kappa = 0.0;

acc_noise = [0.2, 0.2, 0.2];
w_noise = [0.1, 0.1, 0.1];

acc_bias = [0.02, 0.02, 0.02];
pitch_bias = 0.005;
roll_bias = 0.005;

ukfhandle = mexukf('init', alpha, beta, kappa,...
            acc_noise, w_noise, acc_bias, pitch_bias, roll_bias);

mexukf('imu', ukfhandle, IMUDATA, IMUts); 
