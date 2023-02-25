function nLevelDecomposedSignalPlot(signal, wavelet_func, levels)

[decomposed, length_dec] = wavedec(signal, levels, wavelet_func);
coeffs_app = appcoef(decomposed, length_dec, wavelet_func);

figure('Name','Approximated Coefficients')
stem(coeffs_app, 'filled');
title(['Approximated Coefficients when levels = ' num2str(levels)]);

figure('Name','Decomposition of the Signal')
for level= 1:levels
    decomp_coeff = detcoef(decomposed, length_dec, level);
    subplot(levels, 1, level);
    stem(decomp_coeff,'filled');
    title(['Level:' num2str(level) ' Wavelet Function: ' wavelet_func]);
end
