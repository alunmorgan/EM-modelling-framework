function arch_date = run_shunt_simulation(mi, modelling_inputs, arch_date)
% Takes the geometry specification, adds the setup for a wake simulation and
% runs a wake field simulation with the desired calculational precision.
%
% arch_date is
% mi is
% modelling_inputs is
%
% Example: arch_date = run_shunt_simulation(mi, modelling_inputs, arch_date)

storage_path = mi.storage_path;
output_name = mi.model_name;


% Move into the temporary folder.
old_loc = pwd;
tmp_name = tempname;
tmp_name = tmp_name(6:12);
mkdir(mi.scratch_path,tmp_name)
cd([mi.scratch_path,tmp_name])

f_range = 1.3E9:5E7:1.9E9;
for sef = 1:length(f_range)
    frequency = num2str(f_range(sef));
    temp_files('make')
    construct_shunt_gdf_file(mi, modelling_inputs, frequency)
    % making the input file name length fixed. So that you do not run into
    % name length limits.
    if strcmp(mi.precision, 'single')
        [~] = system('single.gd1 < temp_data/model.gdf > temp_data/model_log');
    elseif strcmp(mi.precision, 'double')
        [~] = system('gd1 < temp_data/model.gdf > temp_data/model_log');
    end
    [log] = GdfidL_get_log_date( 'temp_data/model_log' );
    % Move the data to the storage area.
    if nargin ==1
        %         No date given, so get it from the log
        arch_date = datestr(datenum([log.dte,'-',log.tme],'dd/mm/yyyy-HH:MM:SS]'),30);
    end
    if ~exist([storage_path, output_name], 'dir')
        mkdir(storage_path, output_name)
    end
    if ~exist([storage_path, output_name,'/',arch_date],'dir')
        mkdir([storage_path, output_name],arch_date)
    end
    if ~exist([storage_path, output_name,'/',arch_date,'/shunt'],'dir')
        mkdir([storage_path, output_name,'/',arch_date], 'shunt')
    end
    if ~exist([storage_path, output_name,'/',arch_date,'/shunt/',frequency],'dir')
        mkdir([storage_path, output_name,'/',arch_date, '/shunt'], frequency)
    end
    
    arch_out = [storage_path, output_name,'/',arch_date,'/shunt/',frequency,'/'];
    movefile('temp_data/*', arch_out);
    copyfile([mi.input_file_path, mi.model_name, '_model_data'], [storage_path, output_name,'/',arch_date,'/shunt/', frequency, '/']);
    save([mi.storage_path, mi.model_name,'/', arch_date,'/shunt/run_inputs.mat'], 'mi', 'modelling_inputs')

    temp_files('remove')
end
cd(old_loc)
rmdir([mi.scratch_path, tmp_name],'s');