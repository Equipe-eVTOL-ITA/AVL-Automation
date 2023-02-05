module avl_automation
using Reexport
@reexport using Unitful

module AVLFile
using Unitful, StaticArrays
include("avlfile.jl")
end

#todo
#run file
#constructors with sanity checks
#temporary directory on precompilation/loading of package
#avl execution
#result representation
#geometry abstraction


end # module