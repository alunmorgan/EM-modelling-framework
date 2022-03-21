function run_pp = will_pp_run(sim_type)


if exist(fullfile('pp_link', sim_type, ['model_', sim_type, '_post_processing']), 'file') == 0 &&...
        exist(fullfile('pp_link', sim_type, 'data_postprocessed.mat'), 'file') == 0
    run_pp = 1;
else
    run_pp = 0;
end %if

