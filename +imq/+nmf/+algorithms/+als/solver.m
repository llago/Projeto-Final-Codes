function [W,H,gradW,gradH,values] = solver(A,W,H,iter,cfg,values)
    WtW_reg = cfg.cost.applyReg(values.WtW,cfg.regH);
    H = WtW_reg\values.WtA;
    H(H<0)=0;

    AHt = A*H';
    HHt_reg = cfg.cost.applyReg(H*H',cfg.regW);
    Wt = HHt_reg\AHt'; W=Wt';
    W(W<0)=0;

    % normalize : necessary for ALS
    [W,H,weights] = imq.nmf.utils.normalize(W,H, 2);
    D = diag(weights);

    values.WtA = W'*A;
    values.WtW = W'*W;
    AHt = AHt*D;
    HHt_reg = D*HHt_reg*D;

    if cfg.trackGrad
        gradW = W*HHt_reg - AHt;
        gradH = cfg.cost.getGradientOne(values.WtW,values.WtA,H,cfg.regH);
    else
        gradH = 0; gradW = 0;
    end
end