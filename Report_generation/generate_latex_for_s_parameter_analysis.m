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

[s_list,dirs] =  dir_list_gen([data_path,'/s_parameter'],'eps',1);
s_ind = find_position_in_cell_lst(strfind(s_list, 's_parameters_'));
s_list = s_list(s_ind);

main_reflections = find_position_in_cell_lst(strfind(s_list, 'reflection_mode_1'));
main_transmissions = find_position_in_cell_lst(strfind(s_list, 'transmission_mode_1'));
ov1 = latex_single_image(s_list{main_reflections}, 'Reflections for all signal ports', 1);
ov = cat(1,ov,ov1);
ov1 = latex_single_image(s_list{main_transmissions}, 'Transmission between all signal ports', 1);
ov = cat(1,ov,ov1);
ov = cat(1,ov,'\clearpage');

port_excitations_ind = find_position_in_cell_lst(strfind(s_list, 'transmission_excitation_'));
port_excitations = s_list(port_excitations_ind);
len_pe = length(port_excitations);
% need to make the list a multiple of 4
extras = 4 - mod(len_pe,4);
if extras <4
    port_excitations = cat(1, port_excitations, cell(extras,1));
end
for newq = 1:4:len_pe
    ov1 = latex_side_by_side_images([dirs,port_excitations{newq}],...
        [dirs, port_excitations{newq+1}],'','');
    ov = cat(1,ov,ov1);
    ov1 = latex_side_by_side_images([dirs, port_excitations{newq+2}],...
        [dirs, port_excitations{newq+3}],'','');
    ov = cat(1,ov,ov1);
    ov = cat(1,ov,'\clearpage');
end


s_params_ind = find_position_in_cell_lst(strfind(s_list, 's_parameters_S'));
s_params = s_list(s_params_ind);
len_s = length(s_params);
% need to make the list a multiple of 4
extras = 4 - mod(len_s,4);
if extras <4
    s_params = cat(1, s_params, cell(extras,1));
end
len_s = length(s_params);
for newq = 1:4:len_s
    ov1 = latex_side_by_side_images([dirs,s_params{newq}],...
        [dirs, s_params{newq+1}],'','');
    ov = cat(1,ov,ov1);
    ov1 = latex_side_by_side_images([dirs, s_params{newq+2}],...
        [dirs, s_params{newq+3}],'','');
    ov = cat(1,ov,ov1);
    ov = cat(1,ov,'\clearpage');
end