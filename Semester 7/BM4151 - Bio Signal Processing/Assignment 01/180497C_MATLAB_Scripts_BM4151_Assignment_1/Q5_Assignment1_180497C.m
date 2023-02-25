%% 5. IIR Filters
%% 5.1 Realizing IIR Filters
%% 5.1.1 Realizing Coefficients of a Butterworth Low Pass Filter

clear all; clc;

% Sampling Frequency
fs = 500;

%Nyquist Frequency
f_nq = fs/2;

% Order of the Kaiser Low Pass Filter calculated in Q4
M = 302;

% Cut_off frequency of the LPF - 125Hz
w_c_lpf = 125/f_nq;

% Butterworth LPF
[butter_lpf_numerator, butter_lpf_denominator]= butter(M,w_c_lpf,'low');

%% 5.1.2 Visualizing the IIR LPF

fvtool(butter_lpf_numerator, butter_lpf_denominator,'Analysis','freq')

%% 5.1.1 and 5.1.2 Designing BW LPF of Order 10

% Order 10 is used to produce stable responses. 302 is too large and
% produces unstable outputs
M = 10;

% Butterworth LPF
[butter_lpf_numerator, butter_lpf_denominator]= butter(M,w_c_lpf,'low');

fvtool(butter_lpf_numerator, butter_lpf_denominator,'Analysis','freq')

%% 5.1.3.1 Butterworth High Pass Filter

% HPF cut off frequency
w_c_hpf = 5/f_nq;

% Butterworth HPF
[butter_hpf_numerator, butter_hpf_denominator] = butter(M, w_c_hpf,'high');

fvtool(butter_hpf_numerator, butter_hpf_denominator,'Analysis','freq')

%% 5.1.3.2 Comb filters

% Cut off frequency
f_cut_off = 50;

% width of notch set to 3dB
width_paramm = 35;

% bandwidth
bandwidth = f_cut_off/(width_paramm*fs);

% Comb filter should cut off 50Hz, 100Hz, 150Hz
[comb_numerator, comb_denominator] = iircomb(fs/f_cut_off,bandwidth); 

fvtool(comb_numerator,comb_denominator)

%% 5.1.4.1 Magnitude Response of the Combined Filter

% Combined IIR Filter
IIR_combined_filter_numerator = conv(conv(butter_lpf_numerator, butter_hpf_numerator), comb_numerator);
IIR_combined_filter_denominator = conv(conv(butter_lpf_denominator, butter_hpf_denominator),comb_denominator);
fvtool(IIR_combined_filter_numerator,IIR_combined_filter_denominator)

%% 5.1.4.2 Comparing Combined FIR and IIR Filters

% From Q4, let's first import the FIR_combined filter
load('FIR_Combined_Filter.mat')

% Visualizing
fvtool(IIR_combined_filter_numerator, IIR_combined_filter_denominator, lpf_hpf_comb_filter)
legend('IIR Combined Filter', 'FIR Combined Filter')

%% 5.2 Filtering Methods using IIR Filters
%% 5.2.1 Applying Forward Filtering

load('ECG_with_noise.mat')

IIR_forward_filtered_nECG = filter(IIR_combined_filter_numerator, IIR_combined_filter_denominator, nECG);

%% 5.2.2 Applying Forward-Backward filtering

IIR_forward_backward_filtered_nECG = filtfilt(IIR_combined_filter_numerator, IIR_combined_filter_denominator, nECG);

%% 5.2.3 Generating Time Domain Plots 

load('FIR_Filtered_ECG.mat')
load('Delay_Compensated_Time.mat')

t = linspace(0,length(nECG)-1,length(nECG))/fs;

figure;
hold on;
plot(t, IIR_forward_filtered_nECG)
plot(t, IIR_forward_backward_filtered_nECG)
plot(delay_compensated_t_for_combined, lpf_hpf_comb_filtered_nECG)
hold off;
legend('IIR Forward Filtered Signal', 'IIR Forward-Backward Filtered Signal', 'FIR Filtered Signal')
title('Comparing Filtered Signals')
xlabel('Time (s)')
ylabel('Amplitude (mV)')
xlim([10.3 11.8])

%% 5.2.4 Generating PSD Estimates

[p_forward, w_forward] = periodogram(IIR_forward_filtered_nECG ,rectwin(size(IIR_forward_filtered_nECG,2)),[],fs);
[p_forward_backward, w_forward_backward]= periodogram(IIR_forward_backward_filtered_nECG, rectwin(size(IIR_forward_backward_filtered_nECG,2)),[],fs);
[p_fir, w_fir] = periodogram(lpf_hpf_comb_filtered_nECG, rectwin(size(lpf_hpf_comb_filtered_nECG,2)),[],fs);

figure;
semilogy(w_forward, p_forward)
hold on;
semilogy(w_forward_backward, p_forward_backward)
semilogy(w_fir,p_fir)
hold off;
title('PSD Estimates of the Filtered Signals')
xlabel('Frequency (Hz)')
ylabel('Amplitude')
legend('IIR Forward Filtered Signal', 'IIR Forward-Backward Filtered Signal', 'FIR Filtered Signal')