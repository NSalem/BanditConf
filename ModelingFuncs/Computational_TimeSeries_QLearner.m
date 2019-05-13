function [Q,V,pc,PE] = Computational_TimeSeries_QLearner(params,a,r)

l = qLearner(params);
ntrials = length(a);

Q       = zeros(2,ntrials);        % Initial (subjective) mean
V       = zeros(2,ntrials);        % Initial (subjective) variance
pc      = ones(1,ntrials)*.5;

for i = 1:length(a)
    if ~isnan(a(i))
        %%% get probability of action=2 given current values 
        [dum_action,trl_pc] = l.chooseAction(); 
        if dum_action ~=2
            trl_pc = 1-trl_pc; 
        end
        pc(i) = trl_pc;
        %%% learn
        l.learn(a(i),r(i));
        
        if i<length(a)
            PE(i) = r(i)- l.Q(a(i)); 
        end
        Q(a(i),i) = l.Q(a(i));
        Q(3-a(i),i) = l.Q(3-a(i));
        V(a(i),i) = l.V(a(i));

    else
        Q(1,i) = Q(1,i);
        Q(2,i) = Q(2,i);

    end

end
end