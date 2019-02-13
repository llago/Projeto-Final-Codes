function [bool] = method2(errors, threshold)
	bool = (errors(end-1) - errors(end))/(errors(1) - errors(end)) < threshold;
end