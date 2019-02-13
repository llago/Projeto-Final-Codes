function [ver] = iterLogger(ver,cfg,value,W,H,prev_W,prev_H)
    if cfg.trackPrev
        ver.turnZr_W    = length(find( (prev_W>0) & (W==0) ))/(cfg.m*cfg.k);
        ver.turnZr_H    = length(find( (prev_H>0) & (H==0) ))/(cfg.n*cfg.k);
        ver.turnNz_W    = length(find( (prev_W==0) & (W>0) ))/(cfg.m*cfg.k);
        ver.turnNz_H    = length(find( (prev_H==0) & (H>0) ))/(cfg.n*cfg.k);
    end
    ver.numChol_W   = value.numChol_W;
    ver.numChol_H   = value.numChol_H;
    ver.suc_W       = value.suc_W;
    ver.suc_H       = value.suc_H;
end