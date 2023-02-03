function avl_file_plane(plane)
    if ~isstruct(plane)
        error("plane deve ser struct do tipo planedata")
    end
    planestr = string_plane(plane);
    filename = plane.name + ".avl";
    file = fopen(filename, "w");
    fprintf(file, planestr);
    fclose(file);
end