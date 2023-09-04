using Unitful, StaticArrays
using ..AVLFile: Plane, Axes, Pitch, Roll, Yaw

#guardar só um plane + bool timar ou não + case_number? todo processamento na run_string
#assume beta = 0
"Representação dos dados de entrada de um caso de execução do AVL, com ângulo de ataque fixo.

Pode ser compensado ou não."
struct ExecutionCase
    alpha::typeof(1.0u"°")
    #sup controle <-> eixo de compensação
    controlindices_axis_pairs::Dict{Int, Axes}
    plane_name::String
    trim::Bool
    case_number::Int
    output_directory::String
end

function ExecutionCase(alpha, plane::Plane, trim::Bool, case_number::Int, output_directory::String)
    ExecutionCase(alpha, Dict(index => c.axis_to_trim for (index, c) in enumerate(plane.controls)), plane.name, trim, case_number, output_directory)
end

aux_trim_axis_to_string(a::Axes) = begin
    if a == Pitch
        "pm 0"
    elseif a == Roll
        "rm 0"
    elseif a == Yaw
        "ym 0"
    end
end

using Base.Iterators

"""
    run_string(ec::ExecutionCase)

Retorna o texto correspondente a um caso de execução, no formato do arquivo .run.
"""
function run_string(ec::ExecutionCase)
    #enumerate(getproperty.(plane.controls, :axis_to_trim))
    trim_string = (ec.trim) ? join([
        "d$i\n"*aux_trim_axis_to_string(a) for (i, a) in ec.controlindices_axis_pairs
    ], "\n") : "#sem compensação"

    output_file_title = ec.plane_name * string(ec.case_number)

    join([
        "a",
        "a " * string(ustrip(u"°", ec.alpha)),
        trim_string,
        "x",
        "fs",
        joinpath(ec.output_directory, output_file_title*".fs"),
        "st",
        joinpath(ec.output_directory, output_file_title*".st")
    ], "\n")*"\n"
end

#melhorar nome
"""Representação de série de casos de execução.

No AVL, é mais eficiente rodar muitos casos em uma sessão do que rodar várias seções com 
um caso cada, devido à fatoração de uma matriz referente à geometria do avião.
"""
struct ExecutionCaseSeries
    plane_name::String
    cases::Vector{ExecutionCase}
end

"""
    run_string(ecs::ExecutionCaseSeries)

Retorna o texto referente à execução de uma série de casos no AVL.

Este texto inclui toda a informação necessária para a criação de um arquivo .run,
inclusive o carregamento da geometria.

**OBS**: assume que o arquivo .avl está no diretório de execução do AVL, o que é incompatível com
arquivos .avl salvos em outros diretórios (consertar!)
"""
function run_string(ecs::ExecutionCaseSeries)
    join([
        "load",
        ecs.plane_name,
        "oper",
        prod(run_string.(ecs.cases)),
        "quit"
    ], "\n")*"\n"
end

"""
    write_run_file(ecs::ExecutionCaseSeries, directory::String)::String

Cria um arquivo .run na pasta `directory` e retorna seu caminho.
"""
function write_run_file(ecs::ExecutionCaseSeries, directory::String)::String
    ecs_str = run_string(ecs)
    filename = joinpath(directory, ecs.plane_name*".run")
    open(file -> write(file, ecs_str), filename, "w")
    filename
end

export call_avl
#tornar assíncrono?
"""
    call_avl(run_filename::String, avl_directory::String=dirname(@__DIR__))

Executa o AVL com um arquivo de execução `.run`.

Por padrão, usa o executável encontrado na raíz da package, acima do diretório `src/`.
"""
function call_avl(run_filename::String, avl_directory::String=dirname(@__DIR__))
    program = joinpath(avl_directory, "avl")
    run(pipeline(run_filename, `$program`))
end

export run_avl
"""
    run_avl(avl_directory::String=dirname(@__DIR__))

Executa o AVL interativamente.

Por padrão, usa o executável encontrado na raíz da package, acima do diretório `src/`.
"""
function run_avl(avl_directory::String=dirname(@__DIR__))
    program = joinpath(avl_directory, "avl")
    run(`$program`)
end

using DefaultApplication

export doc_avl
"""
    doc_avl(avl_doc_directory::String=dirname(@__DIR__))

Abre a documentação do AVL no leitor de pdf padrão.

Por padrão, usa o pdf encontrado na raíz da package.
"""
function doc_avl(avl_doc_directory::String=dirname(@__DIR__))
    DefaultApplication.open(joinpath(avl_doc_directory, "AVL_User_Primer.pdf"))
end