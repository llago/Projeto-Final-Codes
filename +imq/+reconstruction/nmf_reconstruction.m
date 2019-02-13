function Y_rec = nmf_reconstruction(B,G,b,modelonmf,MM)

M = size(B,2);
Y_rec = cell(M,1);

switch (modelonmf)
    
    case 'nmfcomum'
        
        for m=1:1:M
            Y_rec{m,1} = B(:,m)*G(m,:);
        end
        
    case 'nmfcrit'
        
        for m=1:1:M
            Y_rec{m,1} = B(:,m)*G(m,:);
        end
        
    case 'nmfd'
        
        tau = size(B,3);
        for m=1:1:M
            Ym = 0;
            for t = 1:1:tau
                Ym = Ym + squeeze(B(:,m,t))*shiftright(G(m,:),t-1);
            end
            Y_rec{m,1} = Ym;
        end
        
    case 'nmf2d'
        
        tau = size(B,3);
        phi = size(G,3);
        for m=1:1:M
            Ym = 0;
            for t=1:1:tau
                for p=1:1:phi
                    Ym = Ym + (shiftdown(B(:,m,t),p-1).*MM(:,t,p,m))*shiftright(G(m,:,p),t-1);
                end
            end
            Y_rec{m,1} = Ym;
        end
        
    case 'lnmf2d'
        
        tau = size(B,3);
        phi = size(G,3);
        for m=1:1:M
            Ym = 0;
            for t=1:1:tau
                for p=1:1:phi
                    Ym = Ym + (linear_shift(B(:,m,t),p-1,b).*MM(:,t,p,m))*shiftright(G(m,:,p),t-1);
                end
            end
            Y_rec{m,1} = Ym;
        end
        
    case 'snmf2d'
        
        tau = size(B,3);
        phi = size(G,3);
        for m=1:1:M
            Ym = 0;
            for t=1:1:tau
                for p=1:1:phi
                    Ym = Ym + (shiftdown(B(:,m,t),p-1).*MM(:,t,p,m))*shiftright(G(m,:,p),t-1);
                end
            end
            Y_rec{m,1} = Ym;
        end
        
    case 'snmf2d_plus'
        
        tau = size(B,3);
        phi = size(G,3);
        for m=1:1:M
            Ym = 0;
            for t=1:1:tau
                for p=1:1:phi
                    Ym = Ym + (shiftdown(B(:,m,t),p-1).*MM(:,t,p,m))*shiftright(G(m,:,p),t-1);
                end
            end
            Y_rec{m,1} = Ym;
        end
        
        
end
end