function [bool] = method1(errors, threshold)
	bool = (errors(end) - errors(end-2)) < threshold;
end