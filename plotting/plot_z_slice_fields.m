function plot_z_slice_fields(f_handle, xaxis, yaxis, slice, slice_dir, field_dir, actual_time, field_limits)
figure(f_handle)
subplot(2,2,1)
contourf(xaxis.*1e3, yaxis.*1e3, slice', 'LineStyle', 'none')
if contains(slice_dir, 'fieldsz')
    xlabel('Horizontal (mm)')
    ylabel('Vertical (mm)')
    x_cut_ind = find(abs(diff(sign(xaxis(1,:)),1)) > 0, 1, 'first');
    y_cut_ind = find(abs(diff(sign(yaxis(:,1)),1)) > 0, 1, 'first');
elseif contains(slice_dir, 'fieldsy')
    xlabel('Vertical (mm)')
    ylabel('Longitudinal (mm)')
    y_cut_ind = find(abs(diff(sign(xaxis(1,:)),1)) > 0, 1, 'first');
    x_cut_ind = find(abs(diff(sign(yaxis(:,1)),1)) > 0, 1, 'first');
elseif contains(slice_dir, 'fieldsx')
    xlabel('Horizontal (mm)')
    ylabel('Longitudinal (mm)')
    y_cut_ind = find(abs(diff(sign(xaxis(1,:)),1)) > 0, 1, 'first');
    x_cut_ind = find(abs(diff(sign(yaxis(:,1)),1)) > 0, 1, 'first');
end %if
title([slice_dir, '=0 - ', field_dir, ' time=', actual_time])
axis equal
colorbar
subplot(2,2,3)


plot(squeeze(xaxis(1,:)).*1E3, slice(:, x_cut_ind), 'LineWidth', 2)
if contains(slice_dir, 'fieldsz')
    xlabel('Horizontal (mm)')
elseif contains(slice_dir, 'fieldsy')
    xlabel('Vertical (mm)')
elseif contains(slice_dir, 'fieldsx')
    xlabel('Horizontal (mm)')
end %if
if strcmp(slice_dir(1), 'e')
    ylabel('Field (Vm^{-1})')
elseif strcmp(slice_dir(1), 'h')
    ylabel('Field (H TEMP)')
end %if
axis tight
if nargin > 7
    ylim(field_limits)
end %if


subplot(2,2,2)
plot(slice(y_cut_ind,:),squeeze(yaxis(:,1)).*1E3, 'LineWidth', 2)
xlabel('Field (Vm^{-1})')
if contains(slice_dir, 'fieldsz')
    ylabel('Vertical (mm)')
elseif contains(slice_dir, 'fieldsy')
    ylabel('Longitudinal (mm)')
elseif contains(slice_dir, 'fieldsx')
    ylabel('Longitudinal (mm)')
end %if
axis tight
if nargin > 7
    xlim(field_limits)
end %if

end %function


