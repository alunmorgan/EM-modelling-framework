function run_setup(input_settings, set_id)
% postprocess the current set for all simulation types

orig = pwd;
cd(fullfile(input_settings.paths.inputfile_location, input_settings.sets{set_id}));
run_inputs = feval(input_settings.sets{set_id});
cd(orig);
modelling_inputs = run_inputs_setup_STL(run_inputs, input_settings.versions,...
    input_settings.n_cores, input_settings.precision);
for herf = 1:length(input_settings.sim_types)
    try
        for awh = 1:length(modelling_inputs)
            post_process_setup(input_settings.paths, modelling_inputs{awh},...
                input_settings.sim_types{herf})
        end %for
    catch ME
        fprintf(['\n', input_settings.sets{set_id},' <strong>Problem with postprocessing setup.</strong>'])
        display_error_message(ME)
    end %try
end %for
fprintf('\n')
