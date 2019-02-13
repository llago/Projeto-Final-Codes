function [out] = rdir(path, varargin)
	
	p = inputParser;
	addRequired(p, 'path', @ischar);
	
	addParamValue(p, 'depth', 3, @(x) validateattributes(x, {'numeric'}, {'>=', 0}));
	addParamValue(p, 'filter', '*', @ischar);
	addParamValue(p, 'display', 'all');
	
	parse(p, path, varargin{:});
	
	input = p.Results;
	
	switch input.display
		case 'leaves'
			input.leaves = true;
		case 'all'
			input.leaves = false;
	end
	
	function [out] = rdir_inner(path, depth, filter, leaves)
		if depth == -1
			return;
		end
		
		dirs = dir([path filesep filter]);
		
		root = strcat([path filesep], {dirs(arrayfun(@(x) x.isdir && x.name(1) ~= '.', dirs)).name});
		
		out = {};
			
		if isempty(root)
			if leaves
				out = [out path];
			end
			return;
		end
		
		for index=1:length(root),
			var = rdir_inner(root{index}, depth-1, filter, leaves);
			if ~leaves
				out = [out root{index} var];
			else
				out = [out var];
			end
		end
	end
	
	out = rdir_inner(path, input.depth, input.filter, input.leaves);
end

