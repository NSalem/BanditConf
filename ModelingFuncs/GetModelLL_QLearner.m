function lik = GetModelLL_QLearner(params,learneroptions,s,a,r)
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
        [action,p] = l.chooseAction(s(i));
        if action ~=a(i)
            p = 1-p;
        end
        lik = lik+log(p); 
      
         %%% learn
        l.learn(s(i),a(i),r(i));
    end
end
Q = l.Q;   

%%
lik = -lik;

end