 
%  load('Results\model_sims_subjparams.mat')
 
load('Results\model_fits_patterns.mat')
load('Results\model_fit_conf2.mat')

trlsel = [1:25];
%% plot avg accuracy per condition
%     modelmarkers = {'^','^','d','d','d','o','o','o'}
    mcorrcon = squeeze(mean(corr_cond(:,:,:,trlsel),4));
    mcorrcon = reshape(mcorrcon,4,65);
    mcorrconmean = mean(mcorrcon,2);
    mcorrconse = squeeze(std(mcorrcon,[],2))/sqrt(size(mcorrcon,2));
    
    mmodelpccon = mean(model_pc_cond(:,:,:,:,1:25),5);
    mmodelpccon = reshape(mmodelpccon,whichmodels(end),4,size(mmodelpccon,4));
    modelmean = squeeze(mean(mmodelpccon,3));
    modelse = squeeze(std(mmodelpccon,[],3))/sqrt(size(mmodelpccon,3));
    % std(pcmean,[]/4)/sqrt(size;

    figure()
    plotfilename = 'resim_accuracy_cond'
%     pirateplot(mcorrcon,repmat(condcolors,4,1),0.,1,12,'','Condition','p correct')
    % plot(mcorrcon,'Color',[.8,.8,.8]);
    plot([0,5],[.5,.5],':k')
    for imodel = whichmodels
        subplot(2,4,imodel)
            hold on
            title(modellabels(imodel));
            errorbar(mcorrconmean(4:-1:1),mcorrconse(4:-1:1),['ko'],'MarkerFaceColor', [.5,.5,.5])
            errorbar(modelmean(imodel,4:-1:1),modelse(imodel,4:-1:1),'ko','MarkerFaceColor', modelcolors(imodel,:))
            ylabel('Accuracy')
            xlim([0,5])
            xticks([1:4]);
%             xticklabels({'vLvL','vHvL','vLvH','vHvH'})
            xticklabels({'vHvH','vLvH','vHvL','vLvL'})

    end
%     legend(y(whichmodels),modellabels, 'Location', 'southeastoutside')
    % hold on
    % shadedErrorBar([1:240],squeeze(Q(1,2,1:240)),sqrt(squeeze(V(1,2,1:240))))
%     saveas(gcf,['Plots\',plotfilename,modelsStr,'.png'])

    %% plot avg conf per condition 
    mconfcon = squeeze(mean(conf_cond,4));
%     mconfcon = (mconfcon-1)/10+.5;
    mconfcon = reshape(mconfcon,4,65);
    mconfconmean = mean(mconfcon,2);
    mconfconse = squeeze(std(mconfcon,[],2))/sqrt(size(mconfcon,2));
    
    modelconf = regFittedCond;
%     modelconf = model_pc_cond;
%     modelconf(modelconf<.5) = .5;
    modelconf = squeeze(mean(modelconf(:,:,:,:,1:25),5));
    modelconf = reshape(modelconf,size(modelconf,1),whichmodels(end),4);
%     modelconf = (modelconf-.5)*10+1
    modelmeanconf = squeeze(mean(modelconf,1));
    modelseconf = squeeze(std(modelconf,[],1))/sqrt(size(modelconf,1));

    % std(pcmean,[]/4)/sqrt(size;

    % errorbar(corrcond_m(:),corrcond_se(:))

     %% plot confidence accross conditions
    figure()
    plotfilename = 'resim_confidence_cond'
    for imodel = whichmodels
        subplot(2,4,imodel)
            hold on
            title(modellabels(imodel));
            errorbar(mconfconmean(4:-1:1),mconfconse(4:-1:1),'ko','MarkerFaceColor', [.5,.5,.5])
            errorbar((modelmeanconf(imodel,4:-1:1)),modelseconf(imodel,4:-1:1),'ko','MarkerFaceColor', modelcolors(imodel,:))
            ylabel('Confidence')
        xlim([0,5])
        xticks([1:4]);
        xticklabels({'vHvH','vLvH','vHvL','vLvL'})
    end
%     saveas(gcf,['Plots\',plotfilename,modelsStr,'.png'])

    % %% plot calibration
    % figure()
    % pirateplot(mconfcon/6-mcorrcon,repmat(condcolors,4,1),-.5,.5,12,'','Condition','Confidence-Accuracy')
    % hold on
    % plot([0,5],[0,0],':k')
    % xticklabels({'vLvL','vLvH','vHvL','vHvH'})