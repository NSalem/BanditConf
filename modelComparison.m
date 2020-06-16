% load('Results\model_fitsMLE_exp1');
% load('Results\model_fitsMAP_exp1V0_10.mat');

% load('Results\model_fitsMAPNew_exp1.mat');
load('Results\model_fitsMAP_exp1_20200227.mat');
% load('Results\model_fitsMAP_exp1_nodrift.mat');

extraMods = load('Results\model_fitsMAP_exp1_RC.mat'); %noisy bayes, RC, noisy RC

LAME_all = [LAME,extraMods.LAME]

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
options.families = {[1,2],[3:10]};
options.DisplayWin = 0;
[postBMC,outBMC]  = VBA_groupBMC(-LAME(:,:)'/2,options); %%% V wins



%% Q vs optimal vs SSAT
% options.families = {[1,2],[3:6],[7:10]}
% [postBMC,outBMC]  = VBA_groupBMC(-LAME(:,:)'/2,options); %%% SSAT wins

%%11:13 are noise bayes, RC, and noisy RC
options.families = {[1,2],[3:6,11],[12,13],[7:10],} %%%% change 
[postBMC,outBMC]  = VBA_groupBMC(-LAME_all(:,:)'/2,options); %%% SSAT wins

famNames = {'Q','Bayes','Bayes-RC','SSAT'};
figure()
set(gcf,'Color',[1,1,1])

hold on

bar(squeeze(100*outBMC.families.ep),...
    'FaceColor',.7*[1,1,1],...
    'EdgeColor','none')
alpha(0.5)

% plot(squeeze(100*outBMC.families.pxp),'-o',...
%     'Color',.7*[1,1,1],...
%     'MarkerFaceColor',.7*[1,1,1],...
%     'MarkerEdgeColor',[1,1,1])

errorbar(100*outBMC.families.Ef,100*sqrt(outBMC.families.Vf),'d',...
    'Color',.5*[1,1,1],...
    'MarkerFaceColor',.7*[1,1,1],...
    'MarkerEdgeColor',.5*[1,1,1],...
    'LineStyle','None')
plot([-1,numel(outBMC.families.Ef)+1],100*[1./numel(outBMC.families.Ef),1./numel(outBMC.families.Ef)],'r--');
plot([-1,size(outBMC.families.Ef,1)+1],100*[0.95,0.95],'b--')

set(gca,'YLim', [0 100],...
    'XTick',1:numel(outBMC.families.Ef),...
    'XTickLabels',famNames,...
    'XLim',[0 size(outBMC.families.Ef,1)+1],...
    'FontName','Arial')
xtickangle(90)

hL = legend('Exceedence P.','Expected F.');
hY = ylabel('probability');
set([hY,hL],'FontName','Arial')
set(hL,'Location','Best')
legend boxoff

%% SSAT unbiased vs biased learning
options.families = {[1],[2:4]}
[postBMC,outBMC]  = VBA_groupBMC(-LAME(:,7:10)'/2,options); %%% unconclussive

famNames = {'Symmetric','Biased'};
figure()
set(gcf,'Color',[1,1,1])
hold on

bar(squeeze(100*outBMC.families.ep),...
    'FaceColor',.7*[1,1,1],...
    'EdgeColor','none')
alpha(0.5)

% plot(squeeze(100*outBMC.families.pxp),'-o',...
%     'Color',.7*[1,1,1],...
%     'MarkerFaceColor',.7*[1,1,1],...
%     'MarkerEdgeColor',[1,1,1])

errorbar(100*outBMC.families.Ef,100*sqrt(outBMC.families.Vf),'d',...
    'Color',.5*[1,1,1],...
    'MarkerFaceColor',.7*[1,1,1],...
    'MarkerEdgeColor',.5*[1,1,1],...
    'LineStyle','None')
plot([-1,numel(outBMC.families.Ef)+1],100*[1./numel(outBMC.families.Ef),1./numel(outBMC.families.Ef)],'r--');
plot([-1,size(outBMC.families.Ef,1)+1],100*[0.95,0.95],'b--')

set(gca,'YLim', [0 100],...
    'XTick',1:numel(outBMC.families.Ef),...
    'XTickLabels',famNames,...
    'XLim',[0 size(outBMC.families.Ef,1)+1],...
    'FontName','Arial')
xtickangle(90)

hL = legend('Exceedence P.','Expected F.');
hY = ylabel('probability');
set([hY,hL],'FontName','Arial')
set(hL,'Location','Best')
legend boxoff

set(gcf,'Position',[0,0,350,400])


%%%% extra stuff
%% SSAT all
[postBMC,outBMC]  = VBA_groupBMC(-LAME(:,7:10)'/2); %%% pxp = .90, unbiased winning

figure()
errorbar([1:size(LAME,2)],nanmean(LAME),nanstd(LAME)./(sqrt(size(LAME,1))))
xticklabels(modellabels)
ylabel('Model evidence (LAME)')
xtickangle(45)

% plot(squeeze(100*outBMC.families.pxp),'-o',...
%     'Color',.7*[1,1,1],...
%     'MarkerFaceColor',.7*[1,1,1],...
%     'MarkerEdgeColor',[1,1,1])

errorbar(100*outBMC.families.Ef,100*sqrt(outBMC.families.Vf),'d',...
    'Color',.5*[1,1,1],...
    'MarkerFaceColor',.7*[1,1,1],...
    'MarkerEdgeColor',.5*[1,1,1],...
    'LineStyle','None')
plot([-1,numel(outBMC.families.Ef)+1],100*[1./numel(outBMC.families.Ef),1./numel(outBMC.families.Ef)],'r--');
plot([-1,size(outBMC.families.Ef,1)+1],100*[0.95,0.95],'b--')

set(gca,'YLim', [0 100],...
    'XTick',1:numel(outBMC.families.Ef),...
    'XTickLabels',famNames,...
    'XLim',[0 size(outBMC.families.Ef,1)+1],...
    'FontName','Arial')
xtickangle(90)

hL = legend('Exceedence P.','Expected F.');
hY = ylabel('probability');
set([hY,hL],'FontName','Arial')
set(hL,'Location','Best')
legend boxoff

set(gcf,'Position',[0,0,350,400])


%% optimistic mean, sd, both?
dum = LAME(:,[2,4:6,8:10]); 
options.families = {[1,2,5],[3,6],[4,7]};
[postBMCconf,outBMCconf] = VBA_groupBMC(-dum(:,:)'/2,options) %% mean (ep = .99)

% unbiased vs optimistic each cat
options.families = {[1,3,7],[2,4,8],[5,9],[6,10]}
[postBMC,outBMC]  = VBA_groupBMC(-LAME(:,:)'/2,options); %%% unbiased (ep = .95)
