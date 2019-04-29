addpath('ModelingFuncs\')
addpath('helperfuncs');

loadExp1;

Choices = Choices + 2;
Choices(Choices==3) = 2;

loadModelsInfo; 

options = optimset('Algorithm', 'interior-point', 'Display', 'final', 'MaxIter', 10000, 'UseParallel',true); % These increase the number of iterations to ensure the convergence
for imodel = 1:numel(modelsinfo) 
    lb = modelsinfo{imodel}.lb;
    ub = modelsinfo{imodel}.ub;
    x0 = modelsinfo{imodel}.x0;
    for isub = 1:size(Choices,2)
        [parameters{imodel}(isub,:),ll(isub,imodel),report(isub,imodel),gradient{isub,imodel},hessian{isub,imodel}]=fmincon(@(x) GetModelLL_QLearner(x,modelsinfo{imodel},Choices(:,isub),Reward(:,isub)),x0,[],[],[],[],lb,ub,[],options);
    end
end

save('model_fits','parameters','ll', 'modelsinfo')