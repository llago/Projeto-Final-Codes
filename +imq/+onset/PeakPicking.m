function [onsets] = PeakPicking(f, alpha, delta, varargin)
% function [delta_t] = PeakPicking(D, a, b, lambda, delta)
%
% Peak picking implementation according to [1].
%
% Inputs: (arguments in [.] are optional)
%	f - onset detection function
%	w - is the size of the window used to find a local maximum (default: 3)
%	m - is a multiplier so that the mean is calculated over a large range
%		before the peak (default: 3)
%	alpha - parameter of threshold function
%	delta - is the threshold above the local mean which an onset must reach
%
%	Formula:
%			f(n) >= f(k), for all k such that n-w <= k <= w
%			f(n) >= sum_{k=n-mw}^{n+w) f(k)/(mw + w + 1) + delta
%			f(n) >= g_alpha(n-1)
%			where:
%				g_alpha(n) = max(f(n), alpha*g_alpha(n-1) + (1-alpha)f(n))
%
%	Optimum set varying alpha and delta
%
% Outputs:
%
% Last Modified on 02/2016
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
%	[1] S. Dixon, ?Onset detection revisited?, in Proceedings of the 
%		International Conference on Digital Audio Effects, 2006, 
%		p. 133?137.

	parser = inputParser;
	
	addRequired(parser, 'f', @(x) validateattributes(x, {'numeric'}, {}));
	addRequired(parser, 'alpha', @(x) validateattributes(x, {'numeric'}, {}));
	addRequired(parser, 'delta', @(x) validateattributes(x, {'numeric'}, {}));
	addParamValue(parser, 'w', 3, @(x) validateattributes(x, {'numeric'}, {}));
	addParamValue(parser, 'm', 3, @(x) validateattributes(x, {'numeric'}, {}));
	
	parse(parser, f, alpha, delta, varargin{:});
	
	args = parser.Results;

	% Normalised to have a mean of 0 and standard deviation of 1
	f = f - mean(f);
	f = f/std(f);

	N = length(f);
	
	den = args.m*args.w + args.w + 1;
	
	g_alpha = zeros(N+1,1);
	onsets = zeros(1,N);

	for n=1:N,
		g_alpha(n+1) = max([f(n), alpha*g_alpha(n) + (1-alpha)*f(n)]);
		
		k = max([(n-args.w) 1]): min([(n+args.w) N]);
		if ~all(f(n) >= f(k))
			continue;
		end
		
		k = max([(n-args.m*args.w) 1]): min([(n+args.w) N]);
		if ~(f(n) >= (sum(f(k))/den + delta))
			continue;
		end
		
		if ~(f(n) >= g_alpha(n))
			continue;
		end
		
		onsets(n) = 1;
			
	end
end