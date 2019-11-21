function [Q,V,pc2,PE,p,conf] = Computational_TimeSeries_QLearner(params,a,r)

l = qLearner(params);
ntrials = length(a);

Q       = zeros(2,ntrials);        % Initial (subjective) mean
V       = NaN(2,ntrials);        % Initial (subjective) variance
pc2      = ones(1,ntrials)*.5;
p    = ones(1,ntrials).*5;
conf    = ones(1,ntrials).*5;
for i = 1:length(a)
    if ~isnan(a(i))
        %%% get probability of action=2 given current values 
        [dum_action,trl_pc,trl_conf,trl_confUnchosen] = l.chooseAction(); 
        p(i) = trl_pc;
        if dum_action ~=2
            trl_pc = 1-trl_pc; 
        end
        pc2(i) = trl_pc;
        
        if dum_action == a(i)
            conf(i) = trl_conf;
        else
            conf(i) = trl_confUnchosen;%1-trl_conf;
        end
        %%% learn
        l.learn(a(i),r(i));
        
        if i<length(a)
            PE(i) = r(i)- l.Q(a(i)); 
        end
        Q(a(i),i) = l.Q(a(i));
        Q(3-a(i),i) = l.Q(3-a(i));
        V(a(i),i) = l.V(a(i));
        V(3-a(i),i) = l.V(3-a(i));

    else
        Q(1,i) = Q(1,i);
        Q(2,i) = Q(2,i);

    end

end
end