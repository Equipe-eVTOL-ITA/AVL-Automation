function executeavl(plane, cases)
    clean_files();
    %por ora, assume que todos os casos são level flight
    plane_avl_file(plane);
    run_fn = run_avl_file(plane, cases);
    %avl espera que não existam arquivos com os mesmos nomes dos arquivos
    %de saída
    avlcall(run_fn)
end

function clean_files()
    delete *.avl
    delete *.run
    delete *.fs
    delete *.st
end