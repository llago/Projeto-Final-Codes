function [grad] = getGradientOne(obj, AtA,AtB,X,reg)
    grad = AtA*X - AtB;
    grad = obj.modifyGradient(grad,X,reg);
end