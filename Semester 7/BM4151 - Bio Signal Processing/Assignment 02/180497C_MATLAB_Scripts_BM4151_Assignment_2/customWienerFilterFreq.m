function filtered_signal = customWienerFilterFreq(input_signal, wienerWeights)
    samples = length(input_signal);  
    FT_input  = fft(input_signal, samples*2-1);
    FT_filtered = wienerWeights.*FT_input;          
    time_domain_filtered = (ifft(FT_filtered));
    filtered_signal = time_domain_filtered(1:samples);
end