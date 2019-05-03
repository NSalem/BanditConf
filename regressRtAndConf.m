addpath('ModelingFuncs\');
addpath('helperfuncs\');
loadExp1;
load('Results\model_fitsMLE_exp1OLD.mat');
Choices = Choices + 2;
Choices(Choices==3) = 2;

models = [1:5];
resultsdir = ['Results',filesep];
outfilename = '';


for isub = 1:size(Choices,2)
    cho_sub = Choices(:,isub);
    out_sub = Reward(:,isub);
    conf_sub = AbsConf(:,isub);
    RT_sub = RT(:,isub);
    ntrials = size(Choices,1);
    for imodel = models

            params_sub = parameters{imodel}(isub,:);

            paramstruct = modelsinfo{imodel};
            for iparam = 1:numel(modelsinfo{imodel}.paramnames)
                paramstruct.(modelsinfo{imodel}.paramnames{iparam}) = params_sub(iparam);
            end

        %% Calculate hidden variables
        [Q_sub,V_sub,pc,PE]  = Computational_TimeSeries_QLearner(paramstruct,cho_sub(:),out_sub(:));
        dQ_sub = abs(squeeze(Q_sub(2,1:ntrials)-Q_sub(1,1:ntrials)));
            for itrl = 1:ntrials
                if isnan(cho_sub(itrl))
                    Q_c(itrl) = NaN;
                    Q_uc(itrl) = NaN; 
                else
                    Q_c(itrl) = Q_sub(cho_sub(itrl),itrl);
                    Q_uc(itrl) = Q_sub(3-cho_sub(itrl),itrl); 
                end
            end
        pc_all(imodel,isub,:) = pc;
        %% Regressions
        varnames = {'conf','pc'};
        tbl = table(conf_sub(:),pc(:),'VariableNames', varnames);
        formula = 'conf ~ 1 + pc';
        lm = fitlm(tbl,formula);
        coeff(imodel,isub,:) = lm.Coefficients.Estimate;
        tval(imodel,isub,:) = lm.Coefficients.tStat;

        BIC(imodel,isub) = lm.ModelCriterion.BIC;
    end     
end

 [postBMCconf,outBMCconf] = VBA_groupBMC(-BIC/2)