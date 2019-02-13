clear all;
tic

% Script to evaluate the classifier
annotation_file = 'C:\Projeto Final\Dataset\Gururani\annotation.csv';
suspect_dir = 'C:\Projeto Final\Dataset\Gururani\Copied\';
sample_dir = 'C:\Projeto Final\Dataset\Gururani\Originals\';
time_dir = 'C:\Projeto Final\Dataset\Gururani\time_annotations\';

SetParametersSoundtrackRemoval;
annotation = csvread(annotation_file);

tp_begin_multiplo_index = zeros(1, amount_songs);
fp_begin_index = zeros(1, amount_songs);
fn_begin_index = zeros(1, amount_songs);
tp_begin_index = zeros(1, amount_songs);

tp_end_multiplo_index = zeros(1, amount_songs);
fp_end_index = zeros(1, amount_songs);
fn_end_index = zeros(1, amount_songs);
tp_end_index = zeros(1, amount_songs);
    
fp_index = zeros(1, amount_songs);
fn_index = zeros(1, amount_songs);
tp_index = zeros(1, amount_songs);

tested_values = [];
var_index = 0;

global min_excerpt_matches_perc
variable_name = 'min_excerpt_matches_perc';
nome_arquivo = 'min_excerpt_matches_perc_3';

for var_value = 0.0:0.2:1.0
    tp_begin = 0;
    fp_begin = 0;
    fn_begin = 0;
    tp_begin_multiplo = 0;
    
    tp_end = 0;
    fp_end= 0;
    fn_end= 0;
    tp_end_multiplo = 0;
    
    tp = 0;
    fp = 0;
    fn = 0;
    
    var_index = var_index + 1;
    assignin('base', variable_name, var_value);

    for i = 1:amount_songs
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

       suspect_file = [suspect_dir, filenum2,'.mp3'];
       original_file = [sample_dir, filenum1,'.mp3'];

       sample_start = annotation(i,3)*global_Fs;
       sample_end = annotation(i,4)*global_Fs;
       duration = sample_end - sample_start;

       locations_in_time = get_excerpts(suspect_file, original_file);

       index_begin = find(abs(sample_start - locations_in_time(:,1)) <= tolerance*duration);
       index_end = find(abs(sample_end - locations_in_time(:,2)) <= tolerance*duration);

       if(numel(index_begin) == 0)
           fn_begin = fn_begin + 1;
           fn_begin_index(var_index, i) = fn_begin;
       elseif(numel(index_begin) == 1)
           tp_begin = tp_begin + 1;
           tp_begin_index(var_index, i) = tp_begin;
       else
           tp_begin = tp_begin + 1;
           tp_begin_multiplo = tp_begin_multiplo + 1;
           tp_begin_multiplo_index(var_index, i) = numel(index_begin);
       end
       fp_begin_index(var_index, i) = size(locations_in_time,1);
       fp_begin = fp_begin + size(locations_in_time,1);
       
       
       if(numel(index_end) == 0)
           fn_end = fn_end + 1;
           fn_end_index(var_index, i) = fn_end;
       elseif(numel(index_end) == 1)
           tp_end = tp_end + 1;
           tp_end_index(var_index, i) = tp_end;
       else
           tp_end = tp_end + 1;
           tp_end_multiplo = tp_end_multiplo + 1;
           tp_end_multiplo_index(var_index, i) = numel(index_end);
       end
       fp_end_index(var_index, i) = size(locations_in_time,1);
       fp_end = fp_end + size(locations_in_time,1);
       
       
       if(not(numel(index_begin) == 1 && numel(index_end) == 1))
           fn = fn + 1;
           fn_index(var_index, i) = fn;
       else
           tp = tp + 1;
           tp_index(var_index, i) = tp;
       end
       
       fp_index(var_index, i) = size(locations_in_time,1);
       fp = fp + size(locations_in_time,1);
    end
    
    precision_begin = tp_begin/(tp_begin+fp_begin);
    recall_begin = tp_begin/(tp_begin+fn_begin);
    s.result_array(var_index).precision_begin = precision_begin;
    s.result_array(var_index).recall_begin = recall_begin;
    s.result_array(var_index).f_measure_begin = 2*precision_begin*recall_begin/(precision_begin+recall_begin);
    
    precision_end = tp_end/(tp_end+fp_end);
    recall_end = tp_end/(tp_end+fn_end);
    s.result_array(var_index).precision_end = precision_end;
    s.result_array(var_index).recall_end = recall_end;
    s.result_array(var_index).f_measure_end = 2*precision_end*recall_end/(precision_end+recall_end);
    
    precision = tp/(tp+fp);
    recall = tp/(tp+fn);
    s.result_array(var_index).precision = precision;
    s.result_array(var_index).recall = recall;
    s.result_array(var_index).f_measure = 2*precision*recall/(precision+recall);
    
    tested_values(var_index) = var_value;
    s.i = i;
    s.var_index = var_index;
    save (['C:\Projeto Final\Results\Fingerprint\evaluation_fingerprint_' nome_arquivo '_parcial.mat'], '-struct', 's');

end


s.tp_begin_index = tp_begin_index;
s.fp_begin_index = fp_begin_index;
s.fn_begin_index = fn_begin_index;
s.tp_begin_multiplo_index = tp_begin_multiplo_index;

s.tp_end_index = tp_end_index;
s.fp_end_index = fp_end_index;
s.fn_end_index = fn_end_index;
s.tp_end_multiplo_index = tp_end_multiplo_index;

s.tp_index = tp_index;
s.fp_index = fp_index;
s.fn_index = fn_index;

s.excerptWindowSize_sec = excerptWindowSize_sec;
s.overlapDetection_perc = overlapDetection_perc;
s.max_dist_between_matches_sec = max_dist_between_matches_sec;
s.min_excerpt_length_sec = min_excerpt_length_sec;
s.min_excerpt_matches_perc = min_excerpt_matches_perc;
s.tolerance = tolerance;
s.amount_songs = amount_songs;
s.variable_name = variable_name;
s.tested_values = tested_values;
s.elapsedTime = toc;

save (['C:\Projeto Final\Results\Fingerprint\evaluation_fingerprint_' nome_arquivo '.mat'], '-struct', 's');

% prec = [];
% for i=1:size(result_array,2)
%     prec(i) = result_array(i).precision;
% end
% plot(tested_values, prec);