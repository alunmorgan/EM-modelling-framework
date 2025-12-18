function run_plot_wake_postprocessed(input_settings, set_id)

try
    analysis_root = fullfile(input_settings.paths.results_loc, input_settings.sets{set_id});
    [a_folders] = dir_list_gen(analysis_root, 'dirs',1);
    for nrs = 1:length(a_folders)
        postprocess_folder = fullfile(a_folders{nrs}, 'postprocessing', 'wake');
        plot_postprocessed_folder = fullfile(a_folders{nrs}, 'plot_postprocessed', 'wake');
        [~,name_of_model,~] = fileparts(a_folders{nrs});
        if exist(postprocess_folder, 'dir')
            if ~exist(plot_postprocessed_folder, 'dir')
                mkdir(plot_postprocessed_folder)
            end %if
            fprintf(['\nStarting wake postprocessed plotting <strong>', name_of_model, '</strong>\n'])
            avi_files = dir_list_gen(plot_postprocessed_folder, 'avi', 1);
            if ~isempty(avi_files)
                fprintf('\nPlotting already run ... skipping')
                continue
            end %if
            mtv_file_locs = dir_list_gen(postprocess_folder, 'mtv', 1);
            if isempty(mtv_file_locs)
                fprintf('\nNo mtv files to process... skipping')
                continue
            end %if
            for hse = 1:length(mtv_file_locs)
                temp = read_mtv_file(mtv_file_locs{hse});
%                 h = plot_mtv_data(temp, plot_postprocessed_folder);
                fprintf('.')
                if rem(hse, 100) == 0
                    fprintf('\n')
                end %if
                if contains(temp.metadata.xlabel, 'frequency [Hz]') && contains(temp.metadata.ylabel, 'sqrt(power)/Hz')
                    port_name = regexprep(temp.metadata.subtitle, '\s+out\s+\d+\s*', '');
                    port_name = regexprep(port_name, '^\s*', '');
                    port_name = regexprep(port_name, '\s*', '_');
                    mode = regexp(temp.metadata.subtitle, '\s+out\s+(\d+)', 'tokens');
                    mode_label = mode{1}{1};
                    mode = str2double(mode{1});
                    %Sometimes data has slightly different lengths this breaks
                    %the matrix so changed to put mode as a structure level.
                    port_frequency_data.(port_name).x.(['mode',mode_label]) = temp.x_data;
                    port_frequency_data.(port_name).y.(['mode',mode_label]) = temp.y_data;
                    port_frequency_data.(port_name).x_label{mode} = temp.metadata.xlabel;
                    port_frequency_data.(port_name).y_label{mode} = temp.metadata.ylabel;
                elseif contains(temp.metadata.subtitle, 'Port') && isfield(temp.metadata, 'e_amp_of_mode')
                    port_name = regexprep(temp.metadata.Port, '\s*', '_');
                    mode = str2double(temp.metadata.e_amp_of_mode);
                    mode_label = num2str(mode);
                    port_time_data.E.(port_name).x.(['mode',mode_label]) = temp.x_data;
                    port_time_data.E.(port_name).y.(['mode',mode_label]) = temp.y_data;
                    port_time_data.E.(port_name).x_label{mode} = temp.metadata.xlabel;
                    port_time_data.E.(port_name).y_label{mode} = temp.metadata.ylabel;
                elseif contains(temp.metadata.subtitle, 'Port') && isfield(temp.metadata, 'exh_amp_of_mode')
                    mode = str2double(temp.metadata.exh_amp_of_mode);
                    mode_label = num2str(mode);
                    port_time_data.power.(port_name).x.(['mode',mode_label]) = temp.x_data;
                    port_time_data.power.(port_name).y.(['mode',mode_label]) = temp.y_data;
                    port_time_data.power.(port_name).x_label{mode} = temp.metadata.xlabel;
                    port_time_data.power.(port_name).y_label{mode} = temp.metadata.ylabel;
                elseif contains(temp.metadata.subtitle, 'integrated') && contains(temp.metadata.xlabel, 'frequency [Hz]')
                    port_name = temp.metadata.ports;
                    port_name = regexprep(port_name, '^\s*', '');
                    port_name = regexprep(port_name, '\s*', '_');
                    port_frequency_data_all_modes.(port_name).x = temp.x_data;
                    port_frequency_data_all_modes.(port_name).y = temp.y_data;
                    port_frequency_data_all_modes.(port_name).x_label = temp.metadata.xlabel;
                    port_frequency_data_all_modes.(port_name).y_label = temp.metadata.ylabel;
                elseif contains(temp.metadata.subtitle, 'integrated') && contains(temp.metadata.xlabel, 'time [s]')
                    port_name = temp.metadata.ports;
                    port_name = regexprep(port_name, '^\s*', '');
                    port_name = regexprep(port_name, '\s*', '_');
                    port_time_data_all_modes.(port_name).x = temp.x_data;
                    port_time_data_all_modes.(port_name).y = temp.y_data;
                    port_time_data_all_modes.(port_name).x_label = temp.metadata.xlabel;
                    port_time_data_all_modes.(port_name).y_label = temp.metadata.ylabel;
                elseif contains(temp.metadata.subtitle, 'field snapshots E') && contains(temp.metadata.ylabel, 'x-component [V/m]')
                    mode = regexp(temp.metadata.subtitle, '\s*field\s+snapshots\s+E\s+(\d+)', 'tokens');
                    mode = str2double(mode{1});
                    mode_label = num2str(mode);
                    electric_field_snapshot.x_component.t(mode) = str2double(temp.metadata.t);
                    electric_field_snapshot.x_component.x.(['mode',mode_label])  = temp.x_data;
                    electric_field_snapshot.x_component.y.(['mode',mode_label])  = temp.y_data;
                    electric_field_snapshot.x_component.x_label{mode} = temp.metadata.xlabel;
                    electric_field_snapshot.x_component.y_label{mode} = temp.metadata.ylabel;
                elseif contains(temp.metadata.subtitle, 'field snapshots E') && contains(temp.metadata.ylabel, 'y-component [V/m]')
                    mode = regexp(temp.metadata.subtitle, '\s*field\s+snapshots\s+E\s+(\d+)', 'tokens');
                    mode = str2double(mode{1});
                    mode_label = num2str(mode);
                    electric_field_snapshot.y_component.t(mode) = str2double(temp.metadata.t);
                    electric_field_snapshot.y_component.x.(['mode',mode_label])  = temp.x_data;
                    electric_field_snapshot.y_component.y.(['mode',mode_label])  = temp.y_data;
                    electric_field_snapshot.y_component.x_label{mode} = temp.metadata.xlabel;
                    electric_field_snapshot.y_component.y_label{mode} = temp.metadata.ylabel;
                elseif contains(temp.metadata.subtitle, 'field snapshots E') && contains(temp.metadata.ylabel, 'z-component [V/m]')
                    mode = regexp(temp.metadata.subtitle, '\s*field\s+snapshots\s+E\s+(\d+)', 'tokens');
                    mode = str2double(mode{1});
                    mode_label = num2str(mode);
                    electric_field_snapshot.z_component.t(mode) = str2double(temp.metadata.t);
                    electric_field_snapshot.z_component.x.(['mode',mode_label]) = temp.x_data;
                    electric_field_snapshot.z_component.y.(['mode',mode_label])  = temp.y_data;
                    electric_field_snapshot.z_component.x_label{mode} = temp.metadata.xlabel;
                    electric_field_snapshot.z_component.y_label{mode} = temp.metadata.ylabel;
                elseif contains(temp.metadata.subtitle, 'field snapshots H') && contains(temp.metadata.ylabel, 'x-component [A/m]')
                    mode = regexp(temp.metadata.subtitle, '\s*field\s+snapshots\s+H\s+(\d+)', 'tokens');
                    mode = str2double(mode{1});
                    mode_label = num2str(mode);
                    magnetic_field_snapshot.x_component.t(mode) = str2double(temp.metadata.t);
                    magnetic_field_snapshot.x_component.x.(['mode',mode_label]) = temp.x_data;
                    magnetic_field_snapshot.x_component.y.(['mode',mode_label])  = temp.y_data;
                    magnetic_field_snapshot.x_component.x_label{mode} = temp.metadata.xlabel;
                    magnetic_field_snapshot.x_component.y_label{mode} = temp.metadata.ylabel;
                elseif contains(temp.metadata.subtitle, 'field snapshots H') && contains(temp.metadata.ylabel, 'y-component [A/m]')
                    mode = regexp(temp.metadata.subtitle, '\s*field\s+snapshots\s+H\s+(\d+)', 'tokens');
                    mode = str2double(mode{1});
                    mode_label = num2str(mode);
                    magnetic_field_snapshot.y_component.t(mode) = str2double(temp.metadata.t);
                    magnetic_field_snapshot.y_component.x.(['mode',mode_label])  = temp.x_data;
                    magnetic_field_snapshot.y_component.y.(['mode',mode_label]) = temp.y_data;
                    magnetic_field_snapshot.y_component.x_label{mode} = temp.metadata.xlabel;
                    magnetic_field_snapshot.y_component.y_label{mode} = temp.metadata.ylabel;
                elseif contains(temp.metadata.subtitle, 'field snapshots H') && contains(temp.metadata.ylabel, 'z-component [A/m]')
                    mode = regexp(temp.metadata.subtitle, '\s*field\s+snapshots\s+H\s+(\d+)', 'tokens');
                    mode = str2double(mode{1});
                    mode_label = num2str(mode);
                    magnetic_field_snapshot.z_component.t(mode) = str2double(temp.metadata.t);
                    magnetic_field_snapshot.z_component.x.(['mode',mode_label]) = temp.x_data;
                    magnetic_field_snapshot.z_component.y.(['mode',mode_label])  = temp.y_data;
                    magnetic_field_snapshot.z_component.x_label{mode} = temp.metadata.xlabel;
                    magnetic_field_snapshot.z_component.y_label{mode} = temp.metadata.ylabel;
                elseif contains(temp.metadata.subtitle, 'TEIS')&& contains(temp.metadata.xlabel, 'time [s]')
                    TEIS.x = temp.x_data;
                    TEIS.y = temp.y_data;
                    TEIS.x_label = temp.metadata.xlabel;
                    TEIS.y_label = temp.metadata.ylabel;
                elseif contains(temp.metadata.subtitle, 'TEC')&& contains(temp.metadata.xlabel, 'time [s]')
                    TEC.x = temp.x_data;
                    TEC.y = temp.y_data;
                    TEC.x_label = temp.metadata.xlabel;
                    TEC.y_label = temp.metadata.ylabel;
                elseif contains(temp.metadata.subtitle, 'voltage port') && contains(temp.metadata.xlabel, 'time [s]')
                    port_name = regexprep(temp.metadata.subtitle, '\s*voltage\s*', '');
                    port_name = regexprep(port_name, '^\s*', '');
                    port_name = regexprep(port_name, '\s*', '_');
                    port_voltage_data.(port_name).x = temp.x_data;
                    port_voltage_data.(port_name).y = temp.y_data;
                    port_voltage_data.(port_name).x_label = temp.metadata.xlabel;
                    port_voltage_data.(port_name).y_label = temp.metadata.ylabel;
                elseif contains(temp.metadata.subtitle, 'power') && contains(temp.metadata.xlabel, 'frequency [Hz]')
                    port_name = temp.metadata.ports;
                    port_name = regexprep(port_name, '^\s*', '');
                    port_name = regexprep(port_name, '\s*', '_');
                    port_frequency_power_data_all_modes.(port_name).x = temp.x_data;
                    port_frequency_power_data_all_modes.(port_name).y = temp.y_data;
                    port_frequency_power_data_all_modes.(port_name).x_label = temp.metadata.xlabel;
                    port_frequency_power_data_all_modes.(port_name).y_label = temp.metadata.ylabel;
                elseif contains(temp.metadata.subtitle, 'power') && contains(temp.metadata.xlabel, 'time [s]')
                    port_name = temp.metadata.ports;
                    port_name = regexprep(port_name, '^\s*', '');
                    port_name = regexprep(port_name, '\s*', '_');
                    port_time_power_data_all_modes.(port_name).x = temp.x_data;
                    port_time_power_data_all_modes.(port_name).y = temp.y_data;
                    port_time_power_data_all_modes.(port_name).x_label = temp.metadata.xlabel;
                    port_time_power_data_all_modes.(port_name).y_label = temp.metadata.ylabel;
                else
                    fprintf(' ')
                end %if
            end %for
            if exist('h', 'var')
                close(h)
            end %if
            h2 = figure(3981);
            if exist('port_frequency_data', 'var')
            plot_pp_mode_data_as_ribbon(h2, port_frequency_data, plot_postprocessed_folder)
            end %if
            if exist('port_time_data', 'var')
            plot_pp_mode_data_as_ribbon(h2, port_time_data.E, plot_postprocessed_folder)
            plot_pp_mode_data_as_ribbon(h2, port_time_data.power, plot_postprocessed_folder)
            end %if
            if exist('h2', 'var')
                close(h2)
            end %if
            plot_field_timeseries(magnetic_field_snapshot.x_component, plot_postprocessed_folder, 'Field_(magnetic)_x_component')
            plot_field_timeseries(magnetic_field_snapshot.y_component, plot_postprocessed_folder, 'Field_(magnetic)_y_component')
            plot_field_timeseries(magnetic_field_snapshot.z_component, plot_postprocessed_folder, 'Field_(magnetic)_z_component')
            plot_field_timeseries(electric_field_snapshot.x_component, plot_postprocessed_folder, 'Field_(electric)_x_component')
            plot_field_timeseries(electric_field_snapshot.y_component, plot_postprocessed_folder, 'Field_(electric)_y_component')
            plot_field_timeseries(electric_field_snapshot.z_component, plot_postprocessed_folder, 'Field_(electric)_z_component')
        else
            fprintf('\nNo plotting folder... skipping wake postprocessed plotting.')
        end %if
    end %for
catch ME5
    warning([input_settings.sets{set_id}, ' <strong>Problem with plotting</strong>'])
    display_error_message(ME5)
end %try
