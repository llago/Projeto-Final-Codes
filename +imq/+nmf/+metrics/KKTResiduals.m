function [KKTW, KKTH] = KKTResiduals(beta, V, R, W, H)
	KKTW = norm(min(W, (R.^(beta-2) .* (R - V))*H.'), 1) / numel(W);
	KKTH = norm(min(H, W.'*(R.^(beta-2) .* (R - V))), 1) / numel(H);
end