function [res_err, op_coeff, filter_paramm] = customRLSImplement(x, ref, forget_factor, order)

    samples_x = length(x);
        
    % Initial parameter values
    I = eye(order);
    alpha = 0.01;
    p = alpha * I;
    
    % Creating the holders for the matrices and vectors
    signal_delay_mat = zeros(order,1);    
    adapt_weights_vect = zeros(order,1);    
    filter_paramm = zeros(order,samples_x);
    op_coeff = zeros(samples_x,1);
    res_err = zeros(samples_x,1); 
    
    % Performing the loop as per the equations provided in the assignment
    for q = 1:samples_x
        % R(n) at q
        signal_delay_mat(1) = ref(q);                           
        
        k = (p * signal_delay_mat) ./ (forget_factor + signal_delay_mat' * p * signal_delay_mat);
        
        % y(n) = w(n)'.R(n)
        op_coeff(q) = signal_delay_mat'*adapt_weights_vect;  
        % e(n) = x(n) - w(n)'.R(n) = x(n) - y(n)
        res_err(q) = x(q) - op_coeff(q); 
        % w(n+1) = w(n) + ke(n)
        adapt_weights_vect = adapt_weights_vect + k * res_err(q);
        p = (p - k * signal_delay_mat' * p) ./ forget_factor;
        
        filter_paramm(:,q) = adapt_weights_vect;                            
        signal_delay_mat(2:order) = signal_delay_mat(1:order-1);            
    end

end
