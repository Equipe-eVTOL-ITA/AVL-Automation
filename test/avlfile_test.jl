
function test_control_avl_string()
    control = Control("prof", 1.0, 0.75, Equal, Pitch)
    avl_str = AVLFile.avl_string(control)
    avl_str ==
"CONTROL
#nome, ganho, x_c dobradiça, dobradiça 0 0 0, sinal do duplicado
prof 1.0 0.75 0 0 0 1"
end

function test_section_avl_string()
    control = Control("prof", 1.0, 0.75, Equal, Pitch)
    sect = AVLFile.WingSection([0u"m", 0u"m", 0u"m"], 0.3u"m", 1u"°", 
        "naca0012_selig.dat", [0.04703, 0.01201, 0.05415], [-1.0553, 0, 1.055], control)
    avl_str = AVLFile.avl_string(sect)
    avl_str == 
"#x, y, z do bordo de ataque, corda, incidência
SECTION
0.0 0.0 0.0 0.3 1.0
#arquivo do aerofólio
AFILE
naca0012_selig.dat
#CL1 CD1 CL2 CD2 CL3 CD3 para o aerofólio
CDCL
-1.0553 0.04703 0.0 0.01201 1.055 0.05415
#controle
" * AVLFile.avl_string(control) * "\n"
end

function test_wing_avl_string()
    control = Control("prof", 1.0, 0.75, Equal, Pitch)
    sect = AVLFile.WingSection([0u"m", 0u"m", 0u"m"], 0.3u"m", 1u"°", 
        "naca0012_selig.dat", [0.04703, 0.01201, 0.05415], [-1.0553, 0, 1.055], control)
    wing = AVLFile.Wing("main", [15, 1, 40, 1], true, 1.5u"°", 2, [1.0u"m", 0u"m", 0u"m"], [sect])
    avl_str = AVLFile.avl_string(wing)
    avl_str ==
"SURFACE
main
#distribuição de vórtices
15 1 40 1
#simetria geométrica no plano y=0
YDUPLICATE
0
#ângulo de incidência global
ANGLE
1.5
#id de componente
COMPONENT
2
#posição da raiz da asa
TRANSLATE
1.0 0.0 0.0
" * AVLFile.avl_string(sect)
end

function test_plane_avl_string()
    control = Control("prof", 1.0, 0.75, Equal, Pitch)
    
    sect = AVLFile.WingSection([0u"m", 0u"m", 0u"m"], 0.3u"m", 1u"°", 
        "naca0012_selig.dat", [0.04703, 0.01201, 0.05415], [-1.0553, 0, 1.055], control)
    
    wing = AVLFile.Wing("main", [15, 1, 40, 1], true, 1.5u"°", 2, [1.0u"m", 0u"m", 0u"m"], [sect])
    
    plane = Plane("teste", 1u"m^2", 0.5u"m", 2u"m", 0.02, [wing])

    avl_str = AVLFile.avl_string(plane)
    avl_str ==
"teste
#número de mach
0
#não há simetria aerodinâmica
0 0 0
#área, corda, envergadura de referência
1.0 0.5 2.0
#centro de massa
0 0 0
#coef arrasto parasita
0.02
" * AVLFile.avl_string(wing)
end

@testset "AVLFile tests" begin
    @test test_control_avl_string()
    @test test_section_avl_string()
    @test test_wing_avl_string()
    @test test_plane_avl_string()
end