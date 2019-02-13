function [DMKL] = MKL(X, p)
% function [DMKL] = MKL(X, threshold)
%
% Modified Kullback-Liebler Distance
%
% Inputs: (arguments in [.] are optional)
%
%	p - 
% 		1 - L_1 norm
%		2 - L_2 norm
%
% Outputs:
%	D_SD -	Detection function
%
% Last Modified on 06/2015
%
% Kullback-Liebler distance can be used to highlight the large variations
% and inhibit small ones
%
%	D_MLK = sum_k log(1+ |X_k(n)|/(X_k(n-1)+eps))
%
%	
%
% Written by Igor Quintanilha
%            Universidade Federal do Rio de Janeiro
%            Escola Politécnica
%            Departamento de Engenharia Eletrônica
%            E-mail: igormq@poli.ufrj.br
%
%
% Reference:
%	[1] BELLO, Juan Pablo et al. A tutorial on onset detection in music
%		signals. Speech and Audio Processing, IEEE Transactions on, v. 13, n. 
%		5, p. 1035-1047, 2005.
%	[2] BROSSIER, Paul M. Automatic annotation of musical audio for
%		interactive applications. 2006. Tese de Doutorado. 
%		Queen Mary, University of London.
%		Journal of Global Optimization, 58(2), pp. 285-319, 2014.
eps = 1e-6;

DMKL = sum(log(1 + X./(abs([zeros(size(X,1), 1) X(:, 1:(end-1))]) + eps)), 1);


end