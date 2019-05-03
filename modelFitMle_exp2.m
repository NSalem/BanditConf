
addpath('ModelingFuncs\')
addpath('helperfuncs');

loadExp2;

Choices = Choices + 2;
Choices(Choices==3) = 2;

loadModelsInfo; 

ntrials = size(Choices,1);

options = optimset('Algorithm', 'interior-point', 'Display', 'final', 'MaxIter', 10000); % These increase the number of iterations to ensure the convergence
for imodel = 1:numel(modelsinfo) 
    lb = modelsinfo{imodel}.lb;
    ub = modelsinfo{imodel}.ub;
    x0 = modelsinfo{imodel}.x0;
    for isub = 1:size(Choices,2)
        [parameters{imodel}(isub,:),ll(isub,imodel),report(isub,imodel),gradient{isub,imodel},hessian{isub,imodel}]=fmincon(@(x) GetModelLL_QLearner(x,modelsinfo{imodel},Choices(:,isub),Reward(:,isub),0),x0,[],[],[],[],lb,ub,[],options);
        nfpm = numel(modelsinfo{imodel}.paramnames);
        this_ll =  ll(isub,imodel);
        bic(isub,imodel)=-2*-this_ll+nfpm*log(ntrials);
        aic(isub, imodel)=-2*-this_ll+nfpm; 
    end
end

save('model_fitsMLE_exp2','parameters','ll', 'modelsinfo')