% 'anls_asgivens': ANLS with Active Set Method and Givens Updating
% See nnls1_asgivens.m for reference and details.

function [W,H,par,val,ver] = init(A,W,H,par)
    H = zeros(size(H));

    ver.turnZr_W  = 0;
    ver.turnZr_H  = 0;
    ver.turnNz_W  = 0;
    ver.turnNz_H  = 0;
    ver.numChol_W = 0;
    ver.numChol_H = 0;
    ver.suc_W     = 0;
    ver.suc_H     = 0;

    val(1).WtA = W'*A;
    val.WtW = W'*W;
end