classdef    qLearner < handle
    properties 
        startQ = [0,0];
        startV = [0,0];
        beta
        lrm
        lrv
        lrm2
        lrv2
        V
        Q
        s = [];
        r = [];
        c = [];
        confirmatory
    end

    methods 
        function obj = qLearner(params)
        
        %object = qLearner(params)
        %create a q-learner object. 
        %params is a struct with following fields:
        %lr1: learning rate for confirmatory/factual outcomes
        %lr2: (optional) learning rate for disconfirmatory
        %confirmatory: bool, whether to use different learning rates for
        %confirmatory and disconformatory outcomes (positve and negative
        %prediction errors respectively for factual option, inverted for
        %counterfactual)
        
        dum = properties(obj);
        for fn = fieldnames(params)'
            if any(strcmp(dum,fn))
                obj.(fn{1}) = params.(fn{1});
            end
        end
                  
        if ~isfield(params,'lrm2')
            obj.lrm2 = obj.lrm;
        end     
%         
        if ~isfield(params,'lrv2')
            obj.lrv2 = obj.lrv;
        end     
%         if obj.confirmayory && obj.FvsCF
%             error('Learner cannot have confirmatory bias and factual bias at the same time');
%         end
    end
    
        function learn(obj, s, a, r)
            %%% updates prior distributions for value of the chosen (and
            %%% unchosen option if u is given), as well as the context
            %%% value if obj.relative is true
            %%% s: integer indicating current state
            %%% a: integer (1 or 2) indicating the action taking this
            %%% trial
            %%% r: (float) reward 
            
            if s>size(obj.Q,1)%||a>size(obj.Q,2)
                obj.Q(s, :) = obj.startQ;
            end
            if s>size(obj.V,1)%||a>size(obj.Q,2)
                obj.V(s, :) = [0,0];
            end
    
            delta =  r - obj.Q(s,a);                                        % the prediction error for the factual choice

            %% update var
            if obj.Q(s,a)~=0
                deltaV = ((r - obj.Q(s,a))^2 -obj.V(s,a)); 
                obj.V(s,a) = obj.V(s,a) + obj.lrv.*deltaV.*double(delta>0) + obj.lrv2.*deltaV.*double(delta<0);
            end
            %% udapte mean 
            
            if obj.confirmatory 
                obj.Q(s,a) = obj.Q(s,a) + obj.lrm.*delta.*double(delta>0) + obj.lrm2.*delta.*double(delta<0);                                     % the delta rule for the factual choice             
            else
                obj.Q(s,a) = obj.Q(s,a) + obj.lrm.*delta;                                     % the delta rule for the factual choice
            end

            %%
            obj.s = [obj.s s];
            obj.r = [obj.r r];
            if nargin>4
                obj.c = [obj.c c];
            else 
                obj.c = [obj.c NaN];
            end

        end
        
    
            function [action,p] = chooseActionThompson(obj, state)
                    %state: number representing state
                    %
                    %Outputs:
                    %action: (1 or 2)
                    %p: Probability of having chosen action based on the state

               if state>size(obj.Q,1)
                    obj.Q(state, :) = obj.startQ;
                    obj.V(state,:) = obj.startV;
               end

                Q1 = randn(1000, 1,1)*sqrt(obj.V(state,1))+obj.Q(state,1); %sampled values from current prior distribution of option1
                Q2 = randn(1000, 1,1)*sqrt(obj.V(state,2))+obj.Q(state,2); %sampled values from current prior distribution of option2

            %     f = @(x) normpdf(x,priorMean1,sqrt(priorVar1)).*(4-normcdf(x,priorMean2,sqrt(priorVar2)));
            %     conf2 = integral(f,-4,4);

                pQ2 = sum(Q2>Q1)/numel(Q1); %probability of choosing action 1 is equal to the proportion of sampled  
                                            %values of Q1 that are higher than sampled values from Q2  
               if pQ2 == 1
                    pQ2 = 1-1/1000;
                elseif pQ2 ==0
                    pQ2 = 1/1000;
                end
                action = double(rand<pQ2)+1; %action, 1 or 2
                if action == 2
                    p = pQ2;
                else
                    p = 1-pQ2;
                end
        end
        
        function [action,p] = chooseActionSigmoid(obj, state)
                %state: number representing state
                %
                %Outputs:
                %action: (1 or 2)
                %p: Probability of having chosen action based on the state

           if state>size(obj.Q,1)
                obj.Q(state, 1:2) = obj.startQ;
           end
           
           Q2 = obj.Q(state,2);
           Q1 = obj.Q(state,1);
           
           dQ = Q2 - Q1; % correct vs incorrect
           
           pc = 1./(1+exp(-dQ.*obj.beta));
           action = double(rand<pc) + 1;
        
           if action == 2
                p = pc;
            else
                p = 1-pc;
            end
        end
    end
    methods (Static)
    end
end