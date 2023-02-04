#permite futura adição de asa afilada
abstract type AbstractWing end

@enum SgnDup Equal Inverted
struct Control
    name::String
    gain::Float64
    x_c_hinge::Float64
    #usar XYZhvec = 0 0 0 p/ usar hinge (p. 13)
    sgn_dup::SgnDup
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

#colocar controle
struct WingSection 
    leading_edge_relative_to_wing_root::SVector{3, Unitful.Length}
    chord::Unitful.Length
    incidence::typeof(1.0u"°")
    airfoil_data::String
    claf::Float64
    cd::SVector{3, Float64}
    cl::SVector{3, Float64}
    control::Union{Nothing, Control}
end

using Base.Iterators

function avl_string(ws::WingSection)
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

struct Wing
    name::String
    vortex_distribution::SVector{4, Int}
    is_symmetric::Bool
    incidence::typeof(1.0u"°")
    component::UInt
    root_position::SVector{3, Unitful.Length}
    sections::Vector{WingSection}
end

function avl_string(w::Wing)
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