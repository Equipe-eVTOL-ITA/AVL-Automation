using Unitful
using ..AVLFile: Axes, Control, Pitch, Roll, Yaw

"""Resultados referentes a uma superfície de controle.

Armazena a deflexão calculada no caso executado pelo AVL, bem como as derivadas de 
controle para os coeficientes de força e momento relacionados ao eixo do controle:
|Eixo | Força | Momento |
|:---:|:-----:|:-------:|
|Pitch|  CL   |   Cm    |
|Roll |   -   |   Cl    |
|Yaw  |   CY  |   Cn    |
"""
struct ControlResults
    name::String
    deflection::typeof(1.0u"°")
    #roll não tem força associada
    force_derivative::Union{Nothing, typeof(1.0u"°^-1")}
    moment_derivative::typeof(1.0u"°^-1")
end

"""
    ControlResults(name::String, axis::Axes, index::Int, words::Vector{<:AbstractString})

Interpreta o texto (`words`) de um arquivo .st e constrói um objeto ControlResults.
"""
function ControlResults(name::String, axis::Axes, index::Int, words::Vector{<:AbstractString})
    deflection = get_float_from_key(name, words)*u"°"

    (force_deriv, moment_deriv) = if axis == Pitch
        (get_float_from_key("CLd0$index", words)*u"°^-1", get_float_from_key("Cmd0$index", words)*u"°^-1")
    elseif axis == Yaw
        (get_float_from_key("CYd0$index", words)*u"°^-1", get_float_from_key("Cnd0$index", words)*u"°^-1")
    elseif axis == Roll
        (nothing, get_float_from_key("Cld0$index", words)*u"°^-1")
    end
    ControlResults(name, deflection, force_deriv, moment_deriv)
end

export STFileResults
#todo: derivadas dinâmicas
"Resultados obtidos de arquivo .st"
struct STFileResults
    alpha::typeof(1.0u"°")
    CM::Float64
    CL::Float64
    CD::Float64
    CLa::Float64
    Cma::Float64
    Xnp::Unitful.Length
    control_results::Vector{ControlResults}
end

"""
    get_float_from_key(key::String, words::Vector{<:AbstractString})

Retorna o float interpretado a partir de uma expressão da forma `key = %f`.

É esperado que a lista de palavras contenha apenas uma aparição de `key`. Caso isso não se
aplique, usa a primeira aparição.

Pode lançar uma exceção se não houver um número decimal na posição esperada, ou se `key` não for encontrado.
"""
get_float_from_key(key::String, words::Vector{<:AbstractString}) = parse(Float64, words[findfirst(x -> x == key, words) + 2])


"""
STFileResults(filetitle::String, controls::Vector{Control}, directory::String=pwd())

Retorna um STFileResults com os conteúdos do arquivo `filetitle`.st na pasta `directory`.

O argumento `controls` deve vir da struct `Plane` usada na execução do arquivo AVL.

Por padrão, procura o arquivo no diretório da REPL (pwd()).
"""
function STFileResults(filetitle::String, controls::Vector{Control}, directory::String=pwd())
    words = split(read(joinpath(directory, filetitle*".st"), String))
    STFileResults(
        get_float_from_key("Alpha", words)*u"°",
        get_float_from_key("Cmtot", words),
        get_float_from_key("CLtot", words),
        get_float_from_key("CDtot", words),
        get_float_from_key("CLa", words),
        get_float_from_key("Cma", words),
        get_float_from_key("Xnp", words) * u"m",
        [ControlResults(control.name, control.axis_to_trim, index, words) for (index, control) in enumerate(controls)]
    )
end

"Resultado de coeficientes de sustentação locais ao longo da envergadura da asa"
struct WingResult
    name::String
    y::Vector{Unitful.Length}
    cl::Vector{Float64}
end

function WingResult(surface_str::AbstractString)
    lines = split(surface_str, '\n')
    name = join(split(lines[1])[2:end], " ")

    entries = split.(lines[17:end-2])


    y = parse.(Float64, getindex.(entries, 3)) .* u"m"
    cl = parse.(Float64, getindex.(entries, 10))

    WingResult(String(name), y, cl)
end

export FSFileResults
"Resultados obtidos de arquivo .fs"
struct FSFileResults
    wing_results::Vector{WingResult}
end


"""
    FSFileResults(filetitle::String, directory::String=pwd())

Lê o arquivo `directory` + `filetitle` + .fs e constrói um `FSFileResults`.
"""
function FSFileResults(filetitle::String, directory::String=pwd())
    surface_strs = split(read(joinpath(directory, filetitle*".fs"), String), "Surface #")[2:end]
    
    FSFileResults(WingResult.(surface_strs))
end

export CaseResults
"""Contém todos os resultados decorrentes da execução de um caso do AVL.

Deve ser a união dos campos das structs `STFileResults` e `FSFileResults` 
(ver [essa sintaxe](https://github.com/JuliaLang/julia/issues/42777) e 
[essa package](https://docs.juliahub.com/ReusePatterns/iFGTB/0.2.0/))
"""
struct CaseResults
    filetitle::String
    alpha::typeof(1.0u"°")
    CM::Float64
    CL::Float64
    CD::Float64
    CLa::Float64
    Cma::Float64
    Xnp::Unitful.Length
    control_results::Vector{ControlResults}
    wing_results::Vector{WingResult}
end

"""
    CaseResults(filetitle::String, controls::Vector{Control}, directory::String=pwd())

Constrói um CaseResults com base nos arquivos .st e .fs com o título `filetitle` no diretório `directory` (pwd() por padrão).

Idealmente usado com arquivos gerados por esta package, que garante a criação de arquivos .st e .fs de mesmo nome.
"""
function CaseResults(filetitle::String, controls::Vector{Control}, directory::String=pwd())
    stdata = STFileResults(filetitle, controls, directory)
    fsdata = FSFileResults(filetitle, directory)
    CaseResults(filetitle,
        stdata.alpha,
        stdata.CM,
        stdata.CL,
        stdata.CD,
        stdata.CLa,
        stdata.Cma,
        stdata.Xnp,
        stdata.control_results,
        fsdata.wing_results)
end