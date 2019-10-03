function get_wlf_vs_mesh_density(root, model_set)

[model_names, wlf, ~, mesh_line_spacing, ~, simulation_time] = extract_all_wlf(root, {model_set});
wlf = wlf .* 1e-9;
[min_mesh_line_spacing, I] = min(mesh_line_spacing);
x = linspace(min_mesh_line_spacing/10, min_mesh_line_spacing, 10);

myfittype = fittype('a - b .* exp(-c *x)', 'dependent', {'y'},...
    'independent', {'x'},...
    'coefficients', {'a', 'b', 'c'});
myfit = fit(mesh_line_spacing', wlf', myfittype);
a = myfit.a;
b = myfit.b;
c = myfit.c;

y = a - b .* exp(-c *x);
next_y = a - b .* exp(-c *min_mesh_line_spacing/2);
next_y_improvement = round((wlf(I) - next_y) / wlf(I) *100*10)/10; % percentage reduction
next_next_y = a - b .* exp(-c *min_mesh_line_spacing/4);
next_next_y_improvement = round((wlf(I) - next_next_y) / wlf(I) *100 *10) /10; % percentage reduction

[course_mesh, cm_ind] = max(mesh_line_spacing);
myfittype2 = fittype('d + e.* (x).^4', 'dependent', {'y'},...
    'independent', {'x'},...
    'problem',{'d'},...
    'coefficients', {'e'});
myfit2 = fit(1-mesh_line_spacing'./course_mesh, simulation_time', myfittype2, ...
'problem',{simulation_time(cm_ind)});
e = myfit2.e;
y_time = simulation_time(cm_ind) + e .* (1-x./course_mesh).^4;
 next_time = simulation_time(cm_ind) + e .* (1 - (min_mesh_line_spacing/2) ./ course_mesh ).^4;
 next_next_time = simulation_time(cm_ind) + e .* (1 - (min_mesh_line_spacing/4) ./ course_mesh).^4;

figure(41)
plot(myfit2,1-mesh_line_spacing./course_mesh, simulation_time)
hold on 
plot(1-x/course_mesh, y_time, ':k')
plot(1 - (min_mesh_line_spacing/2) ./ course_mesh, next_time,'*')
plot(1 - (min_mesh_line_spacing/4) ./ course_mesh, next_next_time,'*')
hold off
legend('Location', 'NorthEast')
xlabel('Mesh line spacing')
ylabel('Simulation time (s)')
title(regexprep(model_names{1,1}, '_', ' '))

figure(2)
plot(myfit,mesh_line_spacing, wlf)
hold on 
plot(x,y, ':g', 'DisplayName', 'Extrapolation')
plot(min_mesh_line_spacing/2, next_y, '+k', 'DisplayName',[num2str(next_y_improvement),'% improvement. Calculation time ~ ', num2str(round(next_time/360)/10), 'hrs'])
plot(min_mesh_line_spacing/4, next_next_y, '+k', 'DisplayName',[num2str(next_next_y_improvement),'% improvement. Calculation time ~ ', num2str(round(next_next_time/360)/10), 'hrs'])
legend('Location', 'Best')
xlabel('Mesh line spacing')
ylabel('Wake loss factor mV/pC')
title(regexprep(model_names{1,1}, '_', ' '))
hold off