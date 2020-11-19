function plot_wake_potential(h_wake, path_to_data,timebase_wp, cut_time_ind, ...
    wp, wpdx, lw, wpdy, wpqx, wpqy)

clf(h_wake)
ax(6) = axes('Parent', h_wake);
minxlim = timebase_wp(1);
maxxlim = timebase_wp(cut_time_ind);
hold(ax(6), 'all')
plot(timebase_wp(1:cut_time_ind), wp(1:cut_time_ind),...
    'LineWidth',lw, 'Parent', ax(6))
minxlim = min([minxlim, timebase_wp(1)]);
maxxlim = max([maxxlim, timebase_wp(cut_time_ind)]);
title('Evolution of longitudinal wake potential in the structure', 'Parent', ax(6))
xlabel('Time (ns)', 'Parent', ax(6))
xlim([minxlim maxxlim])
ylabel('Wake potential (V/pC)', 'Parent', ax(6))
savemfmt(h_wake, path_to_data,'wake_potential')
clf(h_wake)

ax_num=50;
ax(ax_num) = axes('Parent', h_wake);
minxlim = timebase_wp(1);
maxxlim = timebase_wp(cut_time_ind);
hold(ax(ax_num), 'all')
plot(timebase_wp(1:cut_time_ind), wpdx(1:cut_time_ind),...
    'LineWidth',lw, 'Parent', ax(ax_num))
minxlim = min([minxlim, timebase_wp(1)]);
maxxlim = max([maxxlim, timebase_wp(cut_time_ind)]);
title('Evolution of dipole transverse wake potential in the structure (x)', 'Parent', ax(ax_num))
xlabel('Time (ns)', 'Parent', ax(ax_num))
xlim([minxlim maxxlim])
ylabel('Wake potential (V/pC)', 'Parent', ax(ax_num))
savemfmt(h_wake, path_to_data,'transverse_dipole_y_wake_potential')
clf(h_wake)

ax_num=51;
ax(ax_num) = axes('Parent', h_wake);
minxlim = timebase_wp(1);
maxxlim = timebase_wp(cut_time_ind);
hold(ax(ax_num), 'all')
plot(timebase_wp(1:cut_time_ind), wpdy(1:cut_time_ind),...
    'LineWidth',lw, 'Parent', ax(ax_num))
minxlim = min([minxlim, timebase_wp(1)]);
maxxlim = max([maxxlim, timebase_wp(cut_time_ind)]);
title('Evolution of dipole transverse wake potential in the structure (y)', 'Parent', ax(ax_num))
xlabel('Time (ns)', 'Parent', ax(ax_num))
xlim([minxlim maxxlim])
ylabel('Wake potential (V/pC)', 'Parent', ax(ax_num))
savemfmt(h_wake, path_to_data,'transverse_dipole_y_wake_potential')
clf(h_wake)

ax_num=52;
ax(ax_num) = axes('Parent', h_wake);
minxlim = timebase_wp(1);
maxxlim = timebase_wp(cut_time_ind);
hold(ax(ax_num), 'all')
plot(timebase_wp(1:cut_time_ind), wpqx(1:cut_time_ind),...
    'LineWidth',lw, 'Parent', ax(ax_num))
minxlim = min([minxlim, timebase_wp(1)]);
maxxlim = max([maxxlim, timebase_wp(cut_time_ind)]);
title('Evolution of quadrupole transverse wake potential in the structure (x)', 'Parent', ax(ax_num))
xlabel('Time (ns)', 'Parent', ax(ax_num))
xlim([minxlim maxxlim])
ylabel('Wake potential (V/pC)', 'Parent', ax(ax_num))
savemfmt(h_wake, path_to_data,'transverse_quadrupole_x_wake_potential')
clf(h_wake)

ax_num=53;
ax(ax_num) = axes('Parent', h_wake);
minxlim = timebase_wp(1);
maxxlim = timebase_wp(cut_time_ind);
hold(ax(ax_num), 'all')
plot(timebase_wp(1:cut_time_ind), wpqy(1:cut_time_ind),...
    'LineWidth',lw, 'Parent', ax(ax_num))
minxlim = min([minxlim, timebase_wp(1)]);
maxxlim = max([maxxlim, timebase_wp(cut_time_ind)]);
title('Evolution of quadrupole transverse wake potential in the structure (y)', 'Parent', ax(ax_num))
xlabel('Time (ns)', 'Parent', ax(ax_num))
xlim([minxlim maxxlim])
ylabel('Wake potential (V/pC)', 'Parent', ax(ax_num))
savemfmt(h_wake, path_to_data,'transverse_quadrupole_y_wake_potential')
clf(h_wake)