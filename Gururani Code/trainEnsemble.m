function [ens] = trainEnsemble(features, labels)

% ens = fitensemble(features, labels,'AdaBoostM1', 50, 'Tree');
ens = fitensemble(features, labels,'LogitBoost', 500, 'Tree');
cval = crossval(ens, 'kfold', 10);
kfoldLoss(cval)
% rsLoss = resubLoss(ens,'Mode','Cumulative');
% plot(rsLoss);

end