aileron = input_controldata("aileron", 1, 0.75, -1, 0.5, 1, "roll");

main = input_wingdata(0.195, 1.32, [0 0 0], "main", ...
    "naca4415_selig.dat", 1.1155, ...
    [-0.7757 0.042 0.431 0.00973 1.4245 0.11579], 0, 1.4245, aileron);

profundor = input_controldata("profundor", 1, 0.75, 1, 0, 1, "pitch");
eh = input_wingdata(0.12, 0.45, [0.664 0.001 0], "EH", ...
    "naca0012_selig.dat", 1.09, ...
    [-1.0553	0.04703 0	0.01201 1.0557	0.05415], 0, 1.055, profundor);

% input de envergadura é diferente q pra asa
% e não deve duplicar
ev = input_wingdata(0.102,0.153, [0.664 0 0], "EV", "sd8020_il_selig.dat", ...
    1.1155, [-0.8854	0.03881 0.0001	0.0125 0.8859	0.03876], 90, 0.8859);

plane = input_planedata(0.195*1.32, 0.195, 1.32, 0, "armagedon", [main, eh, ev]);

%%
%problema: se velocidade baixa demais, não converge
%migrar de level_flight pra setar alpha e trimar?
aed_data = wrapper_aerodynamic_data(plane, -2:2:20, 4, 9.79, 1.23);
%%
[Vcruz, Pcruz] = get_autonomy_cruise_characteristics(plane, aed_data);
[Vstall, a_stall] = get_stall_characteristics(plane, "main", aed_data)
