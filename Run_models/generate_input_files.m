function generate_input_files(paths, sets, varargin)

%sets(cell of strings/char): Names of the model sets to run.


sim_types = {'geometry','wake', 'sparameter', 'eigenmode', 'lossy_eigenmode', 'shunt'};

default_sim_types = {'geometry', 'wake', 'sparameter', 'lossy_eigenmode'};
default_version = {'230330'};
default_number_of_cores = {'60'}; % less than max to avoid contension with other users
default_precision = {'double'};

p = inputParser;
p.StructExpand = false;
p.CaseSensitive = false;
addRequired(p, 'paths');
addRequired(p, 'sets');
addParameter(p, 'sim_types', default_sim_types, @(x) any(matches(x,sim_types)))
addParameter(p, 'versions', default_version)
addParameter(p, 'n_cores', default_number_of_cores)
addParameter(p, 'precision', default_precision)

parse(p, paths, sets, varargin{:});

%% Simulation setup
orig_loc = pwd;
for set_id = 1:length(p.Results.sets)
    try
        cd(fullfile(paths.inputfile_location, p.Results.sets{set_id}))
        % Read in the simulation settings for the model
        run_inputs = feval(p.Results.sets{set_id});
        % generate the input files for the simulations
        run_models(run_inputs, p.Results.sim_types, paths, ...
            p.Results.versions, p.Results.n_cores, p.Results.precision)
        cd(orig_loc)
    catch ME
        cd(orig_loc)
        fprintf(['\nProblem generating input file for ', p.Results.sets{set_id}])
        display_error_message(ME)
    end %try
end %for