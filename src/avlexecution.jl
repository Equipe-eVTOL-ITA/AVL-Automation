using Unitful, StaticArrays, ..AVLFile

#guardar só um plane + bool timar ou não + case_number? todo processamento na run_string
struct ExecutionCase
    alpha::typeof(1.0u"°")
    #1sup <-> eixo de trimagem
    controlindices_axis_pairs::Dict{Int, Axes}
    plane_name::String
    trim::Bool
    case_number::Int
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

#tornar assíncrono?
function call_avl(run_filename::String, avl_directory::String=pwd())
    program = joinpath(avl_directory, "avl")
    run(pipeline(run_filename, `$program`))
end