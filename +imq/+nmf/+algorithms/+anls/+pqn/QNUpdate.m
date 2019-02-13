function [X, gradX, condTimes] = QNUpdate(Y, A, X, k, val)

% 	h = A'*A;
% 	gradX = A'*Y - h*X;
% 	
% 	%tic;
% 	H = kron(val.T,-h);
% 	%toc;
% 	
% 	condTimes = 0;
% 	
% 	%tic;
% 	lambda = val.lambdaInit;
% 	while condest(H) > 1E7
% 		lambda = 10*lambda;
% 		H = H + lambda*val.rT;
% 		condTimes = condTimes + 1;
% 	end
% 	%toc;
% 	
% 	%tic;
% 	[W,R] = qr(H,gradX(:));
% 	%toc;
% 	
% 	%tic;
% 	X(:) = X(:) - val.gamma*R\W;
% 	%toc;
% 	
% 	%Projected
% 	X(X <= 0) = 1e2*eps;

	AtA = A'*A;
	AtA = AtA + (1E-12 + 1E8*exp(-k/tau))*val.I;  % Levenberg-Marquardt regularization
	gradX = AtA*X - A'*Y;  % Gradient
	X = X - .9*pinv(AtA)*gradX;
	X(X <= 0) = 1E2*eps;
	
	
end