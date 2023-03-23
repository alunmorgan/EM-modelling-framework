function plot_field_slices(fig_handle, data, field_type, slice_dir, ...
                           selected_timeslice, field_levels)


field_components = {'Fx','Fy','Fz'};
time_val = num2str(round(data.timestamp(selected_timeslice)*1E9*100)/100);
main_title_string = strcat(field_type, '-field ', ' slice direction: ', slice_dir, ' at ', time_val, 'ns');
figure(fig_handle)
clf(fig_handle)
annotation('textbox', [0.2, 0.3, 0.3, 0.6], 'String', main_title_string, ...
    'Linestyle', 'none', 'FontWeight', 'bold');
geometry_slice = geometry_from_slice_data(data);
a = sum(geometry_slice,1);
b = sum(geometry_slice,2);
valid_c = (find(a>0, 1, 'first'):find(a>0, 1, 'last'));
valid_r = (find(b>0, 1, 'first'):find(b>0, 1, 'last'));

temp_accum = NaN(length(valid_r), length(valid_c), length(field_components));

for igr = 1:length(field_components)
    slice = squeeze(data.(field_components{igr})(:,:,selected_timeslice));
    slice(geometry_slice==0) = NaN;
    slice = slice(valid_r, valid_c);
    temp_accum(:,:,igr) = slice;
    
    subplot(1, length(field_components) +1, igr)
    if strcmp(slice_dir, 'z') || strcmp(slice_dir, 'z')
        [xaxis, yaxis] = meshgrid(data.coord_1, data.coord_2);
        xaxis = xaxis(valid_c, valid_r);
        yaxis = yaxis(valid_c, valid_r);
        if isnan(field_levels)
            contourf(xaxis.*1e3, yaxis.*1e3, slice', 'LineStyle', 'none')
        else
            slice(1,1) = min(field_levels);
            slice(end,end) = max(field_levels);
            contourf(xaxis.*1e3, yaxis.*1e3, slice', field_levels, 'LineStyle', 'none')
        end %if
        xlabel('Horizontal (mm)')
        ylabel('Vertical (mm)')
    else
        [xaxis, yaxis] = meshgrid(data.coord_2, data.coord_1);
        xaxis = xaxis(valid_r, valid_c);
        yaxis = yaxis(valid_r, valid_c);
        if isnan(field_levels)
            contourf(xaxis.*1e3, yaxis.*1e3, slice, 'LineStyle', 'none')
        else
            slice(1,1) = min(field_levels);
            slice(end,end) = max(field_levels);
            contourf(xaxis.*1e3, yaxis.*1e3, slice, field_levels, 'LineStyle', 'none')
        end %if
        xlabel('Beam direction (mm)')
        if strcmp(slice_dir, 'x') || strcmp(slice_dir, 'x')
            ylabel('Horizontal (mm)')
        elseif strcmp(slice_dir, 'y') || strcmp(slice_dir, 'y')
            ylabel('Vertical (mm)')
        end %if
    end %if
    title(field_components{igr})
    axis equal
    colorbar
    drawnow
end%for

temp_accum = (sum(temp_accum .^2, 3)).^0.5;

subplot(1, length(field_components) +1, igr +1)
if strcmp(slice_dir, 'z') || strcmp(slice_dir, 'z')
    if isnan(field_levels)
        contourf(xaxis.*1e3, yaxis.*1e3, temp_accum',  'LineStyle', 'none')
    else
        temp_accum(1,1) = max(field_levels);
        contourf(xaxis.*1e3, yaxis.*1e3, temp_accum', field_levels, 'LineStyle', 'none')
    end %if
    xlabel('Horizontal (mm)')
    ylabel('Vertical (mm)')
else
    if isnan(field_levels)
        contourf(xaxis.*1e3, yaxis.*1e3, temp_accum, 'LineStyle', 'none')
    else
        temp_accum(1,1) = max(field_levels);
        contourf(xaxis.*1e3, yaxis.*1e3, temp_accum, field_levels, 'LineStyle', 'none')
    end %if
    xlabel('Beam direction (mm)')
    if strcmp(slice_dir, 'x') || strcmp(slice_dir, 'x')
        ylabel('Horizontal (mm)')
    elseif strcmp(slice_dir, 'y') || strcmp(slice_dir, 'y')
        ylabel('Vertical (mm)')
    end %if
end %if
title('Field magnitude')
axis equal
colorbar
drawnow