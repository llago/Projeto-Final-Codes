function [W,H,gradW,gradH,values] = solver(A,W,H,iter,cfg,values)

    WtW_reg = cfg.cost.applyReg(values.WtW, cfg.regH);
	
	if ~cfg.fix.H
		[H,~,suc_H,numChol_H,numEq_H] = imq.nmf.algorithms.anls.bpp.nnlsm_blockpivot(WtW_reg,values.WtA,1,H);
	else
		H = H;
		suc_H = 0;
		numChol_H = 0;
		numEq_H = 0;
	end

    HHt_reg = cfg.cost.applyReg(H*H', cfg.regW);
	
	if ~cfg.fix.W
		[W,gradW,suc_W,numChol_W,numEq_W] = imq.nmf.algorithms.anls.bpp.nnlsm_blockpivot(HHt_reg,H*A',1,W');
		W = W';
	elseif ~ischar(cfg.fix.W) && cfg.fix.W,
		gradW = zeros(size(W))';
		suc_W = 0;
		numChol_W = 0;
		numEq_W = 0;
	elseif ischar(cfg.fix.W) && strcmp(cfg.fix.W, 'semi')
		[Wi,gradWi,suc_W,numChol_W,numEq_W] = imq.nmf.algorithms.anls.bpp.nnlsm_blockpivot(HHt_reg,H*A',1,W');
		
		gamma = (1-iter/cfg.maxIteration)^2;
		
		W = gamma*W + (1-gamma)*Wi';

		gradW = (gamma*values.gradW + (1-gamma)*gradWi')';
		
		values.gradW = gradW';
	end

    values.WtA = W'*A;
    values.WtW = W'*W;

    if cfg.trackGrad
        gradW = gradW';
        gradH = cfg.cost.getGradientOne(values.WtW,values.WtA,H,cfg.regH);
    else
        gradW = 0;gradH =0;
    end

    values(1).numChol_W = numChol_W;
    values.numChol_H = numChol_H;
    values.numEq_W = numEq_W;
    values.numEq_H = numEq_H;
    values.suc_W = suc_W;
    values.suc_H = suc_H;
end