function [d] = removeCloser(d0, samples)
% function [d] = removeCloser(d0, samples)
%
% Remove closer samples from onset detection function.
%
% Inputs: (arguments in [.] are optional)
%
%
% Outputs:
%
% Last Modified on 06/2015
%
% Human auditory system can distinguish only 50ms of separation
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

samples = ceil(samples);
d = zeros(size(d0));
[samples numel(d0)]
n = 1;
while n < numel(d0)
	
	[m, i] = max(d0(max((n-samples),1):min((n+samples), numel(d0))));
	if i == 
	d((n-samples - 1) + i) = m;
	
end