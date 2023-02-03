%assume bank angle 0, cg na origem
function iacd = input_alpha_case_data(alpha, axes_to_trim)
    check_numeric(alpha, "alpha")
    check_string(axes_to_trim)
    for trim = axes_to_trim
        if all(trim ~= ["pitch", "roll", "yaw", "none"])
            error("trim deve especificar um momento a ser trimado (pitch, roll, yaw ou none)")
        end
    end

    iacd.alpha = alpha;
    iacd.axes_to_trim = axes_to_trim;
end