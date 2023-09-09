using Unitful, StaticArrays


export Axes, Pitch, Roll, Yaw, Control, SgnDup, Equal, Inverted
"Eixos de controle possíveis: Pitch (arfagem), Roll (rolagem), Yaw (guinada)"
@enum Axes Pitch Roll Yaw

"Opções de sinal da deflexão do reflexo da superfície de controle: Equal (mesmo sentido, usar p/ profundores), Inverted (ailerons)"
@enum SgnDup Equal Inverted

export Control
"""Representação de superfície de controle.

É passado como argumento opcional para os construtores RectangularSegment
e NextRectangularSegment (módulo WingGeometry) para especificar uma superfície
de controle.
"""
struct Control
    name::String
    gain::Float64
    x_c_hinge::Float64
    #usar XYZhvec = 0 0 0 p/ usar hinge (p. 13)
    sgn_dup::SgnDup
    axis_to_trim::Axes
end

"""
    Base.Int(sd::SgnDup)

Converte o enum SgnDup em um Int para criação do arquivo AVL.
"""
Base.Int(sd::SgnDup) = begin
    if sd == Equal
        1
    elseif sd == Inverted
        -1
    end
end

"""
    avl_string(c::Control)::String

Retorna o texto correspondente ao controle de uma seção no formato do arquivo AVL.
"""
function avl_string(c::Control)::String
    "CONTROL\n" *
    "#nome, ganho, x_c dobradiça, dobradiça 0 0 0, sinal do duplicado\n" * 
    join([c.name, string(c.gain), string(c.x_c_hinge), "0 0 0", string(Int(c.sgn_dup))], " ")
end

#não deveria ser exportado para o usuário
"Representação de uma seção de asa."
struct WingSection 
    leading_edge_relative_to_wing_root::SVector{3, <:Unitful.Length}
    chord::Unitful.Length
    incidence::typeof(1.0u"°")
    airfoil_file_path::String
    cd::SVector{3, Float64}
    cl::SVector{3, Float64}
    control::Union{Nothing, Control}
end

using Base.Iterators

"""
    avl_string(ws::WingSection)::String

Retorna o texto correspondente a uma seção de asa no formato do arquivo AVL.
"""
function avl_string(ws::WingSection)::String
    join([
        "#x, y, z do bordo de ataque, corda, incidência",
        "SECTION",
        join(string.(ustrip.(Float64, u"m", ws.leading_edge_relative_to_wing_root)), " ") *
            " " * string(ustrip(Float64, u"m", ws.chord)) *
            " " * string(ustrip(Float64, u"°", ws.incidence)),
        "#arquivo do aerofólio",
        "AFILE",
        ws.airfoil_file_path,
        "#CL1 CD1 CL2 CD2 CL3 CD3 para o aerofólio",
        "CDCL",
        join(Iterators.flatten(zip(ws.cl, ws.cd)), " "),
        "#controle",
        (isnothing(ws.control) ? "#não há" : avl_string(ws.control))
    ], "\n")*"\n"
end

#cálculo de área, cma de asa, etc
"Representação de superfície aerodinâmica."
struct Wing
    name::String
    vortex_distribution::SVector{4, Int}
    is_symmetric::Bool
    incidence::typeof(1.0u"°")
    component::UInt
    root_position::SVector{3, Unitful.Length}
    sections::Vector{WingSection}
end

"""
    avl_string(w::Wing)::String

Retorna o texto correspondente a uma superfície aerodinâmica no formato do arquivo AVL.
"""
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
        string(ustrip(Float64, u"°", w.incidence)),
        "#id de componente",
        "COMPONENT",
        string(w.component),
        "#posição da raiz da asa",
        "TRANSLATE",
        join(string.(ustrip.(Float64, u"m", w.root_position)), " ")
    ], "\n") * "\n" * prod(avl_string.(w.sections))
end

export Plane
"""
Representação de avião completo.

Assume M = 0 (escoamento incompressível), não há simetria aerodinâmica, CG na origem.

Deve ser criado com as superfícies criadas com o módulo WingGeometry.
"""
struct Plane
    name::String
    Sref::Unitful.Area
    cref::Unitful.Length
    bref::Unitful.Length
    parasitic_drag::Float64
    surfaces::Vector{Wing}
    #names of control surfaces, in the order they appear in avl file 
    controls::Vector{Control}
    #melhorar construtor
    function Plane(name::String,
        Sref::Unitful.Area,
        cref::Unitful.Length,
        bref::Unitful.Length,
        parasitic_drag::Float64,
        surfaces::Vector{Wing})
        unique_controls = unique(x -> x.name, [sect.control for surf in surfaces for sect in surf.sections if !isnothing(sect.control)])
        new(name, Sref, cref, bref, parasitic_drag, surfaces, unique_controls)
    end
end

"""
    avl_string(p::Plane)::String

Retorna o texto correspondente a um avião no formato do arquivo AVL.

Esta função retorna todo o texto necessário para criar um arquivo AVL.
"""
function avl_string(p::Plane)::String
    join([
        p.name,
        "#número de mach",
        "0",
        "#não há simetria aerodinâmica",
        "0 0 0",
        "#área, corda, envergadura de referência",
        join(string.([ustrip(Float64, u"m^2", p.Sref), ustrip(Float64, u"m", p.cref), ustrip(Float64, u"m", p.bref)]), " "),
        "#centro de massa",
        "0 0 0",
        "#coef arrasto parasita",
        string(p.parasitic_drag)
    ], "\n") * "\n" * prod(avl_string.(p.surfaces))
end

"""
    write_avl_file(p::Plane, directory::String)::String

Cria um arquivo .avl com a descrição da geometria do avião e retorna o caminho do arquivo.
O caminho do arquivo criado é `directory + <nome do avião>.avl`
"""
function write_avl_file(p::Plane, directory::String)::String
    plane_str = avl_string(p)
    filename = joinpath(directory, p.name*".avl")
    open(file -> write(file, plane_str), filename, "w")
    filename
end