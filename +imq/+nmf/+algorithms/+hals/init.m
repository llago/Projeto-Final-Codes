function [W,H,par,val,ver] = init(V,W,H,par)
    [W,H]=imq.nmf.utils.normalize(W,H,2);

    val = struct([]);
    ver = struct([]);
end