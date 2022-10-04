function data = parseFTdata(ftFile)
    %pega só os números
    CL = textscan(ftFile,'%*s %f',1,'delimiter','=','headerlines',23);
    frewind(ftFile);
    CD = textscan(ftFile,'%*s %f',1,'delimiter','=','headerlines',24);
    CL = [CL{:}];
    CD = [CD{:}];
    data = [CL CD];
end