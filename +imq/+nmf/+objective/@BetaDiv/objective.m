function val = objective(obj, V, W, H)
% function val = objective(obj, V, W, H, varargin)
%
% Beta-divergence cost function
%
% Input:
%	V		- Input nonnegative matrix
%	W		- Basis Matrix
%	H		- Gain matrix
%	[beta]	- 
%				0		- Itakura-Saito			d(x|y) = x/y - ln(x/y) - 1
%				1		- Kullback-Liebler		d(x|y) = x*ln(x/y)-x+y
%				2		- Euclidian distance	d(x|y) = 1/2 ||x - y||_F^2 
%				]0 1[	-						d(x|y) = 1/(b*(b-1))*(x^b +
%													 (b-1)*y^b - b*x*y^(b-1))
%
% Output:
%	div - The error (distortion) measure
%
% Last Modified on 06/2015
%
% Written by Igor Quintanilha
%            Universidade Federal do Rio de Janeiro
%            Escola Politécnica
%            Departamento de Engenharia Eletrônica
%            E-mail: igormq@poli.ufrj.br
	WH = W*H;
	switch obj.beta
		case 0
			val = sum(sum(V./WH - log(V./WH) - 1));
		case 1
			val = sum(sum(V .* log(V./WH) + WH - V));
		case 2
			val = 1/2*norm(V-W*H, 'fro')^2;
		otherwise
			val = sum(sum(1/(obj.beta*(obj.beta-1))*(V.^obj.beta+(obj.beta-1)*WH.^obj.beta - obj.beta*V.*WH.^(obj.beta-1))));
	end
end