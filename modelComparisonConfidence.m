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

%% get model variables (probability of choosing 2) per condition
for imodel  = 1:numel(parameters)
    for isub = 1:size(Choices,2)
        paramstruct = modelsinfo{imodel};
            for iparam = 1:numel(modelsinfo{imodel}.paramnames)
                paramstruct.(modelsinfo{imodel}.paramnames{iparam}) = parameters{imodel}(isub,iparam);
            end
       [Q,V,p2,PE,p] = Computational_TimeSeries_QLearner(paramstruct,Choices(:,isub),Reward(:,isub));    
        p2_all(imodel,isub,:) = p2;
        Q_all(imodel,isub,:,:)= Q;
        V_all(imodel,isub,:,:)= V;
        PE_all(imodel,isub,:,:)= PE;
        p_all(imodel,isub,:) = p;
    end  
end

Qdiff_all = squeeze(Q_all(:,:,2,1:240)-Q_all(:,:,1,1:240));
corrchoice = double(sign(ChoicesOrig) == sign(Pr-Pl));
corrchoice(Pr == Pl) = NaN;

c2 = nanmean(Choices==2,2); %proportion of choosing door2
myQ = squeeze(mean(Q_all,2)); %mean q values 
seQ = squeeze(std(Q_all,[],2))./sqrt(size(Choices,2)); %mean q values 
seQdiff = squeeze((myQ(:,2,:)-myQ(:,1,:))./sqrt(size(Choices,2))); %mean q values 

mpc2 = squeeze(mean(p2_all,2)); %probability of choosing door 2
sepc2 = squeeze(std(p2_all,[],2))./sqrt(size(Choices,2)); %probability of choosing door 2


%% analyze 4 conditions described in paper

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
                pc2 = squeeze(p2_all(imodel, isub,sel));
                pcorr = squeeze(pc2.*(Pr(sel,isub)>Pl(sel,isub))+(1.-pc2).*(Pr(sel,isub)<Pl(sel,isub)));
                model_pc_cond(imodel,ivb,ivg,isub,:) = pcorr ;
                Qdiff_cond(imodel,ivb,ivg,isub,:) = Qdiff_all(imodel,isub,sel);
                p_cond(imodel,ivb,ivg,isub,:) = p_all(imodel,isub,sel);
                if imodel<3
                    modelconf(imodel,ivb,ivg,isub,:)= abs(Qdiff_all(imodel,isub,sel));
                elseif imodel >=3 && imodel<6
                     modelconf(imodel,ivb,ivg,isub,:)  = abs(p_all(imodel,isub,sel)-(1-p_all(imodel,isub,sel)));
                end
                
                Q1_cond(imodel,ivb,ivg,isub,:) = Q_all(imodel,isub,1,sel);
                Q2_cond(imodel,ivb,ivg,isub,:) = Q_all(imodel,isub,2,sel);
                
                 confAllConds = squeeze(conf_cond(:,:,isub,:));
                 pcAllConds = squeeze(model_pc_cond(imodel,:,:,isub,:));
                 modelConfAll = squeeze(modelconf(imodel,:,:,isub,:));
                 pAllConds = squeeze(p_cond(imodel,:,:,isub,:));
                 Q1AllConds = Q1_cond(imodel,:,:,isub,:);
                 Q2AllConds = Q2_cond(imodel,:,:,isub,:);
                 QGood =  max(Q2AllConds(:),Q1AllConds(:));
                 QBad =  min(Q2AllConds(:),Q1AllConds(:));
                 
                if ivb == 2 && ivg ==2
%                     varnames= {'confidence', 'modelpcorr','QGood','QBad'}
%                     tbl = table(confAllConds(:),pcAllConds(:),QGood,QBad,'VariableNames', varnames);  
                    varnames = {'confidence','modelconf'}
                    tbl = table(confAllConds(:),modelConfAll(:),'VariableNames', varnames);  

                    regThisSub = fitlm(tbl,'confidence ~ 1+modelconf');
                    BIC(isub, imodel) =   regThisSub.ModelCriterion.BIC;
                    coeffs(isub,imodel,:) = regThisSub.Coefficients.Estimate;
                    conft(isub,imodel,:) = regThisSub.Coefficients.tStat;

                    RMSE(isub,imodel,:) = regThisSub.RMSE;
                end
            end
        end
    end
end



[deselr,c] = find(isinf(BIC));%

selr = 1:size(BIC,1);
selr(deselr) = [];
BIC = BIC(selr,:); 

save('Results\model_fit_conf.mat', 'BIC', 'coeffs', 'conft', 'RMSE')

%% model comparison between ALL models
[postBMCconf,outBMCconf] = VBA_groupBMC(-BIC'/2)

figure()
bar(outBMCconf.Ef);
xticklabels(modellabels)
xtickangle(40)
hold on
ylabel('model frequencies')
plot([0,9],[1/8,1/8],'k:')
set(gca,'FontSize', 14)

% %% model comparison between families ([1 2] vs [3 4 5] vs [6 7 8])
% options.families = {[1,2],[3:5],[6:8]};
% [postBMCconf,outBMCconf] = VBA_groupBMC(-BIC'/2,options)
