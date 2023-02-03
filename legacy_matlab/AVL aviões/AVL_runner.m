function AVL_runner(fileName, airfoilRange, wingN)
    %fileName: nome do arquivo .avl, sem o .avl

    %airfoilRange: quais aerofólios usar
    %o número vem da ordem no "Comparação aerofólios.txt"
    %se quiser só o 4, por exemplo, colocar 4:4

    %wingN: número de asas com aerofólio

    planes = [];
    %%PARTE 1: CARREGAMENTO DOS AEROFÓLIOS E DADOS

    file = fopen("Comparação aerofólios.txt", 'r');
    text = textscan(file, "%s", 'HeaderLines', 1);
    text = text{1};

    %lsita aerofolios, e matriz com seus coeficientes nas colunas associadas
    %numero de parametros por aerofolio
    dataLen = 7;

    %flag de começo de nome de aerofolio
    strBegin = 0;

    %lista dos aerofólios
    airfoils = [];

    %lista das propriedades
    coefs = [];

    index = 0;
    %loop pelo arquivo de texto
    for i = 1 : length(text)
        if isnan(str2double(text{i})) && ~strBegin
            %começo de um nome
            strBegin = i;
        end
        if ~isnan(str2double(text{i}))
            %é número
            if strBegin
                %o nome acabou, joga ele no airfoils
                name = [];
                for j = strBegin : i-1
                    name = join([name string(text{j})]);
                end
                airfoils = [airfoils name];
                strBegin = 0;
                coefs = cat(2, coefs, zeros(dataLen,1));
                coefs(1, size(coefs, 2)) = str2double(text{i});
                index = 2;
            else
                coefs(index, size(coefs, 2)) = str2double(text{i});
                index = index + 1;
            end
        end
    end
    fclose(file);
    airfoils = strcat(airfoils, ".dat");

    %%PARTE 2: edição do arquivo .avl
    %cria arquivo especifico com o aerofolio na asa principal
    %a modificação exige que a asa principal seja a 1a definida

    basePlane = fopen(strcat(fileName, ".avl"), 'r');
    baseData = textscan(basePlane, "%s", 'Delimiter', '\n');
    baseData = baseData{1};
    fclose(basePlane);

    for i = airfoilRange
        wing = 0;
        planeData = baseData;
        %reconhece onde inserir o aerofólio e suas propriedades
        for j = 1 : size(baseData, 1)
            %fazer o loop sobre baseData - fora do loop dos aerofólios?
            if (wing == wingN) && (baseData{j} == "SURFACE")
                %asas acabaram
                break
            end
            if (baseData{j} == "SURFACE")
                wing = wing + 1;
            end

            if wing
                %substitui arquivo de aerofólio e valores em toda SECTION da
                %asa
                if baseData{j} == "AFILE"
                    planeData{j+1} = airfoils(i);
                elseif planeData{j} == "CDCL"
                    planeData{j+1} = join(string(transpose(coefs(2:size(coefs, 1), i))));
                end
            end
        end

        %criação de novo arquivo .avl
        planes = [planes strcat(fileName, " (", airfoils(i),").avl")];
        plane = fopen(planes(end), 'w');
        if plane == -1
            plane = fopen(planes(end), 'w');
        end
        for j = 1 : size(planeData, 1)
            fprintf(plane, strcat(planeData{j}, "\n"));
        end
        fclose(plane);
    end

    delete("AVLResultados.txt");
    saida = fopen("AVLResultados.txt", 'w');
    fprintf(saida, "%s\n", "Aerofólio, CL e CD com alfa = 0, CLmax");

    for i = 1 : size(planes, 2)
        plane = planes(i);
        planeName = char(plane);
        planeName = string(planeName(1 : end - 4)); %remove .avl

        lastAlfa = 0;
        alfa = 0;

        count = 0;
        %do while loop
        while true
            setup = runf(planeName, alfa);
            dos(strcat("avl < ", '"', setup, '"'));
            delete(strcat(planeName, ".run"));
            fsFile = fopen(strcat(planeName, "fs"), 'r');
            fsData = textscan(fsFile, "%f", 'HeaderLines', 20); %deve pegar só números
            fclose(fsFile);

            fsData = fsData{1};
            %%TODO MUDAR MODO DE CONTAGEM
            cl = [];
            row = 1;
            for j = 1:size(fsData, 1)
                if j <= 7
                    continue
                end
                if fsData(j - 7) == row 
                    cl = [cl fsData(j)];
                    row = row + 1;
                end
            end

            maxCl = max(cl);
            Clmax = coefs(1,i);

            if alfa == 0
                %PEGAR CL E CD
                stFile = fopen(strcat(planeName, "st"), 'r');
                v = textscan(stFile, "  CLtot =   %f\r\n  CDtot =   %f\r\n", 'HeaderLines', 23);
                fclose(stFile);
            end

            if maxCl < Clmax
                lastAlfa = alfa;
                alfa = alfa + 5;
            elseif maxCl > Clmax
                alfa = (alfa + lastAlfa)/2;
            end

            if abs(maxCl - Clmax) <= 0.05 || count > 9
                stFile = fopen(strcat(planeName, "st"), 'r');
                u = textscan(stFile, "  CLtot =   %f\n", 'HeaderLines', 23);
                if count <= 9
                    fprintf(saida, "%s %10f %10f %10f\r\n", planeName, v{1}, v{2}, u{1});
                else
                    fprintf(saida, "%s %10f %10f %10f\r\n", planeName, v{1}, v{2}, u{1});
                    disp(strcat("ERRO COM ", planeName));
                end
                fclose(stFile);
                delete(strcat(planeName, "fs"));
                delete(strcat(planeName, "st"));
                break
            end
            delete(strcat(planeName, "fs"));
            delete(strcat(planeName, "st"));
            count = count + 1;
        end
    end

    fclose(saida);

    %cria arquivo .run
    function name = runf(plane, angle)
    %trimar se alfa =/= 0
        name = strcat(plane, ".run");
        runFile = fopen(name, 'w');
        fprintf(runFile, strcat("load\n", plane, '.avl\n'));

        fprintf(runFile, 'oper\n');
        fprintf(runFile, 'c1\n');

        fprintf(runFile, 'm\n10\n');
        fprintf(runFile, 'g\n9.81\n');
        fprintf(runFile, 'v \n12\n\n');

        fprintf(runFile, 'a\n');
        fprintf(runFile, strcat("a\n", string(angle), '\n'));
        if angle ~= 0
            fprintf(runFile, "d2 pm 0\n");
        end
        fprintf(runFile, 'x\n');
        fprintf(runFile, 'fs\n');
        resultName = char(name);
        resultName = string(resultName(1:end-4)); %remove o .run
        fprintf(runFile, strcat(resultName, "fs\n"));
        fprintf(runFile, 'st\n');
        fprintf(runFile, strcat(resultName, "st\n\n"));
        fprintf(runFile, 'QUIT\n');

        fclose(runFile);
    end
end
