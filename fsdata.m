function fsdata = fsdata(fsfilename)
    %fsdata deve conter vetor de structs
    %contendo {name, y, cl}
    text = fileread(fsfilename + ".fs");
    
    surfaces = string(split(text, "Surface #"));
    %1o elemento de surfaces é o título

    i = 1;
    %não sei o que o .' faz mas vem daqui: https://www.mathworks.com/matlabcentral/answers/1728680-is-it-possible-to-go-through-the-elements-of-an-array-without-resorting-to-length-in-a-for-loop
    for surf = surfaces(2:end).'
        %strtrim e whitespace - quero ler YDUP das superfícies duplicadas
        fsdata.surfaces(i).name = strtrim(string( ...
            textscan(surf, " %*d %s", 1, 'Whitespace','\n') ...
           ));
        [fsdata.surfaces(i).y, fsdata.surfaces(i).cl] = ...
            read_columns(surf);
        i = i+1;
    end
end

function [y, cl] = read_columns(surface_str)
    formatspec = "%*d %*f %f %*f %*f %*f %*f %*f %*f %f %*f %*f %*f %*f %*f";
    scanr = textscan(surface_str, formatspec, 'HeaderLines',16);
    y = scanr{1};
    cl = scanr{2};
end