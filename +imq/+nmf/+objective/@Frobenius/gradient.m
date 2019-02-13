function [gradW,gradH] = gradient(obj, V, W, H)
	
	HHt = H*H';
	HHt_reg = obj.applyReg(HHt, obj.cfg.regW);
	
	WtW = W'*W;
	WtW_reg = obj.applyReg(WtW, obj.cfg.regH);
	
	gradW = W*HHt_reg - V*H';
	gradH = WtW_reg*H - W'*V;
end