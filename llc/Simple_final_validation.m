load 'C:\Projeto Final\Results\DTW\Training Matrix\proeminence_10.mat'

test_matrix = Train_feature_mat(61:80,:);
validation_matrix = Train_labels(61:80);

prediction = trainedModel7.predictFcn(test_matrix);

comp = [validation_matrix prediction];

tp = numel(find(comp(:, 1) == 1 & comp(:, 2) == 1));

fn = numel(find(comp(:, 1) == 1 & comp(:, 2) == 0));

fp = numel(find(comp(:, 1) == 1 & comp(:, 2) == 0));