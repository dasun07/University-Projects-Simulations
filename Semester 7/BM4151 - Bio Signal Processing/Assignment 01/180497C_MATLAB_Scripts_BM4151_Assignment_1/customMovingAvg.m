function filteredSignal = customMovingAvg(inputSignal, order) 
    time_steps = size(inputSignal,2);
    filteredSignal = zeros(1, time_steps);
    % First order-1 data points would not be averaged
    filteredSignal(1:order-1) = inputSignal(1:order-1);
    for time_step = order:time_steps
        filteredSignal(time_step) = sum(inputSignal(time_step-order+1:time_step))/order;
    end
end
