function run_models(mi, force_sim)


if ispc ==1
    error('This needs to be run on the linux modelling machine')
end %if

modelling_inputs = run_inputs_setup_STL(mi);

% Running the different simulators for each model.
for awh = 1:length(modelling_inputs)
    %     % Making the directory to store the run data in.
    %     if ~exist(fullfile(mi.paths.storage_path, modelling_inputs{awh}.model_name),'file')
    %         mkdir(fullfile(mi.paths.storage_path, modelling_inputs{awh}.model_name))
    %     end %if
    %     ow_behaviour = '';
    % Write update to the command line
    disp(datestr(now))
    disp(['Running ',num2str(awh), ' of ',...
        num2str(length(modelling_inputs)), ' simulations'])
    
    sims = cell(1,1);
    s_ck = 1;
    if contains(mi.simulation_defs.sim_select, 'g')
        sims{s_ck} = 'geometry';
        s_ck = s_ck +1;
    end %if
    if contains(mi.simulation_defs.sim_select, 'w')
        sims{s_ck} = 'wake';
        s_ck = s_ck +1;
    end %if
    if contains(mi.simulation_defs.sim_select, 's')
        sims{s_ck} = 's_parameter';
        s_ck = s_ck +1;
    end %if
    if contains(mi.simulation_defs.sim_select, 'e')
        sims{s_ck} = 'eigenmode';
        s_ck = s_ck +1;
    end %if
    if contains(mi.simulation_defs.sim_select, 'l')
        sims{s_ck} = 'lossy eigenmode';
        s_ck = s_ck +1;
    end %if
    if contains(mi.simulation_defs.sim_select, 'r')
        sims{s_ck} = 'shunt';
    end %if
    
    for ksbi = 1:length(sims)
        try
            simulation_result_locations =  GdfidL_run_simulation(sims{ksbi}, mi.paths, modelling_inputs{awh}, ...
                force_sim);
        catch ERR
            display_modelling_error(ERR, sims{ksbi})
        end %try
    end %for
end %for

