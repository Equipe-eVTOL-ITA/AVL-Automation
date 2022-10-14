%assume asa retangular, incidência 0
%adicionar pré-cálculo de propriedades do aerofolio
%translate: vetor da posição do bordo de ataque
function wingdata = wingdata(c, b, translate, name, airfoil_file, ...
    claf, cdcl, x_angle_degrees, controldata)
    check_numeric(c, "c")
    check_numeric(b, "b")
    check_vec(translate, "translate", 3)
    check_string(name, "name")
    check_string(airfoil_file, "airfoil_file")
    check_numeric(claf, "claf")
    check_vec(cdcl, "cdcl", 6)
    check_numeric(x_angle_degrees, "x_angle_degrees")

    wingdata.c = c;
    wingdata.b = b;
    wingdata.translate = translate;
    wingdata.name = name;
    wingdata.airfoil_file = airfoil_file;
    wingdata.claf = claf;
    wingdata.cdcl = cdcl;
    wingdata.x_angle_degrees = x_angle_degrees;
    if exist('controldata', 'var') && isstruct(controldata)
        wingdata.controldata = controldata;
    else 
        wingdata.controldata = 0;
    end
end