function [P, S, F, VP, FP, FN, onsets_reduced, target_reduced] = evaluation(onsets, target, window, varargin)
% [P, S, F] = evaluation(onset, target, window)
% 
% Evaluation of detected onset and target onset
%
% Evaluation of onset detectin
%
% Inputs: (arguments in [.] are optional)
%	onsets - calculated onsets
%	target - target onsets
%	window - precision window in ms
%
% Outputs:
%	P -	Precision
%	S - recall
%	F - F-measure
%
% Formula:
%	P = VP/(VP + FP)
%	S = VP/(VP + FN)
%	F = 2*P*S/(P+S)
%
% Last Modified on 02/2016
%	
%
% Written by Igor Quintanilha
%            Universidade Federal do Rio de Janeiro
%            Escola Politécnica
%            Departamento de Engenharia Eletrônica
%            E-mail: igormq@poli.ufrj.br

	p = inputParser;
	
	addRequired(p, 'onsets', @(x) validateattributes(x, {'numeric'}, {}));
	addRequired(p, 'target', @(x) validateattributes(x, {'numeric'}, {}));
	addOptional(p, 'window', 50, @(x) validateattributes(x, {'numeric'}, {}));
	addParamValue(p, 'merge', true, @(x) validateattributes(x, {'logical'}, {}));

	parse(p, onsets, target, window, varargin{:});
	
	args = p.Results;

	time = window / 1000;

	vp = 0;
	fp = 0;
	fn = 0;

	if args.merge
		target = imq.onset.mergeOnsets(target, window);
		onsets = imq.onset.mergeOnsets(onsets, window);
	end

	if nargout > 6
		onsets_reduced = onsets;
		target_reduced = target;
	end

	L = length(onsets);

	idx = 1;
	while idx <= L
		idxs = find(abs(target - onsets(idx)) - time <= 1e-6);

		if ~isempty(idxs)
			target(idxs) = [];
			onsets(idx) = [];
			L = L - 1;
			vp = vp + length(idxs);
		else
			idx = idx + 1;
		end

	end

	fp = length(onsets);
	fn = length(target);

	if nargout > 3,
		VP = vp;
		FP = fp;
		FN = fn;
	end

	P = vp/(vp + fp);
	S = vp/(vp + fn); 
	F = 2*P*S/(P+S);


end