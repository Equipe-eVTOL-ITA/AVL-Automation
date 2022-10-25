%talvez não precise de um solver numérico. Com as derivadas de controle e
%de estabilidade deve dar pra linearizar muita coisa e chegar em uma
%solução analítica
function [Vcruz, Pcruz] = get_autonomy_cruise_characteristics(plane, aed_data)
    if ~isstruct(plane)
        error("plane deve ser struct do tipo planedata")
    end
    if ~isstruct(aed_data)
        error("aed_Data deve ser struct do tipo avl_aerodynamic_data")
    end
    %seta v0 como a média dos valores de V
    V0 = mean(aed_data.speeds);
    %otimizar Pcruz
    [Vcruz, Pcruz] = fminsearch(@(V) Pcruise(V, plane, aed_data), V0);
end

function Pcruise = Pcruise(v, plane, aed_data)
    %interpolação linear p obter o CD
    %cat pq acessar membros de um vetor de struct retorna elementos
    %separados, não em um vetor
    CD = interp1(aed_data.speeds, cat(1, aed_data.stdata.CD), v);
    Pcruise = 0.5*aed_data.rho*v^3*plane.Sref*CD;
end