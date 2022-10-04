function plane_avl_file(plane)
    if ~isstruct(plane)
        error("plane deve ser struct do tipo planedata")
    end
    planestr = planestring(plane);
    filename = plane.name + ".avl";
    file = fopen(filename, "w");
    fprintf(file, planestr);
    fclose(file);
end