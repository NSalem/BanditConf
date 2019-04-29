function lik = GetModelLL_QLearner(params,learneroptions,a,r, usePriors)
%% Parameters
for iparam = 1:numel(learneroptions.paramnames)
    paramstruct.(learneroptions.paramnames{iparam}) = params(iparam);
end

for fn = fieldnames(learneroptions)'
    if ~strcmp(fn,'paramnames')
        paramstruct.(fn{1}) = learneroptions.(fn{1});
    end
end

l = qLearner(paramstruct);

lik     = 0;   % loglikelihood
for i = 1:length(a)
    
    if ~isnan(a(i))
        [action,p] = l.chooseAction();
        if action ~=a(i)
            p = 1-p;
        end
        lik = lik+log(p); 
      
         %%% learn
        l.learn(a(i),r(i));
    end
end
Q = l.Q;   

%%

if usePriors
    lik = GetPosterior(l,lik,learneroptions.priorfuncs);
end

lik = -lik;


end


function [post]=GetPosterior(l,lik,priors)
%% This function attribute probability to parameters
% it is used to calculate the LPP
% the priors are taken from Daw et al. Neuron 2011

p = [];

    for iparam = fieldnames(priors)'
        ipriorfun = priors.(iparam{1});
        if ischar(ipriorfun)
            ipriorfun = str2func(ipriorfun);
        end
        p = [p, ipriorfun(l.(iparam{1}))];       
    end

p = -sum(p);

post = p + lik;
end
