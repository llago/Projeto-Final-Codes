% Script to evaluate the classifier
annotation_file = 'C:/Projeto Final/Dataset/Gururani/annotation.csv';
annotation = csvread(annotation_file);
load 'C:/Projeto Final/Results/DTW/Costs_locs/complete_duration_proeminence_10_ate_63.mat'

right = 0;
wrong = 0;

for i = 1:63
    if (annotation(i,5) == (best_index_cell{i} - 7))
        right = right + 1;
    else
        wrong = wrong + 1;
    end
   
end
right
wrong
