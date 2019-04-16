     %%% Fit all (selected) models to data from all experiments %%%
%     addpath('ModelingFuncs\');
%     resultsdir = ['Results', filesep];
% %     outfilenameprefix = 'MODEL_RLconf_ns';
%     exps = load([resultsdir,datafilename]);
%     
%     exps = load([resultsdir,'data_all_CONF'])
    % outfilenameprefix = 'MODEL_RL_sample2_';
    % exps = load([resultsdir,'data_all_sample2'])
%     whichexp = 1:5;
%     modelsinfo = struct{};
   dels to be compared, further explained in the other functions

        %% Parameters optimization
        % This part requires the Matlab Optimization toolbox
        options = optimset('Algorithm', 'interior-point', 'Display', 'iter-detailed', 'MaxIter', 10000); % These increase the number of iterations to ensure the convergence
            lb = [0,0];
            ub = [100,100];
            x0 = [];
            for k_sub = 1:n_sub
            
                aa_this_sub = [];
                ss_this_sub = [];
                % Likelihood Mawximization
                [parameters(k_sub,:),ll(k_sub,model),report(k_sub,model),gradient{k_sub,model},hessian{k_sub,model}]=fmincon(@(x) GetModelLL(x,dumcon,Choices(:,k_sub),Reward(:,k_sub),x0,[],[],[],[],lb,ub,[],options));
  
                % LPP (Laplace appriximation of the posterior probability) optimization
%                [parametersLPP{k_sub,model},LPP(k_sub,model),~,reportLPP(k_sub,model),~,gradientLPP{k_sub,model},hessianLPP{k_sub,model}]=fmincon(@(x) GetModelLL_QLearner(x,modelsinfo{model},con{k_sub},cho{k_sub},out{k_sub},cou{k_sub},aa_this_sub,ss_this_sub,1),x0,[],[],[],[],lb,ub,[],options);
    %            [parametersLPP(k_sub,:,model),LPP(k_sub,model),reportLPP(k_sub,model),gradientLPP{k_sub,model},hessianLPP{k_sub,model}]=fmincon(@(x) GetModelLL_QLearner(x,con{k_sub},cho{k_sub},out{k_sub},cou{k_sub},[],[],model,1),[1 .5 .5 .5 1],[],[],[],[],[0 0 0 0 0],[Inf 1 1 1 2],[],options);
%                     thisH = hessianLPP{k_sub,model};
%                     thisLPP = LPP(k_sub,model);
                    k = numel(modelsinfo{model}.paramnames);
%                     LAME(k_sub,model) =  thisLPP + k/2*log(2*pi) - real(log(det(thisH))/2);%Laplace-approximated model evidence
%                     ll(k_sub,model) = GetModelLL_QLearner(parametersLPP{k_sub,model},modelsinfo{model},con{k_sub},cho{k_sub},out{k_sub},cou{k_sub},aa_this_sub,ss_this_sub,0)
                    clear thisLPP thisH k aa_this_sub ss_this_sub
            end
%             modelinfo = modelsinfo{model}; 
%             fmin_info.report = report; fmin_info.gradient = gradient; fmin_info.hessian = hessian;
            fmin_info.reportLPP = reportLPP; fmin_info.gradientLPP = gradientLPP; fmin_info.hessianLPP = hessianLPP;
            modelsinfo{model}.fmin_info{k_sub} = fmin_info;
    
            datainfo.experiments{iexp} = exps(iexp).exp;
            datainfo.subjects{iexp} = exps(iexp).subjects;
            datainfo.sessions = sessthisexp;
            datainfo.postlearning = useposttest;
        save(['Results',filesep,outfilenameprefix,num2str(exps(iexp).expN)],'parametersLPP','LAME','modelsinfo','datainfo','ll','fmin_info');
        clear LAME LPP hessianLPP ll con cho out cou aa ss parameters parametersLPP modelinfo fmin_info clear ub lb x0 n_trials n_sub n_sess reportLPP gradientLPP 
       