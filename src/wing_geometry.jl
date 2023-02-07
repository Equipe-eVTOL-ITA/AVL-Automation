using Unitful, StaticArrays, ..AVLFile

export Airfoil
struct Airfoil
    x::Vector{Float64}
    y::Vector{Float64}
    cl::SVector{3, Float64}
    cd::SVector{3, Float64}
    filename::String
    directory::String
    function Airfoil(filename::String, cl::AbstractVector, cd::AbstractVector, directory::String=pwd())
        xy_string_lines = readlines(joinpath(directory, filename))[2:end] .|> split
        x = parse.(Float64, first.(xy_string_lines))
        y = parse.(Float64, last.(xy_string_lines))
        new(x, y, cl, cd, filename, directory)
    end
end

max_diff(vec) = maximum(vec) - minimum(vec)

function claf(a::Airfoil)
    unique_x = unique(a.x)

    tmax = maximum(max_diff(a.y[findall(el -> el ≈ x, a.x)]) for x in unique_x)

    1 + 0.77 * tmax
end
import Plots.plot
plot(a::Airfoil; kwargs...) = plot(a.x, a.y; kwargs...)

abstract type AbstractWingComponent end

export WingSegment
struct WingSegment <: AbstractWingComponent
    root::WingSection
    tip::WingSection
end
span(ws::WingSegment) = ws.tip.leading_edge_relative_to_wing_root[2] - 
                        ws.root.leading_edge_relative_to_wing_root[2]
#plota no plano (ignora diedro)
function plot(ws::WingSegment; kwargs...)
    x = [
        ws.root.leading_edge_relative_to_wing_root[1]
        ws.tip.leading_edge_relative_to_wing_root[1]
        ws.tip.leading_edge_relative_to_wing_root[1] + ws.tip.chord
        ws.root.leading_edge_relative_to_wing_root[1] + ws.root.chord
    ]
    y = [
        ws.root.leading_edge_relative_to_wing_root[2]
        ws.tip.leading_edge_relative_to_wing_root[2]
        ws.tip.leading_edge_relative_to_wing_root[2]
        ws.root.leading_edge_relative_to_wing_root[2]
    ]
    plot(x, y; kwargs...)
end

#abstract type desnecessário?
abstract type AbstractWingPrimitive end
export RectangularSegment
struct RectangularSegment <: AbstractWingPrimitive
    span::Unitful.Length
    chord::Unitful.Length
end

function (rs::RectangularSegment)(a::Airfoil, control::Union{Nothing, Control} = nothing)
    WingSegment(
        WingSection([0.0, 0.0, 0.0]*u"m", rs.chord, 0u"°", a.filename, claf(a), a.cd, a.cl, control),
        WingSection([0.0u"m", rs.span, 0.0u"m"], rs.chord, 0u"°", a.filename, claf(a), a.cd, a.cl, control))
end

#desnecessário?
abstract type AbstractWingTransform end
export Taper
struct Taper <: AbstractWingTransform
    tip_to_root_chord_ratio::Float64
end

using Setfield

function (t::Taper)(ws::WingSegment)
    tip_chord = t.tip_to_root_chord_ratio * ws.root.chord
    tip_leading_edge_x = ws.tip.leading_edge_relative_to_wing_root[1] + 
        ws.root.chord/4 - tip_chord/4

    new_segment = @set ws.tip.chord = tip_chord
    new_segment = @set new_segment.tip.leading_edge_relative_to_wing_root = [tip_leading_edge_x;
                            new_segment.tip.leading_edge_relative_to_wing_root[2:3]]
    new_segment
end
export Sweep
struct Sweep <: AbstractWingTransform
    #usar ° do unitful aqui
    c_4_angle::Number
end

function (s::Sweep)(ws::WingSegment)
    tip_leading_edge_x = ws.root.leading_edge_relative_to_wing_root[1] +
        ws.root.chord/4 + 
        sin(s.c_4_angle) * span(ws) - ws.tip.chord/4
    new_segment = @set ws.tip.leading_edge_relative_to_wing_root = [tip_leading_edge_x;
                        ws.tip.leading_edge_relative_to_wing_root[2:3]]
    new_segment
end
#plot 3d
struct Dihedral <: AbstractWingTransform
    angle::Number
end

function (d::Dihedral)(ws::WingSegment)
    tip_z = ws.root.leading_edge_relative_to_wing_root[3] + 
        tan(d.angle) * span(ws)
    new_segment = @set ws.tip.leading_edge_relative_to_wing_root = [
        ws.tip.leading_edge_relative_to_wing_root[1:2];
        tip_z
    ]
    new_segment
end


struct SegmentConcatenation <: AbstractWingComponent
    segments::Vector{WingSegment}
end

function Base.:*(wss...)
    SegmentConcatenation(collect(wss))
end