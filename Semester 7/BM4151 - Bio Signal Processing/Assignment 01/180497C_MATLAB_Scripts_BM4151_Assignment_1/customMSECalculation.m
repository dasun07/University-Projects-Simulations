function calcError = customMSECalculation(noiseLessSignal,noisySignal,order)
%Inputs to the function
%noiseLessSignal - A vector
%noisySignal - A vector(Signal to be filtered)
%order - A positive integer (Order of the MA filter)
b_custom = ones(1,order)/order;
a_custom = 1;

%Using the MATLAB builtin function to filter
filtered = filter(b_custom,a_custom,noisySignal); 

tc_delay = floor((order-1)/2);
delay_compensated_signal = zeros(size(filtered));
delay_compensated_signal(1:length(filtered)-tc_delay+1)= filtered(tc_delay:end);

calcError = (1/size(noiseLessSignal,2))*((noiseLessSignal-delay_compensated_signal)*(noiseLessSignal-delay_compensated_signal)');
% calcError = immse(noiseLessSignal, delay_compensated_signal);
end