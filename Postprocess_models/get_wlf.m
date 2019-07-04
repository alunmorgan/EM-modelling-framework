function get_wlf(root, model_sets)

[model_names, wlf, wake_length, metric] = extract_all_wlf(root, model_sets);
for kfn = 1:length(model_names)
        disp([model_names{kfn}, ' ', num2str(wlf(kfn) *1E-9),...
            'mV/pC Wakelength ', num2str(wake_length(kfn)),...
            ' Metric: ', num2str(metric(kfn)), '%'])
end %for