function plot_field_slices(fig_handle, data_Fx, data_Fy, data_Fz, metadata, timestamp, field_type, slice_dir, ...
    field_levels, geometry_slice)

% moved here as parfor was complaining
data.Fx = data_Fx;
data.Fy = data_Fy;
data.Fz = data_Fz;
field_components = {'Fx','Fy','Fz'};
time_val = num2str(round(timestamp*1E9*100)/100);
main_title_string = strcat(field_type, '-field ', ' slice direction: ', slice_dir, ' at ', time_val, 'ns');
set(0,'CurrentFigure',fig_handle) % grab figure window to make plots in it WITHOUT stealing focus.
clf(fig_handle)
annotation('textbox', [0.2, 0.3, 0.3, 0.6], 'String', main_title_string, ...
    'Linestyle', 'none', 'FontWeight', 'bold');

temp_accum = NaN(size(data.Fx,1), size(data.Fx,2), length(field_components));

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


for igr = 1:length(field_components)
    slice = data.(field_components{igr});
    slice(geometry_slice==0) = NaN;
    temp_accum(:,:,igr) = slice;
    subplot(1, length(field_components) +1, igr)

    if isnan(field_levels)
        contourf(xaxis.*1e3, yaxis.*1e3, slice', 'LineStyle', 'none')
    else
        slice(1,1) = min(field_levels);
        slice(end,end) = max(field_levels);
        contourf(xaxis.*1e3, yaxis.*1e3, slice', field_levels, 'LineStyle', 'none')
    end %if
    xlabel(xlab)
    ylabel(ylab)
    title(field_components{igr})
    axis equal
    colorbar
    drawnow
end%for

temp_accum = (sum(temp_accum .^2, 3)).^0.5;

subplot(1, length(field_components) +1, igr +1)

if isnan(field_levels)
    contourf(xaxis.*1e3, yaxis.*1e3, temp_accum',  'LineStyle', 'none')
else
    temp_accum(1,1) = max(field_levels);
    contourf(xaxis.*1e3, yaxis.*1e3, temp_accum', field_levels, 'LineStyle', 'none')
end %if
title('Field magnitude')
axis equal
colorbar
drawnow