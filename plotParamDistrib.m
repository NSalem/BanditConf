addpath('helperfuncs')

%% RL params
rl = load('Results\model_fitsMAP_exp1_20200227.mat');

imodel = 10;
params = cell2mat(rl.parameters(:,imodel));

%prior distributions (check formulas match modelsinfo{imodel}.priors;
x = linspace(0,100,1000);
x2 = linspace(0,1,1000);
priorBeta = gampdf(x,1.25,5); 
priorLR = betapdf(x2,1.1,1.1);
priorT = (betapdf(x/100,1.1,1.1));
priorf=cell(5,1);
priorf{6} = priorBeta;
for k = 1:4
    priorf{k} = priorLR;
end
priorf{5} = priorT;

for iparam = 1:numel(rl.modelsinfo{imodel}.paramnames)
    width(iparam) = 0.75/2/max(priorf{iparam}); %to match pirateplot
end

priorcol = [0.2,0.4,1];
figure();
col = repmat(.5,5,3);
subplot(1,5,1)
hold on
plot(priorBeta*width(1)+1,x,'LineStyle','--','Color',priorcol);
plot(-priorBeta*width(1)+1,x,'LineStyle','--','Color',priorcol);
pirateplot(params(:,6)',col(1,:),0,30,12,'','','','')
xticklabels('\beta');

subplot(1,5,[2:4])
hold on
for iparam = 1:4
plot(priorf{iparam}*width(iparam)+iparam,x2,'LineStyle','--','Color',priorcol);
plot(-priorf{iparam}*width(iparam)+iparam,x2,'LineStyle','--','Color',priorcol);
end
dotproperties.plotLines = [1,2;3,4];
pirateplot(params(:,1:4)',col(1:4,:),0,1,12,'','','',dotproperties)

xticklabels({'\alpha_{\mu+}','\alpha_{\mu-}','\alpha_{\sigma+}','\alpha_{\sigma-}'})


subplot(1,5,5)
hold on
plot(priorT*width(1)+1,x,'LineStyle','--','Color',priorcol);
plot(-priorT*width(1)+1,x,'LineStyle','--','Color',priorcol);
pirateplot(params(:,5)',col(1,:),0,100,12,'','','','')
xticklabels('T');


[~,p] = permTestRelated(params(:,1),params(:,2),10000)
