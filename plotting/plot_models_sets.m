function plot_models_sets(model_sets, varargin)
% Run analysis on multiple models in the settings in the analysis library.
p = inputParser;
addRequired(p,'model_sets',@iscell);
addOptional(p,'skip_plotting','skip',@ischar);
addOptional(p,'plotting_types',{'all'},@iscell);
parse(p, model_sets, varargin{:});

if strcmp(p.Results.skip_plotting, 'skip')
    override = 0;
elseif strcmp(p.Results.skip_plotting, 'no_skip')
    override = 1;
end %if
load_local_paths
[names, analysis_library] = analysis_model_settings_library;
ppi = analysis_settings;

for nw = 1:length(model_sets)
    mse = strcmp(names, model_sets{nw}) == 1;
    if sum(mse) > 0
        input_settings = analysis_library{mse};
%         try
            plot_model(results_loc, ppi, input_settings, override, p.Results.plotting_types);
%         catch ME
%             disp([model_sets{nw}, ' Problem with plotting'])
%             display_error_message(ME)
%         end %try
    else
        disp([model_sets{nw}, ' Input file not matched with analysis library'])
    end %if
end %for