function [pd] = PD(X)
% function [pd] = PD(X)
%
% Phase Deviation by Bello et. al.
%
% Inputs: (arguments in [.] are optional)
%
%	X - spectogram of signal
%
% Outputs:
%	PD - detection function
%
% Last Modified on 03/2016
%
% Formula:
%	X(n,k) = |X(n,k)| exp(j phi(n,k))
%   phi'(n,k) = phi(n,k) - phi(n-1,k)
%	phi''(n,k) = phi'(n,k) - phi'(n-1,k)
%
%	PD(n) = 1/N sum_{k=-N/2}^{N/2-1} |phi''(n,k)|
%
% Written by Igor Quintanilha
%            Universidade Federal do Rio de Janeiro
%            Escola Politécnica
%            Departamento de Engenharia Eletrônica
%            E-mail: igormq@poli.ufrj.br

%
% Reference:
%	[1] BELLO, Juan Pablo et al. A tutorial on onset detection in music
%		signals. Speech and Audio Processing, IEEE Transactions on, v. 13, 
%		n. 5, p. 1035-1047, 2005.
%	[2] S. Dixon, ?Onset detection revisited?, in Proceedings of the 
%		International Conference on Digital Audio Effects, 2006, p. 133?137.


phi = angle(X)';

[n, k] = size(phi);

delta_phi = phi - 2*[zeros(1, k); phi(1:(end-1), :)] + [zeros(2,k); phi(1:(end-2), :)];

pd = mean(abs(delta_phi),2)';