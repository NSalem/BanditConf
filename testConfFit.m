


d = 1;
confNoise = 1;
X = randn(10000,1).*confNoise+1;
conf = (normpdf(X,d,confNoise))./((normpdf(X,d,confNoise))+(normpdf(X,-d,confNoise)));



conflevels = linspace(0,1,12);
binSize = conflevels(2)-conflevels(1);
    confDiscrete = conf;
        confresps = conflevels;
        for ie = 1:numel(confDiscrete) 
            [~,idclosest] = min(abs(confDiscrete(ie)-confresps));
            confDiscrete(ie) = confresps(idclosest);      
        end