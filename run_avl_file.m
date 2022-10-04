function run_fn = run_avl_file(plane, cases)
    rs = runstring(plane, cases);
    filename = plane.name+".run";
    file = fopen(filename, "w");
    fprintf(file, rs);
    fclose(file);
    run_fn = filename;
end