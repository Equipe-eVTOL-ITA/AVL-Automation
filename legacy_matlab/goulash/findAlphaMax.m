function alphamax = findAlphaMax(CLmax)
    
    alpha1 = 0;
    alpha2 = 20;
    condition = 0;
    
    while condition == 0
        alpha = (alpha1+alpha2)/2;
        data = getDataFS(alpha);
        Clmax = max(data);
        dif = CLmax - Clmax;
        if dif > 0
            alpha1 = alpha;
        else
            alpha2 = alpha;
        end
        if abs(dif) < 1e-5 || abs(alpha1-alpha2) < 1e-5
            condition = 1;
        end
    end
    
    alphamax = alpha;
end