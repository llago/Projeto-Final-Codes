function history = saveHistory(index,params,history)
% function history = saveHistory(idx,params,history)
%
% Save params key value in struct format under an index
%
%
% Inputs: (arguments in [.] are optional)
%	index: index of history
%	:
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
    fldnames = fieldnames(params);

    for i=1:length(fldnames)
        flname = fldnames{i};
        history.(flname)(index) = params.(flname);
    end
end