
M = 35;
V = 10;

M2 = 65;
V2 = 25;

x = [0:0.1:100]
lambda = .1


u = -exp(-lambda.*x); %% utility function 

y = exp(-((x-M).^2/(2.*V)))./sqrt(2*pi*V); %% density function of x

% expected utility
EUlowvar = integral(@(x)(-exp(-lambda.*x).*exp(-((x-M).^2./(2.*V)))),-Inf,Inf)/sqrt(2*pi*V)
EUhighvar = integral(@(x)(-exp(-lambda.*x).*exp(-((x-M).^2./(2.*V2)))),-Inf,Inf)/sqrt(2*pi*V2)

EUlowvar>EUhighvar




% y2 = (exp(-lambda.*x).*exp(-((x-M).^2./(2.*V))))/sqrt(2*pi*V);
% 
% integral(@(x)(-exp(-lambda.*x).*exp(-((x-M).^2./(2.*V)))),-Inf,Inf)/sqrt(2*pi*V)
% 
% integral(@(x)(-exp(-lambda.*x).*exp(-((x-M).^2./(2.*V2)))),-Inf,Inf)/sqrt(2*pi*V2)
% 
% 
% y21 = -(exp(-(lambda.*x+((x-M).^2./(2.*V)))))/sqrt(2*pi*V);
% 
% integral(@(x)(-exp(-(lambda.*x+((x-M).^2./(2.*V))))),-Inf,Inf)./sqrt(2*pi*V)
% 
% y22 = -(exp(lambda).*exp(-((x-M)./(2.*V))))/sqrt(2*pi*V);
% 
% y3 = (exp(lambda).*exp(-((x-M).^2./(2.*V))))/sqrt(2*pi*sqrt(V));
% 
% 
% 
% % integral(@(x)((exp(lambda).*exp(-((x-M).^2./(2.*V))))/sqrt(2*pi*sqrt(V))),50,Inf)
% 
% 
% integral(@(x)((exp(lambda).*exp(-((x-M).^2./(2.*V))))/sqrt(2*pi*V)),50,Inf)
% integral(@(x)((exp(lambda).*exp(-((x-M).^2./(2.*V))))/sqrt(2*pi*V)),50,Inf)
% 
% 
% 
% integral(@(x)((exp(lambda).*exp(-((x-M2).^2./(2.*V2))))/sqrt(2*pi*V2)),50,Inf)