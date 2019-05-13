% load('Results\model_fitsMLE_exp1');
load('Results\model_fitsMAP_exp1');

addpath('ModelingFuncs\')
addpath('helperfuncs')
% loadExp1;

modellabels= {'Q1','Q2','Q1V1','Q2V1','Q1V2','Q1V1-T','Q2V1-T','Q1V2-T'}
        
if ~exist('bic')
    n_trials = size(Choices,1);
    nfpm = [];
    for imodel = 1:numel(parameters)
        nfpm = [nfpm,size(parameters{imodel},2)];
    end
    for n= 1:numel(parameters);
        bic(:,n)=-2*-ll(:,n)+nfpm(n)*log(n_trials); 

    end
end
    [postBMC,outBMC]  = VBA_groupBMC(-bic(:,:)'/2);

   
    figure()
    bar(outBMC.Ef);
    xticklabels(modellabels)
    xtickangle(40)
    hold on
    ylabel('model frequencies')
    plot([0,9],[1/8,1/8],'k:')
    set(gca,'FontSize', 14)