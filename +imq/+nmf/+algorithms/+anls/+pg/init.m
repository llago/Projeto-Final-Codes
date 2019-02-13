function [W,H,cfg,val,ver] = init(V,W,H,cfg)
	tol = 1e-12;
	val.maxSearchSteps = 20;
	
	val.sigma = 0.01;
	val.beta = 0.1;
	val.eta = 1;
	val.maxInner = 1000;
	
	[gradW,gradH]    = cfg.getGradient(V,W,H);
	initGrad = imq.nmf.stoppingCriteria.main(2,V,W,H,cfg,gradW,gradH);
	
	val.tolW = max(0.001,tol)*initGrad;
	
	val.tolH = val.tolW;
	
	if ~isempty(cfg.subParams) && ~isempty(fieldnames(cfg.subParams)),
		fields = fieldnames(cfg.subParams);
		
		if strcmp('sigma', fields),
			val.sigma = cfg.subParams.sigma;
		end
		
		if strcmp('beta', fields),
			val.beta = cfg.subParams.beta;
		end
		
	end
	
	ver.sigma = val.sigma;
	ver.beta = val.beta;
	ver.eta = val.eta;
	ver.initGrad = initGrad;
	ver.initTolW = val.tolW;
	ver.initTolH = val.tolH;
	
	val.iterW = 0;
	val.iterH = 0;
	
end