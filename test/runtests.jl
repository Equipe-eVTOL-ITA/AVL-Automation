using avl_automation, Test, Unitful

@test begin
    control = avl_automation.AVLFile.Control("prof", 1.0, 0.75, avl_automation.AVLFile.Equal, avl_automation.AVLFile.Pitch)
    avl_str = avl_automation.AVLFile.avl_string(control)
    avl_str ==
"CONTROL
#nome, ganho, x_c dobradiça, dobradiça 0 0 0, sinal do duplicado
prof 1.0 0.75 0 0 0 1"
end

@test begin
    control = avl_automation.AVLFile.Control("prof", 1.0, 0.75, avl_automation.AVLFile.Equal, avl_automation.AVLFile.Pitch)
    sect = avl_automation.AVLFile.WingSection([0u"m", 0u"m", 0u"m"], 0.3u"m", 1u"°", 
        "naca0012_selig.dat", 1.09, [0.04703, 0.01201, 0.05415], [-1.0553, 0, 1.055], control)
    avl_str = avl_automation.AVLFile.avl_string(sect)
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
#controle
" * avl_automation.AVLFile.avl_string(control) * "\n"
end

@test begin
    control = avl_automation.AVLFile.Control("prof", 1.0, 0.75, avl_automation.AVLFile.Equal, avl_automation.AVLFile.Pitch)
    sect = avl_automation.AVLFile.WingSection([0u"m", 0u"m", 0u"m"], 0.3u"m", 1u"°", 
        "naca0012_selig.dat", 1.09, [0.04703, 0.01201, 0.05415], [-1.0553, 0, 1.055], control)
    wing = avl_automation.AVLFile.Wing("main", [15, 1, 40, 1], true, 1.5u"°", 2, [1.0u"m", 0u"m", 0u"m"], [sect])
    avl_str = avl_automation.AVLFile.avl_string(wing)
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
" * avl_automation.AVLFile.avl_string(sect)
end

@test begin
    control = avl_automation.AVLFile.Control("prof", 1.0, 0.75, avl_automation.AVLFile.Equal, avl_automation.AVLFile.Pitch)
    
    sect = avl_automation.AVLFile.WingSection([0u"m", 0u"m", 0u"m"], 0.3u"m", 1u"°", 
        "naca0012_selig.dat", 1.09, [0.04703, 0.01201, 0.05415], [-1.0553, 0, 1.055], control)
    
    wing = avl_automation.AVLFile.Wing("main", [15, 1, 40, 1], true, 1.5u"°", 2, [1.0u"m", 0u"m", 0u"m"], [sect])
    
    plane = avl_automation.AVLFile.Plane("teste", 1u"m^2", 0.5u"m", 2u"m", 0.02, [wing])

    avl_str = avl_automation.AVLFile.avl_string(plane)
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
" * avl_automation.AVLFile.avl_string(wing)
end

@test begin
    control = avl_automation.AVLFile.Control("prof", 1.0, 0.75, avl_automation.AVLFile.Equal, avl_automation.AVLFile.Pitch)
    
    sect = avl_automation.AVLFile.WingSection([0u"m", 0u"m", 0u"m"], 0.3u"m", 1u"°", 
        "naca0012_selig.dat", 1.09, [0.04703, 0.01201, 0.05415], [-1.0553, 0, 1.055], control)
    
    wing = avl_automation.AVLFile.Wing("main", [15, 1, 40, 1], true, 1.5u"°", 2, [1.0u"m", 0u"m", 0u"m"], [sect])
    
    plane = avl_automation.AVLFile.Plane("teste", 1u"m^2", 0.5u"m", 2u"m", 0.02, [wing])

    contents = ""
    mktempdir(directory -> begin
        
        path = avl_automation.AVLFile.write_avl_file(plane, directory)
        contents = read(path, String)
        # ret = (contents == avl_automation.AVLFile.avl_string(plane))

    end, pwd(), prefix="test_write_avl_file_")

    (contents == avl_automation.AVLFile.avl_string(plane))
end

@test begin
    ec = avl_automation.AVLExecution.ExecutionCase(2.0u"°", Dict(2 => avl_automation.AVLFile.Pitch), "a", true, 1, "./")
    avl_automation.AVLExecution.run_string(ec) ==
"a
a 2.0
d2
pm 0
x
fs
./a1.fs
st
./a1.st
"
end

@test begin
    ec1 = avl_automation.AVLExecution.ExecutionCase(2.0u"°", Dict(2 => avl_automation.AVLFile.Pitch), "a", true, 1, "./")
    ec2 = avl_automation.AVLExecution.ExecutionCase(4.0u"°", Dict(2 => avl_automation.AVLFile.Pitch), "a", true, 1, "./")
    
    ecs = avl_automation.AVLExecution.ExecutionCaseSeries("armagedon", [ec1, ec2])

    contents = ""
    mktempdir(directory -> begin
        
        path = avl_automation.AVLExecution.write_run_file(ecs, directory)
        contents = read(path, String)

    end, pwd(), prefix="test_write_run_file_")

    contents ==
"load
armagedon
oper
" * avl_automation.AVLExecution.run_string(ec1) * avl_automation.AVLExecution.run_string(ec2) * "\nquit\n"
end

@test begin
    avl_automation.AVLExecution.call_avl("armagedon.run", dirname(@__DIR__))
    if isfile("a.fs") && isfile("a.st")
        rm("a.fs"); rm("a.st")
        true
    else
        @warn "something wrong, please clean up test directory"
        false
    end
end

@test begin
    st_file_res = avl_automation.AVLResults.STFileResults("armagedon1", @__DIR__)

    st_file_res.alpha ≈ -2u"°" &&
    st_file_res.CL ≈ 0.1847 &&
    st_file_res.CD ≈ 0.01701 &&
    st_file_res.CLa ≈ 5.196712 &&
    st_file_res.Cma ≈ -2.479769 &&
    st_file_res.Xnp ≈ 0.09305u"m"
end

@test begin
    naca0012 = avl_automation.WingGeometry.Airfoil("naca0012_selig.dat", [-1.0553, 0, 1.055], [0.04703, 0.01201, 0.05415], @__DIR__)
    avl_automation.WingGeometry.claf(naca0012) ≈ 1.09242618 &&
    naca0012.x[50] ≈ 0.142201 &&
    naca0012.y[50] ≈ 0.052625
end

@test begin
    segment = avl_automation.WingGeometry.Airfoil(
            "naca0012_selig.dat", [-1.0553, 0, 1.055], 
            [0.04703, 0.01201, 0.05415], @__DIR__) |>
        avl_automation.WingGeometry.RectangularSegment(2u"m", 0.3u"m") |>
        avl_automation.WingGeometry.Taper(0.2)
    segment.tip.chord == 0.2 * segment.base.chord &&
    segment.tip.leading_edge_relative_to_wing_root[1] > segment.base.leading_edge_relative_to_wing_root[1] &&
    segment.tip.leading_edge_relative_to_wing_root[2] > segment.base.leading_edge_relative_to_wing_root[2] &&
    segment.tip.leading_edge_relative_to_wing_root[3] == segment.base.leading_edge_relative_to_wing_root[3]
end