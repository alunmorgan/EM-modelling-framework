function get_wlf_vs_mesh_density(root, model_set)

[model_names, wlf, ~, mesh_density, ~, simulation_time] = extract_all_wlf(root, {model_set});
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