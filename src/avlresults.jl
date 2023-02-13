using Unitful, ..AVLFile

struct ControlResults
    name::String
    deflection::typeof(1.0u"°")
    force_derivative::Union{Nothing, typeof(1.0u"°^-1")}
    moment_derivative::typeof(1.0u"°^-1")
end

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

#todo: derivadas dinâmicas
#todo: apenas uma struct de resultados
struct STFileResults
    alpha::typeof(1.0u"°")
    CL::Float64
    CD::Float64
    CLa::Float64
    Cma::Float64
    Xnp::Unitful.Length
    control_results::Vector{ControlResults}
end

get_float_from_key(key::String, words::Vector{<:AbstractString}) = parse(Float64, words[findfirst(x -> x == key, words) + 2])

function STFileResults(filetitle::String, controls::Vector{Control}, directory::String=pwd())
    words = split(read(joinpath(directory, filetitle*".st"), String))
    STFileResults(
        get_float_from_key("Alpha", words)*u"°",
        get_float_from_key("CLtot", words),
        get_float_from_key("CDtot", words),
        get_float_from_key("CLa", words),
        get_float_from_key("Cma", words),
        get_float_from_key("Xnp", words) * u"m",
        [ControlResults(control.name, control.axis_to_trim, index, words) for (index, control) in enumerate(controls)]
    )
end

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

struct FSFileResults
    wing_results::Vector{WingResult}
end

function FSFileResults(filetitle::String, directory::String=pwd())
    surface_strs = split(read(joinpath(directory, filetitle*".fs"), String), "Surface #")[2:end]
    
    FSFileResults(WingResult.(surface_strs))
end