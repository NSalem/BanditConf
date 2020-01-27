addpath('ModelingFuncs\')
addpath('helperfuncs');

loadExp1;

Choices = Choices + 2;
Choices(Choices==3) = 2;

conflevels = linspace(0,1,12);

confTransformed = AbsConf;
for ie = 1:numel(AbsConf)
    confTransformed(ie) = conflevels(AbsConf(ie)+6);
end

loadModelsInfoCONF; 

ntrials = size(Choices,1);

whichmodels =1%1:numel(modelsinfo);
options = optimset('Algorithm', 'interior-point', 'Display', 'final', 'MaxIter', 10000); % These increase the number of iterations to ensure the convergence

ll = NaN(size(Choices,2),numel(whichmodels));
LPP = NaN(size(Choices,2),numel(whichmodels));
LAME = NaN(size(Choices,2),numel(whichmodels));
bic = NaN(size(Choices,2),numel(whichmodels));
aic = NaN(size(Choices,2),numel(whichmodels));

for imodel = whichmodels;
    lb = modelsinfo{imodel}.lb;
    ub = modelsinfo{imodel}.ub;
    x0 = modelsinfo{imodel}.x0;
    for isub = 1:size(Choices,2)
        [theseParams,thisLPP,~,report(isub,imodel),~,gradient{isub,imodel},thisH]= ...
            fmincon(@(x) GetModelLLCONF_QLearner(x,modelsinfo{imodel},Choices(:,isub),confTransformed(:,isub),Reward(:,isub),1),x0,[],[],[],[],lb,ub,[],options);
        paramsPerSub(isub,:) = theseParams;
        nfpm = numel(modelsinfo{imodel}.paramnames);
        hessian{isub,imodel} = thisH;
        LPP(isub,imodel);
        this_ll =  GetModelLLCONF_QLearner(theseParams,modelsinfo{imodel},Choices(:,isub),confTransformed(:,isub),Reward(:,isub),1);
        ll(isub,imodel) = this_ll;
        bic(isub,imodel)=-2*-this_ll+nfpm*log(ntrials);
        aic(isub, imodel)=-2*-this_ll+nfpm; 
        LAME(isub,imodel) =  thisLPP - nfpm/2*log(2*pi) + real(log(det(thisH))/2);%Laplace-approximated model evidence
    end
    parameters{imodel} = paramsPerSub;
    clear paramsPerSub;
end

save('Results\model_fitsCONF_exp1V0_10','parameters','LPP', 'modelsinfo','bic', 'aic','ll','LAME')