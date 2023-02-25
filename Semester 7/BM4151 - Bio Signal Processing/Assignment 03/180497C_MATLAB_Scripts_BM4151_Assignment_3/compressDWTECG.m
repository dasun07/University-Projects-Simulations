function [root_mean_sqr_err, paramm_1] = compressDWTECG(signal_to_be_compressed, orig_signal, wavelet_func, num_levels, thresh_arb, name_signal)

    [decomposed, length_decomp] = wavedec(signal_to_be_compressed, num_levels, wavelet_func);
    
    % we need the decompositions in the descending order
    descending_ord_coeff = sort(abs(decomposed(:)),'descend');
    
    % plotting the decomposition
    figure('Name',['Wavelet Coefficients of ' name_signal ' : '  'Wavelet - ' wavelet_func])
    stem(descending_ord_coeff, 'filled');
    xlim([0,length(descending_ord_coeff)])
    title(['Wavelet Coefficients of ' name_signal ' : '  'Wavelet ' wavelet_func]);

    calc_energy = 0;
    paramm_1 = 0;
    if thresh_arb == 0
        total_energy = sum(abs(descending_ord_coeff).^2);
        for i = 1:1:length(descending_ord_coeff)
            calc_energy = calc_energy + abs(descending_ord_coeff(i)).^2;
            % Finding the coeffient whose cumulative sum is 99%
            if (round(calc_energy/total_energy, 2) == 0.99)
                paramm_1 = i;
                break;
            end
        end
        thresh_arb = descending_ord_coeff(paramm_1);
    end

    decomposed_filtering = decomposed;
    
    %Setting the decompositions less than the threshold to 0
    decomposed_filtering(abs(decomposed_filtering) < thresh_arb) = 0;
    
    compressed_signal = waverec(decomposed_filtering, length_decomp, wavelet_func);
    
    % Plotting the results
    figure ('Name',[name_signal ' : ' wavelet_func]);
    plot(compressed_signal, 'LineWidth', 1);
    xlim([0,length(signal_to_be_compressed)])
    title(['Compressed Signal'  ' : ' wavelet_func ' (To be compared with: ' name_signal ')'])
    xlabel('Sample Number (n)')
    ylabel('Amplitude');
    
    % Checking the disparity
    difference = orig_signal - compressed_signal;   
    root_mean_sqr_err = sqrt(sum(abs(difference).^2)/length(difference));

    figure('Name',['Comparison between the Original and Compressed ' name_signal])
    plot(1:1:length(orig_signal), orig_signal, 'LineWidth', 1)
    hold on;
    plot(1:1:length(compressed_signal), compressed_signal, 'LineWidth', 1)
    hold off;
    xlim([0,length(orig_signal)]);
    title(['Comparison between the Original ' name_signal ' and Compressed Signal '  ': ' wavelet_func ])
    xlabel('Sample Number (n)')
    ylabel('Amplitude');
    legend(['Original ' name_signal], 'Compressed Signal')
end