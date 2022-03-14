function current_simulation(sets, varargin)
%sets(cell of strings/char): Names of the model sets to run.
default_logfile_location = '/scratch/afdm76/logs';
default_inputfile_location = '/scratch/afdm76/em_simulation_design_input_files';

binary_string = {'yes', 'no'};
sim_types = {'wake', 'sparameter', 'eigenmode', 'lossy_eigenmode', 'shunt'};

default_sim_types = {'wake', 'sparameter', 'eigenmode', 'lossy_eigenmode'};
default_override = {'no', 'no', 'no', 'no'};
default_stages = {'simulate', 'postprocess', 'analyse', 'plot'};
default_version = {'220303'};
default_number_of_cores = {'48'};
default_precision = {'double'};

p = inputParser;
p.StructExpand = false;
p.CaseSensitive = false;
addRequired(p, 'sets');
addParameter(p, 'logfile_location', default_logfile_location);
addParameter(p, 'inputfile_location', default_inputfile_location);
addParameter(p, 'sim_types', default_sim_types, @(x) any(contains(x,sim_types)))
addParameter(p, 'override', default_override, @(x) any(contains(x,binary_string)))
addParameter(p, 'stages', default_stages)
addParameter(p, 'versions', default_version)
addParameter(p, 'n_cores', default_number_of_cores)
addParameter(p, 'precision', default_precision)

parse(p, sets, varargin{:});

try
    if any(contains(p.Results.stages, 'simulate'))
        run_model_sets(p.Results.sets, p.Results.sim_types, p.Results.override,...
                       p.Results.versions, p.Results.n_cores, p.Results.precision);
    end %if
    for set_id = 1:length(p.Results.sets)
        stamp = regexprep(datestr(now),':', '-');
        if ~exist(fullfile(p.Results.logfile_location, p.Results.sets{set_id}), 'dir')
            mkdir(fullfile(p.Results.logfile_location, p.Results.sets{set_id}))
        end %if
        % Setting up log file
        diary(fullfile(p.Results.logfile_location, p.Results.sets{set_id}, stamp));
        if any(contains(p.Results.stages, 'postprocess'))
            postprocess_single_set(p.Results.sets{set_id}, p.Results.inputfile_location, ...
                p.Results.sim_types, p.Results.override);
        end %if
        if any(contains(p.Results.stages, 'analyse'))
            analyse_single_set(sets{set_id}, p.Results.sim_types, p.Results.override);
        end %if
        if any(contains(p.Results.stages, 'plot'))
            plot_single_set(sets{set_id}, p.Results.sim_types, p.Results.override);
        end %if
        %         generate_report_single_set(sets{set_id});
    end %for
catch ME1
    display_error_message(ME1)
end %try


% upper_frequency = 25E9;

% try
% for set_id = 1:length(sets)
%     Blend_reports(sets(set_id), {'20'}, upper_frequency)
% end %for
% catch
%     disp(['Error in simulation. See ', logfile_location, ' for details'])
% end %try
