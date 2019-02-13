function [A, gradA] = QNUpdateA(Y, A, X, k, val)
	XXt = X*X';
	XXt = XXt + (1E-12 + 1E8*exp(-k))*val.I;  % Levenberg-Marquardt regularization
	gradA = A*XXt - Y*X';  % Gradient
	A = A - .9*gradA*pinv(XXt);
	A(A <= 0) = 1E2*eps;
	A = A*diag(1./sum(A,1));
end