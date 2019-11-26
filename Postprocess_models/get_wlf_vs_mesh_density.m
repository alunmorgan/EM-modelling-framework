function get_wlf_vs_mesh_density(root, model_set)

[model_names, wlf, wlf_3mm, wlf_10mm, ~, mesh_stepsize, mesh_scaling, ~, simulation_time] = extract_all_wlf(root, {model_set});
wlf = wlf .* 1e-9;
wlf_3mm = wlf_3mm .* 1e-9;
wlf_10mm = wlf_10mm .* 1e-9;

% if sum(diff(mesh_line_spacing)) == 0 % no variation in line spacing parameter.
mesh_line_spacing = mesh_stepsize ./ mesh_scaling;
% end %if
[min_mesh_line_spacing, ~] = min(mesh_line_spacing);
    
x = linspace(min_mesh_line_spacing/10, min_mesh_line_spacing, 10);

[myfit_wake_1mm, y_1mm, next_y_1mm, next_next_y_1mm, ...
    next_y_1mm_improvement, next_next_y_1mm_improvement ] = fitting_wlf_vs_mls(mesh_line_spacing, wlf, x);
[myfit_wake_3mm, y_3mm, ~, ~, ~, ~ ] = fitting_wlf_vs_mls(mesh_line_spacing, wlf_3mm, x);
[myfit_wake_10mm, y_10mm, ~, ~, ~, ~ ] = fitting_wlf_vs_mls(mesh_line_spacing, wlf_10mm, x);

% fitting to simulation time vs mesh line spacing data.
[course_mesh, cm_ind] = max(mesh_line_spacing);
myfittype2 = fittype('d + e.* (x).^4', 'dependent', {'y'},...
    'independent', {'x'},...
    'problem',{'d'},...
    'coefficients', {'e'});
myfit2 = fit(1-mesh_line_spacing'./course_mesh, simulation_time', myfittype2, ...
'problem',{simulation_time(cm_ind)});

y_time = simulation_time(cm_ind) + myfit2.e .* (1-x./course_mesh).^4;
 next_time = simulation_time(cm_ind) + myfit2.e .* (1 - (min_mesh_line_spacing/2) ./ course_mesh ).^4;
 next_next_time = simulation_time(cm_ind) + myfit2.e .* (1 - (min_mesh_line_spacing/4) ./ course_mesh).^4;

figure(41)
plot(myfit2,1-mesh_line_spacing./course_mesh, simulation_time)
hold on 
plot(1-x/course_mesh, y_time, ':k')
plot(1 - (min_mesh_line_spacing/2) ./ course_mesh, next_time,'*')
plot(1 - (min_mesh_line_spacing/4) ./ course_mesh, next_next_time,'*')
hold off
legend('Location', 'NorthWest')
ylabel('Simulation time (s)')
title(regexprep(model_names{1,1}, '_', ' '))

figure(42)
plot(myfit_wake_1mm, mesh_line_spacing, wlf)
hold on 
plot(x,y_1mm, ':g', 'DisplayName', 'Extrapolation')
plot(min_mesh_line_spacing/2, next_y_1mm, '+k', 'DisplayName',[num2str(next_y_1mm_improvement),'% improvement. Calculation time ~ ', num2str(round(next_time/360)/10), 'hrs'])
plot(min_mesh_line_spacing/4, next_next_y_1mm, '+k', 'DisplayName',[num2str(next_next_y_1mm_improvement),'% improvement. Calculation time ~ ', num2str(round(next_next_time/360)/10), 'hrs'])
legend('Location', 'Best')
xlabel('Mesh line spacing (m)')
ylabel('Wake loss factor mV/pC')
title(regexprep(model_names{1,1}, '_', ' '))
hold off

figure(43)
plot(myfit_wake_3mm, mesh_line_spacing, wlf_3mm)
hold on 
plot(x,y_3mm, ':g', 'DisplayName', 'Extrapolation')
legend('Location', 'Best')
xlabel('Mesh line spacing (m)')
ylabel('Wake loss factor mV/pC')
title(regexprep(model_names{1,1}, '_', ' '))
hold off

figure(44)
plot(myfit_wake_10mm, mesh_line_spacing, wlf_10mm)
hold on 
plot(x,y_10mm, ':g', 'DisplayName', 'Extrapolation')
legend('Location', 'Best')
xlabel('Mesh line spacing (m)')
ylabel('Wake loss factor mV/pC')
title(regexprep(model_names{1,1}, '_', ' '))
hold off

function [myfit_wake, y, next_y, next_next_y, ...
    next_y_improvement, next_next_y_improvement ] = fitting_wlf_vs_mls(mesh_line_spacing, wlf, x)

% make the x axit increasing.
[mesh_line_spacing, I] = sort(mesh_line_spacing);
wlf = wlf(I);
% Fitting to wlf vs mesh line spacing data.
myfittype = fittype('a - b .* exp(-c *x)', 'dependent', {'y'},...
    'independent', {'x'},...
    'coefficients', {'a', 'b', 'c'});

myfit_wake = fit(mesh_line_spacing', wlf', myfittype);

% calculate the extrapolation.
y = myfit_wake.a - myfit_wake.b .* exp(-myfit_wake.c * x);

[min_mesh_line_spacing, I_spacing] = min(mesh_line_spacing);
next_y = myfit_wake.a - myfit_wake.b .* exp(-myfit_wake.c *min_mesh_line_spacing/2);
next_y_improvement = round((wlf(I_spacing) - next_y) / wlf(I_spacing) *100*10)/10; % percentage reduction
next_next_y = myfit_wake.a - myfit_wake.b .* exp(-myfit_wake.c *min_mesh_line_spacing/4);
next_next_y_improvement = round((wlf(I_spacing) - next_next_y) / wlf(I_spacing) *100 *10) /10; % percentage reduction
