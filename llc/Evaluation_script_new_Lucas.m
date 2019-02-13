% Script to evaluate the classifier
annotation_file = 'C:/Projeto Final/Dataset/Gururani/annotation.csv';
suspect_dir = 'C:/Projeto Final/Dataset/Gururani/Copied/';
sample_dir = 'C:/Projeto Final/Dataset/Gururani/Originals/';
time_dir = 'C:/Projeto Final/Dataset/Gururani/time_annotations/';

annotation = csvread(annotation_file);
% load 'C:/Projeto Final/Results/DTW/Training Matrix/complete_duration_proeminence_10_teste_features.mat'
% load 'C:\Projeto Final\Results\DTW\Costs_locs\Proeminence\proeminence_0.mat'

%figure; hold on;
%costs = cell(1,80);
%locs = cell(1,80);
%labels = cell(1,40);
tp = 0;
fp = 0;
fn = 0;
tn = 0;

% generateTrainingMatrix();

tic
% % ens = trainEnsemble(Train_feature_mat(:,1:4), Train_labels);
% ens = trainEnsemble(Train_feature_mat, Train_labels);
%    z = lsqlin(Train_feature_mat, Train_labels);

tolerance = 1.0;
for i = 61:80
   if(annotation(i,2) < 10)
       filenum2 = ['0',num2str(annotation(i,2))];
   else
       filenum2 = num2str(annotation(i,2));
   end
   if(annotation(i,1) < 10)
       filenum1 = ['0',num2str(annotation(i,1))];
   else
       filenum1 = num2str(annotation(i,1));
   end
   if(annotation(i,6) < 10)
       time_file = ['0',num2str(annotation(i,6))];
   else
       time_file = num2str(annotation(i,6));
   end
   [suspect, fs2] = audioread([suspect_dir, filenum2,'.mp3']);
   a = find(suspect~=0);
   suspect = suspect(a(1):end,:);
   
   
   [~,fs1] = audioread([sample_dir, filenum1,'.mp3'], [1,2]);
   sample = audioread([sample_dir, filenum1,'.mp3'],[ceil(fs1*annotation(i,3)) ceil(fs1*annotation(i,4))]);
   b = find(sample~=0);
   sample = sample(b(1):end,:);
   sample_size = size(sample, 1)/1024;
   if (fs1==22050)
       sample_size = sample_size*2;
   end
%    [conf, locs{i}, costs{i}] = pitch_and_time(sample, suspect,annotation(i,1), annotation(i,2), annotation(i,5), fs1, fs2);
   time_offset = a(1)/fs2;
   time_data = importdata([time_dir, time_file, '.csv']);
   for j = 1:numel(time_data)
       time_data{j} = strrep(time_data{j},',New Point','');
   end
   time_data = str2double(time_data);
   time_data = time_data - time_offset;
   
%    fmat = featureExtract_Lucas(costs{i}, paths{i});   
%    for p = 1:size(paths{i},2)
%        path_begins(p) = paths{i}{p}(2,2);
%    end
%    locs_seconds = path_begins * 1024/44100;   

   [fmat, locs_in_step] = featureExtract_Lucas3(costs{i},locs{i}, paths{i}, sample_size);
   locs_seconds = locs_in_step(1,:) * 1024/44100;

   l = trainedModel1.predictFcn(fmat');
   ind = find(l);
   locations_in_time = locs_seconds(ind);

   for j = 1:numel(time_data)
       index = find(abs(locations_in_time - time_data(j)) <= tolerance);
       if(numel(index) == 0)
           fn = fn + 1;
       elseif(numel(index) == 1)
           tp = tp + 1;
           locations_in_time(index) = [];
       else
           close = locations_in_time(index);
           difference = abs(locations_in_time - time_data(j));
           [~,min_idx] = min(difference);
           locations_in_time(min_idx) = [];
           tp = tp + 1;
       end
   end
   fp = fp + numel(locations_in_time);
end
toc
precision = tp/(tp+fp)
recall = tp/(tp+fn)
f_measure = 2*precision*recall/(precision+recall)

% save ('C:\Projeto Final\Results\DTW\Final Result\complete_duration_proeminence_10_ate_63_20_pares.mat', 'precision', 'recall', 'f_measure', 'tp', 'fp', 'fn')
