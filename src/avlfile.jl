using Unitful, StaticArrays


export Axes, Pitch, Roll, Yaw, Control
@enum Axes Pitch Roll Yaw
@enum SgnDup Equal Inverted
struct Control
    name::String
    gain::Float64
    x_c_hinge::Float64
    #usar XYZhvec = 0 0 0 p/ usar hinge (p. 13)
    sgn_dup::SgnDup
    axis_to_trim::Axes
end

Base.Int(sd::SgnDup) = begin
    if sd == Equal
        1
    elseif sd == Inverted
        -1
    end
end

function avl_string(c::Control)
    "CONTROL\n" *
    "#nome, ganho, x_c dobradiça, dobradiça 0 0 0, sinal do duplicado\n" * 
    join([c.name, string(c.gain), string(c.x_c_hinge), "0 0 0", string(Int(c.sgn_dup))], " ")
end

export WingSection
struct WingSection 
    leading_edge_relative_to_wing_root::SVector{3, <:Unitful.Length}
    chord::Unitful.Length
    incidence::typeof(1.0u"°")
    airfoil_data::String
    claf::Float64
    cd::SVector{3, Float64}
    cl::SVector{3, Float64}
    control::Union{Nothing, Control}
end

using Base.Iterators

function avl_string(ws::WingSection)::String
    join([
        "#x, y, z do bordo de ataque, corda, incidência",
        "SECTION",
        join(string.(ustrip.(u"m", ws.leading_edge_relative_to_wing_root)), " ") *
            " " * string(ustrip(u"m", ws.chord)) *
            " " * string(ustrip(u"°", ws.incidence)),
        "#arquivo do aerofólio",
        "AFILE",
        ws.airfoil_data,
        "#correção de aerofólio espesso (p 16)",
        "CLAF",
        string(ws.claf),
        "#CL1 CD1 CL2 CD2 CL3 CD3 para o aerofólio",
        "CDCL",
        join(Iterators.flatten(zip(ws.cl, ws.cd)), " "),
        "#controle",
        (isnothing(ws.control) ? "#não há" : avl_string(ws.control))
    ], "\n")*"\n"
end

export Wing
struct Wing
    name::String
    vortex_distribution::SVector{4, Int}
    is_symmetric::Bool
    incidence::typeof(1.0u"°")
    component::UInt
    root_position::SVector{3, Unitful.Length}
    sections::Vector{WingSection}
end

function avl_string(w::Wing)::String
    join([
        "SURFACE",
        w.name,
        "#distribuição de vórtices",
        join(string.(w.vortex_distribution), " "),
        "#simetria geométrica no plano y=0",
        (w.is_symmetric) ? "YDUPLICATE" : "#não há simetria",
        (w.is_symmetric) ? "0" : "#####",
        "#ângulo de incidência global",
        "ANGLE",
        string(ustrip(u"°", w.incidence)),
        "#id de componente",
        "COMPONENT",
        string(w.component),
        "#posição da raiz da asa",
        "TRANSLATE",
        join(string.(ustrip.(u"m", w.root_position)), " ")
    ], "\n") * "\n" * prod(avl_string.(w.sections))
end

export Plane
#assume mach = 0, sem simetria aerodinâmica, CG na origem (mudar)
struct Plane
    name::String
    Sref::Unitful.Area
    cref::Unitful.Length
    bref::Unitful.Length
    parasitic_drag::Float64
    surfaces::Vector{Wing}
    #names of control surfaces, in the order they appear in avl file 
    controls::Vector{Control}
    function Plane(name::String,
        Sref::Unitful.Area,
        cref::Unitful.Length,
        bref::Unitful.Length,
        parasitic_drag::Float64,
        surfaces::Vector{Wing})
        new(name, Sref, cref, bref, parasitic_drag, surfaces, [
            sect.control for surf in surfaces for sect in surf.sections if !isnothing(sect.control)
        ])
    end
end

function avl_string(p::Plane)::String
    join([
        p.name,
        "#número de mach",
        "0",
        "#não há simetria aerodinâmica",
        "0 0 0",
        "#área, corda, envergadura de referência",
        join(string.([ustrip(u"m^2", p.Sref), ustrip(u"m", p.cref), ustrip(u"m", p.bref)]), " "),
        "#centro de massa",
        "0 0 0",
        "#coef arrasto parasita",
        string(p.parasitic_drag)
    ], "\n") * "\n" * prod(avl_string.(p.surfaces))
end

function write_avl_file(p::Plane, directory::String=pwd())::String
    plane_str = avl_string(p)
    filename = joinpath(directory, p.name*".avl")
    open(file -> write(file, plane_str), filename, "w")
    filename
end