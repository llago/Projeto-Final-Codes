function history = formatHistory(V,W,H,prevW,prevH,init,cfg,iter,elapsed,gradW,gradH)
% function history = formatHistory(A,W,H,prevW,prevH,init,cfg,iter,elapsed,gradW,gradH)
%
% Format the state of iteration for debugging purposes
%
%
% Inputs: (arguments in [.] are optional)
%	V: V matrix of NMF
%	W: basis matrix of NMF
%	H: activation matrix of NMF
%	prevW: last W matrix
%	prevH: last H matrix
%	init: initial state of algorithm
%	cfg: configuration of algorithm
%	iter: current index of iteration
%	gradW: gradient of W
%	gradH: gradient of H
%
% Outputs:
%	history: the history formatted as a struct
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
    history.iter				= iter;
    history.elapsed				= elapsed;

    history.objective			= cfg.getObjective(V, W, H);
    history.normW				= norm(W,'fro');
    history.normH				= norm(H,'fro');
	
	if cfg.trackPrev
        history.relChangeW  = norm(W-prevW,'fro')/init.normW;
        history.relChangeH  = norm(H-prevH,'fro')/init.normH;
	end
	
	if cfg.trackGrad
        history.relNormPGradW	= norm(imq.nmf.utils.projectedGradient(W,gradW),'fro')/init.normGradW;
        history.relNormPGradH	= norm(imq.nmf.utils.projectedGradient(H,gradH),'fro')/init.normGradH;
        history.SCNMPGRAD		= imq.nmf.stoppingCriteria.main(1,V,W,H,cfg,gradW,gradH)/init.SCNMPGRAD;
        history.SCPGRAD			= imq.nmf.stoppingCriteria.main(2,V,W,H,cfg,gradW,gradH)/init.SCPGRAD;
        history.SCDELTA			= imq.nmf.stoppingCriteria.main(3,V,W,H,cfg,gradW,gradH)/init.SCDELTA; 
	end
	
    history.WDensity     = length(find(W>0))/(cfg.m*cfg.k);
    history.HDensity     = length(find(H>0))/(cfg.n*cfg.k);
end