function run_models(input_data)
% Runs all the geometric and simulation variations set up.
% if restart is not an empty string then is shows the location to the .iMod-1
% restart file.

if ispc ==1
    error('run_models:wrong_machine', 'This needs to be run on the linux modelling machine')
end %if

default_location = pwd;
sim_list = {'#! /bin/bash'};
sim_list = cat(1,sim_list,'# Generates the log location if it does not exist.');
sim_list = cat(1,sim_list,['DATALOC=',input_data.paths.logfile_location]);
sim_list = cat(1,sim_list,'if [ ! -d $DATALOC ]; then');
sim_list = cat(1,sim_list,'mkdir -p $DATALOC');
sim_list = cat(1,sim_list,'fi');

for nse = 1:length(input_data.sets)
    cd(fullfile(input_data.paths.inputfile_location, input_data.sets{nse}))
    mi = feval(input_data.sets{nse});
    cd(default_location)
    modelling_inputs = run_inputs_setup_STL(mi, input_data.versions, input_data.n_cores, input_data.precision);
    % Running the different simulators for each model.
    fprintf(['\n', datestr(now)])
    for awh = 1:length(modelling_inputs)
        % only want to run some simulation types for the geometry sweeps.
        % remove them from the list otherwise.
        geom_only = {'geometry', 'sparameter', 'lossy_eigenmode', 'eigenmode'};
        if ~strcmp(modelling_inputs{awh}.sweep_type, 'Geometry')
            for hes = 1:length(geom_only)
                g_ind = find_position_in_cell_lst(strfind(input_data.sim_types, geom_only{hes}));
                if ~isempty(g_ind)
                    input_data.sim_types(g_ind) = [];
                end %if
            end %for
        end %if

        for ksbi = 1:length(input_data.sim_types)
            fprintf(['\nSetting up ',num2str(ksbi), ' of ',...
                num2str(length(input_data.sim_types)), ' simulations for model ', num2str(awh),...
                ' of ', num2str(length(modelling_inputs)),...
                ' (',input_data.sim_types{ksbi}, ' for ',modelling_inputs{awh}.model_name,')'])
            try
                file_locs = GdfidL_run_simulation(input_data.sim_types{ksbi}, input_data.paths, modelling_inputs{awh});
                if ~isempty(file_locs)
                    sim_list = cat(1, sim_list, file_locs);
                end %if
                clear file_locs
            catch ERR
                display_modelling_error(ERR, input_data.sim_types{ksbi})
                cd(default_location)
                continue
            end %try
        end %for
    end %for
end %for
sim_list_loc = fullfile(input_data.paths.data_loc, 'simulation_run_list.sh');
write_out_data( sim_list, sim_list_loc)
disp(" ")
disp("input file written to " + sim_list_loc)
pause(5)
make_file_executable(sim_list_loc)
