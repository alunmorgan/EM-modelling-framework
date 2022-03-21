function analyse_models_sets(model_sets)
% Run analysis on multiple models in the settings in the analysis library.

load_local_paths
%% Postprocessing setup.
% if wake simulation and you want to investigate machine parameters these
% can be set here.
ppi = analysis_settings;

for nw = 1:length(model_sets)
    input_settings = analysis_model_settings_library(model_sets{nw});
    try
    analyse_pp_data(results_loc,...
        model_sets(nw), ppi,...
        input_settings.wake.portOverrides);
    catch ME
        warning([model_sets{nw}, ' Problem with analysis'])
        display_error_message(ME)
    end %try
end
