function plot_z_slice_fields(f_handle, xaxis, yaxis, slice, slice_dir, field_component, field_type, actual_time, field_limits)


if strcmp(slice_dir, 'z')
    xlab = 'Horizontal (mm)';
    ylab = 'Vertical (mm)';
elseif strcmp(slice_dir, 'y')
    xlab = 'Vertical (mm)';
    ylab = 'Longitudinal (mm)';
elseif strcmp(slice_dir, 'x')
    xlab = 'Horizontal (mm)';
    ylab = 'Longitudinal (mm)';
end %if
if strcmp(field_type, 'e')
    field_label = 'Field (Vm^{-1})';
elseif strcmp(field_type, 'h')
    field_label = 'Field (H TEMP)';
end %if

figure(f_handle)
drawnow; pause(0.1)
subplot(2,2,1)
contourf(xaxis.*1e3, yaxis.*1e3, slice', 'LineStyle', 'none')
xlabel(xlab)
ylabel(ylab)
title(strcat(slice_dir, '=0 - ',field_type, field_component, ' time=', actual_time))
axis equal
colorbar
drawnow

xax = xaxis(1,:);
yax = yaxis(:,1);
x_cut_ind = find(abs(diff(sign(xax),1)) > 0, 1, 'first');
y_cut_ind = find(abs(diff(sign(yax),1)) > 0, 1, 'first');

subplot(2,2,3)
plot(xax.*1E3, slice(:, y_cut_ind), 'LineWidth', 2)
xlabel(xlab)
ylabel(field_label)
axis tight
if nargin > 8
    ylim(field_limits)
end %if
drawnow

subplot(2,2,2)
plot(slice(x_cut_ind,:),yax.*1E3, 'LineWidth', 2)
xlabel(field_label)
ylabel(ylab)
axis tight
if nargin > 8
    xlim(field_limits)
end %if
drawnow; pause(0.1)

subplot(2,2,4)
waterfall(xaxis.*1e3, yaxis.*1e3, slice')
xlabel(xlab)
ylabel(ylab)
zlabel('Field magnitude')
axis tight
if nargin > 8
    zlim(field_limits)
end %if
drawnow; pause(0.1)

