% Script to evaluate the classifier
% clear all;
annotation_file = 'C:/Projeto Final/Dataset/Gururani/annotation.csv';
suspect_dir = 'C:/Projeto Final/Dataset/Gururani/Copied/';
sample_dir = 'C:/Projeto Final/Dataset/Gururani/Originals/';
time_dir = 'C:/Projeto Final/Dataset/Gururani/time_annotations/';

annotation = csvread(annotation_file);
load 'C:/Projeto Final/Results/DTW/Costs_locs/Proeminence/proeminence_0.mat'


tp = 0;
fp = 0;
fn = 0;
tn = 0;

quant_starts = 0;
quant_paths = 0;
tic

for i = 1:80
   if(annotation(i,2) < 10)
       filenum2 = ['0',num2str(annotation(i,2))];
   else
       filenum2 = num2str(annotation(i,2));
   end
   if(annotation(i,6) < 10)
       time_file = ['0',num2str(annotation(i,6))];
   else
       time_file = num2str(annotation(i,6));
   end
   [~,fs1] = audioread([sample_dir, filenum1,'.mp3'], [1,2]);
   sample = audioread([sample_dir, filenum1,'.mp3'],[ceil(fs1*annotation(i,3)) ceil(fs1*annotation(i,4))]);
   b = find(sample~=0);
   sample = sample(b(1):end,:);
   sample_size = size(sample, 1)/1024;
   if (fs1==22050)
       sample_size = sample_size*2;
   end
   
   [suspect, fs2] = audioread([suspect_dir, filenum2,'.mp3']);
   a = find(suspect~=0);
    
   time_offset = a(1)/44100;
   time_data = importdata([time_dir, time_file, '.csv']);
   for j = 1:numel(time_data)
       time_data{j} = strrep(time_data{j},',New Point','');
   end
   time_data = str2double(time_data);
   time_data = time_data - time_offset;
   
%     path_start = [];
%     for p = 1:size(paths{i},2)
%        path_start(p) = paths{i}{p}(2,2);
%     end
%     quant_paths = quant_paths + size(path_start,2);
%     locs_diff = diff([0, path_start]);
%     steps = path_start(locs_diff~=0);
%     steps = [steps, numel(path_start)];
%     starts = [];
%     if (steps(1,1)>0)
%         starts = path_start(steps);
%     end
%     quant_starts = quant_starts + size(starts,2);
   [~, locs_in_step] = featureExtract_Lucas3(costs{i},locs{i}, paths{i}, sample_size);

    locations_in_time = locs_in_step * 1024/44100;

   for j = 1:numel(time_data)
       index = find(abs(locations_in_time - time_data(j)) <= 1.0);
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


precision = tp/(tp+fp)
recall = tp/(tp+fn)
f_measure = 2*precision*recall/(precision+recall)

toc
% save ('C:\Projeto Final\Results\DTW\Before Classification\complete_duration_proeminence_10.mat', 'precision', 'recall', 'f_measure', 'tp', 'fp', 'fn')