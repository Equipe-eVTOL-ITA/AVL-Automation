%talvez não precise de um solver numérico. Com as derivadas de controle e
%de estabilidade deve dar pra linearizar muita coisa e chegar em uma
%solução analítica
function [Vcruz, Pcruz] = get_autonomy_cruise_characteristics(plane, aed_data)
    check_struct(plane, "plane", "input_planedata")
    check_struct(aed_data, "aed_data", "wrapper_aerodynamic_data")
    %seta v0 como a média dos valores de V
    alpha0 = mean(aed_data.alphas);
    %otimizar Pcruz(alpha)
    [alpha_cruz, Pcruz] = fminsearch(@(alpha) Pcruise(alpha, plane, aed_data), alpha0);
    Vcruz = V(alpha_cruz, plane, aed_data);
end

function Pcruise = Pcruise(alpha, plane, aed_data)
    %interpolação linear p obter o CD
    %cat pq acessar membros de um vetor de struct retorna elementos
    %separados, não em um vetor
    v = V(alpha, plane, aed_data);
    %CD é aprox parabólico com alpha, 
    CD = interp1(aed_data.alphas, cat(1, aed_data.stdata.CD), alpha, "makima", nan);
    if isnan(CD)
        error("Cálculo de Pcruise tentou extrapolar a curva CD(alpha) dada. alpha pedido: " ...
            + num2str(alpha))
    end
    Pcruise = 0.5*aed_data.rho*v^3*plane.Sref*CD;
end

function V = V(alpha, plane, aed_data)
    %dependendo do alpha, pode retornar número imaginário! no otimizador
    %não acontece mas pode acontecer
    %cl é aprox linear, então interpolação linear é ok
    CL = interp1(aed_data.alphas, cat(1, aed_data.stdata.CL), alpha);
    V = sqrt(aed_data.m * aed_data.g / (0.5*aed_data.rho*plane.Sref*CL));
end