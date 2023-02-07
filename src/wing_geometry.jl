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
using Plots
Plots.plot(a::Airfoil; kwargs...) = Plots.plot(a.x, a.y; kwargs...)

abstract type AbstractWingComponent end

export WingSegment
struct WingSegment <: AbstractWingComponent
    root::WingSection
    tip::WingSection
end
span(ws::WingSegment) = ws.tip.leading_edge_relative_to_wing_root[2] - 
                        ws.root.leading_edge_relative_to_wing_root[2]

sections(ws::WingSegment) = [ws.root, ws.tip]
#assumindo incidência 0
x_vertexes(ws::WingSegment) = [
    ws.root.leading_edge_relative_to_wing_root[1]
    ws.tip.leading_edge_relative_to_wing_root[1]
    ws.tip.leading_edge_relative_to_wing_root[1] + ws.tip.chord
    ws.root.leading_edge_relative_to_wing_root[1] + ws.root.chord
]

y_vertexes(ws::WingSegment) = [
    ws.root.leading_edge_relative_to_wing_root[2]
    ws.tip.leading_edge_relative_to_wing_root[2]
    ws.tip.leading_edge_relative_to_wing_root[2]
    ws.root.leading_edge_relative_to_wing_root[2]
]

z_vertexes(ws::WingSegment) = [
    ws.root.leading_edge_relative_to_wing_root[3]
    ws.tip.leading_edge_relative_to_wing_root[3]
    ws.tip.leading_edge_relative_to_wing_root[3]
    ws.root.leading_edge_relative_to_wing_root[3]    
]

#plota no plano (ignora diedro)
function Plots.plot(ws::WingSegment; kwargs...)
    Plots.plot(x_vertexes(ws), y_vertexes(ws); kwargs...)
end

#adicionar controle aqui
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

#remover wing segment do código!
struct SectionConcatenation <: AbstractWingComponent
    sections::Vector{WingSection}
end

function Plots.plot(sc::SectionConcatenation; kwargs...)
    p = plot(;kwargs...)
    for (s1, s2) in zip(sc.sections[1:(end-1)], sc.sections[2:end])
        ws = WingSegment(s1, s2)
        p = plot!(p, x_vertexes(ws), y_vertexes(ws))
    end
    p
end

tip_segment(sc::SectionConcatenation) = WingSegment(sc.sections[end-1], sc.sections[end])

function (awt::AbstractWingTransform)(sc::SectionConcatenation)
    SectionConcatenation([sc.sections[1:(end-2)]; sc |> tip_segment |> awt |> sections])
end

struct KeepControl end

export NextRectangularSegment
#colocar mudança de aerofólio opcional
struct NextRectangularSegment <: AbstractWingTransform
    span::Unitful.Length
    #se refere ao segmento anterior?
    control::Union{Nothing, Control, KeepControl}
end

function (ns::NextRectangularSegment)(ws::WingSegment)
    new_section_control = if ns.control === KeepControl()
        ws.tip.control
    elseif  ns.control isa Control
        #ws.tip teria 2 controles
        #ainda não há suporte para 2 controles/seção
        if !isnothing(ws.tip.control)
            error("tip of segment $ws would have 2 controls, which isn't supported yet")
        else
            ws = @set ws.tip.control = ns.control
            ns.control
        end
    end

    SectionConcatenation([
        ws.root,
        ws.tip,
        WingSection(ws.tip.leading_edge_relative_to_wing_root+[0.0u"m", ns.span, 0.0u"m"],
            ws.tip.chord,
            0.0u"°",
            ws.tip.airfoil_data,
            ws.tip.claf,
            ws.tip.cd,
            ws.tip.cl,
            new_section_control)
    ])
end

