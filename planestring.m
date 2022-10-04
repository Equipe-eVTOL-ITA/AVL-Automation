%assume M = 0, sem simetrias, CM na origem
function planestring = planestring(planedata)
    planestring = planedata.name + "\n0\n0 0 0\n" + ...
    string(planedata.Sref) + " " + string(planedata.cref) + ...
    " " + string(planedata.bref) + "\n0 0 0\n" + ...
    string(planedata.parasite_drag) + "\n";
    
    i = 1;
    for wingdata = planedata.wingdatas
        planestring = planestring + wingstring(wingdata, i);
        i = i + 1;
    end
end