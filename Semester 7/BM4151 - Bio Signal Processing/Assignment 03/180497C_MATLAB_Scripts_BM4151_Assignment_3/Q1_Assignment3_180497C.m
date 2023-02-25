%% 1. Continuous Wavelet Transform
%% 1.1 Introduction
%% 1.2 Wavelet Properties

% Answers to 1.2.1, 1.2.2, 1.2.3 are provided in the report

%% 1.2.4 Generating Mexican Hat Daughter Wavelet Function for Different Scaling Factors

% Note that for this part of the question, the code template provided in
% the wavelet_construction.m is used. 

clearvars; close all; clc;

syms p;
syms q;

% Sampling frequency
f_s = 250;
% Recording length
N = 3000;
% Range of time
t = (-N : N)/f_s;
% Range of scaling factors (provided in the assignment)
s = 0.01:0.1:2;

% Plotting the daughter wavelets
W_mesh = zeros(length(t),length(s));

W_mu_vector = zeros(1,length(s));
W_E_vector = zeros(1,length(s));

% Plot for first 10 scaling factors
figure ('Name','Mexican Hat Daughter Wavelets for Different Scaling Factors');
for val = 1:10
    W_mesh(:,val) = (2/((sqrt(3*s(val)))*(pi^(1/4))))*(1-(t/s(val)).^2).*exp((-1/2)*(t/s(val)).^2);
    
    subplot(5,2,val);
    plot(t, W_mesh(:,val), 'LineWidth',1);
    axis([-12 12 -0.5 2]);
    
    title(['s = ', num2str(s(val))]), xlabel('Time (s)'), ylabel('Amplitude');
    
    % Calculating the mean for a given scaling factor
    W_mu_vector(val) = int((2/((sqrt(3*s(val)))*(pi^(1/4))))*(1-((p/s(val)).^2)).*exp((-1/2)*(p/s(val)).^2), 'p', -inf, inf);
    % Calculating the energy for a given scaling factor
    W_E_vector(val) =  int(((2/((sqrt(3*s(val)))*(pi^(1/4))))*(1-((q/s(val)).^2)).*exp((-1/2)*(q/s(val)).^2))^2, 'q', -inf, inf);
end

% Plot for last 10 scaling factors
figure ('Name','Mexican Hat Daughter Wavelets for Different Scaling Factors');
for val = 11:20
    W_mesh(:,val) = (2/((sqrt(3*s(val)))*(pi^(1/4))))*(1-(t/s(val)).^2).*exp((-1/2)*(t/s(val)).^2);
    
    subplot(5,2,val-10);
    plot(t, W_mesh(:,val), 'LineWidth',1);
    axis([-12 12 -0.5 2]);
    
    title(['s = ', num2str(s(val))]), xlabel('Time (s)'), ylabel('Amplitude');
    
    % Calculating the mean for a given scaling factor
    W_mu_vector(val) = int((2/((sqrt(3*s(val)))*(pi^(1/4))))*(1-((p/s(val)).^2)).*exp((-1/2)*(p/s(val)).^2), 'p', -inf, inf);
    % Calculating the energy for a given scaling factor
    W_E_vector(val) =  int(((2/((sqrt(3*s(val)))*(pi^(1/4))))*(1-((q/s(val)).^2)).*exp((-1/2)*(q/s(val)).^2))^2, 'q', -inf, inf);
end

%% 1.2.5 Verifying that the Wavelet Properties are Satisfied

figure ('Name','Variations of Means and Energies of Mexican Hat Daughter Wavelets');

subplot(1,2,1);
plot(s, W_mu_vector,'-o', 'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor','k')
axis([0 2 -0.1 0.1]);
title('Means of Mexican Hat Daughter Wavelets')
xlabel('Scaling Factor (s)')
ylabel('Mean')

subplot(1,2,2);
plot(s, W_E_vector,'-o', 'LineWidth',1, 'MarkerEdgeColor','k','MarkerFaceColor','k')
axis([0 2 0.9 1.1])
title('Energies of Mexican Hat Daughter Wavelets')
xlabel('Scaling Factor (s)')
ylabel('Energy')
     
disp('Mean'), disp(W_mu_vector);
disp('Energy'), disp(W_E_vector);

%% 1.2.6 Plotting the Spectra of the Daughter Wavelets

% For this part too, template provided in the wave_construction.m was used.
% Again, we will plot two different diagram for the 20 cases

figure ('Name' , 'Spectra of Wavelets')

for val = 1:length(s)/2
    Fwavelt = fft(W_mesh(:,val))/length(W_mesh(:,val));
    hz = linspace(0,f_s/2,floor(length(W_mesh(:,val))/2)+1);
    
    subplot(5,2,val);
    plot(hz, 2*abs(Fwavelt(1:length(hz))), 'LineWidth',1)
    axis([0 5 0 0.2]);
    title(['s = ', num2str(s(val))]), xlabel('Frequency (Hz)'), ylabel('Amplitude')
end
subplot(5,2,1);
axis([0 100 0 0.02]);

figure ('Name' , 'Spectra of Wavelets')

for val = length(s)/2 +1:length(s)
    Fwavelt = fft(W_mesh(:,val))/length(W_mesh(:,val));
    hz = linspace(0,f_s/2,floor(length(W_mesh(:,val))/2)+1);
    
    subplot(5,2,val- length(s)/2);
    plot(hz, 2*abs(Fwavelt(1:length(hz))), 'LineWidth',1)
    axis([0 5 0 0.2]);
    title(['s = ', num2str(s(val))]), xlabel('Frequency (Hz)'), ylabel('Amplitude')
end

%% 1.3 Continuous Wavelet Decomposition
%% 1.3.1 Create x[n] Signal

n_part_1 = 1: 1: 3*N/2-1;
n_part_2 = 3*N/2: 1: 3*N;

% Components of the signal
x_part_1 = sin(0.5*pi*n_part_1/f_s);
x_part_2 = sin(1.5*pi*n_part_2/f_s);

% Range
n = [n_part_1, n_part_2];

% Combined Signal
x = [x_part_1, x_part_2];

figure('Name','x[n]')
plot(n, x, 'LineWidth', 1);
title('x[n]')
ylim([-1.1 1.1])
xlabel('Time (s)')
ylabel('Amplitude')

%% 1.3.2 Applying the Scaled Mexican Hat Wavelets to x[n]

% Scale range has to be changed as per the guidelines
s_new = 0.01:0.01:2; 

convolved_entries = zeros(length(s_new), length(n));

for val = 1:length(s_new)
    wavelet_for_val = (2/((sqrt(3*s_new(val)))*(pi^(1/4))))*(1-(t/s_new(val)).^2).*exp((-1/2)*(t/s_new(val)).^2);
    % Convolution
    conv_sig = conv(x, wavelet_for_val);  
    
    redundant_component = floor(length(wavelet_for_val)/2); 
    convolved_entries(val,:) = conv_sig(redundant_component+1: length(conv_sig) - redundant_component); 
end

%% 1.3.3 Visualizing the Spectrogram

h = pcolor(n, s_new, convolved_entries);
set(h, 'EdgeColor', 'none');
colormap jet
xlabel('Time (s)')
ylabel('Scale')
title('Spectrogram')
