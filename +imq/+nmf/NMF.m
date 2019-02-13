function [W, H, it, records] = NMF(V, k, varargin)
% function [W, H, records] = NMF(cfg.V,r,...)
%
% Nonnegative Matrix Factorization
%
% Inputs: (arguments in [.] are optional)
%
% Outputs:
%
% Last Modified on 09/2015
%
% Implementation based on Jingu Kim (jingu.kim@gmail.com) and Fèvotte code.
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
%	[1] LEE, Daniel D., SEUNG, H. Sebastian. Algorithms for non-negative
%		matrix factorization. In: Advances in neural information processing
%		systems. 2001. p. 556-562.
%	[2] Jingu Kim, Yunlong He, and Haesun Park.
%		Algorithms for Nonnegative Matrix and Tensor Factorizations: A Unified View
%		Based on Block Coordinate Descent Framework.
%		Journal of Global Optimization, 58(2), pp. 285-319, 2014.
%	[3] LANGVILLE, Amy N. et al. Algorithms, initializations, and
%		convergence for the nonnegative matrix factorization. 2014.
%

% Parsing parameters

	gStart = tic;
	
	AT = '@';
	DOT = '.';
	
	tries = 0; 

	params = inputParser;
	addRequired(params, 'V'				, @(x) validateattributes(x, {'numeric'}, {'nonnegative','2d'}));
	addRequired(params, 'k'				, @(x) validateattributes(x, {'numeric'}, {'scalar', '>', 0}));
	addParamValue(params, 'algorithm'	, 'imq.nmf.algorithms.anls.bpp'		, @(x) validateattributes(x, {'char'}, {}));
	addParamValue(params, 'cost'			, imq.nmf.objective.Frobenius		, @(x) validateattributes(x, {'imq.nmf.objective.Default'}, {}));
	addParamValue(params, 'fix'			, struct('W', false, 'H', false)	,@(x) validateattributes(x, {'struct'}, {'nonempty'}));
	addParamValue(params, 'stopCriterion', 2									,@(x) validateattributes(x, {'numeric'}, {'scalar', '>=', 0, '<=', 3}));
	addParamValue(params, 'tolerance'	, 1e-6								,@(x) validateattributes(x, {'numeric'}, {'scalar', '>', 0}));
	addParamValue(params, 'minIteration'	, 20								,@(x) validateattributes(x, {'numeric'}, {'scalar', '>', 0}));
	addParamValue(params, 'maxIteration'	, 500								,@(x) validateattributes(x, {'numeric'}, {'scalar', '>', 0}));
	addParamValue(params, 'maxTime'		, 1e6								,@(x) validateattributes(x, {'numeric'}, {'scalar', '>', 0}));
	addParamValue(params, 'init'			, struct([])						,@(x) isstruct(x));
	addParamValue(params, 'verbose'		, 1									,@(x) validateattributes(x, {'numeric'}, {'scalar', '>=', 0, '<=', 3}));
	addParamValue(params, 'lpNorm'		, 2									,@(x) validadeattributes(x, {'numeric'}, {}));
	addParamValue(params, 'regW'			, [0 0]								, @(x) isnumeric(x));
	addParamValue(params, 'regH'			, [0 0]								,@(x) isnumeric(x));
	addParamValue(params, 'subParams'	, {}							,@(x) validateattributes(x, {'cell'},{}));
	addParamValue(params, 'monteCarlo'	, 0									,@(x) validateattributes(x, {'integer'}, {'>=', 0}));
	addParamValue(params, 'maxTries'		, 3									,@(x) validateattributes(x, {'integer'}, {'nonnegative'}));
	% The following options are reserved for debugging/experimental purposes.
	addParamValue(params, 'trackGrad'    ,true								,@(x) validateattributes(x, {'logical'}, {}));
	addParamValue(params, 'trackPrev'    ,true								,@(x) validateattributes(x, {'logical'}, {}));
	addParamValue(params, 'visual'    ,false								,@(x) validateattributes(x, {'function_handle', 'logical'}, {}));

	parse(params, V, k, varargin{:});

	% Loading configurations

	[m, n] = size(V);
	
	cfg = imq.nmf.Configuration.getInstance.setProperties(params.Results);
	
	cfg.addProperty('m', m);
	cfg.addProperty('n', n);
	
	cfg.addProperty('initializer', eval([AT cfg.algorithm DOT 'init']));
	cfg.addProperty('getUpdate', eval([AT cfg.algorithm DOT 'solver']));
	cfg.addProperty('getIterLogger', eval([AT cfg.algorithm DOT 'logger']));
	
	cfg.addProperty('getObjective', @(varargin) cfg.cost.objective(varargin{:}));
	cfg.addProperty('getGradient', @(varargin) cfg.cost.gradient(varargin{:}));
	cfg.addProperty('getHessian', @(varargin) cfg.cost.hessian(varargin{:}));
	
	% If empty, random initializer of matrix W and H
	if isempty(cfg.init)
		W = rand(cfg.m, cfg.k);
		H = rand(cfg.k, cfg.n);
	else
		W = cfg.init.W;
		H = cfg.init.H;
	end
	
	clear('init');
	
	if cfg.verbose          % Collect initial information for analysis/debugging
		
		init.normV = norm(cfg.V, 'fro');
		init.normW = norm(W, 'fro');
		init.normH = norm(H, 'fro');
		init.objective = cfg.getObjective(cfg.V, W, H);
		
		if cfg.trackGrad
			[gradW,gradH]    = cfg.getGradient(cfg.V,W,H);
			init.normGradW   = norm(gradW,'fro');
			init.normGradH   = norm(gradH,'fro');
			
			init.SCNMPGRAD	 = imq.nmf.stoppingCriteria.main(1,cfg.V,W,H,cfg,gradW,gradH);
			init.SCPGRAD     = imq.nmf.stoppingCriteria.main(2,cfg.V,W,H,cfg,gradW,gradH);
			init.SCDELTA     = imq.nmf.stoppingCriteria.main(3,cfg.V,W,H,cfg,gradW,gradH);
		else
			gradW = 0; gradH = 0;
		end
		
		if cfg.trackPrev
			prevW = W; prevH = H;
		else
			prevW = 0; prevH = 0;
		end
		
		ver = imq.nmf.utils.formatHistory(V,W,H,prevW,prevH,init,cfg,0,0,gradW,gradH);
		
		records(1).init = init;
		records.history = ver;
		
		if cfg.verbose >= 2
			display(init);
		end
		
	end
	
	start = tic;
	[W, H, cfg, values, ver] = cfg.initializer(V, W, H, cfg);

	discount = toc(start);
	
	if cfg.verbose && ~isempty(ver)
		records.history = imq.nmf.utils.saveHistory(1,ver,records.history);
	end
	
	records(1).cfg = cfg;
	records.startTime = datestr(now);
	
	if cfg.verbose == 3,
		display(cfg);
	end
	
	if cfg.trackGrad
		init.SC = imq.nmf.stoppingCriteria.main(cfg.stopCriterion,cfg.V,W,H,cfg);
	end
	
	start = start + (toc(start) - discount);

	for it=2:cfg.maxIteration,

		[W, H, gradW, gradH, values] = cfg.getUpdate(cfg.V, W, H, it-2, cfg, values);
		
		if cfg.verbose,	% Collect information for analysis/debugging
			elapsedTime = toc(start);
			
			if ~islogical(cfg.visual)
				cfg.visual(cfg.V, W, H);
			end
			
			clear('ver');
			
			ver = imq.nmf.utils.formatHistory(cfg.V,W,H,prevW,prevH,init,cfg,it,elapsedTime,gradW,gradH);
			
			ver = cfg.getIterLogger(ver,cfg,values,W,H,prevW,prevH);
			
			records.history = imq.nmf.utils.saveHistory(it,ver,records.history);
			
			if cfg.trackPrev,
				prevW = W; prevH = H;
			end
			
			if cfg.verbose == 3,
				display(ver);
			end
			
			start = start + (toc(start) - elapsedTime);
		end
		
		if it > cfg.minIteration,
			if toc(start) >= cfg.maxTime,
				break;
			end
			
			if cfg.trackGrad,
				SC = imq.nmf.stoppingCriteria.main(cfg.stopCriterion,cfg.V,W,H,cfg,gradW,gradH);
				if (SC/init.SC <= cfg.tolerance),
					tries = tries + 1;
					
					if (tries >= cfg.maxTries),
						break;
					end
				else
					tries = 0;
				end
			end
		end
	end
	
	%Normalize columns by lp-norm
	if cfg.lpNorm >= 0,
		[W, H] = imq.nmf.utils.normalize(W,H, cfg.lpNorm);
	end
	
	if cfg.verbose
		final.elapsedTotal			= toc(start);
		final.elapsedGlobal			= toc(gStart);
		final.iterations			= it;
		final.objective				= cfg.getObjective(cfg.V, W, H);
		final.WDensity				= length(find(W > 0))/(cfg.m*cfg.k);
		final.HDensity				= length(find(H > 0))/(cfg.n*cfg.k);
		final.W = W;
		final.H = H;
		records.final = final;
	end
	
	records.finishTime = datestr(now);
	records.elapsedGlobal = toc(gStart);
	
	if cfg.verbose >= 2,
		display(final);
	end
end