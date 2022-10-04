%assume CM na origem
function planedata = planedata(Sref, cref, bref, ...
    parasite_drag, name, wingdatas)
    check_numeric(Sref, "Sref")
    check_numeric(cref, "cref")
    check_numeric(bref, "bref")
    check_string(name, "name")
    check_numeric(parasite_drag, "parasite_drag")
    if ~isstruct(wingdatas)
        error("Wing datas deve ser vetor de structs do tipo wing data,"...
        + " contendo todas as superfícies aerodinâmicas do veículo")
    end

    planedata.Sref = Sref;
    planedata.cref = cref;
    planedata.bref = bref;
    planedata.name = name;
    planedata.parasite_drag = parasite_drag;
    planedata.wingdatas = wingdatas;
end