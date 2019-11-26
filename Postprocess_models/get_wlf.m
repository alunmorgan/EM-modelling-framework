function get_wlf(root, model_sets)

[model_names, wlf, wlf_3mm, wlf_10mm, wake_length_t, mesh_stepsize, mesh_scaling, decay_to, simulation_time_t] = extract_all_wlf(root, model_sets);
for kfn = 1:size(model_names,1)
    names = model_names(kfn, :)';
    wlf_1mm = wlf(kfn,:)' .* 1E-9;
    wlf_3mm = wlf_3mm(kfn,:)' .* 1E-9;
    wlf_10mm = wlf_10mm(kfn,:)' .*1E-9;
    wake_length = wake_length_t(kfn,:)';
    decay = decay_to(kfn, :)';
    simulation_time = simulation_time_t(kfn,:)' ./ 3600;
    mesh_stepsize = mesh_stepsize(kfn,:)' ./ mesh_scaling(kfn,:)' * 1e6;
    T = table(names, wlf_1mm, wlf_3mm, wlf_10mm, wake_length, mesh_stepsize, simulation_time, decay);
    disp(T)
%     for nfe = 1:size(model_names,2)
%         disp([model_names{kfn, nfe}, ' ', num2str(wlf(kfn, nfe) *1E-9),...
%             'mV/pC ', num2str(wlf_3mm(kfn, nfe) *1E-9),...
%             'mV/pC ', num2str(wlf_10mm(kfn, nfe) *1E-9),...
%             'mV/pC Wakelength ', num2str(wake_length(kfn, nfe)),...
%             ' Decay level: ', num2str(decay_to(kfn, nfe)), ...
%             ' Simulation time: ', num2str(simulation_time(kfn, nfe)), 's ',...
%             ' Mesh density: ', num2str(mesh_density(kfn, nfe))])
%     end %for
end %for