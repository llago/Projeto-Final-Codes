function [xResult,ser,tElapsed,dist] = RTISI_LSEE_LA(X_MSTFT,L,S,nroFramesLA,w,faseZero,nroIt,varargin)
%Prototipos possiveis:
%
%   [xResult,ser,tElapsed,dist] = RTISI_LSEE_LA(X_MSTFT,L,S,nroFramesLA,janela,faseZero,nroIt)
%   [xResult,ser,tElapsed,dist] = RTISI_LSEE_LA(X_MSTFT,L,S,nroFramesLA,janela,faseZero,nroIt,faseInicial1oFrame)
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
%nroFramesLA - numeros de frames de Look-Ahead a serem utilizados na
%estimaçao.
%
%w - vetor de L amostras da janela de analise.
%
%faseZero - utiliza-se o valor 1 caso se queira utilizar o janelamento de
%fase zero na obtencao das fases estimadas, durante a estimação, para a STFT modificada ou 0 caso contrário.
%
%nroIt - nro de iteracoes realizadas na estimativa de cada frame.
%
%faseInicial1oFrame - vetor de valores de fase que serao atribuidos
%inicialmente ao primeiro frame.
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

tInit=tic;

[nroPtsFFT,nroFrames]=size(X_MSTFT);

%xFrames=zeros(L,nroFrames);

xResult_Parcial=zeros(L,nroFrames);

if (1+nroFramesLA>=nroFrames)
        nroFramesLA = nroFrames-1;
end

X_MSTFTM=abs(X_MSTFT);

if (size(varargin,1)==1)

    faseFrameBuffer=varargin{1}(:);
    x_aux=real(ifft(X_MSTFTM(:,1:(nroFramesLA+1)).*exp(1i*faseFrameBuffer)));
    
    if (faseZero)
    
            %Rearrumando as amostras do janelamento de fase zero
            xResult_Parcial(:,1:(nroFramesLA+1))=[x_aux(ceil((nroPtsFFT-L/2+1)):nroPtsFFT,:);x_aux(1:floor((L+1)/2),:)];

    else
    
            xResult_Parcial(:,1:(nroFramesLA+1))=x_aux(1:L,:);
    
    end
    
else
    
    x_aux=real(ifft(X_MSTFTM(:,1:(nroFramesLA+1))));
    xResult_Parcial(:,1:(nroFramesLA+1))=x_aux(1:L,:);

end

w=w(:);

k = nroFramesLA; % definindo variavel k que sera usada no tratamento de frames finais

for f=1:nroFrames

    % Tratando casos de frames finais (em que nao da pra fazer LA)
    % Exemplo: sao 250 frames e nroFramesLA = 3. Logo, a partir do frame
    % 258 nao podemos "olhar" os 3 adiante, ja que nao ha frame 251. Esse
    % "if" portanto fara com que no frame 248, 249 e 250 so se "olhe" ate
    % o frame 250
    if (f >= (nroFrames-(nroFramesLA-1)))
        k = nroFrames-f;
        clear xFrameBuffer xFrameBuffer_aux XFrameBufferAtual faseFrameBuffer den%Limpando essas variaveis pois elas diminuem de
    %tamanho a medida que k diminui, devendo portanto ser realocadas em
    %tamanho menor na estimativa dos frames correspondentes
    end

    [xParcial,den]=pre_LSEE_RTISI_LA(w,xResult_Parcial,L,S,f,k);
    i=0;
    xFrameBuffer=xResult_Parcial(:,f:f+k);
    X_MSTFTM_atual=X_MSTFTM(:,f:f+k);
    
    while(1)
        
        xFrameBuffer=LSEE_RTISI_LA(w,den,xFrameBuffer,L,S,xParcial,k);
        
        if(i<nroIt)
            
            if(faseZero)%Opta entre usar ou nao o janelamento de fase zero

                xFrameBuffer_aux=[xFrameBuffer(ceil((L-1)/2+1):end,:);zeros(nroPtsFFT-L,k+1);xFrameBuffer(1:floor(L/2),:)];%Janelamento de fase zero

            else

                xFrameBuffer_aux=xFrameBuffer;

            end%if(faseZero)

            XFrameBuffer=fft(xFrameBuffer_aux,nroPtsFFT);
            %faseFrameBuffer=atan2(imag(XFrameBuffer),real(XFrameBuffer));
            XFrameBuffer(XFrameBuffer==0)=1;%Substituindo os valores 0 do vetor XFrameAtual para poder efetuar a divisao da linha seguinte
            xBuffer_aux=real(ifft((X_MSTFTM_atual.*XFrameBuffer)./abs(XFrameBuffer)));
            %xBuffer_aux=real(ifft(X_MSTFTM_atual.*exp(1i*faseFrameBuffer)));

            if (faseZero)

                %Rearrumando as amostras do janelamento de fase zero
                xFrameBuffer=[xBuffer_aux(ceil((nroPtsFFT-L/2+1)):nroPtsFFT,:);xBuffer_aux(1:floor((L+1)/2),:)];

            else

                xFrameBuffer=xBuffer_aux(1:L,:);

            end
            
        else
            
            break;
        
        end
        
        i=i+1;
        
    end%while

    xResult_Parcial(:,f:f+k)=xFrameBuffer;
    
end%for f=1:nroFrames

xResult=OA(w,xResult_Parcial,L,S,nroFrames);
[~,X_mod]=STFT(xResult,nroPtsFFT,L,S,w,0);
dist=calcDist(X_mod,X_MSTFTM,L);
ser=calcSER(X_mod,X_MSTFTM);
tElapsed=toc(tInit);

end%RTISI

function [xParcial,den]=pre_LSEE_RTISI_LA(w,xFrames,L,S,frameAtual,k)
%Calculo da contribuicao dos frames anteriores na formula do LSEE
%do frame atual. Calculado uma soh vez pois nao muda ao longo das iteracoes.
    
T=k*S+L;
den=zeros(T,1);
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
        
        while ((f<=((frameAtual-1)+(l-1)/S))&&(f<frameAtual+k))
            
            den_aux= den_aux + w(l+(frameAtual-(f+1))*S)^2;
            f=f+1;
            
        end

        den(l)= den_aux;
        
        xParcial(l,1)=num;
        
end%for

for l=(L-S+1):T

    den_aux=0;
    f=max(ceil(((l-L)/S+(frameAtual-1))),0);%==max(l+(frameAtual-1))*S-L)/S,0)
    
    while (f<=((frameAtual-1)+(l-1)/S)&&(f<frameAtual+k))
            
        den_aux= den_aux + w(l+(frameAtual-(f+1))*S)^2;
        f=f+1;
            
    end
    
    den(l)=den_aux;
    
end%for

end%pre_LSEE_RTISI_LA

function [xFrameBuffer_saida]=LSEE_RTISI_LA(w,den,xFrameBuffer_entrada,L,S,xParcial,k)
%Overlap and add que para estimar as amostras de um frame leva em conta
%amostras de frames anteriores, atual e de k posteriores
    
T=k*S+L;
xFrameBuffer_saida=zeros(L,k+1);
num=zeros(T,1);

for l=1:(L-S)
       
        num_aux=xParcial(l);
        f=max(ceil((l-L)/S),0);%==max(l+(frameAtual-1))*S-L)/S,0)%Primeiro frame
        %onde a amostra l aparece.
        
        while((l>f*S)&&(f<=k))
            
            num_aux=num_aux+w(l-f*S)*xFrameBuffer_entrada(l-f*S,f+1);
            f=f+1;
            
        end%while
        
        num(l)=num_aux;
        
end

for l=(L-S+1):T
       
        num_aux=0;
        f=max(ceil((l-L)/S),0);%==max(l+(frameAtual-1))*S-L)/S,0)
        
        while((l>f*S)&&(f<=k))
            
            num_aux=num_aux+w(l-f*S)*xFrameBuffer_entrada(l-f*S,f+1);
            f=f+1;
            
        end%while
        
        num(l)=num_aux;
        
end

xFrameBuffer_aux=num./den;

for f=(0:k)

    xFrameBuffer_saida(:,f+1)=xFrameBuffer_aux((1+f*S:L+f*S)).*w;

end

end%LSEE_RTISI_LA

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