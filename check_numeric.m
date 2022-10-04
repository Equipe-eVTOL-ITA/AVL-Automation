function check_numeric(var, name)
    if ~isnumeric(var) || length(var) ~= 1
        error(name + " deve ser numérico")
    end
end