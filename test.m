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
%atualizar check_vec p incluir caso de qq comprimento

aileron = input_controldata("aileron", 1, 0.75, -1, 0.5, 1, "roll");

main = input_wingdata(0.25, 2.5, [0 0 0], "main", ...
    "opcao_aerofolio.dat", 0.9, ...
    [0.52 0.06 1 0.0155 2.25 0.05], 0, 2.25, aileron);

plane = input_planedata(0.625, 0.25, 2.5, 0.02, "armagedon", main);
%%
file_plane(plane)

case1 = input_alpha_case_data(0, ["roll"]);
case2 = input_alpha_case_data(5, "none");

avl_execute_cases(plane, [case1, case2])
%%
stdata1 = read_stdata("armagedon1", plane);