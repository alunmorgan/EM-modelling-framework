function run_models(mi, ppi)

if ispc ==1
    error('This needs to be run on the linux modelling machine')
end %if

modelling_inputs = run_inputs_setup_STL(mi);

% Running the different simulators for each model.
for awh = 1:length(modelling_inputs)
    % Making the directory to store the run data in.
    mkdir(fullfile(mi.paths.storage_path, modelling_inputs{awh}.model_name))
    %     if ~isempty(stl_flag)
    %         % Create model_data file from STL file.
    %         create_model_data_file_for_STL(...
    %             mi.paths.input_file_path, mi.paths.storage_path,...
    %             modelling_inputs{awh}.base_model_name,...
    %             modelling_inputs{awh}.model_name)
    %     end %if
    %FIXME
    ow_behaviour = '';
    % Write update to the command line
    disp(datestr(now))
    disp(['Running ',num2str(awh), ' of ',...
        num2str(length(modelling_inputs)), ' simulations'])
    
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'w'))
        try
            GdfidL_run_simulation('wake', mi.paths, modelling_inputs{awh}, ...
                ow_behaviour, mi.Plotting);
        catch ERR
            display_modelling_error(ERR, 'wake')
        end %try
        try
            ppi.model_name = modelling_inputs{awh}.model_name;
            GdfidL_post_process_models(ppi);
        catch ERR
            display_postprocessing_error(ERR, 'wake')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 's'))
        try
            GdfidL_run_simulation('s-parameter', mi.paths, modelling_inputs{awh}, ...
                ow_behaviour, mi.Plotting);
        catch ERR
            display_modelling_error(ERR, 'S-parameter')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'e'))
        try
            GdfidL_run_simulation('eigenmode', mi.paths, modelling_inputs{awh}, ...
                ow_behaviour, mi.Plotting);
        catch ERR
            display_modelling_error(ERR, 'eigenmode')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'l'))
        try
            GdfidL_run_simulation('lossy eigenmode', mi.paths, modelling_inputs{awh}, ...
                ow_behaviour, mi.Plotting);
        catch ERR
            display_modelling_error(ERR, 'lossy eigenmode')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'r'))
        try
            GdfidL_run_simulation('shunt', mi.paths, modelling_inputs{awh}, ...
                ow_behaviour, mi.Plotting);
        catch ERR
            display_modelling_error(ERR, 'shunt')
        end %try
    end %if
end %for
