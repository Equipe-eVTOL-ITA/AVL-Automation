function x = x_dec(p1, p2, cm, cd, clmax)
    rho = 0.9964;
    g = 9.81;
    s = 0.2:0.1:1; %surface area of wing
    ks = 1.1;
    m = 9.5; %MTOW
    mi = 0.04;
    T0 = 35;
    T1 = -0.4084;
    T2 = -0.0185;
    [cL, cD, eff] = calc_c_L(p1, p2, cm, cd);
    [~, arDim] = size(cL);
    [S, EFF] = meshgrid(s, eff);
    [~, CL] = meshgrid(s, cL);
    [~, CD] = meshgrid(s, cD);
    vDec = ks * sqrt((m ./ S) * 2*g./(rho*(EFF*clmax)));
    [~, sDim] = size(s);
    x = zeros(arDim, sDim); 
    for i = 1 : arDim
        for j = 1 : sDim
            t = @(v) T0 + T1*v + T2*v.^2;
            d = @(v) rho/2 * v.^2 * s(j) * cD(i);
            l = @(v) rho/2 * v.^2 * s(j) * cL(i);
            fat = @(v) mi * max(0, m * g - l(v));
            func = @(v) m * v ./ (t(v) - d(v) - fat(v));
            x(i, j) = integral(func, 0, vDec(i, j));
            %pode ser que t(v) < d(v) + fat(v) (motor fraco demais)
            if x(i,j) < 0
                x(i,j) = 0;
            end
        end
    end
    x = cat(3, x, S);
    x = cat(3, x, CL);
    x = cat(3, x, CD);
end

function [cL, cD, eff] = calc_c_L(p1, p2, cm, cd)
    %p1 deve ser p alfa = 0, p2 um ponto qq
    Vh = 0.38;
    ratio = 0.078 / 0.625;
    AR = 6:0.2:10;
    m = (p2(2) - p1(2))/(p2(1) - p1(1));
    alfa0 = -p1(2)/m + p1(1);
    
    a0 = p1(2)/(-alfa0);
    eff = 1 ./ (1 + 0.01 + 0.0038*pi*AR);
    a = a0 ./ (1 + 57.3*a0./(pi*eff.*AR));
    
    cLw = a*(-alfa0);
    cLt = cm * (1/Vh) * ratio;
    cL = cLw + cLt;
    cDtrim = 1/(pi*0.95*4) * cLt^2;
    cD = cd + 1./(pi*eff.*AR) .* cLw.^2 + cDtrim;
end