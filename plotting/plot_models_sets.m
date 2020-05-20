function plot_models_sets(model_sets, varargin)
% Run analysis on multiple models in the settings in the analysis library.
p = inputParser;
   addRequired(p,'model_sets',@iscell);
   addOptional(p,'skip_plotting','skip',@ischar);
parse(p, model_sets, varargin{:});

if strcmp(p.Results.skip_plotting, 'skip')
    override = 0;
elseif strcmp(p.Results.skip_plotting, 'no_skip')
    override = 1;
end %if
[report_root, names, analysis_library] = analysis_model_settings_library;
ppi = analysis_settings;

for nw = 1:length(model_sets)
      mse = strcmp(names, model_sets{nw}) == 1;
    input_settings = analysis_library{mse};
    plot_model(report_root, ppi, input_settings, override);
end %for