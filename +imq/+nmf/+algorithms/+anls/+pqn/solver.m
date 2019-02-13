function [W,H,gradW,gradH,val] = solver(V, W, H, iter, cfg, val)
		
% 	tic;
% 		[H, gradH] = imq.nmf.algorithms.anls.pqn.QNUpdate(V, W, H, iter, val.H);
% % 		toc;
% % 		tic;
% 		[W, gradW] = imq.nmf.algorithms.anls.pqn.QNUpdate(V', H', W', iter, val.W);
% 		W = W'; gradW = gradW';
% 		
% % 		toc;
% 		%l-1 normalization
% 		% [1] A. Cichocki, R. Zdunek, A. H. Phan, e S. Amari, Nonnegative 
% 		% Matrix and Tensor Factorizations, 1o ed. Chichester, 
% 		% UK: John Wiley & Sons, Ltd, 2009. Page 305, section 6.1.4
% 		W = W*diag(1./sum(W,1));

	[m,n] = size(V);
	[~, r] = size(W);

	tau = 50;
	alpha0 = 100;
	alpha_reg = alpha0*exp(-iter/tau);
	
	if isnan(W),
% 		disp('Matrix A is too much ill-conditioned. Restarting...')
		return;
	end
	
	if cond(W) > 1e6,
		alphaH = 1e-6;
	else
		alphaH = 0;
	end
	
	H = max(1e6*eps, pinv(W'*W + alpha_reg + alphaH*val.H.I)*W'*V);
	
	[gradW, hessW] = gradhess(V', H', W');
	[gradH, ~] = gradhess(V, W, H);
	[WA, R] = qr(hessW, gradW(:));
	cond_R = condest(R);
	
	gradW = gradW';
	
	if isinf(cond_R)
% 		disp('Matrix R is singular. Restart is needed...');
		return
	end
	
	W = W - 0.9*reshape(R\WA, r, m)';
	W(W<=0) = 1e2*eps;
	W = bsxfun(@rdivide, W, sum(W,1));
	
	function [gradX, hessX] = gradhess(Y, A, X)
		hA = A'*A + (1e-12 + 1e8*exp(-iter))*val.W.I;
		gradX = hA*X - A'*Y;
		hessX = kron(speye(size(X,2)), hA);
	end
end

