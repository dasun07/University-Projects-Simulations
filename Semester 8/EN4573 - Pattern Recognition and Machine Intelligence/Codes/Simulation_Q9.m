set(0, 'DefaultLineLineWidth', 1.3);
m = 10;
mean_x = 2;
theta_0 = 1;
theta = theta_0;
num_iterations = 4;

L_func = log(exp(theta_0)-1) - mean_x*log(theta_0);

theta_range = 0.1:0.01:4.5;
L_func_plot = log(exp(theta_range)-1) - mean_x*log(theta_range);
surr_func = log(exp(theta_0)-1)+ (exp(theta_0)/(exp(theta_0)-1))*(theta_range - theta_0) - mean_x*log(theta_range);

cmap= hsv(num_iterations+1);
figure;

hold on;
plot(theta_range, surr_func, 'Color',cmap(1,:))
text(theta_range(end), surr_func(end),"Iteration 0",'Color', cmap(1,:));
hold on;


for i = 1:num_iterations
    theta(i+1) = (exp(theta(i))-1)*mean_x/exp(theta(i));
    L_func(i+1) = log(exp(theta(i+1))-1) - mean_x*log(theta(i+1));
    surr_func = log(exp(theta(i+1))-1)+ (exp(theta(i+1))/(exp(theta(i+1))-1))*(theta_range - theta(i+1)) - mean_x*log(theta_range);
    plot(theta_range, surr_func, 'Color',cmap(i+1,:))
    hold on;
    if i == num_iterations
        text(theta_range(end), surr_func(end)-0.045,"Iteration "+ num2str(i),'Color',cmap(i+1,:));
    else
        text(theta_range(end), surr_func(end),"Iteration "+ num2str(i),'Color',cmap(i+1,:));
    end
    xlim([0,4.8])
    plot(theta(i+1),L_func(i+1),'bo', 'MarkerFaceColor','b')
    hold on
end
plot(theta_range, L_func_plot, 'k')
text(theta_range(end), L_func_plot(end),"L(\theta)",'Color','k');
% legend('L(\theta)', 'Iteration 0', 'Iteration 1', 'Iteration 2', 'Iteration 3', 'Iteration 4', 'Iteration 5', 'Iteration 6', 'Iteration 7', 'Iteration 8', 'Iteration 9', 'Iteration 10', 'Iteration 11', 'Iteration 12', 'Iteration 13')
plot(theta(1),L_func(1),'bo', 'MarkerFaceColor','b')
hold on
for i = 1:num_iterations
    plot(theta(i+1),L_func(i+1),'bo', 'MarkerFaceColor','b')
    hold on
end
xlabel('\theta')
title('L(\theta) and Surrogate Function for 4 Iterations')
grid on
hold off
my_arr = cat(1, cat(1,(0:num_iterations), theta),L_func)';



