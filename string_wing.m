function wingstring = string_wing(wingdata, component)
    %caso especial: translate(2) = 0 e angle = 90 => remove YDUP e usa b,
    %não b/2
    if wingdata.translate(2) == 0 && wingdata.x_angle_degrees == 90
        yduplicate_string = "";
        semispan = wingdata.b;
    else
        yduplicate_string = "YDUPLICATE\n0\n";
        semispan = wingdata.b/2;
    end
    
    %angle é torção (~= x_angle_degrees) !!
    wingstring = strcat("SURFACE\n", wingdata.name, "\n15 1 40 0\n",...
        yduplicate_string, "ANGLE\n0\n", "COMPONENT\n",...
        num2str(component), "\nTRANSLATE\n",...
        num2str(wingdata.translate), "\n");
        %adicionar seções levando em conta o controle
        
        if isstruct(wingdata.controldata)
            if wingdata.controldata.start_x_b == 0
                wingstring = wingstring +sectionstring(wingdata, 0, true);
            else
                wingstring = wingstring +sectionstring(wingdata, 0, false);
                wingstring = wingstring +sectionstring(wingdata, ...
                    wingdata.controldata.start_x_b*semispan, true);
            end
            if wingdata.controldata.end_x_b == 1
                wingstring = wingstring +sectionstring(wingdata, ...
                    semispan, true);
            else
                wingstring = wingstring +sectionstring(wingdata, ...
                    wingdata.controldata.end_x_b*semispan, true);
                wingstring = wingstring +sectionstring(wingdata, semispan, false);
            end
        else
            wingstring = wingstring +sectionstring(wingdata, 0, false);
            wingstring = wingstring +sectionstring(wingdata, semispan, false);
        end

end

function sectionstring = sectionstring(wingdata, y, hascontrol)
    %converter y_direcao_envergadura em (y, z) do sistema global
    %usando x_angle_degrees
    y_global = y * cosd(wingdata.x_angle_degrees);
    z_global = y * sind(wingdata.x_angle_degrees);
    sectionstring = "SECTION\n0 " + num2str(y_global) + " " + ...
        num2str(z_global) + " " + ...
        num2str(wingdata.c) + " 0\nAFILE\n" + ...
        wingdata.airfoil_file + "\nCLAF\n" + ...
        num2str(wingdata.claf) + "\nCDCL\n" + ...
        num2str(wingdata.cdcl) + "\n";
    
    if hascontrol
        sectionstring = sectionstring + string_control(wingdata.controldata);
    end

end