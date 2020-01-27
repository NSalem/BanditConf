% load('Results\model_fitsMLE_exp1');
% load('Results\model_fitsMAP_exp1V0_10.mat');

load('Results\model_fitsMAPNew_exp1.mat');
addpath('ModelingFuncs\')
addpath('helperfuncs')
% loadExp1;

% modellabels= {'Q1','Q2','Q1V1','Q2V1','Q1V2','Q1V1-T','Q2V1-T','Q1V2-T'}
modellabels= {'Q1','Q2','Q1V1','Q2V1','Q1V2','Q2V2','Q1V1-T','Q2V1-T','Q1V2-T','Q2V2-T'}
        
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
    [postBMC,outBMC]  = VBA_groupBMC(-LAME(:,:)'/2);

   
%     figure()
%     bar(outBMC.Ef);
%     xticklabels(modellabels)
%     xtickangle(40)
%     hold on
%     ylabel('model frequencies')
%     plot([0,9],[1/8,1/8],'k:')
%     set(gca,'FontSize', 14)




%% no V vs V
options.families = {[1,2],[3:10]}
[postBMC,outBMC]  = VBA_groupBMC(-LAME(:,:)'/2,options); %%% V wins


%% Q vs optimal vs SSAT
options.families = {[1,2],[3:6],[7:10]}
[postBMC,outBMC]  = VBA_groupBMC(-LAME(:,:)'/2,options); %%% SSAT wins


%% SSAT unbiased vs biased learning
options.families = {[1],[2:4]}
[postBMC,outBMC]  = VBA_groupBMC(-LAME(:,7:10)'/2,options); %%% unconclussive

%% SSAT all
[postBMC,outBMC]  = VBA_groupBMC(-LAME(:,7:10)'/2); %%% pxp = .90, unbiased winning

figure()
errorbar([1:size(LAME,2)],nanmean(LAME),nanstd(LAME)./(sqrt(size(LAME,1))))
xticklabels(modellabels)
ylabel('Model evidence (LAME)')
xtickangle(45)

% unbiased vs optimistic
options.families = {[1,3,7],[2,4:6,8:10]}
[postBMC,outBMC]  = VBA_groupBMC(-LAME(:,:)'/2,options); %%% optimistic (ep = .96)


%% optimistic mean, sd, both?
dum = LAME(:,[2,4:6,8:10]); 
options.families = {[1,2,5],[3,6],[4,7]}
[postBMCconf,outBMCconf] = VBA_groupBMC(-dum(:,:)'/2,options) %% mean (ep = .99)

% unbiased vs optimistic each cat
options.families = {[1,3,7],[2,4,8],[5,9],[6,10]}
[postBMC,outBMC]  = VBA_groupBMC(-LAME(:,:)'/2,options); %%% unbiased (ep = .95)
