using Unitful, StaticArrays, ..AVLFile

struct ExecutionCase
    alpha::typeof(1.0u"°")
    #permite N -> + de 1 eixo, + de 1 N -> eixo, mas não sei se é certo isso
    #assume que todos os eixos mencionados nesse vetor devem ser trimados (responsabilidade do construtor garantir)
    deflection_moment_pairs::Vector{Tuple{Int, Axes}}
    output_file_title::String
    output_directory::String
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

function run_string(ec::ExecutionCase)
    join([
        "a",
        "a " * string(ustrip(u"°", ec.alpha)),
        [
            "d$i\n"*aux_trim_axis_to_string(a) for (i, a) in ec.deflection_moment_pairs            
        ]...,
        "x",
        "fs",
        joinpath(ec.output_directory, ec.output_file_title*".fs"),
        "st",
        joinpath(ec.output_directory, ec.output_file_title*".st")
    ], "\n")*"\n"
end

#melhorar nome
struct ExecutionCaseSeries
    plane_name::String
    cases::Vector{ExecutionCase}
end

function run_string(ecs::ExecutionCaseSeries)
    join([
        "load",
        ecs.plane_name,
        "oper",
        prod(run_string.(ecs.cases)),
        "quit"
    ], "\n")*"\n"
end

function write_run_file(ecs::ExecutionCaseSeries, directory::String=pwd())::String
    ecs_str = run_string(ecs)
    filename = joinpath(directory, ecs.plane_name*".run")
    open(file -> write(file, ecs_str), filename, "w")
    filename
end