classdef BetaDiv < imq.nmf.objective.Default
	% Beta-divergence cost function
	%
	% Input:
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
	
	properties
		beta = 2
	end
	
	methods
		function obj = BetaDiv(varargin)
		  if nargin > 1
			 for k=1:2:length(varargin)
				obj.(varargin{k}) = varargin{k+1};
			 end
		  end
		end
		
		val = objective(obj, V, W, H)
		
		[gradW, gradH] = gradient(obj, V, W, H, varargin)
		
		val = hessian(obj, V, W, H)
	end
end