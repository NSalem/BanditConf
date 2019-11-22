function [Q,V,pc,a,r,zhat] = SimulateQLearner(params,OUT)

l = qLearner(params);
%% Hidden variables

ntrials = length(OUT);
Q       = zeros(2,ntrials);        % Initial (subjective) mean
V       = zeros(2,ntrials);        % Initial (subjective) variance 
a       = NaN(ntrials,1);
r       = NaN(ntrials,1);
zhat    = NaN(ntrials,1);

%%%% loop through trials %%%%
for itrial = 1:length(a)
    %%% choose action
    [a(itrial),this_pc,~,~,zhat(itrial)]=l.chooseAction();  
    if a(itrial)~=2 
        this_pc = 1-this_pc; %pc is probability of choosing option 2
    end
    pc(itrial) = this_pc;

    %%% determine outcome
    r(itrial) = OUT(a(itrial),itrial);
    %%% learn
    l.learn(a(itrial),r(itrial));

    Q(a(itrial),itrial) = l.Q(a(itrial));   
    Q(3-a(itrial),itrial) = l.Q(3-a(itrial));       
    V(a(itrial),itrial) = l.V(a(itrial));   
    V(3-a(itrial),itrial) = l.V(3-a(itrial));  

end
end