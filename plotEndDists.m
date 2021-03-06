load('Results\model_fit_conf3.mat');
figure()
ip = 0;
vars = [10,25];
nmodel = 4;
trlsel = 20:25;
for ivb =1:2
    for ivg = 1:2
       ip = ip+1; 
       subplot(2,2,ip);
       hold on
       x = [-50:150];
       muGood = squeeze(nanmean(nanmean(Qgood(nmodel,ivb,ivg,:,trlsel),4),5));
       muBad = squeeze(nanmean(nanmean(Qbad(nmodel,ivb,ivg,:,trlsel),4),5));
       sigmaGood = sqrt(squeeze(nanmean(nanmean(Vgood(nmodel,ivb,ivg,:,trlsel),4),5)));
       sigmaBad = sqrt(squeeze(nanmean(nanmean(Vbad(nmodel,ivb,ivg,:,trlsel),4),5)));
       
       muRealGood = 65;
       muRealBad = 35;
       sigmaRealGood = vars(ivg);
       sigmaRealBad = vars(ivb);
       plot(x,normpdf(x,65,vars(ivg)),'k--');
       plot(x,normpdf(x,35,vars(ivb)),'k--');
       plot(x,normpdf(x,muGood,sigmaGood));
       plot(x,normpdf(x,muBad,sigmaBad))
       xlim([-50,150])
       dPrime = (muGood-muBad)./sqrt((sigmaBad^2+sigmaGood^2)./2);
       dPrimeReal = (muRealGood-muRealBad)./sqrt((sigmaRealBad^2+sigmaRealGood^2)./2);
       ylim([0,.1])
       xlabel('R','Interpreter','latex')
       set(gca,'FontSize',12)
       text(0 ,0.90,[sprintf('d'' = %0.2f  ',dPrime),sprintf('d''_{Theoretic} = %0.2f',dPrimeReal)],'Units','normalized')
        dPrimeAll(ivb,ivg) = dPrime;
        dPrimeRealAll(ivb,ivg) = dPrimeReal;
    end
end
figure()
plot(dPrimeAll(:))
hold on
% plot(dPrimeRealAll(:))
