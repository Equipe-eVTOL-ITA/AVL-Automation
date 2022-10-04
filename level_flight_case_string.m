%gera FT e FS
function lfcs = level_flight_case_string(lfcd, outputid)
    check_string(outputid, "outputid")
    if ~isstruct(lfcd)
        error("lfcd deve ser struct do tipo level_flight_case_data")
    end
    
    %ft é redundante
    %atentar p ordem de preenchimento!!! V deve ser a última
    lfcs = "c1\n" + "d " + string(lfcd.d) + "\ng " + ...
        string(lfcd.g) + "\nm " + string(lfcd.m) + "\nv " + ...
        string(lfcd.v) + "\n\nx\n" + ...
        "fs\n" + outputid + ".fs\n" + ...
        "st\n" + outputid + ".st\n";
end