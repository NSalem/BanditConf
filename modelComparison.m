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
    %kk = 0;
    for n= 1:numel(parameters);
    %    kk = kk+1;
        bic(:,n)=-2*-ll(:,n)+nfpm(n)*log(n_trials); % l2 is already positive
    %     aic_this_exp(:,n)=-2*-ll(:,n)+2*nfpm(n);
    %     LAME_this_exp(:,n) = LAME;
    end
    %     [postBMC,outBMC]  = VBA_groupBMC(-bic_this_exp'/2);
    %     post{ifile} = postBMC.r;
    %     postratio{ifile} = ((postBMC.r(2,:)-postBMC.r(1,:))./(postBMC.r(2,:)+postBMC.r(1,:)))';
    
    [postBMC,outBMC]  = VBA_groupBMC(-bic(:,:)'/2);

