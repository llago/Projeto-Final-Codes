function [ver] = iterLogger(ver, cfg, val, W, H, prev_W, prev_H)
	ver.tolH = val.tolH;
	ver.tolW = val.tolW;
	ver.iterW = val.iterW;
	ver.iterH = val.iterH;
end