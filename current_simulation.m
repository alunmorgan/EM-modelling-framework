function current_simulation(sets, varargin)
%sets(cell of strings/char): Names of the model sets to run.


sim_types = {'geometry','wake', 'sparameter', 'eigenmode', 'lossy_eigenmode', 'shunt'};

default_sim_types = {'geometry', 'wake', 'sparameter', 'lossy_eigenmode'};
default_stages = {'simulate', 'postprocess', 'analyse', 'reconstruct'  'plot'};
default_version = {'220421'};
default_number_of_cores = {'64'};
default_precision = {'double'};

p = inputParser;
p.StructExpand = false;
p.CaseSensitive = false;
addRequired(p, 'sets');
addParameter(p, 'sim_types', default_sim_types, @(x) any(contains(x,sim_types)))
addParameter(p, 'stages', default_stages)
addParameter(p, 'versions', default_version)
addParameter(p, 'n_cores', default_number_of_cores)
addParameter(p, 'precision', default_precision)

parse(p, sets, varargin{:});

paths = load_local_paths;
ppi = analysis_settings;
number_of_wake_lengths_to_analyse = 1;

%% Simulation
if any(contains(p.Results.stages, 'simulate'))
    orig_loc = pwd;
    for set_id = 1:length(p.Results.sets)
        try
            cd(fullfile(orig_loc, p.Results.sets{set_id}))
            run_inputs = feval(p.Results.sets{set_id});
            run_models(run_inputs, p.Results.sim_types, paths.restart_files_path, ...
                p.Results.versions, p.Results.n_cores, p.Results.precision)
            cd(orig_loc)
        catch ME
            cd(orig_loc)
            disp(['Problem simulating model ', p.Results.sets{set_id}])
            display_error_message(ME)
        end %try
    end %for
end %if

%% Post simulation
for set_id = 1:length(p.Results.sets)
    stamp = regexprep(datestr(now),':', '-');
    if ~exist(fullfile(paths.logfile_location, p.Results.sets{set_id}), 'dir')
        mkdir(fullfile(paths.logfile_location, p.Results.sets{set_id}))
    end %if
    % Setting up log file
    diary(fullfile(paths.logfile_location, p.Results.sets{set_id}, stamp));
    if any(contains(p.Results.stages, 'postprocess'))
        % postprocess the current set for all simulation types
        for herf = 1:length(p.Results.sim_types)
            orig_loc = pwd;
            try
                cd(fullfile(paths.inputfile_location, p.Results.sets{set_id}))
                run_inputs = feval(p.Results.sets{set_id});
                modelling_inputs = run_inputs_setup_STL(run_inputs, p.Results.versions, p.Results.n_cores, p.Results.precision);
                for awh = 1:length(modelling_inputs)
                    [old_loc, tmp_name] = prepare_for_pp(modelling_inputs{awh}.base_model_name,...
                        modelling_inputs{awh}.model_name, paths);
                    GdfidL_post_process_models(paths, modelling_inputs{awh}.model_name,...
                        'type_selection', p.Results.sim_types{herf});
                    if strcmp(p.Results.sim_types{herf}, 'wake')
                        extract_field_data(paths.scratch_loc)
                    end %if
                    cleanup_after_pp(old_loc, tmp_name)
                end %for
                cd(orig_loc)
            catch ME
                cd(orig_loc)
                disp([sets{set_id},' <strong>Problem with postprocessing models.</strong>'])
                display_error_message(ME)
            end %try
        end %for
    end %if
    if any(contains(p.Results.stages, 'analyse'))
        if any(contains(p.Results.sim_types, 'wake'))
            try
                analyse_pp_data(paths.results_loc, p.Results.sets{set_id});
            catch ME
                warning([sets{set_id}, ' <strong>Problem with wake analysis</strong>'])
                display_error_message(ME)
            end %try
        end %if
        if any(contains(p.Results.sim_types, 'sparameter'))
            try
                analyse_sparameter_data(paths.results_loc, p.Results.sets{set_id})
            catch ME
                warning([sets{set_id}, ' <strong>Problem with S parameter analysis</strong>'])
                display_error_message(ME)
            end %try
        end %if
        if any(contains(p.Results.sim_types, 'lossy_eigenmode'))
            try
                makeLossyEigenmodeSummaryTable(p.Results.sets{set_id}, results_loc)
            catch ME3
                warning([sets{set_id}, ' <strong>Problem with losy eigenmode analysis</strong>'])
                display_error_message(ME3)
            end %try
        end %if
    end %if
    if any(contains(p.Results.stages, 'reconstruct'))
        if any(contains(p.Results.sim_types, 'wake'))
            try
                reconstruct_pp_data(paths.results_loc,...
                    p.Results.sets{set_id}, ppi, number_of_wake_lengths_to_analyse);
            catch ME
                warning([sets{set_id}, ' <strong>Problem with wake reconstruction</strong>'])
                display_error_message(ME)
            end %try
        end %if
    end %if
    if any(contains(p.Results.stages, 'plot'))
        try
            datasets = find_datasets(fullfile(paths.results_loc, p.Results.sets{set_id}));
            plot_model(datasets, ppi, p.Results.sim_types);
        catch ME5
            warning([sets{set_id}, ' <strong>Problem with plotting</strong>'])
            display_error_message(ME5)
        end %try
    end %if
    %         generate_report_single_set(sets{set_id});
end %for



% upper_frequency = 25E9;

% try
% for set_id = 1:length(sets)
%     Blend_reports(sets(set_id), {'20'}, upper_frequency)
% end %for
% catch
%     disp(['Error in simulation. See ', logfile_location, ' for details'])
% end %try
