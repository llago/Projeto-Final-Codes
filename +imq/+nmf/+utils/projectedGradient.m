function pojectedGradientX = projectedGradient(X, gradX)
    pojectedGradientX = gradX(gradX < 0 | X > 0);
end