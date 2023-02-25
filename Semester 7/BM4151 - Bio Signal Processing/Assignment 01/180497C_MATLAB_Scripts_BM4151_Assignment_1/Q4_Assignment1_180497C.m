%% 4 Designing FIR using Windows
%% 4.1 Characteristics of Window Functions
%% 4.1.1 Effect of the Length of the Window Function

clear all; clc;

% FDA Tool was used to design these filters 
load('FIR_Window_Rectangular_5.mat')
load('FIR_Window_Rectangular_50.mat')
load('FIR_Window_Rectangular_100.mat')

figure;
hold on;
stem(FIR_Window_Rectangular_5)
stem(FIR_Window_Rectangular_50)
stem(FIR_Window_Rectangular_100)
hold off;
legend('M=5','M=50','M=100')
title('Impulse Response of Rectangular Windows with Orders (M) 5, 50, and 100')

%% 4.1.2 Magnitude Response and Phase Response of the Rectangular Windows

fvtool(FIR_Window_Rectangular_5,1,FIR_Window_Rectangular_50,1,FIR_Window_Rectangular_100,1)
legend('M=5','M=50','M=100')

%% 4.1.3 Comparative Characteristics of Window Functions: Rectangular, Hanning, Hamming, Blackman

% Morphology
M = 50;
range = linspace(0,M,M);

FIR_window_rectangular = rectwin(M)';
FIR_window_hanning = hann(M)';
FIR_window_hamming = hamming(M)';
FIR_window_blackman = blackman(M)';

figure;
hold on;
plot(range,FIR_window_rectangular,'LineWidth',1.5)
plot(range,FIR_window_hanning,'LineWidth',1.5)
plot(range,FIR_window_hamming,'LineWidth',1.5)
plot(range,FIR_window_blackman,'LineWidth',1.5)
hold off;
ylim([0 1.3])
xlabel('Samples (n)'), ylabel('Amplitude')
title('Morphology of Window Functions'), 
legend('Rectangular','Hanning','Hamming','Blackman')

% Using fvtool to get the Magnitude response and the Phase response
% Normalized cut off frequency
wc= 0.4;

FIR_filter_rectangular = fir1(M,wc,rectwin(M+1));
FIR_filter_hanning = fir1(M,wc,hann(M+1));
FIR_filter_hamming = fir1(M,wc,hamming(M+1));
FIR_filter_blackman = fir1(M,wc,blackman(M+1));

fvtool(FIR_filter_rectangular,1,FIR_filter_hanning,1,FIR_filter_hamming,1,FIR_filter_blackman,1)
legend('Rectangular','Hanning','Hamming','Blackman')

%% 4.2 FIR Filter Design and Application using the Kaiser Window
%% 4.2.1 Plotting the Time Domain Signal and Power Spectral Density

clear all; clc;

% Noisy ECG Signal
load('ECG_with_noise.mat')
% Normal ECG Template
load('ECG_template.mat');

% Sampling frequency is 500 Hz
fs = 500;

t = linspace(0,size(nECG,2)-1,size(nECG,2))/fs;

plot(t,nECG)
title('Noisy ECG Signal')
xlabel('Time (s)')
ylabel('Amplitude (mV)')

% Plotting the PSD estimates of the noisy ECG and noise-free ECG
[p_noise,w_noise] = periodogram(nECG,rectwin(size(nECG,2)),[],fs);
[p_noise_free,w_noise_free] = periodogram(ECG_template,rectwin(size(ECG_template,2)),[],fs);

figure;
semilogy(w_noise,p_noise)
hold on;
plot(w_noise_free,p_noise_free,'r', 'LineWidth',1.5)
hold off;
title('Comparison of PSDs of Noise-free ECG and Noisy ECG')
legend('Noisy ECG','Noise-free ECG');
xlabel('Frequency (Hz)')
ylabel('Amplitude')

%% 4.2.2 Deciding the Parameters of the Filters to be used

% Low pass filter 
f_pass_lpf = 122;
f_cutoff_lpf = 125;
f_stop_lpf = 128;

% Normalized frequencies for LPF
omega_pass_lpf = 2*pi*f_pass_lpf/fs;
omega_cutoff_lpf = 2*pi*f_cutoff_lpf/fs;
omega_stop_lpf = 2*pi*f_stop_lpf/fs;

% High pass filter
f_pass_hpf = 8;
f_cutoff_hpf = 5;
f_stop_hpf = 2;

% Normalized frequencies for HPF
omega_pass_hpf = 2*pi*f_pass_hpf/fs;
omega_cutoff_hpf = 2*pi*f_cutoff_hpf/fs;
omega_stop_hpf = 2*pi*f_stop_hpf/fs;

% Comb filters
f_stop_1_comb = 50;
f_stop_2_comb = 100;
f_stop_3_comb = 150;

% Normalized frequencies for comb filter
omega_stop_1_comb = 2*pi*f_stop_1_comb/fs;
omega_stop_2_comb = 2*pi*f_stop_2_comb/fs;
omega_stop_3_comb = 2*pi*f_stop_3_comb/fs;

% Peak approximation error
d = 0.001;

%% 4.2.3 Calculating beta and M Values for the LPF and HPF

A = -20*log10(d);
delta_omega =  abs(omega_pass_lpf - omega_stop_lpf);

if A < 21
    beta = 0;
elseif A>= 21 & A <= 50
    beta = 0.5842*(A-21)^0.4 + 0.07886*(A-21);
else
    beta = 0.1102*(A - 8.7);
end

M = ceil((A-8)/(2.285*delta_omega));
if mod(M,2) ~= 0
    M = M+1;
end

%% 4.2.4.1 Visualizing the Kaiser Windows for HPF and LPF

% Length of the Kaiser Window = M + 1
Kaiser_window = kaiser(M+1,beta)';

%Nyquist frequency
f_nq = fs/2;

Kaiser_window_lpf = fir1(M, f_cutoff_lpf/f_nq, Kaiser_window);
Kaiser_window_hpf = fir1(M, f_cutoff_hpf/f_nq, 'high', Kaiser_window);

% Magnitude response and phase responses of HPF and LPF
fvtool(Kaiser_window_lpf, 1, Kaiser_window_hpf, 1)
legend('Kaiser Lowpass Filter', 'Kaiser Highpass Filter')

%% 4.2.4.2 Visualizing the Comb Filters

comb_filter = 1;
% There are three comb filter angles
% at 50Hz
comb_filter = conv(comb_filter, [1, (-exp(1i*omega_stop_1_comb) - exp(-1i*omega_stop_1_comb)) , 1]);
% at 100Hz
comb_filter = conv(comb_filter, [1, (-exp(1i*omega_stop_2_comb) - exp(-1i*omega_stop_2_comb)) , 1]);
% at 150Hz
comb_filter = conv(comb_filter, [1, (-exp(1i*omega_stop_3_comb) - exp(-1i*omega_stop_3_comb)) , 1]);

norm_factor = sum(comb_filter);
normed_comb_filter = comb_filter/norm_factor; 

fvtool(normed_comb_filter)

%% 4.2.5 Filtering the Noisy ECG Signal using the LPF, HPF and the Comb Filter

% First we will separately apply the filters to nECG to observe the
% individual filter effects
% LPF, HPF
lp_filtered_nECG = filter(Kaiser_window_lpf, 1, nECG);
hp_filtered_nECG = filter(Kaiser_window_hpf, 1, nECG);

% Comb Filtered
comb_filtered_nECG = filter(comb_filter, norm_factor, nECG);

% Now let's combine these three filters and filter the nECG
lpf_hpf_comb_filter = conv(conv(Kaiser_window_lpf, Kaiser_window_hpf),comb_filter/norm_factor);

% Filtering nECG using the combined filter
lpf_hpf_comb_filtered_nECG = filter(lpf_hpf_comb_filter, 1, nECG);

% Necessary time delay compensations
% For HPF, LPF
group_delay = M/(2*fs);
delay_compensated_t = t - group_delay;

% For Comb filter
group_delay_for_comb = (length(comb_filter)-1)/(2*fs);
delay_compensated_t_for_comb = t - group_delay_for_comb;

% For combined filter
group_delay_for_combined_filter = group_delay + group_delay + group_delay_for_comb;
delay_compensated_t_for_combined = t - group_delay_for_combined_filter;

% Visualizing the filtered signals
figure;
plot(delay_compensated_t,lp_filtered_nECG)
title('Lowpass Filtered (f_c = 125 Hz) nECG Signal')
xlabel('Time (s)')
ylabel('Amplitude (mV)')
xlim([0 115])

figure;
plot(delay_compensated_t, hp_filtered_nECG)
title('Highpass Filtered (f_c = 5Hz) nECG Signal')
xlabel('Time (s)')
ylabel('Amplitude (mV)')
xlim([0 115])

figure;
plot(delay_compensated_t_for_comb,comb_filtered_nECG)
title('Comb Filtered (f_{stop} = 50Hz, 100Hz, 150Hz) nECG Signal')
xlabel('Time (s)')
ylabel('Amplitude (mV)')
xlim([0 115])

figure;
plot(delay_compensated_t_for_combined, lpf_hpf_comb_filtered_nECG)
title('LPF + HPF + Comb Filtered nECG Signal')
xlabel('Time (s)')
ylabel('Amplitude (mV)')
xlim([0 115])

figure;
hold on;
plot(t, nECG)
plot(delay_compensated_t_for_combined, lpf_hpf_comb_filtered_nECG, 'k', 'LineWidth',1.5)
title('nECG Signal vs LPF + HPF + Comb Filtered nECG Signal')
xlabel('Time (s)')
ylabel('Amplitude (mV)')
legend('nECG','Filtered nECG')
xlim([0 5])

%% 4.2.6 Visualizing the Combined Filter and the PSD of the Filtered Signal
%% 4.2.6.1 Magnitude Response and Phase Response of the Combined Filter

fvtool(lpf_hpf_comb_filter)
%% 4.2.6.2 PSD of the Filtered Signal

[p_filtered, w_filtered] = periodogram(lpf_hpf_comb_filtered_nECG,rectwin(length(lpf_hpf_comb_filtered_nECG)),[],fs);
figure
semilogy(w_noise,p_noise,'r')
hold on
semilogy(w_filtered,p_filtered)
hold off
title('Comparing PSD of nECG Signal and Filtered Signal')
legend('nECG','Filtered ECG Signal');
xlabel('Frequency (Hz)')
ylabel('Amplitude')