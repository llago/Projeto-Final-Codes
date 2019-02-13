% Script to help label the data
% clear all;
annotation_file = 'C:/Projeto Final/Dataset/Gururani/annotation.csv';
suspect_dir = 'C:/Projeto Final/Dataset/Gururani/Copied/';
sample_dir = 'C:/Projeto Final/Dataset/Gururani/Originals/';
time_dir = 'C:/Projeto Final/Dataset/Gururani/time_annotations/';

annotation = csvread(annotation_file);
% load 'C:/Projeto Final/Results/DTW/Costs_locs/Proeminence/proeminence_0.mat'
% load 'C:/Projeto Final/Results/DTW/Costs_locs/all_points_last_row.mat'

tolerance = 1.0;
%figure; hold on;
%costs = cell(1,80);
%locs = cell(1,80);
%labels = cell(1,40);
for i = 1:60
   if(annotation(i,1) < 10)
       filenum1 = ['0',num2str(annotation(i,1))];
   else
       filenum1 = num2str(annotation(i,1));
   end
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
   [suspect, fs2] = audioread([suspect_dir, filenum2,'.mp3']);
   a = find(suspect~=0);
   
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

   path_begins = [];
   path_ends = [];

   [mat, locs_in_step] = featureExtract_Lucas3(costs{i},locs{i}, paths{i}, sample_size);
   locs_seconds = locs_in_step(1,:) * 1024/44100;
   
   l = zeros(1, numel(locs_seconds));

   not_found = [];
   ind = [];
   count1 = 1;
   count2 = 1;
   for j = 1:numel(time_data)
       index = find(abs(locs_seconds - time_data(j)) <= tolerance);
       if(numel(index)==0)
           not_found(count1) = time_data(j);
           count1 = count1+1;
       elseif(numel(index) == 1)
           ind(count2) = index;
           count2 = count2+1;
       else
           c = mat(1, index);
           [~,min_c] = min(c);
           ind(count2) = index(min_c);
           count2 = count2+1;
       end
   end
   
   l(ind) = 1;
   
   ind_cell{i} = ind;
   not_found_cell{i} = not_found;
   labels_all{i}=l;
end
% save('C:\Projeto Final\Results\DTW\Labels\proeminence0_feat3b.mat', 'labels_all', 'ind_cell', 'not_found_cell')