function plot_wake_impedance(h_wake, path_to_data, pp_data, ...
    frequency_scale_wi, wi_re, graph_freq_lim, wi_im, ...
    wi_quad_x, wi_quad_y,wi_quad_x_comp, wi_quad_y_comp,...
    wi_dipole_x, wi_dipole_y,  wi_dipole_x_comp, wi_dipole_y_comp)

ax(7) = axes('Parent', h_wake);
plot(frequency_scale_wi, wi_re, 'b', 'Parent', ax(7));
hold(ax(7), 'on')
plot(pp_data.Wake_impedance(:,1)*1e-9, pp_data.Wake_impedance(:,2), 'r', 'Parent', ax(7))
hold(ax(7), 'off')
title('Longditudinal real wake impedance', 'Parent', ax(7))
xlabel('Frequency (GHz)', 'Parent', ax(7))
ylabel('Impedance (Ohms)', 'Parent', ax(7))
xlim([0 graph_freq_lim])
ylim([0 inf])
savemfmt(h_wake, path_to_data,'longditudinal_real_wake_impedance')
clf(h_wake)

ax(8) = axes('Parent', h_wake);
plot(frequency_scale_wi, wi_im, 'b', 'Parent', ax(8));
title('Longditudinal imaginary wake impedance', 'Parent', ax(8))
xlabel('Frequency (GHz)', 'Parent', ax(8))
ylabel('Impedance (Ohms)', 'Parent', ax(8))
xlim([0 graph_freq_lim])
savemfmt(h_wake, path_to_data, 'longditudinal_imaginary_wake_impedance')
clf(h_wake)

ax(9) = axes('Parent', h_wake);
plot(wi_quad_x.scale, wi_quad_x.data, 'b', 'Parent', ax(9));
hold(ax(9), 'on')
plot(wi_quad_x_comp.scale, wi_quad_x_comp.data, 'b', 'Parent', ax(9));
hold(ax(9), 'off')
title('Transverse X real quadrupole wake impedance', 'Parent', ax(9))
legend('Matlab', 'GdfidL')
xlabel('Frequency (GHz)', 'Parent', ax(9))
ylabel('Impedance (Ohms)', 'Parent', ax(9))
xlim([0 graph_freq_lim])
ylim([0 inf])
savemfmt(h_wake, path_to_data, 'Transverse_X_real_quadrupole_wake_impedance')
clf(h_wake)

ax(10) = axes('Parent', h_wake);
plot(wi_quad_y.scale, wi_quad_y.data, 'b', 'Parent', ax(10));
hold(ax(10), 'on')
plot(wi_quad_y_comp.scale, wi_quad_y_comp.data, 'b', 'Parent', ax(10));
hold(ax(10), 'off')
legend('Matlab', 'GdfidL')
title('Transverse Y real quadrupole wake impedance', 'Parent', ax(10))
xlabel('Frequency (GHz)', 'Parent', ax(10))
ylabel('Impedance (Ohms)', 'Parent', ax(10))
xlim([0 graph_freq_lim])
ylim([0 inf])
savemfmt(h_wake, path_to_data,'Transverse_Y_real_quadrupole_wake_impedance')
clf(h_wake)

ax_num = 41;
ax(ax_num) = axes('Parent', h_wake);
plot(wi_dipole_x.scale, wi_dipole_x.data, 'b', 'Parent', ax(ax_num));
hold(ax(ax_num), 'on')
plot(wi_dipole_x_comp.scale, wi_dipole_x_comp.data, 'b', 'Parent', ax(ax_num));
hold(ax(ax_num), 'off')
legend('Matlab', 'GdfidL')
title('Transverse X real dipole wake impedance', 'Parent', ax(ax_num))
xlabel('Frequency (GHz)', 'Parent', ax(ax_num))
ylabel('Impedance (Ohms)', 'Parent', ax(ax_num))
xlim([0 graph_freq_lim])
ylim([0 inf])
savemfmt(h_wake, path_to_data, 'Transverse_X_real_dipole_wake_impedance')
clf(h_wake)

ax_num = 42;
ax(ax_num) = axes('Parent', h_wake);
plot(wi_dipole_y.scale, wi_dipole_y.data, 'b', 'Parent', ax(ax_num));
hold(ax(ax_num), 'on')
plot(wi_dipole_y_comp.scale, wi_dipole_y_comp.data, 'b', 'Parent', ax(ax_num));
hold(ax(ax_num), 'off')
legend('Matlab', 'GdfidL')
title('Transverse Y real dipole wake impedance', 'Parent', ax(ax_num))
xlabel('Frequency (GHz)', 'Parent', ax(ax_num))
ylabel('Impedance (Ohms)', 'Parent', ax(ax_num))
xlim([0 graph_freq_lim])
ylim([0 inf])
savemfmt(h_wake, path_to_data,'Transverse_Y_real_dipole_wake_impedance')
clf(h_wake)