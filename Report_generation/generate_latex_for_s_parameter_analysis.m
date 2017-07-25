function ov = generate_latex_for_s_parameter_analysis(data_path)
% Generates latex code based on the wake simulation results.
% Wraps latex code around the pre generated S parameter results images.
%
% ov is the output latex code.
% data_path is the path to the images.
%
% Example: ov = generate_latex_for_s_parameter_analysis(data_path)
ov = cell(1,1);
ov = cat(1,ov,'\chapter{S parameters}');

[s_list,~] =  dir_list_gen(data_path,'eps',1);
s_ind = find_position_in_cell_lst(strfind(s_list, 's_parameters_'));
s_list = s_list(s_ind);

main_reflections = find_position_in_cell_lst(strfind(s_list, 'reflection_mode_1'));
main_transmissions = find_position_in_cell_lst(strfind(s_list, 'transmission_mode_1'));
s_params_ind = find_position_in_cell_lst(strfind(s_list, 's_parameters_S'));
s_params = s_list(s_params_ind);
t = regexp(s_params, 's_parameters_S(\d{1,2})_(\d{1,2})\.eps', 'tokens');
for wah = length(t):-1:1;
    for ha = 1:2
    t2(wah,ha) = str2double(t{wah}{1}{ha});
    end % for
end % for
n_ports = max(max(t2)) -2;
ov = cat(1,ov,'\section{Reflection}');
ov1 = latex_single_image(['s_parameters/',s_list{main_reflections}],...
    'Reflections for all signal ports', 'Reflections_all_signal_ports', 1);
ov = cat(1,ov,ov1);
ov = cat(1,ov,'\clearpage');
if n_ports >2
    ov = cat(1,ov,'\section{Transmission}');
    ov1 = latex_single_image(['s_parameters/',s_list{main_transmissions}],...
        'Transmission between all signal ports', ...
        'Transmission_between_all_signal_ports',1);
    ov = cat(1,ov,ov1);
    ov = cat(1,ov,'\clearpage');
    
    port_excitations_ind = find_position_in_cell_lst(strfind(s_list, 'transmission_excitation_'));
    port_excitations = s_list(port_excitations_ind);
    len_pe = length(port_excitations);
    % need to make the list a multiple of 4
    extras = 4 - mod(len_pe,4);
    if extras <4
        port_excitations = cat(1, port_excitations, cell(extras,1));
    end %if
    ov = cat(1,ov,'\section{Individual port excitation}');
    for newq = 1:4:len_pe
        ov1 = latex_side_by_side_images(['s_parameters/',port_excitations{newq}],...
            ['s_parameters/', port_excitations{newq+1}],'','');
        ov = cat(1,ov,ov1);
        ov1 = latex_side_by_side_images(['s_parameters/', port_excitations{newq+2}],...
            ['s_parameters/', port_excitations{newq+3}],'','');
        ov = cat(1,ov,ov1);
        ov = cat(1,ov,'\clearpage');
    end %for
end %if

    ov = cat(1,ov,'\section{Higher order modes}');
len_s = length(s_params);
% need to make the list a multiple of 4
extras = 4 - mod(len_s,4);
if extras <4
    s_params = cat(1, s_params, cell(extras,1));
end
len_s = length(s_params);
for newq = 1:4:len_s
    if newq +3 < len_s
        ov1 = latex_side_by_side_images(['s_parameters/',s_params{newq}],...
            ['s_parameters/', s_params{newq+1}],'','');
        ov = cat(1,ov,ov1);
        ov1 = latex_side_by_side_images(['s_parameters/', s_params{newq+2}],...
            ['s_parameters/', s_params{newq+3}],'','');
        ov = cat(1,ov,ov1);
        ov = cat(1,ov,'\clearpage');
    else
        extras = 4 - mod(len_s,4);
        if extras == 1
            ov1 = latex_side_by_side_images(['s_parameters/',s_params{newq}],...
                [],'','');
            ov = cat(1,ov,ov1);
            ov = cat(1,ov,'\clearpage');
        elseif extras == 2
            ov1 = latex_side_by_side_images(['s_parameters/',s_params{newq}],...
                ['s_parameters/', s_params{newq+1}],'','');
            ov = cat(1,ov,ov1);
            ov = cat(1,ov,'\clearpage');
        elseif extras == 3
            ov1 = latex_side_by_side_images(['s_parameters/',s_params{newq}],...
                ['s_parameters/', s_params{newq+1}],'','');
            ov = cat(1,ov,ov1);
            ov1 = latex_side_by_side_images(['s_parameters/', s_params{newq+2}],...
                [],'','');
            ov = cat(1,ov,ov1);
            ov = cat(1,ov,'\clearpage');
        end %if
    end %if
end %for