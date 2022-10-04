%editar esses valores
function [d, mtow] = AVL_dec(surf, range)
    %superfície sustentadora (Sref do .avl)

    %EXTRAÇÃO DOS DADOS DE SAÍDA DO AVL_runner
    %mudar Valores de saída.txt
    planeFile = fopen("AVLResultados.txt", 'r');

    planeData = textscan(planeFile, "%s", 'HeaderLines', 1);
    planeData = planeData{1};

    airfoils = [];

    %aerofólios nas colunas; 1a linha é Clalfa=0, 2a é CDalfa=0, 3a é CLmax
    coefs = [];

    strBegin = 0;
    for i = 1 : length(planeData)
        if isnan(str2double(planeData{i})) && ~strBegin
            %começo de um nome
            strBegin = i;
        end
        if ~isnan(str2double(planeData{i}))
            %é número
            if strBegin
                %o nome acabou, joga ele no airfoils
                name = [];
                for j = strBegin : i-1
                    name = join([name string(planeData{j})]);
                end
                airfoils = [airfoils name];
                strBegin = 0;
                %começa coluna nova
                coefs(1, end+1) = str2double(planeData{i});
                index = 2;
            else
                coefs(index, end) = str2double(planeData{i});
                index = index + 1;
            end
        end
    end

    warning('off');

    d = [];
    mtow = [];
    for i = range
        [d(end+1), mtow(end+1)] = takeOff( coefs(1, i) , coefs(2, i) , coefs(3, i) , surf);
        %mtow = fsolve(
    end

end

function [dist, MTOW] = takeOff(CL, CD, CLmax, s)
    %s é a área sustentadora, deve ser tirado do .avl (automatizar?)
    rho = 0.9964;
    g = 9.81;
    ks = 1.1;
    m = 9.6;
    mi = 0.04;
    T0 = 35;
    T1 = -0.4084;
    T2 = -0.0185;
    vDec = ks * sqrt((m/s) * 2*g/(rho*CLmax))
    function func = dec_fun(mass)
        t = @(v) T0 + T1.*v + T2*v.^2;
        d = @(v) rho/2 * v.^2 * s * CD;
        l = @(v) rho/2 * v.^2 * s * CL;
        fat = @(v) mi * max(0, mass * g - l(v));
        func = @(v) mass * v ./ (t(v) - d(v) - fat(v));
    end
    dist = integral(dec_fun(m), 0, vDec);
    dist(dist<0) = Inf;
    
    dif = @(massa) integral(dec_fun(massa), 0, vDec) - 50;
    [MTOW, ~, flag] = fsolve(dif, 4);
    %ok = [1 2 3 4]
    if all(flag ~= [1 2 3 4]) || MTOW > 17
        %flag não é nenhum dos possíveis casos de dar bom
        MTOW = 0;
    end
end