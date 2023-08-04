function current_simulation(sets, varargin)
%sets(cell of strings/char): Names of the model sets to run.


sim_types = {'geometry','wake', 'sparameter', 'eigenmode', 'lossy_eigenmode', 'shunt'};

default_sim_types = {'geometry', 'wake', 'sparameter', 'lossy_eigenmode'};
default_stages = {'simulate', 'postprocess', 'field_extraction', 'analyse', 'reconstruct'  'plot_analysis_data', 'plot_reconstruction_data', 'plot_fields', 'plot_thermals','report'};
default_version = {'230330'};
default_number_of_cores = {'60'}; % less than max to avoid contension with other users
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
            cd(fullfile(paths.inputfile_location, p.Results.sets{set_id}))
            run_inputs = feval(p.Results.sets{set_id});
            run_models(run_inputs, p.Results.sim_types, paths, ...
                p.Results.versions, p.Results.n_cores, p.Results.precision, '')
            cd(orig_loc)
        catch ME
            cd(orig_loc)
            fprintf(['\nProblem simulating model ', p.Results.sets{set_id}])
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
            run_wake_reconstruction(p.Results, set_id, paths, ppi, number_of_wake_lengths_to_analyse)
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
            generate_wake_field_vids(p.Results, set_id, paths)
        end %if
    end %if
    if any(matches(p.Results.stages, 'plot_thermals'))
        if any(matches(p.Results.sim_types, 'wake'))
           extract_wall_losses(p.Results, set_id, paths);
        end %if
    end %if
     if any(matches(p.Results.stages, 'report'))
            generate_report_single_set(sets{set_id});
     end %if
end %for
