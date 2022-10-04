function stdata = stdata(stfilename)
    text = string(fileread(stfilename)) + ".st";
    
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
end

function val = extract_value(text, name)
    slice = extractAfter(text, name);
    scanres = textscan(slice, " = %f");
    val = scanres{1}(1);
end