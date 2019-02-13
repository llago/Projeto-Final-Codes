function [X, gradX, condTimes] = QNUpdateX(Y, A, X, val)

	h = A'*A;
	gradX = A'*Y - h*X;
	
	%tic;
	H = kron(val.T,-h);
	%toc;
	
	condTimes = 0;
	
	%tic;
	lambda = val.lambdaInit;
	while condest(H) > 1E7
		lambda = 10*lambda;
		H = H + lambda*val.rT;
		condTimes = condTimes + 1;
	end
	%toc;
	
	%tic;
	[W,R] = qr(H,gradX(:));
	%toc;
	
	%tic;
	X(:) = X(:) - val.gamma*R\W;
	%toc;
	
	%Projected
	X(X <= 0) = 1e2*eps;
	
	
end