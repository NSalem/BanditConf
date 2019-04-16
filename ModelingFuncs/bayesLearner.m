classdef bayesLearner < handle
    properties 
        startPriorMeans = [0,0]
        startPriorVars = [10,10]
        priorMeans 
        priorVars 
        likelihoodVarConf
        likelihoodVarDisc
    end

    methods
        function obj = bayesLearner(startPriorMeans, startPriorVars, likelihoodVarConf, likelihoodVarDisc)
        
        %object = bayesLearner(startPriorMeans, startPriorVars, likelihoodVarConf, likelihoodVarDisc, relative)
        %create a bayesian learner object
        %startPriorMeans: vector or matrix for starting prior means for
        %each state and action...
        %startPriorVars
        %likelihoodVarConf: likelihood variance for confirmatory outcomes
        %likelihoodVarDisc: likelihood variance for disconfirmatory outcomes
        %relative: whether the model uses relative value
        
        if isempty(startPriorMeans)
            startPriorMeans = [0,0];
        end
        
        if isempty(startPriorVars)
            startPriorVars = [4,4];
        end
        
        obj.startPriorMeans= startPriorMeans;
        obj.startPriorVars = startPriorVars;
        obj.priorMeans = startPriorMeans;
        obj.priorVars = startPriorVars;
        obj.likelihoodVarConf = likelihoodVarConf;
        obj.likelihoodVarDisc = likelihoodVarDisc;
        
            if obj.likelihoodVarDisc == 0
                obj.likelihoodVarDisc = obj.likelihoodVarConf;
            end
        end
        
        function learn(obj, state, action, r)
            %%% updates prior distributions for value of the chosen (and
            %%% unchosen option if u is given), as well as the context
            %%% value if obj.relative is true
            %%% state: integer indicating current state
            %%% action: integer (1 or 2) indicating the action taking this
            %%% trial
            %%% r: (float) factual monetary reward 
            %%% u: (float, empty or NaN) counterfactual monetary reward (optional)
       
            if state>size(obj.priorMeans,1)%||action>size(obj.priorMeans,2)
                obj.priorMeans(state, :) = obj.startPriorMeans;
                obj.priorVars(state,:) = obj.startPriorVars;
            end                               
        %%
            %% update confirmatory and disconfirmatory
            delta = r - obj.priorMeans(state,action);
            likelihoodChosen = [obj.likelihoodVarConf(delta>=0),obj.likelihoodVarDisc(delta<0)]; 

            if ~isempty(likelihoodChosen)%&& likelihoodChosen~=0
            %use a value of likelihood variance according to sign of prediction error 
                [obj.priorMeans(state, action), obj.priorVars(state,action)] = ...
                obj.bayesUpdate(obj.priorMeans(state, action), obj.priorVars(state,action), r, likelihoodChosen);
            end

        end
    
        function [action,p] = chooseAction(obj, state)
                %state: number representing state
                %
                %Outputs:
                %action: (1 or 2)
                %p: Probability of having chosen action based on the state

           if state>size(obj.priorMeans,1)
                obj.priorMeans(state, :) = obj.startPriorMeans;
                obj.priorVars(state,:) = obj.startPriorVars;
           end

            Q1 = randn(1000, 1,1)*sqrt(obj.priorVars(state,1))+obj.priorMeans(state,1); %sampled values from current prior distribution of option1
            Q2 = randn(1000, 1,1)*sqrt(obj.priorVars(state,2))+obj.priorMeans(state,2); %sampled values from current prior distribution of option2

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
    end
    
    methods (Static)
        function [meanPosterior, varPosterior] = bayesUpdate(meanPrior, varPrior, r, varLikelihood)
        %%basic bayes updating function, is called from object.learn
        %%method
        
        n = numel(r); %number of observations, for updating it will be 1?

        meanPosterior = ...
        (1/(1/varPrior+n/varLikelihood))*(meanPrior/varPrior+sum(r)/varLikelihood);

        varPosterior = (1/varPrior+n/varLikelihood)^-1;

        end
    end
end