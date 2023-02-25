%% 2. Ensemble Averaging
%% 2.1 Signal with Multiple Measurements
%% 2.1.1 Preliminaries
%% 2.1.1.1 Clearing the Workspace and Command Window 

clear all; clc;

%% 2.1.1.2 Loading ABR_rec.mat

load ABR_rec.mat;

%% 2.1.1.3 Plotting the Train of Stimuli and ABRs

figure('Name','Recorded Data')
plot(ABR_rec)
legend('Stimuli','ABR train');
title('Train of Stimuli and ABRs')
xlabel('Sample (n)')
ylabel('Amplitude (mV)')

%% 2.1.1.4 Determining a Voltage Threshold

% Using the value given in the assignment
arbitrary_threshold = 50; 
thresh = find(ABR_rec(:,1)>arbitrary_threshold);

%% 2.1.1.5 Extracting Actual Stimulus Points

j=1;
for i=1:length(thresh)-1
    if thresh(i+1)-thresh(i)>1
        stim_point(j,1)=thresh(i+1);
        j=j+1;
    end
end

%% 2.1.1.6 Windowing ABR epochs

% -80 : 399 points were selected
% Duration of ABR to be 12ms (taking a window from -2ms to +10ms from
% stimulus point)
j = 0;
for i=1:length(stim_point) 
    j = j + 1;
    epochs(:,j) = ABR_rec((stim_point(i)-80:stim_point(i)+399),2); 
end 

%% 2.1.1.7 Calculating the Average of All Epochs

ensmbl_avg = mean(epochs(:,(1:length(stim_point))),2);

%% 2.1.1.8 Plotting the Ensemble Averaged ABR Waveform

figure,
plot((-80:399)/40,ensmbl_avg)
xlabel('Time (ms)')
ylabel('Voltage (uV)')
title(['Ensemble averaged ABR from ',num2str(length(epochs)),' epochs'])

%% 2.1.2 Improvement of the SNR
%% 2.1.2.1 Writing a MATLAB Script to Calculate Progressive MSEs

M = size(epochs,2);
mse_k = zeros(M,1);

% Looping over the first 1033 integers
for m = 1:M
    y_k = mean(epochs(:,(1:m)),2);
    % the built-in function immse is used to calculate MSE
    mse_k(m) = immse(ensmbl_avg,y_k);
end

log_mse_k = 10*log10(mse_k);

%% 2.1.2.2 Plotting MSE_k vs k

k = linspace(1,M,M);
figure;
plot(k,mse_k)
xlabel('Epochs (k)')
ylabel('MSE')
xlim([0,1050]);
title('MSE Variation against k')

% This is a supplementary plot for the variation
figure;
plot(k, log_mse_k)
xlabel('Epochs (k)')
ylabel('MSE (10log10)')
xlim([0,1050]);
title('10log10(MSE) Variation against k')

%% 2.2 Signals with repetitive patterns
%% 2.2.1 Viewing the Signal and Addition of AWGN
%% 2.2.1.1 Clearing the Workspace and Loading ECG_rec.mat

clear all; clc;
load ECG_rec.mat;

%% 2.2.1.2 Plotting the Data and Observing the Waveforms

t = size(ECG_rec,2);
% Sampling frequency is given to be 128Hz
fs = 128;
T = linspace(0,t/fs,t);

figure;
plot(T,ECG_rec)
title('ECG Pulse Train')
xlabel('Time (s)')
ylabel('Voltage (mV)')

%% 2.2.1.3 Extracting a single PQRST Waveform

% Finding the locations of peaks using built-in function findpeaks
[~, indices] = findpeaks(ECG_rec,'MinPeakHeight',1);

periodicity = mean(indices(2:end)-indices(1:end-1));

% Choosing a pulse (Detected 79 peaks, picking one after a few observations)
selected_pulse = indices(17);

% Naming the chosen pulse
ECG_template = ECG_rec(ceil(selected_pulse-0.4*periodicity):ceil(selected_pulse+0.6*periodicity));

figure;
plot(ECG_template)
title('Chosen ECG Waveform')
ylabel('Voltage (mV)')

%% 2.2.1.4 Adding Gaussian White Noise of 5dB to ECG_Rec

nECG = awgn(ECG_rec,5,'measured');

% Supplementary Plot
figure;
plot(T, nECG)
title('nECG Waveform')
ylabel('Voltage (mV)')
xlim([10.3,14.3])

%% 2.2.2 Segmenting ECG into separate epochs and ensemble averaging
%% 2.2.2.1 Calculating the Normalized Cross-correlation

% Extending the template to match the length of nECG
ECG_template_extended = ECG_template;
ECG_template_extended(length(ECG_template)+1:length(nECG)) = 0;

[X_corr, lag_elements] = xcorr(nECG,ECG_template_extended,'coeff');

%% 2.2.2.2 Plotting the Normalized Cross-correlation Values

figure;
plot(lag_elements/fs, X_corr)
title('Normalized Cross-correlation Values')
xlabel('Lag (s)')
ylabel('Normalized X\_corr Value')
% From -60 to 0 lag (s), X_corr is 0. Let's trim that region
xlim([0 60])

%% 2.2.2.3 Segmenting ECG Pulses by Defining a Threshold

% Thresholding
arbitrary_threshold = 0.08;
direct_hits_for_thresh = lag_elements(X_corr > arbitrary_threshold);

% Defining an arbitrary gap to ignore close values
min_arbitrary_separation = 10;

segmented_ECG_pulses = [];
segmented_ECG_pulse_values = [];

for i = 1:length(direct_hits_for_thresh)-1
    % Separation must be greater than 10
    if direct_hits_for_thresh(i+1)- direct_hits_for_thresh(i)> min_arbitrary_separation
        segmented_ECG_pulses = [segmented_ECG_pulses direct_hits_for_thresh(i)+1]; 
        segmented_ECG_pulse_values = [segmented_ECG_pulse_values X_corr(floor(length(X_corr)/2) + direct_hits_for_thresh(i)+1)];
    end
end

% Store pulses
ECG_pulse_indices = segmented_ECG_pulses;
ECG_pulse_values = nECG(segmented_ECG_pulses);

%% 2.2.2.4 Plotting the Improvement in SNR

ECG_pulse_train = [];
for i = 1:length(ECG_pulse_indices)
    ECG_pulse_train = [ECG_pulse_train; nECG(ECG_pulse_indices(i):ceil(ECG_pulse_indices(i)+periodicity))]; %pulse extraction
end

calc_SNR_vector = zeros(size(ECG_pulse_indices));
cal_MSE_vector = zeros(size(ECG_pulse_indices));

% Using the built in functions to calculate the MSE and SNR
% For k = 1, we dont have to separately find a mean
calc_SNR_vector(1) = snr(ECG_template,ECG_pulse_train(1,:));
cal_MSE_vector(1) = immse(ECG_template, ECG_pulse_train(1,:));

% For k = 2:74, mean has to be calculated
for k = 2:length(ECG_pulse_indices)
    cal_MSE_vector(k) = immse(ECG_template, mean(ECG_pulse_train(1:k,:)));
    calc_SNR_vector(k) = snr(ECG_template,mean(ECG_pulse_train(1:k,:)));
end

plot(calc_SNR_vector)
title('Improvement in SNR')
xlabel('Number of Pulses')
ylabel('SNR (dB)')

%% 2.2.2.5 Plotting and Comparing an nECG Pulse and Two Ensemble Averaged Pulses

% Selecting a noisy ECG Pulse
% Using nECG pulse corresponding to the ECG_Template
noisy_ECG_template = nECG(ceil(selected_pulse-0.4*periodicity):ceil(selected_pulse+0.6*periodicity));

% Selecting two arbitrary ensemble averaged ECG pulses
% Taking 30 and 60
ens_avg_30 = mean(ECG_pulse_train(1:30,:));
ens_avg_60 = mean(ECG_pulse_train(1:60,:));

figure;
hold on;
plot(ECG_template,'k','LineWidth',1.6)
plot(noisy_ECG_template, 'g', 'LineWidth', 1.3)
plot(ens_avg_30, 'b', 'LineWidth', 1.5)
plot(ens_avg_60,'r', 'LineWidth', 1.5)
hold off;

title('ECG Template, Noisy ECG Template and Ensemble Averages')
xlabel('No. of Samples (n)')
ylabel('Amplitude (mV)')
legend('ECG Template','Noisy ECG Template', 'Ensemble Average (30 Epochs)','Ensemble Average (60 Epochs)')

%% 2.2.2.6 Justification of the Claim (Supplementary Plots)

arbitrary_f_range = fs*5;
arbitrary_T_range = linspace(1,arbitrary_f_range,arbitrary_f_range)/fs;
arbitrary_ECG_rec = ECG_rec(1:arbitrary_f_range);
arbitrary_nECG = nECG(1:arbitrary_f_range);
arbitrary_indices = ECG_pulse_indices(ECG_pulse_indices<arbitrary_f_range)/fs;
arbitrary_ECG_vals = ECG_pulse_values(ECG_pulse_indices<arbitrary_f_range);
arbitrary_X_corr_vals = X_corr(floor(length(X_corr)/2)+1:floor(length(X_corr)/2+arbitrary_f_range));

figure;
subplot(3,1,1);
plot(arbitrary_T_range,arbitrary_ECG_rec)
title('ECG Recording')
xlabel('Time (s)')
ylabel('Amplitude (mV)')

subplot(3,1,2);
plot(arbitrary_T_range, arbitrary_X_corr_vals)
title('Normalized Cross-correlation Values')
xlabel('Lag (s)')
ylabel('Normalized X\_corr (mV)')

subplot(3,1,3);
hold on;
plot(arbitrary_T_range,arbitrary_nECG)
plot(arbitrary_indices ,arbitrary_ECG_vals,'ko', 'MarkerFaceColor','k')
hold off
title('nECG and Pulse Starting Points')
xlabel('Time (s)')
ylabel('Amplitude (mV)')
