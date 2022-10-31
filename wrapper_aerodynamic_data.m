%m, g, rho não fazem sentido aqui! mas é bem conveniente
%expor opções de trimagem?
function aerodynamic_data = wrapper_aerodynamic_data(plane, alpha_range, m, g, rho)
    check_numeric(m, "m")
    check_numeric(g, "g")
    check_numeric(rho, "rho")
    n = length(alpha_range);
    cases = [];
    for i = 1:n
        cases = [cases input_alpha_case_data(alpha_range(i), ["roll", "pitch", "yaw"])];
    end
    avl_execute_cases(plane, cases)
    aerodynamic_data.m = m;
    aerodynamic_data.g = g;
    aerodynamic_data.rho = rho;
    aerodynamic_data.alphas = alpha_range;
    aerodynamic_data.stdata = [];
    aerodynamic_data.fsdata = [];
    for i = 1:n
        aerodynamic_data.stdata = [aerodynamic_data.stdata, ...
                read_stdata(plane.name+num2str(i), plane)];
        aerodynamic_data.fsdata = [aerodynamic_data.fsdata, ...
                read_fsdata(plane.name+num2str(i))];
    end
end