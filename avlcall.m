function avlcall(runfilename)
    check_string(runfilename)
    if isunix
        [~, ~] = system(char("./avl < " + runfilename));
    elseif ispc
        [~, ~] = dos(['avl < ' runfilename]);
    end
end