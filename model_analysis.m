addpath('ModelingFuncs\')
load('model_fits');
LoadExp1;
ChoicesOrig = Choices;
Choices = Choices + 2;
Choices(Choices==3) = 2;

%% get model accuracy and conf per condition
for imodel  = 1:size(parameters, 2)
    for isub = 1:size(Choices,2)
        paramstruct = modelsinfo{imodel};
            for iparam = 1:numel(modelsinfo{imodel}.paramnames)
                paramstruct.(modelsinfo{imodel}.paramnames{iparam}) = parameters{isub,imodel}(iparam);
            end
       [Q,V,pc,PE] = Computational_TimeSeries_QLearner(paramstruct,ones(240,isub),Choices(:,isub),Reward(:,isub));    
        pc_all(imodel,isub,:) = pc;
        Q_all(imodel,isub,:,:,:)= Q;
        V_all(imodel,isub,:,:,:)= V;
        PE_all(imodel,isub,:,:,:)= PE;

    end  
end

Qdiff_all = squeeze(Q_all(:,:,:,2,1:240)-Q_all(:,:,:,1,1:240));
corr = double(sign(ChoicesOrig) == sign(Pr-Pl));
corr(Pr == Pl) = NaN;

c2 = nanmean(Choices==2,2); %proportion of choosing door2
myQ = squeeze(mean(Q_all,2)); %mean q values 
seQ = squeeze(std(Q_all,[],2))./sqrt(size(Choices,2)); %mean q values 
seQdiff = squeeze((myQ(:,2,:)-myQ(:,1,:))./sqrt(size(Choices,2))); %mean q values 

mpc2 = squeeze(mean(pc_all,2)); %probability of choosing door 2
sepc2 = squeeze(std(pc_all,[],2))./sqrt(size(Choices,2)); %probability of choosing door 2


Pdiff = repmat((Pr'-Pl'),1,1,4);
Pdiff = permute(Pdiff,[3,1,2]);
QdiffM = Qdiff_all-Pdiff;


%% plot average difference between Q-value difference and mean difference accross time


modelcolors = [.5,.5,.5;
1,0,0;
0,0,1;
1,0,1];

modelcolors = [
    127,127,127;
202,0,32;
5,113,176;
94,60,153]/255;

figure()
% plot(mean(Pr'-Pl'),'k')
hold on
for imodel = 1:size(myQ,1)
    s = shadedErrorBar([1:240],squeeze(mean(QdiffM(imodel,:,:),2)),squeeze(std(QdiffM(imodel,:,:),[],2)./sqrt(size(Choices,2))))
    s.mainLine.Color = modelcolors(imodel,:);
    s.edge.delete;
    s.patch.FaceColor = modelcolors(imodel,:);
    s.patch.FaceAlpha = 0.6;
end

% %% plot probability of choosing door 2 
modellabels = {'1 \alpha_Q, 1 \alpha_V','2 \alpha_Q, 1 \alpha_V','1 \alpha_Q, 2 \alpha_V','2 \alpha_Q, 2 \alpha_V'};
legend(modellabels)
xlabel('Trial number')
ylabel('(Q_2-Q_1) - (\mu_2-\mu_1)')
% figure()
% plot(c2,'k')
% hold on
% 
% for imodel = 1:size(mpc2,1)
%     s = shadedErrorBar([1:240],mpc2(imodel,:),sepc2(imodel,:))
%     s.mainLine.Color = modelcolors(imodel,:);
%     s.edge.delete;
%     s.patch.FaceColor = modelcolors(imodel,:);
%     s.patch.FaceAlpha = 0.6;
% end
% 
% % plot(mpc2')
% legend({'data','1 \alpha_Q, 1 \alpha_V','2 \alpha_Q, 1 \alpha_V','1 \alpha_Q, 2 \alpha_V','2 \alpha_Q, 2 \alpha_V'})



%% analyze only 4 conditions described in paper

vars = [10,25];

c_cond = NaN(numel(vars),numel(vars),size(Choices,2),25);

for ivb = 1:numel(vars)
    for ivg = 1:numel(vars)
        for isub = 1:size(Choices,2)
            idg = (Pr(:,isub) ==65 & Vr(:,isub) ==vars(ivg) | (Pl(:,isub) == 65 & Vl(:,isub) == vars(ivg)));
            idb = (Pr(:,isub) == 35 & Vr(:,isub) ==vars(ivb) | (Pl(:,isub) == 35 & Vl(:,isub) == vars(ivb)));
            sel = find(idg & idb);
            sel = sel(1:25);
            
            ChoicesSubCond = Choices((sel),isub);
            ConfSubCond = AbsConf((sel),isub);
            c_cond(ivb,ivg,isub,1:25) =ChoicesSubCond;

            correct = (ChoicesSubCond == 2 & Pr(sel,isub)>Pl(sel,isub))|(ChoicesSubCond == 1 & Pr(sel,isub)<Pl(sel,isub));
            corr_cond(ivb,ivg,isub,1:25) = correct;
            conf_cond(ivb,ivg,isub,1:25) =ConfSubCond;


            for imodel = 1:4
                pc2 = squeeze(pc_all(imodel, isub,sel));
                pcorr = squeeze(pc2.*(Pr(sel,isub)>Pl(sel,isub))+(1.-pc2).*(Pr(sel,isub)<Pl(sel,isub)));
                model_pc_cond(imodel,ivb,ivg,isub,:) = pcorr ;
                
                if ivb == 2 && ivg ==2
                    varnames= {'confidence', 'modelpcorr'}
                    tbl = table(ConfSubCond/6,pcorr,'VariableNames', varnames);  
                    regThisSub = fitlm(tbl,'confidence ~ 1+modelpcorr');
                    BIC(isub, imodel) =   regThisSub.ModelCriterion.BIC;
                    coeffs(isub,imodel,:) = regThisSub.Coefficients.Estimate;
                    RMSE(isub,imodel,:) = regThisSub.RMSE;
                end
            end
        end
    end
end

[selr,c] = find(~isinf(BIC));%
BIC = BIC(selr,:); 
corrmean = squeeze(mean(corr_cond,3));
corrse = squeeze(std(corr_cond,[],3)/sqrt(size(corr_cond,3)));
pcmean  =squeeze(mean(model_pc_cond,4));
pcse = squeeze(std(model_pc_cond,[],4)/sqrt(size(model_pc_cond,4)));


%% plot timecourse per condition 

figure()
i = 0;
for ivb = 1:2
    for ivg = 1:2
        i= i+1;
        subplot(2,2,i)
%         shadedErrorBar([1:25],squeeze(corrmean(ivb,ivg,:)),squeeze(corrse(ivb,ivg,:)));
        errorbar([1:25],squeeze(corrmean(ivb,ivg,:)),squeeze(corrse(ivb,ivg,:)),':k');
        ylim([.4,1])
        for imodel = 1:4
            s = shadedErrorBar([1:25],squeeze(pcmean(imodel,ivb,ivg,:)),squeeze(pcse(imodel,ivb,ivg,:)));
            s.mainLine.Color = modelcolors(imodel,:);
            s.mainLine.LineWidth = 3;
            s.edge.delete;
            s.patch.FaceColor = modelcolors(imodel,:);
            s.patch.FaceAlpha = 0.6;
            s.patch.EdgeColor = modelcolors(imodel,:);
            s.patch.EdgeAlpha = 1;
%             s.edge.Color
        end
        xlabel('Trial')
        ylabel('p correct')
    end
end

legend({'data',modellabels{:}})


condcolors = [6  95  37; 
        143 202 51;
        155 136 21;
        240 213 49]/255;
 condcolors = condcolors(end:-1:1,:);

% corrcond_m = mean(mean(corr_cond,4),3);
% corrcond_se = std(mean(corr_cond,4),[],3)./sqrt(size(corr_cond,3));


%% plot avg accuracy per condition
mcorrcon = squeeze(mean(corr_cond,4));
mcorrcon = reshape(mcorrcon,4,65);

mmodelpccon = mean(model_pc_cond,5);
mmodelpccon = reshape(mmodelpccon,4,4,65);
modelmean = squeeze(mean(mmodelpccon,3));
modelse = squeeze(std(mmodelpccon,[],3))/sqrt(size(mmodelpccon,3));
% std(pcmean,[]/4)/sqrt(size;

figure()
% errorbar(corrcond_m(:),corrcond_se(:))

pirateplot(mcorrcon,repmat(condcolors,4,1),0.,1.1,12,'','Condition','p correct')
hold on
plot([0,5],[.5,.5],':k')
xticklabels({'vLvL','vLvH','vHvL','vHvH'})
for imodel = 1:4
    for ibar = 1:4
        y(imodel) = errorbar(ibar-(4-imodel)*0.1,modelmean(imodel,ibar),modelse(imodel,ibar),['k',modelmarkers{imodel}],'MarkerFaceColor', modelcolors(imodel,:))
    end
end
legend(y,modellabels, 'Location', 'southeastoutside')
% hold on
% shadedErrorBar([1:240],squeeze(Q(1,2,1:240)),sqrt(squeeze(V(1,2,1:240))))


%% plot avg conf per condition 
mconfcon = squeeze(mean(conf_cond,4));
mconfcon = reshape(mconfcon,4,65);

mmodelpccon = mean(model_pc_cond,5);
mmodelpccon = reshape(mmodelpccon,4,4,65);
modelmean = squeeze(mean(mmodelpccon,3));
modelse = squeeze(std(mmodelpccon,[],3))/sqrt(size(mmodelpccon,3));
% std(pcmean,[]/4)/sqrt(size;

% errorbar(corrcond_m(:),corrcond_se(:))

 %% plot confidence accross conditions
 modelmarkers = {'x','d','s','o'}
figure()
pirateplot(mconfcon,repmat(condcolors,4,1),1,6,12,'','Condition','p correct')
xticklabels({'vLvL','vLvH','vHvL','vHvH'})
hold on
% plot([0,5],[.5,.5],':k')
for imodel = 1:4
    for ibar = 1:4
        y(imodel) = errorbar(ibar-(4-imodel)*0.1,modelmean(imodel,ibar)*6,modelse(imodel,ibar)*6,['k',modelmarkers{imodel}],'MarkerFaceColor', modelcolors(imodel,:))
    end
end
legend(y,modellabels, 'Location', 'southeastoutside')

%% plot calibration
figure()
pirateplot(mconfcon/6-mcorrcon,repmat(condcolors,4,1),-.5,.5,12,'','Condition','Confidence-Accuracy')
hold on
plot([0,5],[0,0],':k')
xticklabels({'vLvL','vLvH','vHvL','vHvH'})
