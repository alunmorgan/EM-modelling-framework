function get_wlf(root, model_sets)

model_names = {};
wlf = {};
for kfn = 1:length(model_sets)
    disp(['************ ', model_sets{kfn}, ' ***************'])
    [model_names{kfn}, wlf{kfn}, wake_length{kfn}, metric{kfn}] = extract_all_wlf(root, model_sets{kfn});
    for ind = 1:length(model_names{kfn})
        disp([model_names{kfn}{ind}, ' ', num2str(wlf{kfn}(ind) *1E-9),...
            'mV/pC Wakelength ', num2str(wake_length{kfn}(ind)),...
            ' Metric: ', num2str(metric{kfn}(ind)), '%'])
    end %for
end %for