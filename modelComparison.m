% load('Results\model_fitsMLE_exp1');
load('Results\model_fitsMAP_exp1');

addpath('ModelingFuncs\')
addpath('helperfuncs')
loadExp1;

    n_trials = size(Choices,1);
    nfpm = [];
    for imodel = 1:numel(parameters)
        nfpm = [nfpm,size(parameters{imodel},2)];
    end
    for n= 1:numel(parameters);
        bic(:,n)=-2*-ll(:,n)+nfpm(n)*log(n_trials); 

    end

    [postBMC,outBMC]  = VBA_groupBMC(-bic(:,:)'/2);

