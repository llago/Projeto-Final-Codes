%close all;
%clc;
clear all;
load 'C:\Projeto Final\Results\Fingerprint\evaluation_fingerprint_excerptWindowSize_3.mat';    

for i=1:size(result_array,2)
    recall(i) = result_array(i).recall;
    recall_begin(i) = result_array(i).recall_begin;
    recall_end(i) = result_array(i).recall_end;

    precision(i) = result_array(i).precision;
    precision_begin(i) = result_array(i).precision_begin;
    precision_end(i) = result_array(i).precision_end;
    
    f_measure(i) = result_array(i).f_measure;
    f_measure_begin(i) = result_array(i).f_measure_begin;
    f_measure_end(i) = result_array(i).f_measure_end;
end

folder = 'C:\Projeto Final\Images\Fingerprint Certas\';
file_name = 'evaluation_fingerprint_excerptWindowSize_3';
titulo = 'Tamanho do Bloco';
x_label = "Tamanho (s)";
% file_name = 'evaluation_fingerprint_excerptWindowSize_2_precision_f1';

figProp = struct('size',18,'font','Times','lineWidth',2,'figDim',[1 1 600 400]);

% tested_values = tested_values*100;
figure
plot(tested_values, recall);
hold on;
plot(tested_values, recall_begin);
hold on;
plot(tested_values, recall_end);
hold on;
%     plot(tested_values, precision);
%     hold on;
%     plot(tested_values, f_measure);
title(titulo,'Interpreter','LaTex');
xlabel(x_label)%, 'Interpreter','LaTex');
%     ylabel('Magnitude (dB)', 'Interpreter','LaTex');
%     l = legend('Precisão','f1', 'Interpreter','LaTex');
l = legend('Sensibilidade', 'Sensibilidade Início', 'Sensibilidade Fim', 'Interpreter','LaTex');

l.FontSize = 12;
%figFileName = sprintf('./SpecFrame-%d',i(j));
figFileName = [folder file_name '_recall'];
formatFig(gcf,figFileName,'pt',figProp);
%    formatFig(gcf,'test','pt',figProp);

figure
plot(tested_values, precision);
hold on;
plot(tested_values, precision_begin);
hold on;
plot(tested_values, precision_end);
hold on;

title(titulo,'Interpreter','LaTex');
xlabel(x_label)%, 'Interpreter','LaTex');
%     ylabel('Magnitude (dB)', 'Interpreter','LaTex');
%     l = legend('Precisão','f1', 'Interpreter','LaTex');
l = legend('Precisão', 'Precisão Início', 'Precisão Fim', 'Interpreter','LaTex');

l.FontSize = 12;
%figFileName = sprintf('./SpecFrame-%d',i(j));
figFileName = [folder file_name '_precision'];
formatFig(gcf,figFileName,'pt',figProp);
%    formatFig(gcf,'test','pt',figProp);

figure
plot(tested_values, f_measure);
hold on;
plot(tested_values, f_measure_begin);
hold on;
plot(tested_values, f_measure_end);
hold on;

title(titulo,'Interpreter','LaTex');
xlabel(x_label)%, 'Interpreter','LaTex');
%     ylabel('Magnitude (dB)', 'Interpreter','LaTex');
%     l = legend('Precisão','f1', 'Interpreter','LaTex');
l = legend('F1', 'F1 Início', 'F1 Fim', 'Interpreter','LaTex');

l.FontSize = 12;
%figFileName = sprintf('./SpecFrame-%d',i(j));
figFileName = [folder file_name '_f1'];
formatFig(gcf,figFileName,'pt',figProp);
%    formatFig(gcf,'test','pt',figProp);