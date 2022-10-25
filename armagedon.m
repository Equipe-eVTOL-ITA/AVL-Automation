aileron = controldata("aileron", 1, 0.75, -1, 0.5, 1, "roll");

main = wingdata(0.195, 1.32, [0 0 0], "main", ...
    "naca4415_selig.dat", 1.1155, ...
    [-0.7757 0.042 0.431 0.00973 1.4245 0.11579], 0, aileron);

profundor = controldata("profundor", 1, 0.75, 1, 0, 1, "pitch");
eh = wingdata(0.12, 0.45, [0.664 0.001 0], "EH", ...
    "naca0012_selig.dat", 1.09, ...
    [-1.0553	0.04703 0	0.01201 1.0557	0.05415], 0, profundor);

% input de envergadura é diferente q pra asa
% e não deve duplicar
ev = wingdata(0.102,0.153, [0.664 0 0], "EV", "sd8020_il_selig.dat", ...
    1.1155, [-0.8854	0.03881 0.0001	0.0125 0.8859	0.03876], 90);

plane = planedata(0.195*1.32, 0.195, 1.32, 0, "armagedon", [main, eh, ev]);
%%
case1 = level_flight_case_data(20, 4, 1.23, 9.79);

executeavl(plane, case1)
%%
%melhorar interface
stdata1 = stdata(plane.name + "_level_flight1", plane);
fsdata1 = fsdata(plane.name + "_level_flight1");
%%
aed_data = avl_aerodynamic_data(plane, 15:20, 4, 9.79, 1.23);
[Vcruz, Pcruz] = get_autonomy_cruise_characteristics(plane, aed_data);
%todo
% [Vstall, a_stall] = get_stall_characteristics(plane, "main")
