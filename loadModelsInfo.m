

modelsinfo{1}.paramnames ={'beta','lrm'};
modelsinfo{1}.lb = [0,0];
modelsinfo{1}.ub = [Inf,1];
modelsinfo{1}.x0 = [1,.5,];

modelsinfo{2}.paramnames ={'lrm','lrv'};
modelsinfo{2}.lb = [0,0];
modelsinfo{2}.ub = [1,1];
modelsinfo{2}.x0 = [.5,.5,];

modelsinfo{3}.paramnames ={'lrm','lrm2','lrv'};
modelsinfo{3}.lb = [0,0,0];
modelsinfo{3}.ub = [1,1,1];
modelsinfo{3}.x0 = [.5,.5,.5];

modelsinfo{4}.paramnames ={'lrm','lrv','lrv2'};
modelsinfo{4}.lb = [0,0,0];
modelsinfo{4}.ub = [1,1,1];
modelsinfo{4}.x0 = [.5,.5,.5];

modelsinfo{5}.paramnames ={'lrm','lrm2','lrv','lrv2'};
modelsinfo{5}.lb = [0,0,0,0];
modelsinfo{5}.ub = [1,1,1,1];
modelsinfo{5}.x0 = [.5,.5,.5,.5];

modelsinfo{6}.paramnames = {'lrm','lrv','lambda','T','beta'}
modelsinfo{6}.lb = [0,0,0,0,0];
modelsinfo{6}.ub = [1,1,Inf,100,Inf];
modelsinfo{6}.x0 = [.5,.5,1,50,1];
modelsinfo{6}.drift = true;


priorfuncs.beta = '@(x) log(gampdf(x,1.2,5))';
% priorfuncs.beta = '@(x) log(gampdf(x,1.29,2.03))';
priorfuncs.lrm = '@(x) log(betapdf(x,1.1,1.1))';
priorfuncs.lrm2 = priorfuncs.lrm; 
priorfuncs.lrv = priorfuncs.lrm; 
priorfuncs.lrv2 = priorfuncs.lrm; 
priorfuncs.T = '@(x) log(betapdf(x/100,1.1,1.1))';
priorfuncs.lambda = '@(x) log(gampdf(x,.08,41.46))';
    
for imodel = 1:numel(modelsinfo)
    for iparam = 1:numel(modelsinfo{imodel}.paramnames)
        thisParamName = modelsinfo{imodel}.paramnames{iparam};
        modelsinfo{imodel}.priorfuncs.(thisParamName) = priorfuncs.(thisParamName);
    end
end
