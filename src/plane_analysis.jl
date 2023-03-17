using ..AVLResults, Unitful
using ..AVLFile: Plane, write_avl_file
using ..AVLExecution: ExecutionCase, ExecutionCaseSeries, write_run_file, call_avl

export analyze_plane
"""
    analyse_plane(plane::Plane, trim::Bool, alphas::AbstractVector; work_directory::String=pwd(), clean_inputs::Bool=false, clean_outputs::Bool=true)

Retorna um vetor de CaseResults referente ao avião `plane`, nas condições de ângulo de ataque `alphas`, com ou sem compensação `trim`.

O parâmetro `work_directory` especifica um diretório onde todos os arquivos relacionados à execução do AVL devem ser salvos.

Os parâmetros `clean_inputs` e `clean_outputs` determinam se os arquivos devem ser apagados após a execução do AVL. O AVL não é capaz de sobrescrever arquivos
sem pedir permissão para o usuário, o que alteraria a sequência de comandos do arquivo .run. Assim, por padrão os arquivos de saída serão apagados. Se você quiser
inspecionar esses arquivos, lembre-se de apagá-los antes de executar o AVL novamente. Ou mude o `work_directory`. Ou faça o que quiser. Sua conta e risco.
"""
function analyze_plane(plane::Plane, trim::Bool, alphas::AbstractVector; work_directory::String=pwd(), clean_inputs::Bool=false, clean_outputs::Bool=true)
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