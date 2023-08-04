function plot_field_component(fig_handle, slice, metadata, timestamp, field_type, slice_dir, ...
    field_component, field_levels, geometry_slice)


time_val = num2str(round(timestamp*1E9*100)/100);
main_title_string = strcat(field_type, '-field ','component ', field_component, ' slice direction: ', slice_dir, ' at ', time_val, 'ns');
set(0,'CurrentFigure',fig_handle) % grab figure window to make plots in it WITHOUT stealing focus.

clf(fig_handle)
annotation('textbox', [0.2, 0.3, 0.3, 0.6], 'String', main_title_string, ...
    'Linestyle', 'none', 'FontWeight', 'bold');

slice(geometry_slice==0) = NaN;

if strcmp(slice_dir, 'z')
    [xaxis, yaxis] = meshgrid(metadata.coord_x, metadata.coord_y);
    xlab = 'Horizontal (mm)';
    ylab = 'Vertical (mm)';
elseif strcmp(slice_dir, 'x')
    [xaxis, yaxis] = meshgrid(metadata.coord_y, metadata.coord_z);
    xlab = 'Vertical (mm)';
    ylab = 'Beam direction (mm)';
elseif strcmp(slice_dir, 'y')
    [xaxis, yaxis] = meshgrid(metadata.coord_x, metadata.coord_z);
    xlab = 'Horizontal (mm)';
    ylab = 'Beam direction (mm)';
end %if
if isnan(field_levels)
    contourf(xaxis.*1e3, yaxis.*1e3, slice', 'LineStyle', 'none')
else
    slice(1,1) = min(field_levels);
    slice(end,end) = max(field_levels);
    contourf(xaxis.*1e3, yaxis.*1e3, slice', field_levels, 'LineStyle', 'none')
end %if
xlabel(xlab)
ylabel(ylab)
title(field_component)
axis equal
colorbar

