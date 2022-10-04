function stdata = stdata(stfilename)
    text = string(fileread(stfilename));
    %lista expansível de coeficientes
    stdata.CL = extract_value(text, 24, "CLtot", 1);
    stdata.CD = extract_value(text, 25, "CDtot", 1);
    stdata.alpha = extract_value(text, 16, "Alpha", 1);
    stdata.CM = extract_value(text, 21, "Cmtot", 2);
    stdata.e = extract_value(text, 28, "e", 2);

    %derivadas de estabilidade
    stdata.CLa = extract_value_table(text, 38, "CLa", 1);
    stdata.Cma = extract_value_table(text, 41, "Cma", 1);
    
    stdata.Xnp = extract_value(text, 51, "Neutral point  Xnp", 1);
end

function val = extract_value(text, line, name, position)
    formatspec = strjoin(repmat("%*s = %*f", position-1)) + " " + name ...
        + " = %f";
    val = textscan(text, formatspec, 1, 'HeaderLines',line-1);
end

function val = extract_value_table(text, line, name, position)
    %remover a | e texto anterior da linha desejada
    lines = splitlines(text);
    query_line = lines(line);
    line_parts = split(query_line, "|");
    data = line_parts(2);
    val = extract_value(data, 1, name, position);
end