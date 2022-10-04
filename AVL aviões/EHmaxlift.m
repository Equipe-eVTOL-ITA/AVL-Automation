clear;
Clmax = 1.20;

CDCL = [-1.0 0.02 0.00 0.0070 1.00 0.020];

airfoil = "naca0012.dat";



delta = 0;
ddelta = 0.5;
%loop do-while p achar CLmax

%NÃO FUNCIONA PRA DELTA NEGATIVO
%?????????????
while true
    %maximo cl da asa p delta
    [max_delta, CL] = getData(delta);
    %CL é uma cell
    CL = CL{1};
    %maximo cl da asa p delta + ddelta
    [max_delta_ddelta, ~] = getData(delta + ddelta);
    
    dmax_ddelta = (max_delta_ddelta - max_delta) / ddelta;
    
    %método de newton
    delta = delta - (max_delta - Clmax) / dmax_ddelta;
    
    disp(max_delta)
    if abs(max_delta - Clmax) <= 0.01
        %ler CL e pegar delta
        disp(['O CL é ' num2str(CL) ' e o delta máximo é ' num2str(delta)]);
        break
    end
end



function [m, CL] = getData(def)
    fs = setDeflection(def);
    fsFile = fopen(fs);
    [m, CL] = parseFSData(fsFile);
    fclose(fsFile);
    delete(fs);
end

function resultName = setDeflection(def)
    %deflete o profundor com um ângulo
    name = ['esse_aqui', '.run'];
    runFile = fopen(name, 'w');
    fprintf(runFile, strcat("load\n", "esse_aqui", '.avl\n'));

    fprintf(runFile, 'oper\n');
    fprintf(runFile, ['d1\nd1 ' num2str(def) '\n']);
    
    fprintf(runFile, 'x\n');
    fprintf(runFile, 'fs\n');
    
    resultName = char(name);
    resultName = string([resultName(1:end-4) 'fs']); %remove o .run
    
    fprintf(runFile, strcat(resultName, '\n'));
    fprintf(runFile, '\nQUIT\n');
    fclose(runFile);
    delete(resultName);
    [~, ~] = dos(['avl < ' name]);
    delete(name);
end

function [m, CL] = parseFSData(fsFile)
    %é a 2a asa a ser printada no FS
    resultPosition = 2;
    %m de max
    %pega SÓ a tabela de números
    CL = textscan(fsFile, "CLsurf  =  %f", 'HeaderLines', 99);
    frewind(fsFile);
    fsData = textscan(fsFile, "%f", 'HeaderLines', 20 + 90*(resultPosition - 1)); %deve pegar só números
    fsData = fsData{1};
    %lista dos cls
    cl = [];
    %linha da tabela
    row = 61;
    %no começo de cada linha tem índice da linha
    %60 DEPENDE DO .avl!!!! 2x o num de strips
    for j = 1:size(fsData, 1)
        if j <= 7
            continue
        end
        if fsData(j - 7) == row 
            cl = [cl fsData(j)];
            row = row + 1;
        end
    end
    m = max(cl);
end