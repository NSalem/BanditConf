
load('Results\model_simulations_results_exp1.mat')

whichmodels = [1:5]
options = struct();
confusion = zeros(numel(whichmodels),numel(whichmodels));

criterion = bic;
options.DisplayWin = 0;

for isim = 1:size(bic,1)
    for igenmodel = 1:numel(whichmodels)
        genmodel = whichmodels(igenmodel);
        [post, out] = VBA_groupBMC(squeeze(-criterion(isim,:,genmodel,whichmodels))'/2,options);
        [~,winningmodel] = max(out.pxp);
        confusion(igenmodel,winningmodel) = confusion(igenmodel,winningmodel)+1;
    end
end


figure()
imagesc(confusion/size(bic,1)*100);
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

saveas(gcf,['Plots\model_confusion.png'])