function run_models(mi, sim_types, restart_root, versions, n_cores, precision)
% Runs all the geometric and simulation variations set up.

if ispc ==1
    error('This needs to be run on the linux modelling machine')
end %if
default_location = pwd;
modelling_inputs = run_inputs_setup_STL(mi, versions, n_cores, precision);

% Running the different simulators for each model.
for awh = 1:length(modelling_inputs)
    disp(datestr(now))
    disp(['Running ',num2str(awh), ' of ',...
        num2str(length(modelling_inputs)), ' simulations'])
    restart_loc_base =fullfile(restart_root, modelling_inputs{awh}.base_model_name, modelling_inputs{awh}.model_name);
    % only want to run the geometry simulations for the geometry sweeps.
    % remove it from the list otherwise.
    if ~strcmp(modelling_inputs{awh}.sweep_type, 'Geometry')
        g_ind = find_position_in_cell_lst(strfind(sim_types, 'geometry'));
        sim_types(g_ind) = [];
    end %if
    % only want to run the S parameter simulations for the geometry sweeps.
    % remove it from the list otherwise.
    if ~strcmp(modelling_inputs{awh}.sweep_type, 'Geometry')
        s_ind = find_position_in_cell_lst(strfind(sim_types, 'sparameter'));
        sim_types(s_ind) = [];
    end %if
    
    for ksbi = 1:length(sim_types)
        try
            %             sim_loc = find_position_in_cell_lst(strfind(sim_types, 'wake'));
            restart_loc_tmp =fullfile(restart_loc_base, sim_types{ksbi}, '.iMod-1');
            if exist(restart_loc_tmp, 'dir')
                restart_line = [' -restartfiles=',restart_loc_tmp, ' '];
            else
                restart_line = '';
            end %if
            GdfidL_run_simulation(sim_types{ksbi}, mi.paths, modelling_inputs{awh}, ...
                restart_line);
        catch ERR
            display_modelling_error(ERR, sim_types{ksbi})
            cd(default_location)
            %             if strcmp(sims{ksbi}, 's_parameter')
            %                 cd ..
            %             end %if
            continue
        end %try
    end %for
end %for

