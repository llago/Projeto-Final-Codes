function [xResult,ser,tElapsed,nroIt,vetorDist,vetorDistPercent]= GL_limiar(X_MSTFT,L,S,w,faseZero,metodo,varargin)
%Prototipos possiveis:
%
%
%[xResult,vetorDist] =GL_limiar(X_MSTFT,L,S,janela,faseZero,metodo)
%[xResult,vetorDist]=GL_limiar(X_MSTFT,L,S,janela,faseZero,metodo,limiar)
%[xResult,vetorDist]=GL_limiar(X_MSTFT,L,S,janela,faseZero,metodo,X_fase)
%[xResult,vetorDist]=GL_limiar(X_MSTFT,L,S,janela,faseZero,metodo,X_fase,limiar)
%
%   A funcao implementa o metodo descrito no artigo "Signal Estimation from
%   Modified Short-Time Fourier Transform" de autoria de D.W.Griffin e
%   J.S.Lim utilizando a variacao percentual da medida ser entre duas iteracoes
%   consecutivas como criterio de parada em vez do numero maximo de
%   iteracoes do processo.
%
%Argumentos da funcao:
%
%Entrada:
%
%X_MSTFT - STFT modificada utilizada para estimar o sinal
%
%L - nro de amostras de cada janela
%
%S - deslocamento da janela sobre o sinal a cada frame
%
%janela - String que especifica a janela a ser usada no
%processo('Retangular','MHamming' ou 'MHanning') onde o M antes do nome das
%janelas significa "modificado", pois estas janelas tem periodo L ao inves
%do periodo L-1 das janelas originais  e possuem um coeficiente multiplicativo
%de forma que o somatorio do denominador da formula (6) seja igual a 1.
%
%faseZero - argumento que deve ser 0 caso nao se deseje usar janelamento de
%fase zero no processo iterativo ou 1 caso contrario
%
%metodo - String que especifica a formula da atualizacao a ser
%utilizada no processo iterativo('OA'- baseada no overlap-add ou 'LSEE'-baseada na minimizacao da distancia
%definida no artigo).

%limiar - define o limiar para a parada das iteracoes do algoritmo. Este
%limiar consiste na variacao percentual minima da medida de distancia entre
%duas iteracoes de forma que o algoritmo continue a ser executado. Caso
%nao seja especificado, seu valor padrao eh 0,5%
%
%X_fase - matriz de mesmas dimensoes de X_MSTFT que pode ser usada para
%inicializar o algoritmo iterativo atribuindo uma fase para o espectro de
%modulo de X_MSTFT fornecida.
%
%Saida:
%
%xResult - sinal real resultante
%
%ser - vetor dos valores da medida da razao sinal-erro proposta no artigo
%"Real-Time Signal Estimation From Modified Short-Time Fourier Transform
%Magnitude Spectra" de X.Zhu,G.T.Beauregard e L.L.Wyse.
%
%vetorDist - vetor das distancias obtidas pela metrica da equacao (14) do
%artigo a cada iteracao do algoritmo.
%
%vetorDistPercent - vetor da variacao percentual de vetorDist a cada
%iteracao. Obs.: vetorDistPercent(i) corresponde a variacao da iteracao i
%para a iteracao i+1 do algoritmo.
%
%
%Autores: Renan Mariano Almeida e Carlos Vinicius Caldas Campos
%
%Modificacoes:
%11/3/2010 - Primeira versao
%
%See also: GL_it
tInit=tic;%Inicio da cronometragem de tempo de execucao

[nroPtsFFT,nroFrames]=size(X_MSTFT);

X_MSTFTM=abs(X_MSTFT);

x_Parcial=zeros(L,nroFrames);

limiarPadrao=0.5;%Valor atribuido ao limiar caso este nao seja especificado

switch(nargin)
    case 6
        
        x_Parcial2=real(ifft(X_MSTFTM));
        vetorLimiares=limiarPadrao;
        
    %fim do case 6
        
    case 7
        if((size(varargin{1},1)~=nroPtsFFT)&&((size(varargin{1},1)==1)||((size(varargin{1},2)==1))))
            
            vetorLimiares=varargin{1};
            x_Parcial2=real(ifft(X_MSTFTM));
            
        else
            
            X_fase(:,:)=varargin{1};
            x_Parcial2=real(ifft(X_MSTFTM.*exp(1i*X_fase)));
            limiar=limiarPadrao;
            
        end
        
    %fim do case 7    
        
    case 8
        X_fase(:,:)=varargin{1};
        vetorLimiares=varargin{2};
        x_Parcial2=real(ifft(X_MSTFTM.*exp(1i*X_fase)));
        
    %fim do case 8
        

    otherwise
        
        error('Minimo de 6 e maximo de 8 argumentos para a funcao GL_limiar!');
        
end%switch(nargin)

if (faseZero&&((nargin==7)||(nargin==8)))
    
    for f=1:nroFrames

                    %Rearrumando as amostras do janelamento de fase zero
                    x_Parcial(:,f)=[x_Parcial2(ceil((nroPtsFFT-L/2+1)):nroPtsFFT,f);x_Parcial2(1:floor((L+1)/2),f)];

    end%for f=1:nroFrames
    
else
    
    x_Parcial(:,:)=x_Parcial2((1:L),:);
    
end



X_Parcial=zeros(nroPtsFFT,nroFrames);

w=w(:);


switch(metodo)
    
    case 'OA'
        
        i=1;
        condicaoParada=false;
        
        while(~condicaoParada)

            xResult_Parcial=OA_MSTFT(w,x_Parcial(:,:),L,S,nroFrames);
            [X_fase,X_mod]=STFT(xResult_Parcial(:),nroPtsFFT,L,S,w,faseZero);
            vetorDist(i,1)=calcDist(X_mod(:,:),X_MSTFTM,L);
            ser(i,1)=calcSER(X_mod(:,:),X_MSTFTM);
            
            if(i>=2)
                
                vetorDistPercent(i-1,1)=100*(vetorDist(i-1,1)-vetorDist(i,1))/vetorDist(i-1,1);
                
                if(vetorDistPercent(i-1,1)<=limiar) 
                    
                    condicaoParada=true; 
                
                end
                
            end
            
            X_Parcial(:,:)=X_MSTFTM.*exp(1i*X_fase(:,:));
            x_Parcial2(:,:)=real(ifft(X_Parcial(:,:)));

            if (faseZero)%Opta entre usar ou nao o janelamento de fase zero
    
            for f=1:nroFrames

                    %Rearrumando as amostras do janelamento de fase zero
                    x_Parcial(:,f)=[x_Parcial2(ceil((nroPtsFFT-L/2+1)):nroPtsFFT,f);x_Parcial2(1:floor((L+1)/2),f)];

            end%for f=1:nroFrames
    
            else
    
                x_Parcial(:,:)=x_Parcial2((1:L),:);
    
            end
                
        i=i+1;
        
        end%while(~condicaoParada)
        
        xResult=xResult_Parcial;
        
    %fim do case 'OA'
    
    case 'LSEE'   
        
        i=1;
        j=1;
        
        while(1)

            xResult_Parcial=LSEE_MSTFT(w,x_Parcial(:,:),L,S,nroFrames);
            [exp_X_fase,X_mod]=STFT(xResult_Parcial(:),nroPtsFFT,L,S,w,faseZero);
            vetorDist(i,1)=calcDist(X_mod(:,:),X_MSTFTM,L);
            
            if(i>=2)
                
                vetorDistPercent(i-1,1)=100*(vetorDist(i-1,1)-vetorDist(i,1))/vetorDist(i-1,1)
                
                if (vetorDistPercent(i-1,1)<=min(vetorLimiares)) 
                    
                    xResult(:,j)=xResult_Parcial;
                    ser(j,1)=calcSER(X_mod(:,:),X_MSTFTM);
                    tElapsed(j,1)=toc(tInit);
                    nroIt=i;
                    break; 
                    
                else
                    if (vetorDistPercent(i-1,1)<=vetorLimiares(j)) 
                        
                        xResult(:,j)=xResult_Parcial;
                        ser(j,1)=calcSER(X_mod(:,:),X_MSTFTM);
                        tElapsed(j,1)=toc(tInit);
                        j=j+1;
                    end
                end
                
            end
            
            %X_Parcial(:,:)=X_MSTFTM.*exp(1i*X_fase(:,:));
            X_Parcial(:,:)=X_MSTFTM.*exp_X_fase;
            x_Parcial2(:,:)=real(ifft(X_Parcial(:,:)));

            if (faseZero)
    
            for f=1:nroFrames

                    %Rearrumando as amostras do janelamento de fase zero
                    x_Parcial(:,f)=[x_Parcial2(ceil((nroPtsFFT-L/2+1)):nroPtsFFT,f);x_Parcial2(1:floor((L+1)/2),f)];

            end%for f=1:nroFrames
    
            else
    
                x_Parcial(:,:)=x_Parcial2((1:L),:);
    
            end%if(faseZero)
                
        i=i+1;
        end%while(~condicaoParada)
        
    %fim do case 'LSEE'

end%switch(metodo)

end%GL_limiar

function [exp_X_fase,X_mod]=STFT(x,nroPtsFFT,L,S,w,faseZero)
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
%X_fase=atan2(imag(X),real(X));
X(X==0)=eps;%Substituindo os valores 0 do vetor XFrameAtual para poder efetuar a divisao da linha seguinte
exp_X_fase=X./abs(X);

end%STFT

function [xResult]=LSEE_MSTFT(w,x_MSTFT,L,S,nroFrames)
%Implementa a formula de atualizacao (6)utilizando o fato de o denominador
%ser igual a unidade para as janelas que podem ser escolhidas.

T=((nroFrames-1)*S+L);%nro Total de amostras

xResult=zeros(T,1);

for l=1:T
       
        num=0;
        den=0;
        f=max(ceil((l-L)/S),0);
        
        while((f<=(l-1)/S)&&(f<nroFrames))
            
            num=num+w(l-f*S)*x_MSTFT(l-f*S,f+1);
            den= den + (w(l-f*S))^2;%Usar caso a janela usada nao nos leve
            %a ter somatorio de f=-inf ateh +inf de w^2(n-f*S)=1 para todo n
            f=f+1;
            
        end%while
        
        xResult(l,1)=num/den;
        
end%for
    
end%LSEE_MSTFT


function [xResult]=OA_MSTFT(w,x_MSTFT,L,S,nroFrames)
%Implementa a formula de atualizacao (7)

T=((nroFrames-1)*S+L);%nro Total de amostras

xResult=zeros(T,1);

for l=1:T
       
        num=0;
        den=0;
        f=max(ceil((l-L)/S),0);
        
        while((f<=(l-1)/S)&&(f<nroFrames))
            
            num= num + x_MSTFT(l-f*S,f+1);
            den= den + w(l-f*S);
            f=f+1;
            
        end%while
        
        xResult(l,1)=num/den;
        
end%for

end

function [dist]=calcDist(X_mod,X_MSTFTM,L)
%Calcula a distancia definida na formula (14)

dist=sum(sum((X_mod-X_MSTFTM).^2))/(2*pi*L);

end

function [ser] = calcSER(X_mod,X_MSTFTM)
%Calcula a razao sinal-erro (SER - signal-to-error ratio)

num = sum(sum(X_MSTFTM.^2))/(2*pi);
den = sum(sum((X_mod-X_MSTFTM).^2))/(2*pi);
ser = 10*log10(num/den);

end