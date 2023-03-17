module avl_automation

using Reexport

"Descrição da geometria do avião e criação do arquivo .avl"
module AVLFile
include("avlfile.jl")
end
#colocar control e plane em módulo à parte?
#são diferentes de WingSection, já que devem ser construídos diretamente pelo usuário
@reexport using .AVLFile

"Entradas para execução do AVL, criação do arquivo .run e execução do AVL"
module AVLExecution
include("avlexecution.jl")
end
@reexport using .AVLExecution

"Leitura e representação de resultados obtidos do AVL"
module AVLResults
include("avlresults.jl")
end
@reexport using .AVLResults

#todo
#better plane constructor
#plot control surfaces
#display of objects
#wing area, cma, etc calculation
#post-processing: stability, cruise/stall speed, wing FEM
#cleanup exports and visibility
#cancelar execução do avl?
#documentar API?
#formato de dados dos resultados de controle está ruim
#indicar se resultados estão compensados ou não
#ler Cm do st
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

"Wrapper para análise de aviões."
module PlaneAnalysis
include("plane_analysis.jl")
end
@reexport using .PlaneAnalysis

end # module