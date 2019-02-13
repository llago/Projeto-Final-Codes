function [W,H,gradW,gradH,value] = solver(A,W,H,iter,cfg,value)
    WtW_reg = cfg.cost.applyReg(value.WtW,cfg.regH);
    ow = 0;
    suc_H = zeros(1,size(H,2));
    numChol_H = zeros(1,size(H,2));
    for i=1:size(H,2)
        [H(:,i),temp,suc_H(i),numChol_H(i)] = imq.nmf.algorithms.anls.asgivens.nnls1_asgivens(WtW_reg,value.WtA(:,i),ow,1,H(:,i));
    end

    suc_W = zeros(1,size(W,1));
    numChol_W = zeros(1,size(W,1));

	
    HHt_reg = cfg.cost.applyReg(H*H',cfg.regW);
	
% 	any(eig(HHt_reg)==0);
	
    HAt = H*A';
    Wt = W';
    gradWt = zeros(size(Wt));
    for i=1:size(W,1)
		
        [Wt(:,i),gradWt(:,i),suc_W(i),numChol_W(i)] = imq.nmf.algorithms.anls.asgivens.nnls1_asgivens(HHt_reg,HAt(:,i),ow,1,Wt(:,i));
		
    end
    W = Wt';

    value.WtA = W'*A;
    value.WtW = W'*W;

    if cfg.trackGrad
        gradW = gradWt'; 
        gradH = cfg.cost.getGradientOne(value.WtW,value.WtA,H,cfg.regH);
    else
        gradW = 0; gradH =0;
    end

    value(1).numChol_W = sum(numChol_W);
    value.numChol_H = sum(numChol_H);
    value.suc_W = any(suc_W);
    value.suc_H = any(suc_H);
end