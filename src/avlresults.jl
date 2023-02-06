using Unitful, ..AVLFile

#ignora tudo relacionado ao controle
struct STFileResults
    alpha::typeof(1.0u"°")
    CL::Float64
    CD::Float64
    CLa::Float64
    Cma::Float64
    Xnp::Unitful.Length
end

get_float_from_key(key::String, words::Vector{<:AbstractString}) = parse(Float64, words[findfirst(x -> x == key, words) + 2])

function STFileResults(filetitle::String, directory::String=pwd())
    words = split(read(joinpath(directory, filetitle*".st"), String))
    STFileResults(
        get_float_from_key("Alpha", words)*u"°",
        get_float_from_key("CLtot", words),
        get_float_from_key("CDtot", words),
        get_float_from_key("CLa", words),
        get_float_from_key("Cma", words),
        get_float_from_key("Xnp", words) * u"m"
    )
end