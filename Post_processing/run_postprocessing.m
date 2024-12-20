function run_postprocessing(input_settings, set_id)
% postprocess the current set for all simulation types

pp_list = {'#! /bin/bash'};

orig = pwd;
cd(fullfile(input_settings.paths.inputfile_location, input_settings.sets{set_id}));
% run_inputs = feval(input_settings.sets{set_id});
cd(orig);
% modelling_inputs = run_inputs_setup_STL(run_inputs, input_settings.versions,...
%     input_settings.n_cores, input_settings.precision);
for awh = 1:length(input_settings.sets)
    % find the simulated variations
    [model_varients_folders, ~] = dir_list_gen(fullfile(input_settings.paths.data_loc, input_settings.sets{awh}),'dirs', 1);
    for nes = 1:length(model_varients_folders)
        %         create the postprocessing folder structure
%         [folder_status, folder_message] = mkdir(fullfile(input_settings.paths.results_loc, input_settings.sets{awh}, model_varients_folders{nes},'postprocessing'));
        for herf = 1:length(input_settings.sim_types)
            try
                data_directory = fullfile(input_settings.paths.data_loc, ...
                    input_settings.sets{awh}, model_varients_folders{nes},...
                    input_settings.sim_types{herf});
                pp_directory = fullfile(input_settings.paths.results_loc,...
                    input_settings.sets{awh}, model_varients_folders{nes},...
                    'postprocessing', input_settings.sim_types{herf});
                pp_list_temp = GdfidL_post_process_models(input_settings.ppi, data_directory, pp_directory);
                pp_list = cat(1, pp_list, pp_list_temp);
            catch ME
                fprintf(['\n', input_settings.sets{set_id},' <strong>Problem with postprocessing models.</strong>'])
                display_error_message(ME)
            end %try
        end %for
    end %for
end %for
fprintf('\n')

top_pp_name = fullfile(input_settings.paths.results_loc, 'postprocessing_script.sh');
write_out_data(pp_list, top_pp_name)
pause(5)
make_file_executable(top_pp_name)