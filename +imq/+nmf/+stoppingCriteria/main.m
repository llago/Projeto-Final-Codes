function value = main(stopRule,V,W,H,cfg,gradW,gradH)
% function value = main(stopRule,V,W,H,cfg,gradW,gradH)
%
% Stopping Criterias for Nonnegative Matrix Factorization
%
% Inputs: (arguments in [.] are optional)
%	stopRule: 1 - Normalized proj. gradient
%			  2 - Proj. gradient
%			  3 - Delta by H. Kim
%			  otherwise - None
%
% Outputs:
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
    if nargin~=7
        [gradW,gradH] = cfg.getGradient(V,W,H);
    end

    switch stopRule
        case 2
            pGradW = imq.nmf.utils.projectedGradient(W,gradW);
            pGradH = imq.nmf.utils.projectedGradient(H,gradH);
            pGrad = [pGradW(:); pGradH(:)];
            value = norm(pGrad);
        case 1
			pGradW = imq.nmf.utils.projectedGradient(W,gradW);
            pGradH = imq.nmf.utils.projectedGradient(H,gradH);
            pGrad = [pGradW(:); pGradH(:)];
            value = norm(pGrad)/length(pGrad);
        case 3
            resmat=min(H,gradH); resvec=resmat(:);
            resmat=min(W,gradW); resvec=[resvec; resmat(:)]; 
            deltao=norm(resvec,1); %L1-norm
            num_notconv=length(find(abs(resvec)>0));
            value=deltao/num_notconv;
		otherwise
            value = 1e100;
    end
end