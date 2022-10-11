aileron = controldata("aileron", 1, 0.75, -1, 0.5, 1);

main = wingdata(0.195, 1.32, [0 0 0], "main", ...
    "naca4415_selig.dat", 1.1155, ...
    [-0.7757 0.042 0.431 0.00973 1.4245 0.11579], aileron);

profundor = controldata("profundor", 1, 0.75, 1, 0, 1);
eh = wingdata(0.12, 0.45, [0.664 0 0], "EH", ...
    "naca0012_selig.dat", 1.09, ...
    [-1.0553	0.04703 0	0.01201 1.0557	0.05415], ...
    profundor);

%impossível de inputar por enquanto
% ev = wingdata(153, )

plane = planedata(0.195*1.32, 0.195, 1.32, 0, "armagedon", [main, eh]);

case1 = level_flight_case_data(15, 4, 1.23, 9.79);

executeavl(plane, case1)
%%
stdata1 = stdata(plane.name + "_level_flight1");
fsdata1 = fsdata(plane.name + "_level_flight1");
