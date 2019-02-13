function [varargout] = MISI(mistura,vetorItDesejadas,L,S,w,faseZero,varargin)
%Prototipo da funcao MISI
%
%   [tElapsed,xEstimado1,ser1,xEstimado2,ser2,...,tElapsed] = MISI(y,vetorItDesejadas,L,S,w,faseZero,X_STFTM1,X_STFTM2,...)
%
tInit=tic;

nroSinais=size(varargin,2);
nroPtsFFT=size(varargin{1},1);
nroFrames=size(varargin{1},2);
T=length(mistura);
T2=(nroFrames-1)*S+L;
mistura=mistura(:);
X_MSTFTM=zeros(nroPtsFFT,nroFrames,nroSinais);

nroMaxIt=max(vetorItDesejadas);

for i=1:nroSinais
    
    X_MSTFTM(:,:,i)=abs(varargin{i});
    
end

y=[mistura;zeros(T2-T,1)];
xEstimados=zeros(T2,nroSinais);
xResult=zeros(T2,length(vetorItDesejadas),nroSinais);
tElapsed=zeros(length(vetorItDesejadas),1);
ser=zeros(nroSinais,1);

w=w(:);

ItDesejada=1;

%Inicializacao
for i=1:nroSinais
    
    xEstimados(:,i)=y;
    
end

erro=0;
%------------------------------------------------------------------------%

for i=1:(nroMaxIt+1)
    
    for j=1:nroSinais
        
        xEstimadosRealimentado=xEstimados(:,j)+erro/nroSinais;
        exp_X_fase=STFT(xEstimadosRealimentado,nroPtsFFT,L,S,w,faseZero);
        %X_Parcial(:,:)=X_MSTFTM(:,:,j).*exp(1i*X_fase(:,:));
        %x_Parcial2(:,:)=real(ifft(X_Parcial(:,:)));
        x_Parcial2(:,:)=real(ifft(X_MSTFTM(:,:,j).*exp_X_fase));
        
        if (faseZero)
        
        x_Parcial=zeros(L,nroFrames);
            
            for f=1:nroFrames

                 %Rearrumando as amostras do janelamento de fase zero
                 x_Parcial(:,f)=[x_Parcial2(ceil((nroPtsFFT-L/2+1)):nroPtsFFT,f);x_Parcial2(1:floor((L+1)/2),f)];

            end%for f=1:nroFrames
    
        else
    
                x_Parcial(:,:)=x_Parcial2((1:L),:);
    
        end%if(faseZero)
        
        xEstimados(:,j)=LSEE_MSTFT(w,x_Parcial(:,:),L,S,nroFrames);
    
    end%for i:nroSinais
    
    erro=y-sum(xEstimados.').';
    
    if(i==vetorItDesejadas(ItDesejada)+1)%o +1 eh devido a i=1 correponder a inicializacao do algoritmo
        
        for j=1:nroSinais

            [X_mod]=STFT(xEstimados(:,j),nroPtsFFT,L,S,w,faseZero);
            ser(ItDesejada,j)=calcSER(X_mod,X_MSTFTM(:,:,j));

            xResult(:,ItDesejada,j)=xEstimados(:,j);

        end
        
        tElapsed(ItDesejada,1)=toc(tInit);
        ItDesejada=ItDesejada+1;
                
    end%if (i==vetorItDesejadas(ItDesejada))
    
end%for i=1:(nroMaxIt+1)

for j=1:nroSinais
    
    varargout{1+2*(j-1)}=xResult(:,:,j);
    varargout{2+2*(j-1)}=ser(:,j);
    
end%for j=1:nroSinais

varargout{2*nroSinais+1}=tElapsed;

end%MISI

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

function [ser] = calcSER(X_mod,X_MSTFTM)
%Calcula a razao sinal-erro (SER - signal-to-error ratio)

num = sum(sum(X_MSTFTM.^2))/(2*pi);
den = sum(sum((X_mod-X_MSTFTM).^2))/(2*pi);
ser = 10*log10(num/den);

end