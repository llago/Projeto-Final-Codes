function [W,H,gradW,gradH,value] = solver(A,W,H,iter,cfg,value)
    epsilon = 1e-16;

    WtW_reg = cfg.cost.applyReg(value.WtW,cfg.regH);
    H = H.*value.WtA./(WtW_reg*H + epsilon);

    HHt_reg = cfg.cost.applyReg(H*H',cfg.regW);
    AHt = A*H';
    W = W.*AHt./(W*HHt_reg + epsilon);

    value.WtA = W'*A;
    value.WtW = W'*W;

    if cfg.trackGrad
        gradW = W*HHt_reg - AHt;
        gradH = cfg.cost.getGradientOne(value.WtW,value.WtA,H,cfg.regH);
    else
        gradH = 0; gradW = 0;
    end
end