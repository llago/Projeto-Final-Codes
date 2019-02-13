function [W,H,par,val,ver] = initializer(A,W,H,par)
    [W,H,par,val,ver] = imq.nmf.algorithms.anls.bpp.init(A,W,H,par);
end