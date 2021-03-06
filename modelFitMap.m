% outfilename = 'model_fitsMAPNew_exp1';
% outfilename = 'model_fitsMAP_exp1FLEMBIASED3';
% outfilename = 'model_fitsMAP_exp1_20200227';

% outfilename = 'model_fitsMAP_exp1_20200302';
% outfilename = 'model_fitsMAP_exp1_RC';

outfilename = 'model_fitsMAP_exp1_nodrift';

addpath('ModelingFuncs\')
addpath('helperfuncs');

loadExp1;

Choices = Choices + 2;
Choices(Choices==3) = 2;

% loadModelsInfoRC; 
loadModelsInfoNoDrift; 

% loadModelsInfoFlemingBiased;
ntrials = size(Choices,1);

whichmodels = 1:numel(modelsinfo);
options = optimset('Algorithm', 'interior-point', 'Display', 'final', 'MaxIter', 10000); % These increase the number of iterations to ensure the convergence

ll = NaN(size(Choices,2),numel(whichmodels));
LPP = NaN(size(Choices,2),numel(whichmodels));
LAME = NaN(size(Choices,2),numel(whichmodels));
bic = NaN(size(Choices,2),numel(whichmodels));
aic = NaN(size(Choices,2),numel(whichmodels));

for imodel = whichmodels;
    lb = modelsinfo{imodel}.lb;
    ub = modelsinfo{imodel}.ub;
    x0 = modelsinfo{imodel}.x0;
    parfor isub = 1:size(Choices,2)
        [theseParams,thisLPP,~,report(isub,imodel),~,gradient{isub,imodel},thisH]=fmincon(@(x) GetModelLL_QLearner(x,modelsinfo{imodel},Choices(:,isub),Reward(:,isub),1),x0,[],[],[],[],lb,ub,[],options);
        paramsPerSub(isub,:) = theseParams;
        nfpm = numel(modelsinfo{imodel}.paramnames);
        hessian{isub,imodel} = thisH;
        LPP(isub,imodel);
        this_ll =  GetModelLL_QLearner(theseParams,modelsinfo{imodel},Choices(:,isub),Reward(:,isub),0);
        ll(isub,imodel) = this_ll;
        bic(isub,imodel)=-2*-this_ll+nfpm*log(ntrials);
        aic(isub, imodel)=-2*-this_ll+nfpm; 
        LAME(isub,imodel) =  thisLPP - nfpm/2*log(2*pi) + real(log(det(thisH))/2);%Laplace-approximated model evidence
    end
    parameters{imodel} = paramsPerSub;
    clear paramsPerSub;
end

save(['Results\',outfilename],'parameters','LPP', 'modelsinfo','bic', 'aic','ll','LAME')