module avl_automation

using Reexport
@reexport using Unitful
@reexport using Plots

#colocar em module Internals?
"Descrição da geometria do avião e criação do arquivo .avl"
module AVLFile
include("avlfile.jl")
end
#deixar privado?
@reexport using .AVLFile

"Entradas para execução do AVL, criação do arquivo .run e execução do AVL"
module AVLExecution
include("avlexecution.jl")
end

"Leitura e representação de resultados obtidos do AVL"
module AVLResults
include("avlresults.jl")
end

#todo
#plot control surfaces
#display of objects
#wing area, cma, etc calculation
#post-processing: stability, cruise/stall speed, wing FEM
#cleanup exports and visibility

module WingGeometry
include("wing_geometry.jl")
end

@reexport using .WingGeometry

module PlaneAnalysis
include("plane_analysis.jl")
end

@reexport using .PlaneAnalysis
end # module