function [xResult,dist,ser] = FASE(X_MSTFT,L,S,nroFramesLA,janela,faseZero,nroIt,varargin)
%Prototipos possiveis:
%
%   [xResult,dist,ser] = RTISI_LSEE_LA(X_MSTFT,L,S,nroFramesLA,janela,faseZero,nroIt)
%   [xResult,dist,ser] = RTISI_LSEE_LA(X_MSTFT,L,S,nroFramesLA,janela,faseZero,nroIt,faseInicial1oFrame)
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
%janela - String que seleciona a janela que deve ser usada no processo
%('MHamming' - Hamming modificada, 'MHanning' - Hanning modificada ou
%'Retangular' - janela retangular).
%* As janelas modificadas sao as propostas no artigo da referencia [1] do
%artigo acima.
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
%dist - metrica definida na referencia [1] do artigo acima.
%
%ser - medida da razao sinal-erro proposta no artigo.
%
%Autores: Carlos Vinicius Caldas Campos e Renan Mariano Almeida

[nroPtsFFT,nroFrames]=size(X_MSTFT);

xFrames=zeros(L,nroFrames);

X_MSTFTM=abs(X_MSTFT);

if (nargin==8)

    faseFrame=varargin{1}(:);
    x_aux=real(ifft(X_MSTFTM(:,1).*exp(1i*faseFrame)));
    
    if (faseZero)
    
            %Rearrumando as amostras do janelamento de fase zero
            xFrames(:,1)=[x_aux(ceil((nroPtsFFT-L/2+1)):nroPtsFFT);x_aux(1:floor((L+1)/2))];

    else
    
            xFrames(:,1)=x_aux(1:L);
    
    end

end

xResult_Parcial=zeros(L,nroFrames);

%Construcao de vetor da janela (Hamming modificada, Hanning modificada ou
%Retangular)

switch(janela)
    
    case 'Retangular'
        
        w=sqrt(S/L)*ones(L,1);
                
    case 'MHamming'
        
        a=0.54;
        b=-0.46;
        phi=pi/L;
        
        w = 2*sqrt(S/(L*(4*a^2+2*b^2)))*(a+b*cos(2*pi*(0:(L-1))/L+phi));
        
    case 'MHanning'
        
        a=0.5;
        b=-0.5;
        phi=pi/L;
        
        w = 2*sqrt(S/(L*(4*a^2+2*b^2)))*(a+b*cos(2*pi*(0:(L-1))/L+phi));
        
end
%--------------------------------------------------------------------------
%

w=w(:);

k = nroFramesLA; % definindo variavel k que sera usada no tratamento de frames finais

for f=1:nroFrames

    % Tratando casos de frames finais (em que nao da pra fazer LA)
    % Exemplo: sao 250 frames e nroFramesLA = 3. Logo, a partir do frame
    % 258 nao podemos "olhar" os 3 adiante, ja que nao ha frame 251. Esse
    % "if" portanto fara com que no frame 248, 249 e 250 so se "olhe" ate
    % o frame 250
    if (f >= (nroFrames-(nroFramesLA-1)))
        k = k - 1;
        clear xFrameBuffer xFrameBuffer_aux XFrameBufferAtual faseFrameBuffer%Limpando essas variaveis pois elas diminuem de
    %tamanho a medida que k diminui, devendo portanto ser realocadas em
    %tamanho menor na estimativa dos frames correspondentes
    end
    
    for i=1:(nroIt+1)
        
        xFrameBuffer=LSEE_RTISI_LA(w,xFrames,L,S,f,k);
        
        if(faseZero)%Opta entre usar ou nao o janelamento de fase zero
    
            xFrameBuffer_aux=[xFrameBuffer(ceil((L-1)/2+1):end,:);zeros(nroPtsFFT-L,k+1);xFrameBuffer(1:floor(L/2),:)];%Janelamento de fase zero
    
        else
        
            xFrameBuffer_aux=xFrameBuffer;
    
        end%if(faseZero)
        
        XFrameBuffer=fft(xFrameBuffer_aux,nroPtsFFT);
        faseFrameBuffer=atan2(imag(XFrameBuffer),real(XFrameBuffer));
        xBuffer_aux=real(ifft(X_MSTFTM(:,f:f+k).*exp(1i*faseFrameBuffer)));
    
        if (faseZero)
    
            %Rearrumando as amostras do janelamento de fase zero
            xFrames(:,f:f+k)=[xBuffer_aux(ceil((nroPtsFFT-L/2+1)):nroPtsFFT,:);xBuffer_aux(1:floor((L+1)/2),:)];

        else
    
            xFrames(:,f:f+k)=xBuffer_aux(1:L,:);
    
        end
        
    end%for i=1:nroIt

    xResult_Parcial(:,f:f+k)=xFrameBuffer;
    
end%for f=1:nroFrames

xResult=OA(w,xResult_Parcial,L,S,nroFrames);
dist=calcDist(abs(fft(xResult_Parcial,nroPtsFFT)),X_MSTFTM);
ser=calcSER(abs(fft(xResult_Parcial,nroPtsFFT)),X_MSTFTM);

end%RTISI

% function [xFrameBuffer]=LSEE_RTISI_LA(w,xFrames,L,S,frameAtual,k)
% %Overlap and add que para estimar as amostras de um frame leva em conta
% %amostras de frames anteriores, atual e de k posteriores
%     
% T=k*S+L;
% 
% xFrameBuffer_aux=zeros(T,1);
% xFrameBuffer=zeros(L,k+1);
% 
% for l=(1:T)
%        
%         num=0;
%         den=0;
%         f=max(ceil(((l-L)/S+(frameAtual-1))),0);%==max(l+(frameAtual-1))*S-L)/S,0)
%         
%         while ((f<frameAtual+k)&&(f<=((frameAtual-1)-(1-l)/S)))
%             
%             num= num +  w(l+(frameAtual-(f+1))*S)*xFrames(l+(frameAtual-(f+1))*S,f+1);
%             den= den + w(l+(frameAtual-(f+1))*S)^2;
%             f=f+1;
%             
%         end%while (f<frameAtual)
%         
%         xFrameBuffer_aux(l)=num/den;
% 
% end%for    
% 
% for f=(1:k)
% 
%     xFrameBuffer(:,f)=xFrameBuffer_aux((1:L)+f*S).*w;
% 
% end
% 
% end%LSEE_RTISI_LA

function [xFrameBuffer]=LSEE_RTISI_LA(w,xFrames,L,S,frameAtual,k)
%Overlap and add que para estimar as amostras de um frame leva em conta
%amostras de frames anteriores, atual e de k posteriores
    
T=k*S+L;

xFrameBuffer_aux=zeros(T,1);
xFrameBuffer=zeros(L,k+1);

for l=(1+(frameAtual-1)*S):(T+(frameAtual-1)*S)
       
        num=0;
        den=0;
        f=max(ceil((l-L)/S),0);
        
        while((f<=(l-1)/S)&&(f<frameAtual+k))
            
            num=num+w(l-f*S)*xFrames(l-f*S,f+1);
            den= den + (w(l-f*S))^2;%Usar caso a janela usada nao nos leve
            %a ter somatorio de f=-inf ateh +inf de w^2(n-f*S)=1 para todo n
            f=f+1;
            
        end%while
        
        xFrameBuffer_aux(l-(frameAtual-1)*S,1)=num/den;
        
end

for f=(0:k)

    xFrameBuffer(:,f+1)=xFrameBuffer_aux((1:L)+f*S).*w;

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

function [dist]=calcDist(X_mod,X_MSTFTM)
%Calcula a distancia definida na formula (14)

dist=sum(sum(X_mod-X_MSTFTM).^2)/(2*pi);

end

function [ser] = calcSER(X_mod,X_MSTFTM)
%Calcula a razao sinal-erro (SER - signal-to-error ratio)

num = sum(sum(X_MSTFTM).^2)/(2*pi);
den = sum(sum(X_mod-X_MSTFTM).^2)/(2*pi);
ser = 10*log10(num/den);

end