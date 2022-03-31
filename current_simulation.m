function current_simulation(sets, varargin)
%sets(cell of strings/char): Names of the model sets to run.


sim_types = {'wake', 'sparameter', 'eigenmode', 'lossy_eigenmode', 'shunt'};

default_sim_types = {'wake', 'sparameter', 'lossy_eigenmode'};
default_stages = {'simulate', 'postprocess', 'analyse', 'reconstruct'  'plot'};
default_version = {'220315'};
default_number_of_cores = {'40'};
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

load_local_paths
ppi = analysis_settings;
number_of_wake_lengths_to_analyse = 1;
try
    if any(contains(p.Results.stages, 'simulate'))
        run_model_sets(p.Results.sets, p.Results.sim_types,...
            p.Results.versions, p.Results.n_cores, p.Results.precision);
    end %if
catch ME1
    disp([sets{set_id},' <strong>Problem with simulating models.</strong>'])
    display_error_message(ME1)
end %try

for set_id = 1:length(p.Results.sets)
    stamp = regexprep(datestr(now),':', '-');
    if ~exist(fullfile(logfile_location, p.Results.sets{set_id}), 'dir')
        mkdir(fullfile(logfile_location, p.Results.sets{set_id}))
    end %if
    % Setting up log file
    diary(fullfile(logfile_location, p.Results.sets{set_id}, stamp));
    if any(contains(p.Results.stages, 'postprocess'))
        % postprocess the current set for all simulation types
        for herf = 1:length(p.Results.sim_types)
            orig_loc = pwd;
            try
                cd(fullfile(inputfile_location, p.Results.sets{set_id}))
                run_inputs = feval(p.Results.sets{set_id});
                modelling_inputs = run_inputs_setup_STL(run_inputs, p.Results.versions, p.Results.n_cores, p.Results.precision);
                for awh = 1:length(modelling_inputs)
                    GdfidL_post_process_models(mi.paths, modelling_inputs{awh}.model_name,...
                        'type_selection', p.Results.sim_types{herf});
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
                analyse_pp_data(results_loc, p.Results.sets{set_id});
            catch ME
                warning([sets{set_id}, ' <strong>Problem with wake analysis</strong>'])
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
                reconstruct_pp_data(results_loc,...
                    p.Results.sets{set_id}, ppi, number_of_wake_lengths_to_analyse);
            catch ME
                warning([sets{set_id}, ' <strong>Problem with wake analysis</strong>'])
                display_error_message(ME)
            end %try
        end %if
    end %if
    if any(contains(p.Results.stages, 'plot'))
        try
            datasets = find_datasets(fullfile(results_loc, p.Results.sets{set_id}));
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
