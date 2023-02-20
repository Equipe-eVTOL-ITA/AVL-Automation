using ..AVLFile, ..AVLExecution, ..AVLResults, Unitful

export analyse_plane
function analyse_plane(plane::Plane, trim::Bool, alphas::AbstractVector; work_directory::String=pwd(), clean_inputs::Bool=false, clean_outputs::Bool=true)
    try
        avl_filename = write_avl_file(plane, work_directory)
        ecs = ExecutionCaseSeries(plane.name, [
            ExecutionCase(a, plane, trim, i, work_directory) for (i, a) in enumerate(alphas)
        ])
        run_filename = write_run_file(ecs, work_directory)
        #assume avl da package
        call_avl(run_filename)

        #leitura de arquivos
        CaseResults.(plane.name.*string.(1:length(alphas)), Ref(plane.controls))
    finally
        #limpeza
        if clean_inputs
            rm(avl_filename)
            rm(run_filename)
        end
        if clean_outputs
            output_filenames = plane.name.*string.(1:length(alphas)) .* [".st" ".fs"]
            rm.(output_filenames)
        end
    end
end