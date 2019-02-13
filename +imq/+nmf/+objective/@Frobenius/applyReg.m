function AtA = applyReg(obj, AtA, reg)
	k = obj.cfg.k;
    % Frobenius norm regularization
    if reg(1) > 0
        AtA = AtA + 2 * reg(1) * eye(k);
    end
    % L1-norm regularization
    if reg(2) > 0
        AtA = AtA + 2 * reg(2) * ones(k,k);
    end
end