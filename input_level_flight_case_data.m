%assume bank angle 0, cg na origem
function level_flight_case_data = input_level_flight_case_data(v, m, d, g)
    check_numeric(v, "v")
    level_flight_case_data.v = v;
    check_numeric(m, "m")
    level_flight_case_data.m = m;
    check_numeric(d, "d")
    level_flight_case_data.d = d;
    check_numeric(g, "g")
    level_flight_case_data.g = g;
end