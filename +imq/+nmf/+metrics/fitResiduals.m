function [resW, resH] = fitResiduals(records)
% function [resW, resH] = fitResiduals(records)
%
% Residuals calculation at end of iteration res(Xi) = ||Xi - X||_F
%
% Input:
%	records - Struct containing all records of NMF algorithm
%
% Output:
%	resW - fit residuals of matrix W
%	resH - fit residuals of matrix H
%
% Last Modified on 06/2015
%
% Written by Igor Quintanilha
%            Universidade Federal do Rio de Janeiro
%            Escola Politécnica
%            Departamento de Engenharia Eletrônica
%            E-mail: igormq@poli.ufrj.br

[m, k] = size(records.history(1).W);
[~, n] = size(records.history(1).H);

resW = norm(records.history(:).W - records.history(end).W, 'fro') / (m*k);
resH = norm(records.history(:).H - records.history(end).H, 'fro') / (k*n);