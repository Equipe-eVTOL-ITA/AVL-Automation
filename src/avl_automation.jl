module avl_automation
using Reexport
@reexport using Unitful

#colocar em module Internals
module AVLFile
include("avlfile.jl")
end
#deixar privado?
@reexport using .AVLFile

module AVLExecution
include("avlexecution.jl")
end

module AVLResults
include("avlresults.jl")
end

#todo
#reexport plot
#display of objects
#result representation
#wrappers for avl execution
#simplify directory-related arguments and select better defaults

module WingGeometry
include("wing_geometry.jl")
end

@reexport using .WingGeometry

module PlaneAnalysis
include("plane_analysis.jl")
end

@reexport using .PlaneAnalysis
end # module