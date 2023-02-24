t = 0:0.001:6;

%Substituting the equations obtained for g(t) and i(t)
g_t = -(4/13).*(exp((-1.4).*t).*cos((0.8).*t)) + (37/52).*(exp((-1.4).*t).*sin((0.8).*t)) + 4/13;
i_t = -(1/13).*(exp((-1.4).*t).*cos((0.8).*t)) - (7/52).*(exp((-1.4).*t).*sin((0.8).*t)) + 1/13;
figure(1);
plot(t,g_t,'LineWidth',1)
axis([0 6 0 0.4]);
title('Stability plot of g(t)');

figure(2);
plot(t,i_t,'LineWidth',1)
title('Stability plot of i(t)');
axis([0 6 0 0.1]);