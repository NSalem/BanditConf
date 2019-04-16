rew = randn(100,1)*15+65;
paramstruct.lrm = .5;
paramstruct.lrv = .5;

l = qLearner(paramstruct);

for it = 1:numel(rew);
   l.learn(1,1,rew(it));
   Q(it,:) = l.Q;
   V(it,:) = l.V;
end


rew = double([rand(100,1)>.75]+0.1);
paramstruct.lrm = .5;
paramstruct.lrv = 1;


l = qLearner(paramstruct);

for it = 1:numel(rew);
%    paramstruct.lrm = 1/(1-it);
   l.learn(1,1,rew(it));
   Q(it,:) = mean(l.r);
   V(it,:) = sqrt(std(l.r));
end
