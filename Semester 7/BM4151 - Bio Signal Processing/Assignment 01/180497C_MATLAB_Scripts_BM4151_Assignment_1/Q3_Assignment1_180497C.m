%% 3. FIR Derivative Filters
%% 3.1 FIR Derivative Filter Properties
%% 3.1.1 Observing First Order and Central Difference Derivative Filters
clear all; clc;

T = 1;
coeff_order_1_filter = [1 -1];
gain_order_1_filter = T;
fvtool(coeff_order_1_filter,gain_order_1_filter)

coeff_3_pt_central_diff = [1 0 -1];
gain_3_pt_central_diff = 2*T;
fvtool(coeff_3_pt_central_diff,gain_3_pt_central_diff)

%% 3.1.2 Multiplying Factors to Maximize Gains

% Derivation and explanation are provided in the report.
% For first order filter: G = T/2
% For 3pt difference derivative filter: G = T

% Replotting after adjusting coefficients to obtain a unity gain
T = 1;
coeff_order_1_filter = T/2 *[1 -1];
gain_order_1_filter = T;
fvtool(coeff_order_1_filter,gain_order_1_filter)

coeff_3_pt_central_diff = T*[1 0 -1];
gain_3_pt_central_diff = 2*T;
fvtool(coeff_3_pt_central_diff,gain_3_pt_central_diff)

%% 3.2 FIR Derivative Filter Application
%% 3.2.1 Loading ECG recording

clear all; clc;
load('ECG_rec.mat');

%% 3.2.2 Adding Noise Components

fs = 128;
t = linspace(0,(size(ECG_rec,2)-1)/fs,size(ECG_rec,2));

% Adding AWGN of 10dB
ECG_with_AWGN = awgn(ECG_rec,10,'measured');

% Muscle artifact signal
muscle_artifacts = 2*sin(2*pi*t/4) + 3*sin((2*pi*t/2)+pi/4);

% Adding muscle artifacts to the noisy ecg
nECG = ECG_with_AWGN + muscle_artifacts;

figure;
plot(t,nECG)
title('nECG Signal')
xlabel('Time (s)')
ylabel('Amplitude (mV)')
% xlim([0 28])

% Supplementary plot
figure;
hold on;
plot(t,ECG_rec,'k', 'LineWidth',1.5)
plot(t,nECG)
hold off;
title('nECG Signal and ECG\_rec Signal')
xlabel('Time (s)')
ylabel('Amplitude (mV)')
legend('ECG\_rec Signal', 'nECG')
xlim([0 10])

%% 3.2.3 Applying Derivative Filters to nECG

T = 1;
% Defining filter coefficients for unity gain
% First order filter
coeff_order_1_filter = T/2 *[1 -1];
gain_order_1_filter = T;

% Three point difference derivative filter
coeff_3_pt_central_diff = T*[1 0 -1];
gain_3_pt_central_diff = 2*T;

% Order 1 filtered signal
filtered_necg_conv_order_1 = filter(coeff_order_1_filter, gain_order_1_filter, nECG);

% 3-pt Difference Diff. filtered signal
filtered_necg_conv_three_pt = filter(coeff_3_pt_central_diff, gain_3_pt_central_diff, nECG);

%% 3.2.4 Plotting the Filtered Signals

figure;
hold on;
plot(t,ECG_rec,'g')
plot(t,filtered_necg_conv_order_1, 'b','LineWidth',1)
plot(t,filtered_necg_conv_three_pt, 'r', 'LineWidth', 1)
hold off;
title('Filtered ECG Signals and ECG\_rec Signal')
xlabel('Time (s)')
ylabel('Amplitude (mV)')
legend('ECG\_rec signal', 'First Order Filtered Signal', '3 Point Central Difference Filtered Signal')
xlim([0 3]) 

figure;
subplot(2,1,1);
hold on;
plot(t,nECG,'g')
plot(t, ECG_rec, 'r')
plot(t,filtered_necg_conv_order_1, 'b','LineWidth',1.3)
hold off;
xlabel('Time (s)')
ylabel('Amplitude (mV)')
legend('nECG', 'ECG\_rec','First Order Filtered Signal')
title('Filtered ECG Signals, nECG Signal and ECG\_rec Signal')
subplot(2,1,2);
hold on;
plot(t,nECG,'g')
plot(t, ECG_rec, 'r')
plot(t,filtered_necg_conv_three_pt, 'b','LineWidth',1.3)
hold off;
xlabel('Time (s)')
ylabel('Amplitude (mV)')
legend('nECG', 'ECG\_rec','Three Point Difference Derivative Filtered Signal')
