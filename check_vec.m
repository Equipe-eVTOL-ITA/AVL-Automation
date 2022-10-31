function check_vec(vec, name, len)
    %se len for nan, ignora tamanho
    if ~isnumeric(vec) || (~isnan(len) && length(vec) ~= len)
        error(name + " deve ser um vetor de " + string(len) + ...
            " componentes")
    end
end