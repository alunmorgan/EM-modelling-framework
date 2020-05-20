function get_wlf(model_sets)


[root, ~, ~] = analysis_model_settings_library;
[model_names, wlf, wake_length_t, mesh_stepsize, mesh_scaling, n_cores, simulation_time] = extract_all_wlf(root, model_sets);
wlf = wlf .* 1E-9;
% wlf_1mm = wlf_1mm .* 1E-9;
%     wlf_3mm = wlf_3mm .* 1E-9;
%     wlf_10mm = wlf_10mm .*1E-9;
     simulation_time = simulation_time ./ 3600;
    mesh_stepsize = mesh_stepsize ./ mesh_scaling .* 1e6;
for kfn = 1:size(model_names,1)
%     T = table(model_names(kfn, :)', wlf_1mm(kfn,:)', wlf_3mm(kfn,:)', ...
%         wlf_10mm(kfn,:)', wake_length_t(kfn,:)', mesh_stepsize(kfn,:)', ...
%         simulation_time(kfn,:)', n_cores(kfn,:)');
T = table(model_names(kfn, :)', wlf(kfn,:)', wake_length_t(kfn,:)', mesh_stepsize(kfn,:)', ...
        simulation_time(kfn,:)', n_cores(kfn,:)');
    disp(T)
end %for

% bar(n_cores, simulation_time ./ min(simulation_time))
% title('Finding optimum core selection')
% xlabel('Number of cores')
% ylabel('Multiple of minimum runtime')
