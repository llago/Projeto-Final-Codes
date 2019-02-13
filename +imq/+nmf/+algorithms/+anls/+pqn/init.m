function [W,H,cfg,val,ver] = init(V,W,H,cfg)
	[m,T] = size(V);
	[~, r] = size(W);

	val.H.T = speye(T);
	val.H.rT = speye(r*T);
	val.W.I = eye(r);
	
	val.H.I = eye(r);

	val.H.gamma = .9;
	val.H.lambdaInit = 1e-13;

	ver = struct();
		
	if ~isempty(cfg.subParams) && ~isempty(fieldnames(cfg.subParams)),
		fields = fieldnames(cfg.subParams);
		
		if strmatch('gamma', fields),
			val.H.gamma = cfg.subParams.gamma;
		end
		
		if strmatch('lambdaInit', fields),
			val.H.lambdaInit = cfg.subParams.lambdaInit;
		end
		
	end
	
end