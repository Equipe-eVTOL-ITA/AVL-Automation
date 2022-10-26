%para cada caso, colocar dados e executar
function runstring = string_run(plane, cases)
    %pro ora assume que todos os cases são level flight
    runstring = "load\n" + plane.name + "\noper\n";
    %melhorar como lidar com os casos
    i = 1;
    for c = cases
        runstring = runstring + string_level_flight_case(c, plane, i);
        i = i + 1;
    end
    runstring = runstring + "\nquit";
end