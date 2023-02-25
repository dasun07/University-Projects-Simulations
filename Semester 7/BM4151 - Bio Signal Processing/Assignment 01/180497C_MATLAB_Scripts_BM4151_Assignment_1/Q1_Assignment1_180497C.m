%% 1. Smoothing Filters
%% 1.1 Moving Average Filter
%% 1.1.1 Preliminaries
%% 1.1.1.1 Loading the ECG_template.mat

clear all; clc;

% Sampling frequency (f_s) = 500Hz
% Amplitude range          = mV

load('ECG_template.mat');
orig_ecg_signal = ECG_template;

%% 1.1.1.2 Plotting the loaded raw signal

% The size of the template is (1,340)
time_steps = size(orig_ecg_signal,2);

% Sampling frequency is 500Hz
fs = 500;

% Obtaining the linearly spaced time axis
T = linspace(0,time_steps/fs,time_steps);

% Plotting the template
figure('name','Original ECG Signal')
plot(T, orig_ecg_signal)
title('ECG Template')
xlabel('Time (s)')
ylabel('Amplitude (mV)')

% Plotting the template with additional features
figure('name','Original ECG Signal with features')
hold on;
plot(T, orig_ecg_signal, 'LineWidth', 2)
title('ECG Template')
xlabel('Time (s)')
ylabel('Amplitude (mV)')
y = ylim;
% The following values for segments and intervals
% were handpicked after observing the wavelet
plot([0.08425 0.08425],[y(1) y(2)], 'k--')
plot([0.1424 0.1424],[y(1) y(2)], 'k--')
plot([0.1665 0.1665],[y(1) y(2)], 'k--')
plot([0.2828 0.2828],[y(1) y(2)], 'k--')
plot([0.353 0.353],[y(1) y(2)], 'k--')
plot([0.5356 0.5356],[y(1) y(2)], 'k--')
hold off;
%% 1.1.1.3 Adding White Gaussian Noise of 5dB

% Adding noise
nECG = awgn(orig_ecg_signal,5,'measured');

% Plotting the noisy signal
figure('Name','Noisy ECG Signal')
plot(T,nECG);
title('Noise Added ECG Signal')
xlabel('Time (s)')
ylabel('Amplitude (mV)')

% Plotting the noisy signal with the original signal
figure('Name','Noisy vs Original ECG Signal')
hold on;
plot(T,nECG);
plot(T,orig_ecg_signal,'r','LineWidth',2)
title('Original ECG Signal and Noise Added ECG Signal')
legend('ECG Signal after Noise Addition','ECG Signal before Noise Addition');
xlabel('Time (s)')
ylabel('Amplitude (mV)')
hold off;
%% 1.1.1.4 Plotting the PSD

figure('Name', 'PSD')
window = rectwin(time_steps);
[p_noisy,w_noisy] = periodogram(nECG,window,512,fs);
[p_orig,w_orig] = periodogram(ECG_template,window,512,fs);
semilogy(w_noisy,p_noisy, w_orig,p_orig,'r')
title('Power Spectral Density Estimate')
legend('ECG Signal after Noise Addition','ECG Signal before Noise Addition');
xlabel('Frequency (Hz)')
ylabel('Amplitude (log)')

%% 1.1.2 MA(3) Filter Implementation with Custom Script
%% 1.1.2.1 Implementing a Custom Script for MA Filter

% The function script is found in the file customMovingAvg.m
order = 3;
ma3ECG_1 = customMovingAvg(nECG,order);

%% 1.1.2.2 Deriving the Group Delay

% In the report, the proof for the group delay (tau_g) = [(order-1)/2]T_s
% given
tau_g = ((order - 1)/2)*(1/fs);

%% 1.1.2.3 Plotting the Delay Compensated 'ma3ECG_1' and 'nECG' Signals

delay_compensated_T = T-tau_g;
figure('name', 'maECG_1 normal vs delay compensated')
hold on;
plot(T,ma3ECG_1,'r');
plot(delay_compensated_T,ma3ECG_1,'b')
title('Uncompensated vs Delay Compensated Signals')
legend('Uncompensated maECG_1', 'Delay Compensated ma3ECG_1');
hold off;

figure('name', 'nECG vs delay compensated ma3ECG_1')
hold on;
plot(delay_compensated_T,ma3ECG_1,'b', 'LineWidth',2);
plot(T,nECG,'r')
title('nECG vs Delay Compensated ma3ECG_1')
legend('Delay Compensated maECG_1','nECG');
hold off;


% This is a supplementary plot to emphasize that the delay is T_s = 0.002
figure('name', 'maECG_1 normal vs delay compensated')
hold on;
plot(T,ma3ECG_1,'r');
plot(delay_compensated_T,ma3ECG_1,'b')
y = ylim;
plot([0.01605 0.01605],[y(1) y(2)], 'k--')
plot([0.01805 0.01805],[y(1) y(2)], 'k--')
title('Uncompensated vs Delay Compensated Signals')
legend('Uncompensated maECG_1', 'Delay Compensated ma3ECG_1');
hold off;

%% 1.1.2.4 PSDs of 'ma3ECG_1' and 'nECG' Signals

[p_noisy_1,w_noisy_1] = periodogram(nECG,window,512,fs);
[p_filtered_1,w_filtered_1] = periodogram (ma3ECG_1,window,512,fs);

figure('Name','PSDs of nECG and ma3ECG_1 Signals');
semilogy(w_noisy_1,p_noisy_1, w_filtered_1,p_filtered_1,'r')
title('Power Spectral Density Estimate')
legend('nECG Signal','ma3ECG_1 Signal');
xlabel('Frequency (Hz)')
ylabel('Amplitude (log)')

%% 1.1.3 MA(3) Implementation with MATLAB Built-in Function
%% 1.1.3.1 Using filter(b,a,x) Command 

% x - signal
% a - coeff.s of output
% b - coeff.s of input
a_3 = 1;
b_3 = ones(1,order)/order;
ma3ECG_2 = filter(b_3,a_3,nECG);

%% 1.1.3.2 Plotting nECG, ECG_template and ma3ECG_2

figure('Name','nECG, ECG_template and ma3ECG_2 Signals');
hold on;
plot(T,nECG,'b')
plot(T,orig_ecg_signal,'k', 'LineWidth',2);
plot(T,ma3ECG_2,'r','LineWidth',1.5)
hold off;
title('nECG, ECG_{template} and ma3ECG_2 Signals');
legend('nECG', 'ECG_{template}','ma3ECG_2');
xlabel('Time(s)')
ylabel('Amplitude (mV)')

%% 1.1.3.3 Using fvtool(b,a) Command

% a = 1
% b = (1/3, 1/3, 1/3)
fvtool(b_3,a_3)

%% 1.1.4 MA(10) Filter Implementation with MATLAB Built-in Function
%% 1.1.4.1 Using fvtool(b,a) Command

order = 10;
b_10 = ones(1,order)/order;
a_10 = 1;

fvtool(b_10,a_10)

%% 1.1.4.2 Filtering nECG using MA(10) Filter

ma10ECG = filter(b_10,a_10,nECG);

%% 1.1.4.3 Ploting nECG, ECG_template, ma3ECG_2 and ma10ECG Signals

tau_g_10 = (order-1)/2*(1/fs);
delay_compensated_T_10 = T-tau_g_10;
figure('Name','nECG, ECG_{Template}, ma3ECG_2, ma10ECG Signals');
hold on;
plot(T,nECG,'g')
plot(T,orig_ecg_signal,'k','LineWidth',1.5)
plot(delay_compensated_T,ma3ECG_2,'b','LineWidth',1.3)
plot(delay_compensated_T_10,ma10ECG,'r','LineWidth',2);
title('nECG, ECG_{Template}, ma3ECG_2, ma10ECG Signals');
legend ('nECG', 'ECG_{template}','ma3ECG_2','ma10ECG')
xlabel('Time(s)')
ylabel('Amplitude (mV)')

%% 1.1.5 Optimum MA(N) Filter Order
%% 1.1.5.1 Implementing a Custom Script to Calculate MSE

% The function script is found in the file customMSECalculation.m

%% 1.1.5.2 Determining the Optimum Filter Order

order_range = 50;
error_for_order = zeros(1,order_range-2);

for n_item = 3:order_range
    error_for_order(n_item-2) = customMSECalculation(orig_ecg_signal,nECG,n_item);
end

% Using the min function to get the filter order that yields the minimum
% error
[~,optimum_order] = min(error_for_order);
smooth_MSE = smooth(error_for_order)';
min_MSE = smooth_MSE(1,optimum_order);
optimum_order = optimum_order+2;

b_optimum = ones(1,optimum_order)/optimum_order;
a_optimum =  1;

maECG_optimum = filter(b_optimum,a_optimum,nECG);
order_axis = linspace(1,order_range,order_range);
order_axis = order_axis(1,3:end);

tau_g_optimum = (optimum_order-1)/2*(1/fs);
delay_compesated_T_optimum = T-tau_g_optimum;

figure('Name','MSE vs Filter Order');
hold on;
plot(order_axis ,smooth_MSE)
plot(optimum_order, min_MSE, 'ko', 'MarkerFaceColor','k')
hold off;
title('MSE vs Filter Order');
xlabel('Filter order (N)')
ylabel('Mean Squared Error')

%% 1.1.5.3 Reasons for Behaviour of MSE vs Order Plot

% The explanation is provided in the report.

%% 1.2 Savitzky-Golay Filter
%% 1.2.1 Application of SG Filter
%% 1.2.1.1 Applying SG(3,11) Filter on nECG

% n - 3
% L - 11
N = 3;
L_dash = 2*11 + 1;
sg310ECG = sgolayfilt(nECG,N,L_dash);

%% 1.2.1.2 Plotting nECG, ECG\_{Template}, sg310ECG

figure('Name','nECG, ECG_{Template}, sg310ECG Signals');
hold on;
plot(T,nECG,'g')
plot(T,orig_ecg_signal,'k','LineWidth',1.5)
plot(T,sg310ECG,'b','LineWidth',1.3)
title('nECG, ECG_{Template},and sg310ECG Signals');
legend ('nECG', 'ECG_{template}','sg310ECG')
xlabel('Time(s)')
ylabel('Amplitude (mV)')

%% 1.2.2 Optimum SG(N,L) Filter Parameters
%% 1.2.2.1 Determining the Optimum Filter Parameters

L_upperBound = 30;
N_upperBound = 58;
error_for_paramm = NaN([L_upperBound,N_upperBound]);
% Iterating through the selected L and N values
for l_item = 1:L_upperBound
    n_max = min([(2*l_item),N_upperBound]);
    for n_item = 1:n_max
        filtered_test_signal = sgolayfilt(nECG,n_item,(2*l_item+1));
        error_for_paramm(l_item,n_item) =immse(filtered_test_signal,orig_ecg_signal);
    end
end

% Finding the optimum parameters for which the MSE is minimum
[optimum_paramm_vec, optimum_paramm_indices] = min(error_for_paramm);
[~, optimum_N] = min(optimum_paramm_vec); 
optimum_L = optimum_paramm_indices(optimum_N);
optimum_L_dash = 2*optimum_L + 1; 

min_MSE = immse(sgolayfilt(nECG,optimum_N,optimum_L_dash),orig_ecg_signal);

% Generating the surf plot
L_mesh_range = linspace(1,L_upperBound,L_upperBound);
N_mesh_range = linspace(1,N_upperBound,N_upperBound);
figure('Name','MSE vs Parameters of SG Filters');
surf(L_mesh_range,N_mesh_range,error_for_paramm')
shading interp
hold on
plot3(optimum_L, optimum_N, min_MSE,'ko', 'MarkerFaceColor','k','MarkerSize',10)
hold off
title('MSE vs Parameters of SG Filters')
xlabel('Input Data Points')
ylabel('Order of the Polynomial')
zlabel('MSE')

%% 1.2.2.2 Plotting ECG_Template, sg310ECG and sgECG_optimum Signals

sgECG_optimum = sgolayfilt(nECG,optimum_N,optimum_L_dash); 
figure('Name','ECG_{template}, sg310ECG and sgECG_optimum Signals');
hold on;
plot(T,orig_ecg_signal,'k','LineWidth', 1.2)
plot(T,sg310ECG,'b')
plot(T,sgECG_optimum,'r','LineWidth',1.5)
hold off;
title('ECG_{template}, sg310ECG and sgECG_{optimum} Signals');
legend ('ECG_{template}','sg310ECG','sgECG_{optimum}')
xlabel('Time (s)')
ylabel('Amplitude (mV)')

%% 1.2.2.3 Comparison between MA(N) and SG(N,L) Filters

figure('Name','Final Comparison');
hold on;
plot(T,nECG,'g')
plot(T,orig_ecg_signal, 'k','LineWidth', 1.3)
plot(delay_compesated_T_optimum,maECG_optimum,'b', 'LineWidth',1.5)
plot(T,sgECG_optimum,'r','LineWidth',1.5);
hold off;
title('Comparison between Optimum MA and SG Filters');
legend ('nECG', 'ECG_{template}','maECG_{optimum}','sgECG_{optimum}')
xlabel('Time (s)')
ylabel('Amplitude (mV)')
