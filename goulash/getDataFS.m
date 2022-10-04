function data = getDataFS(alpha)
    fs = datafsAVL(alpha);
    fsFile = fopen(fs);
    data = parseFSdata(fsFile);
    fclose(fsFile);
    delete(fs);
end