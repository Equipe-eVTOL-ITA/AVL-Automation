function run_fn = avl_file_run(plane, cases)
    rs = string_run(plane, cases);
    filename = plane.name+".run";
    file = fopen(filename, "w");
    fprintf(file, rs);
    fclose(file);
    run_fn = filename;
end