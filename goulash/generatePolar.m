function polar = generatePolar(alpha1,alpha2,dalpha)
    
    k = 1;
    alpha = alpha1;
    maxalpha = alpha2;
    polar = zeros(1+(alpha2-alpha1)/dalpha,2);
    
    while alpha <= maxalpha
        data = getDataFT(alpha);
        polar(k,1) = data(1);
        polar(k,2) = data(2);
        alpha = alpha + dalpha;
        k = k + 1;
    end
end

