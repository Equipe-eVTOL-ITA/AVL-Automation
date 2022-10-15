function stdata = stdata(stfilename, plane)
    check_string(stfilename, "stfilename")
    if ~isstruct(plane)
        error("plane deve ser struct do tipo planedata")
    end

    text = string(fileread(stfilename + ".st"));
    
    %lista expansível de coeficientes
    
    stdata.CL = extract_value(text, "CLtot");
    stdata.CD = extract_value(text, "CDtot");
    stdata.alpha = extract_value(text, "Alpha");
    stdata.CM = extract_value(text, "Cmtot");
    %espaços para evitar matches em palavras
    stdata.e = extract_value(text, " e ");

    %derivadas de estabilidade
    stdata.CLa = extract_value(text, "CLa");
    stdata.Cma = extract_value(text, "Cma");
    
    stdata.Xnp = extract_value(text, "Xnp");

    %sups controle
    for wd = plane.wingdatas
        cd = wd.controldata;
        if ~isstruct(cd)
            continue
        end
        %geração dinâmica de campos
        %(https://www.mathworks.com/help/matlab/matlab_prog/generate-field-names-from-variables.html)
        stdata.(cd.name + "_deflection") = extract_value(text, cd.name);
    end
end

function val = extract_value(text, name)
    slice = extractAfter(text, name);
    scanres = textscan(slice, " = %f");
    val = scanres{1}(1);
end