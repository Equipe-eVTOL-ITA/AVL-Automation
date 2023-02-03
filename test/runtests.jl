using avl_automation, Test

@test begin
    sect = avl_automation.WingSection([0u"m", 0u"m", 0u"m"], 0.3u"m", 1u"°", 
        "naca0012_selig.dat", 1.09, [0.04703, 0.01201, 0.05415], [-1.0553, 0, 1.055])
    avl_str = avl_automation.avl_string(sect)
    avl_str == 
"#x, y, z do bordo de ataque, corda, incidência
SECTION
0 0 0 0.3 1.0
#arquivo do aerofólio
AFILE
naca0012_selig.dat
#correção de aerofólio espesso (p 16)
CLAF
1.09
#CL1 CD1 CL2 CD2 CL3 CD3 para o aerofólio
CDCL
-1.0553 0.04703 0.0 0.01201 1.055 0.05415
"
end

@test begin
    sect = avl_automation.WingSection([0u"m", 0u"m", 0u"m"], 0.3u"m", 1u"°", 
        "naca0012_selig.dat", 1.09, [0.04703, 0.01201, 0.05415], [-1.0553, 0, 1.055])
    wing = avl_automation.Wing("main", [15, 1, 40, 1], true, 1.5u"°", 2, [1.0u"m", 0u"m", 0u"m"], [sect])
    avl_str = avl_automation.avl_string(wing)
    avl_str ==
"SURFACE
main
#distribuição de vórtices
15 1 40 1
#simetria geométrica no plano y=0
YDUPLICATE
0
ANGLE
1.5
#id de componente
COMPONENT
2
#posição da raiz da asa
TRANSLATE
1.0 0.0 0.0
" * avl_automation.avl_string(sect)
end