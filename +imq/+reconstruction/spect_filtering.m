function Y = spect_filtering(Y,X_orig,M,type_filtering)

    switch(type_filtering)
        
        case 'mask'
            
            fprintf(' using spectrogram mask...\n');
            for m=1:1:M
                Y{m,1} = Y{m,1}.*X_orig;
            end
            
        case 'cross'
            
            fprintf(' using cross cancel...\n');
            den_cross = 0;
            for m=1:1:M
                den_cross = den_cross + Y{m,1};
            end
            den_cross = den_cross + eps;
            for m=1:1:M
                Y{m,1} = X_orig.*((Y{m,1})./den_cross);
            end
            
        case 'wiener'
            den_wien = 0;
            for m=1:1:M
                den_wien = den_wien + Y{m,1}.^2;
            end
            den_wien = den_wien + eps;
            for m=1:1:M
                Y{m,1} = X_orig.*((Y{m,1}.^2)./den_wien);
            end
            
        case 'binary'
            
            fprintf(' using binary mask...\n');
            for m=1:1:M
                MM = zeros(size(X_orig));
                YY = zeros([m size(X_orig)]);
                for mm=1:M,YY(mm,:,:)=Y{mm,1};end
                
                for k=1:size(X_orig,1)
                    for l =1:size(X_orig,2)
                        [d index] = max(abs(YY(:,k,l)));
                        if(index == m)
                            MM(k,l) = 1;
                        end
                    end
                end
                Y{m,1} = MM.*X_orig;
            end
            
        otherwise,
            display('Inexistent filtering option');
        
    end

end