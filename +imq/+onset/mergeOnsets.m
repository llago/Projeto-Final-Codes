function [mergedOnsets] = mergeOnsets(onsets, time, varargin)
% function [mergedOnsets] = mergeOnsets(onsets, time)
% 
% combination of onset candidates within 'time' ms windows
%
% the weight of the resulting candidate is obtained as the highest weight
% value multiplied by the number of candidates within the 50 ms window
%
% High Frequency Content
%
% Inputs: (arguments in [.] are optional)
%	onsets - onsets detected in seconds
%	time - windows time for merging in ms
%
% Outputs:
%	mergedOnsets -	merged onsets
%
% Last Modified on 02/2016
%	
%
% Written by Igor Quintanilha
%            Universidade Federal do Rio de Janeiro
%            Escola Politécnica
%            Departamento de Engenharia Eletrônica
%            E-mail: igormq@poli.ufrj.br
 
parser = inputParser;

addParamValue(parser, 'recursive', true, @(x) validateattributes(x, {'logical'}, {}));

parse(parser, varargin{:})

args = parser.Results;

time = time/1000; %transform in seconds

while true
	mergedOnsets = [];
	L = length(onsets);
	idx = 1;
	while(idx <= L)
		idxs = find(abs(onsets((idx + 1):end) - onsets(idx)) - time <= 1e-6) + idx;

		if isempty(idxs)
			mergedOnsets = [mergedOnsets onsets(idx)];
			idx = idx + 1;
		else
			mergedOnsets = [mergedOnsets median(onsets([idx idxs]))];
			idx = idxs(end) + 1;
		end
	end
	
	if length(mergedOnsets) == length(onsets) && all(mergedOnsets(:) == onsets(:))
		break;
	end
	
	onsets = mergedOnsets;
	
	if ~args.recursive,
		break
	end
end