function avlcall(runfilename)
    check_string(runfilename)
    if isunix
        %echo -e "load\n armagedon\n quit" | ./avl
        %^ testar (não precisa gerar arquivos
        [~, ~] = system(char("./avl < " + runfilename));
    elseif ispc
        [~, ~] = dos(['avl < ' runfilename]);
    end
end