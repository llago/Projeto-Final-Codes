annotation_file = 'C:/Projeto Final/Dataset/Gururani/annotation.csv';
suspect_dir = 'C:/Projeto Final/Dataset/Gururani/Copied/';
sample_dir = 'C:/Projeto Final/Dataset/Gururani/Originals/';
time_dir = 'C:/Projeto Final/Dataset/Gururani/time_annotations/';
annotation = csvread(annotation_file);

% load 'C:\Projeto Final\Results\DTW\Costs_locs\all_points_last_row.mat'
% load 'C:/Projeto Final/Results/DTW/Costs_locs/Proeminence/proeminence_0.mat'
% load 'C:/Projeto Final/Results/DTW/Labels/proeminence0_feat3.mat'

Train_feature_mat = [];
Train_labels = [];
for i = 1:60
    if(annotation(i,1) < 10)
       filenum1 = ['0',num2str(annotation(i,1))];
    else
       filenum1 = num2str(annotation(i,1));
    end

    [~,fs1] = audioread([sample_dir, filenum1,'.mp3'], [1,2]);
    sample = audioread([sample_dir, filenum1,'.mp3'],[ceil(fs1*annotation(i,3)) ceil(fs1*annotation(i,4))]);
    b = find(sample~=0);
    sample = sample(b(1):end,:);
    sample_size = size(sample, 1)/1024;
    if (fs1==22050)
       sample_size = sample_size*2;
    end

%     mat = featureExtract_Lucas(costs{i},paths{i});
    [mat, locations] = featureExtract_Lucas3(costs{i},locs{i}, paths{i}, sample_size);

    Train_feature_mat = [Train_feature_mat, mat];
    Train_labels = vertcat(Train_labels, labels_all{i}');
end

% Thin out the negative classes
ind = find(Train_labels == 0);
found = find(Train_labels == 1);
% index = randsample(ind, floor(numel(Train_labels)*0.5));
index = randsample(ind, floor((numel(ind)-numel(found))*0.5));
% 
% Train_labels(index) = [];
% Train_feature_mat(:,index) = [];

Train_feature_mat = Train_feature_mat';
training = [Train_feature_mat Train_labels];
% save ('C:\Projeto Final\Results\DTW\Training Matrix\proeminence_5.mat', 'Train_labels', 'Train_feature_mat')