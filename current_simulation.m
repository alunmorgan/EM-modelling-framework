function current_simulation(sets, varargin)
%sets(cell of strings/char): Names of the model sets to run.


sim_types = {'geometry','wake', 'sparameter', 'eigenmode', 'lossy_eigenmode', 'shunt'};

default_sim_types = {'geometry', 'wake', 'sparameter', 'lossy_eigenmode'};
default_version = {'241105'};
default_number_of_cores = {'60'}; % less than max to avoid contension with other users
default_precision = {'double'};

p = inputParser;
p.StructExpand = false;
p.CaseSensitive = false;
addRequired(p, 'sets');
addParameter(p, 'sim_types', default_sim_types, @(x) any(matches(x,sim_types)))
addParameter(p, 'versions', default_version)
addParameter(p, 'n_cores', default_number_of_cores)
addParameter(p, 'precision', default_precision)

parse(p, sets, varargin{:});

paths = load_local_paths;

for set_id = 1:length(p.Results.sets)
    mkdirtree(fullfile(paths.logfile_location, p.Results.sets{set_id}))
end %for

%% Simulation
orig_loc = pwd;
for set_id = 1:length(p.Results.sets)
    % Setting up log file
    stamp = regexprep(datestr(now),':', '-');
    diary(fullfile(paths.logfile_location, p.Results.sets{set_id}, stamp));
    try
        cd(fullfile(paths.inputfile_location, p.Results.sets{set_id}))
        run_inputs = feval(p.Results.sets{set_id});
        run_models(run_inputs, p.Results.sim_types, paths, ...
            p.Results.versions, p.Results.n_cores, p.Results.precision)
        cd(orig_loc)
    catch ME
        cd(orig_loc)
        fprintf(['\nProblem simulating model \n', p.Results.sets{set_id}])
        display_error_message(ME)
    end %try
end %for
