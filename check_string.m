function check_string(str, name)
    if ~isstring(str)
        error(name + " deve ser string (aspas duplas)")
    end
end