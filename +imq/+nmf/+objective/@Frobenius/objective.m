function retVal = objective(obj, V, W, H)

    retVal = 0.5 * (max((norm(V, 'fro'))^2 - 2*trace(H*(V'*W))+trace((W'*W)*(H*H')),0 ));
    retVal = retVal + obj.cfg.regW(1) * sum(sum(W.*W));
    retVal = retVal + obj.cfg.regW(2) * sum(sum(W,2).^2);
    retVal = retVal + obj.cfg.regH(1) * sum(sum(H.*H));
    retVal = retVal + obj.cfg.regH(2) * sum(sum(H,1).^2);
end