function [ver] = logger(ver,cfg,val,W,H,prevW,prevH)
    if cfg.trackPrev
        ver.turnZero_W    = length(find( (prevW>0) & (W==0) ))/(cfg.m*cfg.k);
        ver.turnZero_H    = length(find( (prevH>0) & (H==0) ))/(cfg.n*cfg.k);
        ver.turnNonZero_W    = length(find( (prevW==0) & (W>0) ))/(cfg.m*cfg.k);
        ver.turnNonZero_H    = length(find( (prevH==0) & (H>0) ))/(cfg.n*cfg.k);
    end
    ver.numChol_W   = val.numChol_W;
    ver.numChol_H   = val.numChol_H;
    ver.numEq_W     = val.numEq_W;
    ver.numEq_H     = val.numEq_H;
    ver.suc_W       = val.suc_W;
    ver.suc_H       = val.suc_H;
end