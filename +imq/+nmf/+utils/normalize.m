function [A,B,weights] = normalize(A,B, p)
% function [A,B,weights] = normalize(A,B)
%
% Normalize A to get unitary lp-norm by column and scale B accordingly
% to get the same product AB
%
%
% Inputs: (arguments in [.] are optional)
%	A: matrix m by k
%	B: matrix k by n
%	p: uses of lp-norm. p in (0, inf]
%
% Outputs:
%	A: scaled matrix A, such that ||[A]_{*,i}||_2 = 1
%	B: scaled matrix B
%	weights: D matrix - A D * D^-1 B = AB
%	
%
% Last Modified on 09/2015
%	
%
% Written by Igor Quintanilha
%            Universidade Federal do Rio de Janeiro
%            Escola Politécnica
%            Departamento de Engenharia Eletrônica
%            E-mail: igormq@poli.ufrj.br
%
% based on Jingu Kim's (jingu.kim@gmail.com)) code 
%            School of Computational Science and Engineering,
%            Georgia Institute of Technology
%
    normp = arrayfun(@(i) norm(A(:,i), p), 1:size(A,2));
    toNormalize = normp>0;

    if any(toNormalize)
        A(:,toNormalize) = A(:,toNormalize)./repmat(normp(toNormalize),size(A,1),1);
        B(toNormalize,:) = B(toNormalize,:).*repmat(normp(toNormalize)',1,size(B,2));
    end

    weights = ones(size(normp));
    weights(toNormalize) = normp(toNormalize);
end