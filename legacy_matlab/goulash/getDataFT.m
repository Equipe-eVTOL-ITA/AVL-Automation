function data = getDataFT(alpha)
    ft = dataftAVL(alpha);
    ftFile = fopen(ft);
    data = parseFTdata(ftFile);
    fclose(ftFile);
    delete(ft);
end