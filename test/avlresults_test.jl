#fazer script gerador dos arquivos de teste
function test_st_file_results()
    main_test_wing = Airfoil("naca0012_selig.dat", [-1.0553, 0, 1.055], [0.04703, 0.01201, 0.05415], @__DIR__) |>
       RectangularSegment(1.5u"m", 30u"cm", nothing) |>
       NextRectangularSegment(0.5u"m", Control("aileron", 1.0, 0.75, Inverted, Roll)) |>
       Taper(0.5) |>
       Sweep(20u"°") |>
       WingConstructor("main", [15, 1, 40, 1], true, [0, 0, 0]u"m")
    
    hstab_test = Airfoil("naca0012_selig.dat", [-1.0553, 0, 1.055], [0.04703, 0.01201, 0.05415], @__DIR__) |>
       RectangularSegment(0.4u"m", 17u"cm", Control("profundor", 1.0, 0.75, Equal, Pitch)) |>
       Taper(0.7) |>
       WingConstructor("hstab", [15, 1, 40, 1], true, [60u"cm", 0u"m", 0u"m"])

    test_plane = Plane("test_plane", 0.6u"m^2", 0.3u"m", 2u"m", 0.02, [main_test_wing, hstab_test])
    
    st_file_res = AVLResults.STFileResults("test_plane1", test_plane.controls, @__DIR__)

    st_file_res.alpha ≈ -2u"°" &&
    st_file_res.CM ≈ 0 &&
    st_file_res.CL ≈ -0.31970 &&
    st_file_res.CD ≈ 0.04930 &&
    st_file_res.CLa ≈ 11.383851 &&
    st_file_res.Cma ≈ -4.083255 &&
    st_file_res.Xnp ≈ 0.107607u"m" &&
    st_file_res.control_results[1].deflection ≈ -0.00000u"°" &&
    st_file_res.control_results[2].force_derivative ≈ 0.011736u"°^-1" &&
    st_file_res.control_results[2].moment_derivative ≈ -0.021467u"°^-1"
end

function test_fs_file_results()
    fs_file_results = AVLResults.FSFileResults("test_plane1", @__DIR__)

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

@testset begin
    @test test_st_file_results()
    @test test_fs_file_results()
end