function wingstring = wingstring(wingdata, component)
    wingstring = strcat("SURFACE\n", wingdata.name, "\n15 1 40 0\n",...
        "YDUPLICATE\n0\n", "ANGLE\n0\n", "COMPONENT\n",...
        num2str(component), "\nTRANSLATE\n",...
        num2str(wingdata.translate), "\n");
        %adicionar seções levando em conta o controle
        
        if isfield(wingdata, 'controldata')
            if wingdata.controldata.start_x_b == 0
                wingstring = wingstring +sectionstring(wingdata, 0, true);
            else
                wingstring = wingstring +sectionstring(wingdata, 0, false);
                wingstring = wingstring +sectionstring(wingdata, ...
                    wingdata.controldata.start_x_b*wingdata.b/2, true);
            end
            if wingdata.controldata.end_x_b == 1
                wingstring = wingstring +sectionstring(wingdata, ...
                    wingdata.b/2, true);
            else
                wingstring = wingstring +sectionstring(wingdata, ...
                    wingdata.controldata.end_x_b*wingdata.b/2, true);
                wingstring = wingstring +sectionstring(wingdata, wingdata.b/2, false);
            end
        else
            wingstring = wingstring +sectionstring(wingdata, 0, false);
            wingstring = wingstring +sectionstring(wingdata, wingdata.b/2, false);
        end

end

function sectionstring = sectionstring(wingdata, y, hascontrol)
    sectionstring = "SECTION\n0 " + num2str(y) + " 0 " + ...
        num2str(wingdata.c) + " 0\nAFILE\n" + ...
        wingdata.airfoil_file + "\nCLAF\n" + ...
        num2str(wingdata.claf) + "\nCDCL\n" + ...
        num2str(wingdata.cdcl) + "\n";
    
    if hascontrol
        sectionstring = sectionstring + controlstring(wingdata.controldata);
    end

end