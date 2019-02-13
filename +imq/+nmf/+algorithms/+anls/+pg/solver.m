function [W,H,gradW,gradH,val] = solver(V, W, H, iter, cfg, val)
	
	[W, gradW, val.iterW] = imq.nmf.algorithms.anls.pg.pgrad_subproblem(V',H',W',val.tolW, val.maxInner, val.maxSearchSteps, val.eta, val.beta, val.sigma); 
	
	W = W'; 
	val.gradW = gradW';
	gradW = gradW';
	
	if val.iterW==1,
		val.tolW = 0.1 * val.tolW;
	end

	[H, gradH, val.iterH] = imq.nmf.algorithms.anls.pg.pgrad_subproblem(V,W,H,val.tolH, val.maxInner, val.maxSearchSteps, val.eta, val.beta, val.sigma);
	
	if val.iterH==1,
		val.tolH = 0.1 * val.tolH; 
	end
end