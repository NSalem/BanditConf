%%% test model and parameter identifiability with synthetic data%%%
%%% populations are generated for each model, and their resulting behavior (choices
%%% and confidence) is fitted on each model 
%%% modelConfusion.m can be ran on these results afterwards to show the
%%% actual confusion matrix;

clear 
close all
addpath('ModelingFuncs\');
addpath('helperfuncs\')
outfilename = 'model_simulations_results_exp1.mat';
loadExp1; %load experiment 1 to use the same probability distributions for outcomes

n_sims      = 50;
n_sub       = size(Choices,2);
ntrials = size(Choices,1);
estimateLPP = 1;
estimateML = 0;


 loadModelsInfo;
 n_models = numel(modelsinfo);

%% establish distribution of generative parameters

 gen.lrm = @()random('Beta',1.1,1.1);
 gen.lrv = @()random('Beta',1.1,1.1);
 gen.lrm2 = gen.lrm;
 gen.lrv2 = gen.lrv;
 gen.lambda = @()random('Beta',1.1,1.1);
 gen.beta  = @()random('Gamma',1.2,5);
 gen.T = @()random('Beta',1.1,1.1)*100;


clear parameters;

%% initialize arrays, etc
% n_models = numel(modelsinfo);
parametersLPP = {};
parametersLPP = {};
LPP = nan(n_sims, n_sub, n_models,n_models); %LPP matrix of generative models by recovered models for each subj and sim
ll = zeros(n_sims, n_sub, n_models,n_models);
recfreqs.LL = zeros(n_models,n_models);
recfreqs.AIC = zeros(n_models,n_models);
recfreqs.BIC = zeros(n_models,n_models);
recfreqs.LAME = zeros(n_models,n_models);
recfreqs.regressBIC = zeros(n_models,n_models);
recfreqs.regressAIC = zeros(n_models,n_models);

pxps.LL = zeros(n_sims, n_models, n_models);
pxps.AIC = zeros(n_sims, n_models, n_models);
pxps.BIC = zeros(n_sims, n_models, n_models);
pxps.regressBIC = zeros(n_sims, n_models, n_models);
pxps.regressAIC = zeros(n_sims, n_models, n_models);

aic= zeros(n_sims, n_sub, n_models,n_models);
bic = zeros(n_sims, n_sub, n_models,n_models);
   
%% start simulations

for isim = 1:n_sims
    for igenmodel = 1:n_models
        for isub =1:n_sub
            OUT(1,:) = round(randn(size(Pl,1),1).*Vl(:,isub)+Pl(:,isub));
            OUT(2,:) = round(randn(size(Pl,1),1).*Vr(:,isub)+Pr(:,isub));
            OUT(OUT<5) = 5;
            OUT(OUT>95) = 95;
                
            paramstructgen = modelsinfo{igenmodel};
            genparams{isim,isub,igenmodel} = [];
            for iparam = 1:numel(modelsinfo{igenmodel}.paramnames)
                thisParam = modelsinfo{igenmodel}.paramnames{iparam};
                paramstructgen.(thisParam) = gen.(thisParam)();
                genparams{isim,isub,igenmodel} = [genparams{isim,isub,igenmodel},paramstructgen.(thisParam)];
            end
                

               
                %%% simulate choice and value %%%
                [Q,V,pc,a,r] = Computational_Simus_QLearner(paramstructgen,OUT);
                dQ = squeeze(Q(2,:)-Q(1,:));
                
                for itrl = 1:ntrials
                    if isnan(a(itrl))
                        Q_c(itrl) = NaN;
                        Q_uc(itrl) = NaN; 
                    else
                        Q_c(itrl) = Q(a(itrl),itrl);
                        Q_uc(itrl) = Q(3-a(itrl),itrl); 
                    end
                end
                sigmaQ = Q_c+Q_uc;

                
            for irecmodel = 1:n_models
                lb = modelsinfo{irecmodel}.lb;
                ub = modelsinfo{irecmodel}.ub;
                x0 = modelsinfo{irecmodel}.x0;
                disp(['Simulation ', num2str(isim), '/',num2str(n_sims)])
                disp(['Gen.Model ',num2str(igenmodel), ' ', 'Rec.Model ', num2str(irecmodel)])
                disp(['Subj ', num2str(isub), '/',num2str(n_sub)])

                options = optimset('Algorithm', 'interior-point', 'Display', 'final', 'MaxIter', 10000); % These increase the number of iterations to ensure the convergence
                

                if estimateLPP
                    [parametersLPP{isim,isub,igenmodel,irecmodel},LPP(isim,isub,igenmodel,irecmodel),~,~,~,~,hessian]=fmincon(@(x) GetModelLL_QLearner(x,modelsinfo{irecmodel},a,r,1),x0,[],[],[],[],lb,ub,[],options);
                    nfpm = numel(modelsinfo{irecmodel}.paramnames);
                    this_ll = GetModelLL_QLearner(parametersLPP{isim,isub,igenmodel,irecmodel},modelsinfo{irecmodel},a,r,0);
                    bic(isim, isub,igenmodel,irecmodel)=-2*-this_ll+nfpm*log(ntrials);
                    aic(isim, isub,igenmodel,irecmodel)=-2*-this_ll+nfpm; 
                    
                end

                paramstructrec = modelsinfo{irecmodel};
                params = parametersLPP{isim,isub,igenmodel,irecmodel};
                paramnames = modelsinfo{irecmodel}.paramnames;
                for ipar = 1:numel(paramnames)
                    paramstructrec.(char(paramnames(ipar))) = params(ipar);
                end
                
%                 [Q,V,~,~,~,~,dQ_post, V_post] = Computational_TimeSeries_QLearner(paramstructrec,s,a,r,c,aa,ss);
%                 dQ = squeeze(Q(:,2,1:24)-Q(:,1,1:24));
%                 V = V(:,1:24);
            end
        end
    end
    if ~exist(['Results',filesep,outfilename])
        save(['Results',filesep,outfilename], 'recfreqs','pxps', 'aic', 'bic', 'LPP', 'parametersLPP', 'genparams', 'ntrials', 'n_sims', 'modelsinfo')
    else
        save(['Results',filesep,outfilename], 'recfreqs','pxps', 'aic', 'bic', 'LPP', 'parametersLPP', 'genparams', 'ntrials', 'n_sims', 'modelsinfo','-append')
    end
end

% con_mat2 = (con_mat-max(con_mat(:)))/((max(con_mat(:))-min(con_mat(:))))*(1-0.5)+1;%green = '\color[rgb]{0,1,0}'
n_sub_all = size(corr_mat,1);

save(['Results',filesep,outfilename], 'recfreqs','pxps', 'aic', 'bic', 'LPP','parametersLPP', 'genparams','ntrials', 'n_sims', 'modelsinfo')

