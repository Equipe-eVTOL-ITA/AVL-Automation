using Unitful, StaticArrays, ..AVLFile

struct ExecutionCase
    alpha::typeof(1.0u"°")
    axes_to_trim::Vector{Axes}
    #mudar! significado confuso + não é ergonômico
    control_surface_trim_axis::Vector{Union{Nothing, Axes}}
    output_file_title::String
    output_directory::String
end

aux_control_surface_trim(a::Axes, to_trim::Vector{Axes}) = begin
    if !(a in to_trim)
        nothing
    end

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
            (isnothing(aux_control_surface_trim(a, ec.axes_to_trim))) ? "" : "d$i\n" * aux_control_surface_trim(a, ec.axes_to_trim)
            for (i, a) in Iterators.filter(i_a -> !isnothing(i_a[2]), enumerate(ec.control_surface_trim_axis))
        ]...,
        "x",
        "fs",
        joinpath(ec.output_directory, ec.output_file_title*".fs"),
        "st",
        joinpath(ec.output_directory, ec.output_file_title*".st")
    ], "\n")*"\n"
end