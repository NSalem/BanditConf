

modelsinfo{1}.paramnames ={'beta','lrm'};
modelsinfo{1}.lb = [0,0];
modelsinfo{1}.ub = [Inf,1];
modelsinfo{1}.x0 = [1,.5,];

modelsinfo{2}.paramnames ={'beta','lrm','lrm2'};
modelsinfo{2}.lb = [0,0,0];
modelsinfo{2}.ub = [Inf,1,1];
modelsinfo{2}.x0 = [1,.5,.5];

modelsinfo{3}.paramnames ={'lrm','lrv'};
modelsinfo{3}.lb = [0,0];
modelsinfo{3}.ub = [1,1];
modelsinfo{3}.x0 = [.5,.5,];

modelsinfo{4}.paramnames ={'lrm','lrm2','lrv'};
modelsinfo{4}.lb = [0,0,0];
modelsinfo{4}.ub = [1,1,1];
modelsinfo{4}.x0 = [.5,.5,.5];

modelsinfo{5}.paramnames ={'lrm','lrv','lrv2'};
modelsinfo{5}.lb = [0,0,0];
modelsinfo{5}.ub = [1,1,1];
modelsinfo{5}.x0 = [.5,.5,.5];

% modelsinfo{6}.paramnames ={'lrm','lrm2','lrv','lrv2'};
% modelsinfo{6}.lb = [0,0,0,0];
% modelsinfo{6}.ub = [1,1,1,1];
% modelsinfo{6}.x0 = [.5,.5,.5,.5];

modelsinfo{6}.paramnames = {'lrm','lrv','T','beta'}
modelsinfo{6}.lb = [0,0,0,0];
modelsinfo{6}.ub = [1,1,100,Inf];
modelsinfo{6}.x0 = [.5,.5,50,1];
modelsinfo{6}.drift = true;

modelsinfo{7}.paramnames = {'lrm','lrm2','lrv','T','beta'}
modelsinfo{7}.lb = [0,0,0,0,0];
modelsinfo{7}.ub = [1,1,1,100,Inf];
modelsinfo{7}.x0 = [.5,.5,.5,50,1];
modelsinfo{7}.drift = true;

modelsinfo{8}.paramnames = {'lrm','lrv','lrv2','T','beta'}
modelsinfo{8}.lb = [0,0,0,0,0];
modelsinfo{8}.ub = [1,1,1,100,Inf];
modelsinfo{8}.x0 = [.5,.5,.5,50,1];
modelsinfo{8}.drift = true;

% modelsinfo{9}.paramnames = {'lrm','lrm2','lrv','lrv2','T','beta'}
% modelsinfo{9}.lb = [0,0,0,0,0,0];
% modelsinfo{9}.ub = [1,1,1,1,100,Inf];
% modelsinfo{9}.x0 = [.5,.5,.5,.5,50,1];
% modelsinfo{9}.drift = true;

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
