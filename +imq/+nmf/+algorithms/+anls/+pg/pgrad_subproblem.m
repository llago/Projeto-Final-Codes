function [X, gradX, iter] = pgrad_subproblem(Y, A, X, tol, maxInner, maxSearchSteps, eta, beta, sigma)
	% function [X, gradX, iter] = pgrad_subproblem(Y, A, X, tol, maxIter)
	%
	% Project Gradient Method based on Armijo Update Rule
	
	% Inputs: (arguments in [.] are optional)
	%	Y - matriz de dados m por n
	%	A - matriz fixa m por k
	%	X - matriz com valor inicial k por n
	%	tol - Tolerância pro critério de parada das iterações internas
	%	maxInner - número máximo de iterações
	%
	% Outputs:
	%	X - matriz estimada
	%	gradX - gradiente de X
	%	iter - iteração final
	%
	% Last Modified on 02/2016
	%
	% Implementation based on C. J. C. Lin codes
	%
	%
	% Written by Igor Quintanilha
	%            Universidade Federal do Rio de Janeiro
	%            Escola Politécnica
	%            Departamento de Engenharia Eletrônica
	%            E-mail: igormq@poli.ufrj.br
	%
	%
	% Reference:
	%	[1] C.-J. C. Lin, "Projected gradient methods for nonnegative matrix
	%		factorization", Neural computation, vol. 19, no 10, p. 2756?2779,
	%		out. 2007.
	
	AtY = A'*Y;
	AtA = A'*A;
	
	for iter=1:maxInner,
		
		gradX = AtA*X - AtY;
		
		projGrad = imq.nmf.utils.projectedGradient(X, gradX);
		if norm(projGrad) < tol,
			break;
		end
		
		% search step size
		for step=1:maxSearchSteps,
			
			Xn = max(X - eta*gradX, 0); %Projected gradient 
			
			Delta = Xn-X;
			
			dQd = sum(sum((AtA*Delta).*Delta)); %Quadratic form
			
			condEta = (1-sigma)*gradX(:)'*Delta(:) + 0.5*dQd <= 0; %Equation 4.3
			
			if step == 1,
				decEta = ~condEta; Xp = X;
			end
			
			if decEta,
				if condEta,
					X = Xn; break;
				else
					eta = eta * beta;
				end
			else
				if ~condEta || isequal(Xp, Xn),
					X = Xp; break;
				else
					eta = eta/beta; Xp = Xn;
				end
			end
		end
	end