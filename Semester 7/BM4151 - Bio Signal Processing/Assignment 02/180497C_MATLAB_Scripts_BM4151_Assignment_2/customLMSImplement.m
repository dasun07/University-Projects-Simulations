function [res_err, op_coeff, filter_paramm] = customLMSImplement(x, ref, lr, order)
    samples_x = length(x);
    
    UB_lambda = 20*order*((x*x')/samples_x);
    
    if ~(lr < 2/UB_lambda ) 
        lr = 2/UB_lambda;
    end
    
    % Initializing the parameters
    weights_vect = zeros(order,1);
    delay_mat = zeros(order,1); 
    filter_paramm = zeros(samples_x,order);
    op_coeff = zeros(1,samples_x);
    res_err = zeros(1,samples_x);

    for k = 1:samples_x
        delay_mat(1) = ref(k);          
        % Error term
        op_coeff(k) = weights_vect'*delay_mat;        
        res_err(k) = x(k) - op_coeff(k); 
        % Weights update algo (Widrow Hoff)
        weights_vect = weights_vect + 2*lr*res_err(k)*delay_mat;   
        filter_paramm(k,:) = weights_vect;                
        delay_mat(2:order) = delay_mat(1:order-1);        
    end
end