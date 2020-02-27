modelsinfo{1}.paramnames ={'lrm','lrv','beta'};
modelsinfo{1}.lb = [0,0,0];
modelsinfo{1}.ub = [1,1,Inf];
modelsinfo{1}.x0 = [.5,.5,1];

modelsinfo{2}.paramnames ={'lrm','lrv','beta'};
modelsinfo{2}.lb = [0,0,0];
modelsinfo{2}.ub = [1,1,Inf];
modelsinfo{2}.x0 = [.5,.5,1];
modelsinfo{2}.QuWeightConf = 0;

modelsinfo{3}.paramnames = {'lrm','lrv','T','beta'}
modelsinfo{3}.lb = [0,0,0,0];
modelsinfo{3}.ub = [1,1,100,Inf];
modelsinfo{3}.x0 = [.5,.5,50,1];
modelsinfo{3}.drift = true;

% modelsinfo{1}.paramnames ={'lrm','lrv'};
% modelsinfo{1}.lb = [0,0];
% modelsinfo{1}.ub = [1,1];
% modelsinfo{1}.x0 = [.5,.5,];
% 
% modelsinfo{2}.paramnames ={'lrm','lrm2','lrv'};
% modelsinfo{2}.lb = [0,0,0];
% modelsinfo{2}.ub = [1,1,1];
% modelsinfo{2}.x0 = [.5,.5,.5];
% 
% modelsinfo{3}.paramnames ={'lrm','lrv','lrv2'};
% modelsinfo{3}.lb = [0,0,0];
% modelsinfo{3}.ub = [1,1,1];
% modelsinfo{3}.x0 = [.5,.5,.5];
% 
% modelsinfo{4}.paramnames ={'lrm','lrm2','lrv','lrv2'};
% modelsinfo{4}.lb = [0,0,0,0];
% modelsinfo{4}.ub = [1,1,1,1];
% modelsinfo{4}.x0 = [.5,.5,.5,.5];

priorfuncs.beta = '@(x) log(gampdf(x,1.2,5))';
priorfuncs.lrm = '@(x) log(betapdf(x,1.1,1.1))';
priorfuncs.lrm2 = priorfuncs.lrm; 
priorfuncs.lrv = priorfuncs.lrm; 
priorfuncs.lrv2 = priorfuncs.lrm; 
priorfuncs.T = '@(x) log(betapdf(x/100,1.1,1.1))';
for imodel = 1:numel(modelsinfo)
    for iparam = 1:numel(modelsinfo{imodel}.paramnames)
        thisParamName = modelsinfo{imodel}.paramnames{iparam};
        modelsinfo{imodel}.priorfuncs.(thisParamName) = priorfuncs.(thisParamName);
    end
     modelsinfo{imodel}.Q = [50,50];
     modelsinfo{imodel}.V = [10,10];
end
