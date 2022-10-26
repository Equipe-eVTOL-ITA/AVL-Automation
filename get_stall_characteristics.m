function [Vstall, astall] = get_stall_characteristics(plane, criterion_surface_name, aed_data)
    check_struct(plane, "plane", "planedata")
    check_string(criterion_surface_name, "criterion_surface")

    crit_surf_i = find(strcmp(cat(1, plane.wingdatas.name), criterion_surface_name));

    clmax = plane.wingdatas(crit_surf_i).clmax;

    crit_sec_cls = critical_section_cls(aed_data, criterion_surface_name);

    obj_function = @(alpha) interp1(aed_data.alphas, crit_sec_cls, alpha) - clmax;

    astall = fsolve(obj_function, mean(aed_data.alphas));

    CLmax = interp1(aed_data.alphas, cat(1, aed_data.stdata.CL), astall);

    Vstall = sqrt(aed_data.m * aed_data.g / (0.5*aed_data.rho*plane.Sref*CLmax));

end

%cls máximos em função do ângulo de ataque
function critical_section_cls = critical_section_cls(aed_data, crit_surf_name)
    %pegando índice da superfície em cada fsdata
    surface_index = find(strcmp(cat(1, aed_data.fsdata(1).surfaces.name), crit_surf_name));
    
    %pegar cl máx (da seção crítica da superfície especificada) pra cada velocidade
    critical_section_cls = [];
    for fsd = aed_data.fsdata
        critical_section_cls = [critical_section_cls max(fsd.surfaces(surface_index).cl)];
    end
end