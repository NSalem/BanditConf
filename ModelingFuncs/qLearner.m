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
        sigma = 0;
        choiceRule = 'Thompson';
        wFlemConf = 1;
        T
        drift = false;
        Q = [50,50];
        V = [10,10];
        r = [];
        QuWeightConf = 1;
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
    end
    
        function learn(obj, a, r)
            %%% updates prior distributions of value
            %%% a: integer (1 or 2) indicating the action taking this
            %%% trial
            %%% r: (integer) reward  
            
            delta =  r - obj.Q(a);                                       

            %% update var
            if isprop(obj,'lrv') && ~isempty(obj.lrv) 
                deltaV = ((r - obj.Q(a))^2 -obj.V(a)); 
                obj.V(a) = obj.V(a) + obj.lrv.*deltaV.*double(delta>0) + obj.lrv2.*deltaV.*double(delta<0);
            end
            %% udapte mean 
            obj.Q(a) = obj.Q(a) + obj.lrm.*delta.*double(delta>0) + obj.lrm2.*delta.*double(delta<0);                                     % the delta rule for the factual choice             

            %% drift Q unchosen towards T 
            if isprop(obj,'T') && ~isempty(obj.T) && obj.drift
                obj.Q(3-a) = obj.Q(3-a) + obj.lrm.*(obj.T - obj.Q(3-a));                                     % the delta rule for the factual choice
            end
            %%
            obj.r = [obj.r r];
            
        end
        

        function [action,p,Econf,EconfUnchosen,conf] = chooseAction(obj) 
            if strcmp(obj.choiceRule,'SAT')%isprop(obj,'T') && ~isempty(obj.T) 
                [action,p,Econf,EconfUnchosen] = chooseActionThresholdSigmoid(obj);
            elseif strcmp(obj.choiceRule,'Thompson')%isprop(obj,'lrv') && ~isempty(obj.lrv) 
                [action,p,Econf,EconfUnchosen,conf] = chooseActionThompson(obj);
            elseif strcmp(obj.choiceRule,'Sigmoid')%isprop(obj,'beta') && ~isempty(obj.beta)
                [action,p,Econf,EconfUnchosen]  = chooseActionSigmoid(obj); 
%             elseif isprop(obj,'sigma') && ~isempty(obj.sigma)
%                 [action,p,conf,confUnchosen]  = chooseActionFleming(obj);
            end
            if ~exist('conf','var')
                conf = Econf;
            end
        end
        function [action,p,Econf,EconfUnchosen,conf] = chooseActionThompson(obj)
                    %state: number representing state
                    %
                    %Outputs:
                    %action: (1 or 2)
                    %p: Probability of having chosen action based on the state

%                 Q1 = randn(100000, 1,1)*sqrt(obj.V(1))+obj.Q(1); %sampled values from current prior distribution of option1
%                 Q2 = randn(100000, 1,1)*sqrt(obj.V(2))+obj.Q(2); %sampled values from current prior distribution of option2
%                 Qdiff = Q2-Q1;
%                 pQ2 = sum(Q2>Q1)/numel(Q1); %probability of choosing action 2 is equal to the proportion of sampled  
                                            %values of Q2 that are higher than sampled values from Q1
                 
                muDiff = obj.Q(2)-obj.Q(1);
                if isprop(obj,'beta') && ~isempty(obj.beta)
                    sigmaDiff =  sqrt(obj.V(1)+obj.V(2)+(1./obj.beta)^2);
                else
                    sigmaDiff =  sqrt(obj.V(1)+obj.V(2));
                end
                confNoise =  sigmaDiff;
                
                pQ2 = 1-normcdf(0,muDiff,sigmaDiff);
%                 if (obj.V(1)== 0 || obj.V(2) ==0);
%                     pQ2 = .5;
%                 elseif pQ2 == 1
%                     pQ2 = 1-1/1000;
%                 elseif pQ2 ==0
%                     pQ2 = 1/1000;
%                 end
%                 X = (randn*sqrt(obj.V(2))+obj.Q(2))-(randn*sqrt(obj.V(1))+obj.Q(1))+randn.*1./obj.beta;
                
                X = randn*sigmaDiff+muDiff;

                action = double(X>=0)+1; %action, 1 or 2
                dQ = obj.Q(2)-obj.Q(1);
                Ex = dQ;
                
                ExNew = (obj.Q(action)-50)-(obj.QuWeightConf*(obj.Q(3-action)-50));
                Econf = normpdf(ExNew,ExNew,confNoise)./...
                    (normpdf(ExNew,ExNew,confNoise)+normpdf(ExNew,-ExNew,confNoise));   
                conf = normpdf(X,ExNew,confNoise)./(normpdf(X,ExNew,confNoise)+normpdf(X,-ExNew,confNoise));

                ExU = (obj.Q(3-action)-50)-(obj.QuWeightConf*(obj.Q(action)-50));

                EconfUnchosen = normpdf(ExU,-ExU,confNoise)./...
                    (normpdf(ExU,ExU,confNoise)+normpdf(ExU,-ExU,confNoise));   
               if action ==2
                    p = pQ2;
                elseif action ==1
                    p = 1-pQ2;
               else 
                   p = [];
               end
%                 if action == 2
%                     p = pQ2;
% %                     d =dQ;
% %                     conf = obj.Q(2);confUnchosen = obj.Q(1);
%                     Econf = (normpdf(Ex,abs(dQ),confNoise))./(((normpdf(Ex,abs(dQ),confNoise))+(normpdf(Ex,-abs(dQ),confNoise))));
%                     EconfUnchosen = (normpdf(Ex,-abs(dQ),confNoise))./(obj.wFlemConf.*((normpdf(Ex,abs(dQ),confNoise))+(normpdf(Ex,-abs(dQ),confNoise)))+1-obj.wFlemConf);
%                     conf = normpdf(X,abs(dQ),confNoise)./(normpdf(X,abs(dQ),confNoise)+normpdf(X,-abs(dQ),confNoise));
%                 else
%                     p = 1-pQ2;
% %                     d = dQ;
% %                     conf = obj.Q(1); confUnchosen = obj.Q(2);
%                     Econf = (normpdf(Ex,-abs(dQ),confNoise))./(obj.wFlemConf.*((normpdf(Ex,abs(dQ),confNoise))+(normpdf(Ex,-abs(dQ),confNoise)))+1-obj.wFlemConf);
%                     EconfUnchosen = (normpdf(Ex,abs(dQ),confNoise))./(obj.wFlemConf.*((normpdf(Ex,abs(dQ),confNoise))+(normpdf(Ex,-abs(dQ),confNoise)))+1-obj.wFlemConf);
%                     conf = normpdf(X,abs(-dQ),confNoise)./(normpdf(X,abs(dQ),confNoise)+normpdf(X,-abs(dQ),confNoise));
%                 end



%                 conf = p;
%                 confUnchosen = 1-p;
%            conf = (normpdf(Ex,d,noise))/((normpdf(Ex,d,noise))+(normpdf(Ex,-d,noise)));
%            confUnchosen = (normpdf(Ex,-d,noise))/((normpdf(Ex,d,noise))+(normpdf(Ex,-d,noise)));

        end
        
        
        function [action,p,Econf,EconfUnchosen] = chooseActionSigmoid(obj)
                %Outputs:
                %action: (1 or 2)
                %p: Probability of having chosen action 
      
           Q2 = obj.Q(2);
           Q1 = obj.Q(1);
           
           dQ = (Q2 - Q1)./100; %divided by 100 to keep dQ between 0 and 1
           Ex = dQ;
           pc = 1./(1+exp(-dQ.*obj.beta));
           action = double(rand<pc) + 1;
        
           if action == 2
                p = pc;
%                 conf = Q2; confUnchosen = Q1;
%                 d = dQ;
               Econf = (normpdf(dQ,abs(dQ),1./obj.beta*1.6))/((normpdf(dQ,abs(dQ),1./obj.beta*1.6))+(normpdf(dQ,-abs(dQ),1./obj.beta*1.6)));
               EconfUnchosen = (normpdf(dQ,-abs(dQ),1./obj.beta*1.6))/((normpdf(dQ,abs(dQ),1./obj.beta*1.6))+(normpdf(dQ,-abs(dQ),1./obj.beta*1.6)));
            else
                p = 1-pc;
%                 conf = Q1; confUnchosen = Q2;
%                 d = -dQ;
               Econf = (normpdf(dQ,-abs(dQ),1./obj.beta*1.6))/((normpdf(dQ,abs(dQ),1./obj.beta*1.6))+(normpdf(dQ,-abs(dQ),1./obj.beta*1.6)));
               EconfUnchosen = (normpdf(dQ,abs(dQ),1./obj.beta*1.6))/((normpdf(dQ,abs(dQ),1./obj.beta*1.6))+(normpdf(dQ,-abs(dQ),1./obj.beta*1.6)));

           end
%            conf = (normpdf(d,d,1./obj.beta*1.6))/((normpdf(d,d,1./obj.beta*1.6))+(normpdf(d,-d,1./obj.beta*1.6)));
%            confUnchosen = (normpdf(d,-d,1./obj.beta*1.6))/((normpdf(Ex,d,1./obj.beta*1.6))+(normpdf(Ex,-d,1./obj.beta*1.6)));
        end
        
        function [action,p,Econf,EconfUnchosen] = chooseActionThresholdSigmoid(obj)
                %Outputs:
                %action: (1 or 2)
                %p: Probability of having chosen action 
           
           Q2 = obj.Q(2);
           Q1 = obj.Q(1);
           V2 = obj.V(2);
           V1 = obj.V(1);
           
%            SP2 = (1/sqrt(2*pi*V2)).*integral(@(x)(exp((-((x-Q2).^2./(2.*V2))))),obj.T, Inf);
%            SP1 = (1/sqrt(2*pi*V1)).*integral(@(x)(exp((-((x-Q1).^2./(2.*V1))))),obj.T, Inf);
           SP2 = 1-normcdf(obj.T,Q2,sqrt(V2));
           SP1 = 1-normcdf(obj.T,Q1,sqrt(V1));
           
           dQ = (abs(SP2)-abs(SP1));
           Ex = dQ;
           if isnan(dQ)
               dQ = 0;
           end
           pc = 1./(1+exp(-dQ.*obj.beta));
           action = double(rand<pc) + 1;
        
           if action == 2
                p = pc;
                Econf = SP2;EconfUnchosen = SP1;
%                 d = dQ;
               Econf = (normpdf(dQ,abs(dQ),1./obj.beta*1.6))/((normpdf(dQ,abs(dQ),1./obj.beta*1.6))+(normpdf(dQ,-abs(dQ),1./obj.beta*1.6)));
               EconfUnchosen = (normpdf(dQ,-abs(dQ),1./obj.beta*1.6))/((normpdf(dQ,abs(dQ),1./obj.beta*1.6))+(normpdf(dQ,-abs(dQ),1./obj.beta*1.6)));
           else
                p = 1-pc;
                Econf = SP1;EconfUnchosen = SP2;
%                 d = -dQ;
%                conf = (normpdf(dQ,-abs(dQ),1./obj.beta*1.6))/((normpdf(dQ,abs(dQ),1./obj.beta*1.6))+(normpdf(dQ,-abs(dQ),1./obj.beta*1.6)));
%                confUnchosen = (normpdf(dQ,abs(dQ),1./obj.beta*1.6))/((normpdf(dQ,abs(dQ),1./obj.beta*1.6))+(normpdf(dQ,-abs(dQ),1./obj.beta*1.6)));

           end
%            conf = (normpdf(Ex,d,1./obj.beta*1.6))/((normpdf(Ex,d,1./obj.beta*1.6))+(normpdf(Ex,-d,1./obj.beta*1.6)));
%            confUnchosen = (normpdf(Ex,-d,1./obj.beta*1.6))/((normpdf(Ex,d,1./obj.beta*1.6))+(normpdf(Ex,-d,1./obj.beta*1.6)));
        end
         
        function confp = getConfP(obj,action,confRating,confMargin)
            if isprop(obj,'T') && ~isempty(obj.T) 
                Q2 = obj.Q(2);
                Q1 = obj.Q(1);
                V2 = obj.V(2);
                V1 = obj.V(1);

    %            SP2 = (1/sqrt(2*pi*V2)).*integral(@(x)(exp((-((x-Q2).^2./(2.*V2))))),obj.T, Inf);
    %            SP1 = (1/sqrt(2*pi*V1)).*integral(@(x)(exp((-((x-Q1).^2./(2.*V1))))),obj.T, Inf);
                SP2 = 1-normcdf(obj.T,Q2,sqrt(V2));
                SP1 = 1-normcdf(obj.T,Q1,sqrt(V1));
                
            else
%                 Q1 = randn(100000, 1,1)*sqrt(obj.V(1))+obj.Q(1); %sampled values from current prior distribution of option1
%                 Q2 = randn(100000, 1,1)*sqrt(obj.V(2))+obj.Q(2); %sampled values from current prior distribution of option2
%                 Qdiff = Q2-Q1;
                confNoise =  sqrt(obj.V(1)+obj.V(2)+(1./obj.beta)^2);
%                 rng(1)
                Qdiff = randn(100000, 1,1)*confNoise+(obj.Q(2)-obj.Q(1));
                dQ = obj.Q(2)-obj.Q(1); 
                if action ==2
                    confdist = (normpdf(Qdiff,abs(dQ),confNoise))./((normpdf(Qdiff,abs(dQ),confNoise))+(normpdf(Qdiff,-abs(dQ),confNoise)));
                else
                    confdist = (normpdf(Qdiff,-abs(dQ),confNoise))./((normpdf(Qdiff,abs(dQ),confNoise))+(normpdf(Qdiff,-abs(dQ),confNoise)));
                end
                confp = sum(confdist>confRating-confMargin & confdist<confRating+confMargin)./numel(confdist);
            end
            if confp ==0
                confp = 1./100000;
            end
        end

    end
    methods (Static)
    end
end