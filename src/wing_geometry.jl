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

export WingSegment
struct WingSegment
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

struct Verticalize <: AbstractWingTransform end

#troca y e z
function (v::Verticalize)(ws::WingSegment)
    new_segment = @set ws.tip.leading_edge_relative_to_wing_root = [
        ws.tip.leading_edge_relative_to_wing_root[1]
        ws.tip.leading_edge_relative_to_wing_root[3]
        ws.tip.leading_edge_relative_to_wing_root[2]
    ]
    new_segment
end

#plot 3d?
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

#remover wing segment do código!?
struct SectionConcatenation
    sections::Vector{WingSection}
end

function Plots.plot(sc::SectionConcatenation; kwargs...)
    xs = [[sect.leading_edge_relative_to_wing_root[1] for sect in sc.sections]; 
        [sect.leading_edge_relative_to_wing_root[1] + sect.chord for sect in reverse(sc.sections)]]
    ys = [sect.leading_edge_relative_to_wing_root[2] for sect in cat(sc.sections, reverse(sc.sections), dims=1)]
    p = plot(xs, ys;kwargs...)
    p
end

tip_segment(sc::SectionConcatenation) = WingSegment(sc.sections[end-1], sc.sections[end])

#fazer transformações lazy? permitiria verificar coerência das transformações
function (awt::AbstractWingTransform)(sc::SectionConcatenation)
    SectionConcatenation([sc.sections[1:(end-2)]; sc |> tip_segment |> awt |> sections])
end

export RectangularSegment
struct RectangularSegment
    span::Unitful.Length
    chord::Unitful.Length
    control::Union{Nothing, Control}
end

#retornar section concatenation
function (rs::RectangularSegment)(a::Airfoil)
    SectionConcatenation([
        WingSection([0.0, 0.0, 0.0]*u"m", rs.chord, 0u"°", a.filename, claf(a), a.cd, a.cl, rs.control),
        WingSection([0.0u"m", rs.span, 0.0u"m"], rs.chord, 0u"°", a.filename, claf(a), a.cd, a.cl, rs.control)
    ])
end

struct KeepControl end

export NextRectangularSegment
#colocar mudança de aerofólio opcional
struct NextRectangularSegment <: AbstractWingTransform
    span::Unitful.Length
    #se refere ao segmento adicionado inteiro
    control::Union{Nothing, Control, KeepControl}
end

function (ns::NextRectangularSegment)(sc::SectionConcatenation)
    new_section_control = if ns.control === KeepControl()
        sc.sections[end].control
    elseif  ns.control isa Control
        #ws.tip teria 2 controles
        #ainda não há suporte para 2 controles/seção
        if !isnothing(sc.sections[end].control)
            error("tip of segment $(tip_segment(sc)) would have 2 controls, which isn't supported yet")
        else
            sc = @set sc.sections[end].control = ns.control
            ns.control
        end
    end
    tip = sc.sections[end]
    SectionConcatenation([
        sc.sections...,
        WingSection(tip.leading_edge_relative_to_wing_root+[0.0u"m", ns.span, 0.0u"m"],
            tip.chord,
            0.0u"°",
            tip.airfoil_data,
            tip.claf,
            tip.cd,
            tip.cl,
            new_section_control)
    ])
end

export WingConstructor
struct WingConstructor
    name::String
    vortex_distribution::SVector{4, Int}
    is_symmetric::Bool
    component::Int
    root_position::SVector{3, Unitful.Length}
end

function (wc::WingConstructor)(sc::SectionConcatenation)
    Wing(wc.name, wc.vortex_distribution, wc.is_symmetric, 0.0u"°", wc.component, wc.root_position, sc.sections)
end

function Plots.plot(w::Wing; kwargs...)
    plot(SectionConcatenation(w.sections); kwargs...)
end