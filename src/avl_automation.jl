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
#result representation
#wrappers for avl execution

module WingGeometry
include("wing_geometry.jl")
end

@reexport using .WingGeometry

end # module