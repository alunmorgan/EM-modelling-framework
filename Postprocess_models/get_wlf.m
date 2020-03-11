function get_wlf(root, model_sets)

[model_names, wlf, wlf_3mm, wlf_10mm, wake_length_t, mesh_stepsize, mesh_scaling, n_cores, simulation_time_t] = extract_all_wlf(root, model_sets);
for kfn = 1:size(model_names,1)
    names = model_names(kfn, :)';
    wlf_1mm = wlf(kfn,:)' .* 1E-9;
    wlf_3mm = wlf_3mm(kfn,:)' .* 1E-9;
    wlf_10mm = wlf_10mm(kfn,:)' .*1E-9;
    wake_length = wake_length_t(kfn,:)';
    n_cores = n_cores(kfn, :)';
    simulation_time = simulation_time_t(kfn,:)' ./ 3600;
    mesh_stepsize = mesh_stepsize(kfn,:)' ./ mesh_scaling(kfn,:)' * 1e6;
    T = table(names, wlf_1mm, wlf_3mm, wlf_10mm, wake_length, mesh_stepsize, simulation_time, n_cores);
    disp(T)
end %for

bar(n_cores, simulation_time ./ min(simulation_time))
title('Finding optimum core selection')
xlabel('Number of cores')
ylabel('Multiple of minimum runtime')
