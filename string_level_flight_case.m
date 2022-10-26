%gera FT e FS
function lfcs = string_level_flight_case(lfcd, plane, caseid)
    if ~isstruct(lfcd)
        error("lfcd deve ser struct do tipo level_flight_case_data")
    end
    check_numeric(caseid, "caseid")
    if  ~isstruct(plane)
        error("plane deve ser struct do tipo planedata")
    end

    %ft é redundante
    %atentar p ordem de preenchimento!!! V deve ser a última
    lfcs = "c1\n" + "d " + string(lfcd.d) + "\ng " + ...
        string(lfcd.g) + "\nm " + string(lfcd.m) + "\nv " + ...
        string(lfcd.v) + "\n\n";

    %trimagem
    %não sei se funciona se 2 sup controle forem usadas pro mesmo momento
    i = 0;
    for wd = plane.wingdatas
        cd = wd.controldata;
        i = i + 1;
        if ~isstruct(cd)
            continue
        end
        if cd.trim == "roll"
            lfcs = lfcs + "d" + num2str(i) + "\nrm 0\n";
        elseif cd.trim == "pitch"
            lfcs = lfcs + "d" + num2str(i) + "\npm 0\n";
        elseif cd.trim == "yaw"
            lfcs = lfcs + "d" + num2str(i) + "\nym 0\n";
        end

    end

    %execução e output
    outputname = plane.name + "_level_flight" + num2str(caseid);
    lfcs = lfcs + "x\n" + "fs\n" + outputname + ".fs\n" + ...
        "st\n" + outputname + ".st\n";
end