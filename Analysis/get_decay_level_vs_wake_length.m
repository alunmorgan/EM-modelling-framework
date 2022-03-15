function get_decay_level_vs_wake_length(root, model)

full_path = fullfile(root, model);
wanted_files = full_path(contains(full_path, 'data_analysed_wake.mat'));
if isempty(wanted_files)
    disp(['No analysed files found for ',model,', please run analyse_pp_data.'])
    return
else
    disp(['Getting wake loss factors for ',model])
end %if
split_str = regexp(wanted_files, ['\',filesep], 'split');
for ind = 1:length(wanted_files)
    current_folder = fileparts(wanted_files{ind});
    load(fullfile(current_folder, 'data_postprocessed'), 'pp_data');
    load(fullfile(current_folder, 'data_analysed_wake'),'wake_sweep_data');
    load(fullfile(current_folder, 'run_inputs'), 'modelling_inputs');
    load(fullfile(current_folder, 'data_from_run_logs.mat'), 'run_logs');
    model_names{sts,ind} = split_str{ind}{end - 2};
    wlf(sts,ind) = wake_sweep_data.time_domain_data{end}.wake_loss_factor;
    wake_length(sts,ind) = (round(((wake_sweep_data.time_domain_data{end}.timebase(end)) *3e8)*100))/100;
    mesh_density(sts, ind) = str2num(modelling_inputs.mesh_stepsize);
    pling = max(abs(pp_data.Wake_potential(:,2)));
    % now looking at the last ~10ps of data
    tail = max(abs(pp_data.Wake_potential(end-600:end,2)));
    decay_to(sts,ind) = mean(abs(tail));
    simulation_time(sts, ind) = run_logs.wall_time;
    clear pp_data wake_data
end %for
wlf = wlf .* 1e-9;
myfittype = fittype('a - b .* exp(-c *x)', 'dependent', {'y'},...
    'independent', {'x'},...
    'coefficients', {'a', 'b', 'c'});
myfit = fit(mesh_density', wlf', myfittype);
[min_mesh_density, I] = min(mesh_density);
a = myfit.a;
b = myfit.b;
c = myfit.c;
x = linspace(min_mesh_density/10, min_mesh_density, 10);
y = a - b .* exp(-c *x);
next_y = a - b .* exp(-c *min_mesh_density/2);
next_y_improvement = round((wlf(I) - next_y) / wlf(I) *100*10)/10; % percentage reduction
next_next_y = a - b .* exp(-c *min_mesh_density/4);
next_next_y_improvement = round((wlf(I) - next_next_y) / wlf(I) *100 *10) /10; % percentage reduction
figure(2)
plot(myfit,mesh_density, wlf)
hold on
plot(x,y, ':g', 'DisplayName', 'Extrapolation')
plot(min_mesh_density/2, next_y, '+k', 'DisplayName',[num2str(next_y_improvement),'% improvement. Calculation time ~ ', num2str(round(simulation_time(I)/3600*2^4)), 'hrs'])
plot(min_mesh_density/4, next_next_y, '+k', 'DisplayName',[num2str(next_next_y_improvement),'% improvement. Calculation time ~ ', num2str(round(simulation_time(I)/3600*4^4)), 'hrs'])
legend('Location', 'NorthWest')
xlabel('Mesh density')
ylabel('Wake loss factor mV/pC')
title(regexprep(model_names{1,1}, '_', ' '))
hold off