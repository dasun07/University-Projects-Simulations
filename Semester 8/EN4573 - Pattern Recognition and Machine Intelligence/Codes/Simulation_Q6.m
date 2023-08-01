set(groot, 'defaultLineLineWidth',1.2)

y_10 = randomGen(10);
y_50 = randomGen(50);
y_100 = randomGen(100);
y_500 = randomGen(500);
y_1000 = randomGen(1000);

figure;
cdfplot(y_10)
hold on
cdfplot(y_50)
hold on
cdfplot(y_100)
hold on
cdfplot(y_500)
hold on
cdfplot(y_1000)
hold on
plot(linspace(-5,5),normcdf(linspace(-5,5),0,1),'-')
legend('n = 10','n = 50','n = 100','n = 500','n = 1000', 'Standard Normal')
title('CDF Plot of $$\sqrt{n}$$Y for n = 10, 50, 100, 500, 1000 ($$10^5$$ Samples)', 'interpreter', 'latex')
xlabel('$$\sqrt{n}Y$$','interpreter', 'latex')
ylabel('$$F_{\sqrt{n}Y}(z)$$','interpreter', 'latex')
axis tight
hold off
    
    