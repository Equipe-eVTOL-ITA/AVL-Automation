using ..AVLFile, ..AVLExecution, ..AVLResults, Unitful

function analyse_plane(plane::Plane, trim::Bool, alphas::AbstractVector, output_directory::String)
    write_avl_file(plane)
    ecs = ExecutionCaseSeries(plane.name, [
        ExecutionCase(a, plane, trim, i, output_directory) for (i, a) in enumerate(alphas)
    ])
    write_run_file(ecs)
    #assume avl no pwd
    call_avl(write_run_file(ecs))

    #leitura de arquivos
    CaseResults.(plane.name.*string.(1:length(alphas)), Ref(plane.controls))
end