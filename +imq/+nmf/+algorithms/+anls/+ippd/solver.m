function [W,H,gradW,gradH,values] = solver(A,W,H,iter,cfg,values)
	
	[H, gradH, values.prevH] = imq.nmf.algorithms.anls.ippd.subIPNMFMatrix(A, W, H, cfg, values, values.prevH);
	
	[W, gradW, values.prevW] = imq.nmf.algorithms.anls.ippd.subIPNMFMatrix(A', H', W', cfg, values, values.prevW);
	W = W';

    values.WtA = W'*A;
    values.WtW = W'*W;

    if cfg.trackGrad
        gradW = gradW';
%         gradH = cfg.cost.getGradientOne(values.WtW,values.WtA,H,cfg.regH);
    else
        gradW = 0;gradH =0;
    end

end