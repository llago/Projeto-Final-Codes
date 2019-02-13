function [grad] = modifyGradient(obj, grad,X,reg)
    if reg(1) > 0
        grad = grad + 2 * reg(1) * X;
    end
    if reg(2) > 0
        grad = grad + 2 * reg(2) * ones(obj.cfg.k,obj.cfg.k) * X;
    end
end