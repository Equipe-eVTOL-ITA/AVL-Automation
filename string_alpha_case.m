%gera FT e FS
function sac = string_alpha_case(acd, plane, caseid)
    check_struct(acd, "sacd", "input_alpha_case_data")
    check_numeric(caseid, "caseid")
    check_struct(plane, "plane", "input_planedata")
    %ft é redundante
    %atentar p ordem de preenchimento!!! V deve ser a última
    sac = "a\na " + num2str(acd.alpha) + "\n";

    %trimagem
    %não sei se funciona se 2 sup controle forem usadas pro mesmo momento
    i = 0;
    for wd = plane.wingdatas
        cd = wd.controldata;
        i = i + 1;
        if ~isstruct(cd)
            continue
        end
        if cd.trim == "roll" && any(acd.axes_to_trim == "roll")
            sac = sac + "d" + num2str(i) + "\nrm 0\n";
        elseif cd.trim == "pitch" && any(acd.axes_to_trim == "pitch")
            sac = sac + "d" + num2str(i) + "\npm 0\n";
        elseif cd.trim == "yaw" && any(acd.axes_to_trim == "yaw")
            sac = sac + "d" + num2str(i) + "\nym 0\n";
        end

    end

    %execução e output
    outputname = plane.name + num2str(caseid);
    sac = sac + "x\n" + "fs\n" + outputname + ".fs\n" + ...
        "st\n" + outputname + ".st\n";
end