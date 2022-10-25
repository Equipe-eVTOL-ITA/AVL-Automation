function drag_polar = calculate_drag_polar(plane, speed_range, m, g, rho)
    n = length(speed_range);
    cases = [];
    for i = 1:n
        cases = [cases level_flight_case_data(speed_range(i), m, rho, g)];
    end
    executeavl(plane, cases)
    drag_polar = [];
    for i = 1:n
        drag_polar = [drag_polar stdata(plane.name+"_level_flight"+num2str(i), plane)];
    end
end