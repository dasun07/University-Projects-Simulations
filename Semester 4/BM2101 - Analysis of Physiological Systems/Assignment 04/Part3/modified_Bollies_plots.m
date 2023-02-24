clc;
clear all;
close all;

%solving for i(t), g(t), gn(t)
%considering a time period of 4hours
[t,y] = ode23('modified_Bollies',[0 4],[0 0 0])
plot(t,y(:,1),'b-','LineWidth',1);
hold on;
plot(t,y(:,2),'r-','LineWidth',1);
hold on;
plot(t,y(:,3),'g-','LineWidth',1);
axis tight;
title('Modified Bollies plasma glucose/insulin/glucagon model - step input');
legend('Insulin','Glucose','Glucagon','Location','east');
xlabel('Time (h)');
ylabel('Glucagon (g/kg) & Insulin (g/kg) & Glucose (g/kg)');