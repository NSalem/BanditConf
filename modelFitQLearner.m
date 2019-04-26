LoadExp1;
addpath('ModelingFuncs\')
addpath('helperfuncs');

Choices = Choices + 2;
Choices(Choices==3) = 2;

modelsinfo{1}.paramnames ={'lrm','lrv'};
modelsinfo{1}.lb = [0,0];
modelsinfo{1}.ub = [1,1];
modelsinfo{1}.x0 = [.5,.5,];

modelsinfo{2}.paramnames ={'lrm','lrm2','lrv'};
modelsinfo{2}.lb = [0,0,0];
modelsinfo{2}.ub = [1,1,1];
modelsinfo{2}.x0 = [.5,.5,.5];

modelsinfo{3}.paramnames ={'lrm','lrv','lrv2'};
modelsinfo{3}.lb = [0,0,0];
modelsinfo{3}.ub = [1,1,1];
modelsinfo{3}.x0 = [.5,.5,.5];

modelsinfo{4}.paramnames ={'lrm','lrm2','lrv','lrv2'};
modelsinfo{4}.lb = [0,0,0,0];
modelsinfo{4}.ub = [1,1,1,1];
modelsinfo{4}.x0 = [.5,.5,.5,.5];

options = optimset('Algorithm', 'interior-point', 'Display', 'final', 'MaxIter', 10000); % These increase the number of iterations to ensure the convergence
for imodel = 1:numel(modelsinfo) 
    lb = modelsinfo{imodel}.lb;
    ub = modelsinfo{imodel}.ub;
    x0 = modelsinfo{imodel}.x0;
    for isub = 1:size(Choices,2)
        [parameters{isub,imodel},ll(isub,imodel),report(isub,imodel),gradient{isub,imodel},hessian{isub,imodel}]=fmincon(@(x) GetModelLL_QLearner(x,modelsinfo{imodel},ones(size(Choices,1)),Choices(:,isub),Reward(:,isub)),x0,[],[],[],[],lb,ub,[],options);
    end
end

save('model_fits','parameters','ll', 'modelsinfo')