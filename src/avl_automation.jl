module avl_automation
using Reexport
@reexport using Unitful

module AVLFile
using Unitful, StaticArrays
include("avlfile.jl")
end


end # module

