%3 1os parametros vem do avl (Xhinge smp 0 0 0)
%2 ultimos indicam a fração da envergadura de inicio e fim da sup
%contando a partir da raiz (0 = raiz, 1 = ponta)
function controldata = controldata(name, gain, Xhinge, sgnDup, start_x_b, end_x_b, ...
        trim)
    check_string(name, "name")
    check_numeric(gain, "gain")
    check_numeric(Xhinge, "Xhinge")
    check_numeric(sgnDup, "sgnDup")
    if sgnDup ~= 1 && sgnDup ~=-1
        error("sgnDup deve ser +1 ou -1")
    end
    check_numeric(start_x_b, "start_x_b")
    check_numeric(end_x_b, "end_x_b")
    check_string(trim, "trim")
    if all(trim ~= ["pitch", "roll", "yaw", "none"])
        error("trim deve especificar um momento a ser trimado (pitch, roll, yaw ou none)")
    end

    controldata.name = name;
    controldata.gain = gain;
    controldata.Xhinge = Xhinge;
    controldata.sgnDup = sgnDup;
    controldata.start_x_b = start_x_b;
    controldata.end_x_b = end_x_b;
    controldata.trim = trim;
end