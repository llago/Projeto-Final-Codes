classdef Frobenius < imq.nmf.objective.Default
   methods
      val = objective(obj, V, W, H)
      % Return objective value
      [gradW, gradH] = gradient(obj, V, W, H)
      % Return gradient value
      hessian(obj, V, W, H)
      % Return hessian value
   end
   
   methods
	   val = applyReg(obj, XtX, reg)
	   grad = getGradientOne(obj, AtA,AtB,X,reg)
	   grad = modifyGradient(obj, grad,X,reg)
   end
end 