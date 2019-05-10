addpath('ModelingFuncs\')
addpath('helperfuncs');
% load('Results\model_fitsMLE_exp1.mat');
load('Results\model_fitsMAP_exp1.mat');

loadExp1;
ChoicesOrig = Choices;
Choices = Choices + 2;
Choices(Choices==3) = 2;

whichmodels = 1:numel(parameters);
nmodels = numel(whichmodels);

allabels= {'Q1','Q2','Q1V1','Q2V1','Q1V2','Q1V1-T','Q2V1-T','Q1V2-T'}
modellabels = {allabels{whichmodels}};
%% get model accuracy and conf per condition
for imodel  = 1:numel(parameters)
    for isub = 1:size(Choices,2)
        paramstruct = modelsinfo{imodel};
            for iparam = 1:numel(modelsinfo{imodel}.paramnames)
                paramstruct.(modelsinfo{imodel}.paramnames{iparam}) = parameters{imodel}(isub,iparam);
            end
       [Q,V,pc,PE] = Computational_TimeSeries_QLearner(paramstruct,Choices(:,isub),Reward(:,isub));    
        pc_all(imodel,isub,:) = pc;
        Q_all(imodel,isub,:,:)= Q;
        V_all(imodel,isub,:,:)= V;
        PE_all(imodel,isub,:,:)= PE;

    end  
end

Qdiff_all = squeeze(Q_all(:,:,2,1:240)-Q_all(:,:,1,1:240));
corrchoice = double(sign(ChoicesOrig) == sign(Pr-Pl));
corrchoice(Pr == Pl) = NaN;

c2 = nanmean(Choices==2,2); %proportion of choosing door2
myQ = squeeze(mean(Q_all,2)); %mean q values 
seQ = squeeze(std(Q_all,[],2))./sqrt(size(Choices,2)); %mean q values 
seQdiff = squeeze((myQ(:,2,:)-myQ(:,1,:))./sqrt(size(Choices,2))); %mean q values 

mpc2 = squeeze(mean(pc_all,2)); %probability of choosing door 2
sepc2 = squeeze(std(pc_all,[],2))./sqrt(size(Choices,2)); %probability of choosing door 2

%% plot average difference between Q-value difference and mean difference accross time

modelcolors = [
141,211,199;
255,255,179;
190,186,218;
251,128,114;
128,177,211;
253,180,98;
179,222,105;
252,205,229;
217,217,217;
188,128,189;
]/255;


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


            for imodel = whichmodels
                pc2 = squeeze(pc_all(imodel, isub,sel));
                pcorr = squeeze(pc2.*(Pr(sel,isub)>Pl(sel,isub))+(1.-pc2).*(Pr(sel,isub)<Pl(sel,isub)));
                model_pc_cond(imodel,ivb,ivg,isub,:) = pcorr ;
                Qdiff_cond(imodel,ivb,ivg,isub,:) = Qdiff_all(imodel,isub,sel);
                Q1_cond(imodel,ivb,ivg,isub,:) = Q_all(imodel,isub,1,sel);
                Q2_cond(imodel,ivb,ivg,isub,:) = Q_all(imodel,isub,2,sel);
                
                 confAllConds = squeeze(conf_cond(:,:,isub,:));
                 pcAllConds = squeeze(model_pc_cond(imodel,:,:,isub,:));
                 Q1AllConds = Q1_cond(imodel,:,:,isub,:);
                 Q2AllConds = Q2_cond(imodel,:,:,isub,:);
                 QGood =  max(Q2AllConds(:),Q1AllConds(:));
                 QBad =  min(Q2AllConds(:),Q1AllConds(:));
                 
                if ivb == 2 && ivg ==2
                    varnames= {'confidence', 'modelpcorr','QGood','QBad'}
                    tbl = table(confAllConds(:),pcAllConds(:),QGood,QBad,'VariableNames', varnames);  
                    regThisSub = fitlm(tbl,'confidence ~ 1+modelpcorr');
                    BIC(isub, imodel) =   regThisSub.ModelCriterion.BIC;
                    coeffs(isub,imodel,:) = regThisSub.Coefficients.Estimate;
                    conft(isub,imodel,:) = regThisSub.Coefficients.tStat;

                    RMSE(isub,imodel,:) = regThisSub.RMSE;
                end
            end
        end
    end
end

[selr,c] = find(~isinf(BIC));%
BIC = BIC(selr,:); 
% measureMean = squeeze(mean(corr_cond,3));
% measureSe = squeeze(std(corr_cond,[],3)/sqrt(size(conf_cond,3)));
% confmean = squeeze(mean(corr_cond,3));
% confse = squeeze(std(corr_cond,[],3)/sqrt(size(conf_cond,3)));
pcmean  =squeeze(mean(model_pc_cond,4));
pcse = squeeze(std(model_pc_cond,[],4)/sqrt(size(model_pc_cond,4)));


%% plot timecourse per condition 

for imeasure = 1:2
    
    if imeasure ==1
        thisMeasure = corr_cond;
    else
        thisMeasure = (conf_cond-1)/10+.5;
    end

    measureMean = squeeze(mean(thisMeasure,3));
    measureSe = squeeze(std(thisMeasure,[],3)/sqrt(size(thisMeasure,3)));

    figure()
    i = 0;
    for ivb = 1:2
        for ivg = 1:2
            i= i+1;
            subplot(2,2,i)
    %         shadedErrorBar([1:25],squeeze(corrmean(ivb,ivg,:)),squeeze(corrse(ivb,ivg,:)));
            errorbar([1:25],squeeze(measureMean(ivb,ivg,:)),squeeze(measureSe(ivb,ivg,:)),':k');
            ylim([.4,1])
            for imodel = whichmodels
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

end
% corrcond_m = mean(mean(corr_cond,4),3);
% corrcond_se = std(mean(corr_cond,4),[],3)./sqrt(size(corr_cond,3));


%% plot avg accuracy per condition
modelmarkers = {'^','^','d','d','d','o','o','o'}
mcorrcon = squeeze(mean(corr_cond,4));
mcorrcon = reshape(mcorrcon,4,65);

mmodelpccon = mean(model_pc_cond,5);
mmodelpccon = reshape(mmodelpccon,nmodels,4,65);
modelmean = squeeze(mean(mmodelpccon,3));
modelse = squeeze(std(mmodelpccon,[],3))/sqrt(size(mmodelpccon,3));
% std(pcmean,[]/4)/sqrt(size;

figure()
% errorbar(corrcond_m(:),corrcond_se(:))

pirateplot(mcorrcon,repmat(condcolors,4,1),0.,1.1,12,'','Condition','p correct')
% plot(mcorrcon,'Color',[.8,.8,.8]);
hold on
plot([0,5],[.5,.5],':k')
xticklabels({'vLvL','vLvH','vHvL','vHvH'})
for imodel = whichmodels
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
mmodelpccon = reshape(mmodelpccon,nmodels,4,65);
modelmean = squeeze(mean(mmodelpccon,3));
modelse = squeeze(std(mmodelpccon,[],3))/sqrt(size(mmodelpccon,3));
% std(pcmean,[]/4)/sqrt(size;

% errorbar(corrcond_m(:),corrcond_se(:))

 %% plot confidence accross conditions
figure()
pirateplot(mconfcon,repmat(condcolors,4,1),1,6,12,'','Condition','Confidence')
xticklabels({'vLvL','vLvH','vHvL','vHvH'})
hold on
% plot([0,5],[.5,.5],':k')
for imodel = whichmodels
    for ibar = 1:4
        y(imodel) = errorbar(ibar-(4-imodel)*0.1,modelmean(imodel,ibar)*6,modelse(imodel,ibar)*6,['k',modelmarkers{imodel}],'MarkerFaceColor', modelcolors(imodel,:))
    end
end
legend(y,modellabels, 'Location', 'southeastoutside')

% %% plot calibration
% figure()
% pirateplot(mconfcon/6-mcorrcon,repmat(condcolors,4,1),-.5,.5,12,'','Condition','Confidence-Accuracy')
% hold on
% plot([0,5],[0,0],':k')
% xticklabels({'vLvL','vLvH','vHvL','vHvH'})
