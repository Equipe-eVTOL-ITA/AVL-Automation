module avl_automation
using Reexport
@reexport using Unitful

#colocar em module Internals
module AVLFile
include("avlfile.jl")
end

@reexport using .AVLFile

module AVLExecution
include("avlexecution.jl")
end

module AVLResults
include("avlresults.jl")
end

#todo
#display of objects
#change test files to coherent input-result pairs: wing with elevon
#result representation
#geometry abstraction + wrappers for avl

module WingGeometry
include("wing_geometry.jl")
end

@reexport using .WingGeometry

end # module