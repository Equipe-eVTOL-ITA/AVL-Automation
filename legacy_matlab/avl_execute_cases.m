function avl_execute_cases(plane, cases)
    %avl espera que não existam arquivos com os mesmos nomes dos arquivos
    %de saída
    clean_files();
    %por ora, assume que todos os casos são level flight
    file_plane(plane);
    run_fn = file_run(plane, cases);
    
    avl_call(run_fn)
end

function clean_files()
    delete *.avl
    delete *.run
    delete *.fs
    delete *.st
end