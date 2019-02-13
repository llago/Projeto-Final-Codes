function [nwpd] = NWPD(X)
% function [nwpd] = NWPD(X)
%
% Normalized Weighted Phase Deviation by Dixon et. al.
%
% Inputs: (arguments in [.] are optional)
%
%	X - spectogram of signal
%
% Outputs:
%	NWPD - detection function
%
% Last Modified on 03/2016
%
% Formula:
%	X(n,k) = |X(n,k)| exp(j phi(n,k))
%   phi'(n,k) = phi(n,k) - phi(n-1,k)
%	phi''(n,k) = phi'(n,k) - phi'(n-1,k)
%
%	WPD(n) = sum_{k=-N/2}^{N/2-1} |X(n,k)phi''(n,k)| / sum_{k=-N/2}^{N/2-1}
%	|X(n,k)|
%
% Written by Igor Quintanilha
%            Universidade Federal do Rio de Janeiro
%            Escola Politécnica
%            Departamento de Engenharia Eletrônica
%            E-mail: igormq@poli.ufrj.br

%
% Reference:
%	[1] S. Dixon, Onset detection revisited, in Proceedings of the 
%		International Conference on Digital Audio Effects, 2006, p. 133-137.

X = X';
phi = angle(X);

phi_line = [phi(1, :); diff(phi)];

phi_line_line = [phi_line(1, :); diff(phi_line)];

nwpd = sum(abs(X.*phi_line_line),2)' ./ sum(sum(abs(X + eps),2));