function estimated_signal = customWienerFilter(input_signal, wienerWeights)
    order = length(wienerWeights);
    estimated_signal = zeros(size(input_signal));
    
    % implementing convolution
    for i = 1: length(input_signal)- order
        estimated_signal(i) = input_signal(i:i+order-1)* wienerWeights;
    end
    
end