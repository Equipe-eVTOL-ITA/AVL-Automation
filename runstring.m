%para cada caso, colocar dados e executar
function runstring = runstring(plane, cases)
    %pro ora assume que todos os cases são level flight
    runstring = "load\n" + plane.name + "\noper\n";
    %melhorar como lidar com os casos
    i = 1;
    for c = cases
        runstring = runstring + level_flight_case_string(c, plane.name+"_level_flight"+num2str(i));
        i = i + 1;
    end
    runstring = runstring + "\nquit";
end