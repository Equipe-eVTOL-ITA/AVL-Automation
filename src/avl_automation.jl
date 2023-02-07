module avl_automation
using Reexport
@reexport using Unitful

#colocar em module Internals
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
#change test files to coherent input-result pairs: wing with elevon
#result representation
#geometry abstraction + wrappers for avl
module WingGeometry
include("wing_geometry.jl")
end

end # module