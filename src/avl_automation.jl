module avl_automation
using Reexport
@reexport using Unitful

module AVLFile
include("avlfile.jl")
end

module AVLExecution
include("avlexecution.jl")
end

module AVLResults
include("avlresults.jl")
end

#todo
#constructors with sanity checks - at least 2 sections per surface etc (affects tests!)
#result representation
#refactor control representation
#geometry abstraction


end # module