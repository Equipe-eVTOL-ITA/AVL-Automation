function data = parseFSdata(fsFile)
    span = textscan(fsFile,'%*s %*s %*s %*f %*s %*s %*s %f',1,'headerlines',7);
    span = [span{:}];
    Cly = zeros(span,1);
    frewind(fsFile);
    %pega só os números
    for i = 1:span
        Cly(i,1) = cell2mat(textscan(fsFile,'%*f %*f %*f %*f %*f %*f %*f %f',1,'headerlines',19+i));
        frewind(fsFile);
    end
    disp(Cly)
    data = Cly;
end