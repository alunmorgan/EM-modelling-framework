function plot_z_slice_fields(f_handle, metadata, slice, slice_dir, field_component, field_type, actual_time, field_limits)


if strcmp(slice_dir, 'z')
    xlab = 'Horizontal (mm)';
    ylab = 'Vertical (mm)';
    xaxis = metadata.coord_x;
    yaxis = metadata.coord_y;
elseif strcmp(slice_dir, 'y')
    xlab = 'Vertical (mm)';
    ylab = 'Longitudinal (mm)';
    xaxis = metadata.coord_x;
    yaxis = metadata.coord_z;
elseif strcmp(slice_dir, 'x')
    xlab = 'Horizontal (mm)';
    ylab = 'Longitudinal (mm)';
    xaxis = metadata.coord_y;
    yaxis = metadata.coord_z;
end %if
if strcmpi(field_type, 'e')
    field_label = 'Field (Vm^{-1})';
elseif strcmpi(field_type, 'h')
    field_label = 'Field (Am^{-1})';
end %if

set(0,'CurrentFigure',f_handle) % grab figure window to make plots in it WITHOUT stealing focus.
drawnow; pause(0.1)
subplot(2,2,1)
contourf(xaxis.*1e3, yaxis.*1e3, slice', 'LineStyle', 'none')
xlabel(xlab)
ylabel(ylab)
title(strcat(slice_dir, '=0 - ',field_type, field_component, ' time=', num2str(round(actual_time*1E9*100)/100)))
axis equal
colorbar
drawnow

x_cut_ind = find(abs(diff(sign(xaxis),1)) > 0, 1, 'first');
y_cut_ind = find(abs(diff(sign(yaxis),1)) > 0, 1, 'first');

subplot(2,2,3)
plot(xaxis.*1E3, slice(:, y_cut_ind), 'LineWidth', 2)
xlabel(xlab)
ylabel(field_label)
axis tight
if nargin > 8
    ylim(field_limits)
end %if
drawnow

subplot(2,2,2)
plot(slice(x_cut_ind,:),yaxis.*1E3, 'LineWidth', 2)
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

