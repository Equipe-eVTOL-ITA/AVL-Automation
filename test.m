%adicionar info de Clmax
%extrair infos de aerofólio automaticamente?
%documentar e segmentar funçoes de input x internas
%outputar geometria

%dependencia de dados desejados x arquivos de saida e casos de execução
%migrar pra casos com alpha fixo, ao invés de level_flight?
%p baixas velocidades a trimagem não converge
%avisar quando pode ter ocorrido problema de convergência no estol/Vcruz
%obter deflexão asa
%obter MS
%verificar estabilidade
%fazer um .mass?

aileron = controldata("aileron", 1, 0.75, -1, 0.5, 1);

main = wingdata(0.25, 2.5, [0 0 0], "main", ...
    "opcao_aerofolio.dat", 0.9, ...
    [0.52 0.06 1 0.0155 2.25 0.05], 0, aileron);

plane = planedata(0.625, 0.25, 2.5, 0.02, "armagedon", main);

plane_avl_file(plane)

case1 = level_flight_case_data(10, 4, 1.2, 9.8);
case2 = level_flight_case_data(15, 4, 1.2, 9.8);

executeavl(plane, [case1, case2])
stdata1 = stdata('armagedon_level_flight1');