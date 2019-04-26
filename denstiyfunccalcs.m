
M = 35;
V = 10;

M2 = 65;
V2 = 10;

x = [0:0.1:100]
lambda = .2

y = exp(-((x-M).^2/(2.*V)))/sqrt(2*pi*sqrt(V));

y2 = -(exp(-.3).*exp(-((x-M).^2./(2.*V))))/sqrt(2*pi*V);
y22 = -(exp(.3).*exp(-((x-M)./(2.*V))))/sqrt(2*pi*V);

y3 = (exp(lambda).*exp(-((x-M).^2./(2.*V))))/sqrt(2*pi*sqrt(V));



% integral(@(x)((exp(lambda).*exp(-((x-M).^2./(2.*V))))/sqrt(2*pi*sqrt(V))),50,Inf)


integral(@(x)((exp(lambda).*exp(-((x-M).^2./(2.*V))))/sqrt(2*pi*V)),50,Inf)
integral(@(x)((exp(lambda).*exp(-((x-M).^2./(2.*V))))/sqrt(2*pi*V)),50,Inf)



integral(@(x)((exp(lambda).*exp(-((x-M2).^2./(2.*V2))))/sqrt(2*pi*V2)),50,Inf)