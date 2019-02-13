function [DH, MoT, hits] = HFC(X, p, threshold)
% function [DH] = HFC(X, threshold)
%
% High Frequency Content
%
% Inputs: (arguments in [.] are optional)
%
% Outputs:
%	MoT -	Measure of Transient
%			Condition of detection: MoT > T_D,ED (Detection Threshold (for
%			the Energy Distribution method))
%	D_H -	Detection function (High Frequency Content)
%
% Last Modified on 06/2015
%
% This operation emphasises energy changes occuring in the higher part of 
% the spectrum, especially the burst-like broadband noise, usually 
% associated with percussive onsets
%
%	D_H = sum_{k=2}^{N} k |X_k[n]|^2
%	Where, X_k[n] is the kth bin of the STFT taken at time n. Usually the
%	lowest bin were discarded to avoid unwanted bias from the DC component
%	MoT = D_H_n / D_H_{n-1} *D_H_{n} / E_n
%	Were E_n = sum_k |X_k[n]|^2 is the energy function for the frame n
%	Note: E_n and D_H_{n-1} are constrained to have a minimum value of one,
%	to avoid potential division by zero
%
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
%	[1] BELLO, Juan Pablo et al. A tutorial on onset detection in music
%		signals. Speech and Audio Processing, IEEE Transactions on, v. 13, n. 
%		5, p. 1035-1047, 2005.
%	[2] BROSSIER, Paul M. Automatic annotation of musical audio for
%		interactive applications. 2006. Tese de Doutorado. 
%		Queen Mary, University of London.
%		Journal of Global Optimization, 58(2), pp. 285-319, 2014.
%	[3] MASRI, Paul. Computer modelling of sound for transformation and
%		synthesis of musical signals. 1996. Tese de Doutorado. 
%		University of Bristol.
%

	[K, N] = size(X);
	
	W = (1:K)';
	W(1) = 0; %REMOVING DC
	
% 	
% 	W = fliplr((1:K))';
% 	W(end) = 0; %REMOVING DC
% 	
	
	DH = mean(repmat(W, 1, N).^p .* abs(X).^2,1);
	
	if nargout > 1
		MoT = DH / max([0 DH(k_i:(end-1))],1) .* (DH ./ max(sum(abs(X(k_i:K, :)).^2, 1), 1));

		hits = MoT > threshold;
	end
end