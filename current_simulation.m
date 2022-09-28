function current_simulation(sets, varargin)
%sets(cell of strings/char): Names of the model sets to run.


sim_types = {'geometry','wake', 'sparameter', 'eigenmode', 'lossy_eigenmode', 'shunt'};

default_sim_types = {'geometry', 'wake', 'sparameter', 'lossy_eigenmode'};
default_stages = {'simulate', 'postprocess', 'field_extraction', 'analyse', 'reconstruct'  'plot_analysis_data', 'plot_reconstruction_data', 'plot_fields'};
default_version = {'220421'};
default_number_of_cores = {'64'};
default_precision = {'double'};

p = inputParser;
p.StructExpand = false;
p.CaseSensitive = false;
addRequired(p, 'sets');
addParameter(p, 'sim_types', default_sim_types, @(x) any(matches(x,sim_types)))
addParameter(p, 'stages', default_stages)
addParameter(p, 'versions', default_version)
addParameter(p, 'n_cores', default_number_of_cores)
addParameter(p, 'precision', default_precision)

parse(p, sets, varargin{:});

paths = load_local_paths;
ppi = analysis_settings;
number_of_wake_lengths_to_analyse = 4;

%% Simulation
if any(matches(p.Results.stages, 'simulate'))
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
    if any(matches(p.Results.stages, 'postprocess'))
        run_postprocessing(p.Results, set_id, paths);
    end %if
    if any(matches(p.Results.stages, 'field_extraction'))
        run_field_extraction(p.Results, set_id, paths);
    end %if
    
    
    if any(matches(p.Results.stages, 'analyse'))
        if any(matches(p.Results.sim_types, 'wake'))
            run_wake_analysis(p.Results, set_id, paths)
        end %if
        if any(matches(p.Results.sim_types, 'sparameter'))
            run_sparameter_analysis(p.Results, set_id, paths)
        end %if
        if any(matches(p.Results.sim_types, 'lossy_eigenmode'))
            try
                makeLossyEigenmodeSummaryTable(p.Results.sets{set_id}, results_loc)
            catch ME3
                warning([sets{set_id}, ' <strong>Problem with losy eigenmode analysis</strong>'])
                display_error_message(ME3)
            end %try
        end %if
    end %if
    if any(matches(p.Results.stages, 'reconstruct'))
        if any(matches(p.Results.sim_types, 'wake'))
            run_wake_reconstruction(p.Results, set_id, paths)
        end %if
    end %if
    if any(matches(p.Results.stages, 'plot_analysis_data'))
        if any(matches(p.Results.sim_types, 'wake'))
            run_plot_wake_analysis(p.Results, set_id, paths, ppi)
        end %if
        if any(matches(p.Results.sim_types, 'sparameter'))
            run_plot_sparameter_analysis(p.Results, set_id, paths)
        end %if
    end %if
    if any(matches(p.Results.stages, 'plot_reconstruction_data'))
        if any(matches(p.Results.sim_types, 'wake'))
            run_plot_wake_reconstruction(p.Results, set_id, paths, ppi)          
        end %if
    end %if
    if any(matches(p.Results.stages, 'plot_fields'))
        if any(matches(p.Results.sim_types, 'wake'))
            plot_wake_fields(p.Results, set_id, paths)
        end %if
    end %if
    %         generate_report_single_set(sets{set_id});
end %for
