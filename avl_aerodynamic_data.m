function aerodynamic_data = avl_aerodynamic_data(plane, speed_range, m, g, rho)
    check_numeric(m, "m")
    check_numeric(g, "g")
    check_numeric(rho, "rho")
    n = length(speed_range);
    cases = [];
    for i = 1:n
        cases = [cases level_flight_case_data(speed_range(i), m, rho, g)];
    end
    executeavl(plane, cases)
    aerodynamic_data.m = m;
    aerodynamic_data.g = g;
    aerodynamic_data.rho = rho;
    aerodynamic_data.speeds = speed_range;
    aerodynamic_data.stdata = [];
    aerodynamic_data.fsdata = [];
    for i = 1:n
        aerodynamic_data.stdata = [aerodynamic_data.stdata, ...
                stdata(plane.name+"_level_flight"+num2str(i), plane)];
        aerodynamic_data.fsdata = [aerodynamic_data.fsdata, ...
                fsdata(plane.name+"_level_flight"+num2str(i))];
    end
end