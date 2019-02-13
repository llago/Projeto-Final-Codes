function [ w ] = janela(janela,L,S)

switch(janela)
    
    case 'Retangular'
        
        w_aux=sqrt(S/L)*ones(L,1);
                
    case 'MHamming'
        
        a=0.54;
        b=-0.46;
        phi=pi/L;
        
        w_aux = 2*sqrt(S/(L*(4*a^2+2*b^2)))*(a+b*cos(2*pi*(0:(L-1))/L+phi));
        
    case 'MHanning'
        
        a=0.5;
        b=-0.5;
        phi=pi/L;
        
        w_aux = 2*sqrt(S/(L*(4*a^2+2*b^2)))*(a+b*cos(2*pi*(0:(L-1))/L+phi));
end

w=w_aux(:);

end

