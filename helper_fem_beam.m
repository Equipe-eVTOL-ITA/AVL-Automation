function [u, theta] = helper_fem_beam(shear, moment, y, I, E, bc1, bc2)
    check_vec(y, "y", nan)
    check_vec(shear, "shear", length(y))
    check_vec(moment, "moment", length(y))
    %tipos de bc - fixed, simsup, free
    if all(bc1 ~= ["fixed", "simsup", "free"])
        error("condição de contorno deve ser fixed, simsup ou free")
    end
    if all(bc2 ~= ["fixed", "simsup", "free"])
        error("condição de contorno deve ser fixed, simsup ou free")
    end

    n = length(y);
    load = zeros(2*n, 1);
    load(1:2:end) = shear;
    load(2:2:end) = moment;

    K = global_rigidity_matrix(E, I, diff(y));

    if bc1 == "fixed"
        K(1:2, :) = 0;
        K(1,1) = 1;
        K(2,2) = 1;
        load(1:2) = 0;
    elseif bc1 == "simsup"
        K(1,:) = 0;
        K(1,1) = 1;
        load(1) = 0;
    end
    if bc2 == "fixed"
        K((end-1):end, :) = 0;
        K(end-1, end-1) = 1;
        K(end, end) = 1;
        load((end-1):end) = 0;
    elseif bc2 == "simsup"
        K((end-1),:) = 0;
        K(end-1, end-1) = 1;
        load(end-1) = 0;
    end
    
    deformation = K \ load;
    u = deformation(1:2:end);
    theta = deformation(2:2:end);
end

% Matriz de rigidez global do elemento
% N é a dimensão da matriz global e i é o número do elemento
function k = element_rigidity_matrix(E, I, L)
    % Nó 1
    M11 = E*I*[12/L^3 6/L^2;
                6/L^2 4/L];
    M12 = E*I*[-12/L^3 6/L^2; 
               -6/L^2 2/L];
    % Nó 2
    M21 = E*I*[-12/L^3 -6/L^2;
                6/L^2 2/L];
    M22 = E*I*[12/L^3 -6/L^2; 
                -6/L^2 4/L];
    % Matriz local
    k = [M11 M12; 
        M21 M22];
end

function K = global_rigidity_matrix(E, I, Ls)
    %1 nó a mais que comprimento
    N = length(Ls)+1;
    K = zeros(2*N);
    for i = 1:(N-1)
        K(2*i-1 : 2*i+2, 2*i-1 : 2*i+2) = ...
            K(2*i-1 : 2*i+2, 2*i-1 : 2*i+2) + ...
            element_rigidity_matrix(E, I, Ls(i));
    end
end