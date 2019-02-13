function [xResult,ser,tElapsed,dist] = RTISI_LSEE(X_MSTFT,L,S,w,faseZero,nroIt,varargin)
%Prototipos possiveis:
%
%   [xResult,ser,tElapsed,dist] = RTISI(X_MSTFT,L,S,janela,nroIt)
%   [xResult,ser,tElapsed,dist] = RTISI(X_MSTFT,L,S,janela,nroIt,faseInicial)
%   
%Implementacao o metodo RTISI(Real-Time Iterative Spectrogram Inversion)
%tal como descrito no artigo "Real-Time Signal Estimation From Modified
%Short-Time Fourier Transform Magnitude Spectra" de X.Zhu,G.T.Beauregard e
%L.L.Wyse.
%
%Argumentos de entrada:
%
%X_MSTFT - STFT modificada a partir da qual se realiza a estimativa do
%sinal
%
%L - comprimento da janela
%
%S - tamanho do passo entre as janelas
%
%w - vetor de L amostras da janela de analise.
%
%faseZero - utiliza-se o valor 1 caso se queira utilizar o janelamento de
%fase zero na obtencao das fases estimadas, durante a estimação, para a STFT modificada ou 0 caso contrário.

%nroIt - nro de iteracoes realizadas na estimativa de cada frame.
%
%faseInicial - vetor de valores de fase que serao atribuidos
%inicialmente ao primeiro quadro do sinal.
%
%Argumentos de saida:
%
%xResult - Sequencia real estimada ao final do processo iterativo.
%
%ser - medida da razao sinal-erro proposta no artigo.
%
%tElapsed - tempo gasto para a execucao do metodo.
%
%dist - metrica definida na referencia [1] do artigo acima.
%
%Autores: Carlos Vinicius Caldas Campos e Renan Mariano Almeida

tInit=tic;%Inicio da cronometragem do tempo de execucao

[nroPtsFFT,nroFrames]=size(X_MSTFT);

X_MSTFTM=abs(X_MSTFT);

if (size(varargin,1)==1)

    x_aux=real(ifft(X_MSTFTM(:,1).*exp(1i*varargin{1})));
    
    if (faseZero)
    
            %Rearrumando as amostras do janelamento de fase zero
            xFrameAtual=[x_aux(ceil((nroPtsFFT-L/2+1)):nroPtsFFT);x_aux(1:floor((L+1)/2))];

    else
    
            xFrameAtual=x_aux(1:L);
    
    end
    
else
    
    x_aux=real(ifft(X_MSTFTM(:,1)));
    xFrameAtual=x_aux(1:L);
    
end

%xFrameAtual=zeros(L,1);

xResult_Parcial=zeros(L,nroFrames);

w=w(:);

for f=1:nroFrames
    
    i=0;
    X_MSTFTM_atual=X_MSTFTM(:,f);
    [xParcial,den]=pre_LSEE_RTISI(w,xResult_Parcial,L,S,f);
    
    while(1)
        
        xFrameAtual=LSEE_RTISI(w,den,xFrameAtual,L,S,xParcial);
        
        if(i<nroIt)
        
            if(faseZero)%Opta entre usar ou nao o janelamento de fase zero

                xFrameAtual_aux=[xFrameAtual(ceil((L-1)/2+1):end);zeros(nroPtsFFT-L,1);xFrameAtual(1:floor(L/2),f)];%Janelamento de fase zero

            else

                xFrameAtual_aux=xFrameAtual;

            end%if(faseZero)

            XFrameAtual=fft(xFrameAtual_aux,nroPtsFFT);
            %faseFrame=atan2(imag(XFrameAtual),real(XFrameAtual));
            %x_aux=real(ifft(X_MSTFTM(:,f).*exp(1i*faseFrame)));
            XFrameAtual(XFrameAtual==0)=1;%Substituindo os valores 0 do vetor XFrameAtual para poder efetuar a divisao da linha seguinte
            %x_aux=real(ifft(X_MSTFTM(:,f).*(XFrameAtual./abs(XFrameAtual))));
            x_aux=real(ifft((X_MSTFTM_atual.*XFrameAtual)./abs(XFrameAtual)));
            %x_aux=real(ifft((X_MSTFTM(:,f).*XFrameAtual)./abs(XFrameAtual)));
            if (faseZero)

                %Rearrumando as amostras do janelamento de fase zero
                xFrameAtual=[x_aux(ceil((nroPtsFFT-L/2+1)):nroPtsFFT);x_aux(1:floor((L+1)/2))];

            else

                xFrameAtual=x_aux(1:L);

            end
        
        else
            
            break;
            
        end
        
    i=i+1;    
    
    end%for i=1:nroIt+1
    
    xResult_Parcial(:,f)=xFrameAtual;
    xFrameAtual=zeros(L,1);
    
end%for f=1:nroFrames

xResult=OA(w,xResult_Parcial,L,S,nroFrames);
[~,X_mod]=STFT(xResult,nroPtsFFT,L,S,w,0);
dist=calcDist(X_mod,X_MSTFTM,L);
ser=calcSER(X_mod,X_MSTFTM);
tElapsed=toc(tInit);

end%RTISI

function [xParcial,den]=pre_LSEE_RTISI(w,xFrames,L,S,frameAtual)
%Calculo da contribuicao dos frames anteriores na formula do LSEE
%do frame atual. Calculado uma soh vez pois nao muda ao longo das iteracoes.
    
den=zeros(L-S,1);
xParcial=zeros(L-S,1);

for l=(1:L-S)
       
        den_aux=0;
        num=0;
        f=max(ceil(((l-L)/S+(frameAtual-1))),0);%==max(l+(frameAtual-1))*S-L)/S,0)
        
        while (f<frameAtual-1)
            
            num= num +  w(l+(frameAtual-(f+1))*S)*xFrames(l+(frameAtual-(f+1))*S,f+1);
            den_aux= den_aux + w(l+(frameAtual-(f+1))*S)^2;
            f=f+1;
            
        end%while (f<frameAtual-1)
        
        den(l)= den_aux + w(l)^2;
        
        xParcial(l,1)=num;
        
end%for

end%OA_RTISI

function [xFrameAtual_saida]=LSEE_RTISI(w,den,xFrameAtual_entrada,L,S,xParcial)
%Overlap and add que para estimar as amostras de um frame leva em conta
%apenas as amostras de frames anteriores e do atual

xFrameAtual_saida(1:(L-S),1)=w(1:L-S).*(xParcial+w(1:L-S).*xFrameAtual_entrada(1:L-S))./den;
xFrameAtual_saida((L-S+1):L,1)=xFrameAtual_entrada(L-S+1:L);
        
end%for

function [xResult]=OA(w,xFrames,L,S,nroFrames)
%Overlap and Add convencional

T=((nroFrames-1)*S+L);%nro Total de amostras

xResult=zeros(T,1);

for l=1:T
       
        num=0;
        den=0;
        f=max(ceil((l-L)/S),0);
        
        while((f<=(l-1)/S)&&(f<nroFrames))
            
            num= num + xFrames(l-f*S,f+1);
            den= den + w(l-f*S);
            f=f+1;
            
        end%while
        
        xResult(l,1)=num/den;
        
end%for

end%OA

function [dist]=calcDist(X_mod,X_MSTFTM,L)
%Calcula a distancia definida na formula (14)

dist=sum(sum((X_mod-X_MSTFTM).^2))/(2*pi*L);

end

function [X_fase,X_mod]=STFT(x,nroPtsFFT,L,S,w,faseZero)
%Funcao que efetua a STFT de um sinal utilizando uma certa janela w com
%janelamento de fase zero

T=length(x);
F=ceil((T-L)/S+1);%nro de frames de forma a abrangermos todas as amostras com os L e S dados.
X=zeros(nroPtsFFT,F);
x=x(:);


for f=(0:F-1)
   
    x_janelado=x((1:L)+f*S).*w;
    if(faseZero)
    
        x_aux=[x_janelado(ceil((L-1)/2+1):end);zeros(nroPtsFFT-L,1);x_janelado(1:floor(L/2))];%Janelamento de fase zero
        X(:,f+1)=fft(x_aux,nroPtsFFT);
    
    else
        
        X(:,f+1)=fft(x_janelado,nroPtsFFT);%Sem janelamento de fase zero
    
    end%if(faseZero)

end%for f=(0:F-1)

X_mod=abs(X);
X_fase=atan2(imag(X),real(X));

end%STFT

function [ser] = calcSER(X_mod,X_MSTFTM)
%Calcula a razao sinal-erro (SER - signal-to-error ratio)

num = sum(sum(X_MSTFTM.^2))/(2*pi);
den = sum(sum((X_mod-X_MSTFTM).^2))/(2*pi);
ser = 10*log10(num/den);

end