module avl_automation
using Reexport
@reexport using Unitful

module AVLFile
include("avlfile.jl")
end

module AVLExecution
include("avlexecution.jl")
end

#todo
#constructors with sanity checks - at least 2 sections per surface etc (affects tests!)
#result representation
#geometry abstraction


end # module