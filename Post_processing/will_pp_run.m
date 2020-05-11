function run_pp = will_pp_run(sim_type, skip_setting)

% works for wake and eigenmode.
if strcmp(skip_setting, 'skip') && exist(fullfile('pp_link', sim_type, 'data_postprocessed.mat'), 'file') == 7
    run_pp = 0;
elseif strcmp(skip_setting, 'skip') && exist(fullfile('pp_link', sim_type, 'data_postprocessed.mat'), 'file') == 0
    run_pp = 1;
elseif strcmp(skip_setting, 'no_skip')
    run_pp = 1;
else
    error('Please select skip or no_skip for the postprocessing')
end %if
