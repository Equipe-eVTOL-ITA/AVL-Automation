function check_vec(vec, name, len)
    if ~isnumeric(vec) || length(vec) ~= len || isnan(len)
        error(name + " deve ser um vetor de " + string(len) + ...
            " componentes")
    end
end