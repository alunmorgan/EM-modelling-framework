function top_level_postprocessing(sets, varargin)

%sets(cell of strings/char): Names of the model sets to run.


sim_types = {'geometry','wake', 'sparameter', 'eigenmode', 'lossy_eigenmode', 'shunt'};

default_sim_types = {'geometry', 'wake', 'sparameter', 'lossy_eigenmode'};
default_stages = {'setup', 'postprocess', 'field_extraction', 'analyse', 'reconstruct'  'plot_analysis_data', 'plot_reconstruction_data', 'plot_fields', 'plot_thermals','report'};
default_version = {'241105'};
default_number_of_cores = {'60'}; % less than max to avoid contension with other users
default_precision = {'double'};

p = inputParser;
p.StructExpand = false;
p.CaseSensitive = false;
%addRequired(p, 'paths');
%addRequired(p, 'ppi'); % analysis_settings
addRequired(p, 'sets');
addParameter(p, 'sim_types', default_sim_types, @(x) any(matches(x,sim_types)))
addParameter(p, 'stages', default_stages)
addParameter(p, 'versions', default_version)
addParameter(p, 'n_cores', default_number_of_cores)
addParameter(p, 'precision', default_precision)

parse(p, sets, varargin{:});
input_data = p.Results;
input_data.ppi = analysis_settings;
input_data.paths = load_local_paths;
number_of_wake_lengths_to_analyse = 4;



%% Post simulation
for set_id = 1:length(input_data.sets)
    %% Setting up log file
    stamp = regexprep(datestr(now),':', '-');
    if ~exist(fullfile(input_data.paths.logfile_location, input_data.sets{set_id}), 'dir')
        mkdirtree(fullfile(input_data.paths.logfile_location, input_data.sets{set_id}))
    end %if
    diary(fullfile(input_data.paths.logfile_location, input_data.sets{set_id}, stamp));
    % Setup directory structure and copy across setup datafiles
    if any(matches(input_data.stages, 'setup'))
%         if ~any(matches(input_data.sim_types, 'geometry'))
            run_setup(input_data, set_id);
%         end %if
    end %if

    %% Postprocessing
    if any(matches(input_data.stages, 'postprocess'))
%         if ~any(matches(input_data.sim_types, 'geometry'))
            run_postprocessing(input_data, set_id);
%         end %if
    end %if

    %% Field extraction
    if any(matches(input_data.stages, 'field_extraction'))
        run_field_extraction(input_data, set_id);
    end %if

    %% Analysis
    if any(matches(input_data.stages, 'analyse'))
        if any(matches(input_data.sim_types, 'wake'))
            run_wake_analysis(input_data, set_id)
        end %if
        if any(matches(input_data.sim_types, 'sparameter'))
            run_sparameter_analysis(input_data, set_id)
        end %if
        if any(matches(input_data.sim_types, 'lossy_eigenmode'))
            try
                makeLossyEigenmodeSummaryTable(input_data.sets{set_id}, results_loc)
            catch ME3
                warning('top_level_post_processing:analysis', [sets{set_id}, ' <strong>Problem with losy eigenmode analysis</strong>'])
                display_error_message(ME3)
            end %try
        end %if
    end %if

    %% Reconstruction
    if any(matches(input_data.stages, 'reconstruct'))
        if any(matches(input_data.sim_types, 'wake'))
            run_wake_reconstruction(input_data, set_id, number_of_wake_lengths_to_analyse)
        end %if
    end %if

    %% Plotting (analysis)
    if any(matches(input_data.stages, 'plot_analysis_data'))
        if any(matches(input_data.sim_types, 'wake'))
            run_plot_wake_analysis(input_data, set_id)
        end %if
        if any(matches(p.Results.sim_types, 'sparameter'))
            run_plot_sparameter_analysis(input_data, set_id)
        end %if
    end %if

    %% Plotting (reconstruction)
    if any(matches(p.Results.stages, 'plot_reconstruction_data'))
        if any(matches(p.Results.sim_types, 'wake'))
            run_plot_wake_reconstruction(input_data, set_id)
        end %if
    end %if

    %% Plotting (fields)
    if any(matches(input_data.stages, 'plot_fields'))
        if any(matches(input_data.sim_types, 'wake'))
            plot_wake_fields(input_data, set_id)
            generate_wake_field_vids(input_data, set_id)
        end %if
    end %if

    %% Plotting (thermals)
    if any(matches(input_data.stages, 'plot_thermals'))
        if any(matches(input_data.sim_types, 'wake'))
            extract_wall_losses(input_data, set_id);
            plot_wall_losses(input_data, set_id)
        end %if
    end %if

%     %% Report generation
%     if any(matches(p.Results.stages, 'report'))
%         generate_report_single_set(sets{set_id});
%     end %if
end %for
