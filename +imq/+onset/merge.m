function y = merge(a,b)
	y = zeros(max(length(a), length(b)), 1);
	
	y(1:length(a)) = 0.9*a(:);
	y(1:length(b)) = y(1:length(b)) + 0.5*b(:);
    y = imq.reconstruction.normaliza(y, 0);
end