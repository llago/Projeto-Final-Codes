function [W,H,gradW,gradH,values] = solver(V,W,H,iter,cfg,values)
    epsilon = 1e-16;

    WtA = W'*V;
    WtW = W'*W;
    WtW_reg = cfg.cost.applyReg(WtW,cfg.regH);
	
	if ~cfg.fix.H
		for i = 1:cfg.k
			H(i,:) = max(H(i,:) + WtA(i,:) - WtW_reg(i,:) * H,epsilon);
		end
	end

    AHt = V*H';
    HHt_reg = cfg.cost.applyReg(H*H',cfg.regW);
	
	if ~cfg.fix.W,
		for i = 1:cfg.k
			W(:,i) = max(W(:,i) * HHt_reg(i,i) + AHt(:,i) - W * HHt_reg(:,i),epsilon);
			if sum(W(:,i))>0
				W(:,i) = W(:,i)/norm(W(:,i));
			end
		end
	end

    if cfg.trackGrad
        gradW = W*HHt_reg - AHt;
        gradH = cfg.cost.getGradientOne(W'*W,W'*V,H,cfg.regH);
    else
        gradH = 0; gradW = 0;
    end
end