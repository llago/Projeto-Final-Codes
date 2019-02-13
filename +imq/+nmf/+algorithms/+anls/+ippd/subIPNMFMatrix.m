function [X, gradX, prev] = subIPNMFMatrix(Y, A, X, cfg, values, prev)
	
	maxInnerIt = values.maxInnerIt;
% 	initReg = values.initReg;
	mu = values.mu;
	xi = values.xi;
	tol = values.tol;
	epsFeas = values.epsFeas;
	
	[r, n] = size(X);
	rn = numel(X);
	
	x = X(:);
		
	I = prev.I;
	lambda = rand(rn, 1);
	
	%Get current gradient
	[~, gradX] = cfg.getGradient(Y, A, X);
	gradX = gradX(:);
	

	for innerIt=1:maxInnerIt,
	
		%t = mu*m/eta
		t = mu*rn/(x'*lambda);

		%Computing the search direction

		%Inverse Hessian caculation by BFGS
		s = x - prev.x;

		y = gradX - prev.grad;
		
		gamma = 1/(y'*s);
		
		g = -gradX + (1/t)./(x + eps); %Equation 5.2
		
		B = sparse((I-gamma*s*y') * prev.B * (I-gamma*(y*s')) + gamma*(s*s')); % Eq. 5.6
		
		Hinv = B+ diag(1/(lambda.*x));
		

		% Equations 5.7
		dx = (Hinv)*g;
		dlambda = -lambda - (lambda./(x + eps)).*dx + (1/t)*(1./(x + eps)); % Eq. 5.1

		%Backtracking line search
		ax = -(x./dx)';
		bx = -(lambda./(dlambda))';

		%Step size
		s = xi*min([1,ax(dx < 0), bx(dlambda < 0)]);

		%Save previous values
		prev.grad = gradX;
		prev.x = x;
		prev.B = B;
		
		%Update
		x = x + s*dx;
		lambda = lambda + s*dlambda;
		
		%Calculating new gradient
		X = reshape(x, r, n);
		[~,gradX] = cfg.getGradient(Y, A, X);
		gradX = gradX(:);

		%Verifying dua residual
		rdual = gradX - lambda;

		%end of backtrack line search
		%if norm(rdual) < eps && eta < eps
		if norm(rdual) <= epsFeas && x'*lambda < tol,
			break;
		end
	end
	
	gradX = reshape(gradX, r, n);
end