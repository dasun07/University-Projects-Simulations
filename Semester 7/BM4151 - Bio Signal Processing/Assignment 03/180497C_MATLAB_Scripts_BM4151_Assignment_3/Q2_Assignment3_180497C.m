%% 2. Discrete Wavelet Transform
%% 2.1 Introduction
%% 2.2 Applying DWT with the Wavelet Toolbox in MATLAB
%% 2.2.1 Creating the x_1[n] and x_2[n] Signals

clc;
clearvars; 
close all; 

% Sampling frequency
f_s = 512;

% x_1[n] Signal
t_part_1_x_1 = 0:1:511;
t_part_2_x_1 = 512:1:1023;
t_1 = [t_part_1_x_1 t_part_2_x_1];

x_1_part_1 = 2*sin(20* pi* t_part_1_x_1/f_s) + sin(80* pi* t_part_1_x_1/f_s);
x_1_part_2 = 0.5*sin(40* pi* t_part_2_x_1/f_s) + sin(60* pi* t_part_2_x_1/f_s);
 
x_1 = [x_1_part_1,x_1_part_2];
figure ('Name', 'x_1[n]')
plot(t_1,x_1, 'LineWidth',1);
axis([0 1024 -3 3]);
title('x_1[n] Signal')
xlabel('Sample Number (n)')
ylabel('Amplitude');

% x_2[n] Signal
n_2 = 0:1:1023;

x_2 = zeros(1, length(n_2));
x_2(1:64) = x_2(1:64) + ones(1,64);
x_2(193:256) = x_2(193:256) + 2*ones(1,length(x_2(193:256)));
x_2(129:512) = x_2(129:512) - ones(1,length(x_2(129:512)));
x_2(513:704) = x_2(513:704) + 3*ones(1,length(x_2(513:704)));
x_2(705:960) = x_2(705:960) + ones(1,length(x_2(705:960)));

figure ('Name', 'x_2[n]')
plot(n_2, x_2, 'LineWidth', 1);
axis([0 1024 -1.5 3.5]);
title('x_2[n] Signal')
xlabel('Sample Number (n)')
ylabel('Amplitude');

%% 2.2.1.1 Corrupting x_1[n] and x_2[n] with AWGN

rng(1);

y_1 = awgn(x_1, 10, 'measured');
y_2 = awgn(x_2, 10, 'measured');

figure ('Name', 'Noisy x_1 Signal')
plot(t_1, x_1, 'k', 'LineWidth', 2)
hold on
plot(t_1, y_1, 'LineWidth', 1)
hold off
axis([0 1024 -3.5 3.5]);
title('x_1[n] vs y_1[n]')
xlabel('Sample Number (n)')
ylabel('Amplitude');
legend('x_1[n]','y_1[n]');

figure ('Name', 'Noisy x_2 Signal')
plot(n_2, y_2, 'LineWidth', 1)
hold on
plot(n_2, x_2, 'k', 'LineWidth', 2)
hold off
axis([0 1024 -3.5 5]);
title('x_2[n] vs y_2[n]')
xlabel('Sample Number (n)')
ylabel('Amplitude');
legend('y_2[n]','x_2[n]');

%% 2.2.2 Observing the Morphology of Haar and Daubechies Tap 9 Wavelets

% Haar Wavelet
wavelet_1 = 'haar';
[phi_Haar, psi_Haar, val_Haar] = wavefun(wavelet_1, 10); 

figure ('Name','Haar Wavelet')

subplot(1,2,1);
plot(val_Haar, psi_Haar, 'b','LineWidth',1);
title('Haar Wavelet Function');

subplot(1,2,2);
plot(val_Haar, phi_Haar,'r', 'LineWidth',1);
title('Haar Scaling Function');

% Daubechies tap 9
wavelet_2 = 'db9';
[phi_Daube, psi_Daube, val_Daube] = wavefun(wavelet_2, 10); 

figure  ('Name','Daubechies tap 9 Wavelet')

subplot(1,2,1);
plot(val_Daube, psi_Daube,'b', 'LineWidth',1);
title('Daubechies Tap 9 Wavelet Function');

subplot(1,2,2);
plot(val_Daube, phi_Daube, 'r', 'LineWidth',1);
title('Daubechies Tap 9 Scaling Function');

% Uncomment the following line, if you want to use the wavelet analyzer
% When the GUI appears,use the option display -> wavelet display and select
% the wavelet type and its parameters

% waveletAnalyzer

%% 2.2.3 Calculating the 10-level Decomposition of the Signal

% Noisy x_1[n] Decomposition
[dec_haar_y_1, dec_len] = wavedec(y_1, 10, 'haar');
haar_10_1 = appcoef(dec_haar_y_1, dec_len, 'haar');
[dec_haar_1_1, dec_haar_2_1, dec_haar_3_1, dec_haar_4_1, dec_haar_5_1, dec_haar_6_1, dec_haar_7_1 ,dec_haar_8_1, dec_haar_9_1, dec_haar_10_1] = detcoef(dec_haar_y_1, dec_len, 1:1:10);

[dec_db_y_1, dec_len] = wavedec(y_1, 10, 'db9');
db_10_1 = appcoef(dec_db_y_1, dec_len, 'db9');
[dec_db_1_1, dec_db_2_1, dec_db_3_1, dec_db_4_1, dec_db_5_1, dec_db_6_1, dec_db_7_1 ,dec_db_8_1, dec_db_9_1, dec_db_10_1] = detcoef(dec_db_y_1, dec_len, 1:1:10);

% Noisy x_2[n] Decomposition
[dec_haar_y_2, dec_len] = wavedec(y_2, 10, 'haar');
haar_10_2 = appcoef(dec_haar_y_2, dec_len, 'haar');
[dec_haar_1_2, dec_haar_2_2, dec_haar_3_2, dec_haar_4_2, dec_haar_5_2, dec_haar_6_2, dec_haar_7_2 ,dec_haar_8_2, dec_haar_9_2, dec_haar_10_2] = detcoef(dec_haar_y_2, dec_len, 1:1:10);

[dec_db_y_2, dec_len] = wavedec(y_2, 10, 'db9');
db_10_2 = appcoef(dec_db_y_2, dec_len, 'db9');
[dec_db_1_2, dec_db_2_2, dec_db_3_2, dec_db_4_2, dec_db_5_2, dec_db_6_2, dec_db_7_2 ,dec_db_8_2, dec_db_9_2, dec_db_10_2] = detcoef(dec_db_y_2, dec_len, 1:1:10);

nLevelDecomposedSignalPlot(y_1,'haar',10);
nLevelDecomposedSignalPlot(y_1, 'db9', 10);
nLevelDecomposedSignalPlot(y_2,'haar',10);
nLevelDecomposedSignalPlot(y_2, 'db9', 10);

%% 2.2.4 Using Inverse DWT to Reconstruct the Signal

% Reconstructing y_1 - Haar
haar_A9_1 = idwt(haar_10_1, dec_haar_10_1, 'haar');
haar_A8_1 = idwt(haar_A9_1, dec_haar_9_1, 'haar');
haar_A7_1 = idwt(haar_A8_1, dec_haar_8_1, 'haar');
haar_A6_1 = idwt(haar_A7_1, dec_haar_7_1, 'haar');
haar_A5_1 = idwt(haar_A6_1, dec_haar_6_1, 'haar');
haar_A4_1 = idwt(haar_A5_1, dec_haar_5_1, 'haar');
haar_A3_1 = idwt(haar_A4_1, dec_haar_4_1, 'haar');
haar_A2_1 = idwt(haar_A3_1, dec_haar_3_1, 'haar');
haar_A1_1 = idwt(haar_A2_1, dec_haar_2_1, 'haar');

y_1_haar_recons = idwt(haar_A1_1, dec_haar_1_1, 'haar');

figure
plot(t_1, y_1_haar_recons, 'LineWidth',1);
title('Reconstructed y_1[n] - Haar');
xlabel('Sample Number (n)');
ylabel('Amplitude');
xlim([0,1023])

% Reconstructing y_1 - DB9
db9_A9_1 = idwt(db_10_1, dec_db_10_1, 'db9');
db9_A8_1 = idwt(db9_A9_1, dec_db_9_1, 'db9');
db9_A7_1 = idwt(db9_A8_1, dec_db_8_1, 'db9');
db9_A6_1 = idwt(db9_A7_1, dec_db_7_1, 'db9');
db9_A5_1 = idwt(db9_A6_1, dec_db_6_1, 'db9');
db9_A4_1 = idwt(db9_A5_1, dec_db_5_1, 'db9');
db9_A3_1 = idwt(db9_A4_1(1:79), dec_db_4_1, 'db9');
db9_A2_1 = idwt(db9_A3_1, dec_db_3_1, 'db9');
db9_A1_1 = idwt(db9_A2_1, dec_db_2_1, 'db9');

y_1_db_recons = idwt(db9_A1_1, dec_db_1_1, 'db9');

figure
plot(t_1, y_1_db_recons, 'LineWidth',1);
title('Reconstructed y_1[n] - DB9');
xlabel('Sample Number (n)');
ylabel('Amplitude');
xlim([0,1023])

% Reconstructing y_2 - Haar
haar_A9_2 = idwt(haar_10_2, dec_haar_10_2, 'haar');
haar_A8_2 = idwt(haar_A9_2, dec_haar_9_2, 'haar');
haar_A7_2 = idwt(haar_A8_2, dec_haar_8_2, 'haar');
haar_A6_2 = idwt(haar_A7_2, dec_haar_7_2, 'haar');
haar_A5_2 = idwt(haar_A6_2, dec_haar_6_2, 'haar');
haar_A4_2 = idwt(haar_A5_2, dec_haar_5_2, 'haar');
haar_A3_2 = idwt(haar_A4_2, dec_haar_4_2, 'haar');
haar_A2_2 = idwt(haar_A3_2, dec_haar_3_2, 'haar');
haar_A1_2 = idwt(haar_A2_2, dec_haar_2_2, 'haar');

y_2_haar_recons = idwt(haar_A1_2, dec_haar_1_2, 'haar');

figure
plot(n_2, y_2_haar_recons, 'LineWidth',1);
title('Reconstructed y_2[n] - Haar');
xlabel('Sample Number (n)');
ylabel('Amplitude');
xlim([0,1023])

db9_A9_2 = idwt(db_10_2, dec_db_10_2, 'db9');
db9_A8_2 = idwt(db9_A9_2, dec_db_9_2, 'db9');
db9_A7_2 = idwt(db9_A8_2, dec_db_8_2, 'db9');
db9_A6_2 = idwt(db9_A7_2, dec_db_7_2, 'db9');
db9_A5_2 = idwt(db9_A6_2, dec_db_6_2, 'db9');
db9_A4_2 = idwt(db9_A5_2, dec_db_5_2, 'db9');
db9_A3_2 = idwt(db9_A4_2(1:79), dec_db_4_2, 'db9');
db9_A2_2 = idwt(db9_A3_2, dec_db_3_2, 'db9');
db9_A1_2 = idwt(db9_A2_2, dec_db_2_2, 'db9');

y_2_db_recons = idwt(db9_A1_2, dec_db_1_2, 'db9');

figure
plot(n_2, y_2_db_recons, 'LineWidth',1);
title('Reconstructed y_2[n] - DB9');
xlabel('Sample Number (n)');
ylabel('Amplitude');
xlim([0,1023])

%% 2.2.4.1 Comparing the Energies the Original and Reconstructed Noisy Signals

energy_y_1 = sum(abs(y_1).^2);
energy_y_1_recons_haar = sum(abs(y_1_haar_recons).^2);
energy_y_1_recons_db9 = sum(abs(y_1_db_recons).^2);

energy_y_2 = sum(abs(y_2).^2);
energy_y_2_recons_haar = sum(abs(y_2_haar_recons).^2);
energy_y_2_recons_db9 = sum(abs(y_2_db_recons).^2);

disp('Energy of y_1: '), disp(energy_y_1)
disp('Energy of Reconstructed y_1 - Haar: '), disp(energy_y_1_recons_haar)
disp('Energy of Reconstructed y_1 - DB9: '), disp(energy_y_1_recons_db9)

disp('Energy of y_2: '), disp(energy_y_2)
disp('Energy of Reconstructed y_2 - Haar: '), disp(energy_y_2_recons_haar)
disp('Energy of Reconstructed y_2 - DB9: '), disp(energy_y_2_recons_db9)

%% 2.3 Signal Denoising with DWT
%% 2.3.1 Plotting the Wavelet Coefficients
%% 2.3.2 Setting a Suitable Threshold
%% 2.3.3 Calculating the RMSE
%% 2.3.4 Repeating the Process with Haar Wavelet

% Note that the first four parts of 2.3 are implemented together in the
% denoiseDWTWavelet.m script.

% Setting the thresholds
thresh_for_y_1 = 0.85;
thresh_for_y_2 = 1.95;

% Denoising, Plotting and Calculating the RMSE
root_mean_sqr_err_haar_1 = denoiseDWTWavelet(y_1, x_1, 'haar', 10, thresh_for_y_1, 'x_1[n]');
root_mean_sqr_err_db9_1 = denoiseDWTWavelet(y_1, x_1, 'db9', 10, thresh_for_y_1, 'x_1[n]');
root_mean_sqr_err_haar_2 = denoiseDWTWavelet(y_2, x_2, 'haar', 10, thresh_for_y_2, 'x_2[n]');
root_mean_sqr_err_db9_2 = denoiseDWTWavelet(y_2, x_2, 'db9', 10, thresh_for_y_2, 'x_2[n]');

disp('root_mean_sqr_err_haar_1 '), disp(root_mean_sqr_err_haar_1)
disp('root_mean_sqr_err_db9_1 '), disp(root_mean_sqr_err_db9_1)
disp('root_mean_sqr_err_haar_2 '), disp(root_mean_sqr_err_haar_2)
disp('root_mean_sqr_err_db9_2 '), disp(root_mean_sqr_err_db9_2)

%% 2.3 Signal Compression with DWT
%% 2.3.1 Obtaining the Discrete Wavelet Coefficients of the ECG Signal
%% 2.3.2 Arranging the Coefficients in the Descending Order
%% 2.3.3 Compressing the Signal and Finding the Compression Ratio

% Note that the parts 2.3.1, 2.3.2 and 2.3.3 are implemented together in
% the following code snippet.

% Loading the signal
ECGsig =  importdata('ECGsig.mat');      
signal_duration = length(ECGsig);

% Sampling Frequency
f_s = 257;
T_s = 1/f_s;
n  = 0:1:(signal_duration-1);

figure
plot(n, ECGsig, 'LineWidth', 1);
title('aV_R Lead of ECG - Time Domain');
xlabel('Sample Number (n)');
ylabel('Voltage (mV)');
xlim([0 length(ECGsig)]);

% Compressing the ECG Signal
levels_to_be_used = ceil(log2(signal_duration));

[root_mean_sqr_err_db9_ecg, K1] = compressDWTECG(ECGsig, ECGsig, 'db9', levels_to_be_used, 0, 'ECG Signal'); 
[root_mean_sqr_err_haar_ecg, K2] = compressDWTECG(ECGsig, ECGsig, 'haar', levels_to_be_used, 0, 'ECG Signal'); 
