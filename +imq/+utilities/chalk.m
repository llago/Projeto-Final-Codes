function chalk(str,reset)
% Write erasable text to screen
%
% function chalk(str,reset)
%
% Inputs
% str - string to print (add new line character if needed)
% reset - reset previous string length to zero
%
% Rob Campbell - July 2010
%
% See: demo_chalk


persistent previousStrLength ; 


if isempty(previousStrLength)
    previousStrLength=0;
end

if nargin==2 & reset==1
    previousStrLength=0;
end


%Wipe the previous string
if previousStrLength>0
    fprintf(repmat('\b',1,previousStrLength))
    fprintf(repmat(' ' ,1,previousStrLength))
    fprintf(repmat('\b',1,previousStrLength))
end



fprintf(str) %write the new string to screen

previousStrLength=length(str); %update the counter
