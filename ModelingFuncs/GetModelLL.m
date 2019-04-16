function lik = GetModelLL(params,s,a,r)

%% Parameters
lr1   = params(1);                                                     % policy or factual learning rate
lr2   = params(2);                                                     % counterfactual or fictif learning rate
l = bayesLearner([],[],lr1,lr2);

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
Q = l.priorMeans;   
QVar= l.priorVars;   
%%
lik = -lik;
end