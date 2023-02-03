#permite futura adição de asa afilada
abstract type AbstractWing end

struct WingSection 
    leading_edge_relative_to_wing_root::SVector{3, Unitful.Length}
    chord::Unitful.Length
    incidence::typeof(1.0u"°")
    airfoil_data::String
    claf::Float64
    cd::SVector{3, Float64}
    cl::SVector{3, Float64}
end

using Base.Iterators: flatten

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
        join(flatten(zip(ws.cl, ws.cd)), " ")
    ], "\n")*"\n"
end

struct Wing
    vortex_distribution::SVector{4, Int}
    is_symmetric::Bool
    incidence::typeof(1.0u"°")
    component::Int
    root_position::SVector{3, Unitful.Length}
    sections::Vector{WingSection}
end