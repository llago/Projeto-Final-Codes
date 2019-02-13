function [ver] = iterLogger(ver,par,val,W,H,prev_W,prev_H)
    ver = imq.nmf.algorithms.anls.bpp.logger(ver,par,val,W,H,prev_W,prev_H);
end