function value = initCriteria(stopRule,V,W,H,cfg,gradW,gradH)
% function value = initCriteria(stopRule,V,W,H,cfg,gradW,gradH)
%
%
% Inputs: (arguments in [.] are optional)
%	stopRule: 1 - Normalized proj. gradient
%			  2 - Proj. gradient
%			  3 - Delta by H. Kim
%			  otherwise - None
%
% Outputs:
%	value
%
% Last Modified on 09/2015
%	
%
% Written by Igor Quintanilha
%            Universidade Federal do Rio de Janeiro
%            Escola Politécnica
%            Departamento de Engenharia Eletrônica
%            E-mail: igormq@poli.ufrj.br
%
% based on Jingu Kim's (jingu.kim@gmail.com)) code 
%            School of Computational Science and Engineering,
%            Georgia Institute of Technology
%
%
% Reference:
%	[1] H. Kim e H. Park, "Sparse non-negative matrix factorizations 
%		via alternating non-negativity-constrained least squares for 
%		microarray data analysis", Bioinformatics, vol. 23, no 12, 
%		p. 1495?1502, jun. 2007.
%
	value = stoppingCriteria(stopRule,V,W,H,cfg,gradW,gradH);
end