function test_airfoil_load()
    naca0012 = Airfoil("naca0012_selig.dat", [-1.0553, 0, 1.055], [0.04703, 0.01201, 0.05415], @__DIR__)
    
    naca0012.x[50] ≈ 0.142201 &&
    naca0012.y[50] ≈ 0.052625
end

function test_rectangular_segment()
    segment = Airfoil(
            "naca0012_selig.dat", [-1.0553, 0, 1.055], 
            [0.04703, 0.01201, 0.05415], @__DIR__) |>
        RectangularSegment(2u"m", 0.3u"m", nothing)

    length(segment.sections) == 2 &&
    all(segment.sections[1].leading_edge_relative_to_wing_root .≈ [0, 0, 0]u"m") &&
    all(segment.sections[2].leading_edge_relative_to_wing_root .≈ [0, 2, 0]u"m") &&
    segment.sections[1].chord == segment.sections[2].chord == 0.3u"m"
end

function test_taper()
    segment = Airfoil(
            "naca0012_selig.dat", [-1.0553, 0, 1.055], 
            [0.04703, 0.01201, 0.05415], @__DIR__) |>
        RectangularSegment(2u"m", 0.3u"m", nothing) |>
        Taper(0.5)

    segment.sections[2].chord == 0.5 * segment.sections[1].chord &&
    segment.sections[2].leading_edge_relative_to_wing_root[1] ≈ 0.0375u"m"
end

function test_sweep()
    segment = Airfoil(
            "naca0012_selig.dat", [-1.0553, 0, 1.055], 
            [0.04703, 0.01201, 0.05415], @__DIR__) |>
        RectangularSegment(2u"m", 0.3u"m", nothing) |>
        Sweep(45u"°")

    segment.sections[2].leading_edge_relative_to_wing_root[1] ≈ 2u"m"
end

function test_verticalize()
    segment = Airfoil(
            "naca0012_selig.dat", [-1.0553, 0, 1.055], 
            [0.04703, 0.01201, 0.05415], @__DIR__) |>
        RectangularSegment(2u"m", 0.3u"m", nothing) |>
        Verticalize()

    segment.sections[2].leading_edge_relative_to_wing_root[1] == 0u"m" &&
    segment.sections[2].leading_edge_relative_to_wing_root[2] == 0u"m" &&
    segment.sections[2].leading_edge_relative_to_wing_root[3] == 2u"m"
end

function test_dihedral()
    base_segment = Airfoil(
            "naca0012_selig.dat", [-1.0553, 0, 1.055], 
            [0.04703, 0.01201, 0.05415], @__DIR__) |>
        RectangularSegment(2u"m", 0.3u"m", nothing)

    segment = base_segment |> Dihedral(5u"°")

    segment.sections[2].leading_edge_relative_to_wing_root[1] == base_segment.sections[2].leading_edge_relative_to_wing_root[1] &&
    segment.sections[2].leading_edge_relative_to_wing_root[2] == base_segment.sections[2].leading_edge_relative_to_wing_root[2] &&
    segment.sections[2].leading_edge_relative_to_wing_root[3] ≈  0.17497732705184801u"m" #2*tand(5)
end

function test_next_rectangular_segment()
    segment = Airfoil(
            "naca0012_selig.dat", [-1.0553, 0, 1.055], 
            [0.04703, 0.01201, 0.05415], @__DIR__) |>
        RectangularSegment(2u"m", 0.3u"m", nothing) |>
        NextRectangularSegment(1u"m", nothing)

    copied_airfoil_segment = Airfoil(
        "naca0012_selig.dat", [-1.0553, 0, 1.055], 
        [0.04703, 0.01201, 0.05415], @__DIR__) |>
        RectangularSegment(2u"m", 0.3u"m", nothing) |>
        NextRectangularSegment(1u"m", nothing, Airfoil(
            "naca0012_selig copy.dat", [-1.0553, 0, 1.055], 
            [0.04703, 0.01201, 0.05415], @__DIR__))


    length(segment.sections) == 3 &&
    segment.sections[end].leading_edge_relative_to_wing_root[2] == 3u"m" &&
    segment.sections[end].airfoil_data == "naca0012_selig.dat" &&
    copied_airfoil_segment.sections[end].airfoil_data == "naca0012_selig copy.dat"
end

#fazer teste misto? taper + sweep + Verticalize
#testar adição de controle no NextRectangularSegment
@testset "WingGeometry tests" begin
    @test test_airfoil_load()
    @test test_rectangular_segment()
    @test test_taper()
    @test test_sweep()
    @test test_verticalize()
    @test test_dihedral()
    @test test_next_rectangular_segment()
end