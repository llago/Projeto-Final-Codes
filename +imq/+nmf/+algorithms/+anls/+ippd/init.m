function [W,H,cfg,values,ver] = init(V,W,H,cfg)
    input = inputParser;

	addParamValue(input, 'maxInnerIt', 10);
	addParamValue(input,'initReg', 1e-8);
	addParamValue(input,'mu', 15);
	addParamValue(input,'xi', 0.99);
	addParamValue(input,'tol', 1e-8);
	addParamValue(input,'epsFeas', 1e-6); 
% 	addParamValue(input,'alphaSpar', [0 0]); %[sparW sparH contW contH contOrder]
% 	addParamValue(input,'alphaCont', [0 0]);
% 	addParamValue(input,'alpha', [0 0]);%[weightSpar normSpar weightCont]
	addParamValue(input,'T', 0);
	
	parse(input, cfg.subParams{:})
	
	values = input.Results;
	
	[gradW, gradH] = cfg.getGradient(V, W, H);
	
	[m,n] = size(V);
	r = size(W, 2);
	
	values.prevH.x = H(:);
	values.prevH.grad = gradH(:);
	values.prevH.B = speye(r*n);
	values.prevH.I = speye(r*n);
	
	values.prevW.x = W(:);
	values.prevW.grad = gradW(:);
	values.prevW.B = speye(r*m);
	values.prevW.I = speye(r*m);
	
	ver = struct();
end