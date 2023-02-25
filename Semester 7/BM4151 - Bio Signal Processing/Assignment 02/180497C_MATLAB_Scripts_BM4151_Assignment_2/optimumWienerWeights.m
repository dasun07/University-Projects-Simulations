function wienerWeights = optimumWienerWeights(desired_signal, noisy_signal, order)
    % Initializing the variables
    auto_corr_X = 0;
    auto_corr_N = 0;
    cross_corr_X_y = 0;
    
    dummy_X = zeros(order,1);
    dummy_N = zeros(order,1);
    
    % Calculating the elements of auto and cross correlations
    for i=1:length(desired_signal)
        dummy_X(1) = desired_signal(i);
        dummy_N(1) = noisy_signal(i);
        
        auto_corr_X = auto_corr_X + toeplitz(autocorr(dummy_X,order-1));
        auto_corr_N = auto_corr_N + toeplitz(autocorr(dummy_N,order-1));
        cross_corr_X_y = cross_corr_X_y + dummy_X*desired_signal(i);
        
        dummy_X(2:order) = dummy_X(1:order-1); 
        dummy_N(2:order) = dummy_N(1:order-1);
    end
    
auto_corr_X = auto_corr_X.* mean(desired_signal.^2);
auto_corr_N = auto_corr_N.* mean(noisy_signal.^2);
 

Psi_Y = auto_corr_X./(length(desired_signal)-order);
Psi_N = auto_corr_N./(length(desired_signal)-order);
Theta_Yy = cross_corr_X_y./(length(desired_signal)-order);
    
Psi_X = Psi_Y + Psi_N;

% Implementing the Wiener Hopf equation
wienerWeights = Psi_X\Theta_Yy;
end