function [Q,V,pc,PE] = Computational_TimeSeries_QLearner(params,s,a,r)

l = qLearner(params);
if sum(size(s)>1)==2
    ntrials = size(s,1);
else 
    ntrials = 24;
end
Q       = zeros(numel(unique(s)),2,ntrials);        % Initial option values (all Models) as a function of conditio ("s")
V       = zeros(numel(unique(s)),2,ntrials);        % Initial Var
pc      = ones(numel(unique(s)),ntrials)*.5;
trialc = zeros(numel(unique(s)),1);                                                                % loglikelyhood


for i = 1:length(a)
    trialc(s(i)) =  trialc(s(i)) +1;
    if ~isnan(a(i))
        %%% get probability of action being correct given current values 
        [dum_action,trl_pc] = l.chooseActionThompson(s(i)); 
        if dum_action ~=2
            trl_pc = 1-trl_pc; 
        end
        pc(s(i),trialc(s(i))) = trl_pc;
        %%% learn
        l.learn(s(i),a(i),r(i));
        
        if i<length(a)
            PE(s(i),trialc(s(i))+1) = r(i)- l.Q(s(i),a(i)); 
        end
        Q(s(i),a(i),trialc(s(i))+1) = l.Q(s(i),a(i));
        Q(s(i),3-a(i),trialc(s(i))+1) = l.Q(s(i),3-a(i));
        V(s(i),a(i),trialc(s(i))+1) = l.V(s(i),a(i));

    else
        Q(s(i),1,trialc(s(i))+1) = Q(s(i),1,trialc(s(i)));
        Q(s(i),2,trialc(s(i))+1) = Q(s(i),2,trialc(s(i)));

    end

end
end