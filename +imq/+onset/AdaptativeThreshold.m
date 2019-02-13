function [delta] = AdaptativeThreshold(D, a, b, lambda, delta0)
% function [delta_t] = AdaptativeThreshold(D, a, b, lambda, delta)
%
% Median Filtering
%
% Inputs: (arguments in [.] are optional)
%
%
% Outputs:
%
% Last Modified on 06/2015
%
% Adaptative thresholding
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

delta = zeros(size(D));

N = length(D);

D = [zeros(1, a) D zeros(1,b)];

for n=1:N,
	
	delta(n) = delta0 + lambda*median(D(n + a + (-a:b)));
end

% delta = delta0 + lambda*medfilt1(D, 2*a+1);

end