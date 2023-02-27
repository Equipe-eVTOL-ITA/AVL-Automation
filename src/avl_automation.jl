module avl_automation

using Reexport
@reexport using Unitful
@reexport using Plots

#colocar em module Internals?
"Descrição da geometria do avião e criação do arquivo .avl"
module AVLFile
include("avlfile.jl")
end
#deixar privado? - exportar nome, não nomes internos - e structs base? fazer prelúdio?
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
#make vortex_distribution option more fine grained (better represent control surfaces, taper changes, etc)
#plot control surfaces
#display of objects
#wing area, cma, etc calculation
#post-processing: stability, cruise/stall speed, wing FEM
#cleanup exports and visibility
"""
Definição de geometria de asas.

Para criar uma asa, utiliza-se a sequência a seguir:

    wing = Airfoil(...) |> 
            RectangularSegment(...) |> 
            [AbstractWingTransform(...), NextRectangularSegment(...)]... |> 
            WingConstructor(...)

Os parâmetros estão omitidos por brevidade.

Sempre se deve criar um aerofólio no início do processo. 

A seguir, cria-se um segmento de asa retangular a partir desse aerofólio, em uma operação análoga ao pad/extrude de softwares CAD.

A seguir, aplica-se qualquer quantidade de transformações e concatenações de segmentos, incluindo nenhuma, para se obter a geometria
desejada. A qualquer momento, a geometria atual pode ser exibida com plot(wing, aspect_ratio=:equal). **Obs**: o uso de []... apenas
indica uma sequência de qualquer tamanho dos itens listados dentro dos colchetes.

Por fim, a lista de seções de asa (struct SectionConcatenation) é passada para um WingConstructor, que retornará uma struct Wing que pode
ser usada na construção de um avião.
"""
module WingGeometry
include("wing_geometry.jl")
end

@reexport using .WingGeometry

module PlaneAnalysis
include("plane_analysis.jl")
end

@reexport using .PlaneAnalysis
end # module