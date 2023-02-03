function check_struct(var, name, constructor_name)
    if ~isstruct(var)
        error(name+" deve ser uma struct do tipo " + constructor_name)
    end
end