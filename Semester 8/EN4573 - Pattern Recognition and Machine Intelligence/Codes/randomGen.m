function y_arr = randomGen(n)
    y = zeros(100000,1);
    for i = 1:100000
        y(i) = sum(unifrnd(-sqrt(3), sqrt(3), n, 1))/sqrt(n);
    end
    y_arr = sort(y);
end
