classdef    qLearner < handle
    properties 
%         startQ = [0,0];
%         startV = [0,0];
        beta
        lrm
        lrv
        lrm2
        lrv2
        lambda = 0;
        T
        drift = false;
        Q = [0,0];
        V = [0,0];
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
    
        function learn(obj, a, r)
            %%% updates prior distributions of value
            %%% a: integer (1 or 2) indicating the action taking this
            %%% trial
            %%% r: (integer) reward  
            
            delta =  r - obj.Q(a);                                       

            %% update var
            if obj.Q(a)~=0
                deltaV = ((r - obj.Q(a))^2 -obj.V(a)); 
                obj.V(a) = obj.V(a) + obj.lrv.*deltaV.*double(delta>0) + obj.lrv2.*deltaV.*double(delta<0);
            end
            %% udapte mean 
            
            if obj.confirmatory 
                obj.Q(a) = obj.Q(a) + obj.lrm.*delta.*double(delta>0) + obj.lrm2.*delta.*double(delta<0);                                     % the delta rule for the factual choice             
            else
                obj.Q(a) = obj.Q(a) + obj.lrm.*delta;                                     % the delta rule for the factual choice
            end

            %% drift Q unchosen towards T 
            if isprop(obj,'T') && ~isempty(obj.T) && obj.drift
                obj.Q(3-a) = obj.Q(3-a) + obj.lrm.*(obj.T - obj.Q(3-a));                                     % the delta rule for the factual choice
            end
            %%
            obj.r = [obj.r r];
            
        end
        

        function [action,p] = chooseAction(obj) 
            if isprop(obj,'T') && ~isempty(obj.T) 
                [action,p] = chooseActionThresholdSigmoid(obj);
            else 
                [action,p] = chooseActionThompson(obj);
            end
        end
    
        function [action,p] = chooseActionThompson(obj)
                    %state: number representing state
                    %
                    %Outputs:
                    %action: (1 or 2)
                    %p: Probability of having chosen action based on the state

                Q1 = randn(1000, 1,1)*sqrt(obj.V(1))+obj.Q(1); %sampled values from current prior distribution of option1
                Q2 = randn(1000, 1,1)*sqrt(obj.V(2))+obj.Q(2); %sampled values from current prior distribution of option2

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
        
        function [action,p] = chooseActionSigmoid(obj)
                %state: number representing state
                %
                %Outputs:
                %action: (1 or 2)
                %p: Probability of having chosen action based on the state
      
           Q2 = obj.Q(2);
           Q1 = obj.Q(1);
           
           dQ = Q2 - Q1; % correct vs incorrect
           
           pc = 1./(1+exp(-dQ.*obj.beta));
           action = double(rand<pc) + 1;
        
           if action == 2
                p = pc;
            else
                p = 1-pc;
            end
        end
        
        function [action,p] = chooseActionThresholdSigmoid(obj)
                %Outputs:
                %action: (1 or 2)
                %p: Probability of having chosen action 
           
           Q2 = obj.Q(2);
           Q1 = obj.Q(1);
           V2 = obj.V(2);
           V1 = obj.V(1);
           
%             integral(@(x)(-exp(-lambda.*x).*exp(-((x-M).^2./(2.*V)))),-Inf,Inf)/sqrt(2*pi*V)
%            SP2 = (1/sqrt(2*pi*V2)).*integral(@(x)(-exp(-obj.lambda.*x).*exp(-((x-Q2).^2./(2.*V2)))),obj.T, Inf);
%            SP1 = (1/sqrt(2*pi*V1)).*integral(@(x)(-exp(-obj.lambda.*x).*exp(-((x-Q1).^2./(2.*V1)))),obj.T, Inf);                 
           SP2 = (1/sqrt(2*pi*V2)).*integral(@(x)(-exp(-obj.lambda.*x+(-((x-Q2).^2./(2.*V2))))),obj.T, Inf);
           SP1 = (1/sqrt(2*pi*V1)).*integral(@(x)(-exp(-obj.lambda.*x+(-((x-Q1).^2./(2.*V1))))),obj.T, Inf);
           
%            T1 = (obj.T-Q1)./V1;
%            T2 = (obj.T-Q2)./V2;
%            
%            SP2 = (1/sqrt(2*pi)).*integral(@(x)(-exp(-obj.lambda.*x+(-((x).^2./(2))))),T2, Inf);
%            SP1 = (1/sqrt(2*pi)).*integral(@(x)(-exp(-obj.lambda.*x+(-((x).^2./(2))))),T1, Inf);
%             

           
           dQ = (abs(SP2)-abs(SP1))./(abs(SP1)+abs(SP2));
           if isnan(dQ)
               dQ = 0;
           end
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