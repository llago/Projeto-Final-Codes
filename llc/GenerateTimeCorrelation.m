%close all;
%clc;
clear all;
load 'C:\Projeto Final\Results\Fingerprint\evaluation_fingerprint_max_dist_3.mat';    
annotation_file = 'C:\Projeto Final\Dataset\Gururani\annotation.csv';
annotation = csvread(annotation_file);
duration = annotation(1:40,4) - annotation(1:40,3);

% stem(sort(duration))

tp{1} = sum(tp_index(:, duration < 2) ~= 0, 2);
tp{2} = sum(tp_index(:,(2 < duration) & (duration < 4)) ~= 0, 2);
tp{3} = sum(tp_index(:,(4 < duration) & (duration < 6)) ~= 0, 2);
tp{4} = sum(tp_index(:,(6 < duration) & (duration < 8)) ~= 0, 2);
% tp{5} = sum(tp_index(:,(4 < duration) & (duration < 5)) ~= 0, 2);
% tp{6} = sum(tp_index(:,(5 < duration) & (duration < 6)) ~= 0, 2);
% tp{7} = sum(tp_index(:,(6 < duration) & (duration < 7)) ~= 0, 2);
tp{5} = sum(tp_index(:, 8 < duration) ~= 0, 2);



% tp{1} = sum(tp_begin_index(:, duration < 2) ~= 0, 2);
% tp{2} = sum(tp_begin_index(:,(2 < duration) & (duration < 4)) ~= 0, 2);
% tp{3} = sum(tp_begin_index(:,(4 < duration) & (duration < 6)) ~= 0, 2);
% tp{4} = sum(tp_begin_index(:,(6 < duration) & (duration < 8)) ~= 0, 2);
% % tp{5} = sum(tp_index(:,(4 < duration) & (duration < 5)) ~= 0, 2);
% % tp{6} = sum(tp_index(:,(5 < duration) & (duration < 6)) ~= 0, 2);
% % tp{7} = sum(tp_index(:,(6 < duration) & (duration < 7)) ~= 0, 2);
% tp{5} = sum(tp_begin_index(:, 8 < duration) ~= 0, 2);



% tp{1} = sum(tp_end_index(:, duration < 2) ~= 0, 2);
% tp{2} = sum(tp_end_index(:,(2 < duration) & (duration < 4)) ~= 0, 2);
% tp{3} = sum(tp_end_index(:,(4 < duration) & (duration < 6)) ~= 0, 2);
% tp{4} = sum(tp_end_index(:,(6 < duration) & (duration < 8)) ~= 0, 2);
% % tp{5} = sum(tp_index(:,(4 < duration) & (duration < 5)) ~= 0, 2);
% % tp{6} = sum(tp_index(:,(5 < duration) & (duration < 6)) ~= 0, 2);
% % tp{7} = sum(tp_index(:,(6 < duration) & (duration < 7)) ~= 0, 2);
% tp{5} = sum(tp_end_index(:, 8 < duration) ~= 0, 2);

folder = 'C:\Projeto Final\Images\Fingerprint Time Correlation\';
file_name = 'evaluation_fingerprint_max_dist_3_time_correlation';
titulo = 'Correlação Temporal - Geral';
% file_name = 'evaluation_fingerprint_excerptWindowSize_2_precision_f1';

figProp = struct('size',18,'font','Times','lineWidth',2,'figDim',[1 1 600 400]);

figure
bar(cell2mat(tp)');
%     plot(tested_values, precision);
%     hold on;
%     plot(tested_values, f_measure);
title(titulo,'Interpreter','LaTex');
xlabel('Grupos de Duração')%, 'Interpreter','LaTex');
ylabel('Samples Encontrados', 'Interpreter','LaTex');
%     l = legend('Precisão','f1', 'Interpreter','LaTex');
% l = legend('1s', '2s', '3s', '4s', '5s', '6s', '7s', '7+s', 'Interpreter','LaTex');

l.FontSize = 12;
%figFileName = sprintf('./SpecFrame-%d',i(j));
figFileName = [folder file_name];
formatFig(gcf,figFileName,'pt',figProp);
%    formatFig(gcf,'test','pt',figProp);
