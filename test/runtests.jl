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
0.0 0.0 0.0 0.3 1.0
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
###########################
#tests that use the files in the test directory
@test begin
    if !isdir(joinpath(@__DIR__, "tmp"))
        mkdir("tmp")
    end
    avl_automation.AVLExecution.call_avl("test_plane.run", dirname(@__DIR__))
    if isfile("tmp/test_plane1.fs") && isfile("tmp/test_plane1.st")
        rm("tmp/test_plane1.fs"); rm("tmp/test_plane1.st")
        true
    else
        @warn "something wrong, please clean up test directory"
        false
    end
end

@test begin
    main_test_wing = Airfoil("naca0012_selig.dat", [-1.0553, 0, 1.055], [0.04703, 0.01201, 0.05415], @__DIR__) |>
       RectangularSegment(1.5u"m", 30u"cm", nothing) |>
       NextRectangularSegment(0.5u"m", avl_automation.AVLFile.Control("aileron", 1.0, 0.75, avl_automation.AVLFile.Inverted, avl_automation.AVLFile.Roll)) |>
       Taper(0.5) |>
       Sweep(20u"°") |>
       WingConstructor("main", [15, 1, 40, 1], true, 1, [0, 0, 0]u"m")
    
    hstab_test = Airfoil("naca0012_selig.dat", [-1.0553, 0, 1.055], [0.04703, 0.01201, 0.05415], @__DIR__) |>
       RectangularSegment(0.4u"m", 17u"cm", avl_automation.AVLFile.Control("profundor", 1.0, 0.75, avl_automation.AVLFile.Equal, avl_automation.AVLFile.Pitch)) |>
       Taper(0.7) |>
       WingConstructor("hstab", [15, 1, 40, 1], true, 2, [60u"cm", 0u"m", 0u"m"])

    test_plane = avl_automation.AVLFile.Plane("test_plane", 0.6u"m^2", 0.3u"m", 2u"m", 0.02, [main_test_wing, hstab_test])
    
    st_file_res = avl_automation.AVLResults.STFileResults("test_plane1", test_plane.controls, @__DIR__)

    st_file_res.alpha ≈ -2u"°" &&
    st_file_res.CL ≈ -0.31970 &&
    st_file_res.CD ≈ 0.04930 &&
    st_file_res.CLa ≈ 11.383851 &&
    st_file_res.Cma ≈ -4.083255 &&
    st_file_res.Xnp ≈ 0.107607u"m" &&
    st_file_res.control_results[1].deflection ≈ -0.00000u"°" &&
    st_file_res.control_results[2].force_derivative ≈ 0.011736u"°^-1" &&
    st_file_res.control_results[2].moment_derivative ≈ -0.021467u"°^-1"
end

@test begin
    fs_file_results = avl_automation.AVLResults.FSFileResults("test_plane1", @__DIR__)

    length(fs_file_results.wing_results) == 4 &&
    fs_file_results.wing_results[2].name == "main (YDUP)" &&
    all(fs_file_results.wing_results[2].y .≈ [
        -0.0008
        -0.0068
        -0.0189
        -0.0370
        -0.0609
        -0.0905
        -0.1256
        -0.1660
        -0.2115
        -0.2618
        -0.3165
        -0.3753
        -0.4379
        -0.5038
        -0.5727
        -0.6442
        -0.7178
        -0.7930
        -0.8694
        -0.9465
        -1.0239
        -1.1010
        -1.1774
        -1.2527
        -1.3262
        -1.3977
        -1.4666
        -1.5346
        -1.6011
        -1.6637
        -1.7218
        -1.7752
        -1.8235
        -1.8665
        -1.9038
        -1.9353
        -1.9607
        -1.9799
        -1.9927
        -1.9992
    ]u"m") &&
    fs_file_results.wing_results[2].cl[1] ≈ -0.2039
end


@test begin
    naca0012 = avl_automation.WingGeometry.Airfoil("naca0012_selig.dat", [-1.0553, 0, 1.055], [0.04703, 0.01201, 0.05415], @__DIR__)
    avl_automation.WingGeometry.claf(naca0012) ≈ 1.09242618 &&
    naca0012.x[50] ≈ 0.142201 &&
    naca0012.y[50] ≈ 0.052625
end

#############################
#wing geometry tests
#melhorar esse teste
@test begin
    segment = avl_automation.WingGeometry.Airfoil(
            "naca0012_selig.dat", [-1.0553, 0, 1.055], 
            [0.04703, 0.01201, 0.05415], @__DIR__) |>
        avl_automation.WingGeometry.RectangularSegment(2u"m", 0.3u"m", nothing) |>
        avl_automation.WingGeometry.Taper(0.2) |>
        avl_automation.WingGeometry.Sweep(15u"°")
    segment.sections[2].chord == 0.2 * segment.sections[1].chord &&
    segment.sections[2].leading_edge_relative_to_wing_root[1] >  segment.sections[1].leading_edge_relative_to_wing_root[1] &&
    segment.sections[2].leading_edge_relative_to_wing_root[2] >  segment.sections[1].leading_edge_relative_to_wing_root[2] &&
    segment.sections[2].leading_edge_relative_to_wing_root[3] == segment.sections[1].leading_edge_relative_to_wing_root[3]
end

@test begin
    segment = avl_automation.WingGeometry.Airfoil(
            "naca0012_selig.dat", [-1.0553, 0, 1.055], 
            [0.04703, 0.01201, 0.05415], @__DIR__) |>
        avl_automation.WingGeometry.RectangularSegment(2u"m", 0.3u"m", nothing) |>
        avl_automation.WingGeometry.Dihedral(3u"°")
    wing = segment |> 
        avl_automation.WingGeometry.NextRectangularSegment(1u"m", avl_automation.AVLFile.Control("aileron", 1.0, 0.75, 
                                        avl_automation.AVLFile.Inverted, avl_automation.AVLFile.Roll)) |> 
        avl_automation.WingGeometry.Taper(0.5)

    segment.sections[2].leading_edge_relative_to_wing_root[3] ≈ segment.sections[1].leading_edge_relative_to_wing_root[3] + 2u"m"*tan(3u"°") &&
    length(wing.sections) == 3 &&
    avl_automation.WingGeometry.tip_segment(wing).tip.chord ≈ 0.15u"m"
end