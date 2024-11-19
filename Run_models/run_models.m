function run_models(mi, sim_types, paths, versions, n_cores, precision)
% Runs all the geometric and simulation variations set up.
% if restart is not an empty string then is shows the location to the .iMod-1
% restart file.

if ispc ==1
    error('run_models:wrong_machine', 'This needs to be run on the linux modelling machine')
end %if

default_location = pwd;
modelling_inputs = run_inputs_setup_STL(mi, versions, n_cores, precision);

% Running the different simulators for each model.
sim_list = {'#! /bin/bash'};
fprintf(['\n', datestr(now)])
for awh = 1:length(modelling_inputs)
    % only want to run some simulation types for the geometry sweeps.
    % remove them from the list otherwise.
    geom_only = {'geometry', 'sparameter', 'lossy_eigenmode', 'eigenmode'};
    if ~strcmp(modelling_inputs{awh}.sweep_type, 'Geometry')
        for hes = 1:length(geom_only)
            g_ind = find_position_in_cell_lst(strfind(sim_types, geom_only{hes}));
            if ~isempty(g_ind)
                sim_types(g_ind) = [];
            end %if
        end %for
    end %if

    for ksbi = 1:length(sim_types)
        fprintf(['\nSetting up ',num2str(ksbi), ' of ',...
            num2str(length(sim_types)), ' simulations for model ', num2str(awh),...
            ' of ', num2str(length(modelling_inputs)),...
            ' (',sim_types{ksbi}, ' for ',modelling_inputs{awh}.model_name,')'])
        try
            file_locs = GdfidL_run_simulation(sim_types{ksbi}, paths, modelling_inputs{awh});
            if ~isempty(file_locs)
                sim_list = cat(2, sim_list, file_locs);
            end %if
            clear file_locs
        catch ERR
            display_modelling_error(ERR, sim_types{ksbi})
            cd(default_location)
            continue
        end %try
    end %for
end %for
sim_list_loc = fullfile(paths.data_loc, 'simulation_run_list.sh');
write_out_data( sim_list, sim_list_loc)
disp(" ")
disp("input file written to " + sim_list_loc)
pause(5)
make_file_executable(sim_list_loc)
