addpath('ModelingFuncs\')
addpath('helperfuncs');

loadExp1;

Choices = Choices + 2;
Choices(Choices==3) = 2;

loadModelsInfo; 

ntrials = size(Choices,1);

whichmodels = 1:numel(modelsinfo);
options = optimset('Algorithm', 'interior-point', 'Display', 'final', 'MaxIter', 10000); % These increase the number of iterations to ensure the convergence
for imodel = whichmodels;
    lb = modelsinfo{imodel}.lb;
    ub = modelsinfo{imodel}.ub;
    x0 = modelsinfo{imodel}.x0;
    for isub = 1:size(Choices,2)
        [parameters{imodel}(isub,:),LPP(isub,imodel),report(isub,imodel),gradient{isub,imodel},hessian{isub,imodel}]=fmincon(@(x) GetModelLL_QLearner(x,modelsinfo{imodel},Choices(:,isub),Reward(:,isub),1),x0,[],[],[],[],lb,ub,[],options);
        nfpm = numel(modelsinfo{imodel}.paramnames);
        this_ll =  GetModelLL_QLearner(parameters{imodel}(isub,:),modelsinfo{imodel},Choices(:,isub),Reward(:,isub),0);
        ll(isub,imodel) = this_ll;
        bic(isub,imodel)=-2*-this_ll+nfpm*log(ntrials);
        aic(isub, imodel)=-2*-this_ll+nfpm; 
    end
end

save('Results\model_fitsMAP_exp1','parameters','LPP', 'modelsinfo','bic', 'aic','ll')