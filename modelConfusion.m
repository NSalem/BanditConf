function modelConfusion(filename,whichmodels,doSave)
    %%% filename: path to file containing results of simulations (default
    %%% 'Results\model_simulations_results_exp1.mat')
    %%% whichmodels: vector of models to test (default all)
    %%% doSave: bool, whether to save the plot (default no)
    if nargin<3
        doSave = 0;
    end
    if nargin<1 || isempty(filename)
        filename = 'Results\model_simulations_results_exp1.mat';
    end
    
    load(filename);
    
    if nargin<2||isempty(whichmodels)
        whichmodels = 1:numel(modelsinfo);
    end

    options = struct();
    options.DisplayWin =0;
    confusionMat = zeros(numel(whichmodels),numel(whichmodels));

    criterion = bic;
    [selr,~] = find(criterion~=0);%
    criterion = criterion(unique(selr),:,:,:);
    for isim = 1:size(criterion,1)
        for igenmodel = 1:numel(whichmodels)
            genmodel = whichmodels(igenmodel);
            [post, out] = VBA_groupBMC(squeeze(-criterion(isim,:,genmodel,whichmodels))'/2,options);
            [~,winningmodel] = max(out.pxp);
            confusionMat(igenmodel,winningmodel) = confusionMat(igenmodel,winningmodel)+1;
        end
    end

    allabels= {'Q1','Q2','Q1V1','Q2V1','Q1V2','Q1V1-T','Q2V1-T','Q1V2-T'}
    modelnames = {allabels{whichmodels}};
    
    figure()
    imagesc(confusionMat/size(criterion,1)*100);
    colormap(1-gray);
    c = colorbar;
    xticks(1:numel(whichmodels));yticks(1:numel(whichmodels))
    xticklabels(modelnames);yticklabels(modelnames)
    xtickangle(45)
    c.Label.String = '% best fit'
    set(gca,'FontSize', 14)
    xlabel("Recovered model", 'FontSize', 14);
    ylabel("Generative model", 'FontSize', 14);
    caxis([0,100])
    
    if doSave
            saveas(gcf,['Plots\model_confusion.png'])
    end
end