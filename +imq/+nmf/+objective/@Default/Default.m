classdef Default < handle
	
	properties(Access=protected)
		cfg
	end
	
	methods
		function obj = Default(varargin)
			obj.cfg = imq.nmf.Configuration.getInstance;
		end
	end
	
	% Abstract class for creating cost functions
	methods (Abstract)
		objective(obj, V, W, H)
		% Return objective value
		gradient(obj, V, W, H)
		% Return gradient value
		hessian(obj, V, W, H)
		% Return hessian value
	end
end