function plot_z_slice_fields(f_handle, xaxis, yaxis, slice, slice_dir, field_dir, field_limits)
figure(f_handle)
subplot(2,2,1)
contourf(xaxis.*1e3, yaxis.*1e3, slice', 'LineStyle', 'none')
if strcmp(slice_dir, 'efieldsz')
    xlabel('Horizontal (mm)')
    ylabel('Vertical (mm)')
    x_cut_ind = find(abs(diff(sign(xaxis(1,:)),1)) > 0, 1, 'first');
    y_cut_ind = find(abs(diff(sign(yaxis(:,1)),1)) > 0, 1, 'first');
elseif strcmp(slice_dir, 'efieldsy')
    xlabel('Vertical (mm)')
    ylabel('Longitudinal (mm)')
    y_cut_ind = find(abs(diff(sign(xaxis(1,:)),1)) > 0, 1, 'first');
    x_cut_ind = find(abs(diff(sign(yaxis(:,1)),1)) > 0, 1, 'first');
elseif strcmp(slice_dir, 'efieldsx')
    xlabel('Horizontal (mm)')
    ylabel('Longitudinal (mm)')
    y_cut_ind = find(abs(diff(sign(xaxis(1,:)),1)) > 0, 1, 'first');
    x_cut_ind = find(abs(diff(sign(yaxis(:,1)),1)) > 0, 1, 'first');
end %if
title([slice_dir, '=0 - ', field_dir])
axis equal
colorbar
subplot(2,2,3)


plot(squeeze(xaxis(1,:)).*1E3, slice(:, x_cut_ind))
if strcmp(slice_dir, 'efieldsz')
    xlabel('Horizontal (mm)')
elseif strcmp(slice_dir, 'efieldsy')
    xlabel('Vertical (mm)')
elseif strcmp(slice_dir, 'efieldsx')
    xlabel('Horizontal (mm)')
end %if
ylabel('Field (Vm^{-1})')
axis tight
if nargin > 6
    ylim(field_limits)
end %if


subplot(2,2,2)
plot(slice(y_cut_ind,:),squeeze(yaxis(:,1)).*1E3)
xlabel('Field (Vm^{-1})')
if strcmp(slice_dir, 'efieldsz')
    ylabel('Vertical (mm)')
elseif strcmp(slice_dir, 'efieldsy')
    ylabel('Longitudinal (mm)')
elseif strcmp(slice_dir, 'efieldsx')
    ylabel('Longitudinal (mm)')
end %if
axis tight
if nargin > 6
    xlim(field_limits)
end %if

end %function


