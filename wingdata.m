%assume asa retangular, incidência 0
%adicionar pré-cálculo de propriedades
%translate: vetor da posição do bordo de ataque
function wingdata = wingdata(c, b, translate, name, airfoil_file, ...
    claf, cdcl, controldata)
    check_numeric(c, "c")
    check_numeric(b, "b")
    check_vec(translate, "translate", 3)
    check_string(name, "name")
    check_string(airfoil_file, "airfoil_file")
    check_numeric(claf, "claf")
    check_vec(cdcl, "cdcl", 6)

    wingdata.c = c;
    wingdata.b = b;
    wingdata.translate = translate;
    wingdata.name = name;
    wingdata.airfoil_file = airfoil_file;
    wingdata.claf = claf;
    wingdata.cdcl = cdcl;
    if exist('controldata', 'var') && isstruct(controldata)
        wingdata.controldata = controldata;
    end
end