function [y_filtered , wienerWeights_freq] = customWienerFilterFrequencyDomain(desired_signal, noise, noisy_sigal)

num_samples = length(noisy_sigal);

% PSD of y_i
PSD_desired_signal = abs(fft(desired_signal, num_samples*2-1)).^2;  

% PSD of the noise
PSD_noise = abs(fft(noise, num_samples*2-1)).^2; 

% FT of the noisy signal
FFT_noisy_signal  = fft(noisy_sigal, num_samples*2-1);         

% Obtaining the weights in freq domain
wienerWeights_freq = PSD_desired_signal./(PSD_desired_signal+PSD_noise);

% Convolution in time domain is multiplication in freq domain
FFT_filtered_signal = wienerWeights_freq.*FFT_noisy_signal;  

% Inverse FT
filtered_signal = (ifft(FFT_filtered_signal)); 

y_filtered = filtered_signal(1:length(noisy_sigal)); 
end