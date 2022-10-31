function deflection = get_wing_deflection(plane, aed_data, V, n, surf, I, E)
    check_struct(plane, "plane", "input_planedata")
    check_struct(aed_data, "aed_data", "wrapper_aerodynamic_data")
    check_numeric(V, "V")
    check_numeric(n, "n")
    check_string(surf, "surf")
    check_numeric(I, "I")
    check_numeric(E, "E")
    
    %cisalhamento na condição de V desejada
    shear = get_shear(plane, aed_data, V, n, surf);
    y = aed_data.fsdata(1).surfaces(cat(1, aed_data.fsdata(1).surfaces.name) == surf).y;
    [deflection, ~] = helper_fem_beam(shear, zeros(size(shear)), y, I, E, "fixed", "free");
end

%load deve ser força pontual no nó em y
function [y, shear] = get_shear(plane, aed_data, V, n, surf)
    %todos os fsdata têm as mesmas sueprfícies então uso o 1o elemento pq
    %sim - usar logical indexing aqui e no get_stall_characteristics
    surface_index = find(strcmp(cat(1, aed_data.fsdata(1).surfaces.name), surf));
    %matriz n_alphas x n_surfs necessária p cálculos de interpolação
    m = cat(1, aed_data.fsdata.surfaces);
    %vetor das structs surface correspondente à sup desejada, variando
    %alpha
    strip_coef_vector = m(:, surface_index);

    %cálculo do CL necessário p manter tal V a tal fator de carga
    CL = n * aed_data.m * aed_data.g / (0.5 * aed_data.rho * V^2 * plane.Sref);
    %interpolação entre as curvas de cl com base no CL
    cl_y = interp1(cat(1, aed_data.stdata.CL), cat(2, strip_coef_vector.cl)', 0.4);
    
    %sustentação por strip
    %os y não variam entre os casos portanto usar o 1o serve
    delta_y = diff(strip_coef_vector(1).y);
    %considera que a ponta tá descarregada - verificar se é a melhor forma
    shear = 0.5 * aed_data.rho * V^2 * [delta_y; 0] * cl_y;
    y = strip_coef_vector(1).y;

end