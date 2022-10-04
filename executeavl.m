function executeavl(plane, cases)
    %por ora, assume que todos os casos são level flight
    plane_avl_file(plane);
    run_fn = run_avl_file(plane, cases);
    %avl espera que não existam arquivos com os mesmos nomes dos arquivos
    %de saída
    clean_output_files();
    avlcall(run_fn)
end

function clean_output_files()
    delete *.fs
    delete *.ft
end