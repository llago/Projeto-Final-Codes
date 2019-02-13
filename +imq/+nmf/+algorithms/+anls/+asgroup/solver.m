function [W,H,gradW,gradH,value] = solver(A,W,H,iter,cfg,value)
    WtW_reg = cfg.cost.applyReg(value.WtW,cfg.regH);
    ow = 0;
    [H,temp,suc_H,numChol_H,numEq_H] = imq.nmf.algorithms.anls.asgroup.nnlsm_activeset(WtW_reg,value.WtA,ow,1,H);

    HHt_reg = cfg.cost.applyReg(H*H',cfg.regW);
    [W,gradW,suc_W,numChol_W,numEq_W] = imq.nmf.algorithms.anls.asgroup.nnlsm_activeset(HHt_reg,H*A',ow,1,W');
    W = W';

    value.WtA = W'*A;
    value.WtW = W'*W;

    if cfg.trackGrad
        gradW = gradW'; 
		gradH = cfg.cost.getGradientOne(value.WtW,value.WtA,H,cfg.regH);
    else
        gradW = 0; gradH =0;
    end

    value(1).numChol_W = numChol_W;
    value.numChol_H = numChol_H;
    value.numEq_W = numEq_W;
    value.numEq_H = numEq_H;
    value.suc_W = suc_W;
    value.suc_H = suc_H;
end