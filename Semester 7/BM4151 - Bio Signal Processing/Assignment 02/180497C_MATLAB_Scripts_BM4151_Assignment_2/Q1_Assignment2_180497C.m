%% 1. Wiener Filtering (On Stationary Signals)

% Data construction
clearvars; 
clc;

load('idealECG.mat')
% Mean normalizing the signal
y_i = idealECG - mean(idealECG);

% Sampling frequency
f_s = 500;

% Linearly divided time scale based on f_s
t = linspace(0, length(y_i)-1, length(y_i))/f_s;

% AWGN with 10dB wrt to y_i
noise_gaussian = y_i - awgn(y_i,10,'measured');

% Sinusoidal noise signal
f_1 = 50;
noise_50 = 0.2*sin(2*pi*f_1*t);

 %add noise to ECG
x = y_i + noise_gaussian + noise_50;

figure('Name','Ideal ECG Signal')
plot(t,y_i)
xlim([0,t(end)])
title('y_i(n) -  Ideal ECG Signal')
xlabel('Time (s)')
ylabel('Amplitude (mV)')

figure('Name','Noise Added ECG Signal')
plot(t,x)
xlim([0,t(end)])
title('x(n) = y_i(n) + \eta_{wg}(n) + \eta_{50}(n) - Noisy ECG Signal')
xlabel('Time (s)')
ylabel('Amplitude (mV)')

%% 1.1 Discrete-time Domain Implementation of the Wiener Filter
%% 1.1.1 PART 1

% Beats are manually picked
selected_beat = 1.03*f_s:1.19*f_s-1;
y = y_i(selected_beat);
t_selected_range = t(selected_beat);

isoelectric_range = 1.18*f_s+1:1.22*f_s;
isoelectric_segment = x(isoelectric_range);
noise_replicated = repmat(isoelectric_segment,[1,4]);
t_n_selected_range = t(isoelectric_range);

figure('Name','Selected ECG Beat')
plot(t_selected_range,y,'LineWidth',1)
xlim([t_selected_range(1),t_selected_range(end)])
title('Selected ECG Beat')
xlabel('Time (s)')
ylabel('Amplitude (mV)')

figure('Name','Selected Noise Estimate')
plot(t_selected_range,noise_replicated,'LineWidth',1)
xlim([t_selected_range(1),t_selected_range(end)])
title('Selected Noise Estimate')
xlabel('Time (s)')
ylabel('Amplitude (mV)')

%% 1.1.1.1 Finding Optimum Weights for an Arbitrary Order

order = 10;

% Finding optimum weights for arbitrarily picked order = 10
wienerWeights = optimumWienerWeights(y, noise_replicated, order);

y_wienerFiltered_order_10 = customWienerFilter(x, wienerWeights);
figure('Name', 'Weiner Filtered Signal')
hold on;
plot(t,y_i,'k')
plot(t,x)
plot(t,y_wienerFiltered_order_10, 'LineWidth',1)
hold off;
legend('Ideal ECG','Noisy ECG','Wiener Filtered ECG (Order 10)')
title(['Impact of Wiener Filtering : Order = ' num2str(order)])
xlabel('Time (s)')
ylabel('Amplitude (mV)');

%% 1.1.1.2 Finding the Optimum Filter Order

range_for_orders = 75;
mean_sq_err_vector = NaN(1,range_for_orders);

for order = 2:range_for_orders
    wienerWeights_for_order = optimumWienerWeights(y, noise_replicated, order);
    y_wienerFiltered_for_order = customWienerFilter(x(selected_beat), wienerWeights_for_order); 
    mean_sq_err_vector(order) = immse(y_wienerFiltered_for_order, y_i(selected_beat));
end

figure('Name','MSE vs Wiener Filter Order')
plot(mean_sq_err_vector)
hold on;
[minimum_MSE, corresponding_order] = min(mean_sq_err_vector);
scatter(corresponding_order, minimum_MSE, 'MarkerFaceColor','k')
hold off;
title('MSE vs Wiener Filter Order')
xlabel('Filter Order')
ylabel('Mean Square Error');

% Extracting the weights of the optimum order
wienerWeights_for_optimum_order = optimumWienerWeights(y, noise_replicated, corresponding_order);

% Obtaining the magnitude response of the filter
fvtool(wienerWeights_for_optimum_order,1)

%% 1.1.1.3 Filtering the Noisy Signal using the Optimum Wiener Filter

y_wienerFiltered_order_42 = customWienerFilter(x, wienerWeights_for_optimum_order);

figure('Name', 'Weiner Filtered Signal')
hold on;
plot(t,y_i,'k')
plot(t,x)
plot(t,y_wienerFiltered_order_42, 'LineWidth',1)
hold off;
legend('Ideal ECG','Noisy ECG','Wiener Filtered ECG (Order 42)')
title('Impact of Wiener Filtering : Order = 42')
xlabel('Time (s)')
ylabel('Amplitude (mV)');

%% 1.1.1.4 Plotting the Spectra of the Signals

noise_signal = x - y_i;

[spectra_1,freq_1] = periodogram(y_i,[],[],f_s);
[spectra_2,freq_2] = periodogram(noise_signal,[],[],f_s);
[spectra_3,freq_3] = periodogram(x,[],[],f_s);
[spectra_4,freq_4] = periodogram(y_wienerFiltered_order_42,[],[],f_s);

figure;
hold on;
plot(freq_1,10*log10(spectra_1))
plot(freq_2,10*log10(spectra_2))
plot(freq_3,10*log10(spectra_3))
plot(freq_4,10*log10(spectra_4))
hold off;
ylim([-100,0])

legend('Ideal ECG Signal','Noise signal', 'Noisy ECG signal','Optimum Wiener Filtered Signal')
title('Power Spectral Density Comparison between the Signals')
xlabel('Frequency (Hz)')
ylabel('dB/Hz');

%% 1.1.2 PART 2

% We had 80 samples in the segment picked in the previous part
simulated_beat_samples = [1 4 6 9 12 20 28 30 33 40 48 60 65 70 75 80];
y_linear_model = zeros(1,length(y));                 

% Applying a linear model to estimate
for j = 1:length(simulated_beat_samples)-1                               
    if j==1
        linear_model_estimate = LinearModel.fit([simulated_beat_samples(j):simulated_beat_samples(j+1)],y(simulated_beat_samples(j):simulated_beat_samples(j+1)));
        y_linear_model(simulated_beat_samples(j):simulated_beat_samples(j+1)) = linear_model_estimate.Fitted;
    else
        linear_model_estimate = LinearModel.fit([simulated_beat_samples(j)+1:simulated_beat_samples(j+1)],y(simulated_beat_samples(j)+1:simulated_beat_samples(j+1)));
        y_linear_model(simulated_beat_samples(j)+1:simulated_beat_samples(j+1)) = linear_model_estimate.Fitted;
    end
end

% Arbitrarily choosing a noisy isoelectric segment
% For convenience, segment from part 1 is used
isoelectric_range = 1.18*f_s+1:1.22*f_s;
isoelectric_segment = x(isoelectric_range);
noise_replicated = repmat(isoelectric_segment,[1,4]);
t_n_selected_range = t(isoelectric_range);

figure('Name','Linear Model')
plot(y_linear_model, 'LineWidth',1);
title('Linearly Modelled ECG Wave')
xlabel('Sample Number')
ylabel('Amplitude');
xlim([0 length(y_linear_model)-1]);

figure('Name','Selected Noise Estimate')
plot(t_selected_range,noise_replicated,'LineWidth',1)
xlim([t_selected_range(1),t_selected_range(end)])
title('Selected Noise Estimate')
xlabel('Time (s)')
ylabel('Amplitude (mV)')

%% 1.1.2.1 Finding Optimum Weights for an Arbitrary Order

order_2 = 16;

% Finding optimum weights for arbitrarily picked order = 16
wienerWeights_2 = optimumWienerWeights(y_linear_model, noise_replicated, order_2);

y_wienerFiltered_order_16 = customWienerFilter(x, wienerWeights_2);
figure('Name', 'Weiner Filtered Signal')
hold on;
plot(t,y_i,'k')
plot(t,x)
plot(t,y_wienerFiltered_order_16, 'LineWidth',1)
hold off;
legend('Ideal ECG','Noisy ECG','Wiener Filtered ECG (Order 16)')
title(['Impact of Wiener Filtering : Order = ' num2str(order_2)])
xlabel('Time (s)')
ylabel('Amplitude (mV)');

%% 1.1.2.2 Finding the Optimum Filter Order

range_for_orders_2 = 75;
mean_sq_err_vector_2 = NaN(1,range_for_orders_2);

for order = 2:range_for_orders_2
    wienerWeights_for_order = optimumWienerWeights(y_linear_model, noise_replicated, order);
    y_wienerFiltered_for_order_2 = customWienerFilter(x(selected_beat), wienerWeights_for_order); 
    mean_sq_err_vector_2(order) = immse(y_wienerFiltered_for_order_2, y_i(selected_beat));
end

figure('Name','MSE vs Wiener Filter Order')
plot(mean_sq_err_vector_2)
hold on;
[minimum_MSE_2, corresponding_order_2] = min(mean_sq_err_vector_2);
scatter(corresponding_order_2, minimum_MSE_2, 'MarkerFaceColor','k')
hold off;
title('MSE vs Wiener Filter Order')
xlabel('Filter Order')
ylabel('Mean Square Error');

% Extracting the weights of the optimum order
wienerWeights_for_optimum_order_2 = optimumWienerWeights(y_linear_model, noise_replicated, corresponding_order_2);

% Obtaining the magnitude response of the filter
fvtool(wienerWeights_for_optimum_order_2,1)

%% 1.1.2.3 Filtering the Noisy Signal using the Optimum Wiener Filter

y_wienerFiltered_order_41 = customWienerFilter(x, wienerWeights_for_optimum_order_2);

figure('Name', 'Weiner Filtered Signal')
hold on;
plot(t,y_i,'k')
plot(t,x)
plot(t,y_wienerFiltered_order_41, 'LineWidth',1)
hold off;
legend('Ideal ECG','Noisy ECG','Wiener Filtered ECG (Order 41)')
title('Impact of Wiener Filtering : Order = 41')
xlabel('Time (s)')
ylabel('Amplitude (mV)');

%% 1.1.2.4 Plotting the Spectra of the Signals

noise_signal = x - y_i;

[spectra_1,freq_1] = periodogram(y_i,[],[],f_s);
[spectra_2,freq_2] = periodogram(noise_signal,[],[],f_s);
[spectra_3,freq_3] = periodogram(x,[],[],f_s);
[spectra_4_2,freq_4_2] = periodogram(y_wienerFiltered_order_41,[],[],f_s);

figure;
hold on;
plot(freq_1,10*log10(spectra_1))
plot(freq_2,10*log10(spectra_2))
plot(freq_3,10*log10(spectra_3))
plot(freq_4_2,10*log10(spectra_4_2))
hold off;
ylim([-100,0])

legend('Ideal ECG Signal','Noise signal', 'Noisy ECG signal','Optimum Wiener Filtered Signal')
title('Power Spectral Density Comparison between the Signals')
xlabel('Frequency (Hz)')
ylabel('dB/Hz');

%% 1.2 Frequency Domain Implementation of the Wiener Filter
%% 1.2.1 Implementing the Wiener Filter in Frequency Domain

noise_signal = x - y_i;

[y_wienerFiltered_freqDomain, wienerWeights_freqDomain] = customWienerFilterFrequencyDomain(y_i, noise_signal, x);

% Plotting the signals in time domain
figure('Name', 'Wiener Filtered in Frequency Domain')
hold on
plot(t, y_i)
plot(t, x)
plot(t, y_wienerFiltered_freqDomain)
hold off

legend('Ideal ECG','Noisy ECG','Wiener Filtered ECG')
title(['Impact of Wiener Filtering in Frequency Domain'])
xlabel('Time (s)')
ylabel('Amplitude (mV)');

[spectra_1_f, freq_1_f] = periodogram(y_i,[],[],f_s);
[spectra_2_f, freq_2_f] = periodogram(noise_signal,[],[],f_s);
[spectra_3_f, freq_3_f] = periodogram(x,[],[],f_s);
[spectra_4_f, freq_4_f] = periodogram(y_wienerFiltered_freqDomain,[],[],f_s);

% Plotting the PSDs of the signals
figure('Name','PSD Comparison');
hold on;
plot(freq_1_f, 10*log10(spectra_1_f))
plot(freq_2_f, 10*log10(spectra_2_f))
plot(freq_3_f, 10*log10(spectra_3_f))
plot(freq_4_f, 10*log10(spectra_4_f))
hold off;
ylim([-100 0])
legend('Ideal ECG Signal','Noise Signal','Noisy ECG Signal','Wiener Filtered Signal (in Frequency Domain)')
title('PSD Comparison between the Signals')
xlabel('Frequency (Hz)')
ylabel('dB/Hz');

%% 1.2.2 Comparing Frequency Domain Filtered Signal with Time Domain Filtered Signals

% Measuring the MSE of the filtered signals
MSE_time_domain_order_42 = immse(y_wienerFiltered_order_42, y_i);
MSE_time_domain_order_41 = immse(y_wienerFiltered_order_41, y_i);
MSE_freq_domain = immse(y_wienerFiltered_freqDomain, y_i);

% Plotting the signals
figure('Name', 'Comparison between the Filtered Signals')
hold on;
plot(t,y_i)
plot(t,y_wienerFiltered_order_42,'r')
plot(t,y_wienerFiltered_order_41,'k')
plot(t,y_wienerFiltered_freqDomain)
hold off;

legend('Desired ECG Signal','Time Domain Wiener Filtered Signal (Order 42)', 'Time Domain Wiener Filtered Signal (Order 41)','Frequency Domain Wiener Filtered Signal')
title(['Comparison between Signals Filtered in Time and Frequency Domain'])
xlabel('Time (s)')
ylabel('Amplitude (mV)');

%% 1.3 Effect of Non-stationary Noise on Wiener Filtering

% Data construction 
first_half_period = t(1:floor(length(t)/2));
second_half_period = t(floor(length(t)/2)+1:end);

% Sinusoidal noise signals
noise_1 = 0.2*sin(2*pi*50*first_half_period);
noise_2 = 0.3*sin(2*pi*100*second_half_period);

non_stationary_noise_signal = [noise_1 noise_2];

% AWGN with 10dB wrt to y_i
noise_gaussian = y_i - awgn(y_i,10,'measured');

noise_signal_ns = noise_gaussian + non_stationary_noise_signal;

% Constructing the noisy ECG signal
x_with_non_stationary_noise = y_i + noise_gaussian + non_stationary_noise_signal;

%% 1.3.1 Applying Wiener Filter on the New Noisy ECG Signal

y_ns_wienerFiltered = customWienerFilterFreq(x_with_non_stationary_noise, wienerWeights_freqDomain);

%% 1.3.2 Plotting and Interpreting the Filtered Signal

% Plotting the signal
figure('Name','Impact of Non Stationary Noise')
hold on;
plot(t,y_i)
plot(t,y_ns_wienerFiltered)
hold off
xlim([t(1),t(end)])
legend('Desired ECG Signal','Filtered Signal (Non-stationary Noise)')
title('Impact of Non-stationary Noise')
xlabel('Time (s)')
ylabel('Amplitude (mV)')


[spectra_1_2, freq_1_2] = periodogram(y_i,[],[],f_s);
[spectra_2_2, freq_2_2] = periodogram(noise_signal_ns,[],[],f_s);
[spectra_3_2, freq_3_2] = periodogram(x_with_non_stationary_noise,[],[],f_s);
[spectra_4_2, freq_4_2] = periodogram(y_ns_wienerFiltered,[],[],f_s);

% Plotting the PSDs
figure('Name','PSDs of the signals')
hold on
plot(freq_1_2, 10*log10(spectra_1_2))
plot(freq_2_2, 10*log10(spectra_2_2))
plot(freq_3_2, 10*log10(spectra_3_2))
plot(freq_4_2, 10*log10(spectra_4_2))
hold off;
legend('Desired ECG Signal','Non-stationary Noise','Noisy ECG Signal','Wiener Filtered Signal')
title('PSDs of the Signals')
ylim([-100 0])
xlabel('Frequency (Hz)')
ylabel('dB/Hz')
