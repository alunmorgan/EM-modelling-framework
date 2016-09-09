function arch_date = run_s_param_simulation(mi, modelling_inputs, arch_date)
% Takes the geometry specification, adds the setup for a wake simulation and
% runs a wake field simulation with the desired calculational precision.
%
% arch_date is
% mi is
% modelling_inputs is
%
% Example: arch_date = run_s_param_simulation(mi, modelling_inputs, arch_date)

storage_path = mi.storage_path;
output_name_base = mi.model_name;
port_select = mi.s_param_ports;


% Move into the temporary folder.
old_loc = pwd;
tmp_name = tempname;
tmp_name = tmp_name(6:12);
mkdir(mi.scratch_path,tmp_name)
cd([mi.scratch_path,tmp_name])

% if strcmp(mi.beam, 'no')
%     strt = 1;
% else
%     strt = 3;
%     % If beam is present.
%     % assumes that the first 2 ports are beam pipe ports and thus we do not
%     % want to excite at those ports (due to odd behaviour around cut off).
% end


% for nes = strt:length(port_names)
for nes = 1:length(port_select)
    port_name = port_select{nes};
    temp_files('make')
    construct_s_param_gdf_file(mi, modelling_inputs, port_name)
    if strcmp(mi.precision, 'single')
        [~] = system('single.gd1 < temp_data/model.gdf > temp_data/model_log');
    elseif strcmp(mi.precision, 'double')
        [~] = system('gd1 < temp_data/model.gdf > temp_data/model_log');
    end
    [log] = GdfidL_get_log_date( 'temp_data/model_log' );
    % Move the data to the storage area.
    if nargin ==1 && nes ==1
        %         No date given, so get it from the log
        arch_date = datestr(datenum([log.dte,'-',log.tme],'dd/mm/yyyy-HH:MM:SS]'),30);
    end
    if ~exist([storage_path, output_name_base], 'dir')
        mkdir(storage_path, output_name_base)
    end
    if ~exist([storage_path, output_name_base,'/',arch_date],'dir')
        mkdir([storage_path, output_name_base],arch_date)
    end
    if ~exist([storage_path, output_name_base,'/',arch_date,'/s_parameters'],'dir')
        mkdir([storage_path, output_name_base, '/',arch_date], 's_parameters')
    end
    arch_out = [storage_path, output_name_base,'/',arch_date,'/s_parameters/port_',port_name, '_excitation/'];
    if ~exist(arch_out,'dir')
        mkdir([storage_path, output_name_base, '/',arch_date, '/s_parameters'], ['port_',port_name, '_excitation'])
    end
    save([mi.storage_path, mi.model_name,'/', arch_date,'/s_parameters/run_inputs.mat'], 'mi', 'modelling_inputs')
    movefile('temp_data/*', arch_out);
    copyfile([mi.input_file_path, mi.model_name, '_model_data'], arch_out);
    temp_files('remove')
end
cd(old_loc)
rmdir([mi.scratch_path, tmp_name],'s');