using Unitful, StaticArrays
using ..AVLFile: WingSection, Wing, Control

export Airfoil
"""Representação de aerofólio com as informações necessárias para plot e entrada no AVL.

O arquivo de entrada DEVE estar em formato selig.

Os vetores `cl`, `cd` devem conter 3 elementos cada, com o coeficiente próximo da região
de estol negativo, próximo da região de Cd mínimo, e próximo da região de estol positivo.

A importação de um aerofólio é o primeiro passo na criação de uma asa.

Pode ser plotado com plot(airfoil, aspect_ratio=:equal)
"""
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

filepath(a::Airfoil) = joinpath(a.directory, a.filename)

export camber_line_points
function camber_line_points(a::Airfoil)
    #ASSUMING selig file has ODD number of elements
    leading_edge_index = (length(a.x)+1)/2 |> Int
    x = a.x[leading_edge_index:end]
    y = (a.y[leading_edge_index:end] + a.y[leading_edge_index:-1:1]) / 2
    x, y
end

using RecipesBase

@recipe function f(a::Airfoil)
    aspect_ratio --> :equal
    label --> ""
    a.x, a.y
end

"""
Representação de segmento de asa através de uma seção raiz e uma seção de ponta.

Necessário para usar as transformações geométricas desejadas e garantir que sempre há um
número válido de seções (>= 2).
"""
struct WingSegment
    root::WingSection
    tip::WingSection
end

span(ws::WingSegment) = ws.tip.leading_edge_relative_to_wing_root[2] - 
                        ws.root.leading_edge_relative_to_wing_root[2]

sections(ws::WingSegment) = [ws.root, ws.tip]

export AbstractWingTransform
"""
Transformações aplicáveis a um segmento de asa.

Devem ser aplicadas a uma sequência de segmentos
(SectionConcatenation) com a sintaxe `objeto_taper(sequência de segmentos)`,
ou ainda com o operador pipe `|>` (método sugerido). Esta aplicação retorna um novo objeto do 
mesmo tipo, com a transformação aplicada.

Podem ser usadas após a criação de um primeiro segmento de asa com RectangularSegment para 
transformar o segmento mais externo da asa.

Ver Taper, Sweep, Verticalize, Dihedral.
"""
abstract type AbstractWingTransform end

export Taper
"""
Afilamento de segmento de asa.

Deve manter o enflechamento do quarto de corda do segmento.

Deve ser usado como uma AbstractWingTransform.
"""
struct Taper <: AbstractWingTransform
    tip_to_root_chord_ratio::Float64
end

using Setfield
#documentar essas chamadas???
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
"""
Enflechamento de segmento de asa.

O ângulo deve ser especificado usando u"°" do Unitful.

Deve ser usado como uma AbstractWingTransform.
"""
struct Sweep <: AbstractWingTransform
    #usar ° do unitful aqui
    c_4_angle::Number
end

function (s::Sweep)(ws::WingSegment)
    tip_leading_edge_x = ws.root.leading_edge_relative_to_wing_root[1] +
        ws.root.chord/4 + 
        tan(s.c_4_angle) * span(ws) - ws.tip.chord/4
    new_segment = @set ws.tip.leading_edge_relative_to_wing_root = [tip_leading_edge_x;
                        ws.tip.leading_edge_relative_to_wing_root[2:3]]
    new_segment
end

export Verticalize
"""
Transforma um segmento em vertical.

Deve ser usado como uma AbstractWingTransform.
"""
struct Verticalize <: AbstractWingTransform end

#troca y e z
function (v::Verticalize)(ws::WingSegment)

    new_segment = @set ws.tip.leading_edge_relative_to_wing_root = [
        ws.tip.leading_edge_relative_to_wing_root[1]
        ws.root.leading_edge_relative_to_wing_root[2]
        ws.tip.leading_edge_relative_to_wing_root[3] + span(ws)
    ]
    new_segment
end

#plot 3d?
export Dihedral
"""
Aplica um diedro a um segmento de asa.

O ângulo deve ser especificado usando u"°" do Unitful.

Deve ser usado como uma AbstractWingTransform.
"""
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

"""
Sequência de seções para representação de asa.

As seções estão ordenadas da raiz para a ponta da asa.
"""
struct SectionConcatenation
    sections::Vector{WingSection}
end

@recipe function f(sc::SectionConcatenation, top_view::Bool=true)
    if top_view
        label --> ""
        aspect_ratio --> :equal
        xs = [
            getindex.(getproperty.(sc.sections, :leading_edge_relative_to_wing_root), 1)
            (getindex.(getproperty.(sc.sections, :leading_edge_relative_to_wing_root), 1) + getproperty.(sc.sections, :chord)) |> reverse
        ]
        ys = [
            getindex.(getproperty.(sc.sections, :leading_edge_relative_to_wing_root), 2)
            (getindex.(getproperty.(sc.sections, :leading_edge_relative_to_wing_root), 2)) |> reverse
        ]

        for (inner_sec, outer_sec) in zip(sc.sections[1:(end-1)], sc.sections[2:end])
            if inner_sec.control == outer_sec.control && !isnothing(inner_sec.control)
                @series begin
                    label := inner_sec.control.name
                    control_xs = [
                        #só funciona p x_c_hinge > 0!
                        inner_sec.leading_edge_relative_to_wing_root[1] + inner_sec.control.x_c_hinge * inner_sec.chord
                        outer_sec.leading_edge_relative_to_wing_root[1] + inner_sec.control.x_c_hinge * outer_sec.chord
                        outer_sec.leading_edge_relative_to_wing_root[1] + outer_sec.chord
                        inner_sec.leading_edge_relative_to_wing_root[1] + inner_sec.chord
                    ]
                    control_ys = [
                        inner_sec.leading_edge_relative_to_wing_root[2]
                        outer_sec.leading_edge_relative_to_wing_root[2]
                        outer_sec.leading_edge_relative_to_wing_root[2]
                        inner_sec.leading_edge_relative_to_wing_root[2]
                    ]
                    control_xs, control_ys
                end
            end
        end

    else
        label --> ""
        aspect_ratio --> :equal
        #eixo x: coordenadas y
        #eixo y: coordenadas z
        #assume incidência = 0
        xs = [
            getindex.(getproperty.(sc.sections, :leading_edge_relative_to_wing_root), 2)
        ]
        ys = [
            getindex.(getproperty.(sc.sections, :leading_edge_relative_to_wing_root), 3)
        ]
    end
    xs, ys
end

tip_segment(sc::SectionConcatenation) = WingSegment(sc.sections[end-1], sc.sections[end])


function (awt::AbstractWingTransform)(sc::SectionConcatenation)
    SectionConcatenation([sc.sections[1:(end-2)]; sc |> tip_segment |> awt |> sections])
end

export Inherit
"""
Struct marcadora de herança de aerofólios e controles de seções de asa.
"""
struct Inherit end

#colocar mudança de aerofólio opcional?
export RectangularSegment
"""
Cria um segmento retangular de asa quando aplicado a um aerofólio.

É o segundo passo na criação de uma asa.

É possível passar um `tip_airfoil::Airfoil` para fazer uma asa com perfil variável.
"""
struct RectangularSegment
    span::Unitful.Length
    chord::Unitful.Length
    control::Union{Nothing, Control}
    tip_airfoil::Union{Inherit, Airfoil}
    function RectangularSegment(span, chord, control, tip_airfoil)
        new(span, chord, control, tip_airfoil)
    end
    function RectangularSegment(span::Unitful.Length, chord::Unitful.Length, control::Union{Nothing, Control})
        new(span, chord, control, Inherit())
    end
end

function (rs::RectangularSegment)(a::Airfoil)
    tip_airfoil = (rs.tip_airfoil == Inherit()) ? a : rs.tip_airfoil
    SectionConcatenation([
        WingSection([0.0, 0.0, 0.0]*u"m", rs.chord, 0u"°", filepath(a), a.cd, a.cl, rs.control),
        WingSection([0.0u"m", rs.span, 0.0u"m"], rs.chord, 0u"°", filepath(tip_airfoil), tip_airfoil.cd, tip_airfoil.cl, rs.control)
    ])
end

export NextRectangularSegment
"""
Concatena mais um segmento retangular na ponta da asa quando aplicado a um SectionConcatenation.

Pode ser usado após a criação de um primeiro segmento de asa com RectangularSegment.


    NextRectangularSegment(span, control, airfoil)

Cria um novo segmento retangular com novo controle `Control` e novo aerofólio `Airfoil`.
Também pode receber `Inherit()` nos 2 últimos parâmetros para manter o mesmo controle e o mesmo aerofólio.
control também pode receber `nothing`.

    NextRectangularSegment(span, control)

Automaticamente repete o aerofólio anterior.
"""
struct NextRectangularSegment <: AbstractWingTransform
    span::Unitful.Length
    control::Union{Nothing, Control, Inherit}
    airfoil::Union{Airfoil, Inherit}
    function NextRectangularSegment(span, control, airfoil)
        new(span, control, airfoil)
    end
    function NextRectangularSegment(span, control)
        new(span, control, Inherit())
    end
end

function (ns::NextRectangularSegment)(sc::SectionConcatenation)
    tip = sc.sections[end]

    new_section_control = if ns.control === Inherit()
        tip.control
    elseif  ns.control isa Control
        #ws.tip teria 2 controles
        #ainda não há suporte para 2 controles/seção
        if !isnothing(tip.control)
            error("tip of segment $(tip_segment(sc)) would have 2 controls, which isn't supported yet")
        else
            sc = @set sc.sections[end].control = ns.control
            ns.control
        end
    end

    new_section_airfoil_data, new_section_cd, new_section_cl = 
    if ns.airfoil == Inherit()
        tip.airfoil_file_path, tip.cd, tip.cl
    else
        ns.airfoil |> filepath, ns.airfoil.cd, ns.airfoil.cl
    end

    SectionConcatenation([
        sc.sections...,
        WingSection(tip.leading_edge_relative_to_wing_root+[0.0u"m", ns.span, 0.0u"m"],
            tip.chord,
            0.0u"°",
            new_section_airfoil_data,
            new_section_cd,
            new_section_cl,
            new_section_control)
    ])
end

export WingConstructor
"""
    WingConstructor(name::AbstractString, 
            vortex_distribution::SVector{4, Int},
            is_symmetric::Bool,
            root_position::SVector{3, Unitful.Length},
            component::Int = 1)
Constrói uma asa quando aplicado a um SectionConcatenation (obtido da descrição da geometria da asa).

A distribuição de vórtices influencia a precisão dos resultados. Ver a 
documentação do AVL para saber mais. Geralmente [40, 1, 15, 1] é suficiente.

Caso deseje-se criar uma versão espelhada da superfície criada, usar `is_symmetric = true`.
Cuidado com superfícies verticais no plano de simetria, que não devem ser espelhadas!

O número de componente é mantido em 1 por padrão, de modo que o AVL encontra  a influência de todas
as superfícies sobre todas as outras. Para desativar isso numere as superfícies sequencialmente, mas
usar o mesmo número de componente para todas as superfícies gera resultados mais precisos.

Assume-se que a geometria construída refere-se à asa direita,
de forma que a posição da raiz deve ter y > 0 (ver referencial do AVL).
"""
struct WingConstructor
    name::String
    vortex_distribution::SVector{4, Int}
    is_symmetric::Bool
    root_position::SVector{3, Unitful.Length}
    component::Int
    function WingConstructor(name::AbstractString, 
        vortex_distribution::AbstractVector,
        is_symmetric::Bool,
        root_position::Vector{<:Unitful.Length},
        component::Int = 1)
            new(name, vortex_distribution, is_symmetric, root_position, component)
    end
end

function (wc::WingConstructor)(sc::SectionConcatenation)
    Wing(wc.name, wc.vortex_distribution, wc.is_symmetric, 0.0u"°", wc.component, wc.root_position, sc.sections)
end

@recipe f(::Type{Wing}, wing::Wing) = wing.sections |> SectionConcatenation