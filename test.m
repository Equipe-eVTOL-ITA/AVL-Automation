%adicionar info de Clmax
%para depois: d<int> e numerado na ordem de apariçao no .avl
%extrair infos de aerofólio automaticamente

aileron = controldata("aileron", 1, 0.75, -1, 0.5, 1);

main = wingdata(0.25, 2.5, [0 0 0], "main", ...
    "opcao_aerofolio.dat", 0.9, ...
    [0.52 0.06 1 0.0155 2.25 0.05], aileron);

plane = planedata(0.625, 0.25, 2.5, 0.02, "armagedon", main);

plane_avl_file(plane)

case1 = level_flight_case_data(10, 4, 1.2, 9.8);
case2 = level_flight_case_data(15, 4, 1.2, 9.8);

executeavl(plane, [case1, case2])
stdata1 = stdata('armagedon_level_flight1');