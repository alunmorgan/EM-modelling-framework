function run_pp = will_pp_run(sim_type, skip_setting)

if strcmp(skip_setting, 'no_skip')
    run_pp = 1;
elseif strcmp(skip_setting, 'skip')
    if exist(fullfile('pp_link', sim_type, ['model_', sim_type, '_post_processing']), 'file') == 0 &&...
            exist(fullfile('pp_link', sim_type, 'data_postprocessed.mat'), 'file') == 0
        run_pp = 1;
    else
        run_pp = 0;
    end %if
else
    error('Please select skip or no_skip for the postprocessing')
end %if
