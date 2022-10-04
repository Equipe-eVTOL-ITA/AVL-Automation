function resultName = datafsAVL(alpha)
    %define ângulo
    name = ['armageddon', '.run'];
    runFile = fopen(name, 'w');
    fprintf(runFile, strcat("load\n", "armageddon", '.avl\n'));

    fprintf(runFile, 'oper\n');

    fprintf(runFile, ['a\na ' num2str(alpha) '\n']);
    fprintf(runFile, 'd1\npm 0\n'); 

    fprintf(runFile, 'x\n');
    fprintf(runFile, 'fs\n');
    
    resultName = char(name);
    resultName = string([resultName(1:end-4) 'fs']); %remove o .run
    
    fprintf(runFile, strcat(resultName, '\n'));
    fprintf(runFile, '\nQUIT\n');
    fclose(runFile);
    delete(resultName);
    [~, ~] = dos(['avl < ' name]);
    %delete(name);
end