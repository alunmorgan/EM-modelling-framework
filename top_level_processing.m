function top_level_processing(sets, varargin)

%sets(cell of strings/char): Names of the model sets to run.


sim_types = {'geometry','wake', 'sparameter', 'eigenmode', 'lossy_eigenmode', 'shunt'};

default_sim_types = {'geometry', 'wake', 'sparameter', 'lossy_eigenmode'};
default_stages = {'simulate', 'postprocess', 'field_extraction', 'analyse', 'reconstruct'  'plot_analysed_data', 'plot_reconstruction_data', 'plot_fields', 'plot_thermals','report'};
default_version = {'241105'};
default_number_of_cores = {'60'}; % less than max to avoid contension with other users
default_precision = {'double'};
default_author = {'Alun Morgan'};

p = inputParser;
p.StructExpand = false;
p.CaseSensitive = false;
addRequired(p, 'sets');
addParameter(p, 'sim_types', default_sim_types, @(x) any(matches(x,sim_types)))
addParameter(p, 'stages', default_stages)
addParameter(p, 'versions', default_version)
addParameter(p, 'n_cores', default_number_of_cores)
addParameter(p, 'precision', default_precision)
addParameter(p, 'author', default_author)

parse(p, sets, varargin{:});
input_data = p.Results;
input_data.paths = load_local_paths;

for set_id = 1:length(input_data.sets)
    %% Setting up log file
    stamp = regexprep(datestr(now),':', '-');
    if ~exist(fullfile(input_data.paths.logfile_location, input_data.sets{set_id}), 'dir')
        mkdirtree(fullfile(input_data.paths.logfile_location, input_data.sets{set_id}))
    end %if
    diary(fullfile(input_data.paths.logfile_location, input_data.sets{set_id}, stamp));
end %for

input_data.ppi = analysis_settings;
%% Eigenmode plotting settings
input_data.ppi.eigenmode.cuts = {'x', '0';'y', '0';'z', '0';};
input_data.ppi.eigenmode.scale = '2';
% input_data.ppi.eigenmode.subsections{1}.ymin = '-4E-3';
% input_data.ppi.eigenmode.subsections{1}.ymax = '4E-3';
% input_data.ppi.eigenmode.subsections{1}.xmin = '13E-3';
% input_data.ppi.eigenmode.subsections{1}.xmax = '14E-3';
% input_data.ppi.eigenmode.subsections{1}.zmin = '-4E-3';
% input_data.ppi.eigenmode.subsections{1}.zmax = '4E-3';

number_of_wake_lengths_to_analyse = 4;
% If 1 then the postprocessor will export the full fields to ascii files.
% This can take a long time so may not be desired always.
input_data.ppi.fullfieldexport = 0;

%% Simulation
if any(matches(input_data.stages, 'simulate'))
    run_models(input_data)
end %if

%% Postprocessing
if any(matches(input_data.stages, 'postprocess'))
    run_postprocessing(input_data);
end %if

for set_id = 1:length(input_data.sets)
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
                run_eigenmode_analysis(input_data, set_id)
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

    %% Plotting (postprocessing)
    if any(matches(input_data.stages, 'plot_postprocessed_data'))
        if any(matches(input_data.sim_types, 'wake'))
            run_plot_wake_postprocessed(input_data, set_id)
        end %if
    end %if

    %% Plotting (analysis)
    if any(matches(input_data.stages, 'plot_analysed_data'))
        if any(matches(input_data.sim_types, 'wake'))
            run_plot_wake_analysis(input_data, set_id)
        end %if
        if any(matches(p.Results.sim_types, 'sparameter'))
            run_plot_sparameter_analysis(input_data, set_id)
        end %if
        if any(matches(p.Results.sim_types, 'lossy_eigenmode'))
            run_plot_eigenmode_analysis(input_data, set_id)
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

    %% Report generation
    if any(matches(p.Results.stages, 'report'))
        generate_report_single_set(input_data, set_id);
    end %if
end %for
