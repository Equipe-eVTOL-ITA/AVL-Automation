% L, E, I: vetores com as respecitvas grandezas de cada elemento
% S: vetor com os esforços horizontais e verticais atuando em cada nó
% cont: vetor com as condições de contorno de cada nó em x e y
% 1 indica deslocamento nulo e 0 indica condição de contorno não especificada
function u = Elem_Fin(L, E, I, S, cont)

    N = length(S); n = length(E);
    % Matriz de rigidez global
    K = zeros(N); 
    for i = 1:n
        Ke = M_rigid(E(i), I(i), L(i), N, i); 
        K = K + Ke;
    end

    % Condições de contorno
    for i = 1:N
        if cont(i)
            K(i, :) = 0;
            K(i, i) = 1;
            S(i) = 0;
        end
    end

   % Resolver os sistema
   u = K\S;

   for i = 1:n
        [Ke,k] = M_rigid(E(i), I(i), L(i), N, i); 
        S = k*[u(i);u(i+1)]
    end
end

% Matriz de rigidez global do elemento
% N é a dimensão da matriz global e i é o número do elemento
function [Ke,k] = M_rigid(E, I, L, N, i)
% Nó 1
M11 = E*I*[12/L^3 6/L^2; 6/L^2 4/L];
M12 = E*I*[-12/L^3 6/L^2; -6/L^2 2/L];
% Nó 2
M21 = E*I*[-12/L^3 -6/L^2; 6/L^2 2/L];
M22 = E*I*[12/L^3 -6/L^2; -6/L^2 4/L];
% Matriz local
k = [M11 M12; M21 M22];
% Matriz global
Ke = zeros(N); size(Ke)
Ke(2*i-1 : 2*i+2, 2*i-1 : 2*i+2) = k; size(Ke)
end
