function run_postprocessing(input_settings)
% postprocess the current set for all simulation types

pp_list = {'#! /bin/bash'};

for awh = 1:length(input_settings.sets)
    % find the simulated variations
    [model_varients_folders, ~] = dir_list_gen(fullfile(input_settings.paths.data_loc, input_settings.sets{awh}),'dirs', 1);
    for nes = 1:length(model_varients_folders)
            pp_list_temp = GdfidL_post_process_models(input_settings, awh, model_varients_folders{nes});
            pp_list = cat(1, pp_list, pp_list_temp);
    end %for
end %for
fprintf('\n')

top_pp_name = fullfile(input_settings.paths.results_loc, 'postprocessing_script.sh');
write_out_data(pp_list, top_pp_name)
pause(5)
make_file_executable(top_pp_name)