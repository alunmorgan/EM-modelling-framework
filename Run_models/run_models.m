function run_models(mi, force_sim, force_pp)


if ispc ==1
    error('This needs to be run on the linux modelling machine')
end %if

%%%% Generating mappings %%%%%
for nwe = 1:length(mi.mat_params)
    % Structure is {stl file name, material name, order to apply the stl files}
    mi.stl_part_mapping{nwe,1} = [mi.base_model_name, '-', mi.mat_params{nwe}{1}];
    mi.stl_part_mapping{nwe,2} = mi.mat_params{nwe}{2};
    mi.stl_part_mapping{nwe,3} = mi.mat_params{nwe}{6};
end %for
% A lookup table of materials to component names
ck = 1;
for nes = 1:length(mi.mat_params)
    if ~strcmp(mi.mat_params{nes}{2}, 'vacuum')
        mi.mat_list{ck, 1} = mi.mat_params{nes}{2};
        mi.mat_list{ck, 2} = mi.mat_params{nes}{3};
        mi.material_defs{ck} = {mi.mat_params{nes}{2}, ...
            mi.mat_params{nes}{5}, mi.mat_params{nes}{4}};
        ck = ck +1;
    end %if
end %for


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
    try
        model_name = modelling_inputs{awh}.model_name;
        if isnan(simulation_result_locations{1})
            %If the simulation results already exist then the location is
            %NaN.
            GdfidL_post_process_models(mi.paths, model_name, 'ow_behaviour',force_pp);
        else
            GdfidL_post_process_models(mi.paths, model_name, ...
                'ow_behaviour',force_pp,...
                'input_data_location', simulation_result_locations);
        end %if
    catch ERR
        display_postprocessing_error(ERR)
    end %try
end %for

