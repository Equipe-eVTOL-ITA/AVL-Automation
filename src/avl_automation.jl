"""Package de automação do Athena Vortex Lattice, solver de forças aerodinâmicas para projeto aeronáutico.

Para usar essa package corretamente, é necessário adicionar também as packages Unitful e Plots:
``
]add Unitful Plots``

Analogamente, é sempre necessário usar as 3 packages para ter acesso à funcionalidade completa:
``
using avl_automation, Unitful, Plots
``

O fluxo de trabalho usual é:
1) Criação de geometria de asas (ver módulo `WingGeometry`)
2) Criação de um `Plane` com as superfícies criadas no módulo anterior (ver struct `Plane`)
3) Análise com a função `analyze_plane` ou sessão interativa do AVL aberta com a função `run_avl()`
4) Uso (eventual armazenamento) dos dados obtidos para pós processamento (TODO!)

Se em algum momento você tiver dúvidas do que fazer a seguir, algumas sugestões de navegação:
* Use a função `doc_avl` para abrir a documentação do AVL, caso necessário.
* Se estiver em dúvida sobre o que uma função/struct `X` faz e como usar, use (na REPL) os comandos `?X`
ou digite `X(<TAB>`, o que vai te mostrar os nomes e tipos dos argumentos da função/construtor.
* Se estiver realmente perdido, ou quiser conhecer mais a package, tente o comando `names(avl_automation)`.
Ele vai mostrar todos os tipos, módulos e funções exportados pela package. A menos que você esteja usando
um fluxo de trabalho meio estranho/específico, tudo que você vai precisar usar vai estar contido nessa lista
de nomes. Caso você precise de uma função não exportada, basta usar `módulo.nome`.
"""
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
#aerofólio placa plana
#mudar de aerofólio ao longo da asa?
#plot control surfaces
#display of objects
#wing area, cma, etc calculation
#post-processing: stability, cruise/stall speed, wing FEM
#remover claf
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
ser usada na construção de um avião (struct Plane do módulo AVLFile).
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