function [W,H,par,val,ver] = init(A,W,H,par)
    ver = struct([]);

    val.WtA = W'*A;
    val.WtW = W'*W;
end