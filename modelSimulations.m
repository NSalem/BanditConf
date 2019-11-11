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

nsims      = 50;
nsub       = size(Choices,2);
ntrials = size(Choices,1);
estimateLPP = 1;
estimateML = 0;


 loadModelsInfo;
 nmodels = numel(modelsinfo);

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
parametersLPP = cell(nsims,nsub,nmodels,nmodels);
genparams = cell(nsims,nsub,nmodels);
reportLPP = cell(nsims,nsub,nmodels,nmodels);
LPP  = NaN(nsims,nsub,nmodels,nmodels);
gradientLPP = cell(nsims,nsub,nmodels,nmodels);
hessianLPP = cell(nsims,nsub,nmodels,nmodels);
LAME = NaN(nsims,nsub,nmodels,nmodels);
ll = NaN(nsims,nsub,nmodels,nmodels);

LPP = nan(nsims, nsub, nmodels,nmodels); %LPP matrix of generative models by recovered models for each subj and sim
ll = zeros(nsims, nsub, nmodels,nmodels);
recfreqs.LL = zeros(nmodels,nmodels);
recfreqs.AIC = zeros(nmodels,nmodels);
recfreqs.BIC = zeros(nmodels,nmodels);
recfreqs.LAME = zeros(nmodels,nmodels);
recfreqs.regressBIC = zeros(nmodels,nmodels);
recfreqs.regressAIC = zeros(nmodels,nmodels);

pxps.LL = zeros(nsims, nmodels, nmodels);
pxps.AIC = zeros(nsims, nmodels, nmodels);
pxps.BIC = zeros(nsims, nmodels, nmodels);
pxps.regressBIC = zeros(nsims, nmodels, nmodels);
pxps.regressAIC = zeros(nsims, nmodels, nmodels);

aic= zeros(nsims, nsub, nmodels,nmodels);
bic = zeros(nsims, nsub, nmodels,nmodels);
   
%% start simulations

for isim = 1:nsims
    for igenmodel = 1:nmodels
        for isub =1:nsub
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

                
            parfor irecmodel = 1:nmodels
                lb = modelsinfo{irecmodel}.lb;
                ub = modelsinfo{irecmodel}.ub;
                x0 = modelsinfo{irecmodel}.x0;
                disp(['Simulation ', num2str(isim), '/',num2str(nsims)])
                disp(['Gen.Model ',num2str(igenmodel), ' ', 'Rec.Model ', num2str(irecmodel)])
                disp(['Subj ', num2str(isub), '/',num2str(nsub)])

                options = optimset('Algorithm', 'interior-point', 'Display', 'final', 'MaxIter', 10000); % These increase the number of iterations to ensure the convergence
                

                if estimateLPP
                    [parametersLPP{isim,isub,igenmodel,irecmodel},thisLPP,~,~,~,~,hessian]=fmincon(@(x) GetModelLL_QLearner(x,modelsinfo{irecmodel},a,r,1),x0,[],[],[],[],lb,ub,[],options);
                    k = numel(modelsinfo{irecmodel}.paramnames);
                    LPP(isim,isub,igenmodel,irecmodel) = thisLPP;
                    this_ll = GetModelLL_QLearner(parametersLPP{isim,isub,igenmodel,irecmodel},modelsinfo{irecmodel},a,r,0);
                    bic(isim, isub,igenmodel,irecmodel)=-2*-this_ll+k*log(ntrials);
                    aic(isim, isub,igenmodel,irecmodel)=-2*-this_ll+k; 
                    LAME(isim, isub,igenmodel,irecmodel) =  thisLPP - k/2*log(2*pi) + real(log(det(hessian))/2);%Laplace-approximated imodel evidence
                end
                paramstructrec = modelsinfo{irecmodel};
                params = parametersLPP{isim,isub,igenmodel,irecmodel};
                paramnames = modelsinfo{irecmodel}.paramnames;
                for ipar = 1:numel(paramnames)
                    paramstructrec.(char(paramnames(ipar))) = params(ipar);
                end
            end
        end
    end
    if ~exist(['Results',filesep,outfilename])
        save(['Results',filesep,outfilename], 'recfreqs','pxps', 'aic', 'bic', 'LAME','LPP', 'parametersLPP', 'genparams', 'ntrials', 'nsims', 'modelsinfo')
    else
        save(['Results',filesep,outfilename], 'recfreqs','pxps', 'aic', 'bic', 'LAME','LPP', 'parametersLPP', 'genparams', 'ntrials', 'nsims', 'modelsinfo','-append')
    end
end

% con_mat2 = (con_mat-max(con_mat(:)))/((max(con_mat(:))-min(con_mat(:))))*(1-0.5)+1;%green = '\color[rgb]{0,1,0}'
n_sub_all = size(corr_mat,1);

save(['Results',filesep,outfilename], 'recfreqs','pxps', 'aic', 'bic','LAME','LPP','parametersLPP', 'genparams','ntrials', 'nsims', 'modelsinfo')

