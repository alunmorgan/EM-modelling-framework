function run_models(mi, sim_types, force_sim, restart_root)
% Runs all the geometric and simulation variations set up.

if ispc ==1
    error('This needs to be run on the linux modelling machine')
end %if

modelling_inputs = run_inputs_setup_STL(mi);

% Running the different simulators for each model.
for awh = 1:length(modelling_inputs)
    disp(datestr(now))
    disp(['Running ',num2str(awh), ' of ',...
        num2str(length(modelling_inputs)), ' simulations'])
    
    sims = cell(1,1);
    restart = cell(1,1);
    s_ck = 1;
    if contains(sim_types, 'wake')
        sims{s_ck} = 'wake';
        restart_loc_tmp =fullfile(restart_root, modelling_inputs{awh}.base_model_name, modelling_inputs{awh}.model_name, 'wake', '.iMod-1');
        if exist(restart_loc_tmp)
            restart{s_ck} = [' -restartfiles=',restart_loc_tmp, ' '];
        else
            restart{s_ck} = '';
        end %if
        s_ck = s_ck +1;
    end %if
    if str2double(modelling_inputs{awh}.beam_offset_x) == 0 ...
            && str2double(modelling_inputs{awh}.beam_offset_y) == 0
        % FIXME add filter for user signals
        if contains(sim_types, 'geometry') ...
                sims{s_ck} = 'geometry';
            restart_loc_tmp =fullfile(restart_root, modelling_inputs{awh}.base_model_name, modelling_inputs{awh}.model_name, 'geometry', '.iMod-1');
            if exist(restart_loc_tmp)
                restart{s_ck} = [' -restartfiles=',restart_loc_tmp, ' '];
            else
                restart{s_ck} = '';
            end %if
            s_ck = s_ck +1;
        end %if
        if contains(sim_types, 'sparameter')
            sims{s_ck} = 's_parameter';
            restart_loc_tmp =fullfile(restart_root, modelling_inputs{awh}.base_model_name, modelling_inputs{awh}.model_name, 's_parameter', '.iMod-1');
            if exist(restart_loc_tmp)
                restart{s_ck} = [' -restartfiles=',restart_loc_tmp, ' '];
            else
                restart{s_ck} = '';
            end %if
            s_ck = s_ck +1;
        end %if
        if contains(sim_types, 'eigenmode')
            sims{s_ck} = 'eigenmode';
            restart_loc_tmp =fullfile(restart_root, modelling_inputs{awh}.base_model_name, modelling_inputs{awh}.model_name, 'eigenmode', '.iMod-1');
            if exist(restart_loc_tmp)
                restart{s_ck} = [' -restartfiles=',restart_loc_tmp, ' '];
            else
                restart{s_ck} = '';
            end %if
            s_ck = s_ck +1;
        end %if
        if contains(sim_types, 'lossy_eigenmode')
            sims{s_ck} = 'lossy_eigenmode';
            restart_loc_tmp =fullfile(restart_root, modelling_inputs{awh}.base_model_name, modelling_inputs{awh}.model_name, 'lossy_eigenmode', '.iMod-1');
            if exist(restart_loc_tmp)
                restart{s_ck} = [' -restartfiles=',restart_loc_tmp, ' '];
            else
                restart{s_ck} = '';
            end %if
            s_ck = s_ck +1;
        end %if
        if contains(sim_types, 'shunt')
            sims{s_ck} = 'shunt';
            restart_loc_tmp =fullfile(restart_root, modelling_inputs{awh}.base_model_name, modelling_inputs{awh}.model_name, 'shunt', '.iMod-1');
            if exist(restart_loc_tmp)
                restart{s_ck} = [' -restartfiles=',restart_loc_tmp, ' '];
            else
                restart{s_ck} = '';
            end %if
        end %if
    end %if
    
    for ksbi = 1:length(sims)
        try
            sim_loc = find_position_in_cell_lst(strfind(sim_types, 'wake'));
            override = force_sim{sim_loc};
            simulation_result_locations =  GdfidL_run_simulation(sims{ksbi}, mi.paths, modelling_inputs{awh}, ...
                override, restart{ksbi});
        catch ERR
            display_modelling_error(ERR, sims{ksbi})
            cd(simulation_result_locations{1, 1})
            if strcmp(sims{ksbi}, 's_parameter')
                cd ..
            end %if
            continue
        end %try
    end %for
end %for

