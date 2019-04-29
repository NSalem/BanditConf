%%% test model and parameter identifiability with synthetic data%%%
%%% populations are generated for each model, and their resulting behavior (choices
%%% and confidence) is fitted on each model 

clear 
close all
addpath('ModelingFuncs\');
addpath('helperfuncs\')
outfilename = 'model_simulations_results';
loadExp1; %load experiment 1 to use the same probability distributions for outcomes

n_sims      = 50;
n_sub       = size(Choices,2);
ntrials = size(Choices,1);
estimateLPP = 1;
estimateML = 0;

% models = 1:6;
% n_models = 6;


%% establish distribution of generative parameters

 gen.lrm = @()random('Beta',1.1,1.1);
 gen.lrv = @()random('Beta',1.1,1.1);
 gen.lrm2 = gen.lrm;
 gen.lrv2 = gen.lrv;
 gen.lambda = @()random('Beta',1.1,1.1);
 gen.beta  = @()random('Gamma',1.2,5);
 gen.T = @()random('Beta',1.1,1.1)*100;

 loadModelsInfo;

% load parameters from model fits
% load ('model_fits.mat','parameters','modelsinfo')
% fittedParams = parameters;

clear parameters;

%% initialize arrays, etc
n_models = numel(modelsinfo);
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
kk = 0;
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
%                 paramstructgen.(thisParam) = fittedParams{igenmodel}(isub,iparam);
%                 genparams{isim,isub,igenmodel} = fittedParams{igenmodel}(isub,iparam);
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

             
                %%% simulate confidence %%%                

                %%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%
                
            for irecmodel = 1:n_models
                lb = modelsinfo{irecmodel}.lb;
                ub = modelsinfo{irecmodel}.ub;
                x0 = modelsinfo{irecmodel}.x0;
                disp(['Simulation ', num2str(isim), '/',num2str(n_sims)])
                disp(['Gen.Model ',num2str(igenmodel), ' ', 'Rec.Model ', num2str(irecmodel)])
                disp(['Subj ', num2str(isub), '/',num2str(n_sub)])

                if igenmodel == n_models && irecmodel == n_models
                    kk=kk+1;
                    corr_mat(isub,:,:) = transpose(squeeze(mean(reshape((a-1)',ntrials,4,n_sess),3)));
                    %                 corr_mat(isub,:,:) = squeeze(nanmean(reshape((a-1)',3,4,ntrials),1));
%                     con_mat(isub,:,:) = transpose(squeeze(mean(reshape(conf',ntrials,4,n_sess),3)));
                    %con_mat(isub,:,:) = squeeze(nanmean(reshape(conf(:)',3,4,ntrials),1));
                end

                options = optimset('Algorithm', 'interior-point', 'Display', 'final', 'MaxIter', 10000); % These increase the number of iterations to ensure the convergence
                

                if estimateLPP
                    % LPP (Laplace appriximation of the posterior probability) optimization    
                                       % LPP (Laplace appriximation of the posterior probability) optimization    
%                     [parametersLPP{isim,isub,igenmodel,irecmodel},LPP(isim,isub,igenmodel,irecmodel),~,~,~,~,hessian]=fmincon(@(x) GetModelLL_QLearner(x,modelsinfo{irecmodel},s,a,r,c,aa,ss,1),x0,[],[],[],[],lb,ub,[],options);
%                     thisLPP = LPP(isim,isub,igenmodel,irecmodel);
%                     k = numel(modelsinfo{irecmodel}.paramnames);
%                     LAME(isim,isub,igenmodel,irecmodel) =  thisLPP + k/2*log(2*pi) - real(log(det(hessian))/2);%Laplace-approximated model evidence
%                     this_ll = GetModelLL_QLearner(parametersLPP{isim,isub,igenmodel,irecmodel},modelsinfo{irecmodel},s,a,r,c,aa,ss,0);

                    [parametersLPP{isim,isub,igenmodel,irecmodel},LPP(isim,isub,igenmodel,irecmodel),~,~,~,~,hessian]=fmincon(@(x) GetModelLL_QLearner(x,modelsinfo{irecmodel},a,r,1),x0,[],[],[],[],lb,ub,[],options);
%                     LPP(isim,isub,igenmodel,irecmodel) = this_LPP;
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
    save(['Results',filesep,outfilename], 'recfreqs','pxps', 'aic', 'bic', 'LPP', 'LAME', 'parametersLPP', 'parameters', 'genparams','corr_mat','con_mat', 'regress', 'ntrials', 'n_sims', 'modelsinfo','-append')
end

con_mat2 = (con_mat-max(con_mat(:)))/((max(con_mat(:))-min(con_mat(:))))*(1-0.5)+1;%green = '\color[rgb]{0,1,0}'
n_sub_all = size(corr_mat,1);

save(['Results',filesep,outfilename], 'recfreqs','pxps', 'aic', 'bic', 'LPP', 'LAME', 'parametersLPP', 'parameters', 'genparams','corr_mat','con_mat', 'regress', 'ntrials', 'n_sims', 'modelsinfo')

