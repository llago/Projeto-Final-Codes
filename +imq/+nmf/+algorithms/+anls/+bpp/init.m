function [W,H,cfg,values,ver] = init(A,W,H,cfg)
    H = zeros(size(H));

    ver.turnZr_W  = 0;
    ver.turnZr_H  = 0;
    ver.turnNz_W  = 0;
    ver.turnNz_H  = 0;
    ver.numChol_W = 0;
    ver.numChol_H = 0;
    ver.numEq_W   = 0;
    ver.numEq_H   = 0;
    ver.suc_W     = 0;
    ver.suc_H     = 0;

    values(1).WtA = W'*A;
    values.WtW = W'*W;
	
	if ischar(cfg.fix.W) && strcmp(cfg.fix.W, 'semi')
		[values.gradW, ~] = cfg.cost.gradient(A, W, H);
	end
end