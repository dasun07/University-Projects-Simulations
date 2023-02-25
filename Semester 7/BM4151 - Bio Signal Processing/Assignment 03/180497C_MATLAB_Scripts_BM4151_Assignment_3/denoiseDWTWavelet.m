function root_mean_sqr_err = denoiseDWTWavelet(noisy_signal, orig_signal, wavelet_func, num_levels, thresh_arb, name_signal)

    [decomposed, length_decomp] = wavedec(noisy_signal, num_levels, wavelet_func);
    
    % we need the decompositions in the descending order
    descending_ord_coeff = sort(abs(decomposed(:)),'descend');
    
    % plotting the decomposition
    figure('Name',['Wavelet Coefficients of ' name_signal ' : '  'Wavelet - ' wavelet_func])
    stem(descending_ord_coeff, 'filled');
    xlim([0,length(descending_ord_coeff)])
    title(['Wavelet Coefficients of ' name_signal ' : '  'Wavelet ' wavelet_func]);

    decomposed_filtering = decomposed;
    
    %Setting the decompositions less than the threshold to 0
    decomposed_filtering(abs(decomposed_filtering) < thresh_arb) = 0;
    
    denoised_signal = waverec(decomposed_filtering, length_decomp, wavelet_func);
    
    % Plotting the results
    figure ('Name',[name_signal ' : ' wavelet_func]);
    plot(denoised_signal, 'LineWidth', 1);
    xlim([0,length(noisy_signal)])
    title(['Denoised Signal'  ' : ' wavelet_func ' (To be compared with: ' name_signal ')'])
    xlabel('Sample Number (n)')
    ylabel('Amplitude');
    
    % Checking the disparity
    difference = orig_signal - denoised_signal;   
    root_mean_sqr_err = sqrt(sum(abs(difference).^2)/length(difference));

    figure('Name',['Comparison between the Original and Denoised ' name_signal])
    plot(1:1:length(orig_signal), orig_signal, 'LineWidth', 1)
    hold on;
    plot(1:1:length(denoised_signal), denoised_signal, 'LineWidth', 1)
    hold off;
    xlim([0,length(orig_signal)]);
    title(['Comparison between the Original ' name_signal ' and Denoised Signal '  ': ' wavelet_func ])
    xlabel('Sample Number (n)')
    ylabel('Amplitude');
    legend(['Original ' name_signal], 'Denoised Signal')
end