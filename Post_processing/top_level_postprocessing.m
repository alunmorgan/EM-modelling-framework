function top_level_postprocessing(paths, ppi, sets, varargin)

%sets(cell of strings/char): Names of the model sets to run.


sim_types = {'geometry','wake', 'sparameter', 'eigenmode', 'lossy_eigenmode', 'shunt'};

default_sim_types = {'geometry', 'wake', 'sparameter', 'lossy_eigenmode'};
default_stages = {'setup', 'postprocess', 'field_extraction', 'analyse', 'reconstruct'  'plot_analysis_data', 'plot_reconstruction_data', 'plot_fields', 'plot_thermals','report'};
default_version = {'230330'};
default_number_of_cores = {'60'}; % less than max to avoid contension with other users
default_precision = {'double'};

p = inputParser;
p.StructExpand = false;
p.CaseSensitive = false;
addRequired(p, 'paths');
addRequired(p, 'ppi'); % analysis_settings
addRequired(p, 'sets');
addParameter(p, 'sim_types', default_sim_types, @(x) any(matches(x,sim_types)))
addParameter(p, 'stages', default_stages)
addParameter(p, 'versions', default_version)
addParameter(p, 'n_cores', default_number_of_cores)
addParameter(p, 'precision', default_precision)

parse(p, paths, ppi, sets, varargin{:});

% ppi = analysis_settings;
number_of_wake_lengths_to_analyse = 4;

%% Post simulation
for set_id = 1:length(p.Results.sets)
    % Making a copy of data folder structure for post processing
%     make_pp_folder_structure(paths, sets, set_id)



    %% Setting up log file
    stamp = regexprep(datestr(now),':', '-');
    if ~exist(fullfile(paths.logfile_location, p.Results.sets{set_id}), 'dir')
        mkdir(fullfile(paths.logfile_location, p.Results.sets{set_id}))
    end %if
    diary(fullfile(paths.logfile_location, p.Results.sets{set_id}, stamp));
    % Setup directory structure and copy across setup datafiles
    if any(matches(p.Results.stages, 'setup'))
%         if ~any(matches(p.Results.sim_types, 'geometry'))
            run_setup(p.Results, set_id);
%         end %if
    end %if

    %% Postprocessing
    if any(matches(p.Results.stages, 'postprocess'))
%         if ~any(matches(p.Results.sim_types, 'geometry'))
            run_postprocessing(p.Results, set_id);
%         end %if
    end %if

    %% Field extraction
    if any(matches(p.Results.stages, 'field_extraction'))
        run_field_extraction(p.Results, set_id, p.Results.paths);
    end %if

    %% Analysis
    if any(matches(p.Results.stages, 'analyse'))
        if any(matches(p.Results.sim_types, 'wake'))
            run_wake_analysis(p.Results, set_id, p.Results.paths)
        end %if
        if any(matches(p.Results.sim_types, 'sparameter'))
            run_sparameter_analysis(p.Results, set_id, p.Results.paths)
        end %if
        if any(matches(p.Results.sim_types, 'lossy_eigenmode'))
            try
                makeLossyEigenmodeSummaryTable(p.Results.sets{set_id}, results_loc)
            catch ME3
                warning('top_level_post_processing:analysis', [sets{set_id}, ' <strong>Problem with losy eigenmode analysis</strong>'])
                display_error_message(ME3)
            end %try
        end %if
    end %if

    %% Reconstruction
    if any(matches(p.Results.stages, 'reconstruct'))
        if any(matches(p.Results.sim_types, 'wake'))
            run_wake_reconstruction(p.Results, set_id, paths, ppi, number_of_wake_lengths_to_analyse)
        end %if
    end %if

    %% Plotting (analysis)
    if any(matches(p.Results.stages, 'plot_analysis_data'))
        if any(matches(p.Results.sim_types, 'wake'))
            run_plot_wake_analysis(p.Results, set_id, paths, ppi)
        end %if
        if any(matches(p.Results.sim_types, 'sparameter'))
            run_plot_sparameter_analysis(p.Results, set_id, paths)
        end %if
    end %if

    %% Plotting (reconstruction)
    if any(matches(p.Results.stages, 'plot_reconstruction_data'))
        if any(matches(p.Results.sim_types, 'wake'))
            run_plot_wake_reconstruction(p.Results, set_id, paths, ppi)
        end %if
    end %if

    %% Plotting (fields)
    if any(matches(p.Results.stages, 'plot_fields'))
        if any(matches(p.Results.sim_types, 'wake'))
%             plot_wake_fields(p.Results, set_id, paths)
            generate_wake_field_vids(p.Results, set_id, paths)
        end %if
    end %if

    %% Plotting (thermals)
    if any(matches(p.Results.stages, 'plot_thermals'))
        if any(matches(p.Results.sim_types, 'wake'))
            extract_wall_losses(p.Results, set_id, paths);
            plot_wall_losses(p.Results, set_id, paths)
        end %if
    end %if

%     %% Report generation
%     if any(matches(p.Results.stages, 'report'))
%         generate_report_single_set(sets{set_id});
%     end %if
end %for
