function output_file_locations = GdfidL_find_ouput(data_loc)
% finds the output generated by GdfidL and returns the paths for the different
% result types
%
% Example: [ WP_l, Port_mat, port_names, Energy, Energy_in_ceramics] = GdfidL_find_ouput(data_loc)

%
% Run name is the name prepended to the results by GdfidL.
% data loc is the path to the scratch location where the results files are
% stored.

% get the full list of files in the scratch directory.
run_list = dir_list_gen_tree(data_loc, '',1);

% % select only the results which contain the run name.
% inds = find_position_in_cell_lst(strfind(full_list, [run_name,'_scratch']));
% run_list = full_list(inds);
% clear full_list

% Find the longditudinal wakepotential file, for at the origin.
inds = find_position_in_cell_lst(strfind(run_list, 'W_AT_XY'));
output_file_locations.WP_origin.s = run_list(inds);

% Find the longditudinal wakepotential file, for at the origin.
inds = find_position_in_cell_lst(strfind(run_list, 'Wq_AT_XY'));
output_file_locations.WP_beam.s = run_list(inds);

% now find the transverse wakepotential file, for at the origin.
% x
inds = find_position_in_cell_lst(strfind(run_list, 'WX_AT_XY'));
output_file_locations.WP_origin.x = run_list(inds);
% y
inds = find_position_in_cell_lst(strfind(run_list, 'WY_AT_XY'));
output_file_locations.WP_origin.y = run_list(inds);

% Find the longditudinal wakepotential file, for at the beam location.
inds = find_position_in_cell_lst(strfind(run_list, 'Wq_AT_XY'));
output_file_locations.WP_beam.s = run_list(inds);
% x
inds = find_position_in_cell_lst(strfind(run_list, 'WXq_AT_XY'));
output_file_locations.WP_beam.x = run_list(inds);
% y
inds = find_position_in_cell_lst(strfind(run_list, 'WYq_AT_XY'));
output_file_locations.WP_beam.y = run_list(inds);

%Find the GdfidL calculated impedances
%s
inds = find_position_in_cell_lst(strfind(run_list, 'ReZ_AT_XY'));
output_file_locations.WI_s = run_list(inds);
%x
inds = find_position_in_cell_lst(strfind(run_list, 'ReZx_AT_XY'));
output_file_locations.WI_x = run_list(inds);
%y
inds = find_position_in_cell_lst(strfind(run_list, 'ReZy_AT_XY'));
output_file_locations.WI_y = run_list(inds);

%s
inds = find_position_in_cell_lst(strfind(run_list, 'ImZ_AT_XY'));
output_file_locations.WI_Im_s = run_list(inds);
%x
inds = find_position_in_cell_lst(strfind(run_list, 'ImZx_AT_XY'));
output_file_locations.WI_Im_x = run_list(inds);
%y
inds = find_position_in_cell_lst(strfind(run_list, 'ImZy_AT_XY'));
output_file_locations.WI_Im_y = run_list(inds);

% now find the Energy and electric field files files. The order is determined by the order they are
% called in the post processing file.
inds = find_position_in_cell_lst(strfind(run_list, 'oneDPlot'));
if ~isempty(inds)
    output_file_locations.Energy = run_list(inds(1));
    output_file_locations.Energy_in_ceramics = run_list(inds(2));
%     output_file_locations.EfieldAtZerox = run_list(inds(3));
%     output_file_locations.EfieldAtZerox_freq = run_list(inds(4));
else
    disp('No Energy graphs - This is a problem')
    output_file_locations.Energy = NaN;
    output_file_locations.Energy_in_ceramics = NaN;
end

% Find list of ports.
inds = find_position_in_cell_lst(strfind(run_list, 'Port='));
power_inds = find_position_in_cell_lst(strfind(run_list, '-h_amp_of_mode='));
voltage_inds = find_position_in_cell_lst(strfind(run_list, '-e_amp_of_mode='));
output_file_locations.Ports.power = run_list(intersect(inds ,power_inds));
output_file_locations.Ports.voltage = run_list(intersect(inds ,voltage_inds));
% Put the paths into a grid of port vs mode

% first find the port names.
nme_start = strfind(output_file_locations.Ports.voltage, 'Port=');
nme_end = strfind(output_file_locations.Ports.voltage, '-e_amp_of_mode=');
port_names_list_voltage = cell(1,1);
ac = 1;
for nr = 1:length(output_file_locations.Ports.voltage)
    if ~isempty(nme_end{nr})
        port_names_list_voltage{ac} = output_file_locations.Ports.voltage{nr}(nme_start{nr}+5:nme_end{nr}-1);
        ac = ac + 1;
    end %if
end %for
% nme_end = strfind(output_file_locations.Ports.power, '-h_amp_of_mode=');
% port_names_list_power = cell(1,1);
% ac = 1;
% for nr = 1:length(output_file_locations.Ports.power)
%     if ~isempty(nme_end{nr})
%     port_names_list_power{ac} = output_file_locations.Ports.power{nr}(nme_start{nr}+5:nme_end{nr}-1);
%     ac = ac + 1;
%     end %if
% end %for
% find the unique port names
port_names_temp = unique(port_names_list_voltage);
empty_names_ind = cellfun(@isempty, (port_names_temp));
output_file_locations.port_names = port_names_temp(~empty_names_ind);
% if isempty(output_file_locations.port_names)
%     disp('No Port data - This is a problem')
%     output_file_locations.Port_mat = NaN;
%     output_file_locations.port_names = NaN;
% else
%     port_modes = NaN;
%     % Now the port modes.
%     nme_end = strfind(output_file_locations.Ports.voltage, '-e_amp_of_mode=');
%     mode_end = strfind(output_file_locations.Ports.voltage, '-time.mtv');
%     for nr = 1:length(output_file_locations.Ports.voltage)
%         port_modes(nr) = str2double(output_file_locations.Ports.voltage{nr}(nme_end{nr}+15:mode_end{nr}-1));
%     end %for
%     % put them in a matrix
%     output_file_locations.Port_mat.voltage = cell(1,1);
%     for hs = 1:length(output_file_locations.port_names)
%         p_ind = contains(port_names_list_voltage, output_file_locations.port_names{hs});
%         selected_port_modes = port_modes(p_ind);
%         selected_ports = output_file_locations.Ports.voltage(p_ind);
%         for hfe = 1:length(selected_ports)
%             output_file_locations.Port_mat.voltage{hs, selected_port_modes(hfe)} = selected_ports{hfe};
%         end %for
%     end %for
%     output_file_locations.Port_mat.power = cell(1,1);
%     for hs = 1:length(output_file_locations.port_names)
%         p_ind = contains(port_names_list_power, output_file_locations.port_names{hs});
%         selected_port_modes = port_modes(p_ind);
%         selected_ports = output_file_locations.Ports.power(p_ind);
%         for hfe = 1:length(selected_ports)
%             output_file_locations.Port_mat.power{hs, selected_port_modes(hfe)} = selected_ports{hfe};
%         end %for
%     end %for
% end %if

inds = find_position_in_cell_lst(strfind(run_list, 'Port='));
if ~isempty(inds)
input_list = run_list(inds);
inds = find_position_in_cell_lst(strfind(input_list, '-e_amp_of_mode='));
input_list = input_list(inds);
nme_start = 'Port=';
nme_end = '-e_amp_of_mode=';
mode_end = '-time.mtv';
port_names = output_file_locations.port_names;
output_file_locations.Port_mat.time.voltage_port_mode = ...
    arrange_outputs_into_grids(nme_start, nme_end, mode_end, ...
    port_names, input_list);
end %if

inds = find_position_in_cell_lst(strfind(run_list, 'Port='));
if ~isempty(inds)
input_list = run_list(inds);
inds = find_position_in_cell_lst(strfind(input_list, '-h_amp_of_mode='));
input_list = input_list(inds);
nme_start = 'Port=';
nme_end = '-h_amp_of_mode=';
mode_end = '-time.mtv';
port_names = output_file_locations.port_names;
output_file_locations.Port_mat.time.power_port_mode = ...
    arrange_outputs_into_grids(nme_start, nme_end, mode_end, ...
    port_names, input_list);
end %if

inds = find_position_in_cell_lst(strfind(run_list, '-integral-sum-power-df'));
if ~isempty(inds)
    input_list = run_list(inds);
    nme_start = '/';
    nme_end = '-integral-sum-power-df';
    mode_end = '';
    port_names = output_file_locations.port_names;
    output_file_locations.Port_mat.frequency.power_cumulative_port = ...
        arrange_outputs_into_grids(nme_start, nme_end, mode_end, ...
        port_names, input_list);
end %if

inds = find_position_in_cell_lst(strfind(run_list, '-integral-sum-power-dt'));
if ~isempty(inds)
input_list = run_list(inds);
nme_start = '/';
nme_end = '-integral-sum-power-dt';
mode_end = '';
port_names = output_file_locations.port_names;
output_file_locations.Port_mat.time.power_cumulative_port = ...
    arrange_outputs_into_grids(nme_start, nme_end, mode_end, ...
    port_names, input_list);
end %if

inds = find_position_in_cell_lst(strfind(run_list, '-sum-power-freq'));
if ~isempty(inds)
input_list = run_list(inds);
nme_start = '/';
nme_end = '-sum-power-freq';
mode_end = '';
port_names = output_file_locations.port_names;
output_file_locations.Port_mat.frequency.power_port = ...
    arrange_outputs_into_grids(nme_start, nme_end, mode_end, ...
    port_names, input_list);
end %if

inds = find_position_in_cell_lst(strfind(run_list, '-sum-power-time'));
if ~isempty(inds)
    input_list = run_list(inds);
    nme_start = '/';
    nme_end = '-sum-power-time';
    mode_end = '';
    port_names = output_file_locations.port_names;
    output_file_locations.Port_mat.time.power_port = ...
        arrange_outputs_into_grids(nme_start, nme_end, mode_end, ...
        port_names, input_list);
end %if
end %function

function output_matrix = arrange_outputs_into_grids(nme_start, nme_end, mode_end, ...
    port_names, input_list)
nme_start_ind = strfind(input_list, nme_start);
nme_end_ind = strfind(input_list, nme_end);
mode_end_ind = strfind(input_list, mode_end);
port_names_list = cell(1,1);
for nr = 1:length(input_list)
    if ~isempty(nme_end_ind{nr})
        port_names_list{nr} = input_list{nr}(nme_start_ind{nr}+length(nme_start):nme_end_ind{nr}-1);
    end %if
end %for
if~strcmp(mode_end, '')
    port_modes = NaN;
    % Now the port modes.
    for nr = 1:length(input_list)
        port_modes(nr) = str2double(input_list{nr}(nme_end_ind{nr}+length(nme_end):mode_end_ind{nr}-1));
    end %for
else
    port_modes = ones(1, length(input_list));
end %if
% put them in a matrix
output_matrix = cell(1,1);
for hs = 1:length(port_names)
    p_ind = contains(port_names_list, port_names{hs});
    selected_port_modes = port_modes(p_ind);
    selected_ports = input_list(p_ind);
    for hfe = 1:length(selected_ports)
        output_matrix{hs, selected_port_modes(hfe)} = selected_ports{hfe};
    end %for
end %for

end %function