function [xResult,ser,tElapsed,vetorDist,vetorDistPercent]= GL_it(X_MSTFT,L,S,vetorItDesejadas,w,faseZero,metodo,varargin)
%Prototipos possiveis: 
%
%[xResult,ser,vetorDist,vetorDistPercent] =GL_it(X_MSTFT,L,S,vetorItDesejadas,janela,faseZero,metodo)
%[xResult,ser,vetorDist,vetorDistPercent]=GL_it(X_MSTFT,L,S,vetorItDesejadas,janela,faseZero,metodo,X_fase)
%
%   A funcao implementa o metodo descrito no artigo "Signal Estimation from
%   Modified Short-Time Fourier Transform" de autoria de D.W.Griffin e
%   J.S.Lim para a estimativa de fase de um sinal do qual eh conhecido
%   apenas seu espectro de modulo da STFT.
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
%vetorItDesejadas - vetor que possue os numeros de iteracoes cujos
%resultados sao devolvidos na variavel xResult. O vetor-resultado
%referente a cada numero de iteracoes sera colocado em uma coluna
%da matriz xResult.
%
%w - vetor de L amostras da janela de analise.
%
%metodo - String que especifica a formula da atualizacao a ser
%utilizada no processo iterativo('OA'- baseada no overlap-add ou 
%'LSEE'-baseada na minimizacao do erro quadratico entre a STFT do sinal
%estimado e a STFT dada, chamada de STFTM no artigo.
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
%iteracao. Obs.: vetorDistPercent(i) corresponde a variacao da medida
%de distancia correspondente a iteracao i para a da iteracao i+1 do
%algoritmo.
%
%
%Autores: Renan Mariano Almeida e Carlos Vinicius Caldas Campos
%
%Modificacoes:
%11/3/2010 - Primeira versao
%
%See also: GL_limiar
%
tInit=tic;%Inicio da cronometragem de tempo de execucao

nromaxIt=max(vetorItDesejadas);

[nroPtsFFT,nroFrames]=size(X_MSTFT);

T=((nroFrames-1)*S+L);

xResult=zeros(T,length(vetorItDesejadas));

X_MSTFTM=abs(X_MSTFT);

x_Parcial=zeros(L,nroFrames);

if(size(varargin,2)==0)
    
    x_Parcial2=real(ifft(X_MSTFTM));
    x_Parcial(:,:)=x_Parcial2((1:L),:);

else
    
    X_fase(:,:)=varargin{1};
    x_Parcial2=real(ifft(X_MSTFTM.*exp(1i*X_fase)));
    
    if (faseZero)
    
        for f=1:nroFrames

                        %Rearrumando as amostras do janelamento de fase zero
                        x_Parcial(:,f)=[x_Parcial2(ceil((nroPtsFFT-L/2+1)):nroPtsFFT,f);x_Parcial2(1:floor((L+1)/2),f)];

        end%for f=1:nroFrames
    
    else
    
        x_Parcial(:,:)=x_Parcial2((1:L),:);
    
    end
    
end

X_Parcial=zeros(nroPtsFFT,nroFrames);

vetorDist=zeros(nromaxIt,1);

ser=zeros(length(vetorItDesejadas),1);

tElapsed=zeros(length(vetorItDesejadas),1);

vetorDistPercent=zeros(nromaxIt-1,1);

w=w(:);

ItDesejada=1;

switch(metodo)
    
    case 'OA'
        
        for i=1:(nromaxIt+1)%o +1 eh devido a i=1 correponder a inicializacao do algoritmo

            xResult_Parcial=OA_MSTFT(w,x_Parcial(:,:),L,S,nroFrames);
            [exp_X_fase,X_mod]=STFT(xResult_Parcial(:),nroPtsFFT,L,S,w,faseZero);
            vetorDist(i,1)=calcDist(X_mod(:,:),X_MSTFTM,L);
            ser(i,1)=calcSER(X_mod(:,:),X_MSTFTM);
            
            if(i>=2)
                
                vetorDistPercent(i-1,1)=100*(vetorDist(i-1,1)-vetorDist(i,1))/vetorDist(i-1,1);
            
            end
            
            %X_Parcial(:,:)=X_MSTFTM.*exp(1i*X_fase(:,:));
            X_Parcial(:,:)=X_MSTFTM.*exp_X_fase;
            x_Parcial2(:,:)=real(ifft(X_Parcial(:,:)));

            if (faseZero)%Opta entre usar ou nao o janelamento de fase zero
    
                for f=1:nroFrames

                        %Rearrumando as amostras do janelamento de fase zero
                        x_Parcial(:,f)=[x_Parcial2(ceil((nroPtsFFT-L/2+1)):nroPtsFFT,f);x_Parcial2(1:floor((L+1)/2),f)];

                end%for f=1:nroFrames
    
            else
    
                x_Parcial(:,:)=x_Parcial2((1:L),:);
    
            end

            if(i==vetorItDesejadas(ItDesejada)+1)%o +1 eh devido a i=1 correponder a inicializacao do algoritmo
                xResult(:,ItDesejada)=xResult_Parcial(:);
                ser(ItDesejada,1)=calcSER(X_mod(:,:),X_MSTFTM);
                tElapsed(ItDesejada,1)=toc(tInit);
                ItDesejada=ItDesejada+1;
            end%if (i==vetorItDesejadas(ItDesejada))

        end%for i=1:nromaxIt
        
    case 'LSEE'   
        
       for i=1:(nromaxIt+1)%o +1 eh devido a i=1 correponder a inicializacao do algoritmo

            xResult_Parcial=LSEE_MSTFT(w,x_Parcial(:,:),L,S,nroFrames);
            [exp_X_fase,X_mod]=STFT(xResult_Parcial(:),nroPtsFFT,L,S,w,faseZero);
            vetorDist(i,1)=calcDist(X_mod(:,:),X_MSTFTM,L);
            
            if(i>=2)
                
                vetorDistPercent(i-1,1)=100*(vetorDist(i-1,1)-vetorDist(i,1))/vetorDist(i-1,1);
            
            end
            
            %X_Parcial(:,:)=X_MSTFTM.*exp(1i*X_fase(:,:));
            X_Parcial(:,:)=X_MSTFTM.*exp_X_fase;
            x_Parcial2(:,:)=real(ifft(X_Parcial(:,:)));

            if (faseZero)%Opta entre usar ou nao o janelamento de fase zero
    
            for f=1:nroFrames

                    %Rearrumando as amostras do janelamento de fase zero
                    x_Parcial(:,f)=[x_Parcial2(ceil((nroPtsFFT-L/2+1)):nroPtsFFT,f);x_Parcial2(1:floor((L+1)/2),f)];

            end%for f=1:nroFrames
    
            else
    
                x_Parcial(:,:)=x_Parcial2((1:L),:);
    
            end

            if(i==vetorItDesejadas(ItDesejada)+1)%o +1 eh devido a i=1 correponder a inicializacao do algoritmo
                xResult(:,ItDesejada)=xResult_Parcial(:);
                ser(ItDesejada,1)=calcSER(X_mod(:,:),X_MSTFTM);
                tElapsed(ItDesejada,1)=toc(tInit);
                ItDesejada=ItDesejada+1;
            end%if (i==vetorItDesejadas(ItDesejada))

        end%for i=1:nromaxIt
            
end%switch(metodo)

end%GL_it

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