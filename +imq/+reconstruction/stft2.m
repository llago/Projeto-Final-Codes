function [X,x_p]=STFT2(x,nroPtsFFT,L,S,w,faseZero)
%Funcao que efetua a STFT de um sinal utilizando uma certa janela w com
%janelamento de fase zero

T=length(x);
F1=ceil((T-L)/S+1);%nro de frames de forma a abrangermos todas as amostras com os L e S dados.
F2=floor((L-1)/S);%frames que abrangem amostras antes da amostra de indice 1 do sinal
F=F1+F2;%nro total de frames
X=zeros(nroPtsFFT,F);

x_p=[zeros(F2*S,1);x;zeros(L+(F1-1)*S-T,1)];%Completa o sinal com zeros para ser coerente com as medidas da janela e o numero de frames coerentes com F1 e F2

if (faseZero)
    
        for f=(0:F-1)
    
        x_janelado=x_p((1:L)+f*S).*w;
        x_aux=[x_janelado(ceil((L-1)/2+1):end);zeros(nroPtsFFT-L,1);x_janelado(1:floor(L/2))];%Janelamento de fase zero
        X(:,f+1)=fft(x_aux);
        %cada frame eh janelado com fase zero
        
        end
        
else
    
    for f=(0:F-1)
        
        x_janelado=x_p((1:L)+f*S).*w;
        X(:,f+1)=fft(x_janelado,nroPtsFFT);
        
     end
        
end

end

