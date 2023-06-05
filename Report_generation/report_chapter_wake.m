function  [w_ltx, w_appnd] = report_chapter_wake(results_path, ppi, port_overrides, chosen_wake_length)

load(fullfile(results_path,'run_inputs.mat'), 'modelling_inputs');
% Load up the data extracted from the run log.
load(fullfile(results_path, 'data_from_run_logs.mat'), 'run_logs')
% Load up post processing inputs
%     load(fullfile(results_path, 'wake', 'pp_inputs.mat'), 'ppi')
report_input.model_name = regexprep(modelling_inputs.model_name,'_',' ');
report_input.doc_root = results_path;
% Load up the post precessed data.
load(fullfile(results_path, 'data_postprocessed.mat'), 'pp_data')
load(fullfile(results_path, 'data_analysed_wake.mat'), 'wake_sweep_data')
for nw = 1:length(wake_sweep_data.raw)
    wake_sweep_vals(nw) = wake_sweep_data.raw{1, nw}.wake_setup.Wake_length;
end %for
chosen_wake_ind = find(wake_sweep_vals == str2double(chosen_wake_length));
if isempty(chosen_wake_ind)
    [~,chosen_wake_ind] = min(abs((wake_sweep_vals ./ str2double(chosen_wake_length)) - 1));
    fprinf('\nChosen wake length not found. Setting the wakelength to maximum value.')
end %if
wake_data.port_time_data = wake_sweep_data.time_domain_data{chosen_wake_ind}.port_data;
wake_data.time_domain_data = wake_sweep_data.time_domain_data{chosen_wake_ind};
wake_data.frequency_domain_data = wake_sweep_data.frequency_domain_data{chosen_wake_ind};

first_name = fieldnames(run_logs);
% [mb_param_list, mb_param_vals, ...
%     geom_param_list, geom_param_vals ] = extract_parameters(run_logs, modelling_inputs);

[w_ltx, w_appnd] = Generate_wake_report(results_path, ...
    pp_data, wake_data, modelling_inputs, ppi, port_overrides, run_logs);