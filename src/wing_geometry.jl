using ..AVLFile

export Airfoil
struct Airfoil
    x::Vector{Float64}
    y::Vector{Float64}
    filename::String
    directory::String
    function Airfoil(filename::String, directory::String=pwd())
        xy_string_lines = readlines(joinpath(directory, filename))[2:end] .|> split
        x = parse.(Float64, first.(xy_string_lines))
        y = parse.(Float64, last.(xy_string_lines))
        new(x, y, filename, directory)
    end
end

import Plots.plot
plot(a::Airfoil; kwargs...) = plot(a.x, a.y; kwargs...)