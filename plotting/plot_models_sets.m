function plot_models_sets(model_sets, varargin)
% Run analysis on multiple models in the settings in the analysis library.
p = inputParser;
addRequired(p,'model_sets',@iscell);
addOptional(p,'skip_plotting','skip',@ischar);
addOptional(p,'plotting_types',{'all'},@iscell);
parse(p, model_sets, varargin{:});

paths = load_local_paths;
ppi = analysis_settings;

for nw = 1:length(model_sets)
        input_settings = analysis_model_settings_library(model_sets{mse});
%         try
            plot_model(paths.results_loc, ppi, input_settings, p.Results.skip_plotting, p.Results.plotting_types);
%         catch ME
%             disp([model_sets{nw}, ' Problem with plotting'])
%             display_error_message(ME)
%         end %try
end %for